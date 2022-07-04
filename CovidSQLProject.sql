--SPECIFY DESIRED DATA

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.dbo.CovidDeaths
ORDER BY 1,2


--TOTAL CASES VS TOTAL DEATHS IN SOUTH AFRICA = PERCENTAGE CHANCE OF DYING IF HAVING COVID

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS Death_Percentage
FROM CovidProject.dbo.CovidDeaths
WHERE location = 'South Africa'
ORDER BY 1,2


--TOTAL CASES VS POPULATION IN SOUTH AFRICA = PERCENTAGE OF POPULATION HAVING COVID

SELECT location, date, total_cases, population, (total_cases / population)*100 AS Percent_of_Population_Having_Covid
FROM CovidProject.dbo.CovidDeaths
WHERE location = 'South Africa'
ORDER BY 1,2


--HIGHEST INFECTION RATE VS POPULATION PER COUNTRY

SELECT location, MAX(total_cases) AS Highest_Count, population, MAX(total_cases / population)*100 AS Highest_Infection_Rate
FROM CovidProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY Highest_Infection_Rate DESC


--COUNTRIES WITH HIGHEST DEATH COUNT / POPULATION

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
-- GROUP BY continent (TO GET JUST THE CONTINENTS)
ORDER BY Total_Death_Count desc


--GLOBAL STATISTICS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(New_Cases)*100 AS Death_Percentage
FROM CovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--TOTAL POPULATION VS VACCINATION (USE JOINS, CONVERT, PARTITION BY, OVER)

SELECT deaths.location, deaths.continent, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(int,vacs.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.Date) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths deaths
JOIN CovidProject.dbo.CovidVaccinations vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL
ORDER BY 1,2


--USE PREVIOUS QUERY TO PERFORM CALCULATIONS 

WITH PopvsVac (Location, continent, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS (
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(int,vacs.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.Date) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths deaths
JOIN CovidProject.dbo.CovidVaccinations vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL

)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Population_Percent_Vaccinated
From PopvsVac


--CREATE A TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(int,vacs.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.Date) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths deaths
JOIN CovidProject.dbo.CovidVaccinations vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--CREATE VIEW

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.location, deaths.continent, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(int,vacs.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.Date) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths deaths
JOIN CovidProject.dbo.CovidVaccinations vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated