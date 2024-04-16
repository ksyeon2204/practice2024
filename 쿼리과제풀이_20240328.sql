-- 2024.03.29 (금) 쿼리문제 풀이 
-------------------------------------------------------------------------------------------
-- (1)번 문제 
-- 영업일 조회 : No, 기준일자, 요일, 휴일여부, 영업일 조회 
 
DESC TCOM001_CODE_GROUP; -- 공통코드그룹 케이블 
DESC TCOM002_CODE;	-- 공통코드 테이블 

SELECT * FROM TCOM000_CALENDAR;
SELECT * FROM TCOM001_CODE_GROUP;
SELECT * FROM TCOM002_CODE;

SELECT * FROM TCOM002_CODE 
 WHERE CD_GRP_ID IN('009','010'); -- 009(일구분코드), 010(요일구분코드)
 
 -- 캘린더 테이블 조회하는 거 아님 
SELECT CAL.BASE_DT 
		 ,CAL.DATE_DCD	 
		 ,CAL.WEEK_DCD		
		 ,CAL.DATE_NM
		 ,CASE 
		 		WHEN CAL.DATE_DCD = '00' THEN CAL.BASE_DT
		 		ELSE (SELECT CAL1.BASE_DT
						  FROM TCOM000_CALENDAR CAL1    
						 WHERE CAL.BASE_DT < CAL1.BASE_DT 
						   AND CAL1.DATE_DCD = '00'
						 LIMIT 1)
		   END AS BZ_DT		 
  FROM TCOM000_CALENDAR CAL
  WHERE CAL.BASE_DT BETWEEN '20220101' AND '20221231'; 

-- 테이블 생성 후 영업일 조회 
WITH RECURSIVE CAL AS (
SELECT 1 AS num
		 ,DATE_FORMAT('20240101', '%Y%m%d') AS baseDt
		 ,CASE WHEN WEEKDAY(DATE_FORMAT('20240101', '%Y%m%d')) >= 5 THEN 'Y'
		       ELSE 'N'
			END	  AS holYn
 UNION ALL
SELECT num + 1 
	   ,DATE_FORMAT(DATE_ADD(baseDt, INTERVAL 1 DAY), '%Y%m%d')
		,CASE WHEN WEEKDAY(DATE_ADD(baseDt, INTERVAL 1 DAY)) >= 5 THEN 'Y'
		       ELSE 'N'
			END
  FROM CAL
  WHERE baseDt <  STR_TO_DATE('20240101', '%Y%m%d') + INTERVAL 1 YEAR
),
HOLIDAY AS (
	SELECT DATE_FORMAT('20240101', '%Y%m%d') AS baseDtm FROM DUAL
	UNION ALL
	SELECT DATE_FORMAT('20240104', '%Y%m%d') AS baseDtm FROM DUAL
	UNION ALL
	SELECT DATE_FORMAT('20240108', '%Y%m%d') AS baseDtm FROM DUAL
)
SELECT num
       ,baseDt
		 ,dateNm
		 ,holYn
		 ,CASE 
		 		WHEN CAL_1.holYn = 'N' THEN CAL_1.baseDt
		 		ELSE (SELECT CAL.baseDt
						  FROM CAL CAL
						  LEFT OUTER JOIN HOLIDAY H
						    ON CAL.baseDt = H.baseDtm
						 WHERE CAL_1.baseDt < CAL.baseDt
						   AND H.baseDtm IS NULL
						   AND CAL.holYn = 'N'
					    LIMIT 1
						 )
		   END AS bzNm
  FROM (
		SELECT num
				 ,baseDt
				 ,DAYNAME(baseDt) AS dateNm
				 ,WEEKDAY(baseDt)  AS weekNo
				 ,CASE WHEN C.baseDt = H.baseDtm THEN 'Y'
				 		 WHEN WEEKDAY(C.baseDt) >= 5 THEN 'Y'
				       ELSE C.holYn
				   END  AS holYn  
		  FROM CAL C
		  LEFT OUTER JOIN HOLIDAY H
		    ON C.baseDt = H.baseDtm
	 )CAL_1;


-;------------------------------------------------------------------------------------------
-- (2)번 문제 
-- 검증쿼리 : KEY, VAL, 대상여부기준(기준정보), 대상여부판단(포함,이하,유,같음), 대상여부
 -- TCOM005_APPR_M (결재원장)
 ;
SELECT * FROM TCOM005_APPR_M;
SELECT APPR_DCD 
       ,CURR_APPR_ORD 
       ,CNTNT
       ,APPR_ST_CD
  FROM TCOM005_APPR_M
 WHERE APPR_NO = '001A202300046';

-- 이거 아님 ㅎㅎ
SELECT APPR_NO
       ,APPR_DCD 
       ,CURR_APPR_ORD 
       ,CNTNT
       ,APPR_ST_CD
       ,CASE WHEN APPR_DCD = '001' THEN 'Y'
            ELSE 'N'
       END AS apprDcdYn	
		 ,CASE WHEN CURR_APPR_ORD <= 1 THEN 'Y'
		 	    ELSE 'N'
		 END AS currApprDcdYn 
		 ,CASE WHEN CNTNT IS NOT NULL THEN 'Y'
		       ELSE 'N'
		   END AS cntntYn
		 ,CASE WHEN APPR_ST_CD IN('01','02','03') THEN 'Y'
		       ELSE 'N'
		   END AS apprStCdYn
  FROM TCOM005_APPR_M
 WHERE APPR_NO = '001A202300046';
	
-- pivot형으로 조회
WITH APPR AS (
  SELECT  APPR_NO
          ,APPR_DCD 
	       ,CURR_APPR_ORD 
	       ,CNTNT
	       ,APPR_ST_CD
	       ,CASE WHEN APPR_DCD = '001' THEN 'Y'
	            ELSE 'N'
	       END AS apprDcdYn	
			 ,CASE WHEN CURR_APPR_ORD <= 1 THEN 'Y'
			 	    ELSE 'N'
			 END AS currApprDcdYn 
			 ,CASE WHEN CNTNT IS NOT NULL THEN 'Y'
			       ELSE 'N'
			   END AS cntntYn
			 ,CASE WHEN APPR_ST_CD IN('01','02','03') THEN 'Y'
			       ELSE 'N'
			   END AS apprStCdYn
    FROM TCOM005_APPR_M
   WHERE APPR_NO = '001A202300046'
)
SELECT 'APPR_DCD'
       ,APPR_DCD
       ,'같음' AS 대상여부판단
       ,apprDcdYn
  FROM APPR 
 UNION ALL 
 SELECT 'CURR_APPR_ORD'
       ,CURR_APPR_ORD
       ,'이하'
       ,currApprDcdYn
  FROM APPR
 UNION ALL 
 SELECT 'CNTNT'
       ,CNTNT
       ,'유'
       ,cntntYn
  FROM APPR
 UNION ALL 
 SELECT 'APPR_ST_CD'
       ,APPR_ST_CD
       ,'포함'
       ,apprStCdYn
  FROM APPR;
 	
-------------------------------------------------------------------------------------------
-- (3)번 문제  
-- SELECT INSERT 쿼리문 만드는 쿼리 
;
SHOW TABLES;
SELECT COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_SCHEMA = 'tgsol_db' 
   AND TABLE_NAME = 'TCOM000_CALENDAR';

SELECT 
'
INSERT INTO 테이블명(컬럼명 ,....)
 SELECT ~~~~
 WHERE ID = ''
 ' 
  FROM DUAL;


WITH TABLE_INFO AS (
	 SELECT TABLE_NAME  AS tableNm
	        ,'1' AS id
	 		  ,GROUP_CONCAT(COLUMN_NAME) AS colNm
	  FROM INFORMATION_SCHEMA.COLUMNS
	 WHERE TABLE_SCHEMA = 'tgsol_db' 
	   AND TABLE_NAME = 'TCOM000_CALENDAR'
	 GROUP BY TABLE_NAME
)
SELECT CONCAT('INSERT INTO', SPACE(1), tableNm, '(', colNm, ') SELECT * FROM', SPACE(1), tableNm,SPACE(1), 'WHERE ID=',id) 
       AS SQL_S
FROM TABLE_INFO;

  
-------------------------------------------------------------------------------------------
-- (4)번 문제 
-- 부서 하이라크구조로 조회쿼리 
-- DEPT_LVL_CD(부서레벨코드), LVL, DEPT_CD(부서코드), DEPT_NM(부서명), DEPT_ORD(정렬순서)
;
SELECT * FROM TCOM003_DEPT;

WITH RECURSIVE DEPT AS (
		SELECT DEPT_LVL_CD
		       ,'' AS LVL
		       ,DEPT_CD
		       ,DEPT_NM
		       ,convert(DEPT_NM, CHAR(1000)) AS path
		       ,DEPT_ORD
		  FROM TCOM003_DEPT
		 WHERE INST_CD = '001'
		   AND DEPT_LVL_CD = 1
		 UNION ALL 
		SELECT D.DEPT_LVL_CD
		       ,'' AS LVL
		       ,D.DEPT_CD
		       ,D.DEPT_NM
		       ,concat(A.path, '-', D.DEPT_NM) AS path
		       ,D.DEPT_ORD
		  FROM TCOM003_DEPT D
		 INNER JOIN DEPT A
		    ON D.UPPER_DEPT_CD = A.DEPT_CD
)
SELECT *
  FROM DEPT
 ORDER BY path
 ; 

