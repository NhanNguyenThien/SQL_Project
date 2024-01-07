select * from coviddeaths
order by 3,4
---Truy vấn dữ liệu cần sử dụng
select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--total_cases: số ca nhiễm tính đến thời điểm cập nhật dữ liệu
--new_cases: số ca nhiễm mới

--Tính toán tỷ lệ tử vong của VietNam dựa trên số ca nhiễm và số ca tử vong
select location,date,total_cases,total_deaths,
CONVERT(float, total_deaths) / CONVERT(float, total_cases)*100 AS DeathRate
from CovidDeaths
where location like '%iet%'
order by 1,2

--Tìm kiếm nước nào có tỷ lệ lây nhiễm cao nhất dựa trên dân số
select location,population, MAX(CONVERT(int, total_cases)) as HighestInfectionCount,
MAX(CONVERT(int, total_cases)/population)*100 as Rate
from CovidDeaths
group by location,population
order by Rate desc

--Hiển thị nước nào có tổng số người chết cao nhất
select location, MAX(convert(int, total_deaths)) as TotalDeathCounts
from CovidDeaths
group by location
order by TotalDeathCounts desc

--Hiển thị khu vực nào có tổng số người chết cao nhất
select location, max(convert(int, total_deaths)) as TotalDeathCounts
from CovidDeaths
group by location
order by TotalDeathCounts desc

--Tỷ lệ tử vong của toàn thế giới
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
order by 1,2
