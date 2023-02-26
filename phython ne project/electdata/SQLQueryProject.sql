create Database World_electricity_analysis
use world_electricity_analysis
---1.Comparison of access to electricity post 2000s in different countries
Select * from 
select Country_Code, Country_Name, AVG([Values]) as 'Access_to_Electricity%' 
from access_to_world where Year>2000
group by Country_Code, Country_Name;

---2.Find one interesting insight present in the data (across all the tables)

--DISTRIBUTION LOSSES AND PRODUCTION SOURCES
select l.Country_Code,avg(l.[Values]) as 'avg_loss_%_of_output',avg(o.[Values]) as 'avg%_production_of_electricity_by_oil', avg(n.[Values]) as 'avg%_production_of_electricity_by_nuclear'
from transmission_distribution_losses as l
join production_by_nuclear as n
on l.Country_Code=n.Country_Code and l.[Year] = n.[Year]
join production_by_oil as o
on n.Country_Code=o.Country_Code and n.[Year] = o.[Year]
where l.[Year] >=2000
group by l.Country_Code, l.Country_name
having avg(l.[Values])>0
order by avg(l.[Values]) desc;

--DISTRIBUTION LOSSES AND ACCESSIBILITY
select l.Country_Code, l.Country_name, avg(l.[Values]) as 'avg_loss_%_of_output', avg(w.[Values]) as 'avg_access_to_electricity'
from transmission_distribution_losses as l
join access_to_world as w
on l.Country_Code=w.Country_Code and l.[Year] = w.[Year]
where l.[Year] >=2000
group by l.Country_Code, l.Country_name
having avg(l.[Values])>0
order by avg(l.[Values]) desc;


---3.Present a way to compare every country’s performance with respect to world average for every year. 
--As in, if someone wants to check how is the accessibility of electricity in India in 2006 
--as compared to average access of the world to electricity

With World_Avg_Access_to_Electricity as
(select [Year],avg([Values]) as 'World_Avg_Access_to_Electricity' from access_to_world
group by [Year])
select Country_Name,Country_Code, Indicator_Name, a.[Year], 
[Values] as 'Country_Access_to_Electricity%', World_Avg_Access_to_Electricity 
from access_to_world as a
join World_Avg_Access_to_Electricity as b
on a.[Year]=b.[Year];

---4.A chart to depict the increase in count of country with greater than 75% electricity
--access in rural areas across different year. For example, what was the count of countries 
--having ?75% rural electricity access in 2000 as compared to 2010.

select [Year], count(Country_Code) as No_of_Countries from access_to_rural
where [Values]>=75
group by [Year]
order by [Year];

---5.Define a way/KPI to present the evolution of nuclear power presence grouped by Region and IncomeGroup. 
--How was the nuclear power generation in the region of Europe & Central Asia as compared to Sub-Saharan Africa.

--EVOLUTION OF NUCLEAR PRODUCTION % GROUPED BY INCOME GROUP
select [Year], IncomeGroup, avg([Values]) as '%_of_electricity_by_nuclear_production' 
from production_by_nuclear as n
left join Countries_Metadata as c
on n.Country_Code = c.Country_Code
where IncomeGroup is not null
group by IncomeGroup,[Year]
order by [Year],IncomeGroup;
--EVOLUTION OF NUCLEAR PRODUCTION % GROUPED BY REGION
select [Year], Region, avg([Values]) as '%_of_electricity_by_nuclear_production' 
from production_by_nuclear as n
left join Countries_Metadata as c
on n.Country_Code = c.Country_Code
where Region is not null
group by Region,[Year]
order by [Year], Region;

---6.A chart to present the production of electricity across different sources (nuclear, oil, etc.) as a function of time

select cast(concat('01-01-',cast(o.[Year] as nvarchar)) as date) as [Year],(avg(o.[Values])+avg(n.[Values])) as '%production_of_electricity_by_oil_&_nuclear', avg(r.[Values]) as 'kWh_production_of_electricity_by_renewable'
from production_by_oil as o
join production_by_nuclear as n
on o.Country_Code=n.Country_Code and o.[Year] = n.[Year]
join production_by_renewable as r
on n.Country_Code=r.country_code and n.[Year] = r.[Year]
group by cast(concat('01-01-',cast(o.[Year] as nvarchar)) as date)
order by cast(concat('01-01-',cast(o.[Year] as nvarchar))as date);