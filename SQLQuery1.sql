

SELECT * 
FROM Covid_Project..CovidDeaths
ORDER BY 3,4


--SELECT * 
--FROM Covid_Project..CovidVaccinations
--ORDER BY 3,4


-- select the data that we need

SELECT location, date, total_cases, new_cases, total_deaths, population  
FROM Covid_Project..CovidDeaths
ORDER BY 1,2

-- TOTAL CASES vs TOTAL DEATHS

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_rate  
FROM Covid_Project..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

-- TOTAL CASES vs POPULATION

SELECT  location,  MAX(total_cases) as Highest_Case_Count, (MAX(total_cases/population))*100 as Infection_Rate    
FROM Covid_Project..CovidDeaths
--WHERE location = 'India'
WHERE continent is NOT NULL
GROUP BY  location  
ORDER BY 3 DESC

--Total death count

SELECT location, MAX(cast(total_deaths as INT)) AS Highest_Death_Count    
FROM Covid_Project..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY 2 DESC


SELECT location, MAX(cast(total_deaths as INT)) AS Highest_Death_Count    
FROM Covid_Project..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY 2 DESC



--Global analysis 

SELECT date, SUM(new_cases) AS Daily_New_Cases, SUM(CAST(new_deaths AS INT)) AS Daily_Death_Count, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Daily_Death_rate    
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL--and new_cases <> '0'  
GROUP BY date
ORDER BY 1,2


SELECT date, new_cases AS Daily_New_Cases, CAST(new_deaths AS INT) AS Daily_Death_Count, (CAST(new_deaths AS INT)/new_cases)*100 AS Daily_Death_rate    
FROM Covid_Project..CovidDeaths
WHERE continent IS NULL AND location = 'World' AND new_cases <> ' '
--GROUP BY date
--ORDER BY 1,2


SELECT SUM(new_cases) AS Daily_New_Cases, SUM(CAST(new_deaths AS INT)) AS Daily_Death_Count, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS Daily_Death_rate    
FROM Covid_Project..CovidDeaths
WHERE continent IS NULL AND location = 'World' AND new_cases <> ' '


--CTE 

WITH Popn_Vacn(LOCATION, DATE, POPULATION, NEW_VACCINATION, ROLLING_VACCINATION )
AS(
SELECT DTH.location, DTH.date, 
		DTH.population, DTH.new_vaccinations,
		SUM(CAST(DTH.new_vaccinations AS INT)) OVER (PARTITION BY DTH.location ORDER BY DTH.location, DTH.date) AS ROLLING_VACCINATION

FROM Covid_Project..CovidDeaths DTH
JOIN Covid_Project..CovidVaccinations VCN
	ON DTH.location = VCN.location
	AND DTH.date = VCN.date
WHERE DTH.continent IS NOT NULL
)
SELECT * , ROLLING_VACCINATION/POPULATION*100
FROM Popn_Vacn




-- TEMP TABLES

DROP TABLE IF EXISTS TempTable_Popn_Vacn

CREATE TABLE TempTable_Popn_Vacn(

LOCATION nvarchar(255), 
DATE datetime, 
POPULATION numeric, 
NEW_VACCINATION numeric, 
ROLLING_VACCINATION numeric

)

INSERT INTO Temp_Popn_Vacn

SELECT DTH.location, DTH.date, 
		DTH.population, DTH.new_vaccinations,
		SUM(CAST(DTH.new_vaccinations AS INT)) OVER (PARTITION BY DTH.location ORDER BY DTH.location, DTH.date) AS ROLLING_VACCINATION

FROM Covid_Project..CovidDeaths DTH
JOIN Covid_Project..CovidVaccinations VCN
	ON DTH.location = VCN.location
	AND DTH.date = VCN.date
WHERE DTH.continent IS NOT NULL

SELECT *, ROLLING_VACCINATION/POPULATION*100 AS PERCENT_VACCINATED
FROM Temp_Popn_Vacn

--VIEW FUNCTION

DROP VIEW IF EXISTS VIEWPopnVacn
CREATE VIEW VIEWPopnVacn
AS
SELECT DTH.location, DTH.date, 
		DTH.population, DTH.new_vaccinations,
		SUM(CAST(DTH.new_vaccinations AS INT)) OVER (PARTITION BY DTH.location ORDER BY DTH.location, DTH.date) AS ROLLING_VACCINATION

FROM Covid_Project..CovidDeaths DTH
JOIN Covid_Project..CovidVaccinations VCN
	ON DTH.location = VCN.location
	AND DTH.date = VCN.date
WHERE DTH.continent IS NOT NULL


