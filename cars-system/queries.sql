--1 insert shops
insert into car_service_shops (country, city, street, zip, is_billing)
values ('Lithuania', 'Vilnius', 'Vilnius g', 'LT-01001', true),
       ('Lithuania', 'Kaunas', 'Kaunas g', 'LT-01002', true),
       ('Lithuania', 'Klaipeda', 'Klaipeda g', 'LT-01003', false),
       ('Spain', 'Madrid', 'santiago str', '01005', true),
       ('Spain', 'Barcelona', 'barcelona str', '01006', true),
       ('Spain', 'Valencia', 'valencia str', '01007', false),
       ('France', 'Paris', 'paris str', '01008', true),
       ('France', 'Lyon', 'lyon str', '01009', true),
       ('France', 'Marseille', 'marseille str', '01010', false);

-- 2 get all employees that added a car in Vilnius shop
select *
from employees
where id in (select employee_id
             from cars
                      join car_service_shops s
                           on cars.shop_id = s.id
             where s.shop_city = 'Vilnius');

-- 3 Select all customers that paid in credit card
select *
from customers
where id in (select customer_id from payments where payment_type = 'credit card');

-- 4 check how much money was spent in each shop
select s.shop_city, sum(p.amount)
from payments p
         join car_service_shops s
              on p.shop_id = s.id
group by s.shop_city;

-- 5 check how much a company has spent
select c.company_name, sum(p.amount)
from companies c
         join auth_users u on c.auth_id = u.id
         join payments p on u.id = p.auth_id
         join companies c on p.auth_id = c.auth_id
group by c.company_name;

-- 6 check what shops have more than 20 cars
select s.shop_city, count(c.id) as cars_count
from cars c
         inner join car_to_sell s
                    on c.id = s.car_id
         inner join car_to_rent r
                    on c.id = r.car_id
         left join car_service_shops s
                   on c.shop_id = s.id
where cars_count > 20
group by s.shop_city
order by cars_count desc;

-- 7 check how many cars each employee has added
select e.first_name, e.last_name, count(c.id) as cars_count
from employees e
         inner join cars c
                    on e.id = c.added_by
group by e.first_name, e.last_name
order by cars_count desc;

-- 8 Function to get employees count at each sho[
create function get_employee_count(shop_id int)
    returns int
    language plpgsql
as
$$
declare
employee integer;
begin
select count(*)
into film_count
from employees
where shop_id = shop_id return employee_count;
end;
$$;

-- 9 customers rent procedure
create
or replace procedure checkup(
   car int,
   last_check_up date
)
language plpgsql
as $$
begin
update car_rental_checkup
set last_check_up = NOW()
where car_id = car
  and last_check_up < NOW() - interval '1 month';

insert into car_rental_checkup (car_id, last_check_up)
    commit;
end;
$$;

-- 10 Get customers with more than 20% discount on rent cars
select c.id, c.first_name, c.last_name, c.email, c.phone
from customers c
         union
         join customers_rent_discount d
              on c.id = d.customer_id
where d.discount_per_day > 20;

-- 11 Delete users from banned table after 2 years of no ban
delete
from banned_users
where banned_until < NOW() - interval '2 years';

-- 12 Get all cars category that have been more than 20 times rented by customers
with rent as (select car_id, count(*) as rent_count
              from cars_rental
              group by car_id
              order by rent_count desc)
select c.id, c.category, cat.id, rent.rent_count
from cars
         join categories cat
              on c.category = cat.id
         join rent
              on c.id = rent.car_id
where rent.rent_count > 20;

-- 13 For each month of 2021, count how many rentals had amount greater than - this - month's average rental amount
SELECT year (cr.rent_from) as yr, month (cr.rent_from) as mnth, count (cr.id) as counter
FROM cars_rental as cr
WHERE year (cr.rent_from)=2021
  and a.amount
    >
    (SELECT avg (r.amount)
    from cars_rental as r
    where month (cr.rent_from)= month (r.rent_from)
  and year (cr.rent_from)= year (r.rent_from)
    group by month (r.rent_from))
group by month (cr.rent_from)

-- 14 Update car_to_sell table of BMW x5 cars add 1000 $
update car_to_sell
set price = price + 1000
where car_id in (select id from cars where model = 'BMW x5');

-- 15 Cheapest sold car
select cs.car_id, min(cs.amount), c.model
from car_sold cs
         right join cars c
                    on cs.car_id = c.id;

-- 16 Most expensive sold car
select cs.car_id, min(cs.amount), c.model
from car_sold cs
         right join cars c
                    on cs.car_id = c.id;

-- 17 Most expensive rented car
select cr.car_id, min(cr.amount), c.model
from cars_rental cr
         right join cars c
                    on cr.car_id = c.id;

-- 18 Add 10% discount to all companies in Ukraine on car buying
update companies_sell_discount
set discount_per_day = discount_per_day + 10
where company_id in (select id
                     from companies c
                              inner join addresses a on c.address_id = a.id
                     where a.country = 'Ukraine');

-- 19 How many cars each of employees have rented
select e.id, e.first_name, e.last_name, e.email, e.phone, count(cr.id) as c
from employees e
         inner join cars_rental cr
                    on e.auth_id = cr.auth_id
group by e.id, e.first_name, e.last_name, e.email, e.phone
order by count(cr.id) desc;

-- 20 union of all cars that have been bought and rented by customers
select c.id, c.model, c.year, cs.auth_id, cs.amount
from cars c
         inner join car_sold cs
                    on c.id = cs.car_id
where c.auth_id in (select auth_id
                    from customers)
union all
select c.id, c.model, c.year, cr.auth_id, cr.amount
from cars c
         inner join cars_rental cr
                    on c.id = cr.car_id
where c.auth_id in (select auth_id
                    from customers);

-- 21 count unique customers who have bought cars
select count(distinct c.auth_id)
from cars c
         inner join car_sold cs
                    on c.id = cs.car_id
where c.auth_id in (select auth_id
                    from customers);

-- 22 count unique companies who have rented cars in 2022
select count(distinct c.auth_id)
from cars c
         inner join cars_rental cr
                    on c.id = cr.car_id
where c.auth_id in (select auth_id
                    from companies)
          and year (cr.rent_from)=2022;

-- 23 Create customer master view new/old
create view customer_master as
select c.customer_id                      as id,
       c.first_name || ' ' || c.last_name AS name,
       a.country,
       a.street,
       a.city,
       case
           when year (c.created_at)=2022 then 'new'
                else 'old'
end
as status,
        c.email
        from customers c
             inner join addresses a on c.auth_id = a.auth_id;


-- 24 Create company master view new/old
create view company_master as
select c.id as id,
       c.company_name,
       a.country,
       a.street,
       a.city,
       case
           when year (c.created_at)=2022 then 'new'
                else 'old'
end
as status,
        c.email
        from companies c
             inner join addresses a on c.auth_id = a.auth_id;

-- 25 Select all cars added by employees from Vilnius in 2019
select c.id, c.model, c.year, c.auth_id, c.price
from cars c
         inner join employees e
                    on c.auth_id = e.auth_id
         inner join addresses a on e.address_id = a.id
where a.city = 'Vilnius'
          and year (c.created_at)=2019;

-- 26 analyzing average renting volume by an hour of the day and by work week days
select
    hour,
    avg ( case when weekday = 0 then rented else null end ) 'monday',
    avg ( case when weekday = 1 then rented else null end ) 'tuesday',
    avg ( case when weekday = 2 then rented else null end ) 'wednesday',
    avg ( case when weekday = 3 then rented else null end ) 'thursday',
    avg ( case when weekday = 4 then rented else null end ) 'friday',
    avg ( rented ) average_of_all
from (
    select
    extract ( hour from rent_from ),
    count (distinct id) as rented,
    extract (isodow from rent_from) as weekday
    from cars_rental
    group by 3, 1
    ) as hour
group by 1
order by 1;

-- 27 Count cars sold in first 4 months of 2022
select extract(month from created_at) as month,
    count (distinct car_id) as car_count
from cars_sold
where created_at >= '2022-01-01' and created_at<= '2022-04-31'
group by extract (month from created_at);

-- 28 Select only one car that was rented by customer with id = 201020120
select c.id, c.model, c.year, c.auth_id, c.price
from cars c
         inner join cars_rental cr
                    on c.id = cr.car_id
         inner join customers cus
                    on cr.auth_id = cus.auth_id
where cus.customer_id = '201020120' limit 1;

-- 29 Get all cars that were repaired in 2019 with price_per_day > 1000
select c.id, c.model, c.year, c.auth_id, sp.price_per_day
from cars c
         left join rent_pricing sp
                   on c.id = sp.car_id
         inner join car_rental_repair crr
                    on c.id = crr.car_id
where crr.repair_date >= '2019-01-01'
  and crr.repair_date <= '2019-12-31'
  and sp.price_per_day > 1000;

-- 30 Intersect of all cars that were rented and bought by customers from Vilnius
select c.id, c.model, c.year, c.auth_id
from cars c
         inner join cars_rental cr
                    on c.id = cr.car_id
         inner join customers cus
                    on cr.auth_id = cus.auth_id
where cus.auth_id in (select auth_id
                      from addresses
                      where city = 'Vilnius');
intersect
select c.id, c.model, c.year, c.auth_id
from cars c
         inner join cars_sold cs
                    on c.id = cs.car_id
         inner join customers cus
                    on cs.auth_id = cus.auth_id
where cus.auth_id in (select auth_id
                      from addresses
                      where city = 'Vilnius');

-- 31 Select all cars that were rented by employees from Madrid and have price_per_day > 1000
select c.id, c.model, c.year, c.auth_id
from cars c
         inner join cars_rental cr
                    on c.id = cr.car_id
         inner join employees e
                    on cr.auth_id = e.auth_id
         inner join rent_pricing sp
                    on c.id = sp.car_id
where e.auth_id in (select auth_id
                    from addresses
                    where city = 'Madrid')
  and sp.price_per_day > 1000
order by sp.price_per_day;

-- 32 Select max price_per_day for each car rented by companies in France
select c.id, c.model, c.year, cmp.id, max(sp.price_per_day)
from cars c
         inner join cars_rental cr
                    on c.id = cr.car_id
         inner join companies cmp
                    on cr.auth_id = cmp.auth_id
         left join rent_pricing sp
                   on c.id = sp.car_id
where cmp.auth_id in (select auth_id
                      from addresses
                      where country = 'France')
group by 1, 2, 3
order by 4;

-- 33 Select all cars that were sold for customers with discount > 10
select c.id, c.model, c.year, cus.id, csd.discount
from cars c
         inner join cars_sold cs
                    on c.id = cs.car_id
         inner join customers cus
                    on cs.auth_id = cus.auth_id
         left join customers_sell_discount csd
                   on cus.customer_id = csd.customer_id
where csd.discount > 10;

-- 34 Select all cars that were bought by customers from Vilnius and car model is 'BMW'
select c.id, c.model, c.year, c.auth_id
from cars c
         inner join cars_sold cs
                    on c.id = cs.car_id
         inner join customers cus
                    on cs.auth_id = cus.auth_id
where cus.auth_id in (select auth_id
                      from addresses
                      where city = 'Vilnius')
  and c.model = 'BMW';

-- 35 Avg price of all cars sold
select avg(cs.amount)
from cars_sold cs;

-- 36 Most expensive car in 2020
select c.id, c.model, c.year, max(sp.price)
from cars c
         inner join sell_pricing sp
                    on c.id = sp.car_id
where c.year = 2020;

-- 37. Add a new column containing the number of cars_rented for each customer
alter table cars_rental
    add rented_cars_number varchar;

update cars_rental
SET rented_cars_number = CASE WHEN LEFT (id, 3) <> 'gid' THEN id ELSE '' END;

-- 38 Customers Car sell analysis
select c.id,
       count(cs.id)                      sales,
       sum(sp.price * sd.discount / 100) revenue,
       sum(sp.price)                     margin,
       avg(revenue)                      average_sale_value
from cars c
         inner join cars_sold cs
                    on c.id = cs.car_id
         inner join sell_pricing sp
                    on c.id = sp.car_id
         right join customers_sell_discount sd
                    on cs.auth_id = sd.customer_id
group by 1
order by 2 desc;

-- 39 Companies Car rent analysis
select c.id,
       count(cr.id)                              rents,
       sum(rp.price_per_day * rd.discount / 100) revenue,
       sum(rp.price_per_day)                     margin,
       avg(revenue)                              average_rent_value
from cars c
         inner join cars_rental cr
                    on c.id = cr.car_id
         inner join rent_pricing sp
                    on c.id = sp.car_id
         right join companies_rent_discount rd
                    on cr.auth_id = rd.company_id
group by 1
order by 2 desc;

-- 40 Car repair analysis
select c.id,
       count(crr.id)        repairs,
       sum(crr.repair_cost) cost,
       avg(cost)            average_repair_value
from cars c
         inner join car_rental_repair crr
                    on c.id = crr.car_id
group by 1
order by 2 desc;

-- 41 Select all customers who have bought more than one car
select cus.id, cus.name, cus.surname, count(cs.id)
from customers cus
         inner join cars_sold cs
                    on cus.auth_id = cs.auth_id
group by 1, 2, 3
having count(cs.id) > 1;

-- 42 Select all companies located in Vilnius
select cmp.id, cmp.company_name
from companies cmp
         left join addresses ad
                   on cmp.auth_id = ad.auth_id
where ad.city = 'Vilnius';

-- 43 Employees who have worked for more than one year
select e.id, e.name, e.surname
from employees e
where created_at < Now() - INTERVAL 1 YEAR
order by created_at;

-- 44 Select employees in Lyon shop who have rented more than one car
select e.id, e.name, e.surname, count(cr.id)
from employees e
         inner join cars_rental cr
                    on e.auth_id = cr.auth_id
group by 1, 2, 3
having count(cr.id) > 1;

-- 45 Count all companies located in Ukraine
select count(cmp.id)
from companies cmp
         left join addresses ad
                   on cmp.auth_id = ad.auth_id
where ad.country = 'Ukraine';
