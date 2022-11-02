select *
from PortfolioProject..COVIDDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..COVIDVaccinations
--order by 3,4

--Select Data that we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..COVIDDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
--Shows chance of death by country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..COVIDDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of the population got COVID

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..COVIDDeaths
--where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..COVIDDeaths
--where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..COVIDDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- Breakdown by Continent

-- Showing continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..COVIDDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..COVIDDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPopulationVaccinated
, (RollingPeopleVaccinated/population)*100
from PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPopulationVaccinated/population)*100
from PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



-- TEMP TABLE

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

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated
