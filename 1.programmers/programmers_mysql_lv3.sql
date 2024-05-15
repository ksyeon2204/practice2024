-- 2024.05.14 (화)
-- 1.대장균의 크기에 따라 분류하기 2
-- HINT : PERCENT_RANK로 순위확인
SELECT E.ID
       ,CASE WHEN E.PER < 0.25 THEN 'CRITICAL'
            WHEN E.PER < 0.5 AND E.PER >= 0.25 THEN 'HIGH'
            WHEN E.PER < 0.75 AND E.PER >= 0.5 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS COLONY_NAME  
FROM (SELECT ID
             ,PERCENT_RANK() OVER (ORDER BY SIZE_OF_COLONY DESC) AS PER
        FROM ECOLI_DATA
     ) E
ORDER BY ID; 