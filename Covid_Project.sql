select *
from PortfolioProject.dbo.covid_deaths
where continent is not null
order by 3,4;

--select *
--from covid_deaths 
--order by 3,4

Select Location,date,total_cases,total_deaths,population
from
PortfolioProject.dbo.covid_deaths where continent is not null
order by 1,2

--Total Cases vs Total deaths 
--shows the likelihood of dying if you contract covid in your country
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 DeathPercentage
from
PortfolioProject.dbo.covid_deaths 
--Where location like '%Greece'
where continent is not null
order by 1,2

--Looking at vs Population
--Shows what percetange of population got Covid
Select Location,date,population,total_cases,(total_cases/population)*100 PercentPopulationInfected
from
PortfolioProject.dbo.covid_deaths 
--Where location like '%Greece'
where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location,population,MAX(total_cases) HighestInfectionCount,MAX((total_cases/population))*100 PercentPopulationInfected
from
PortfolioProject.dbo.covid_deaths 
--Where location like '%Greece'
where continent is not null
group by Location,Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location,max(Cast(total_deaths as int)) as TotalDeathCount
from
PortfolioProject.dbo.covid_deaths 
--Where location like '%Greece'
where continent is not null
group by Location
order by TotalDeathCount desc


--BREAK THINGS DOWN BY CONTINENT



--Showing continents with highest death count per population
Select continent,max(Cast(total_deaths as int)) as TotalDeathCount
from
PortfolioProject.dbo.covid_deaths 
--Where location like '%Greece'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

Select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from
PortfolioProject.dbo.covid_deaths 
--Where location like '%Greece'
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from
PortfolioProject.dbo.covid_deaths 
--Where location like '%Greece'
where continent is not null
order by 1,2

-- Looking at Total population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location 
order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from
PortfolioProject..covid_deaths dea
join PortfolioProject..Covid_Vaccinations   vac
   on  dea.location=vac.location
   and dea.date=vac.date
 where dea.continent is not null
order by 1,2,3

--USE CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location 
order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from
PortfolioProject..covid_deaths dea
join PortfolioProject..Covid_Vaccinations   vac
   on  dea.location=vac.location
   and dea.date=vac.date
 where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac


--Temp table same as before but in a different way
DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE table #PERCENTPOPULATIONVACCINATED
(
continent nvarchar(255),
Location nvarchar (255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PERCENTPOPULATIONVACCINATED
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location 
order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from
PortfolioProject..covid_deaths dea
join PortfolioProject..Covid_Vaccinations   vac
   on  dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
select *, (RollingPeopleVaccinated/Population)*100 
from #PERCENTPOPULATIONVACCINATED


--CREATING View to store data for later visualization

Create view PERCENTPOPULATIONVACCINATED as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location 
order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from
PortfolioProject..covid_deaths dea
join PortfolioProject..Covid_Vaccinations   vac
   on  dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PERCENTPOPULATIONVACCINATED