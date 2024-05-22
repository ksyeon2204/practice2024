-- 2024.05.22 (수)
-- 1.특정 세대의 대장균 찾기 
-- (검증용) 부모세대 ID 확인 쿼리
SELECT E1.ID AS E1_ID
       , E1.PARENT_ID AS E1_PARENT_ID
       , E2.ID AS E2_ID
       , E2.PARENT_ID AS E2_PARENT_ID
       , E3.ID AS E3_ID
       , E3.PARENT_ID AS E3_PARENT_ID
       , E4.ID AS E4_ID
       , E4.PARENT_ID AS E4_PARENT_ID
  FROM ECOLI_DATA E1 -- 1세대
  LEFT OUTER JOIN ECOLI_DATA E2 -- 2세대
    ON E1.PARENT_ID = E2.ID
  LEFT OUTER JOIN ECOLI_DATA E3 -- 3세대
    ON E2.PARENT_ID = E3.ID
  LEFT OUTER JOIN ECOLI_DATA E4 -- 4세대
    ON E3.PARENT_ID = E4.ID;

-- (본문제) 3세대 ID 찾는 쿼리 
SELECT E1.ID AS ID
  FROM ECOLI_DATA E1 -- 1세대
  LEFT OUTER JOIN ECOLI_DATA E2 -- 2세대
    ON E1.PARENT_ID = E2.ID
  LEFT OUTER JOIN ECOLI_DATA E3 -- 3세대
    ON E2.PARENT_ID = E3.ID
 WHERE E3.ID IS NOT NULL 
   AND E3.PARENT_ID IS NULL
 ORDER BY E1.ID;

-- 2. 연간 평가점수에 해당하는 평가 등급 및 성과금 조회하기
SELECT E.EMP_NO
       ,E.EMP_NAME
       ,G.GRADE
       ,CASE WHEN G.GRADE = 'S' THEN E.SAL * 0.2
             WHEN G.GRADE = 'A' THEN E.SAL * 0.15
             WHEN G.GRADE = 'B' THEN E.SAL * 0.1
             ELSE 0
         END AS BONUS   
  FROM HR_EMPLOYEES E -- 직원테이블
  LEFT OUTER JOIN (
        SELECT EMP_NO
               ,AVG(SCORE) AS SCORE
               ,CASE WHEN AVG(SCORE) >= 96 THEN 'S'
                     WHEN AVG(SCORE) >= 90 AND AVG(SCORE) < 96 THEN 'A'
                     WHEN AVG(SCORE) >= 80 AND AVG(SCORE) < 90 THEN 'B'
                     ELSE 'C'
                 END AS GRADE
          FROM HR_GRADE
         GROUP BY EMP_NO
       ) G -- 평가테이블(사원당 반기에 한번씩 연간 2번)
    ON E.EMP_NO = G.EMP_NO
 ORDER BY E.EMP_NO;

-- 3. 언어별 개발자 분류하기
 SELECT DS.GRADE
       ,DS.ID
       ,MAX(DS.EMAIL) AS EMAIL
  FROM (SELECT CASE WHEN S1.NAME IS NOT NULL AND S3.NAME IS NOT NULL  THEN 'A'
                    WHEN S2.NAME IS NOT NULL THEN 'B'
                    WHEN S1.NAME IS NOT NULL AND S3.NAME IS NULL THEN 'C'
                    ELSE NULL
                END AS GRADE 
               ,D.ID 
               ,D.EMAIL
          FROM DEVELOPERS D -- 개발자 테이블
          LEFT OUTER JOIN SKILLCODES S1 -- 스킬테이블1 : Front End
            ON D.SKILL_CODE & S1.CODE > 0
           AND S1.CATEGORY = 'Front End'
          LEFT OUTER JOIN SKILLCODES S2 -- 스킬테이블2 : C#
            ON D.SKILL_CODE & S2.CODE > 0
           AND S2.NAME = 'C#'
          LEFT OUTER JOIN SKILLCODES S3 -- 스킬테이블3 : Python
            ON D.SKILL_CODE & S3.CODE > 0
           AND S3.NAME = 'Python'
       ) DS
 GROUP BY DS.GRADE, DS.ID
HAVING DS.GRADE IS NOT NULL 
 ORDER BY DS.GRADE, DS.ID;

-- 4. FrontEnd 개발자 찾기
SELECT D.ID
       ,MAX(D.EMAIL) AS EMAIL
       ,MAX(D.FIRST_NAME) AS FIRST_NAME
       ,MAX(D.LAST_NAME) AS LAST_NAME
  FROM DEVELOPERS D
 INNER JOIN SKILLCODES S
    ON D.SKILL_CODE & S.CODE > 0
   AND S.CATEGORY = 'Front End' 
 GROUP BY D.ID
 ORDER BY D.ID;

-- 5. 특정 기간동안 대여 가능한 자동차들의 대여비용 구하기 
SELECT C.CAR_ID
       ,C.CAR_TYPE
       ,MAX(ROUND(C.DAILY_FEE * (1 - P.DISCOUNT_RATE/100) * 30)) AS FEE
  FROM CAR_RENTAL_COMPANY_CAR C
  LEFT OUTER JOIN CAR_RENTAL_COMPANY_RENTAL_HISTORY H
    ON C.CAR_ID = H.CAR_ID
   AND H.START_DATE <= '2022-11-30' 
   AND H.END_DATE >= '2022-11-01'
  LEFT OUTER JOIN CAR_RENTAL_COMPANY_DISCOUNT_PLAN P
    ON C.CAR_TYPE = P.CAR_TYPE
 WHERE C.CAR_TYPE IN ('세단','SUV')
   AND P.DURATION_TYPE = '30일 이상' 
   AND H.CAR_ID IS NULL
 GROUP BY  C.CAR_ID, C.CAR_TYPE
HAVING FEE >= 500000 AND FEE < 2000000 
 ORDER BY FEE DESC,C.CAR_TYPE, C.CAR_ID DESC;

-- 6. 자동차 대여 기록 별 대여 금액 구하기
SELECT CHP.HISTORY_ID
      ,ROUND(CHP.DAILY_FEE * (1 - CHP.DISCOUNT_RATE/100) * CHP.DATEDIFF) AS FEE
  FROM (
        SELECT CH.HISTORY_ID
               ,MAX(CH.DAILY_FEE) AS DAILY_FEE
               ,MAX(CH.DATEDIFF) AS DATEDIFF
               ,MAX(CASE WHEN CH.DATEDIFF >= REPLACE(P.DURATION_TYPE,'일 이상','') THEN P.DISCOUNT_RATE 
                         ELSE 0
                    END) AS DISCOUNT_RATE
          FROM (
                SELECT H.HISTORY_ID
                       ,C.CAR_TYPE
                       ,C.DAILY_FEE
                       ,DATEDIFF(H.END_DATE,H.START_DATE) + 1 AS DATEDIFF
                  FROM CAR_RENTAL_COMPANY_CAR C
                 INNER JOIN CAR_RENTAL_COMPANY_RENTAL_HISTORY H
                    ON C.CAR_ID = H.CAR_ID
                   AND C.CAR_TYPE = '트럭' 
               ) CH
          LEFT OUTER JOIN CAR_RENTAL_COMPANY_DISCOUNT_PLAN P
            ON CH.CAR_TYPE = P.CAR_TYPE
         GROUP BY CH.HISTORY_ID
       ) CHP
 ORDER BY FEE DESC, CHP.HISTORY_ID DESC;

-- 7. 저자 별 카테고리 별 매출액 집계하기
SELECT B.AUTHOR_ID
       ,MAX(A.AUTHOR_NAME) AS AUTHOR_NAME
       ,B.CATEGORY 
       ,SUM(BA.SALES * B.PRICE) AS TOTAL_SALES
  FROM BOOK B
 INNER JOIN AUTHOR A
    ON B.AUTHOR_ID = A.AUTHOR_ID
 INNER JOIN BOOK_SALES BA
    ON BA.BOOK_ID = B.BOOK_ID
   AND DATE_FORMAT(BA.SALES_DATE, '%Y-%m') = '2022-01'
 GROUP BY B.AUTHOR_ID, B.CATEGORY
 ORDER BY B.AUTHOR_ID, B.CATEGORY DESC;

----------------------------------------------------------
-- 2024.05.23 (목)
-- 8. 
-- 9. 
-- 10. 

