use Portfolio
go
SELECT C.NAME AS COLUMN_NAME,
       TYPE_NAME(C.USER_TYPE_ID) AS DATA_TYPE,
       C.IS_NULLABLE,
       C.MAX_LENGTH,
       C.PRECISION,
       C.SCALE
FROM SYS.COLUMNS C
JOIN SYS.TYPES T
     ON C.USER_TYPE_ID=T.USER_TYPE_ID
WHERE C.OBJECT_ID=OBJECT_ID('CovidVacination');

ALTER TABLE CovidDeath ALTER COLUMN total_cases float;
ALTER TABLE CovidDeath ALTER COLUMN total_deaths float;

select *
from Portfolio..CovidDeath

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeath
Order by 1,2;

--looking at total cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From Portfolio..CovidDeath
where total_cases is not null and total_deaths is not null
Order by 1,2 ;

-- looking at Total cases vs Population
-- show what percentage of population got covid
Select location, date, population, total_cases, (total_deaths/population) * 100 as PercentPopulationInfected
From Portfolio..CovidDeath
where total_cases is not null and total_deaths is not null
Order by 1,2 ;

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as highestInFectionCount, MAX(total_deaths), max((total_deaths/population)) * 100 as PercentPopulationInfected
From Portfolio..CovidDeath
Group by location, population
Order by 1,2 ;

select *
from Portfolio..CovidDeath
where continent is not null

-- Coutris with Higheest death
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeath
Where continent is not null 
group by location
Order by TotalDeathCount desc;

-- Break things down by continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeath
Where continent is null 
group by continent
Order by TotalDeathCount desc;

-- Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeath
Where continent is not null 
group by continent
Order by TotalDeathCount desc;

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From Portfolio..CovidDeath
Having SUM(new_cases) <> 0;

--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From Portfolio..CovidDeath
Where continent is not null
group by date
Having SUM(new_cases) <> 0
Order by 2 desc;

-- Vacination
Select*
from Portfolio..CovidVacination

--Join table

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio..CovidDeath dea
join Portfolio..CovidVacination vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

ALTER TABLE CovidVacination ALTER COLUMN new_vaccinations int;

-- Looking at Total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeath dea
join Portfolio..CovidVacination vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

With Popvsvac (Continent, location, date, Population, New_vaccination, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeath dea
join Portfolio..CovidVacination vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
) select *, (RollingPeopleVaccinated/Population)*100
from Popvsvac 

Drop Table if exists PercentPopulationVaccinated
-- Create Table
use Portfolio
go
Create Table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeath dea
join Portfolio..CovidVacination vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated

-- Create veiw
DROP VIEW [VPercentPopulationVaccinated]

use Portfolio
go
Create View VPercentPopulationVaccinated 
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeath dea
join Portfolio..CovidVacination vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null)

select *, (RollingPeopleVaccinated/Population)*100
from VPercentPopulationVaccinated
