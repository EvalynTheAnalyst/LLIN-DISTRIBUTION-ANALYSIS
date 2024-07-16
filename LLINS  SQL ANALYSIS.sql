#creating a Database
CREATE DATABASE llin_analysis;

USE llin_analysis;

#creating a table.
CREATE TABLE llin_distribution(
id INT auto_increment primary KEY,
number INT,
location varchar(50),
country VARCHAR(50),
year year,llin_distribution
by_whom varchar(100),
country_code varchar(50))

# Obtaining all the information from the table.
SELECT *
FROM llin_analysis.llin_distribution;

 -- calculate total distribution per country
SELECT 
country,
SUM(number) AS Total_number_of_llin_distribution #calculation of total distribution per country
FROM 
llin_analysis.llin_distribution
GROUP BY country;

# AVERAGE NUMBER OF LLINS DISTRIBUTION IN EACH EVENT.
SELECT 
by_whom,
ROUND(avg(number),2) AS average_num_of_llins_per_event
FROM 
llin_analysis.llin_distribution
GROUP BY by_whom
HAVING avg(number);

#Total distribution per organisation.
SELECT 
by_whom,
sum(number) AS Total_distribution_per_organisation
FROM 
llin_analysis.llin_distribution
GROUP BY by_whom
HAVING sum(number);

#Total distribution per year.
SELECT 
year,
sum(number) AS Total_distribution_per_year
FROM 
llin_analysis.llin_distribution
GROUP BY year;

#HIGHEST AND LOWEST NUMBER OF LLINS DISTRIBUTION
WITH HighLowDistribution AS(
SELECT 
location,
MAX(number) as high,
MIN(number)as low,
RANK()OVER(ORDER BY MAX(number) DESC) AS highest_rank, 
RANK()OVER( ORDER BY MIN(number)) AS lowest_rank
FROM
llin_analysis.llin_distribution
GROUP BY location
)

SELECT 
    location, 
    high AS highest_distribution, 
    low AS lowest_distribution
FROM 
    HighLowDistribution
WHERE 
    highest_rank = 1 OR 
    lowest_rank = 1;


#DETERMINE SIGNIFICANT DIFFERENCE IN THE NUMBER OF LLINS DISTRIBUTED IN DIFFERENT ORGANISATION.

SELECT 
by_whom, 
SUM(number) AS sum_distribution, 
AVG(number) AS avg_distribution,
STDDEV(number) AS stddev_distribution
FROM llin_analysis.llin_distribution
GROUP BY by_whom
order by sum_distribution DESC;

#Identify any outliers or significant spikes in the number of LLINs distributed in specific locations or periods.
-- Step 1: Calculate the sum and average of distributions for each organization
WITH SumAvgDistribution AS (
    SELECT 
        location, 
        SUM(number) AS sum_distribution, 
        AVG(number) AS avg_distribution,
        STDDEV(number) AS stddev_distribution
    FROM 
        llin_analysis.llin_distribution
    GROUP BY 
        location
),

-- Step 2: Calculate the overall mean and standard deviation of distributions
OverallStats AS (
    SELECT 
        AVG(number) AS overall_mean,
        STDDEV(number) AS overall_stddev
    FROM 
        llin_analysis.llin_distribution
),

-- Step 3: Calculate Z-score for each record to identify outliers
#(A z-score measures exactly how many standard deviations above or below the mean a data point is)
ZScores AS (
    SELECT
        l.location,
        l.number,
        (l.number - o.overall_mean) / o.overall_stddev AS z_score
    FROM 
        llin_analysis.llin_distribution l,
        OverallStats o
)

-- Step 4: Select records with Z-score
SELECT
    location,
    number,
    z_score
FROM
    ZScores
ORDER BY
    z_score DESC;






