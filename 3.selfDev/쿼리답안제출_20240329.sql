-- (1)번 문제 
-- 영업일 조회 : No, 기준일자, 요일, 휴일여부, 영업일 조회 

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
  WHERE baseDt < DATE_FORMAT('20241231', '%Y%m%d')
),
HOLIDAY AS (
	SELECT DATE_FORMAT('20240101', '%Y%m%d') AS baseDtm FROM DUAL
	UNION ALL
	SELECT DATE_FORMAT('20240102', '%Y%m%d') AS baseDtm FROM DUAL
	UNION ALL
	SELECT DATE_FORMAT('20240103', '%Y%m%d') AS baseDtm FROM DUAL
)
SELECT baseDt
		 ,dateNm
		 ,weekNo
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
		SELECT baseDt
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