BEGIN
  DBMS_SCHEDULER.create_job(
    job_name        => 'RMAN_L1_DAILY',
    job_type        => 'EXECUTABLE',
    job_action      => '/u01/app/oracle/product/19c/dbhome_1/bin/rman',
    number_of_arguments => 3,
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
    enabled         => FALSE
  );
  DBMS_SCHEDULER.set_job_argument_value('RMAN_L1_DAILY',1,'target');
  DBMS_SCHEDULER.set_job_argument_value('RMAN_L1_DAILY',2,'/');
  DBMS_SCHEDULER.set_job_argument_value('RMAN_L1_DAILY',3,'cmdfile=/u01/backup/rman/level1.rman log=/u01/backup/logs/level1_$(date +%F).log');
  DBMS_SCHEDULER.enable('RMAN_L1_DAILY');
END;
/
COMMIT;