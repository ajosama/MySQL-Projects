/*USE master;
GO
ALTER DATABASE abudb MODIFY NAME = SSMSP;*/

--SELECT * FROM SSMSP..coviddeaths;
--SELECT * FROM SSMSP..CovidVaccination;
--select COUNT(iso_code) from dbo.coviddeaths;
--select COUNT(iso_code) from dbo.CovidVaccination;

---------------- select data that we are going to be using ----------------

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM dbo.coviddeaths
WHERE continent is NOT NULL
ORDER BY 1,2;

---------------- Looking at Total Cases vs Total Deaths ----------------

SELECT location,date,total_cases,total_deaths,(total_deaths*total_cases)*100 AS DeathPercentage
FROM dbo.coviddeaths
WHERE continent is NOT NULL
ORDER BY 1,2;
--------------------------------------------------------------------------------
/*Msg 8117, Level 16, State 1, Line 17
Operand data type nvarchar is invalid for multiply operator.*/

---------------- change the datatype ----------------

ALTER TABLE dbo.coviddeaths
ALTER COLUMN total_deaths numeric;

ALTER TABLE dbo.coviddeaths
ALTER COLUMN total_cases numeric;

---------------- SHOWS Likelihood of dying ----------------

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases) AS DeathPercentage
FROM dbo.coviddeaths
WHERE continent is NOT NULL
ORDER BY 1,2;

---------------- Looking at Total cases vs population ----------------
---------------- Shows what percentage of population got affected in INDIA ----------------

SELECT location,date,total_cases,population,(total_cases/population)*100 AS CasePercentage
FROM dbo.coviddeaths
WHERE location like '%india' AND continent is NOT NULL
ORDER BY 1,2;

---------------- Looking at Countries with highest infection rate compared to population ----------------

SELECT location,MAX(total_cases) AS HighestInfectionCount,population,MAX((total_cases/population)*100) AS PopulationInfectedPercentage
FROM dbo.coviddeaths
WHERE continent is NOT NULL
GROUP BY location,population
--WHERE location like '%india'
ORDER BY PopulationInfectedPercentage desc;

---------------- Showing Countries with highest death count per population ----------------

SELECT location,MAX(total_deaths) AS HighestDeathCount
FROM dbo.coviddeaths
WHERE continent is NOT NULL
GROUP BY location
--WHERE location like '%india'
ORDER BY HighestDeathCount desc;

---------------- Showing Continent with highest death count per population ----------------

SELECT continent,MAX(total_deaths) AS HighestDeathCount
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount desc;

---------------- GLOBAL NUMBERS ----------------

SELECT date,SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,
CASE WHEN SUM(new_cases) = 0 THEN NULL
ELSE SUM(new_deaths)/NULLIF(SUM(new_cases),0) * 100 
END AS DeathPercentage
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

---------------- Looking at Total Population vs Vaccinations ----------------

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM dbo.coviddeaths dea
JOIN dbo.CovidVaccination vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

---------------- CTE ----------------

WITH Comp (continent,location,date,population,new_vaccinations,PeopleVaccinated)
AS(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM dbo.coviddeaths dea
JOIN dbo.CovidVaccination vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * ,(PeopleVaccinated/population) * 100 AS PeoVacPer FROM Comp

---------------- TEMP TABLE ----------------

CREATE TABLE #PerPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric
)
INSERT INTO #PerPopVac
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM dbo.coviddeaths dea
JOIN dbo.CovidVaccination vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM #PerPopVac

---------------- Creating views for a later Visualizations ----------------

CREATE VIEW PerPopVac2 AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM dbo.coviddeaths dea
JOIN dbo.CovidVaccination vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL