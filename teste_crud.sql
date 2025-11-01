SET SERVEROUTPUT ON;

DECLARE
  v_dep_id NUMBER;
  v_new_id NUMBER;
BEGIN
  SELECT dep_id
  INTO   v_dep_id
  FROM   departaments
  WHERE  departament_name = 'Java';

  employee_api.create_employee(
    p_name           => 'Nou Angajat',
    p_email          => 'nou.angajat@acmdasdadadae.com',
    p_username       => 'nou.angajat',
    p_job_role       => 'Java Engineer',
    p_departament_id => v_dep_id,
    p_new_id         => v_new_id
  );

  DBMS_OUTPUT.PUT_LINE('ID nou = '||v_new_id);
  COMMIT;
END;
/


VAR rc REFCURSOR;

DECLARE
  v_dep_id NUMBER;
BEGIN
  SELECT dep_id INTO v_dep_id
  FROM   departaments
  WHERE  departament_name = 'Frontend';

  employee_api.list_employees(p_departament_id => v_dep_id, p_cur => :rc);
END;
/

PRINT rc

BEGIN
  DECLARE
    v_dep_id NUMBER;
  BEGIN
    SELECT dep_id INTO v_dep_id
    FROM   departaments
    WHERE  departament_name = 'Java';

    employee_api.update_employee(
      p_id             => 1,
      p_name           => 'Nume Actualizat',
      p_job_role       => 'Senior Java Engineer',
      p_departament_id => v_dep_id
    );
    COMMIT;
  END;
END;
/
