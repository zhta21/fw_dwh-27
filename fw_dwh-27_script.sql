-- drop

drop table if exists dwh.fact_flights;
drop table if exists dwh.reject_fact_flights;
drop table if exists dwh.dim_calendar;
drop table if exists dwh.dim_passengers;
drop table if exists dwh.reject_dim_passengers;
drop table if exists dwh.dim_aircrafts;
drop table if exists dwh.reject_dim_aircrafts;
drop table if exists dwh.dim_airports;
drop table if exists dwh.reject_dim_airports;
drop table if exists dwh.dim_tariff;
drop table if exists dwh.reject_dim_tariff;
drop schema if exists dwh;

create schema dwh;

-- dim_calendar

create table dwh.dim_calendar as 
with dates as (
    select dd::date as dt
    from generate_series
            ('2016-01-01'::timestamp, 
            '2030-01-01'::timestamp, 
            '1 day'::interval) dd
)
select
    to_char(dt, 'yyyymmdd')::int as id,
    dt::timestamp as "date",
    to_char(dt, 'yyyy-mm-dd') as ansi_date,
    date_part('isodow', dt)::int as "day",
    date_part('week', dt)::int as week_number,
    date_part('month', dt)::int as "month",
    date_part('isoyear', dt)::int as "year",
    (date_part('isodow', dt)::smallint between 1 and 5)::int as weekday,
    (date_part('isodow', dt)::smallint between 6 and 7)::int as weekend
from dates
order by dt;

alter table dwh.dim_calendar add primary key (id);

-- dim_passengers

create table dwh.dim_passengers (
	id serial not null primary key,
	passenger_id varchar(20) not null,
	"name" varchar (100) not null,
	phone varchar(12) not null,
	email varchar (100));

-- reject_dim_passengers

create table dwh.reject_dim_passengers (
	passenger_id text,
	"name" text,
	phone text,
	email text);
	
-- dim_aircrafts

create table dwh.dim_aircrafts (
	id serial2 not null primary key,
	aircraft_code char(3) not null,
	model varchar(50) not null,
	"range" int4 not null,
	count_seats int2 not null,
	economy_seats int2,
	comfort_seats int2,
	business_seats int2);
	
-- reject_dim_aircrafts

create table dwh.reject_dim_aircrafts (
	aircraft_code text,
	model text,
	"range" int4,
	count_seats int2,
	economy_seats int2,
	comfort_seats int2,
	business_seats int2);

-- dim_airports

create table dwh.dim_airports (
	id serial not null primary key,
	airport_code char(3) not null,
	"name" varchar(50) not null,
	city varchar(50) not null,
	longitude float8 not null,
	latitude float8 not null,
	timezone varchar(50) not null);

-- reject_dim_airports

create table dwh.reject_dim_airports (
	airport_code text,
	"name" text,
	city text,
	longitude float8,
	latitude float8,
	timezone text);

-- dim_tariff

create table dwh.dim_tariff (
	id serial2 not null primary key,
	service_class varchar(20) not null);

-- reject_dim_tariff

create table dwh.reject_dim_tariff (
	service_class text);

-- fact_flights

create table dwh.fact_flights (
	passenger_key int not null references dwh.dim_passengers(id),
	actual_departure timestamptz not null,
	actual_arrival timestamptz not null,
	departure_delay int not null,
	arrival_delay int not null,
	aircraft_key int2 not null references dwh.dim_aircrafts(id),
	departure_airport_key int not null references dwh.dim_airports(id),
	arrival_airport_key int not null references dwh.dim_airports(id),
	service_class_key int2 not null references dwh.dim_tariff(id),
	amount numeric(10, 2) not null);

-- reject_fact_flights

create table dwh.reject_fact_flights (
	passenger_id text,
	actual_departure timestamptz,
	actual_arrival timestamptz,
	scheduled_departure timestamptz,
	scheduled_arrival timestamptz,
	aircraft_code text,
	departure_airport text,
	arrival_airport text,
	fare_conditions text,
	amount numeric(10, 2));