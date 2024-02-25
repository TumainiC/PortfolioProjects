--SELECT *
--FROM ThePortfolioProject..CovidDeaths
--Where location Like '%asia%'
--Order By 1,2


--Select the data to work with

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM ThePortfolioProject..CovidDeaths
Order BY 1,2

--Total Cases vs Total Deaths

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ThePortfolioProject..CovidDeaths
--Where location LIKE '%states%'
Order BY 1,2

--Total Cases vs Population
SELECT location, date, total_cases,total_deaths,population,(total_deaths/population)*100 as DeathperPop
FROM ThePortfolioProject..CovidDeaths
Where location LIKE '%states%'
Order BY 1,2

--Countries with highes infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases/population))*100 as  PerecentPopulationInfected
FROM ThePortfolioProject..CovidDeaths
Group By location, population
Order By  PerecentPopulationInfected desc

--Showing countries with highest Death Count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM ThePortfolioProject..CovidDeaths
Group By location
Order By  TotalDeathCount desc

--BREAKING THINGS DOWN BY CONNTINENT

--Continents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM ThePortfolioProject..CovidDeaths
Where continent is null
Group By continent
Order By  TotalDeathCount desc


--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ThePortfolioProject..CovidDeaths
--Where location LIKE '%states%'
WHERE continent is not null
GROUP BY date
Order BY 1,2

--VIEW FOR THIS TABLE ABOVE 
CREATE VIEW GlobalNumbers as 
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ThePortfolioProject..CovidDeaths
--Where location LIKE '%states%'
WHERE continent is not null
GROUP BY date
--Order BY 1,2




--Total deaths globally
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ThePortfolioProject..CovidDeaths
--Where location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
Order BY 1,2



--Total Population vs Total Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ThePortfolioProject..CovidDeaths dea
Join ThePortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
ORDER BY 2,3


--Uing a CTE
WITH CTE_popVSvac (continent, location,date,population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ThePortfolioProject..CovidDeaths dea
Join ThePortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as RollingPercentagePeopleVaccinated
FROM CTE_popVSvac

--Using a Temp Table

DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ThePortfolioProject..CovidDeaths dea
Join ThePortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATING VIEWS FOR LATER USE

CREATE VIEW PercentagePeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ThePortfolioProject..CovidDeaths dea
Join ThePortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

