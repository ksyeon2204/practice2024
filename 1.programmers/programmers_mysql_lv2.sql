-- 2024.05.02 (목)
--1. 부모의 형질을 모두 가지는 대장균 찾기
SELECT 
       A.ID
       ,A.GENOTYPE
       ,B.GENOTYPE AS PARENT_GENOTYPE
  FROM ECOLI_DATA A
 INNER JOIN ECOLI_DATA B
    ON A.PARENT_ID = B.ID
 WHERE A.GENOTYPE & B.GENOTYPE = B.GENOTYPE
 ORDER BY A.ID;
 
-- 2.분기별 분화된 대장균의 개체 수 구하기
SELECT CONCAT(QUARTER(DATE_FORMAT(DIFFERENTIATION_DATE, '%Y-%m-%d')), 'Q')  AS QUARTER
       ,COUNT(*) AS ECOLI_COUNT
  FROM ECOLI_DATA
 GROUP BY QUARTER
 ORDER BY QUARTER
 
-- 3. 
 
 
 
 
 
 
 
 









