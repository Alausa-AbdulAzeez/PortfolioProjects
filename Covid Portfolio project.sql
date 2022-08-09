/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortProject..CovidDeaths$
WHERE location = 'Nigeria'
AND continent IS NOT NULL
ORDER BY 1,2



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location,date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortProject..CovidDeaths$
GROUP BY location,population
ORDER BY 4 DESC



-- Countries with Highest Death Count per Population

SELECT location ,MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Showing contintents with the highest death count 

SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.location,dea.date,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM PortProject..CovidDeaths$ dea
JOIN PortProject..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as PeopleVaccinated
FROM PortProject..CovidDeaths$ dea
JOIN PortProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

)
SELECT *, (PeopleVaccinated/Population)*100
FROM PopvsVac
ORDER BY location, date


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as PeopleVaccinated

FROM PortProject..CovidDeaths$ dea
JOIN PortProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL





