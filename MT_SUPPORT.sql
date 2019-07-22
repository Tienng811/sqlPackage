CREATE OR REPLACE PACKAGE MT_SUPPORT AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
PROCEDURE JOB_PROC 
(
  ARG_JOBNO out JOB.JOB_NO%type 
, ARG_JOBSDATE IN JOB.JOB_SDATE%type 
, ARG_JOBEDATE IN JOB.JOB_EDATE%type 
, ARG_CLIENTNO IN JOB.CLIENT_NO%type
, ARG_SPECCODE IN JOB.SPEC_CODE%type
);

PROCEDURE ADD_MANAGER_REVIEW 
(
  ARG_EMPNO IN manager.emp_no%type
, ARG_DATE IN MANAGER_REVIEW.MANAGER_REVIEW_DATE%type
, ARG_RATING IN MANAGER_REVIEW.MANAGER_REVIEW_RATING%type
, ARG_REVIEWER IN MANAGER_REVIEW.REVIEWER_EMP_NO%type
); 

PROCEDURE ADD_JOB_SUPPORT 
(
  ARG_EMPNO IN job_support.emp_no%type
, ARG_JOBNO IN job_support.job_no%type
, ARG_JOBHRS IN job_support.job_hrs%type
, ARG_JOBRATING IN job_support.job_rating%type 
);

PROCEDURE ADD_ABSENCE 
(
  ARG_EMPNO IN ABSENCE.EMP_NO%type
, ARG_SDATE IN ABSENCE.ABSENCE_SDATE%type
, ARG_EDATE IN ABSENCE.ABSENCE_EDATE%type 
, Arg_paid in ABSENCE.ABSENCE_PAID%type
, Arg_type in ABSENCE.ABSENCE_TYPE%type
, ARG_ATT1 IN Char 
, ARG_ATT2 IN Char
);

 PROCEDURE RETURN_CLIENT_JOB 
(
  ARG_CLIENTNO IN VARCHAR2 
, ARG_SDATE IN date
, ARG_EDATE IN date 
, Client_CURSOR OUT sys_refcursor
, Job_CURSOR OUT sys_refcursor
, Employee_CURSOR OUT sys_refcursor
);

END MT_SUPPORT;
/


CREATE OR REPLACE PACKAGE BODY MT_SUPPORT AS

  PROCEDURE JOB_PROC 
(
  ARG_JOBNO out JOB.JOB_NO%type 
, ARG_JOBSDATE IN JOB.JOB_SDATE%type 
, ARG_JOBEDATE IN JOB.JOB_EDATE%type 
, ARG_CLIENTNO IN JOB.CLIENT_NO%type
, ARG_SPECCODE IN JOB.SPEC_CODE%type
) AS
--declare exception and variable
INVALID_CLIENTNO EXCEPTION;
    INVALID_SPECCODE EXCEPTION;
    INVALID_DATE Exception;
    client_count Number;
    spec_count number;
  BEGIN
    -- TODO: Implementation required for PROCEDURE MT_SUPPORT.JOB_PROC
   --verify whether clientno exists or not
  SELECT
        COUNT (*)
    INTO
        client_count
    FROM
        client
    WHERE
        client_no   = arg_clientno;
        
  --verify the end date is after the start date         
  If to_date(arg_jobedate,'dd/mm/yyyy') >to_date(arg_jobsdate,'dd/mm/yyyy') then
  --verify client existence
   If client_count = 1 Then
    --verify spec_code existence
    SELECT
        COUNT (*)
    INTO
        spec_count
    FROM
        speciality
    WHERE
        spec_code   = arg_speccode;
        
    If spec_count = 1 Then
    --insert into table job
      insert into job values (job_job_no_seq.nextval,arg_jobsdate,arg_jobedate,arg_clientno,arg_speccode);
      arg_jobno := job_job_no_seq.currval;
       dbms_output.put_line (
        'New job successfully inserted - Job code is : ' ||
        arg_jobno);
    else
     --exception if speccode is not found
       raise INVALID_SPECCODE;
    end if;
  else
    -- exception if clientno is not found
       raise INVALID_CLIENTNO;
  end if;
  else 
  --exception if date is not found
      raise INVALID_DATE;
  end if;
  --declare exception
  EXCEPTION
  When INVALID_SPECCODE THEN
       raise_application_error (-20001, 'Invalid Speciality code - INSERT UNSUCCESSFUL'
    ) ;
  When INVALID_CLIENTNO then
      raise_application_error (-20001, 'Invalid Client number - INSERT UNSUCCESSFUL'
    ) ;
  When INVALID_DATE then
      raise_application_error (-20001, 'Invalid Date - INSERT UNSUCCESSFUL'
    ) ;  
  END JOB_PROC;

  PROCEDURE ADD_MANAGER_REVIEW 
(
  ARG_EMPNO IN manager.emp_no%type
, ARG_DATE IN MANAGER_REVIEW.MANAGER_REVIEW_DATE%type
, ARG_RATING IN MANAGER_REVIEW.MANAGER_REVIEW_RATING%type
, ARG_REVIEWER IN MANAGER_REVIEW.REVIEWER_EMP_NO%type
) AS
--declare exceptions and variables for procedure add_manager_review
  Invalid_EMPNO Exception;
  Invalid_Date Exception;
  Invalid_Reviewer Exception;
  Invalid_Owner Exception;
  Invalid_Rating Exception;
  emp_count number;
  reviewer_count number;
  appoint_date date;
  owner_verify number;
  BEGIN
    -- TODO: Implementation required for PROCEDURE MT_SUPPORT.ADD_MANAGER_REVIEW
    --verify whether the employee is manager or not
  SELECT
        COUNT (*)
    INTO
        emp_count
    FROM
        MANAGER
    WHERE
        emp_no   = arg_empno;
        
  If emp_count = 1 then
    SELECT
        COUNT (*)
    INTO
        reviewer_count
    FROM
        MANAGER
    WHERE
        emp_no   = arg_reviewer;
    --verify the reviewer is manager and not the same manager as the reviewee
    If reviewer_count =1 and arg_reviewer != arg_empno then
      SELECT
        manager_date_appt
      INTO
        appoint_date
      FROM
        MANAGER
      WHERE
        emp_no  = arg_reviewer;
       --verify a review is after the appoint date of the reviewer
       If arg_date > appoint_date then
          SELECT
            COUNT (*)
          INTO
            owner_verify
          FROM
            Employee
          WHERE
            emp_no = arg_empno and manager_no is not Null;
         --verify the reviewee is not the owner
         If owner_verify = 1 then
         --verify the rating
           If arg_rating = 'S' or arg_rating = 'P' or arg_rating ='N' then
             insert into manager_review values (arg_empno, arg_date, arg_rating, arg_reviewer);
           else  
           --raise exception accordingly
             raise Invalid_rating;
           end if;
         else
             raise Invalid_owner;
         end if;
        else
             raise Invalid_date;
        end if;
      else
          raise Invalid_reviewer;
      end if;
  else
      raise Invalid_empno;
  end if;
   
   EXCEPTION
  When INVALID_reviewer THEN
       raise_application_error (-20001, 'Invalid Reviewer - INSERT UNSUCCESSFUL'
    ) ;
  When INVALID_empno then
      raise_application_error (-20001, 'Invalid manager number - INSERT UNSUCCESSFUL'
    ) ;
  When INVALID_owner then
      raise_application_error (-20001, 'The owner cannot be reviewed - INSERT UNSUCCESSFUL'
    ) ;  
   When INVALID_date THEN
       raise_application_error (-20001, 'Invalid date - INSERT UNSUCCESSFUL'
    ) ;
    When INVALID_rating THEN
       raise_application_error (-20001, 'Invalid rating - INSERT UNSUCCESSFUL'
    ) ;
  END ADD_MANAGER_REVIEW;

  PROCEDURE ADD_JOB_SUPPORT 
(
  ARG_EMPNO IN job_support.emp_no%type
, ARG_JOBNO IN job_support.job_no%type
, ARG_JOBHRS IN job_support.job_hrs%type
, ARG_JOBRATING IN job_support.job_rating%type 
) AS
--declare exceptions and variables
 INVALID_empno exception;
 INVALID_jobno exception;
 hold_support_rating support.support_rating%type;
 --variable to hold the average rating
 average_rating support.support_rating%type;
 --variable to hold the new job hours
 hold_jobhrs JOB_SUPPORT.JOB_HRS%type;
 emp_count number;
 job_count number;
 
  BEGIN
    -- TODO: Implementation required for PROCEDURE MT_SUPPORT.ADD_JOB_SUPPORT
 --verify employee
  SELECT
        COUNT (*)
    INTO
        emp_count
    FROM
       support
    WHERE
        emp_no   = arg_empno;
    if emp_count = 1 then
       SELECT
          COUNT (*)
       INTO
          job_count
       FROM
          job
       WHERE
          job_no   = arg_jobno;
          --verify job
       if job_count = 1 then
       --add row to job_support
         insert into JOB_SUPPORT values(arg_empno, arg_jobno, arg_jobhrs, arg_jobrating);
         -- add new job_hrs into the hold_jobhrs variable
         SELECT
            job_hrs
         INTO
            hold_jobhrs
         From
            job_support
         WHERE
            emp_no = arg_empno and job_no = arg_jobno;
            -- update the support table
         Update Support   
         Set SUPPORT_HRS_COMP =SUPPORT_HRS_COMP + hold_jobhrs 
         Where emp_no = arg_empno;   
         --add average rating into the average_rating variable
         Select AVG(job_rating)
         into
            average_rating
         from
            job_support
         where
            emp_no = arg_empno ;
            --update support table
         Update Support   
         Set SUPPORT_RATING =average_rating 
         Where emp_no = arg_empno;     
          --raise exception
       else 
         raise Invalid_jobno;
       end if;
       
   else
      raise Invalid_empno;
    end if;
    
    EXCEPTION
  When INVALID_JOBNO THEN
       raise_application_error (-20001, 'Invalid Job - INSERT UNSUCCESSFUL'
    ) ;
  When INVALID_EMPNO then
      raise_application_error (-20001, 'Invalid employee - INSERT UNSUCCESSFUL'
    ) ;
    
  END ADD_JOB_SUPPORT;

  PROCEDURE ADD_ABSENCE 
(
  ARG_EMPNO IN ABSENCE.EMP_NO%type
, ARG_SDATE IN ABSENCE.ABSENCE_SDATE%type
, ARG_EDATE IN ABSENCE.ABSENCE_EDATE%type 
, Arg_paid in ABSENCE.ABSENCE_PAID%type
, Arg_type in ABSENCE.ABSENCE_TYPE%type
, ARG_ATT1 IN Char 
, ARG_ATT2 IN Char
) AS
Invalid_empno Exception;
 Invalid_course Exception;
 Invalid_date Exception;
 Invalid_type Exception;
 Invalid_attribute Exception;
 emp_count number;
 course_count number;
  BEGIN
    -- TODO: Implementation required for PROCEDURE MT_SUPPORT.ADD_ABSENCE
    Select Count(*)
  Into emp_count
  from employee
  where emp_no = arg_empno;
  --verify employee
  If emp_count = 1 then
  --verify end date is after start date
    If to_date(arg_edate,'dd/mm/yyyy') > to_date(arg_sdate,'dd/mm/yyyy') then
    --insert into absence table
     insert into absence values (arg_empno, arg_sdate, arg_edate, arg_paid, arg_type);  
     If arg_type = 'P' or arg_type = 'T' or arg_type = 'V' then
        If arg_att1 = 'Y' or arg_att1 = 'N' then
        -- if Training absence then verify course and insert into Training table
          If arg_type = 'T' then
            Select Count(*)
            Into course_count
            from course
            where course_code = arg_att2;
            If course_count =1 then 
             insert into training values (arg_empno, arg_sdate, arg_att1, arg_att2);
            else
             raise  invalid_course;
            end if;
          --insert into personal table
          Elsif arg_type= 'P' then
            insert into personal values (arg_empno, arg_sdate, arg_att1, arg_att2);
          --insert into vacation table  
          Elsif arg_type = 'V' then
            insert into vacation values (arg_empno, arg_sdate, arg_att1);
          end if;
       else
         raise Invalid_attribute;
       end if;
      else
         raise Invalid_type;
       end if;
     else
         raise Invalid_date;
     end if;
   else
      raise Invalid_empno;
   end if;
   
    EXCEPTION
  When INVALID_Date THEN
       raise_application_error (-20001, 'Invalid Date - INSERT UNSUCCESSFUL'
    ) ;
  When INVALID_empno then
      raise_application_error (-20001, 'Invalid Employee - INSERT UNSUCCESSFUL'
    ) ;
  When INVALID_Course then
      raise_application_error (-20001, 'Invalid Course - INSERT UNSUCCESSFUL'
    ) ;  
    When INVALID_type then
      raise_application_error (-20001, 'Invalid Absence type, must be P,T or V - INSERT UNSUCCESSFUL'
    ) ;
  When INVALID_attribute then
      raise_application_error (-20001, 'First attribute must be either Y or N - INSERT UNSUCCESSFUL'
    ) ;  
  END ADD_ABSENCE;

  PROCEDURE RETURN_CLIENT_JOB 
(
  ARG_CLIENTNO IN VARCHAR2 
, ARG_SDATE IN date
, ARG_EDATE IN date 
, Client_CURSOR OUT sys_refcursor
, Job_CURSOR OUT sys_refcursor
, Employee_CURSOR OUT sys_refcursor
) AS
Invalid_Client exception;
 Invalid_Date exception;
 client_count number;
  BEGIN
    -- TODO: Implementation required for PROCEDURE MT_SUPPORT.RETURN_CLIENT_JOB
     select count(*)
  into client_count
  from client
  where client_no = arg_clientno;
  
  If client_count =1 then
  --verify end date is after start date
     If to_date(arg_edate,'dd/mm/yyyy')>= to_date(arg_sdate,'dd/mm/yyyy') then
     --open cursor contains client's info
     open Client_CURSOR for
     select *
     from client
     where client.client_no = arg_clientno;
     --open cursor contains job's info during the date range
     open Job_CURSOR for
     select job_no, job_sdate, job_edate, spec_code
     from job
     where job.client_no = arg_clientno and job_sdate>=arg_sdate and job_edate<arg_edate ;
     --open cursor contains employees' info
     open Employee_CURSOR for
     select js.EMP_NO, e.emp_gname ||' '||e.emp_fname as emp_name, js.job_rating as emp_rating, js.job_hrs as emp_hours
     from employee e join job_support js on e.emp_no=js.EMP_NO
          join job j on j.job_no=js.job_no 
          where j.client_no =arg_clientno and job_sdate>=arg_sdate and job_edate<arg_edate; 
     else
          raise Invalid_date;
     end if;
   else
          raise Invalid_client;
   end if;   
   
   EXCEPTION
  When INVALID_date THEN
       raise_application_error (-20001, 'Invalid date - INSERT UNSUCCESSFUL'
    ) ;
  When INVALID_Client then
      raise_application_error (-20001, 'Invalid client - INSERT UNSUCCESSFUL'
    ) ;
  END RETURN_CLIENT_JOB;

END MT_SUPPORT;
/
