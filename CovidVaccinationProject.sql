select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortofolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortofolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as case_percentage
from PortofolioProject..CovidDeaths
--where location like '%indonesia%'
order by 1,2

-- Looking at Countries with highest in infection rate compared to population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percent_population_infected
from PortofolioProject..CovidDeaths
group by location, population
order by percent_population_infected desc

-- Showing Countries with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count
from PortofolioProject..CovidDeaths
where continent is not null
group by location
order by total_death_count desc

-- Showing continent with death count

select continent, max(cast(total_deaths as int)) as total_death_count
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc

-- Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from PortofolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Looking at total population vs vaccinations

select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
 , sum(convert(int, vacc.new_vaccinations)) over (partition by death.location order by death.location 
 , death.date) as total_people_vaccinated
 from PortofolioProject..CovidDeaths death
join PortofolioProject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 1,2

-- Use CTE
with PopVsVac (continent, location, population, vaccinations, total_people_vaccinated)
as
(
select death.continent, death.location, death.population, vacc.new_vaccinations
 , sum(convert(int, vacc.new_vaccinations)) over (partition by death.location order by death.location 
 , death.date) as total_people_vaccinated
 from PortofolioProject..CovidDeaths death
join PortofolioProject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
)
select *, (total_people_vaccinated/population)*100 as vaccinated_percentage
from PopVsVac
--where vaccinations is not null
--order by vaccinated_percentage desc

-- temp table

drop table if exists PeopleVaccinated
create table PeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
population numeric,
vaccinations numeric,
total_vaccinated numeric
)

insert into PeopleVaccinated
select death.continent, death.location, death.population, vacc.new_vaccinations
 , sum(convert(numeric, vacc.new_vaccinations)) over (partition by death.location order by death.location 
 , death.date) as total_people_vaccinated
 from PortofolioProject..CovidDeaths death
join PortofolioProject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date

select *, (total_vaccinated/population)*100 as vaccinated_percentage
from PeopleVaccinated

-- Creating view to store data for visualizations

create view percent_PopulationVaccinated as
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
 , sum(convert(int, vacc.new_vaccinations)) over (partition by death.location order by death.location 
 , death.date) as total_people_vaccinated
 from PortofolioProject..CovidDeaths death
join PortofolioProject..CovidVaccinations vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
)
select * from percent_PopulationVaccinated