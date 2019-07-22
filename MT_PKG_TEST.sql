spool 'C:/Users/Doom/Desktop/BBIS S1 2017/FIT2077/MT_Support_pkg_test_output.txt'
--test add job Job_PROC procedure

   --all correct input
var new_jobno number
exec MT_SUPPORT.job_proc(:new_jobno,TO_DATE('16/02/2016', 'DD/MM/YYYY'),TO_DATE('17/02/2016', 'DD/MM/YYYY'),6,'WIN');
select*from job;
rollback;

   --incorrect date
exec MT_SUPPORT.job_proc(:new_jobno,TO_DATE('16/02/2016', 'DD/MM/YYYY'),TO_DATE('17/01/2016', 'DD/MM/YYYY'),6,'WIN');

   --incorrect client
exec MT_SUPPORT.job_proc(:new_jobno,TO_DATE('16/02/2016', 'DD/MM/YYYY'),TO_DATE('17/02/2016', 'DD/MM/YYYY'),20,'WIN');

   --incorrect spec_code
exec MT_SUPPORT.job_proc(:new_jobno,TO_DATE('16/02/2016', 'DD/MM/YYYY'),TO_DATE('17/02/2016', 'DD/MM/YYYY'),6,'N');




--test Add_Manager_Review procedure

   --correct input
exec MT_SUPPORT.ADD_MANAGER_REVIEW(3,TO_DATE('16/02/2018', 'DD/MM/YYYY'),'P', 2);
rollback;

   --incorrect manager
exec MT_SUPPORT.ADD_MANAGER_REVIEW(7,TO_DATE('16/02/2018', 'DD/MM/YYYY'),'P', 2);

   --incorrect date
exec MT_SUPPORT.ADD_MANAGER_REVIEW(3,TO_DATE('16/02/2014', 'DD/MM/YYYY'),'P', 2);

   --reviewer and reviewee are the same or incorrect reviewer
exec MT_SUPPORT.ADD_MANAGER_REVIEW(2,TO_DATE('16/02/2018', 'DD/MM/YYYY'),'P', 2);
exec MT_SUPPORT.ADD_MANAGER_REVIEW(3,TO_DATE('16/02/2018', 'DD/MM/YYYY'),'P', 7);

  --reviewee is owner
exec MT_SUPPORT.ADD_MANAGER_REVIEW(5,TO_DATE('16/02/2018', 'DD/MM/YYYY'),'P', 2);

  --invalid rating
exec MT_SUPPORT.ADD_MANAGER_REVIEW(3,TO_DATE('16/02/2018', 'DD/MM/YYYY'),'o', 2);



--test ADD_JOB_SUPPORT

   --correct input
delete from job_support;
update support
set support_hrs_comp = 0, SUPPORT_RATING= null;
exec MT_Support.ADD_JOB_SUPPORT(6,4,4,4);
exec MT_Support.ADD_JOB_SUPPORT(6,3,5,3);
exec MT_Support.ADD_JOB_SUPPORT(7,2,3,5);
exec MT_Support.ADD_JOB_SUPPORT(7,1,2,6);
select*from job_support;
select emp_no, support_rating, support_hrs_comp from support; 
rollback;

   --incorrect employee
exec MT_Support.ADD_JOB_SUPPORT(10,1,2,6);

   --incorrect job
exec MT_Support.ADD_JOB_SUPPORT(7,9,2,6);



--test Add_Absence

   --Add training
delete from training;
delete from personal;
delete from vacation;
delete from absence;
exec MT_SUPPORT.Add_absence(3,to_date('28/06/2017','dd/mm/yyyy'),to_date('28/08/2017','dd/mm/yyyy'),'Y','T','N','FIT01');
select*from absence;
select*from training;

   --insert vacation
exec MT_SUPPORT.Add_absence(4,to_date('28/06/2017','dd/mm/yyyy'),to_date('28/08/2017','dd/mm/yyyy'),'Y','V','N',null);
select*from absence;
select*from vacation;

   --insert personal
exec MT_SUPPORT.Add_absence(5,to_date('28/06/2017','dd/mm/yyyy'),to_date('28/08/2017','dd/mm/yyyy'),'Y','P','N','Y');
select*from absence;
select*from training;

rollback;

  --incorrect employee
exec MT_SUPPORT.Add_absence(12,to_date('28/06/2017','dd/mm/yyyy'),to_date('28/08/2017','dd/mm/yyyy'),'Y','V','N',null);

  --incorrect date
exec MT_SUPPORT.Add_absence(4,to_date('28/06/2017','dd/mm/yyyy'),to_date('28/05/2017','dd/mm/yyyy'),'Y','V','N',null);



--test Return_Client_Job

var new_cursor1 refcursor;
     var new_cursor2 refcursor;
     var new_cursor3 refcursor;
     exec MT_SUPPORT.return_client_job(1,TO_DATE('12/02/2016','DD/MM/YYYY'),TO_DATE('22/02/2016','DD/MM/YYYY'),:new_cursor1,:new_cursor2,:new_cursor3);
     print new_cursor1;
     print new_cursor2;
     print new_cursor3;
     
var new_cursor1 refcursor;
     var new_cursor2 refcursor;
     var new_cursor3 refcursor;
     exec return_client_job(1,TO_DATE('12/02/2016','DD/MM/YYYY'),TO_DATE('18/02/2016','DD/MM/YYYY'),:new_cursor1,:new_cursor2,:new_cursor3);
     print new_cursor1;
     print new_cursor2;
     print new_cursor3;     
     
  spool off;