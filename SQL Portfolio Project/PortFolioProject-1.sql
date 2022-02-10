use portfolioproject;
select*from portfolioproject.covid_deaths
where continent is not null;
#select*from portfolioproject.covidvaccinations;

##2 select data what we are goin to use
select location, date, total_cases, new_cases, total_deaths, population from portfolioproject.coviddeaths;

##3 Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage from portfolioproject.coviddeaths;

##4 it shows covid deaths in any country by the effected rate
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage from portfolioproject.coviddeaths where location like '%africa%';

##5 looking at total_cses vs population
## we will get percentage of populatrion got covid
select location, date, population, total_cases, (total_cases/population)*100 as pop_got_covid_in_perc from portfolioproject.covid_deaths;

##6 looking to to countries highest infection rate compare to population

select location, population, max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as pop_got_covid_in_perc from portfolioproject.covid_deaths
group by location, population;

##7 below query we will get the same resukt above but in descenting order
select location, population, max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as pop_got_covid_in_perc from portfolioproject.covid_deaths
group by location, population
order by pop_got_covid_in_perc desc;

##8 looking countries with highest death count per population

select location, max(total_deaths) as TotalDeathCount from portfolioproject.covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc;

##9 above query result is not good because of inapropriate data we need do an extra step

#select location, max(cast(total_deaths as int) as TotalDeathCount from portfolioproject.covid_deaths
#group by location
#order by TotalDeathCount desc;

## or we can do the above cast thing same as below if its not working(we are doing this to change the data type of columns)

#select location, max(convert(int,total_deaths)) as TotalDeathCount from portfolioproject.covid_deaths
#group by location
#order by TotalDeathCount desc;

##10 looking continent with highest death count per population

select continent, max(total_deaths) as TotalDeathCount from portfolioproject.covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;

## query 8 and 10 same result r is correct but 10 is not becouse inaccurate data

##11 global numbers

select date, sum(new_cases)as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as Death_percentage from portfolioproject.coviddeaths
where continent is not null
group by date;

##12 global numbers in a single raw result

select date, sum(new_cases)as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as Death_percentage from portfolioproject.coviddeaths
where continent is not null;

##13  loading vaccination table

select*from portfolioproject.covidvaccinations;


###14 joinimg both tables with the basis of common columns in both table


select*from portfolioproject.covid_deaths dea
join portfolioproject.covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date;

##15 looking total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
from portfolioproject.covid_deaths dea
join portfolioproject.covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3;

##16 looking the sum of new_vaccination people everyday but its partioned by location and order by location and date(it means creating new column this column include summation of new vaccinated people every day each of location)

## below one what happened we are not using the order by form 
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location) as summationOfNewvaccin
from portfolioproject.covid_deaths dea
join portfolioproject.covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3;

## using order by

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.population, dea.date) as summationOfNewvaccin
from portfolioproject.covid_deaths dea
join portfolioproject.covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3;

## 17 looking summationOfNewvaccin/population in percentage
## below query is get error so we creating a CTE(look Note)

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.population, dea.date) as summationOfNewvaccin, # (summationOfNewvaccin/population)*100
from portfolioproject.covid_deaths dea
join portfolioproject.covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3;

##18  currect query for the above looking is below after creating CTE

with popvsvac(continent,location,date,population,new_vaccinations,summationOfNewvaccin)
as(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.population, dea.date) as summationOfNewvaccin
from portfolioproject.covid_deaths dea
join portfolioproject.covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3
)
select*, (summationOfNewvaccin/population)*100 as percOfNewvVaccNoByPop
from popvsvac;

##19 creating a Temp table and insrt values from the query18

#drop table if exist percngePopVacnated;
create table percngePopVacnated(
continent varchar(250),
location varchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
summationOfNewvaccin numeric
);
insert into percngePopVacnated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.population, dea.date) as summationOfNewvaccin
from portfolioproject.covid_deaths dea
join portfolioproject.covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3;
select*, (summationOfNewvaccin/population)*100 as percOfNewvVaccNoByPop
from percngePopVacnated;


##20 create a view to store data for later visualization

create view newpercngePopVacnated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.population, dea.date) as summationOfNewvaccin
from portfolioproject.covid_deaths dea
join portfolioproject.covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null;
#order by 2,3;


select*from newpercngePopVacnated;











