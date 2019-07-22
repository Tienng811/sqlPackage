--------------------------------------------------------
--  File created - Monday-May-08-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Trigger WRITE_ATTENTION_TRIGGER
--------------------------------------------------------
drop table review_attention;

create table review_attention (
emp_no number(4) not null primary key,
emp_name varchar2(60) not null,
emp_contactno varchar2(60) not null,
manager_name varchar2(60) not null,
manager_emp_no varchar2(60) not null,
review_date date not null);
  CREATE OR REPLACE TRIGGER "WRITE_ATTENTION_TRIGGER" BEFORE
  INSERT
  or
  UPDATE
    OF MANAGER_REVIEW_RATING ON MANAGER_REVIEW FOR EACH ROW
  Declare
  emp_name varchar2(30);
  reviewer_name varchar2(30);
  emp_contactno char(10);
  
  BEGIN 
  IF
    :new.manager_review_rating = 'N' THEN
  Select emp_gname ||' '|| emp_fname into emp_name from employee where emp_no = :new.emp_no;
  Select emp_contactno into emp_contactno from employee where emp_no = :new.emp_no;
  Select emp_gname ||' '|| emp_fname into reviewer_name from employee where emp_no = :new.reviewer_emp_no;
  insert into review_attention values (:new.emp_no,emp_name, emp_contactno, reviewer_name,:new.reviewer_emp_no, :new.manager_review_date);  
END IF;
END;
/
ALTER TRIGGER "WRITE_ATTENTION_TRIGGER" ENABLE;
/
