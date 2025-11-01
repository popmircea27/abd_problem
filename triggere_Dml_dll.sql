CREATE OR REPLACE PACKAGE general_log_api AS
  PROCEDURE log_event(
    p_action_type IN VARCHAR2,      -- 'INSERT' / 'UPDATE' / 'DELETE' / 'DDL' / 'ASSIGN' / etc.
    p_table_name  IN VARCHAR2,
    p_record_key  IN VARCHAR2,
    p_message     IN VARCHAR2 DEFAULT NULL,
    p_details     IN CLOB DEFAULT NULL
  );

  -- helperi utili
  FUNCTION make_ctx_json RETURN CLOB;   -- context sesiune ca JSON
  FUNCTION make_kv_json(p_key IN VARCHAR2, p_val IN VARCHAR2) RETURN CLOB;
END general_log_api;
/
CREATE OR REPLACE PACKAGE BODY general_log_api AS
  PRAGMA AUTONOMOUS_TRANSACTION;

  FUNCTION make_ctx_json RETURN CLOB IS
    v_ctx CLOB;
  BEGIN
    SELECT JSON_OBJECT(
             'user'       VALUE SYS_CONTEXT('USERENV','SESSION_USER'),
             'ip'         VALUE SYS_CONTEXT('USERENV','IP_ADDRESS'),
             'module'     VALUE SYS_CONTEXT('USERENV','MODULE'),
             'action'     VALUE SYS_CONTEXT('USERENV','ACTION'),
             'sid'        VALUE SYS_CONTEXT('USERENV','SID'),
             'client_id'  VALUE SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'),
             'host'       VALUE SYS_CONTEXT('USERENV','HOST'),
             'timestamp'  VALUE TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD"T"HH24:MI:SS.FF TZH:TZM')
           RETURNING CLOB)
      INTO v_ctx
      FROM dual;
    RETURN v_ctx;
  END;

  FUNCTION make_kv_json(p_key IN VARCHAR2, p_val IN VARCHAR2) RETURN CLOB IS
    v_json CLOB;
  BEGIN
    SELECT JSON_OBJECT(p_key VALUE p_val RETURNING CLOB) INTO v_json FROM dual;
    RETURN v_json;
  END;

  PROCEDURE log_event(
    p_action_type IN VARCHAR2,
    p_table_name  IN VARCHAR2,
    p_record_key  IN VARCHAR2,
    p_message     IN VARCHAR2,
    p_details     IN CLOB
  ) IS
  BEGIN
    INSERT INTO general_log (action_type, table_name, record_key, message, details)
    VALUES (SUBSTR(p_action_type,1,50),
            SUBSTR(p_table_name,1,100),
            SUBSTR(p_record_key,1,100),
            SUBSTR(p_message,1,4000),
            p_details || CHR(10) || make_ctx_json);

    COMMIT; -- autonomous transaction
  EXCEPTION
    WHEN OTHERS THEN
      -- protecție: nu blochează DML-ul aplicației dacă logul cade
      NULL;
  END;
END general_log_api;
/
CREATE OR REPLACE TRIGGER trg_employees_audit
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
DECLARE
  v_details CLOB;
BEGIN
  IF INSERTING THEN
    SELECT JSON_OBJECT(
             'new' VALUE JSON_OBJECT(
               'id' VALUE :NEW.id,
               'name' VALUE :NEW.name,
               'email' VALUE :NEW.email,
               'username' VALUE :NEW.username,
               'job_role' VALUE :NEW.job_role,
               'departament_id' VALUE :NEW.departament_id
             )
           RETURNING CLOB)
      INTO v_details FROM dual;

    general_log_api.log_event('INSERT','EMPLOYEES', TO_CHAR(:NEW.id), 'Employee created', v_details);

  ELSIF UPDATING THEN
    SELECT JSON_OBJECT(
             'old' VALUE JSON_OBJECT(
               'id' VALUE :OLD.id, 'name' VALUE :OLD.name, 'email' VALUE :OLD.email,
               'username' VALUE :OLD.username, 'job_role' VALUE :OLD.job_role,
               'departament_id' VALUE :OLD.departament_id
             ),
             'new' VALUE JSON_OBJECT(
               'id' VALUE :NEW.id, 'name' VALUE :NEW.name, 'email' VALUE :NEW.email,
               'username' VALUE :NEW.username, 'job_role' VALUE :NEW.job_role,
               'departament_id' VALUE :NEW.departament_id
             )
           RETURNING CLOB)
      INTO v_details FROM dual;

    general_log_api.log_event('UPDATE','EMPLOYEES', TO_CHAR(:NEW.id), 'Employee updated', v_details);

  ELSIF DELETING THEN
    SELECT JSON_OBJECT(
             'old' VALUE JSON_OBJECT(
               'id' VALUE :OLD.id,
               'name' VALUE :OLD.name,
               'email' VALUE :OLD.email,
               'username' VALUE :OLD.username
             )
           RETURNING CLOB)
      INTO v_details FROM dual;

    general_log_api.log_event('DELETE','EMPLOYEES', TO_CHAR(:OLD.id), 'Employee deleted', v_details);
  END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_projects_audit
AFTER INSERT OR UPDATE OR DELETE ON projects
FOR EACH ROW
DECLARE
  v_details CLOB;
BEGIN
  IF INSERTING THEN
    SELECT JSON_OBJECT('new' VALUE JSON_OBJECT(
             'id' VALUE :NEW.id, 'title' VALUE :NEW.title,
             'status' VALUE :NEW.status, 'user_id' VALUE :NEW.user_id
           ) RETURNING CLOB) INTO v_details FROM dual;

    general_log_api.log_event('INSERT','PROJECTS', TO_CHAR(:NEW.id), 'Project created', v_details);

  ELSIF UPDATING THEN
    SELECT JSON_OBJECT(
            'old' VALUE JSON_OBJECT('id' VALUE :OLD.id, 'title' VALUE :OLD.title, 'status' VALUE :OLD.status, 'user_id' VALUE :OLD.user_id),
            'new' VALUE JSON_OBJECT('id' VALUE :NEW.id, 'title' VALUE :NEW.title, 'status' VALUE :NEW.status, 'user_id' VALUE :NEW.user_id)
           RETURNING CLOB) INTO v_details FROM dual;

    general_log_api.log_event('UPDATE','PROJECTS', TO_CHAR(:NEW.id), 'Project updated', v_details);

  ELSIF DELETING THEN
    SELECT JSON_OBJECT('old' VALUE JSON_OBJECT(
             'id' VALUE :OLD.id, 'title' VALUE :OLD.title, 'status' VALUE :OLD.status
           ) RETURNING CLOB) INTO v_details FROM dual;

    general_log_api.log_event('DELETE','PROJECTS', TO_CHAR(:OLD.id), 'Project deleted', v_details);
  END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_assignment_audit
AFTER INSERT OR UPDATE OR DELETE ON project_assignment
FOR EACH ROW
DECLARE
  v_key VARCHAR2(100);
  v_details CLOB;
BEGIN
  -- cheia textuală clară: "id=<id>;emp=<emp>;proj=<proj>"
  v_key := 'id='||CASE WHEN INSERTING THEN :NEW.id WHEN UPDATING THEN :NEW.id ELSE :OLD.id END||
           ';emp='||CASE WHEN INSERTING THEN :NEW.employee_id WHEN UPDATING THEN :NEW.employee_id ELSE :OLD.employee_id END||
           ';proj='||CASE WHEN INSERTING THEN :NEW.project_id WHEN UPDATING THEN :NEW.project_id ELSE :OLD.project_id END;

  IF INSERTING THEN
    SELECT JSON_OBJECT('assign.new' VALUE JSON_OBJECT(
             'id' VALUE :NEW.id, 'employee_id' VALUE :NEW.employee_id,
             'project_id' VALUE :NEW.project_id, 'start_date' VALUE TO_CHAR(:NEW.start_date,'YYYY-MM-DD HH24:MI:SS'),
             'end_date' VALUE TO_CHAR(:NEW.end_date,'YYYY-MM-DD HH24:MI:SS'), 'role' VALUE :NEW.role
           ) RETURNING CLOB) INTO v_details FROM dual;

    general_log_api.log_event('ASSIGN','PROJECT_ASSIGNMENT', v_key, 'Employee assigned to project', v_details);

  ELSIF UPDATING THEN
    SELECT JSON_OBJECT(
             'assign.old' VALUE JSON_OBJECT(
               'id' VALUE :OLD.id, 'employee_id' VALUE :OLD.employee_id, 'project_id' VALUE :OLD.project_id,
               'start_date' VALUE TO_CHAR(:OLD.start_date,'YYYY-MM-DD HH24:MI:SS'),
               'end_date' VALUE TO_CHAR(:OLD.end_date,'YYYY-MM-DD HH24:MI:SS'),
               'role' VALUE :OLD.role
             ),
             'assign.new' VALUE JSON_OBJECT(
               'id' VALUE :NEW.id, 'employee_id' VALUE :NEW.employee_id, 'project_id' VALUE :NEW.project_id,
               'start_date' VALUE TO_CHAR(:NEW.start_date,'YYYY-MM-DD HH24:MI:SS'),
               'end_date' VALUE TO_CHAR(:NEW.end_date,'YYYY-MM-DD HH24:MI:SS'),
               'role' VALUE :NEW.role
             )
           RETURNING CLOB) INTO v_details FROM dual;

    general_log_api.log_event('ASSIGN.UPDATE','PROJECT_ASSIGNMENT', v_key, 'Assignment updated', v_details);

  ELSIF DELETING THEN
    SELECT JSON_OBJECT('assign.old' VALUE JSON_OBJECT(
             'id' VALUE :OLD.id, 'employee_id' VALUE :OLD.employee_id,
             'project_id' VALUE :OLD.project_id, 'start_date' VALUE TO_CHAR(:OLD.start_date,'YYYY-MM-DD HH24:MI:SS'),
             'end_date' VALUE TO_CHAR(:OLD.end_date,'YYYY-MM-DD HH24:MI:SS'), 'role' VALUE :OLD.role
           ) RETURNING CLOB) INTO v_details FROM dual;

    general_log_api.log_event('UNASSIGN','PROJECT_ASSIGNMENT', v_key, 'Assignment removed', v_details);
  END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_timesheet_audit
AFTER INSERT OR UPDATE OR DELETE ON TimesheetEntries
FOR EACH ROW
DECLARE
  v_details CLOB;
  v_key     VARCHAR2(100);
BEGIN
  v_key := 'id='||CASE WHEN INSERTING THEN :NEW.TimesheetEntryId WHEN UPDATING THEN :NEW.TimesheetEntryId ELSE :OLD.TimesheetEntryId END
          ||';emp='||CASE WHEN INSERTING THEN :NEW.EmployeeId WHEN UPDATING THEN :NEW.EmployeeId ELSE :OLD.EmployeeId END
          ||';date='||TO_CHAR(CASE WHEN INSERTING THEN :NEW.DateEntry WHEN UPDATING THEN :NEW.DateEntry ELSE :OLD.DateEntry END,'YYYY-MM-DD');

  IF INSERTING THEN
    SELECT JSON_OBJECT('new' VALUE JSON_OBJECT(
             'TimesheetEntryId' VALUE :NEW.TimesheetEntryId, 'EmployeeId' VALUE :NEW.EmployeeId,
             'ProjectId' VALUE :NEW.ProjectId, 'DateEntry' VALUE TO_CHAR(:NEW.DateEntry,'YYYY-MM-DD'),
             'HoursWorked' VALUE :NEW.HoursWorked, 'EntryType' VALUE :NEW.EntryType,
             'TimesheetStatus' VALUE :NEW.TimesheetStatus
           ) RETURNING CLOB) INTO v_details FROM dual;

    general_log_api.log_event('INSERT','TIMESHEETENTRIES', v_key, 'Timesheet created', v_details);

  ELSIF UPDATING THEN
    SELECT JSON_OBJECT(
             'old' VALUE JSON_OBJECT(
               'TimesheetEntryId' VALUE :OLD.TimesheetEntryId, 'EmployeeId' VALUE :OLD.EmployeeId,
               'ProjectId' VALUE :OLD.ProjectId, 'DateEntry' VALUE TO_CHAR(:OLD.DateEntry,'YYYY-MM-DD'),
               'HoursWorked' VALUE :OLD.HoursWorked, 'EntryType' VALUE :OLD.EntryType,
               'TimesheetStatus' VALUE :OLD.TimesheetStatus
             ),
             'new' VALUE JSON_OBJECT(
               'TimesheetEntryId' VALUE :NEW.TimesheetEntryId, 'EmployeeId' VALUE :NEW.EmployeeId,
               'ProjectId' VALUE :NEW.ProjectId, 'DateEntry' VALUE TO_CHAR(:NEW.DateEntry,'YYYY-MM-DD'),
               'HoursWorked' VALUE :NEW.HoursWorked, 'EntryType' VALUE :NEW.EntryType,
               'TimesheetStatus' VALUE :NEW.TimesheetStatus
             )
           RETURNING CLOB) INTO v_details FROM dual;

    general_log_api.log_event('UPDATE','TIMESHEETENTRIES', v_key, 'Timesheet updated', v_details);

  ELSIF DELETING THEN
    SELECT JSON_OBJECT('old' VALUE JSON_OBJECT(
             'TimesheetEntryId' VALUE :OLD.TimesheetEntryId, 'EmployeeId' VALUE :OLD.EmployeeId,
             'ProjectId' VALUE :OLD.ProjectId, 'DateEntry' VALUE TO_CHAR(:OLD.DateEntry,'YYYY-MM-DD'),
             'HoursWorked' VALUE :OLD.HoursWorked, 'EntryType' VALUE :OLD.EntryType,
             'TimesheetStatus' VALUE :OLD.TimesheetStatus
           ) RETURNING CLOB) INTO v_details FROM dual;

    general_log_api.log_event('DELETE','TIMESHEETENTRIES', v_key, 'Timesheet deleted', v_details);
  END IF;
END;
/
