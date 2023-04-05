-- QUERIES USED IN TABLEAU PROJECT

-- 1.

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths$
-- where location like '%states%'
-- where location like 'India'
where continent is not null
--GROUP BY date
ORDER BY 1,2

-- Double checking based on the data provided
-- The below query contains "International" in location, the numbers are pretty close 

/*SELECT SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths$
-- where location like '%states%'
-- where location like 'India'
where location = 'World'
--GROUP BY date
ORDER BY 1, 2
*/


--2.
-- Taking out World, International and European Union from the location as they aren't included in the first query.

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths$
-- where location like '%states%'
-- where location like 'India'
WHERE continent is null
and location not in ('World', 'International', 'European Union')
GROUP BY location
ORDER BY TotalDeathCount desc


--3.

SELECT location, Population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths$
--where location like '%states%'
--where location like 'India'
GROUP BY location, Population
ORDER BY PercentPopulationInfected desc


--4.

SELECT location, Population, date, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths$
--where location like '%states%'
--where location like 'India'
GROUP BY location, Population, Date
ORDER BY PercentPopulationInfected desc


--5.

SELECT dea.continent, dea.location, dea.date, dea.population,
MAX(vac.new_vaccinations) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM ProjectPortfolio..CovidDeaths$ dea
JOIN ProjectPortfolio..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3


--6. 
-- Using CTE, WINDOWS FUNCTION to perform aggregate func on new_vaccinations partitioned by location


WITH PopvsVac ( Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER ( PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM ProjectPortfolio..CovidDeaths$ dea
JOIN ProjectPortfolio..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
FROM PopvsVac