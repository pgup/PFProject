Select *
From PortfolioProject..CovidDeath
order by 3,4

 
--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
order by 1,2

-- total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where location like '%states%'
order by 1,2

--looking at total cases vs population


Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
Where location like '%states%'
order by 1,2

--Looking at countries with highest infection Rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
Group by location, population
order by PercentPopulationInfected desc


Select location, population, date, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
Group by location, population, date
order by PercentPopulationInfected desc


--showing countries with highest death count per population (descending by percent of population)

Select location, population, MAX(cast(total_deaths as int)) as Highestdeath , MAX((cast(total_deaths as int)/population))*100 as PercentPopulationdead
From PortfolioProject..CovidDeath
Group by location, population
order by PercentPopulationdead desc




--showing countries with highest death Count per population (descending highest death rate)
Select location, population, MAX(cast(total_deaths as int)) as Highestdeath , MAX((cast(total_deaths as int)/population))*100 as PercentPopulationdead
From PortfolioProject..CovidDeath
Group by location, population
order by Highestdeath desc


--showing continents with the highest death count per population


-- by Continent 
Select continent, MAX(cast(total_deaths as int)) as Highestdeath , MAX((cast(total_deaths as int)/population))*100 as PercentPopulationdead
From PortfolioProject..CovidDeath
where continent is not null
Group by continent
order by Highestdeath desc


--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2
 

--over all ... across the world
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast
(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null
order by 1,2



-- take world, European and international out also continent is null
-- location, total death count

Select location, SUM(cast(new_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeath
where continent is null 
and location not in ('World','European Union','International')
Group by location
order by TotalDeath desc



-- total population vs vaccination
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingpeopleVaccinated

from PortfolioProject..CovidDeath  dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
 
	   
--total popluation vs vacination

with PopvsVac (continent, location, date, population, new_vaccinations, RollingpeopleVaccinated) 
as
( ---CAST(vac.new_vaccinations as BIGINT))
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingpeopleVaccinated

from PortfolioProject..CovidDeath  dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingpeopleVaccinated/population)*100  from PopvsVac


-- temporary table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

