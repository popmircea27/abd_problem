SET DEFINE OFF;

CREATE TABLE departaments (
    dep_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    departament_name VARCHAR2(255) NOT NULL
);

CREATE TABLE employees (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    email VARCHAR2(255) UNIQUE NOT NULL,
    username VARCHAR2(100) UNIQUE NOT NULL,
    job_role VARCHAR2(50) NOT NULL,                 -- a fost "role"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    departament_id INTEGER NOT NULL,
    CONSTRAINT fk_employees_departament
        FOREIGN KEY (departament_id)
        REFERENCES departaments(dep_id)
        ON DELETE CASCADE
);

CREATE TABLE projects (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR2(255) NOT NULL,
    body CLOB,
    user_id INTEGER NOT NULL,
    status VARCHAR2(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_projects_user
        FOREIGN KEY (user_id)
        REFERENCES employees(id)
        ON DELETE CASCADE
);

CREATE TABLE project_assignment (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    project_id INTEGER NOT NULL,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    role VARCHAR2(100),
    CONSTRAINT fk_assignment_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_assignment_project
        FOREIGN KEY (project_id)
        REFERENCES projects(id)
        ON DELETE CASCADE
);

CREATE TABLE general_log (
    log_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type VARCHAR2(50),
    table_name VARCHAR2(100),
    record_key VARCHAR2(100),
    message VARCHAR2(4000),
    details CLOB
);

CREATE TABLE Attendance (
    AttendanceID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    EmployeeName VARCHAR2(100) NOT NULL,
    FirstJoin TIMESTAMP,
    LastLeave TIMESTAMP,
    InMeetingDuration NUMBER,               -- tratat ca minute
    Email VARCHAR2(100) NOT NULL,
    ParticipantStatus VARCHAR2(50) NOT NULL
);

CREATE TABLE Absences (
    AbsenceID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StartDate TIMESTAMP,
    EndDate TIMESTAMP,
    AbsenceType VARCHAR2(100) NOT NULL,
    Organizer  VARCHAR2(100) NOT NULL
);

CREATE TABLE Holidays (
    HolidayID INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    HolidayDate DATE NOT NULL,
    HolidayName VARCHAR2(100) NOT NULL
);

CREATE TABLE TimesheetEntries (
    TimesheetEntryId INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    EmployeeId   INTEGER NOT NULL,
    ProjectId    INTEGER,
    AttendanceId INTEGER,
    AbsenceId    INTEGER,
    DateEntry    DATE NOT NULL,
    HolidayID    INTEGER,
    HoursWorked  NUMBER(5,2),
    EntryType    VARCHAR2(50),    -- 'work'/'absence'/'holiday'/'meeting'
    TimesheetStatus VARCHAR2(50), -- 'draft'/'submitted'/'approved'/'rejected'
    CONSTRAINT FK_Timesheet_Employee   FOREIGN KEY (EmployeeId)    REFERENCES employees(id)             ON DELETE CASCADE,
    CONSTRAINT FK_Timesheet_Project    FOREIGN KEY (ProjectId)     REFERENCES projects(id)              ON DELETE SET NULL,
    CONSTRAINT FK_Timesheet_Attendance FOREIGN KEY (AttendanceId)  REFERENCES Attendance(AttendanceID)  ON DELETE SET NULL,
    CONSTRAINT FK_Timesheet_Absence    FOREIGN KEY (AbsenceId)     REFERENCES Absences(AbsenceID)       ON DELETE SET NULL,
    CONSTRAINT FK_Timesheet_Holiday    FOREIGN KEY (HolidayID)     REFERENCES Holidays(HolidayID)       ON DELETE SET NULL,
    CONSTRAINT uq_employee_date UNIQUE (EmployeeId, DateEntry)
);
commit;
----------------------------------------------------------------
-- SEED DATA (INSERT)
----------------------------------------------------------------
-- DEPARTMENTS
INSERT INTO departaments (departament_name) VALUES ('HR');
INSERT INTO departaments (departament_name) VALUES ('Java');
INSERT INTO departaments (departament_name) VALUES ('.NET');
INSERT INTO departaments (departament_name) VALUES ('Android');
INSERT INTO departaments (departament_name) VALUES ('iOS');
INSERT INTO departaments (departament_name) VALUES ('Frontend');
INSERT INTO departaments (departament_name) VALUES (q'[Data & AI]');
INSERT INTO departaments (departament_name) VALUES ('Planning');
INSERT INTO departaments (departament_name) VALUES ('Testing');
INSERT INTO departaments (departament_name) VALUES ('Management');
commit;
-- EMPLOYEES (job_role în loc de role)
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Ana Ionescu','ana.ionescu@acme.com','ana.ionescu','HR Specialist',
       (SELECT dep_id FROM departaments WHERE departament_name='HR'));

INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Mihai Pop','mihai.pop@acme.com','mihai.pop','HR Generalist',
       (SELECT dep_id FROM departaments WHERE departament_name='HR'));

INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Ioana Radu','ioana.radu@acme.com','ioana.radu','Java Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Java'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Andrei Petrescu','andrei.petrescu@acme.com','andrei.petrescu','Senior Java Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Java'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Sorin Matei','sorin.matei@acme.com','sorin.matei','Java Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Java'));

INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Elena Vlaicu','elena.vlaicu@acme.com','elena.vlaicu','.NET Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='.NET'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Radu Marinescu','radu.marinescu@acme.com','radu.marinescu','Senior .NET Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='.NET'));

INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Vlad Dima','vlad.dima@acme.com','vlad.dima','Android Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Android'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Cristina Pavel','cristina.pavel@acme.com','cristina.pavel','Senior Android Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Android'));

INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Iulia Enache','iulia.enache@acme.com','iulia.enache','iOS Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='iOS'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Alex Bobocea','alex.bobocea@acme.com','alex.bobocea','Senior iOS Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='iOS'));

INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Teodora Dumitrescu','teodora.dumitrescu@acme.com','teodora.dumitrescu','Frontend Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Frontend'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Ciprian Ghinea','ciprian.ghinea@acme.com','ciprian.ghinea','Senior Frontend Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Frontend'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Paul Neagu','paul.neagu@acme.com','paul.neagu','Frontend Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Frontend'));

INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Larisa Barbu','larisa.barbu@acme.com','larisa.barbu','Data Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Data & AI'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Marius Tudoran','marius.tudoran@acme.com','marius.tudoran','ML Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Data & AI'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Bianca Toma','bianca.toma@acme.com','bianca.toma','Data Scientist',
       (SELECT dep_id FROM departaments WHERE departament_name='Data & AI'));

INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('George Voicu','george.voicu@acme.com','george.voicu','Project Manager',
       (SELECT dep_id FROM departaments WHERE departament_name='Planning'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Irina Petcu','irina.petcu@acme.com','irina.petcu','Scrum Master',
       (SELECT dep_id FROM departaments WHERE departament_name='Planning'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Valentin Serban','valentin.serban@acme.com','valentin.serban','Business Analyst',
       (SELECT dep_id FROM departaments WHERE departament_name='Planning'));

-- extra
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Daria Mihail','daria.mihail@acme.com','daria.mihail','QA Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Frontend'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Tudor Onea','tudor.onea@acme.com','tudor.onea','DevOps Engineer',
       (SELECT dep_id FROM departaments WHERE departament_name='Java'));
INSERT INTO employees (name,email,username,job_role,departament_id)
VALUES ('Roxana Georgescu','roxana.georgescu@acme.com','roxana.georgescu','Product Owner',
       (SELECT dep_id FROM departaments WHERE departament_name='Planning'));
commit;
-- PROJECTS
INSERT INTO projects (title, body, user_id, status)
VALUES ('Mobile Banking App','Core mobile features for retail banking.',
        (SELECT id FROM employees WHERE email='george.voicu@acme.com'),'active');

INSERT INTO projects (title, body, user_id, status)
VALUES ('E-Commerce Revamp','Headless commerce with SPA frontend.',
        (SELECT id FROM employees WHERE email='irina.petcu@acme.com'),'active');

INSERT INTO projects (title, body, user_id, status)
VALUES ('Data Lakehouse','Batch + streaming ingestion, governance.',
        (SELECT id FROM employees WHERE email='larisa.barbu@acme.com'),'active');

INSERT INTO projects (title, body, user_id, status)
VALUES ('AI Recommendations','Model serving + A/B testing.',
        (SELECT id FROM employees WHERE email='marius.tudoran@acme.com'),'active');

INSERT INTO projects (title, body, user_id, status)
VALUES ('iOS Replatforming','SwiftUI migration.',
        (SELECT id FROM employees WHERE email='alex.bobocea@acme.com'),'on_hold');

INSERT INTO projects (title, body, user_id, status)
VALUES ('Android Performance','Cold start & memory tuning.',
        (SELECT id FROM employees WHERE email='cristina.pavel@acme.com'),'active');

INSERT INTO projects (title, body, user_id, status)
VALUES ('Frontend Design System','Reusable UI library.',
        (SELECT id FROM employees WHERE email='ciprian.ghinea@acme.com'),'active');

INSERT INTO projects (title, body, user_id, status)
VALUES ('Risk Scoring Engine','.NET microservices.',
        (SELECT id FROM employees WHERE email='radu.marinescu@acme.com'),'active');

INSERT INTO projects (title, body, user_id, status)
VALUES ('On-Prem to Cloud','Java migration & DevOps.',
        (SELECT id FROM employees WHERE email='andrei.petrescu@acme.com'),'active');

INSERT INTO projects (title, body, user_id, status)
VALUES ('Chatbot Care','NLP for support center.',
        (SELECT id FROM employees WHERE email='bianca.toma@acme.com'),'active');

INSERT INTO projects (title, body, user_id, status)
VALUES ('KPI Dashboards','Company analytics.',
        (SELECT id FROM employees WHERE email='george.voicu@acme.com'),'completed');

INSERT INTO projects (title, body, user_id, status)
VALUES ('Fraud Detection','Graph + ML features.',
        (SELECT id FROM employees WHERE email='marius.tudoran@acme.com'),'active');

-- RECOMANDAT: fără griji de precizie
INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='teodora.dumitrescu@acme.com'),
 (SELECT id FROM projects  WHERE title='Frontend Design System'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(120,'DAY'), 'Frontend Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='ciprian.ghinea@acme.com'),
 (SELECT id FROM projects  WHERE title='Frontend Design System'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(110,'DAY'), 'Tech Lead');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='paul.neagu@acme.com'),
 (SELECT id FROM projects  WHERE title='E-Commerce Revamp'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(95,'DAY'), 'Frontend Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='andrei.petrescu@acme.com'),
 (SELECT id FROM projects  WHERE title='On-Prem to Cloud'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(150,'DAY'), 'Senior Java');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='sorin.matei@acme.com'),
 (SELECT id FROM projects  WHERE title='On-Prem to Cloud'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(130,'DAY'), 'Java Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='elena.vlaicu@acme.com'),
 (SELECT id FROM projects  WHERE title='Risk Scoring Engine'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(160,'DAY'), '.NET Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='radu.marinescu@acme.com'),
 (SELECT id FROM projects  WHERE title='Risk Scoring Engine'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(170,'DAY'), 'Architect');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='vlad.dima@acme.com'),
 (SELECT id FROM projects  WHERE title='Android Performance'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(80,'DAY'), 'Android Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='cristina.pavel@acme.com'),
 (SELECT id FROM projects  WHERE title='Android Performance'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(90,'DAY'), 'Tech Lead Android');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='iulia.enache@acme.com'),
 (SELECT id FROM projects  WHERE title='iOS Replatforming'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(140,'DAY'), 'iOS Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='alex.bobocea@acme.com'),
 (SELECT id FROM projects  WHERE title='iOS Replatforming'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(145,'DAY'), 'Tech Lead iOS');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='larisa.barbu@acme.com'),
 (SELECT id FROM projects  WHERE title='Data Lakehouse'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(200,'DAY'), 'Data Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='marius.tudoran@acme.com'),
 (SELECT id FROM projects  WHERE title='AI Recommendations'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(60,'DAY'), 'ML Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='bianca.toma@acme.com'),
 (SELECT id FROM projects  WHERE title='Chatbot Care'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(70,'DAY'), 'Data Scientist');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='george.voicu@acme.com'),
 (SELECT id FROM projects  WHERE title='KPI Dashboards'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(210,'DAY'), 'Project Manager');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='irina.petcu@acme.com'),
 (SELECT id FROM projects  WHERE title='E-Commerce Revamp'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(100,'DAY'), 'Scrum Master');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='valentin.serban@acme.com'),
 (SELECT id FROM projects  WHERE title='E-Commerce Revamp'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(98,'DAY'), 'Business Analyst');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='tudor.onea@acme.com'),
 (SELECT id FROM projects  WHERE title='On-Prem to Cloud'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(148,'DAY'), 'DevOps Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='daria.mihail@acme.com'),
 (SELECT id FROM projects  WHERE title='Frontend Design System'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(85,'DAY'), 'QA Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='ana.ionescu@acme.com'),
 (SELECT id FROM projects  WHERE title='KPI Dashboards'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(215,'DAY'), 'HR Partner');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='mihai.pop@acme.com'),
 (SELECT id FROM projects  WHERE title='Mobile Banking App'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(75,'DAY'), 'HR Generalist');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='paul.neagu@acme.com'),
 (SELECT id FROM projects  WHERE title='Mobile Banking App'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(70,'DAY'), 'Frontend Engineer');

INSERT INTO project_assignment (employee_id, project_id, start_date, role) VALUES
((SELECT id FROM employees WHERE email='roxana.georgescu@acme.com'),
 (SELECT id FROM projects  WHERE title='AI Recommendations'),
 CAST(SYSTIMESTAMP AS TIMESTAMP) - NUMTODSINTERVAL(58,'DAY'), 'Product Owner');

COMMIT;

commit;
-- ATTENDANCE (exemple)
INSERT INTO Attendance (EmployeeName, FirstJoin, LastLeave, InMeetingDuration, Email, ParticipantStatus)
VALUES ('Teodora Dumitrescu', SYSTIMESTAMP - INTERVAL '5' DAY, SYSTIMESTAMP - INTERVAL '5' DAY + INTERVAL '90' MINUTE, 90,
        'teodora.dumitrescu@acme.com','Accepted');
-- ... (restul rândurilor tale de Attendance rămân identice, doar cu spații la INTERVAL)

-- ABSENCES (idem, cu spații la INTERVAL)
INSERT INTO Absences (StartDate, EndDate, AbsenceType, Organizer)
VALUES (SYSTIMESTAMP - INTERVAL '14' DAY, SYSTIMESTAMP - INTERVAL '13' DAY, 'Vacation', 'HR');
-- ... (restul rândurilor tale de Absences rămân identice, doar cu spații la INTERVAL)
commit;
-- HOLIDAYS (noiembrie -> 20 feb)
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2025-11-30', 'Sf. Andrei');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2025-12-01', 'Ziua Națională');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2025-12-24', 'Ajun Crăciun');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2025-12-25', 'Crăciun');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2025-12-26', 'A doua zi de Crăciun');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2025-12-31', 'Revelion (companie)');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2026-01-01', 'Anul Nou');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2026-01-02', 'A doua zi după Anul Nou');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2026-01-24', 'Ziua Unirii Principatelor');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2026-02-10', 'Zi liberă companie');
INSERT INTO Holidays (HolidayDate, HolidayName) VALUES (DATE '2026-02-20', 'Zi liberă companie');
commit;
----------------------------------------------------------------
-- GENERATOR TIMESHEETS 2 LUNI (NOV-DEC 2025)
----------------------------------------------------------------
DECLARE
  v_start DATE := DATE '2025-11-01';
  v_end   DATE := DATE '2025-12-31';

  CURSOR c_emp IS
    SELECT id FROM employees;

  -- proiect activ într-o zi (sau NULL)
  -- << ÎNLOCUIEȘTE doar funcția pick_project din blocul tău >>
FUNCTION pick_project(p_emp_id NUMBER, p_day DATE) RETURN NUMBER IS
  v_proj NUMBER;
BEGIN
  SELECT project_id
    INTO v_proj
    FROM (
      SELECT project_id
      FROM project_assignment
      WHERE employee_id = p_emp_id
        AND start_date <= CAST(p_day AS TIMESTAMP) + NUMTODSINTERVAL(1,'DAY')
        AND (end_date IS NULL OR end_date >= CAST(p_day AS TIMESTAMP))
      ORDER BY start_date DESC
    )
    WHERE ROWNUM = 1;
  RETURN v_proj;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;


  -- ID sărbătoare pentru ziua respectivă (sau NULL)
  FUNCTION get_holiday_id(p_day DATE) RETURN NUMBER IS
    v_hid NUMBER;
  BEGIN
    SELECT HolidayID INTO v_hid
    FROM Holidays
    WHERE HolidayDate = TRUNC(p_day);
    RETURN v_hid;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  -- există deja timesheet (emp, day)?
  FUNCTION exists_entry(p_emp_id NUMBER, p_day DATE) RETURN BOOLEAN IS
    v_dummy NUMBER;
  BEGIN
    SELECT 1 INTO v_dummy
    FROM TimesheetEntries
    WHERE EmployeeId = p_emp_id
      AND DateEntry  = TRUNC(p_day);
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
  END;

BEGIN
  FOR r IN c_emp LOOP
    DECLARE
      d DATE := v_start;
      v_hid NUMBER;
      v_pid NUMBER;
    BEGIN
      WHILE d <= v_end LOOP
        -- doar Luni–Vineri
        IF TO_CHAR(d, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') NOT IN ('SAT','SUN') THEN
          IF NOT exists_entry(r.id, d) THEN
            v_hid := get_holiday_id(d);
            IF v_hid IS NOT NULL THEN
              INSERT INTO TimesheetEntries
                (EmployeeId, HolidayID, DateEntry, HoursWorked, EntryType, TimesheetStatus)
              VALUES
                (r.id, v_hid, TRUNC(d), 0, 'holiday', 'approved');
            ELSE
              v_pid := pick_project(r.id, d);
              INSERT INTO TimesheetEntries
                (EmployeeId, ProjectId, DateEntry, HoursWorked, EntryType, TimesheetStatus)
              VALUES
                (r.id, v_pid, TRUNC(d), 8, 'work', 'approved');
            END IF;
          END IF;
        END IF;
        d := d + 1;
      END LOOP;
    END;
  END LOOP;

  COMMIT;
END;
/
commit;