select * from covid_data;

-- INDIA
-- Daily trend of new COVID-19 cases, deaths, and vaccinations in India.
select location, date, new_cases, new_deaths, new_vaccinations
from covid_data where location like '%india%';

-- Monthly trend of new COVID-19 cases, deaths, and vaccinations in India.
select location, Year(date) as Year, month(date) as Month, sum(new_cases), sum(new_deaths), sum(new_vaccinations)
from covid_data where location like '%india%' group by location, Year(date), month(date);

-- with this query we can find the trend of Cases, Deaths, and Vaccination in India

-- --------------------------------------- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Average Cases in India by Daily bases
select location, Year(date) as Year, month(date) as Month, round(avg(new_cases)) as Average_Cases, round(avg(new_deaths)) as Average_Deaths, 
round(avg(new_vaccinations)) as Average_vaccination 
from covid_data where location = "india" group by location, Year(date), month(date);

-------------------------------------------------------------------------------------------------------------
-- Trends evolved over time since the beginning of the pandemic. 
select location, max(population) as Population, sum(new_cases) as Total_cases , sum(new_deaths) as Total_deaths,
max(total_vaccinations) as Total_vaccinations
from covid_data where location like '%india%' group by location; 

-- with this query we can identitify the Total cases, Total deaths, Total vaccinations in India

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Comparing Total Deaths over Total Cases.
select location, year(date) as Year, month(date) as Month, sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as Death_Percentage
from covid_deaths where location like "%india%" group by location, year, month order by Death_Percentage desc;
 
-- with this query we can identitfy the percentage of people died who as been infected
-- we can see that which month of year had highest death percentage

select location, max(total_cases) as Total_cases, max(total_deaths) as Total_deaths, (max(total_deaths)/max(total_cases))*100 as Death_percentage
from covid_deaths where location like "%india%" group by location;

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Comparing Total Cases over Population.
select location, year(date) as Year, month(date) as Month, max(population) as Population, sum(new_cases) as Total_Cases, 
(sum(new_cases)/max(population))*100 as Infected_percentage
from covid_data where location = 'india' group by year(date), month(date) order by Infected_percentage desc;

-- This Query gives the Percentage of People infected with Poplulation on monthly bases
-- we can see that which month of year had highest death percentage

select location, max(population) as Population, max(total_cases) as Total_Cases, (max(total_cases)/max(population))*100 as Infected_Percentage
from covid_deaths where location like "india" group by location;  

-- This Query gives the Percentage of People infected with Poplulation during the pandemic 

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Comparing Global trends with India's trend over COVID-19 cases, deaths, and vaccinations
with global_trend as( 
select year(date) as Year,month(date) as Month, sum(new_cases) as global_new_cases, sum(new_deaths) as global_new_deaths, 
sum(new_vaccinations) as global_new_vaccinations
from covid_data group by year(date), month(date) order by year(date),month(date)),
india_trend as(
select year(date) as year,month(date) as month, sum(new_cases) as india_new_cases, sum(new_deaths) as india_new_deaths, 
sum(new_vaccinations) as india_new_vaccinations
from covid_data where location = 'India'
group by year(date), month(date) order by year(date),month(date))

select global_trend.year, global_trend.month, global_new_cases, india_new_cases,
(india_new_cases/global_new_cases)*100 as percentage_share_of_global_cases,
global_new_deaths, india_new_deaths,(india_new_deaths/global_new_deaths)*100 as percentage_share_of_global_deaths,
global_new_vaccinations, india_new_vaccinations, (india_new_vaccinations/global_new_vaccinations)*100 as percentage_share_of_global_vaccinations
from global_trend join india_trend on global_trend.year = india_trend.year and global_trend.month = india_trend.month;

-- with this query we identify the percentage of share of cases, deaths, vaccination of India with the global impact

-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- Creating a view to store data for later visualization
create view country_table as 
select location, date, population, new_cases, new_deaths, new_vaccinations from covid_data;

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL
-- Countries with highest total_cases
select row_number() over(order by sum(new_cases) desc) as 'rank', location, population, sum(new_cases) as Total_cases,
(sum(new_cases)/population)*100 as Infected_percentage
from covid_data where continent is not null group by location, population order by Total_cases desc;
-- we use continent is not null to exclude continent from the location column

-- This query gives us the countries with highest total cases 

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with highest death_count
select row_number() over(order by sum(new_deaths) desc) as 'rank', location, population, sum(new_cases) as Total_cases, 
sum(new_deaths) as Total_deaths, (sum(new_deaths)/population)*100 as Death_percentage
from covid_data where continent is not null group by location, population order by total_deaths desc;

-- This query gives us the countries with highest total deaths

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- Continent with Highest Infected rate & Death rate
select row_number() over(order by (sum(new_cases)/max(population))*100 desc) as 'rank', continent, max(population) as Population, 
sum(new_cases) as Total_cases, (sum(new_cases)/max(population))*100 as Infected_Percentage,
sum(new_deaths) as Total_deaths, (sum(new_deaths)/max(population))*100 as Death_Percentage 
from covid_data where continent is not null group by continent order by Infected_Percentage desc;

-- This query gives us the continent with highest infected rate

-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- countries with highest ICU admission rate
select location, sum(hosp_patients) AS total_hospitalizations, sum(icu_patients) AS total_icu_admissions,
(sum(icu_patients)/sum(hosp_patients))*100 as Percentage_of_people
from covid_data	 where continent is not null  group by location  order by Percentage_of_people desc;

-- this query gives us the percentage of people admitted in ICU who has bee hospitalized

-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with Higher Population Density
select row_number() over(order by avg(population_density) desc) as `Rank` ,location, cast(avg(population_density)as signed) AS Population_Density 
from covid_data where continent is not null group by location order by Population_Density desc; 


-- By examining population density, we can infer the rate at which the virus spreads, 
-- as higher population density often correlates with a faster spread of the virus.

-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with Higher Gross Domestic Product (GDP) 
select row_number() over(order by avg(gdp_per_capita) desc) as `Rank` ,location, cast(avg(gdp_per_capita) as SIGNED) AS GDP 
from covid_data where continent is not null group by location order by GDP desc; 

-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with Higher Life Expectancy
select row_number() over(order by avg(life_expectancy) desc) as `Rank`, location, avg(life_expectancy) as life_expectancy
from covid_data where continent is not null group by location order by life_expectancy desc;

-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with Higher Life Expectancy
select row_number() over(order by avg(human_development_index) desc) as `Rank`, location, avg(human_development_index) as human_development_index
from covid_data where continent is not null group by location order by human_development_index desc;