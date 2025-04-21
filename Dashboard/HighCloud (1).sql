create database HighCloud;
use highcloud;
show tables;
select * from maindata;

select count(*) from maindata;
select sum(Transported_passengers) from maindata;
describe maindata;

alter table maindata rename column `%Distance Group ID` to `Distance_Group_ID`;
alter table maindata rename column `# Available Seats` to `Available_Seats`;
alter table maindata rename column `From - To City` to `From_To_City`;
alter table maindata rename column `Carrier Name` to `Carrier_Name`;
alter table maindata rename column `# Transported Passengers` to `Transported_Passengers`;
alter table maindata rename column `%Airline ID` to `Airline_ID`;
alter table maindata rename column `month (#)` to `month`;

create View	order_date as 
select concat(year,'-', Month,'-',day) as order_date,Transported_Passengers,Available_Seats,from_to_city,
		Carrier_Name,Distance_Group_ID from maindata;
select * from order_date;
-- KPI-1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)
-- A.Year
-- B.Monthno
-- C.Monthfullname
-- D.Quarter(Q1,Q2,Q3,Q4)
-- E. YearMonth ( YYYY-MMM)
-- F. Weekdayno
-- G.Weekdayname
-- H.FinancialMOnth
-- I. Financial Quarter 

create view kpi1 as select year(order_date) as year_number,month(order_date) as month_number, day(order_date) as day_number,
					monthname(order_date) as month_name,concat("Q",quarter(order_date)) as quarter_number,
                    concat(year(order_date),'-',monthname(order_date)) as year_monrh_name, weekday(order_date) as weekday_number,
                    dayname(order_date) as day_name,
                    case
                    when quarter(order_date)=1 then "FQ4"
                    when quarter(order_date)=2 then "FQ1"
                    when quarter(order_date)=3 then "FQ2"
                    when quarter(order_date)=4 then "FQ3"
                    end as Finicial_Quarter,
                    case
                    when month(order_date)=1 then "10"
                    when month(order_date)=2 then "11"
                    when month(order_date)=3 then "12"
                    when month(order_date)=4 then "1"
                    when month(order_date)=5 then "2"
                    when month(order_date)=6 then "3"
                    when month(order_date)=7 then "4"
                    when month(order_date)=8 then "5"
                    when month(order_date)=9 then "6"
                    when month(order_date)=10 then "7"
                    when month(order_date)=11 then "8"
                    when month(order_date)=12 then "9"
                    end as Finicial_Month,
                    case
                    when weekday(order_date) in (5,6) then "Weekend"
                    when weekday(order_date) in (0,1,2,3,4) then "Weekday"
                    end as Weekend_Weekday,
                    Transported_passengers,Available_seats,from_to_city,distance_group_id from order_date;
                    
select * from kpi1;

-- KPI-2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)
select year_number,concat(round(sum(Transported_Passengers) / 1000000, 2), 'M')as Transported_passengers,concat(round(sum(Available_Seats) / 1000000, 2), 'M') 
			as Available_seats,concat(round(sum(Transported_Passengers) / sum(Available_Seats) * 100, 2), '%')
			as Load_Factor from kpi1 group by year_number;
                
select quarter_number,concat(round(sum(Transported_Passengers) / 1000000, 2), 'M')as Transported_passengers,concat(round(sum(Available_Seats) / 1000000, 2), 'M') 
			as Available_seats,concat(round(sum(Transported_Passengers) / sum(Available_Seats) * 100, 2), '%')
			as Load_Factor from kpi1 group by quarter_number order by quarter_number;

select month_name,concat(round(sum(Transported_Passengers) / 1000000, 2), 'M')as Transported_passengers,concat(round(sum(Available_Seats) / 1000000, 2), 'M') 
			as Available_seats,concat(round(sum(Transported_Passengers) / sum(Available_Seats) * 100, 2), '%')
			as Load_Factor from kpi1 group by month_name order by load_factor desc;
                
-- KPI-3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
select Carrier_Name from maindata;
select Carrier_Name,concat(round(sum(Transported_Passengers) / 1000, 0), 'K') as Transported_passengers,concat(round(sum(Available_Seats) / 1000, 0), 'K')  
		as Available_seats,concat(round(sum(Transported_Passengers / Available_Seats)/100,0),'%')
        as Load_Factor from maindata group by Carrier_Name order by load_Factor desc;

-- KPI-4. Identify Top 10 Carrier Names based passengers preference 
SELECT 
    Carrier_Name,
    CONCAT(FORMAT(SUM(Transported_Passengers) / 1000000, 2), 'M') AS TotalPassengers
FROM maindata
GROUP BY Carrier_Name
ORDER BY SUM(Transported_Passengers) DESC
LIMIT 10;



-- KPI 5: Average Load Factor by Region
SELECT 
    `%Region Code` AS Region,
    CONCAT(FORMAT((SUM(`Transported_Passengers`) / SUM(`Available_Seats`) * 100), 2), '%') AS Average_Load_Factor
FROM maindata
GROUP BY `%Region Code`;

-- KPI 6: Top 5 Routes by Transported Passengers
SELECT 
    From_To_City AS Route,
    CONCAT(FORMAT(SUM(Transported_Passengers) / 1000, 1), 'K') AS Total_Passengers
FROM maindata
GROUP BY From_To_City
ORDER BY SUM(Transported_Passengers) DESC
LIMIT 5;

-- KPI 7: Revenue Passenger Kilometers (RPK)
SELECT 
    Year,
    CONCAT(FORMAT(SUM(Transported_Passengers * Distance) / 1000000, 2), 'M') AS RPK
FROM maindata
GROUP BY Year;


-- KPI 8: Top Routes by Number of Flights
SELECT 
    From_To_City AS Route,
    COUNT(*) AS NumberOfFlights
FROM maindata
GROUP BY From_To_City
ORDER BY NumberOfFlights DESC
LIMIT 10;

-- KPI 9: Load Factor on Weekends vs Weekdays
SELECT 
    DayType,
    SUM(Transported_Passengers) AS TotalTransportedPassengers,
    SUM(Available_Seats) AS TotalAvailableSeats,
    FORMAT((SUM(Transported_Passengers) * 100.0) / SUM(Available_Seats), 2) AS LoadFactorPercentage
FROM (
    SELECT 
        CASE
            WHEN DAYOFWEEK(DateField) IN (1, 7) THEN 'Weekend'
            ELSE 'Weekday'
        END AS DayType,
        Transported_Passengers,
        Available_Seats
    FROM maindata
) AS SubQuery
GROUP BY DayType;




-- KPI 10: Number of Flights by Distance Group
SELECT 
    Distance_Group_ID,
    COUNT(*) AS NumberOfFlights
FROM maindata
GROUP BY Distance_Group_ID;

    
    -- KPI 11: Top 10 Cities by Traffic
SELECT 
    City,
    sum(`Transported_Passengers`) AS Total_Passengers
FROM (
    SELECT `Origin City` AS City, `Transported_Passengers` FROM maindata
    UNION ALL
    SELECT `Destination City` AS City, `Transported_Passengers` FROM maindata
) AS Combined
GROUP BY City
ORDER BY Total_Passengers DESC
LIMIT 10;


-- KPI 12: Average Distance Per Passenger
SELECT 
    Year,
    sum(Distance) / sum(`Transported_Passengers`) AS Avg_Distance_Per_Passenger
FROM maindata
GROUP BY Year;
