--------------------------------------------------------
--  File created - Monday-May-08-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger MAINTAIN_EMPCOUNT_TRIGGER
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "MAINTAIN_EMPCOUNT_TRIGGER" BEFORE
  INSERT
  OR
  UPDATE
    OF MANAGER_NO ON EMPLOYEE FOR EACH ROW
    
  BEGIN 
  IF inserting THEN
  UPDATE
    manager
  SET
    manager_no_emps = manager_no_emps + 1
  WHERE
    emp_no = :new.manager_no;

ELSE
    IF updating THEN
      UPDATE
        manager
      SET
        manager_no_emps = manager_no_emps - 1
      WHERE
       emp_no = :old.manager_no;
      UPDATE
        manager
      SET
        manager_no_emps = manager_no_emps + 1
      WHERE
        emp_no = :new.manager_no;
    END IF;
  END IF;
END;
/
ALTER TRIGGER "MAINTAIN_EMPCOUNT_TRIGGER" ENABLE;
/
