SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid..CovidDeaths
order by 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
Where [location] like '%states%'
order by 1,2

--Total Cases vs Population

SELECT Location, date, total_cases, population, (total_deaths/population) * 100
From PortfolioProjectCovid..CovidDeaths
Where [location] = 'Iran'
order by 1,2

-- Looking at Coutries with highest infection rate compared to Population

SELECT Location, population,date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProjectCovid..CovidDeaths
Group by [location],population,date
order by PercentPopulationInfected desc

--Highiest Death Count per population

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovid..CovidDeaths
Where continent is null
and [location] not in ('World','Europian Union','International')
GROUP by [location]
order by TotalDeathCount desc

-- Global Numbers

 

----



-- USe CTE

With PopvsVac (continent,Location,date,Population,new_vaccinations,RollingPeoplevaccinated)
as (Select dea.continent, dea.[location], dea.date, dea.[population], vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
From PortfolioProjectCovid..CovidDeaths dea 
Join PortfolioProjectCovid..CovidVaccinations vac 
    on dea.[location] = vac.[location]
    and dea.date = vac.date 
where dea.continent is not null

)

SELECT *, (RollingPeoplevaccinated/cast(Population as float))*100 from PopvsVac

--Temp Table
DROP table if EXISTS #PercentPopulationInfected
CREATE table #PercentPopulationInfected
(Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric)

Create View PercentPopulationVaccinated as
Select dea.continent, dea.[location], dea.date, dea.[population], vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
From PortfolioProjectCovid..CovidDeaths dea 
Join PortfolioProjectCovid..CovidVaccinations vac 
    on dea.[location] = vac.[location]
    and dea.date = vac.date 
where dea.continent is not null

SELECT *, (RollingPeoplevaccinated/cast(Population as float))*100 from #PercentPopulationInfected

SELECT * from [#PercentPopulationInfected]