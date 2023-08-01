select *
from portfolio_project.dbo.CovidDeaths$
where continent is not null


--looking at total cases vs total deaths
-- shows likelihoof of dying if you contract  covid in argentina

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as death_percentage
from portfolio_project.dbo.CovidDeaths$
where location like '%arg%' 
AND continent is not null
order by 1, 2


--looking at total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases / population) * 100 as percent_population_infected
from portfolio_project.dbo.CovidDeaths$
--where location like '%arg%'
order by 1, 2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highest_infection_count , max((total_cases / population) * 100) as percent_population_infected
from portfolio_project.dbo.CovidDeaths$
--where location like '%arg%'
WHERE continent is not null
group by location, population
order by percent_population_infected desc

--countries with highest death count per population
select location, max(cast(total_deaths as int)) as total_death_count
from portfolio_project.dbo.CovidDeaths$
--where location like '%arg%'
where continent is not null
group by location
order by total_death_count desc

-- things by continent

--showing the continents with the highest death count per population


select location, max(cast(total_deaths as int)) as total_death_count
from portfolio_project.dbo.CovidDeaths$
--where location like '%arg%'
where continent is  null
group by location
order by total_death_count desc

--global numbers

select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as int)) / sum(new_cases) * 100) as death_percentage
from portfolio_project.dbo.CovidDeaths$
---where location like '%arg%' AND
where continent is not null
--group by date
order by 1,2 


-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from portfolio_project.dbo.CovidDeaths$ dea
join portfolio_project.dbo.covidvaccination$ vac
on dea.location =vac.location 
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--use cte
with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from portfolio_project.dbo.CovidDeaths$ dea
join portfolio_project.dbo.covidvaccination$ vac
on dea.location =vac.location 
and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (rolling_people_vaccinated / population) * 100 as percentage_population_vaccinated
from pop_vs_vac

--- temp table
drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from portfolio_project.dbo.CovidDeaths$ dea
join portfolio_project.dbo.covidvaccination$ vac
	on dea.location =vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


select *, (rolling_people_vaccinated / population) * 100 as percentage_population_vaccinated
from #percent_population_vaccinated

-- creating view to store date for later visualizations 


create view percent_population_vaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from portfolio_project.dbo.CovidDeaths$ dea
join portfolio_project.dbo.covidvaccination$ vac
	on dea.location =vac.location 
	and dea.date = vac.date
where dea.continent is not null 

select *
from percent_population_vaccinated