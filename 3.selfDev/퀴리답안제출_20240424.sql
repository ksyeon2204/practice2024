-- 2024.04.24 (수) 쿼리과제
-- 1번은 자산별 일려번호를 채번하는 쿼리입니다.
SELECT COALESCE(MAX(SEQ_NO)+1, 1) AS SEQ_NO
  FROM TCOM024_ASST_USE_D D 
 WHERE D.ASST_NO = '1';

-- 2번은 직원등급표를 조회하는 쿼리입니다.
--    등급(경력개월수)    |  직원수(합계) | 정규직 | 계약직 | 프리랜서 |
--         > 초급 : ~ 3년이하 
--         > 중급 : ~ 5년이하 
--         > 고급 : ~ 7년이하 
--         > 특급 : 7년초과 ~ 
;
SELECT 
		 C.CD_NM AS '등급'
		 ,SUM(CASE WHEN US1.EMP_NO IS NOT NULL THEN 1 ELSE 0 END) AS '직원수(합계)'
       ,SUM(CASE WHEN US1.USER_TP_CD = '01' THEN 1 ELSE 0 END) AS '정규직'
       ,SUM(CASE WHEN US1.USER_TP_CD = '02' THEN 1 ELSE 0 END) AS '계약직'
       ,SUM(CASE WHEN US1.USER_TP_CD = '03' THEN 1 ELSE 0 END) AS '프리랜서'
  FROM  TCOM002_CODE C
  LEFT OUTER JOIN (
			SELECT US.EMP_NO
			       ,US.INST_CD
			       ,US.USER_TP_CD
			       ,CASE WHEN  US.DIF_MM >= 84 THEN '10'
			             WHEN US.DIF_MM >= 60 AND US.DIF_MM < 84 THEN '20'
			             WHEN US.DIF_MM >= 36 AND US.DIF_MM < 60 THEN '30'
			             ELSE '40'
			         END AS LV_CD
			  FROM(
					SELECT U.EMP_NO
					       ,U.INST_CD
					       ,MAX(U.USER_TP_CD) AS USER_TP_CD
					       ,MAX(IFNULL(PERIOD_DIFF(DATE_FORMAT(NOW(),'%Y%m'), W.WORK_ST_YM),0)) AS DIF_MM
					  FROM TUSR001_USER U
					  LEFT OUTER JOIN TUSR022_WORK_CAREER W
					    ON U.INST_CD = W.INST_CD
					   AND U.EMP_NO = W.EMP_NO
					GROUP BY U.INST_CD, U.EMP_NO
			  ) US
    )US1
   ON US1.LV_CD = C.CD
  AND US1.INST_CD = C.INST_CD
WHERE C.CD_GRP_ID = '025'
 GROUP BY C.CD_NM
;
   
   
SELECT * FROM TUSR001_USER;

					SELECT U.EMP_NO
					       ,U.INST_CD
					       ,MAX(U.USER_TP_CD) AS USER_TP_CD
					       ,MAX(IFNULL(PERIOD_DIFF(DATE_FORMAT(NOW(),'%Y%m'), W.WORK_ST_YM),0)) AS DIF_MM
					  FROM TUSR001_USER U
					  LEFT OUTER JOIN TUSR022_WORK_CAREER W
					    ON U.INST_CD = W.INST_CD
					   AND U.EMP_NO = W.EMP_NO
					GROUP BY U.INST_CD, U.EMP_NO