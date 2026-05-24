-- ============================================================
-- USER EVENT FUNNEL ANALYSIS PROJECT
-- Database: user_events_project
-- Author: Siddheshwar Sakhare
-- Description: Full funnel analysis including conversion rates,
--              traffic source breakdown, journey timing & revenue
-- ============================================================

USE user_events_project;

-- ============================================================
-- SECTION 1: DATA EXPLORATION
-- ============================================================

-- Preview all records
SELECT * FROM user_events LIMIT 100;

-- Check distinct event types to understand the funnel steps
SELECT DISTINCT event_type FROM user_events;

-- Check date range of available data
SELECT 
    MIN(event_date) AS earliest_event,
    MAX(event_date) AS latest_event,
    COUNT(*) AS total_records,
    COUNT(DISTINCT user_id) AS unique_users
FROM user_events;


-- ============================================================
-- SECTION 2: FUNNEL STAGE COUNTS (January 2026)
-- ============================================================

WITH funnel_stages AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN event_type = 'page_view'      THEN user_id END) AS stage_1_views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'    THEN user_id END) AS stage_2_carts,
        COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
        COUNT(DISTINCT CASE WHEN event_type = 'payment_info'   THEN user_id END) AS stage_4_payment,  
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'       THEN user_id END) AS stage_5_purchase 
    FROM user_events
    WHERE event_date >= DATE_SUB(DATE '2026-02-01', INTERVAL 30 DAY)
)
SELECT * FROM funnel_stages;

-- Insight: For January 2026 - total viewers: 4,603 | total purchasers: 760 (16.5% overall conversion)


-- ============================================================
-- SECTION 3: CONVERSION RATE ANALYSIS (Step-by-Step)
-- ============================================================

WITH funnel_stages AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN event_type = 'page_view'      THEN user_id END) AS stage_1_views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'    THEN user_id END) AS stage_2_carts,
        COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
        COUNT(DISTINCT CASE WHEN event_type = 'payment_info'   THEN user_id END) AS stage_4_payment,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'       THEN user_id END) AS stage_5_purchase
    FROM user_events
    WHERE event_date >= DATE_SUB(DATE '2026-02-01', INTERVAL 30 DAY)
)
SELECT 
    stage_1_views,
    stage_2_carts,
    ROUND(stage_2_carts * 100.0 / stage_1_views, 2)       AS pct_views_to_cart,
    stage_3_checkout,
    ROUND(stage_3_checkout * 100.0 / stage_2_carts, 2)    AS pct_cart_to_checkout,
    stage_4_payment,
    ROUND(stage_4_payment * 100.0 / stage_3_checkout, 2)  AS pct_checkout_to_payment,
    stage_5_purchase,
    ROUND(stage_5_purchase * 100.0 / stage_4_payment, 2)  AS pct_payment_to_purchase,
    ROUND(stage_5_purchase * 100.0 / stage_1_views, 2)    AS pct_overall_conversion
FROM funnel_stages;

-- Insights:
--   View → Cart:           ~31%  (large drop-off, investigate product pages)
--   Cart → Checkout:       ~71%
--   Checkout → Payment:    ~81%
--   Payment → Purchase:    ~91%  (very strong, intent confirmed)
--   Overall Conversion:    ~16.5%


-- ============================================================
-- SECTION 4: FUNNEL BY TRAFFIC SOURCE
-- ============================================================

WITH funnel_by_source AS (
    SELECT
        traffic_source,
        COUNT(DISTINCT CASE WHEN event_type = 'page_view'      THEN user_id END) AS views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'    THEN user_id END) AS carts,
        COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS checkout,
        COUNT(DISTINCT CASE WHEN event_type = 'payment_info'   THEN user_id END) AS payment,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'       THEN user_id END) AS purchase
    FROM user_events
    WHERE event_date >= DATE_SUB(DATE '2026-02-01', INTERVAL 30 DAY)
    GROUP BY traffic_source
)
SELECT 
    traffic_source,
    views,
    carts,
    checkout,
    payment,
    purchase,
    ROUND(purchase * 100.0 / NULLIF(views, 0), 2) AS pct_overall_conversion
FROM funnel_by_source
ORDER BY pct_overall_conversion DESC;
-- Insights (January 2026):
--   Email:    ~34% conversion  (highest - highly targeted audience)
--   Paid Ads: ~21% conversion
--   Organic:  ~17% conversion
--   Social:   ~6.5%  conversion  (lowest - top of funnel, awareness channel)


-- ============================================================
-- SECTION 5: USER JOURNEY TIMING ANALYSIS
-- (Only users who completed a purchase)
-- ============================================================

WITH funnel_by_date AS (
    SELECT
        user_id,
        MIN(CASE WHEN event_type = 'page_view'      THEN event_date END) AS view_time,
        MIN(CASE WHEN event_type = 'add_to_cart'    THEN event_date END) AS cart_time,
        MIN(CASE WHEN event_type = 'checkout_start' THEN event_date END) AS checkout_time,
        MIN(CASE WHEN event_type = 'payment_info'   THEN event_date END) AS payment_time,
        MIN(CASE WHEN event_type = 'purchase'       THEN event_date END) AS purchase_time
    FROM user_events
    WHERE event_date >= DATE_SUB(DATE '2026-01-01', INTERVAL 30 DAY)
    GROUP BY user_id
    HAVING purchase_time IS NOT NULL -- SUGGESTION: Cleaner HAVING clause using alias
)
SELECT 
    COUNT(*) AS converted_users,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, view_time, cart_time)), 2)         AS avg_view_to_cart_mins,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, cart_time, checkout_time)), 2)     AS avg_cart_to_checkout_mins,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, checkout_time, payment_time)), 2)  AS avg_checkout_to_payment_mins,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, payment_time, purchase_time)), 2)  AS avg_payment_to_purchase_mins,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, view_time, purchase_time)), 2)     AS avg_total_journey_mins
FROM funnel_by_date;

-- Insights:
--   View → Cart:           ~11.16 mins
--   Cart → Checkout:       ~5.37 mins
--   Checkout → Payment:    ~5.06
--   Total Journey:         ~24.63 mins 


-- ============================================================
-- SECTION 6: REVENUE FUNNEL ANALYSIS BY TRAFFIC SOURCE
-- ============================================================

WITH funnel_revenue AS (
    SELECT 
        traffic_source,
        COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END)   AS total_viewers,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'  THEN user_id END)   AS total_buyers,
        SUM(CASE WHEN event_type = 'purchase' THEN amount END)                AS total_revenue,
        COUNT(CASE WHEN event_type = 'purchase' THEN 1 END)                   AS total_orders
    FROM user_events 
    WHERE event_date >= DATE_SUB(DATE '2026-01-01', INTERVAL 30 DAY)
    GROUP BY traffic_source
)
SELECT 
    traffic_source,
    total_viewers,
    total_buyers,
    ROUND(total_revenue, 2)                                                    AS total_revenue,
    total_orders,
    ROUND(total_revenue / NULLIF(total_orders, 0), 2)                         AS avg_order_value,       
    ROUND(total_revenue / NULLIF(total_viewers, 0), 2)                        AS avg_revenue_per_viewer, 
    ROUND(total_buyers * 100.0 / NULLIF(total_viewers, 0), 2)                 AS conversion_rate_pct
FROM funnel_revenue
ORDER BY total_revenue DESC;

-- Insights:
--   Total Revenue (Dec 2025): $87,975.10
--   Avg Revenue per Viewer:   $17.59


-- ============================================================
-- SECTION 7 (BONUS): DROP-OFF ANALYSIS
-- ============================================================

WITH funnel_stages AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN event_type = 'page_view'      THEN user_id END) AS stage_1_views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart'    THEN user_id END) AS stage_2_carts,
        COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
        COUNT(DISTINCT CASE WHEN event_type = 'payment_info'   THEN user_id END) AS stage_4_payment,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase'       THEN user_id END) AS stage_5_purchase
    FROM user_events
    WHERE event_date >= DATE_SUB(DATE '2026-01-01', INTERVAL 30 DAY)
)
SELECT
    'View → Cart'         AS funnel_step,
    stage_1_views - stage_2_carts                                   AS users_dropped,
    ROUND((stage_1_views - stage_2_carts) * 100.0 / stage_1_views, 2) AS pct_dropped
FROM funnel_stages
UNION ALL
SELECT 'Cart → Checkout',
    stage_2_carts - stage_3_checkout,
    ROUND((stage_2_carts - stage_3_checkout) * 100.0 / stage_2_carts, 2)
FROM funnel_stages
UNION ALL
SELECT 'Checkout → Payment',
    stage_3_checkout - stage_4_payment,
    ROUND((stage_3_checkout - stage_4_payment) * 100.0 / stage_3_checkout, 2)
FROM funnel_stages
UNION ALL
SELECT 'Payment → Purchase',
    stage_4_payment - stage_5_purchase,
    ROUND((stage_4_payment - stage_5_purchase) * 100.0 / stage_4_payment, 2)
FROM funnel_stages;

-- ============================================================
-- SECTION 8 (BONUS): COHORT - RETURNING vs NEW BUYERS
-- Identifies repeat purchase behavior
-- ============================================================

SELECT
    user_id,
    
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS purchase_count,
    CASE 
        WHEN COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) = 1 THEN 'New Buyer'
        WHEN COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) > 1 THEN 'Repeat Buyer'
    END AS buyer_type
FROM user_events
WHERE event_date >= DATE_SUB(DATE '2026-01-01', INTERVAL 30 DAY)
GROUP BY user_id
HAVING purchase_count > 0
ORDER BY purchase_count DESC;

-- Insights - Every Buyer is a New buyer no repeated buyer is present