
SELECT*
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccination
--order by 3,4

--SELECT DATA that we are going to be using

SELECT Location, date, total_cases, new_cases,total_deaths,population 
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%finland%'
order by 1,2

--Looking at Total Cases vs Population 

SELECT Location, date, population, total_cases,population,(total_cases/population)*100 as Deathpercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%finland%'
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population 


SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
---where location like '%finland%'
Group by Location,population
Order by PercentPopulationInfected desc

--Let's break things down by continent 
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is null
Group by location
Order by TotalDeathCount desc


---Showing Countries with Highest Death Count per Population 

SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is null
Group by Location
Order by TotalDeathCount desc


--Showing continents with the highest death count per population 

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

---Global Numbers

SELECT  
    SUM(new_cases) as total_cases, 
    SUM(CAST(new_deaths AS int)) as total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 
        ELSE SUM(CAST(new_deaths AS int)) * 100.0 / NULLIF(SUM(new_cases), 0) 
    END as deathpercentage
FROM 
    PortfolioProject.dbo.CovidDeaths
---GROUP BY date
ORDER BY 1,2

--Looking at Table of CovidVaccination

SELECT *
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccination vac
On dea.location = vac.location 
and dea.date= vac.date


--Looking at Total Population vs Vaccination
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(COALESCE(CONVERT(bigint, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location, dea.date) AS total_vaccinations
FROM 
    PortfolioProject.dbo.CovidDeaths dea
JOIN 
    PortfolioProject.dbo.CovidVaccination vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE 
    dea.continent is not NULL
ORDER BY 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, total_vaccinations )
as (

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(COALESCE(CONVERT(bigint, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location, dea.date) AS total_vaccinations
FROM 
    PortfolioProject.dbo.CovidDeaths dea
JOIN 
    PortfolioProject.dbo.CovidVaccination vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE 
    dea.continent is not NULL
---ORDER BY 2,3
)

SELECT *, (total_vaccinations/population)*100
From PopvsVac

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255), 
    Location NVARCHAR(255), 
    Date DATETIME, 
    Population NUMERIC, 
    New_vaccinations NUMERIC, 
    total_vaccinations NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(COALESCE(CONVERT(bigint, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
FROM 
    PortfolioProject.dbo.CovidDeaths dea
JOIN 
    PortfolioProject.dbo.CovidVaccination vac
    ON dea.location = vac.location 
    AND dea.date = vac.date;
 --WHERE dea.continent is not NULL
---ORDER BY 2,3   
SELECT *, (total_vaccinations/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualization 

Create View PercentPopulationVaccinated as

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(COALESCE(CONVERT(bigint, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
FROM 
    PortfolioProject.dbo.CovidDeaths dea
JOIN 
    PortfolioProject.dbo.CovidVaccination vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
 WHERE dea.continent is not null
--ORDER BY 2,3   

-- View Temporary Worktable
SELECT *
FROM #PercentPopulationVaccinated;
