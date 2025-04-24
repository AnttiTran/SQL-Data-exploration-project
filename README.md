
#  COVID-19 Data Exploration with SQL

This project uses SQL to explore COVID-19 death and vaccination data. The goal is to examine trends in cases, deaths, and vaccinations over time and across countries using raw data from two tables: `CovidDeaths` and `CovidVaccination`.

All analysis was performed using Microsoft SQL Server.

---

##  Data Used
- **CovidDeaths**  
  Includes daily records of total cases, new cases, total deaths, population, etc.
- **CovidVaccination**  
  Contains vaccination-related metrics such as new vaccinations per day.


##  Queries and Transformations Performed

###  Initial Filtering
- Removed entries with null `continent` values to focus on country-level data.

```sql
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4
```

---

###  Selected Relevant Columns

```sql
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2
```

---

###  Total Cases vs. Total Deaths

Calculated death percentage by country:

```sql
SELECT location, date, total_cases, total_deaths, 
       (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%finland%'
ORDER BY 1,2
```

---

###  Total Cases vs. Population

```sql
SELECT location, date, population, total_cases, 
       (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%finland%'
ORDER BY 1,2
```

---

###  Highest Infection Rate by Country

```sql
SELECT location, population, 
       MAX(total_cases) AS HighestInfectionCount, 
       MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
```

---

###  Death Counts by Continent and Country

Countries/continents with the highest total death counts:

```sql
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
```

```sql
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
```

---

###  Global Totals

```sql
SELECT  
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE SUM(CAST(new_deaths AS INT)) * 100.0 / NULLIF(SUM(new_cases), 0) 
    END AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
```

---

###  Joining Deaths and Vaccinations Tables

```sql
SELECT *
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
  ON dea.location = vac.location 
 AND dea.date = vac.date
```

---

###  Total Vaccinations per Country Over Time

```sql
SELECT dea.continent, dea.location, dea.date, dea.population, 
       vac.new_vaccinations, 
       SUM(COALESCE(CONVERT(BIGINT, vac.new_vaccinations), 0)) 
       OVER (PARTITION BY dea.location, dea.date) AS total_vaccinations
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
  ON dea.location = vac.location 
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
```

---

###  Using CTE for Population vs. Vaccination

```sql
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, total_vaccinations) AS (
    ...
)
SELECT *, (total_vaccinations/population)*100
FROM PopvsVac
```

---

###  Using Temporary Table

```sql
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated (...);

INSERT INTO #PercentPopulationVaccinated
SELECT ...

SELECT *, (total_vaccinations/population)*100
FROM #PercentPopulationVaccinated;
```

---

###  Creating a View

```sql
CREATE VIEW PercentPopulationVaccinated AS
SELECT ...
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
  ON dea.location = vac.location 
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
```

---

##  Tools Used

- Microsoft SQL Server
- Excel

