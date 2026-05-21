//Analysing Depot that generated most profit
SELECT d.depot_name,
SUM (
	s.revenue - s.shipment_cost
) AS total_profit,
ROUND (
	AVG (s.revenue - s.shipment_cost),
	2
) AS avg_profit_per_shipment
FROM shipments s
LEFT JOIN depots d
ON s.depot_id = d.depot_id
GROUP BY d.depot_name
ORDER BY total_profit DESC;

//Ranking Drivers inside each depot
SELECT
	dr.driver_name,
	d.depot_name,
	COUNT(s.shipment_id) AS total_shipments,
	RANK() 
	OVER 
	(
		PARTITION BY d.depot_name
		ORDER BY COUNT(s.shipment_id) DESC
	) AS driver_rank
FROM
	shipments s
JOIN
	drivers dr
ON
	s.driver_id = dr.driver_id
JOIN 
	depots d
ON s.depot_id = d.depot_id
GROUP BY d.depot_name, dr.driver_name
ORDER BY depot_name;


//Checking if longer journeys result to delivery failures
SELECT
	delivery_status,
	COUNT(*) AS shipment_count,
	ROUND (AVG(distance_miles), 2) as avg_distance,
	ROUND (AVG(package_weight_kg), 2) as avg_weight
FROM shipments
GROUP BY delivery_status
ORDER BY avg_distance DESC


//Checking each customers previous shipment revenue along with the difference from the current shipment revenue
SELECT shipment_id, customer_id, revenue, 
LAG(revenue)
OVER (
	PARTITION BY customer_id 
	ORDER BY shipment_date, shipment_id
) as previous_revenue,
revenue - LAG(revenue) 
OVER (
	PARTITION BY customer_id
	ORDER  BY shipment_date, shipment_id) as revenue_difference
FROM shipments;


//Customers with revenue drops with CTE
WITH customer_revenues AS (
	SELECT shipment_id,
		   customer_id,
		   shipment_date,
		   revenue,
		   LAG(revenue) 
		   OVER (
		   		PARTITION BY customer_id
		   		ORDER BY shipment_date
		   ) as previous_revenue
    FROM shipments
)

SELECT * FROM customer_revenues WHERE revenue < previous_revenue


//Adding shipment size column flag with CASE WHEN
SELECT 
	shipment_id,
	package_weight_kg,
CASE WHEN 
	package_weight_kg < 100
THEN
	'Small'
WHEN
	package_weight_kg < 200
THEN
	'Medium'
ELSE
	'Large'
END AS shipment_size
FROM shipments;
	
