/*
Q1: Calculate total visit, pageview, transaction for Jan, Feb and March 2017
(order by month)
*/
SELECT 
format_date("%Y%m", parse_date("%Y%m%d", date)) AS month,
    SUM(totals.visits) AS visits,
    SUM(totals.pageviews) AS pageviews,
    SUM(totals.transactions) AS transactions 
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*` 
WHERE 
_table_suffix BETWEEN '0101' AND '0331'
GROUP BY 1
ORDER BY 1;

-- correct

/*
Q2: Bounce rate per traffic source in July 2017
(Bounce_rate = num_bounce/total_visit)
(order by total_visit)
*/
SELECT  
    trafficSource.source AS source,
    SUM(totals.visits) AS total_visits,
    SUM(totals.bounces) AS total_no_of_bounces,
    (SUM(totals.bounces) / SUM(totals.visits)) * 100 AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY
    source
ORDER BY
    total_visits DESC;

/*
Q3: Revenue by traffic source by week, by month
in June 2017
*/
WITH base_data AS (
  SELECT 
    trafficSource.source AS source
    ,format_date('%Y %m', parse_date('%Y %m %d', date)) as month_id
    ,format_date('%Y %m', parse_date('%Y %m %d', date)) as week_id
    ,p.productRevenue / 1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
  ,UNNEST(hits) AS h
  ,UNNEST(h.product) AS p
  WHERE p.productRevenue IS NOT NULL
)

SELECT
  'Month' AS time_type,
  month_id AS time,
  source,
  SUM(revenue) AS revenue
FROM base_data
GROUP BY 2, 3

UNION ALL

SELECT
  'Week' AS time_type,
  week_id AS time,
  source,
  SUM(revenue) AS revenue
FROM base_data
GROUP BY 2, 3

ORDER BY time_type DESC, time ASC;

-- cách trình bày của a
with 
month_data as(
  SELECT
    "Month" as time_type,
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    trafficSource.source AS source,
    SUM(p.productRevenue)/1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
    unnest(hits) hits,
    unnest(product) p
  WHERE p.productRevenue is not null
  GROUP BY 1,2,3
  order by revenue DESC
),

week_data as(
  SELECT
    "Week" as time_type,
    format_date("%Y%W", parse_date("%Y%m%d", date)) as week,
    trafficSource.source AS source,
    SUM(p.productRevenue)/1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
    unnest(hits) hits,
    unnest(product) p
  WHERE p.productRevenue is not null
  GROUP BY 1,2,3
  order by revenue DESC
)

select * from month_data
union all
select * from week_data;
order by time_type
-- nên order by time_type, để month vs week đc xếp thành các cụm riêng biệt


/*
Q4: Conversion rate by traffic source in 2017
(order by conversion_rate desc)
*/

SELECT  
    trafficSource.source AS source,
    SUM(totals.visits) AS total_visits,
    SUM(totals.transactions) AS total_transactions,
    (SUM(totals.transactions) / SUM(totals.visits)) * 100 AS conversion_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
GROUP BY source
HAVING total_transactions >= 50
ORDER BY conversion_rate DESC;

-- correct

/*
Q5: Average number of pageviews by purchaser type
(purchasers vs non-purchasers) in June, July 2017
*/
WITH user_behavior AS (
  SELECT
    fullVisitorId
    ,MAX(CASE WHEN totals.transactions >= 1
          AND p.productRevenue IS NOT NULL THEN 1 ELSE 0 END) AS is_buyer  
    ,MAX(totals.pageviews) AS session_pageviews
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
,UNNEST(hits) AS h
,UNNEST(h.product) AS p
WHERE _table_suffix between '0601' AND '0731'
GROUP BY fullVisitorId, visitId 
)

SELECT
  CASE 
    WHEN is_buyer = 1 THEN 'Purchaser' 
    ELSE 'Non-purchaser' 
  END AS user_type,
  SUM(session_pageviews) / COUNT(DISTINCT fullVisitorId) AS avg_pageviews
FROM
  user_behavior
GROUP BY
  user_type;

-- thay vì dùng case when, mình có thể tách ra thành các CTE để dễ kiểm soát câu lệnh hơn
-- để hạn chế lỗi logic, lệch số mà k biết lệch ở đâu thì mình nên break nhỏ từng phần theo đặc tính của nó
-- ở đây là purchaser và non_purchaser, rồi check xem outcome của từng phần có hợp lý k

with 
purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      (sum(totals.pageviews)/count(distinct fullvisitorid)) as avg_pageviews_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions>=1
  and product.productRevenue is not null
  group by month
),

non_purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      sum(totals.pageviews)/count(distinct fullvisitorid) as avg_pageviews_non_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions is null
  and product.productRevenue is null
  group by month
)

select
    pd.*,
    avg_pageviews_non_purchase
from purchaser_data pd
full join non_purchaser_data using(month)
order by pd.month;

-- câu 5 này lưu ý là mình nên dùng full join/left join, bởi vì trong câu này, phạm vi chỉ từ tháng 6-7, nên chắc chắc sẽ có pur và nonpur của cả 2 tháng
-- mình inner join thì vô tình nó sẽ ra đúng. nhưng nếu đề bài là 1 khoảng thời gian dài hơn, 2-3 năm chẳng hạn, thì có tháng chỉ có nonpur mà k có pur
-- thì khi đó inner join nó sẽ làm mình bị mất data, thay vì hiện số của nonpur và pur thì nó để trống

/*
Q6: Average number of transactions per user that made a purchase in July 2017
*/
SELECT 
  SUM(totals.transactions) / COUNT(DISTINCT fullVisitorId) AS avg_transaction_process
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
, UNNEST(hits) AS h
, UNNEST(h.product) AS p
WHERE totals.transactions >= 1
    AND p.productRevenue IS NOT NULL;

-- correct

/*
Q7: Revenue contribution by device
(desktop,mobile...) (order by ratio desc)
*/
WITH revenue_by_device AS (
  SELECT
    device.deviceCategory AS device_category
    ,SUM(p.productRevenue / 1000000) AS revenue  
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  ,UNNEST(hits) AS h
  ,UNNEST(h.product) AS p   
  WHERE 
    _table_suffix between '20170101' AND '20171231'
    AND totals.transactions IS NOT NULL
    AND p.productRevenue IS NOT NULL
  GROUP BY 
    device_category
)

SELECT
  device_category,
  revenue,
  (revenue / SUM(revenue) OVER()) * 100 AS ratio
FROM
  revenue_by_device
ORDER BY
  ratio DESC;

-- cách khác, dùng subquery
with 
raw_data as (
  SELECT
    device.deviceCategory AS device
    ,SUM(productRevenue)/1000000 AS revenue_by_device
    ,(SELECT SUM(productRevenue)/1000000 AS total_revenue
      from `bigquery-public-data.google_analytics_sample.ga_sessions_*`
            ,unnest(hits) hits
          ,unnest(product) product
      where totals.transactions>=1
        and product.productRevenue is not null) as total_revenue
  from  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
        ,unnest(hits) hits
      ,unnest(product) product
  where totals.transactions>=1
    and product.productRevenue is not null
  GROUP BY device
  ORDER BY revenue_by_device DESC)

select
  device
  ,revenue_by_device
  ,total_revenue
  ,round(100.00*(revenue_by_device/total_revenue),2) as ratio
from raw_data;

/*
Q8: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley"
in July 2017
Output should show product name and quantity was ordered
*/
WITH purchasers_of_henley AS (
  SELECT DISTINCT
    fullVisitorId
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST(hits) AS h
  ,UNNEST(h.product) AS p
  WHERE
    p.v2ProductName = "Youtube Men's Vintage Henley"
    AND h.eCommerceAction.action_type = '6'
    AND p.productRevenue IS NOT NULL 
)
SELECT
  p.v2ProductName AS other_purchased_products,
  SUM(p.productQuantity) AS quantity
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
  UNNEST(hits) AS h,
  UNNEST(h.product) AS p
JOIN purchasers_of_henley USING (fullVisitorId)
WHERE
  h.eCommerceAction.action_type = '6'
  AND p.productRevenue IS NOT NULL
  AND p.v2ProductName != "YouTube Men's Vintage Henley"
GROUP BY other_purchased_products
ORDER BY quantity DESC;

-- correct
/*
Q10: Calculate revenue by week from May to July 2017 and culmilative revenue
*/
WITH weekly_revenue AS (
  SELECT
    format_date("%G%V", parse_date("%Y%m%d", date)) AS week_id
    ,SUM(p.productRevenue/1000000) AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) As h
    ,UNNEST(h.product) As p 
  WHERE _table_suffix between '0501' AND '0731'
  AND p.productRevenue IS NOT NULL
  GROUP BY 1
)

SELECT
  week_id
  ,revenue 
  ,SUM(revenue) OVER (ORDER BY week_id) AS cumulative_revenue
FROM weekly_revenue
ORDER BY week_id;

-- correct
-- cách trình bày khác
-- Cách Subquery
select
  week
  ,weekly_revenue
  ,sum(weekly_revenue) over(order by week
                           rows between unbounded preceding and current row) as cumulative_revenue
from (
      SELECT
        format_date("%Y-%W", parse_date("%Y%m%d", date)) as week
        ,SUM(p.productRevenue)/1000000 AS weekly_revenue
      FROM
        `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
      unnest(hits) hits,
          unnest(product) p
      WHERE _table_suffix between '0501' and '0731'
      and p.productRevenue is not null
      GROUP BY week
      ORDER BY week)
order by week;

-- Cách CTE
with 
raw_data as ( -- get revenue by week
  SELECT
    format_date("%Y-%W", parse_date("%Y%m%d", date)) as week
    ,SUM(p.productRevenue)/1000000 AS weekly_revenue
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  unnest(hits) hits,
      unnest(product) p
  WHERE _table_suffix between '0501' and '0731'
  and p.productRevenue is not null
  GROUP BY week
  ORDER BY week
)

-- calculate cumulative
select
  week
  ,weekly_revenue
  ,sum(weekly_revenue) over(order by week
                           rows between unbounded preceding and current row) as cumulative_revenue
from raw_data
order by week;


-- good