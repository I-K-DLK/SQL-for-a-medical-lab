
-- Создадим рабочую  схему

create schema lab;


/*
Создадим таблицу с анализами, выполняемыми лабораторией Analysis, где:
an_id — ID анализа;
an_name — название анализа;
an_cost — себестоимость анализа;
an_price — розничная цена анализа;
an_group — группа анализов.
Создадим таблицу групп анализов Groups:
gr_id — ID группы;
gr_name — название группы;
gr_temp — температурный режим хранения.
И таблицу заказов Orders:
ord_id — ID заказа;
ord_datetime — дата и время заказа;
ord_an — ID анализа.
*/

create table lab.analysis(
an_id int primary key not null,
an_name varchar(20),
an_cost int,
an_price int,
an_group int
);
 

create table lab.groups(
gr_id int primary key not null,
gr_name varchar(30),
gr_temp varchar
);

create table lab.orders(
ord_id int primary key not null,
ord_datetime timestamp,
ord_an int
);
 
-- Заполним таблицы данными

insert into lab.analysis values
(1,'Covid_1',1000,1500,1),
(2,'Covid_2',1100,1600,1),
(3,'Covid_3',1400,1700,1),
(4,'АСТМА_1',1300,1500,2),
(5,'АСТМА_2',1100,1600,2),
(6,'АСТМА_3',1000,1300,2),
(7,'Псориаз_1',1000,1400,3),
(8,'Псориаз_2',1200,1600,3),
(9,'Псориаз_3',900,1000,3)
 

insert into lab.groups values
(1,'Covid','8'),
(2,'АСТМА','12'),
(3,'Псориаз','4')
  

insert into lab.orders values
(1,'2020-02-10 00:00:00.000',1),
(2,'2020-02-11 00:00:00.000',1),
(3,'2020-02-14 00:00:00.000',2),
(4,'2020-02-09 00:00:00.000',3),
(5,'2020-02-05 00:00:00.000',1),
(6,'2020-02-08 00:00:00.000',2),
(7,'2020-02-09 00:00:00.000',4),
(8,'2020-02-03 00:00:00.000',6),
(9,'2020-02-06 00:00:00.000',7),
(10,'2020-02-09 00:00:00.000',6),
(11,'2020-02-09 00:00:00.000',9),
(12,'2020-02-07 00:00:00.000',8),
(13,'2020-02-01 00:00:00.000',5),
(14,'2020-02-03 00:00:00.000',1),
(15,'2020-03-10 00:00:00.000',1),
(16,'2020-03-11 00:00:00.000',1),
(17,'2020-04-14 00:00:00.000',2),
(18,'2020-05-09 00:00:00.000',3),
(19,'2020-06-05 00:00:00.000',1),
(20,'2020-05-08 00:00:00.000',2),
(21,'2020-07-09 00:00:00.000',4),
(22,'2020-08-03 00:00:00.000',6),
(23,'2020-08-06 00:00:00.000',7),
(24,'2020-07-09 00:00:00.000',6),
(25,'2020-08-09 00:00:00.000',9),
(26,'2020-10-07 00:00:00.000',8),
(27,'2020-10-01 00:00:00.000',5),
(28,'2020-12-03 00:00:00.000',1),
(29,'2020-01-01 00:00:00.000',5),
(30,'2020-01-03 00:00:00.000',1);
  
-- SQL запрос 1:
--Выведем название и цену для всех медицинских тестов, которые продавались 5 февраля 2020 года и всю следующую неделю.
 
select distinct a.an_name as "тест" , a.an_price as "цена" 
from lab.analysis a 
inner join lab.orders o on a.an_id = o.ord_an
where o.ord_datetime between '2020-02-05'::timestamp  
and  '2020-02-05'::timestamp + interval '1 week';

-- Результат 
/*
Тест     |Цена|
---------+----+
Covid_1  |1500|
Covid_2  |1600|
Covid_3  |1700|
АСТМА_1  |1500|
АСТМА_3  |1300|
Псориаз_1|1400|
Псориаз_2|1600|
Псориаз_3|1000|
*/

 
-- SQL запрос 2:
-- Нарастающим итогом рассчитаем, как увеличивалось количество проданных тестов каждый месяц каждого года с разбивкой по группе.

with t1 as ( 
select g.gr_id, count(a.an_name) as count, extract(month from o.ord_datetime) as month, extract(year from o.ord_datetime) as year
from lab.groups g 
inner join lab.analysis a on a. an_group = g. gr_id
inner join lab.orders o on a.an_id = o.ord_an
group by gr_id, month, year
order by  gr_id asc, month asc, year desc)

select gr_id as "Группа", count as "Количество", sum(count) over(partition by gr_id order by month,year ) as "Итог", month as "Месяц", year as "Год" 
from t1
order by Группа asc, Год desc, Месяц asc;

-- Результат
/*
Группа|Количество|Итог|Месяц|Год |
------+----------+----+-----+----+
     1|         1|   1|    1|2020|
     1|         7|   8|    2|2020|
     1|         2|  10|    3|2020|
     1|         1|  11|    4|2020|
     1|         2|  13|    5|2020|
     1|         1|  14|    6|2020|
     1|         1|  15|   12|2020|
     2|         1|   1|    1|2020|
     2|         4|   5|    2|2020|
     2|         2|   7|    7|2020|
     2|         1|   8|    8|2020|
     2|         1|   9|   10|2020|
     3|         3|   3|    2|2020|
     3|         2|   5|    8|2020|
     3|         1|   6|   10|2020|
*/

-- SQL запрос 3:
-- Выведем тест с максимальной годовой выручкой для каждой группы за 2020 год.

with t1 as ( 
select g.gr_id, a.an_name, sum(a.an_price) as sum
from lab.groups g 
inner join lab.analysis a on a. an_group = g. gr_id
inner join lab.orders o on a.an_id = o.ord_an
where extract(year from o.ord_datetime) = 2020
group by gr_id, a.an_name),

t2 as(
select gr_id, an_name,sum, dense_rank() over(partition by gr_id order by sum desc) as rank 
from t1)
 
select gr_id as "Группа", an_name as "Тест", sum as "Выручка" 
from t2
where rank = 1
order by Группа asc, Выручка desc;

-- Результат
/*
Группа|Тест     |Выручка|
------+---------+-------+
     1|Covid_1  |  13500|
     2|АСТМА_3  |   5200|
     3|Псориаз_2|   3200|
*/


/*
Создадим таблицу балансов клиентов лаборатории:
ClientBalance(client_id, client_name, client_balance_date, client_balance_value)
client_id — идентификатор клиента;
client_name — ФИО клиента;
client_balance_date — дата баланса клиента;
client_balance_value — значение баланса клиента.
*/

drop table lab.client_balance;
create table lab.client_balance(
client_id int, 
client_name varchar, 
client_balance_date date, 
client_balance_value int
) 

insert into lab.client_balance values
(1, 'Ivan', '2020-12-02', 1234123),
(2, 'Dima', '2020-12-02', 34345), 
(3, 'Vasya', '2020-12-02', 34536),
(4, 'Vova', '2020-12-02', 4646),
(5, 'Kolya', '2020-12-02', 4564),
(1, 'Ivan', '2020-12-02', 1234123),
(1, 'Ivan', '2020-12-02', 1234123),
(2, 'Dima', '2020-12-02', 34345)


select * from lab.client_balance;

/*
client_id|client_name|client_balance_date|client_balance_value|
---------+-----------+-------------------+--------------------+
        1|Ivan       |         2020-12-02|             1234123|
        2|Dima       |         2020-12-02|               34345|
        3|Vasya      |         2020-12-02|               34536|
        4|Vova       |         2020-12-02|                4646|
        5|Kolya      |         2020-12-02|                4564|
        1|Ivan       |         2020-12-02|             1234123|
        1|Ivan       |         2020-12-02|             1234123|
        2|Dima       |         2020-12-02|               34345|
*/

/*
Предположим, что в данной таблице в какой-то момент времени появились полные дубли. Можно ли от них избавиться без создания новой таблицы?

Перед избавлением от полных дублей нужно задать вопрос: нужно ли удалить дубликаты или изменить дублирующие записи таким образом, 

чтобы они снова стали уникальными? /
В первом случае в PostgreSQL можно удалить все дублирующие записи с помощью запроса:
*/

with cte as(
select ctid from lab.client_balance cb1
where ctid > (select min(ctid) 
			  from lab.client_balance cb2
			  where cb1.client_id = cb2.client_id 
			  	and cb1.client_name = cb2.client_name 
			  	and cb1.client_balance_date = cb2.client_balance_date
			  	and cb1.client_balance_value = cb2.client_balance_value))
delete from lab.client_balance 
	where ctid in (select * from cte);	

select * from lab.client_balance;

-- Результат
/*
client_id|client_name|client_balance_date|client_balance_value|
---------+-----------+-------------------+--------------------+
        1|Ivan       |         2020-12-02|             1234123|
        2|Dima       |         2020-12-02|               34345|
        3|Vasya      |         2020-12-02|               34536|
        4|Vova       |         2020-12-02|                4646|
        5|Kolya      |         2020-12-02|                4564|
*/


/*
Во втором случае самый простой способ устранения полных дублей заключается в добавлении нового поля ID в таблицу. 
При этом любая запись, имеющая одинаковые значения в исходных полях с другой записью, будет отличаться значением в поле ID, 
а значит снова станет уникальной.
Например, в PostgreSQL выполнить это можно с помощью запроса:
*/
alter table lab.clientbalance add column row_id bigint generated by default as identity;


 