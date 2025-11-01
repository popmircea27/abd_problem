-- RULEAZĂ CA APPUSER
-- Creează un API de inserare timesheet-uri care rulează cu drepturile proprietarului (APPUSER)
-- și dă EXECUTE la PUBLIC, astfel încât orice user existent poate insera timesheet-uri
-- fără CREATE USER / CREATE ROLE.

-- 1) Pachetul API
CREATE OR REPLACE PACKAGE timesheet_api AUTHID DEFINER AS
  PROCEDURE add_entry(
    p_employee_username IN VARCHAR2,
    p_date              IN DATE,
    p_hours             IN NUMBER,
    p_project_id        IN INTEGER,
    p_entry_type        IN VARCHAR2,
    p_status            IN VARCHAR2 DEFAULT 'submitted'
  );
END;
/

CREATE OR REPLACE PACKAGE BODY timesheet_api AS
  PROCEDURE add_entry(
    p_employee_username IN VARCHAR2,
    p_date              IN DATE,
    p_hours             IN NUMBER,
    p_project_id        IN INTEGER,
    p_entry_type        IN VARCHAR2,
    p_status            IN VARCHAR2
  ) IS
    v_emp_id  employees.id%TYPE;
  BEGIN
    -- mapăm username -> employee_id (acceptăm nume cu puncte, case-insensitive)
    SELECT id
      INTO v_emp_id
      FROM employees
     WHERE UPPER(username) = UPPER(p_employee_username);

    -- inserăm timesheetul (PK e IDENTITY, nu e nevoie de secvență)
    INSERT INTO timesheetentries(
      employeeid, projectid, dateentry, hoursworked, entrytype, timesheetstatus
    ) VALUES (
      v_emp_id, p_project_id, p_date, p_hours, p_entry_type, p_status
    );
  END;
END;
/

-- 2) Drept de EXECUTE pentru toți utilizatorii existenți (fără privilegii de DBA)
GRANT EXECUTE ON timesheet_api TO PUBLIC;
