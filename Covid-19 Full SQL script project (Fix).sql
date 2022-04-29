select*
from [Covid  Portfolio Project]..[covid-Death]
where continent is not null
order by 3,4

--select*
--from [Covid  Portfolio Project]..[covid-vaccination]
--order by 3,4
--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from [Covid  Portfolio Project]..[covid-Death]
where continent is not null
order by 1,2

--looking at total cases vs total Deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
from [Covid  Portfolio Project]..[covid-Death]
where continent is not null
and location like '%states%'
order by 1,2


--Looking at the total cases vs population
-- shows the Percentage of the population who got Covid at some point.
--you can check your own country rate of infection by changing the name in the where location like statment

select location, date,population, total_cases,  (total_cases/population)*100 AS infectionRate 
from [Covid  Portfolio Project]..[covid-Death]
where continent is not null
and location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population
--group by statment has to be used cause the data has daily cases reported for each country and 
--we needed each country represented by one row.

select location,population, max(total_cases)  AS Highestinfectioncount, max((total_cases/population))*100 AS PercentofPopulationInfected
from [Covid  Portfolio Project].dbo.[covid-Death]
--where location like '%egypt%' 
where continent is not null
group by location, population
order by 4 desc 

---showing countries with highest Death count per population

select location, max(cast (total_deaths as int)) as TotalDeathCount
from [Covid  Portfolio Project].dbo.[covid-Death]
--where location like '%egypt%' 
where continent is not null
group by location
order by TotalDeathCount desc 

-- show continent with the total deaths count 

select continent, max(cast (total_deaths as int)) as TotalDeathCount
from [Covid  Portfolio Project].dbo.[covid-Death]
--where location like '%egypt%' 
where continent is not null
group by continent
order by TotalDeathCount desc 

--- showing the Global deathtoll percentage (How Many of the World Population died) 

select  Sum(new_cases) as total_cases, sum (cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum (new_cases)*100 as DeathPercentage 
from [Covid  Portfolio Project].dbo.[covid-Death]
--where location like '%egypt%' 
where continent is not null
--group by date
order by 1,2

--showing the Global Deathtoll numbers per day

select date, Sum(new_cases) as total_cases, sum (cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum (new_cases)*100 as DeathPercentage 
from [Covid  Portfolio Project].dbo.[covid-Death]
--where location like '%egypt%' 
where continent is not null
group by date
order by 1,2
--

--- looking at the total population Vs Vaccinations

select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum (convert (int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date)
--as RollingPeopleVaccinated 
from [covid-Death] Dea
join [covid-vaccination]  Vac
on Dea.location=Vac.location
and Dea.date=vac.date
where dea.continent is not null
order by 2,3


-- Using CTE

with PopvsVac (continent ,location,date,population,new_vaccination, rollingpeoplevaccinated)
as
(

select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum (convert (int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date)
--as RollingPeopleVaccinated 
from [covid-Death] Dea
join [covid-vaccination]  Vac
on Dea.location=Vac.location
and Dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100  as VaccinatedPopulationRate
from PopvsVac


---Creating A Temp Table
--(this code was givign an error "Arithmetic overflow error converting expression to data type int", it's referring to
 --Vac.new_vaccinations which we had it converted to int but the Sum of it exceeded 2,147,483,647 which the int Limit so we replaced Int by Bigint)
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime ,
population numeric ,
new_vaccinations numeric,
rollingpeoplevaccinated numeric )

insert into #PercentPopulationVaccinated

select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum (convert (bigint, Vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date)
--as RollingPeopleVaccinated 
from [covid-Death] Dea
join [covid-vaccination]  Vac
on Dea.location=Vac.location
and Dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100  as VaccinatedPopulationRate
from #PercentPopulationVaccinated

---creatign view to store data for later visualization

create view GlobalTotaldeath as
select location, max(cast (total_deaths as int)) as TotalDeathCount
from [Covid  Portfolio Project].dbo.[covid-Death]
--where location like '%egypt%' 
where continent is not null
group by location
--order by TotalDeathCount desc

---creatign view to store data for later visualization
create view 
PercentPopulationVaccinated as
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum (convert (bigint, Vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date)
as RollingPeopleVaccinated 
from [covid-Death] Dea
join [covid-vaccination]  Vac
on Dea.location=Vac.location
and Dea.date=vac.date
where dea.continent is not null
--order by 2,3