select * 
from CovidDeaths$
order by 3,4

select *
from CovidVaccinations$
order by 3,4

--select data that we are using

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths$
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
order by 1,2


--looking at Total cases and population
--Shows what poplulation got covid

select location,date,population,total_cases,(total_deaths/population)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
order by 1,2


--looking at Countries with Highest infection rate compared to population
select location,population,max(total_Cases) as HighestInfectionCount, max((total_cases/population))*100 as persentPopulationInfected
from CovidDeaths$
group by Location,population
order by persentPopulationInfected desc

--showing continents with highest death counts per population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--showing countries with highest death counts per population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where location is not null
group by location
order by TotalDeathCount desc

--looking at total population vs vaccination

--use CTE
with PopvsVac(Continent,location,Date,population,new_vaccinations,RollingPeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeoplevaccinated/population)*100
from PopvsVac


--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select*,(RollingPeoplevaccinated/population)*100
from #PercentPopulationVaccinated

--creating a view to store data for later visualization
create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date 
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated