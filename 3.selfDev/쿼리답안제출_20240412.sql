-- (1) 자산 조회
WITH ASST AS (
SELECT  ASST_NO
        ,MIN(SEQ_NO) AS MIN_SEQ_NO
        ,MAX(SEQ_NO) AS MAX_SEQ_NO
  FROM TCOM024_ASST_USE_D D 
 GROUP BY ASST_NO 
HAVING COUNT(ASST_NO) > 1
)
SELECT  A.ASST_NO
       ,(SELECT DA.USE_EMP_NO
          FROM TCOM024_ASST_USE_D DA
         WHERE A.MIN_SEQ_NO = DA.SEQ_NO)  AS FST_EMP_NO
       ,(SELECT DA.USE_EMP_NO
          FROM TCOM024_ASST_USE_D DA
         WHERE A.MAX_SEQ_NO = DA.SEQ_NO) AS CUR_EMP_NO
  FROM ASST A

;

-- (2)부서 테이블 부서직원 테이블, 직원테이블
SELECT E.DEPT_CD
       ,GROUP_CONCAT(E.USER_NM) AS USER_NM
       ,CASE WHEN MAX(E.ER_EMP_NO) IS NULL THEN ''
             ELSE MAX(E.ER_EMP_NO)
              END AS ER_EMP_NO
FROM (
		SELECT ED.DEPT_CD AS DEPT_CD
		       ,ED.EMP_NO AS EMP_NO
		       ,U.USER_NM AS USER_NM
		       ,CASE WHEN U.EMP_NO IS NULL THEN ED.EMP_NO
				       ELSE '' END AS ER_EMP_NO
		  FROM TCOM010_EMP_DEPT ED
		  LEFT OUTER JOIN TUSR001_USER U
		    ON ED.EMP_NO = U.EMP_NO
) E
GROUP BY E.DEPT_CD
;

-- (3) 영업일 계산 
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
SELECT  (SELECT MIN(CAL.baseDt) 
		     FROM CAL
			 WHERE LEFT(CAL_1.baseDt,6) = LEFT(CAL.baseDt,6)
			)AS 연초
		,CASE WHEN (SELECT holYn 
						  FROM CAL
						 WHERE baseDt = DATE_ADD(CAL_1.baseDt, INTERVAL -5 DAY)
						) = 'N' 
				THEN DATE_FORMAT(DATE_ADD(CAL_1.baseDt, INTERVAL -5 DAY), '%Y%m%d')
		 		ELSE (SELECT MIN(CAL.baseDt)
						  FROM CAL CAL
						  LEFT OUTER JOIN HOLIDAY H
						    ON CAL.baseDt = H.baseDtm
						 WHERE DATE_FORMAT(DATE_ADD(CAL_1.baseDt, INTERVAL -5 DAY), '%Y%m%d') > CAL.baseDt
						   AND H.baseDtm IS NULL
						   AND CAL.holYn = 'N'
						 )
		   END AS 5익영업일
		 ,CASE WHEN (SELECT holYn 
						  FROM CAL
						 WHERE baseDt = DATE_ADD(CAL_1.baseDt, INTERVAL -1 DAY)
						) = 'N' 
		       THEN DATE_FORMAT(DATE_ADD(baseDt, INTERVAL -1 DAY), '%Y%m%d')
		 		ELSE (SELECT MIN(CAL.baseDt)
						  FROM CAL CAL
						  LEFT OUTER JOIN HOLIDAY H
						    ON CAL.baseDt = H.baseDtm
						 WHERE DATE_FORMAT(DATE_ADD(CAL_1.baseDt, INTERVAL -1 DAY), '%Y%m%d') > CAL.baseDt
						   AND H.baseDtm IS NULL
						   AND CAL.holYn = 'N'
						 )
		   END AS 전영엽일
		 ,DATE_FORMAT(DATE_ADD(baseDt, INTERVAL -1 DAY), '%Y%m%d') AS 전일
		 ,baseDt AS 기준일
		 ,CASE WHEN CAL_1.holYn = 'N' THEN CAL_1.baseDt
		 		ELSE (SELECT MIN(CAL.baseDt)
						  FROM CAL CAL
						  LEFT OUTER JOIN HOLIDAY H
						    ON CAL.baseDt = H.baseDtm
						 WHERE CAL_1.baseDt < CAL.baseDt
						   AND H.baseDtm IS NULL
						   AND CAL.holYn = 'N'
						 )
		   END AS 현영엽일
		,CASE WHEN CAL_1.holYn = 'N' THEN DATE_FORMAT(DATE_ADD(baseDt, INTERVAL 1 DAY), '%Y%m%d')
		 		ELSE (SELECT MIN(CAL.baseDt)
						  FROM CAL CAL
						  LEFT OUTER JOIN HOLIDAY H
						    ON CAL.baseDt = H.baseDtm
						 WHERE CAL_1.baseDt < CAL.baseDt
						   AND H.baseDtm IS NULL
						   AND CAL.holYn = 'N'
						 )
		   END AS 익영업일 
		,CASE WHEN (SELECT holYn 
						  FROM CAL
						 WHERE baseDt = DATE_ADD(CAL_1.baseDt, INTERVAL 5 DAY)
						) = 'N' 
				THEN DATE_FORMAT(DATE_ADD(CAL_1.baseDt, INTERVAL 5 DAY), '%Y%m%d')
		 		ELSE (SELECT MIN(CAL.baseDt)
						  FROM CAL CAL
						  LEFT OUTER JOIN HOLIDAY H
						    ON CAL.baseDt = H.baseDtm
						 WHERE DATE_FORMAT(DATE_ADD(CAL_1.baseDt, INTERVAL 5 DAY), '%Y%m%d') < CAL.baseDt
						   AND H.baseDtm IS NULL
						   AND CAL.holYn = 'N'
						 )
		   END AS 5익영업일
		, (SELECT MAX(CAL.baseDt) 
		     FROM CAL
			 WHERE LEFT(CAL_1.baseDt,6) = LEFT(CAL.baseDt,6)
			)AS 연말
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
	 )CAL_1
WHERE CAL_1.basedt = '20240110';

SELECT * FROM TCOM005_APPR_M;
SELECT * FROM TCOM006_APPR_D;
SELECT * FROM TUSR001_USER;




