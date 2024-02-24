select * 
from coviddeath
where continent is not null
order by 2,3,4

-- select *
-- from covidvaccination
-- order by 2,3,4
-- select the data that we going to be using
ALTER table coviddeath
rename column data to date;

SELECT continent,location,date,population,total_cases,new_cases,total_deaths
from coviddeath
where continent is not null
order by 1,2,3


-- alter column total_death varchar to double precision
ALTER TABLE coviddeath
ALTER COLUMN total_cases TYPE double precision
USING total_cases::double precision;

--total cases vs total death
-- showing liklihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage 
from coviddeath
where location like '%ndia%'
order by deathpercentage desc



-- change population data type varhcar to bigint
ALTER TABLE coviddeath
ALTER COLUMN population type decimal
USING population::decimal

--looking at toal_cases vs population
-- what percentage of population got covid
select location,population,date,total_cases,total_deaths,(total_cases/population)*100 as totalCasePerc 
from coviddeath
where location like  '%ndia%'
order by totalCasePerc asc

-- looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highest_infection_rate,max((total_cases/population))*100 as percentofPopulationInfected
from coviddeath
where continent is not null
group by location,population
order by percentofPopulationInfected desc

-- showing countries with highest death count for population

select location,population,max(total_deaths) as highest_death_count,max((total_deaths/population))*100 as percentofPopulationdeath
from coviddeath
where location = 'Bulgaria'
group by location,population
order by percentofPopulationdeath asc

-- showing countries with highest death count per population

select location, max(total_deaths) as totalt_death_count
from coviddeath
where continent is not null
group by location
order by totalt_death_count desc

-- let's break things done by continent

-- showing the continent with highest death count per population
select continent, max(total_deaths) as totalt_death_count
from coviddeath
where continent is not null
group by continent
order by totalt_death_count desc

-- total population vs vaccination

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date )as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from coviddeath as cd
inner join covidvaccination as cv
on cd.location = cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3


-- CTE

with covidvacVScovidpop(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date )as RollingPeopleVaccinated
from coviddeath as cd
inner join covidvaccination as cv
on cd.location = cv.location and cd.date=cv.date
where cd.continent is not null

)
select *,(RollingPeopleVaccinated/population)*100 as peopleVaccinatedPercentage
from covidvacVScovidpop;


-- TEMP TABLE

CREATE TEMP TABLE percentpopulationvaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO percentpopulationvaccinated
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM 
    coviddeath AS cd
INNER JOIN 
    covidvaccination AS cv ON cd.location = cv.location AND cd.date = cv.date
WHERE 
    cd.continent IS NOT NULL;

SELECT 
    *,
    (RollingPeopleVaccinated / population) * 100 AS peopleVaccinatedPercentage
FROM 
    percentpopulationvaccinated;
	
-- creating view to store data for later visualization

create view percentpopulationvaccinated as
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM 
    coviddeath AS cd
INNER JOIN 
    covidvaccination AS cv ON cd.location = cv.location AND cd.date = cv.date
WHERE 
    cd.continent IS NOT NULL;





