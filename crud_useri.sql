-- proceduri de crud pe useri
SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE employee_api AS
  -- CREATE
  PROCEDURE create_employee(
    p_name           IN employees.name%TYPE,
    p_email          IN employees.email%TYPE,
    p_username       IN employees.username%TYPE,
    p_job_role       IN employees.job_role%TYPE,
    p_departament_id IN employees.departament_id%TYPE,
    p_new_id         OUT employees.id%TYPE
  );

  -- READ (un singur angajat după ID)
  PROCEDURE get_employee(
    p_id   IN employees.id%TYPE,
    p_cur  OUT SYS_REFCURSOR
  );

  -- LIST (toți sau opțional filtru după departament)
  PROCEDURE list_employees(
    p_departament_id IN employees.departament_id%TYPE DEFAULT NULL,
    p_cur            OUT SYS_REFCURSOR
  );

  -- UPDATE (nume, rol, departament; email/username rămân neschimbate în mod normal)
  PROCEDURE update_employee(
    p_id             IN employees.id%TYPE,
    p_name           IN employees.name%TYPE,
    p_job_role       IN employees.job_role%TYPE,
    p_departament_id IN employees.departament_id%TYPE
  );

  -- DELETE
  PROCEDURE delete_employee(
    p_id IN employees.id%TYPE
  );
END employee_api;
/
CREATE OR REPLACE PACKAGE BODY employee_api AS

  -- helper: verifică existența departamentului
  PROCEDURE assert_departament_exists(p_dep_id IN NUMBER) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt
    FROM departaments
    WHERE dep_id = p_dep_id;
    IF v_cnt = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Departament inexistent: dep_id='||p_dep_id);
    END IF;
  END;

  -- CREATE
  PROCEDURE create_employee(
    p_name           IN employees.name%TYPE,
    p_email          IN employees.email%TYPE,
    p_username       IN employees.username%TYPE,
    p_job_role       IN employees.job_role%TYPE,
    p_departament_id IN employees.departament_id%TYPE,
    p_new_id         OUT employees.id%TYPE
  ) IS
  BEGIN
    assert_departament_exists(p_departament_id);

    INSERT INTO employees(name, email, username, job_role, departament_id)
    VALUES (p_name, p_email, p_username, p_job_role, p_departament_id)
    RETURNING id INTO p_new_id;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      -- încălcă UNIQUE (email sau username)
      RAISE_APPLICATION_ERROR(-20002, 'Email sau username deja folosit.');
  END create_employee;

  -- READ (un angajat după ID)
  PROCEDURE get_employee(
    p_id   IN employees.id%TYPE,
    p_cur  OUT SYS_REFCURSOR
  ) IS
  BEGIN
    OPEN p_cur FOR
      SELECT e.id, e.name, e.email, e.username, e.job_role, e.created_at,
             e.departament_id, d.departament_name
      FROM employees e
      JOIN departaments d ON d.dep_id = e.departament_id
      WHERE e.id = p_id;
  END get_employee;

  -- LIST (toți sau după departament)
  PROCEDURE list_employees(
    p_departament_id IN employees.departament_id%TYPE DEFAULT NULL,
    p_cur            OUT SYS_REFCURSOR
  ) IS
  BEGIN
    IF p_departament_id IS NULL THEN
      OPEN p_cur FOR
        SELECT e.id, e.name, e.email, e.username, e.job_role,
               e.created_at, e.departament_id, d.departament_name
        FROM employees e
        JOIN departaments d ON d.dep_id = e.departament_id
        ORDER BY e.id;
    ELSE
      OPEN p_cur FOR
        SELECT e.id, e.name, e.email, e.username, e.job_role,
               e.created_at, e.departament_id, d.departament_name
        FROM employees e
        JOIN departaments d ON d.dep_id = e.departament_id
        WHERE e.departament_id = p_departament_id
        ORDER BY e.id;
    END IF;
  END list_employees;

  -- UPDATE (nu schimbăm email/username ca să evităm coliziuni; poți extinde ușor)
  PROCEDURE update_employee(
    p_id             IN employees.id%TYPE,
    p_name           IN employees.name%TYPE,
    p_job_role       IN employees.job_role%TYPE,
    p_departament_id IN employees.departament_id%TYPE
  ) IS
    v_rows PLS_INTEGER;
  BEGIN
    assert_departament_exists(p_departament_id);

    UPDATE employees
       SET name = p_name,
           job_role = p_job_role,
           departament_id = p_departament_id
     WHERE id = p_id;

    v_rows := SQL%ROWCOUNT;
    IF v_rows = 0 THEN
      RAISE_APPLICATION_ERROR(-20003, 'Employee inexistent: id='||p_id);
    END IF;
  END update_employee;

  -- DELETE
  PROCEDURE delete_employee(
    p_id IN employees.id%TYPE
  ) IS
    v_rows PLS_INTEGER;
  BEGIN
    DELETE FROM employees WHERE id = p_id;
    v_rows := SQL%ROWCOUNT;
    IF v_rows = 0 THEN
      RAISE_APPLICATION_ERROR(-20003, 'Employee inexistent: id='||p_id);
    END IF;
  END delete_employee;

END employee_api;
/
commit;




-- folosire
-- CREATE
DECLARE
  v_new_id NUMBER;
BEGIN
  employee_api.create_employee(
    p_name           => 'Nou Angajat',
    p_email          => 'nou.angajat@acme.com',
    p_username       => 'nou.angajat',
    p_job_role       => 'Java Engineer',
    p_departament_id => (SELECT dep_id FROM departaments WHERE departament_name='Java'),
    p_new_id         => v_new_id
  );
  DBMS_OUTPUT.PUT_LINE('ID nou = '||v_new_id);
  -- COMMIT; -- la decizia ta
END;
/

-- READ
VAR rc REFCURSOR
EXEC employee_api.get_employee( p_id => 1, p_cur => :rc );
PRINT rc

-- LIST (toți)
VAR rcl REFCURSOR
EXEC employee_api.list_employees( p_cur => :rcl );
PRINT rcl

-- LIST (după departament)
VAR rcd REFCURSOR
EXEC employee_api.list_employees( p_departament_id => (SELECT dep_id FROM departaments WHERE departament_name='Frontend'), p_cur => :rcd );
PRINT rcd

-- UPDATE
BEGIN
  employee_api.update_employee(
    p_id             => 1,
    p_name           => 'Nume Actualizat',
    p_job_role       => 'Senior Java Engineer',
    p_departament_id => (SELECT dep_id FROM departaments WHERE departament_name='Java')
  );
  -- COMMIT;
END;
/

-- DELETE
BEGIN
  employee_api.delete_employee( p_id => 1 );
  -- COMMIT;
END;
/
commit;


DECLARE
  v_new_id NUMBER;
BEGIN
  employee_api.create_employee(
    p_name           => 'Maria Popescu',
    p_email          => 'maria.popescu@acme.com',
    p_username       => 'maria.popescu',
    p_job_role       => 'Frontend Engineer',
    p_departament_id => (SELECT dep_id FROM departaments WHERE departament_name='Frontend'),
    p_new_id         => v_new_id
  );
  DBMS_OUTPUT.PUT_LINE('ID nou = '||v_new_id);
  COMMIT;
END;
/
