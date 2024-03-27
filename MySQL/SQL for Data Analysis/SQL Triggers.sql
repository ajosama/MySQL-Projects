create database triggers;
use triggers;

/* before insert trigger */
create table customers
(
cust_id int,
age int,
name varchar(30)
);

delimiter //
create trigger age_verify
before insert on customers
for each row 
if new.age < 0 then set new.age = 0;
end if; //

insert into customers
values(101,27,'James'),
(102,-40,'Ammy'),
(103,32,'Ben'),
(104,-39,'Angela');

select * from customers;

/* after insert trigger */
create table customers1
(
id int auto_increment primary key,
name varchar(40) not null,
email varchar(30),
birthdate date
);

create table message
(
id int auto_increment,
messageId int,
message varchar(300) not null,
primary key(id,messageId)
);

Delimiter //
create trigger check_null_dob
after insert on customers1
for each row
begin
if new.birthdate is null then
insert into message (messageId,message)
values (new.id,concat('Hi',new.name,', please update your date of birth'));
end if;
end //
delimiter ;

insert into customers1 (name,email,birthdate)
values ('Nancy','nancy@abc.com',NULL),
('Ronald','ronald@xyz.com','1998-11-16'),
('Chris','chris@xyz.com','1997-08-20'),
('Alice','alice@anc.com',NULL);


/* before update */
create table employees
(
emp_id int primary key,
emp_name varchar(25),
age int,
salary float
);

insert into employees values
(101,'jimmy',35,70000),
(102,'shane',30,55000),
(103,'marry',28,28000),
(104,'dwayne',37,57000),
(105,'sara',32,72000),
(106,'ammy',35,80000),
(107,'jack',40,100000);

delimiter //
create trigger upd_trigger
before update on employees
for each row begin
if new.salary = 10000 then set new.salary = 85000;
elseif new.salary < 10000 then set new.salary = 72000;
end if;
end //
delimiter ;

update employees
set salary = 8000
where emp_id in (102,103,104);

select * from employees;

/* before delete */

create table salary 
(
eid int primary key,
validfrom date not null,
amount float not null
);

insert into salary (eid, validfrom, amount)
values (101,'2005-05-01',55000),
(102,'2007-08-01',68000),
(103,'2006-09-01',75000);

select * from salary;

create table salary_delete 
(
id int primary key auto_increment,
eid int,validfrom date not null,
amount float not null,
deleted_at timestamp default now()
);

delimiter $$ 
create trigger salary_delete1
before delete on salary
for each row begin
insert into salary_delete(eid,validfrom,amount)
value(old.eid,old.validfrom,old.amount);
end $$
delimiter ;

delete from salary
where eid = 103;

select * from salary;
select * from salary_delete;