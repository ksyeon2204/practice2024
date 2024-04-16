-- 2024.04.02 (화) 쿼리문제 풀이 
-- (1)번 문제 
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
	SELECT DATE_FORMAT('20240103', '%Y%m%d') AS baseDtm FROM DUAL
)
SELECT num
       ,baseDt
		 ,dateNm
		 ,holYn
		 ,CASE 
		 		WHEN CAL_1.holYn = 'N' THEN CAL_1.baseDt
		 		ELSE (SELECT MIN(CAL.baseDt)
						  FROM CAL CAL
						  LEFT OUTER JOIN HOLIDAY H
						    ON CAL.baseDt = H.baseDtm
						 WHERE CAL_1.baseDt < CAL.baseDt
						   AND H.baseDtm IS NULL
						   AND CAL.holYn = 'N'
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
	 
-- (2)번 문제 	 
WITH VERI AS (
	SELECT 'APPR_DCD' AS COL ,'001' AS TY_CD ,'같음' AS TY_CD_NM
	  FROM DUAL
	 UNION ALL 
	SELECT 'CURR_APPR_ORD' ,1 ,'이하'
	  FROM DUAL
	 UNION ALL 
	SELECT 'CNTNT' ,NULL ,'유'
	  FROM DUAL
	 UNION ALL 
	SELECT 'APPR_ST_CD' ,'01|02|03' ,'포함'
	  FROM DUAL  
),APPR AS (
	SELECT  APPR_DCD 
	       ,CURR_APPR_ORD 
	       ,CNTNT
	       ,CONVERT(APPR_ST_CD, CHAR(100))  AS APPR_ST_CD
	 FROM TCOM005_APPR_M
	WHERE APPR_NO = '001A202300046'
) 
SELECT V.COL
       ,A.APPR_DCD AS VAL
       ,V.TY_CD AS 대상여부기준
       ,V.TY_CD_NM AS 대상여부판단
       ,CASE WHEN A.APPR_DCD = V.TY_CD THEN 'Y' 
	          ELSE 'N'
	      END AS 검증여부
  FROM VERI V
  INNER JOIN APPR A
     ON V.COL = 'APPR_DCD'
 UNION ALL
 SELECT V.COL
       ,A.CURR_APPR_ORD
       ,V.TY_CD
       ,V.TY_CD_NM
		 ,CASE WHEN A.CURR_APPR_ORD <= V.TY_CD THEN 'Y'
			 	 ELSE 'N'
	      END
  FROM VERI V
 INNER JOIN APPR A
    ON V.COL = 'CURR_APPR_ORD'
 UNION ALL
 SELECT V.COL
       ,A.CNTNT
       ,V.TY_CD
       ,V.TY_CD_NM
		 ,CASE WHEN A.CNTNT IS NOT NULL THEN 'Y'
			 	 ELSE 'N'
	      END
  FROM VERI V
 INNER JOIN APPR A
    ON V.COL = 'CNTNT'
 UNION ALL
 SELECT V.COL
       ,A.APPR_ST_CD
       ,V.TY_CD
       ,V.TY_CD_NM
		 ,CASE WHEN A.APPR_ST_CD IN (01,02,03) THEN 'Y'
			    ELSE 'N'
	      END
  FROM VERI V
 INNER JOIN APPR A
    ON V.COL = 'APPR_ST_CD'    
  ;
  

  
-- (3)번 문제 
  WITH TABLE_INFO AS (
	 SELECT TABLE_NAME  AS tableNm
	 		  ,GROUP_CONCAT(COLUMN_NAME) AS colNm
	 		  ,MAX(COLUMN_KEY) AS colNmPk
	  FROM INFORMATION_SCHEMA.COLUMNS
	 WHERE TABLE_SCHEMA = 'tgsol_db' 
	   AND TABLE_NAME = 'TCOM000_CALENDAR'
	 GROUP BY TABLE_NAME
)
SELECT CONCAT('INSERT INTO', SPACE(1), tableNm,'\n'
              'SELECT',SPACE(1),colNm ,' FROM', SPACE(1), tableNm,SPACE(1),'\n',
				  'WHERE',SPACE(1),colNmPk,'=?') 
       AS SQL_S
  FROM TABLE_INFO;
  
SELECT * FROM TCOM022_EXPENSES;

-- (4)번 문제(심화)  
WITH RECURSIVE DEPT AS (
 		SELECT DEPT_LVL_CD
		       ,DEPT_CD
		       ,DEPT_NM
		       ,convert(CONCAT(DEPT_ORD, DEPT_NM), CHAR(1000)) AS path
		       ,DEPT_ORD AS DEPT_ORD
		  FROM TCOM003_DEPT
		 WHERE INST_CD = '001'
		 UNION ALL 
		SELECT D.DEPT_LVL_CD
		       ,D.DEPT_CD
		       ,CONCAT(SPACE(4 * D.DEPT_LVL_CD),D.DEPT_NM)
		       ,CONCAT(A.path, '-',100 - D.DEPT_ORD, D.DEPT_NM) AS path
		       ,D.DEPT_ORD
		  FROM TCOM003_DEPT D
		 INNER JOIN DEPT A
		    ON D.UPPER_DEPT_CD = A.DEPT_CD	    
)
SELECT *
  FROM DEPT 
  WHERE path LIKE '%투게더%'
 ORDER BY PATH;


