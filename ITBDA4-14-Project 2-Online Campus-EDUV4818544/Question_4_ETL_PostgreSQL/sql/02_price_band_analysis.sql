
-- Question 4.3 - SQL investigation 2: compare price bands
SELECT
    price_band,
    COUNT(*) AS books,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating,
    ROUND(AVG(price_gbp)::numeric, 2) AS avg_price_gbp
FROM public.books_etl
GROUP BY price_band
ORDER BY MIN(price_gbp);
