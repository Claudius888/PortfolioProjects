select *
From PortfolioCovid .. CovidDeaths
Where continent is not null
order by 3,4


--select *
--From PortfolioCovid .. CovidVaccinations
--order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioCovid .. CovidDeaths 
Where continent is not null
order by 1,2

-- Looking at the Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contact covid in a country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioCovid .. CovidDeaths
where location like '%India%' and continent is not null
order by 1,2

-- Looking at the Total Cases Vs Population
-- Shows what percentage of population get Covid

select Location, date, total_cases, population, (total_cases/population) * 100 as PercentagePopulationinfected
From PortfolioCovid .. CovidDeaths
where location like '%India%' and continent is not null
order by 1,2

-- Looking at Coutry with Highest Infection rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population) * 100 as 
	PercentPopulationInfected
From PortfolioCovid .. CovidDeaths
--- where location like '%India%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select Location, population, MAX(cast(total_deaths as bigint)) as TotalDeathCount
--Max(total_cases/population) * 100 as PercentPopulationInfected
From PortfolioCovid .. CovidDeaths
--- where location like '%India%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Breaking Down by Continent
-- Showing continents with highest death count

select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioCovid .. CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select date, SUM(new_cases) as SumNewCases, SUM(cast(new_deaths as bigint)) as SumNewDeaths , SUM(cast(new_deaths as bigint)) / SUM(new_cases) * 100 as DeathPercentage
From PortfolioCovid .. CovidDeaths
Where continent is not null
Group by date
order by  1, 2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioCovid .. CovidDeaths dea
Join PortfolioCovid .. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

 -- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioCovid..CovidDeaths dea
Join PortfolioCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEmp Table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioCovid..CovidDeaths dea
Join PortfolioCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

drop view PercentPopulationVaccinated

Create view PercentPopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioCovid..CovidDeaths dea
Join PortfolioCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationvaccinated

