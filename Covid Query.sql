SELECT *
FROM PortfolioProject ..CovidDeaths
Where continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject ..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM PortfolioProject ..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS 'Death%'
FROM PortfolioProject ..CovidDeaths
Where location like 'United%'
ORDER BY 1,2


-- Total Cases Vs Population 
-- Shows percentage of population who got Covid
SELECT location, date, population ,total_cases, (total_cases/population) * 100 AS 'Infected Population'
FROM PortfolioProject ..CovidDeaths
-- Where location like 'United%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population 
SELECT location, population, max(total_cases) AS 'Highest Infection Count', Max((total_cases/population)) * 100 AS 'Infected Population'
FROM PortfolioProject ..CovidDeaths
Group By location, population
ORDER BY [Infected Population] DESC 

-- Countries with Highest death count to population 
SELECT location, MAX(cast(total_deaths AS int)) AS "Total Death Count"
FROM PortfolioProject ..CovidDeaths
Where continent IS NOT NULL 
Group By location
ORDER BY [Total Death Count] DESC 
 

-- Continet with highest death count to population 
SELECT continent, MAX(cast(total_deaths AS int)) AS "Total Death Count"
FROM PortfolioProject ..CovidDeaths
Where continent IS NOT NULL 
Group By continent
ORDER BY [Total Death Count] DESC 

-- Global Statistics
SELECT Sum(new_cases) AS 'Total Cases', sum(cast(new_deaths AS int)) AS 'Total Deaths', sum(cast(new_deaths AS int))/SUM(new_cases) * 100  AS 'Death Percentage' 
FROM PortfolioProject ..CovidDeaths
Where continent IS NOT NULL
--Group By date
ORDER BY 1,2

-- Total Population Against vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) AS 'Rolling People Vaccinated'
--(Rolling People Vaccinated/ population) * 100 
FROM PortfolioProject ..CovidDeaths dea
JOIN PortfolioProject ..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER By 2,3

-- Create #Percent_Population_Vaccinated using CTE for Analysis
With PopvsVac ( Continent, Location, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) AS 'Rolling_People_Vaccinated'
--(Rolling People Vaccinated/ population) * 100 
FROM PortfolioProject ..CovidDeaths dea
JOIN PortfolioProject ..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER By 2,3
)

Select *, (Rolling_People_Vaccinated/population) * 100
FROM PopvsVac


-- Create #Percent_Population_Vaccinated as TEMP TABLE for Analysis
DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)


Insert into #Percent_Population_Vaccinated

SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) AS 'Rolling_People_Vaccinated'
--(Rolling People Vaccinated/ population) * 100 
FROM PortfolioProject ..CovidDeaths dea
JOIN PortfolioProject ..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER By 2,3

Select *, (Rolling_People_Vaccinated/population) * 100
FROM #Percent_Population_Vaccinated

SELECT continent, MAX(cast(total_deaths AS int)) AS "Total Death Count"
FROM PortfolioProject ..CovidDeaths
Where continent IS NOT NULL 
Group By continent
ORDER BY [Total Death Count] DESC 

-- Percent_Population_Vaccinated view 
Create view Percent_Population_Vaccinated AS 
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) AS 'Rolling_People_Vaccinated'
--(Rolling People Vaccinated/ population) * 100 
FROM PortfolioProject ..CovidDeaths dea
JOIN PortfolioProject ..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER By 2,3

Select * 
FROM Percent_Population_Vaccinated
