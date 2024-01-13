select * from CovidVaccinations
order by 3,4

select *
from CovidDeaths
WHERE continent is NOT NULL
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select continent, Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location like '%Canada'
and continent is NOT NULL
order by 1,2

-- Looking at the total cases vs Population
-- Shows what percentage of population got Covid
select continent, Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
WHERE continent is NOT NULL
order by 1,2

-- Looking at Countries with highest infection rate compared to population
select Continent, Location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
WHERE continent is  NOT NULL
Group By Location, continent, population
order by PercentPopulationInfected DESC

-- Showing the Continents with highest death counts
Select Location, Max(total_deaths) as TotalDeathCount
From CovidDeaths
WHERE continent is NULL
Group By [location]
Order By TotalDeathCount DESC

-- GLOBAL NUMBERS

-- Looking at Death Percentage per day
select date, SUM(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
-- Where location like '%Canada'
WHERE continent is NOT NULL
Group By Date
order by 1,2

-- Looking at Total Population vs Vaccination

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_vaccinations,RollingPPLVaccinated)
As 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by  dea.Location order by dea.location, dea.date) as RollingPPLVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.[date]
Where dea.continent is not null
)

Select *, (RollingPPLVaccinated/Population)*100 as PerPPLVaccinated
from PopvsVac

--TEMP TABLE
DROP Table if EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPPLVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by  dea.Location order by dea.location, dea.date) as RollingPPLVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.[date]
Where dea.continent is not null


SELECT Location, Population, MAX((RollingPPLVaccinated/Population)*100) as PerPPLVaccinated
FROM #PercentPopulationVaccinated
GROUP BY Location, Population
Order by PerPPLVaccinated DESC

-- Creating View to store data for later visualization

Create VIEW PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by  dea.Location order by dea.location, dea.date) as RollingPPLVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.[date]
Where dea.continent is not null

Select * from PercentPopulationVaccinated