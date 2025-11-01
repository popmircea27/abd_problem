CREATE OR REPLACE PROCEDURE drop_all_tables AS
  PROCEDURE safe_drop(p_name VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ' || p_name || ' CASCADE CONSTRAINTS PURGE';
  EXCEPTION
    WHEN OTHERS THEN
      NULL; -- dacă nu există încă, continuăm
  END;
BEGIN
  -- ordinea nu mai contează cu CASCADE, dar păstrăm una logică
  safe_drop('TimesheetEntries');
  safe_drop('project_assignment');
  safe_drop('Attendance');
  safe_drop('Absences');
  safe_drop('Holidays');
  safe_drop('projects');
  safe_drop('employees');
  safe_drop('departaments');
  safe_drop('general_log');

  -- curățăm Recycle Bin (opțional dar util)
  EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';
END;
/
BEGIN
  drop_all_tables;
END;
/
-- apoi rulezi scriptul tău de CREATE TABLE + INSERT-uri de la capăt
commit;