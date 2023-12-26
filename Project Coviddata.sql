SELECT *
FROM Portfolio..Coviddeaths
WHERE continent IS NOT NULL
order by 3,4 

SELECT *
FROM Portfolio..CovidVaccines$
order by 3,4 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..Coviddeaths
WHERE total_cases IS NOT NULL AND total_deaths IS NOT NULL
order by 1,2

--Looking at Total Cases Vs Total Deaths (Percentage of deaths)
--Shows likelihood of dying if you catch covid
SELECT Location, date, total_cases, total_deaths, (CONVERT(FLOAT,total_deaths) / CONVERT(FLOAT, total_cases)) * 100 AS DeathPercentage
FROM Portfolio..Coviddeaths
WHERE location like '%Pakistan%'
ORDER BY 1,2;

--Total Cases Vs Population
--Shows what Percentage of Population got Covid
SELECT Location, date, total_cases, Population, (total_cases/population) * 100 AS PopulationPercentage
FROM Portfolio..Coviddeaths
WHERE location like '%Pakistan%'
ORDER BY 1,2;

--Highest Infection rate by country compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS InfectionRate
FROM Portfolio..Coviddeaths
WHERE total_cases IS NOT NULL
GROUP BY Location,population
ORDER BY InfectionRate desc;

--Countries with highest death 
SELECT Location, MAX(CONVERT(INT, total_deaths)) AS HighestdeathCount
FROM Portfolio..Coviddeaths
WHERE continent IS NULL
GROUP BY Location
ORDER BY HighestdeathCount desc;


--Continent with highest deaths
SELECT continent, MAX(CONVERT(INT, total_deaths)) AS HighestdeathCount
FROM Portfolio..Coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestdeathCount desc;


--Global Numbers
SELECT date, SUM(new_cases) AS totalcases, SUM(CONVERT(bigint, new_deaths)) as totaldeaths, SUM(CONVERT(INT, new_deaths))/SUM(new_cases)*100 AS DeathPercentage --total_deaths, (CONVERT(FLOAT,total_deaths) / CONVERT(FLOAT, total_cases)) * 100 AS DeathPercentage
FROM Portfolio..Coviddeaths
WHERE continent is not null AND new_cases!=0
group by date
ORDER BY 1,2;

--Without date 
SELECT SUM(new_cases) AS totalcases, SUM(CONVERT(int, new_deaths)) as totaldeaths, SUM(CONVERT(INT, new_deaths))/SUM(new_cases)*100 AS DeathPercentage --total_deaths, (CONVERT(FLOAT,total_deaths) / CONVERT(FLOAT, total_cases)) * 100 AS DeathPercentage
FROM Portfolio..Coviddeaths
WHERE continent is not null AND new_cases!=0
ORDER BY 1,2;


--Total Population Vs Vaccinations 
--Number of people vaccinated in world
SELECT Coviddeaths.continent, Coviddeaths.location, Coviddeaths.date, Coviddeaths.population, CovidVaccines$.new_vaccinations
, SUM(CONVERT(INT,CovidVaccines$.new_vaccinations)) OVER (Partition by Coviddeaths.location Order by Coviddeaths.location, Coviddeaths.date) as RollingPeopleVaccinated
FROM Portfolio..Coviddeaths
JOIN Portfolio..CovidVaccines$
	ON Portfolio..Coviddeaths.location=Portfolio..CovidVaccines$.location
AND 
	   Portfolio..Coviddeaths.date=Portfolio..CovidVaccines$.date
WHERE Coviddeaths.continent is not null
order by 2,3 ;


--Using CTE
With PopVsVac (Continent,Location,date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
SELECT Coviddeaths.continent, Coviddeaths.location, Coviddeaths.date, Coviddeaths.population, CovidVaccines$.new_vaccinations
, SUM(CONVERT(INT,CovidVaccines$.new_vaccinations)) OVER (Partition by Coviddeaths.location Order by Coviddeaths.location, Coviddeaths.date) as RollingPeopleVaccinated
FROM Portfolio..Coviddeaths
JOIN Portfolio..CovidVaccines$
	ON Portfolio..Coviddeaths.location=Portfolio..CovidVaccines$.location
AND 
	   Portfolio..Coviddeaths.date=Portfolio..CovidVaccines$.date
WHERE Coviddeaths.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinatedPercentage
From PopVsVac

--TEMP TABLE
DROP TABLE IF exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations bigint,
RollingPeopleVaccinated bigint
)

Insert into PercentPopulationVaccinated 
SELECT Coviddeaths.continent, Coviddeaths.location, Coviddeaths.date, Coviddeaths.population, CovidVaccines$.new_vaccinations
, SUM(CONVERT(bigint,CovidVaccines$.new_vaccinations)) OVER (Partition by Coviddeaths.location Order by Coviddeaths.location, Coviddeaths.date) as RollingPeopleVaccinated
FROM Portfolio..Coviddeaths
JOIN Portfolio..CovidVaccines$
	ON Portfolio..Coviddeaths.location=Portfolio..CovidVaccines$.location
AND 
	   Portfolio..Coviddeaths.date=Portfolio..CovidVaccines$.date
--WHERE Coviddeaths.continent is not null
--order by 2,3 ;
SELECT *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinatedPercentage
From PercentPopulationVaccinated

--Creating View for Continent deaths
CREATE VIEW HighestdeathContinents AS
SELECT continent, MAX(CONVERT(INT, total_deaths)) AS HighestdeathCount
FROM Portfolio..Coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent;

SELECT * FROM HighestdeathContinents ORDER BY HighestdeathCount desc;

CREATE VIEW PercentPopulationsVaccinated AS
SELECT Coviddeaths.continent, Coviddeaths.location, Coviddeaths.date, Coviddeaths.population, CovidVaccines$.new_vaccinations
, SUM(CONVERT(bigint,CovidVaccines$.new_vaccinations)) OVER (Partition by Coviddeaths.location Order by Coviddeaths.location, Coviddeaths.date) as RollingPeopleVaccinated
FROM Portfolio..Coviddeaths
JOIN Portfolio..CovidVaccines$
	ON Portfolio..Coviddeaths.location=Portfolio..CovidVaccines$.location
AND 
	   Portfolio..Coviddeaths.date=Portfolio..CovidVaccines$.date

SELECT * FROM PercentPopulationsVaccinated ORDER BY 2,3;