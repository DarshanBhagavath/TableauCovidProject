select top 20 * from PortfolioProject.dbo.CovidDeaths

select top 20 * from PortfolioProject.dbo.CovidVaccinations

-- Death Percetage vs Total case
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%Canada%'
order by 1,2

--Total cases Vs Population
select location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location like '%Canada%'
order by 1,2

-- Looking at countries with Highest Infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%Canada%'
GROUP BY location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
select location, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%Canada%'
where continent is not null
GROUP BY location

-- Lets break things down by Continent
select continent, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%Canada%'
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC


-- Showing Continents with Highest Death Rate count per population
select continent, MAX(CAST(Total_deaths as INT)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%Canada%'
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC

--Global Numbers
select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths,
SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%Canada%'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population VS Vaccination
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths cd
JOIN PortfolioProject.dbo.CovidVaccinations cv
ON cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3



-- USE CTE
With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths cd
JOIN PortfolioProject.dbo.CovidVaccinations cv
ON cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100  from PopVsVac


--CREATE View
Create View PercentagePopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(INT,cv.new_vaccinations)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths cd
JOIN PortfolioProject.dbo.CovidVaccinations cv
ON cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
