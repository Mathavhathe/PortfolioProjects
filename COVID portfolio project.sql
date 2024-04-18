select * 
from PortfolioProject..CovidDeaths
where continent is not null   --to remove places where location is also the continent.
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases Vs Total Deaths (what percentage of reported cases resulted in deaths)
-- shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total cases Vs Population 
-- Shows what percentage of population got Covid
select location, date, total_cases,population,  total_deaths, (total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
--where location like '%Africa%'
order by 1,2

-- Looking at countries with highest Infection Rates compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc

-- Showing countries with the highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Breaking things up by Continents
-- Showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers
-- this is per day
select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- remove dates to see overall without the dates
select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- LOOKING AT THE VACCINATION Table and joining it with the deaths table
select  *
from PortfolioProject..CovidDeaths dea   --(naming them dea and vac)
join PortfolioProject..CovidVaccinations vac 
-- joining them in with respect to date and location. 
on dea.location = vac.location
and dea.date    = vac.date


-- Looking at Total population Vs Vaccinations

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100 (cannot use this name within this query, create CTE or Temp table)
from PortfolioProject..CovidDeaths dea  
join PortfolioProject..CovidVaccinations vac 
-- joining them in with respect to date and location. 
on dea.location = vac.location
and dea.date    = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) --PopVsVac : population Vs vaccination
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea  
join PortfolioProject..CovidVaccinations vac 
-- joining them in with respect to date and location. 
on dea.location = vac.location
and dea.date    = vac.date
where dea.continent is not null

)
select*, (RollingPeopleVaccinated/population)*100
from PopVsVac

-- Use Temp Table

DROP table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(-- specify columns of the table & data type
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea  
join PortfolioProject..CovidVaccinations vac 
-- joining them in with respect to date and location. 
on dea.location = vac.location
and dea.date    = vac.date

select*, (RollingPeopleVaccinated/population)*100
from  #PercentPopulationVaccinated


-- Create View for Visualisations


Create View PercentPopulationVaccinated as
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea  
join PortfolioProject..CovidVaccinations vac 
-- joining them in with respect to date and location. 
on dea.location = vac.location
and dea.date    = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated