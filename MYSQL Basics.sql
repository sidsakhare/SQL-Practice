USE city;   -- replace with your actual schema name
DESCRIBE city;

USE city;
SELECT * FROM city;

-- Get all cities where the CountryCode is 'IND'.
SELECT *  FROM city WHERE  CountryCode = 'IDN';

-- Find all cities with Population greater than 10,000,000.
SELECT * FROM city WHERE Population > 10000000;

-- List all cities in the District 'Maharashtra'.
SELECT * FROM city
WHERE District = 'Maharashtra';

-- Find cities in 'IND' that have a Population above 500,000.
SELECT * 
FROM city
WHERE CountryCode = 'IND' AND Population > 500000;

-- Get cities that are either in 'USA' or 'IND'.
SELECT *
FROM city
WHERE CountryCode = 'USA' or CountryCode= 'IND';

-- Find all cities NOT in CountryCode 'IND' with population above 2,000,000.
SELECT ID, Name, CountryCode, District, Population
FROM city
WHERE CountryCode NOT IN ('IND') AND Population > 2000000;

-- Insert a new city: Name='Pune', CountryCode='IND', District='Maharashtra', Population=3124458.
INSERT INTO city(`Name` , `CountryCode` , `District`, `Population`)
VALUES('Pune', 'IND', 'MAHARASHTRA', 3124458);

SELECT * 
FROM city
WHERE `Name` = 'Pune';

-- Update the Population of the city named 'Mumbai' to 20000000.
UPDATE city
SET Population = 20000000
WHERE `ID` = 1024;

SELECT * FROM city WHERE `Name`= 'Mumbai (Bombay)';

-- Delete all cities where Population is 150000.
DELETE FROM city
WHERE Population = 150000;

-- Update the District to 'Unknown' for all cities where District is an empty string ''.
UPDATE city
set District = 'Maharashtra'
WHERE District = 'MAHARASHTRA';

#checking if chasges are made in District coloumn or not.
SELECT *
FROM city
WHERE `Name` = 'Pune';

-- List all cities ordered by Population from highest to lowest.
SELECT * 
FROM city
ORDER BY Population DESC;

-- Show all cities ordered by Name alphabetically (A to Z).
SELECT * 
FROM city
ORDER BY `Name` ASC;

-- List cities in CountryCode 'IND' sorted by District A→Z, then by Population highest first.
SELECT * 
FROM city
WHERE CountryCode = 'IND' 
ORDER BY District , Population DESC;

-- Get the 10 most populated cities in the world.
SELECT * 
FROM city
ORDER BY Population DESC 
LIMIT 10;

-- Show cities ranked 11 to 20 by population (page 2).
SELECT * 
FROM city
ORDER BY Population DESC
LIMIT 10 OFFSET 10;

-- Get the 5 least populated cities in 'IND'.
SELECT * 
FROM city
WHERE CountryCode = 'IND'
ORDER BY Population ASC 
LIMIT 5;

-- Find all cities whose Name starts with 'New'.
SELECT * 
FROM city
WHERE `Name` LIKE 'New%';

-- Find cities whose Name ends with 'pur'.
SELECT * 
FROM city
WHERE `Name` LIKE '%pur';

-- Find all cities whose Name contains 'bad' anywhere.

SELECT * 
FROM city
WHERE `Name` LIKE '%Bad%';

-- Find cities whose Name has 'N' as the second character.
SELECT * 
FROM city
WHERE `Name` LIKE '_N%';

-- Find all cities with Population between 500,000 and 1,000,000.
SELECT * 
FROM city
WHERE Population BETWEEN 500000 and 1000000;

-- List cities from any of these countries: 'IND', 'CHN', 'BRA', 'USA'.
SELECT * 
FROM city
WHERE `CountryCode` IN ('IND', 'CHN', 'BRA', 'USA');

-- Find cities NOT in 'IND', 'PAK', 'BGD' with population above 1,000,000.
SELECT * 
FROM city
WHERE `CountryCode` NOT IN ('IND', 'PAK', 'BGD') 
AND Population > 1000000;

-- Count the total number of cities in the table.
SELECT 
COUNT(`Name`) as Cities_count
From city;

-- Find the maximum and minimum Population in the entire table.
SELECT 
MAX(Population) as Max_pop,
MIN(Population) as Min_pop
FROM city;

-- Find the total (SUM) population of all cities in 'IND'.
SELECT 
SUM(Population) as Total_pop
FROM city
WHERE CountryCode = 'IND';

-- Find the average population of cities in 'USA', rounded to the nearest whole number.
SELECT 
round(AVG(`Population`),0)
FROM city
WHERE CountryCode = 'USA';
-- Count how many cities exist for each CountryCode.
SELECT CountryCode,
count(distinct`Name`) as country_wise_city_count
FROM city
GROUP BY CountryCode;

-- Find the total population per CountryCode, ordered by total population descending.
SELECT CountryCode,
sum(Population) as Country_wise_pop
FROM city
GROUP BY CountryCode
ORDER BY Country_wise_pop DESC;

-- Find countries that have more than 50 cities in the table.
SELECT 
CountryCode, Count('Name') as Contryc
FROM city
group by CountryCode
HAVING COUNT('Name')>50;

-- For each District in 'IND', find the most populated city (MAX Population).
USE city;
SELECT District , max(Population) as Maxpopby_Dist
FROM city
WHERE CountryCode = 'IND'
GROUP BY District;

-- Display all city Names in uppercase.
SELECT ID, upper(`Name`), CountryCode, District, Population
FROM city;

-- Show each city Name and the length (number of characters) of the name.
SELECT `Name`, length(`Name`) as Length_of_char
FROM city;

-- Show the first 3 characters of each Name (useful for checking data).

SELECT ID, `Name`,CountryCode, left(Name,3) as new_name
FROM city;

-- Show city names with all spaces replaced by underscores '_'.
SELECT *, replace(`Name`," ","_") as New_out
FROM city;
-- Combine Name and CountryCode into one column like: 'Delhi (IND)'.
SELECT *, concat(`Name`, ":",CountryCode) as Concatifo
FROM city;

-- Try adding a new city with a NULL Name — what happens? Write the INSERT and explain why it would fail if NOT NULL is set.
INSERT INTO city (`Name`, CountryCode, District,Population)
VALUE('','LPG','Maharashtra',10);
SELECT *
FROM city
WHERE `Name` =  '';

-- First find its ID
SELECT * FROM city WHERE CountryCode = 'LPG';

-- Then delete using that ID
SET SQL_SAFE_UPDATES = 0;
DELETE FROM city WHERE ID IS NULL;
SET SQL_SAFE_UPDATES = 1;
-- Verify  Bad data is deleted
SELECT * FROM city 
WHERE CountryCode = 'LPG';

-- Write a SELECT to find any cities where Population is NULL (missing data check).
SELECT *
FROM city
WHERE Population is NULL;

-- Find all cities where the Name is NOT NULL and Population is greater than 0.
SELECT *
FROM city
WHERE `Name` IS  NOT NULL AND Population > 0



            