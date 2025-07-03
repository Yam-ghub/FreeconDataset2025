CREATE OR REPLACE VIEW base_metrics AS
SELECT
  country,
  product,
  segment,
  discount_band,

  SUM(sales) AS total_sales,
  SUM(gross_sales) AS total_gross_sales,
  SUM(cogs) AS total_cogs,
  SUM(units_sold) AS total_units_sold,
  SUM(profit) AS total_profit,
  SUM(discounts) AS total_discounts,

  AVG(manufacturing_price) AS avg_manufacturing_price,
  AVG(sale_price) AS avg_sale_price
FROM freecon
GROUP BY country, product, segment, discount_band;

-- PROFITABILITY METRICS BY PRODUCT
SELECT 
  product,
  ROUND(SUM(total_profit)::NUMERIC, 2) AS total_profit,
  ROUND((SUM(total_profit) * 100.0 / NULLIF(SUM(total_sales), 0))::NUMERIC, 2) AS profit_margin_pct,
  ROUND(AVG(avg_manufacturing_price)::NUMERIC, 2) AS avg_manufacturing_price
FROM base_metrics
GROUP BY product
ORDER BY total_profit DESC;

--  OPERATIONAL EFFICIENCY BY SEGMENT
SELECT 
  segment,
  SUM(total_cogs) AS total_cogs,
  SUM(total_gross_sales) AS total_gross_sales,
  ROUND((SUM(total_discounts) / NULLIF(SUM(total_gross_sales), 0))::NUMERIC, 2) AS discount_rate
FROM base_metrics
GROUP BY segment
ORDER BY total_cogs, total_gross_sales DESC;

-- DISCOUNT BAND IMPACT
SELECT 
  discount_band,
  ROUND(SUM(total_sales)::NUMERIC, 2) AS total_sales
FROM base_metrics
GROUP BY discount_band
ORDER BY total_sales DESC;

-- UNITS SOLD BY PRODUCT & COUNTRY
SELECT 
  product,
  country,
  SUM(total_units_sold) AS total_units_sold
FROM base_metrics
GROUP BY product, country;

-- Product KPI's
SELECT 
  product,
  ROUND(((SUM(total_sales) - SUM(total_cogs)) / NULLIF(SUM(total_sales), 0))::NUMERIC, 2) AS contribution_margin_pct,
  ROUND((SUM(total_sales) / NULLIF(SUM(total_units_sold), 0))::NUMERIC, 2) AS revenue_per_unit,
  ROUND((SUM(total_gross_sales) - SUM(total_sales))::NUMERIC, 2) AS lost_revenue_to_discount,
  ROUND(SUM(total_profit)::NUMERIC / NULLIF(COUNT(DISTINCT product), 0), 2) AS profit_per_product
FROM base_metrics
GROUP BY product;