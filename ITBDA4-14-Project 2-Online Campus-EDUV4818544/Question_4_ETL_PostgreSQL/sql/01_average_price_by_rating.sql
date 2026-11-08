
-- Question 4.3 - SQL investigation 1: price by rating
SELECT
    rating,
    COUNT(*) AS books,
    ROUND(AVG(price_gbp)::numeric, 2) AS avg_price_gbp,
    MIN(price_gbp) AS min_price_gbp,
    MAX(price_gbp) AS max_price_gbp
FROM public.books_etl
GROUP BY rating
ORDER BY rating;
