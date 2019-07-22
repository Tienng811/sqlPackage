--------------------------------------------------------
--  File created - Monday-May-08-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger CHECK_MANAGER_TRIGGER
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER "CHECK_MANAGER_TRIGGER" 
BEFORE INSERT OR UPDATE ON MANAGER 
FOR EACH ROW 
Declare
emp_is CHAR(1);
BEGIN
  Select emp_is_manager into emp_is
  from employee
  where emp_no = :new.emp_no;
  
  If emp_is <> 'Y' then
    raise_application_error (-20001, 'Employee is not a manager');
  End if;  
END;
/
ALTER TRIGGER "CHECK_MANAGER_TRIGGER" ENABLE;
/