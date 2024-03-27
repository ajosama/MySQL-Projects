select * from employees;

/* Employees with salary more than the average salary of all employees */

select emp_name, dept, salary
from employees where salary > (select avg(salary) from employees);

/* Employees with salary more than Ammy's salary */

select emp_name, gender, dept, salary
from employees
where salary > (select salary from employees where emp_name = 'Ammy');

use classicmodels;
select * from products;
select * from orderdetails;

/* priceEach is less than $ 100 */

select productcode, productname, MSRP from products
where productcode in (select productcode from orderdetails where priceeach < 100);

/* Stored Procedure */
/* list of top player who scored more than 6 goals in a tournament */

use sql_new;
delimiter &&
create procedure top_player()
begin 
select name,country, goals
from players where goals > 6;
End &&
delimiter ;

call top_player();

/* Stored Procedure using IN */
delimiter //
create procedure sp_sortBySalary (IN var int)
begin
select name, age, salary from emp_details
order by salary desc limit var;
end //
delimiter ;

call sp_sortBySalary(3);

delimiter //
create procedure update_salary (IN temp_name varchar(20), IN new_salary float)
begin
update emp_details 
set salary = new_salary where name = temp_name;
end; //

call update_salary ('Sara',80000);

/* Stored procedure using OUT parameter */

delimiter //
create procedure sp_CountEmployees (OUT Total_Emps int)
begin
select count(name) into Total_Emps from emp_details
where sex = 'F';
end //
delimiter ;

call sp_CountEmployees (@F_emp);
select @F_emp as female_emps; 