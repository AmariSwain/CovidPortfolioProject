/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT * 
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

--SELECT * 
--FROM PortfolioProject1..CovidVaccinations
--ORDER BY 3,4;

-- Selecting data I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2;

--Total Cases vs Total Deaths
--Allows us to see the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2;

--Total Cases vs Total Deaths US

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%United States%'
and continent is not null
ORDER BY 1,2;

--Total Cases vs Population
--Displays the percentage of the population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population) * 100 as PopulationInfectedPercentage
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2;

--Total Cases vs Population US

SELECT location, date, population, total_cases, (total_cases/population) * 100 as USPopulationInfectedPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%United States%'
and continent is not null
ORDER BY 1,2;

--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as HighestPopulationInfectedPercentage
FROM PortfolioProject1..CovidDeaths
GROUP BY location, population
ORDER BY HighestPopulationInfectedPercentage desc;

--Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

--Highest Death Count by Continent

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

--Global Numbers Grouped by date

SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%United States%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%United States%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

-- Total Population vs Vaccinations
--Displays Percentage of Population that has recieved atleast one COVID vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

--CTE to perform calculation on partition by in previous query

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVacinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;

--Temp Table to perform calculation on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVacinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;

--VIEWS SECTION
--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVacinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

--DeathCount View

CREATE VIEW DeathCountByContinent as
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY continent
--ORDER BY TotalDeathCount desc;

SELECT * 
FROM DeathCountByContinent

--Death Percentage US view

CREATE VIEW DeathPercentageUS as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%United States%'
and continent is not null
--ORDER BY 1,2;

SELECT *
FROM DeathPercentageUS

