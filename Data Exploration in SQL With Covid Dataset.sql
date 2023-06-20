Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeath
Order by 1,2;

Select total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeath
where total_cases is not null and total_deaths is not null
Order by 1,2;

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

-- deathpercentage
Select location , total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as Deathpercentange
From Portfolio..CovidDeath
where location like '%states' and total_cases is not null and total_deaths is not null
Order by 1,2;

--gotcovidpercentage in States
Select location , total_cases, new_cases, total_deaths, population, (total_cases/population)*100 as gotcovidpercentange
From Portfolio..CovidDeath
where location like '%states' and total_cases is not null and total_deaths is not null
Order by 1,2;

-- coutris with highest infection rate
Select location, population, max(total_cases) as HighestInfection, max((total_cases/population)*100) as HighestInfectionPercentage
From Portfolio..CovidDeath
group by location, population
Order by HighestInfectionPercentage desc;

-- coutris with total death
Select location, max(total_deaths) as TotalDeathCount
From Portfolio..CovidDeath
Where continent is not null 
group by location
Order by TotalDeathCount desc;

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
-- order by 2,3 
) select *, (RollingPeopleVaccinated/Population)*100
from Popvsvac 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..CovidDeath dea
join Portfolio..CovidVacination vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated