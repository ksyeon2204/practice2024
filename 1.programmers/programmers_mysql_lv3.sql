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

-- 2024.05.17 (금)
-- 2. 대장균의 크기에 따라 분류하기 1
SELECT ID
       ,CASE WHEN SIZE_OF_COLONY <= 100 THEN 'LOW'
             WHEN SIZE_OF_COLONY <= 1000 AND SIZE_OF_COLONY > 100 THEN 'MEDIUM'
             WHEN SIZE_OF_COLONY > 1000 THEN 'HIGH'
             ELSE SIZE_OF_COLONY 
         END AS SIZE
  FROM ECOLI_DATA
 ORDER BY ID; 

-- 3. 대장균들의 자식의 수 구하기
SELECT E1.ID
       ,COUNT(E2.PARENT_ID) AS CHILD_COUNT
  FROM ECOLI_DATA E1
  LEFT OUTER JOIN ECOLI_DATA E2
    ON E1.ID = E2.PARENT_ID
 GROUP BY E1.ID
 ORDER BY E1.ID;

-- 4. 특정 조건을 만족하는 물고기별 수와 최대 길이 구하기
SELECT COUNT(ID) AS FISH_COUNT
       ,MAX(LENGTH) AS MAX_LENGTH
       ,FISH_TYPE
  FROM FISH_INFO
 GROUP BY FISH_TYPE
HAVING AVG(IFNULL(LENGTH, 10)) >= 33
 ORDER BY FISH_TYPE;
 
-- 5. 물고기 종류 별 대어 찾기
SELECT FI.ID
       ,FN.FISH_NAME
       ,FI.LENGTH
  FROM (
        SELECT  FISH_TYPE
               ,MAX(LENGTH) AS LENGTH
          FROM FISH_INFO 
         GROUP BY FISH_TYPE
       ) F
  LEFT OUTER JOIN FISH_INFO FI
    ON F.FISH_TYPE = FI.FISH_TYPE
   AND F.LENGTH = FI.LENGTH
 INNER JOIN FISH_NAME_INFO FN
    ON F.FISH_TYPE = FN.FISH_TYPE
 ORDER BY FI.ID;

-- 6. 부서별 평균 연봉 조회하기
SELECT HE.DEPT_ID
       ,HD.DEPT_NAME_EN
       ,ROUND(AVG(HE.SAL)) AS AVG_SAL
  FROM HR_EMPLOYEES HE
  LEFT OUTER JOIN HR_DEPARTMENT HD
    ON HE.DEPT_ID = HD.DEPT_ID
 GROUP BY HE.DEPT_ID
 ORDER BY AVG_SAL DESC;

-- 2024.05.20 (월)
-- 7.업그레이드 할 수 없는 아이템 구하기
SELECT II.ITEM_ID
       ,II.ITEM_NAME
       ,II.RARITY
  FROM ITEM_INFO II
  LEFT OUTER JOIN ITEM_TREE IT
    ON II.ITEM_ID = IT.PARENT_ITEM_ID
 WHERE IT.PARENT_ITEM_ID IS NULL
 ORDER BY II.ITEM_ID DESC;

-- 8. 조회수가 가장 많은 중고거래 게시판의 첨부파일 조회하기
SELECT CONCAT('/home/grep/src/',F.BOARD_ID,'/',F.FILE_ID,F.FILE_NAME, F.FILE_EXT) AS FILE_PATH
  FROM USED_GOODS_BOARD B
  LEFT OUTER JOIN USED_GOODS_FILE F
    ON B.BOARD_ID = F.BOARD_ID
 WHERE (B.BOARD_ID, B.VIEWS) = (SELECT BOARD_ID
                                       ,MAX(VIEWS) AS MAX_VIEWS
                                  FROM USED_GOODS_BOARD 
                                 GROUP BY BOARD_ID
                                 ORDER BY MAX_VIEWS DESC
                                 LIMIT 1);
                                 
-- 9.조건에 맞는 사용자 정보 조회하기
SELECT U.USER_ID
       ,MAX(U.NICKNAME) AS NICKNAME
       ,MAX(CONCAT(U.CITY, ' ', U.STREET_ADDRESS1, ' ', U.STREET_ADDRESS2)) AS '전체주소'
       ,MAX(CONCAT(SUBSTRING(U.TLNO,1,3),'-',SUBSTRING(U.TLNO,4,4),'-',SUBSTRING(U.TLNO,8,4))) AS '전화번호'
  FROM  USED_GOODS_BOARD B
  LEFT OUTER JOIN USED_GOODS_USER U
    ON U.USER_ID = B.WRITER_ID
 GROUP BY U.USER_ID
HAVING COUNT(B.WRITER_ID) >= 3 
 ORDER BY U.USER_ID DESC;
                                 
-- 10.조건에 맞는 사용자와 총 거래금액 조회하기
SELECT B.WRITER_ID
       ,MAX(U.NICKNAME) AS NICKNAME
       ,SUM(B.PRICE) AS TOTAL_SALES
  FROM USED_GOODS_BOARD B
  LEFT OUTER JOIN USED_GOODS_USER U
    ON B.WRITER_ID = U.USER_ID
 WHERE B.STATUS = 'DONE' 
 GROUP BY WRITER_ID
HAVING TOTAL_SALES >= 700000
 ORDER BY TOTAL_SALES ;
 
-- 11.대여 기록이 존재하는 자동차 리스트 구하기
SELECT H.CAR_ID
  FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY H
  LEFT OUTER JOIN CAR_RENTAL_COMPANY_CAR C
    ON H.CAR_ID = C.CAR_ID
 WHERE C.CAR_TYPE = '세단'
   AND MONTH(H.START_DATE) = '10'
 GROUP BY H.CAR_ID
 ORDER BY H.CAR_ID DESC;
 
-- 12. 자동차 대여 기록에서 대여중 / 대여 가능 여부 구분하기
SELECT C.CAR_ID
       ,CASE WHEN C.AVAILABILITY > 0 THEN '대여중' ELSE '대여 가능' END AS AVAILABILITY
  FROM (
        SELECT CAR_ID
               ,SUM(CASE WHEN '2022-10-16' BETWEEN START_DATE AND END_DATE THEN 1 ELSE 0 END) AS AVAILABILITY
          FROM CAR_RENTAL_COMPANY_RENTAL_HISTORY
         GROUP BY CAR_ID
       ) C
 ORDER BY C.CAR_ID DESC;
 
-- 2024.05.21 (월) 
-- 13.대여 횟수가 많은 자동차들의 월별 대여 횟수 구하기


-- 14.

-- 15.

-- 16.
  
 
 
 
 












