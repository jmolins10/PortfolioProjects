SELECT *
FROM PortfolioProject..CovidDeaths

--Select Data that I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Looking at total cases v. total deaths
--New column shows how likely you are to die if you contract covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE total_cases <> 0 AND location LIKE '%states%'
ORDER BY 1,2;

--Looking at Total case v. Population
--New column shows what % of population has covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS contraction_percentage
FROM PortfolioProject..CovidDeaths
WHERE population <> 0 AND location LIKE '%states%'
ORDER BY 1,2;

--List of countries with the highest infenction rates compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percentage_infected
FROM PortfolioProject..CovidDeaths
WHERE population <> 0
GROUP BY location, population
ORDER BY percentage_infected DESC;

--Show the countries with the highest death percentages

SELECT location, MAX(total_deaths) AS total_death_count 
FROM PortfolioProject..CovidDeaths
WHERE continent NOT LIKE ''
GROUP BY location
ORDER BY total_death_count DESC;

	-- WHAT ABOUT BY CONTINENT IN DEATHS?

	SELECT location, MAX(total_deaths) AS total_death_count 
	FROM PortfolioProject..CovidDeaths
	WHERE continent LIKE ''
	GROUP BY location
	ORDER BY total_death_count DESC;

-- GLOBAL NUMBERS

--Totals

SELECT SUM(new_cases) AS global_cases, SUM(new_deaths) AS global_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE new_cases <> 0 AND continent IS NOT NULL
ORDER BY 1,2;

--Connecting our 2 tables

-- Total poulation v. Total vaccination

SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	   SUM(new_vaccinations) OVER (PARTITION BY dth.location ORDER BY dth.date, dth.date) AS rolling_ppl_vac,
	   (rolling_ppl_vac/population)*100

FROM PortfolioProject..CovidDeaths AS dth
	JOIN PortfolioProject..CovidVaccinations AS vac
	ON dth.location = vac.location 
	AND dth.date = vac.date
WHERE dth.continent NOT LIKE ''
ORDER BY 2,3;

--Using a CTE (Common Table Expression), to pull up rolling percentage of vaccination v. population 

WITH PopVsVac (continent, location, date, population, new_vaccinations, rolling_ppl_vac)
AS ( SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	   SUM(new_vaccinations) OVER (PARTITION BY dth.location ORDER BY dth.date, dth.date) AS rolling_ppl_vac
	 FROM PortfolioProject..CovidDeaths AS dth
		JOIN PortfolioProject..CovidVaccinations AS vac
		ON dth.location = vac.location 
		AND dth.date = vac.date
	 WHERE dth.continent NOT LIKE '')
SELECT *, (rolling_ppl_vac/population)*100 AS percentage_vac_pop
FROM PopVsVac
WHERE population <> 0
ORDER BY 2,3;

--Can also use TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( continent varchar(50),
  location varchar(50),
  date date,
  population float,
  new_vaccinations float,
  rolling_ppl_vac float
)

INSERT INTO #PercentPopulationVaccinated
	SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
		   SUM(new_vaccinations) OVER (PARTITION BY dth.location ORDER BY dth.date, dth.date) AS rolling_ppl_vac
	FROM PortfolioProject..CovidDeathss AS dth
		JOIN PortfolioProject..CovidVaccinations AS vac
		ON dth.location = vac.location 
		AND dth.date = vac.date
	WHERE dth.continent NOT LIKE ''

SELECT *, (rolling_ppl_vac/population)*100 AS percentage_vac_pop
FROM #PercentPopulationVaccinated
WHERE population <> 0
ORDER BY 2,3;

--Creating a view to store data for viz

CREATE VIEW PercentPopulationVaccinated AS
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	   SUM(new_vaccinations) OVER (PARTITION BY dth.location ORDER BY dth.date, dth.date) AS rolling_ppl_vac
FROM PortfolioProject..CovidDeaths AS dth
	JOIN PortfolioProject..CovidVaccinations AS vac
	ON dth.location = vac.location 
	AND dth.date = vac.date
WHERE dth.continent NOT LIKE ''

-- QUERIES FOR VISUALIZATION

SELECT SUM(new_cases) AS global_cases, SUM(new_deaths) AS global_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE new_cases <> 0 AND continent NOT LIKE ''
ORDER BY 1,2;

Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent LIKE '' AND location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE population <> 0
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE population <> 0
Group by Location, Population, date
order by PercentPopulationInfected desc
