/* 
Data Analysis using SQL - Capstone Project
*/


-- Que1. How many sales occurred during this time period? 

-- Solution:

USE nft;
SELECT COUNT(*) FROM cryptopunkdata;

-- There are total 19920 sales occured during this time period.



/* Que2. Return the top 5 most expensive transactions (by USD price) for this data set. 
Return the name, ETH price, and USD price, as well as the date. */

SELECT name, eth_price, usd_price, day 
FROM cryptopunkdata
ORDER BY usd_price DESC
LIMIT 5;



/* 3. Return a table with a row for each transaction with an event column, 
a USD price column, and a moving average of USD price that averages the last 50 transactions.
*/

SELECT event_date, 
	   usd_price, 
       AVG(usd_price) OVER (ORDER BY utc_timestamp ROWS BETWEEN 50 PRECEDING AND CURRENT ROW) AS moving_avg
FROM pricedata;



-- 4. Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.

SELECT name, 
AVG(usd_price) OVER(PARTITION BY name) AS average_price
FROM cryptopunkdata
ORDER BY average_price DESC;

-- OR

SELECT name, 
AVG(usd_price) AS average_price
FROM cryptopunkdata
GROUP BY name
ORDER BY average_price DESC;



/*
5. Return each day of the week and the number of sales that occurred on that day of the week, 
as well as the average price in ETH. Order by the count of transactions in ascending order.
*/

SELECT 
    DAYNAME(p.event_date) AS day_of_week,
    COUNT(*) AS number_of_sales,
    AVG(c.eth_price) AS average_eth_price
FROM cryptopunkdata c
JOIN pricedata p ON c.buyer_address = p.buyer_address 
GROUP BY day_of_week
ORDER BY number_of_sales ASC;



/* 
6. Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, who bought the NFT, 
who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
*/

SELECT *,
CONCAT(name, " was sold for $", ROUND(usd_price, -3), 
		" to ", buyer_address, " from ", seller_address, " on ", DATE(event_date)) AS summary 
FROM pricedata;



/*
7. Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.
*/

CREATE VIEW 1919_purchases AS
SELECT * FROM cryptopunkdata
WHERE buyer_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";



/*
8. Create a histogram of ETH price ranges. Round to the nearest hundred value
*/

SELECT ROUND(eth_price, -2) AS eth_price_ranges,
COUNT(*) AS count,
RPAD('', COUNT(*), '-') AS bar
FROM cryptopunkdata
GROUP BY eth_price_ranges
ORDER BY eth_price_ranges;


/*
9. Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” 
with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. 
The table should have a name column, a price column called price, and a status column. 
Order the result set by the name of the NFT, and the status, in ascending order.  
*/

(SELECT name,
MAX(usd_price) AS price, "highest" AS status
from cryptopunkdata
GROUP BY name
UNION
SELECT name,
MIN(usd_price) AS price, "lowest" AS status
from cryptopunkdata
GROUP BY name)
ORDER BY name ASC, status ASC;


/*
10. What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format.  
*/

SELECT name, 
       MONTH(event_date) AS month, 
       YEAR(event_date) AS year, 
       COUNT(*) AS sales_count, 
       MAX(usd_price) AS max_usd_price
FROM pricedata
GROUP BY name, month, year
ORDER BY year, month;



/*
11. Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).
*/


SELECT YEAR(event_date) AS Year,
MONTH(event_date) AS Month,
ROUND(SUM(usd_price), -2) AS Total_Volume
FROM pricedata
GROUP BY YEAR(event_date),MONTH(event_date)
ORDER BY Year, Month;


/*
12. Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.
*/

SELECT buyer_address, COUNT(*) AS transaction_count 
FROM pricedata
WHERE buyer_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";

-- There are 234 transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.




/*
13. Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
 - Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
 - Take the daily average of remaining transactions.
  a) First create a query that will be used as a subquery. 
  Select the event date, the USD price, and the average USD price for each day using a window function. Save it as a temporary table.
 b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average 
 and return a new estimated value which is just the daily average of the filtered data.
 
*/ 



/* a) */
CREATE TEMPORARY TABLE temp_daily_avg_price AS
SELECT event_date, usd_price,
       AVG(usd_price) OVER (PARTITION BY DATE(event_date)) AS daily_avg_price
FROM pricedata;


/* b) */
SELECT event_date, 
       AVG(usd_price) AS estimated_avg_value
FROM temp_daily_avg_price
WHERE usd_price >= 0.1 * daily_avg_price
GROUP BY event_date;







