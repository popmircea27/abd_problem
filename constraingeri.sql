-- constrângeri: PK/UK existente
SELECT constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name = 'EMPLOYEES';

SELECT constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name = 'TIMESHEETENTRIES';

-- indecși existenți și unicitatea lor
SELECT index_name, uniqueness
FROM user_indexes
WHERE table_name IN ('EMPLOYEES','TIMESHEETENTRIES');

-- coloanele fiecărui index
SELECT table_name, index_name, column_name, column_position
FROM user_ind_columns
WHERE table_name IN ('EMPLOYEES','TIMESHEETENTRIES')
ORDER BY table_name, index_name, column_position;


-- asigurăm unicitatea numelui de departament (ex: "Java", "Finance")
ALTER TABLE departaments
  ADD CONSTRAINT uq_departament_name UNIQUE (departament_name);

-- în projects: un titlu de proiect e unic per user (util dacă userul își creează mai multe proiecte)
ALTER TABLE projects
  ADD CONSTRAINT uq_project_user_title UNIQUE (user_id, title);

-- în project_assignment: un angajat să nu fie alocat de două ori la același proiect
ALTER TABLE project_assignment
  ADD CONSTRAINT uq_projectassignment_emp_proj UNIQUE (employee_id, project_id);

-- în holidays: ziua de sărbătoare trebuie să fie unică
ALTER TABLE holidays
  ADD CONSTRAINT uq_holiday_date UNIQUE (HolidayDate);


-- vederi

-- vedere cu angajatii care sunt pe proiect

CREATE OR REPLACE VIEW vw_employees_on_projects AS
SELECT 
    e.id           AS employee_id,
    e.name         AS employee_name,
    e.email,
    e.job_role,
    d.departament_name,
    p.title        AS project_title,
    pa.start_date,
    pa.end_date,
    pa.role         AS project_role
FROM employees e
JOIN departaments d ON e.departament_id = d.dep_id
JOIN project_assignment pa ON pa.employee_id = e.id
JOIN projects p ON pa.project_id = p.id
WHERE pa.end_date IS NULL OR pa.end_date >= SYSDATE;

-- cei care nu sunt pe proiect
CREATE OR REPLACE VIEW vw_employees_without_projects AS
SELECT 
    e.id,
    e.name,
    e.email,
    e.job_role,
    d.departament_name
FROM employees e
JOIN departaments d ON e.departament_id = d.dep_id
WHERE e.id NOT IN (
    SELECT employee_id 
    FROM project_assignment 
    WHERE end_date IS NULL OR end_date >= SYSDATE
);

-- timeshieeturi în stare "draft" sau "submitted"
CREATE OR REPLACE VIEW vw_timesheet_pending AS
SELECT 
    te.timesheetentryid,
    e.name AS employee_name,
    te.dateentry,
    te.hoursworked,
    te.entrytype,
    te.timesheetstatus,
    p.title AS project_title
FROM timesheetentries te
JOIN employees e ON te.employeeid = e.id
LEFT JOIN projects p ON te.projectid = p.id
WHERE te.timesheetstatus IN ('draft', 'submitted');
commit;