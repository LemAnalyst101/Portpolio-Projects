
SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%Philipp%'
Where continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases , (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
ORDER BY 1,2

--Looking at countries with highest infection rate compared to poplulation

SELECT Location, population, max(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, population
ORDER BY PercentPopulationInfected DESC

--Showing countries with Highest Death Count per Population

SELECT Location, MAX(convert(int, total_deaths)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count per population

SELECT continent, MAX(convert(int, total_deaths)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
group by date
ORDER BY 1,2

--ALL OVER ACROSS THE WORLD

SELECT SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
-- group by date
Where continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Total Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations\

CREATE VIEW PercentPopulationVaccinated AS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated