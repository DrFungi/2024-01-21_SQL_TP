alter session set NLS_Date_Format = 'yyyy-mm-dd';

-- 1. Which were the hottest and coldest years in the station

select local_date, max(max_temperature)
from clima_mtl 
where max_temperature = (select max(max_temperature) from clima_mtl)
group by local_date;

select local_date,min(min_temperature)
from clima_mtl 
where min_temperature = (select min(min_temperature) from clima_mtl)
group by local_date;

--2. what is the average amount of snow fall by month in the whole range of years

select 
CASE local_month
    WHEN 1 THEN 'January'
    WHEN 2 THEN 'February'
    WHEN 3 THEN 'March'
    WHEN 4 THEN 'April'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'June'
    WHEN 7 THEN 'July'
    WHEN 8 THEN 'August'
    WHEN 9 THEN 'September'
    WHEN 10 THEN 'October'
    WHEN 11 THEN 'November'
    WHEN 12 THEN 'December'
  END AS month,
  round(avg(snow_on_ground),2) as snow_fallen_cm
from clima_mtl
group by local_month
order by avg(snow_on_ground)desc;

--3. which year has had the most snow on ground

select local_year, max(total_snow)
from clima_mtl
group by local_year
order by max(total_snow) desc;

-- 4. which year has had the longest snow season

select local_year, count(total_snow) snow_fallen_CM
from clima_mtl
where total_snow != 0
group by local_year
order by count(total_snow) desc;

-- 5. number of days of extreme cold ( less than -10C) for at least 3 days in a row

select local_year, count(flag) "3day_strike_of_cold"
from(
select local_year, local_month, local_day, local_date, mean_temperature,
case 
  when mean_temperature < -10
      and lead(mean_temperature) over(order by local_date) < -10 --lead() allows to access data in subsequent rows
      and lead(mean_temperature, 2) over(order by local_date) < -10
  then 'very_cold'
  when mean_temperature < -10
    and lag(mean_temperature) over(order by local_date) < -10 --lag() allows to access data in preceding rows within the result set based on the order specified
    and lead(mean_temperature) over(order by local_date) < -10
  then 'very_cold'
  when mean_temperature < -10
    and lag(mean_temperature) over(order by local_date) < -10 
    and lag(mean_temperature, 2) over(order by local_date) < -10
  then 'very_cold'
  else null
end as flag
from clima_mtl
order by local_date) x
where local_year not in (2024, 2013) -- both these years are excluded for not being complete
group by local_year
order by local_year;

-- 6. what is the total amount of precipitation per year

select local_year, round(sum(total_precipitation), 0)as tot_precipitation_cm
from clima_mtl
where local_year != 2024
group by (local_year)
order by local_year;

-- 7. which year has had the most precipitation separated as rain and snow

select local_year, round(sum(nvl(total_precipitation,0)),0) tot_prep, round(sum(nvl(total_rain,0)),0) rain, round(sum(nvl(total_snow,0)),0) snow
from clima_mtl
where local_year != 2024
group by local_year
order by sum(nvl(total_precipitation,0));

-- 8. What is the average relative humidity in the wettest year

select local_year wettest_year, round(avg(((max_rel_humidity+min_rel_humidity)/2)),1) avg_rel_humidity
from clima_mtl
where local_year = (
  select local_year
  from (
      select local_year, sum(total_precipitation)
      from clima_mtl
      group by local_year
      having local_year >= 2018  -- this is necesary because relative humidity data start in 2018
      order by sum(total_precipitation) desc)
  where rownum = 1)
group  by local_year;






/*****************************************************************************
questions to ask to this dataset:
1. !!! which has been the coldest and hottest year
2. !!! what is the average amount of snow fall by month in the whole range of years
3. !!! which year has had the most snow on the ground
4. !!! which year has had the longest snow season
5. !!! number of days of extreme cold for 3 or more days
6. !!! what is the total amount of precipitation per year
7. !!! which year has had the most precipitation separated as rain and snow
8. What is the average relative humidity in the wettest year
9. what is the most amount of snow fallen in one day
10. 



Cuál es la temperatura promedio para cada uno de los años Cuál es el mes más frío y el mes más caliente. 

Cuánta nieve cayó en un determinado año 

Cuál es la humedad relativa promedio cuando cae una cierta cantidad de nieve. 

Cuál es la máxima y la mínima humedad relativa promedio para determinado año. 

ambién quisiera saber cuántos días por año ha tenido que calentar las casas 
las personas de Montreal y cuántos días por año han tenido que prender el 
aire acondicionado las personas de Montreal esto se puede hacer para todos 
los años y para el año que más ha ocurrido. */



