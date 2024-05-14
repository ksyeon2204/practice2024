-- 20240507(금) 김승연 쿼리답안제출
-- 1. 상환스케줄
-- (1) 만기일시 
WITH RECURSIVE SH AS (
	 SELECT 1 AS NUM
	        ,12000000 AS AM
	        ,NOW() AS ST_DT
	        ,DATE_ADD(NOW(), INTERVAL 1 MONTH) AS ED_DT
			  ,12 AS MM
			  ,0.05 AS INST
		FROM DUAL	
	  UNION ALL 
	 SELECT NUM + 1
	        ,AM
	        ,DATE_ADD(ST_DT, INTERVAL 1 MONTH) AS ST_DT
	        ,DATE_ADD(ST_DT, INTERVAL 2 MONTH) AS ED_DT
	        ,MM
	        ,INST
	   FROM SH
	  WHERE NUM < MM   
)
SELECT NUM AS '회차'
       ,AM AS '대상금액'
       ,DATE_FORMAT(ST_DT,'%Y-%m-%d') AS '시작일자'
       ,DATE_FORMAT(ED_DT,'%Y-%m-%d')  AS '종료일자'
       ,DATEDIFF(ED_DT,ST_DT) AS '일수'
       ,INST AS '이율'
       ,ROUND(AM * INST * DATEDIFF(ED_DT,ST_DT)/365) AS '이자'
       ,CASE WHEN NUM = MM THEN AM 
             WHEN NUM <> MM THEN 0
				 ELSE 0
			END AS '원금'
  FROM SH;

-- (2) 원금균등 
WITH RECURSIVE SH AS (
	 SELECT 1 AS NUM
	        ,12000000 AS AM
	        ,800000 AS PR
	        ,NOW() AS ST_DT
	        ,DATE_ADD(NOW(), INTERVAL 1 MONTH) AS ED_DT
			  ,12 AS MM
			  ,0.05 AS INST
		FROM DUAL	
	  UNION ALL 
	 SELECT NUM + 1
	        ,CASE WHEN AM < PR THEN 0 ELSE AM-PR END AS AM
	        ,PR
	        ,DATE_ADD(ST_DT, INTERVAL 1 MONTH) AS ST_DT
	        ,DATE_ADD(ST_DT, INTERVAL 2 MONTH) AS ED_DT
	        ,MM
	        ,INST
	   FROM SH
	  WHERE NUM < MM   
)
SELECT NUM AS '회차'
       ,AM AS '대상금액'
       ,DATE_FORMAT(ST_DT,'%Y-%m-%d') AS '시작일자'
       ,DATE_FORMAT(ED_DT,'%Y-%m-%d')  AS '종료일자'
       ,DATEDIFF(ED_DT,ST_DT) AS '일수'
       ,INST AS '이율'
       ,ROUND(AM * INST * DATEDIFF(ED_DT,ST_DT)/365) AS '이자'
       ,CASE WHEN AM < PR  THEN AM
             WHEN NUM = MM AND AM > PR THEN AM
		       ELSE PR
			END  AS '원금'
  FROM SH;

-- 2024.05.07 (금) 
-- (1) PAY_CD이 '01' (만기일시) OR '02'(원금균등) 상환스케줄 쿼리
WITH RECURSIVE SH AS (
	 SELECT 1 AS NUM
	        ,12000000 AS AM
	        ,1000000 AS PR
	        ,NOW() AS ST_DT
	        ,DATE_ADD(NOW(), INTERVAL 1 MONTH) AS ED_DT
			  ,12 AS MM
			  ,0.05 AS INST
			  ,'02' AS PAY_CD
		FROM DUAL	
	  UNION ALL 
	 SELECT NUM + 1
	        ,AM
	        ,PR
	        ,DATE_ADD(ST_DT, INTERVAL 1 MONTH) AS ST_DT
	        ,DATE_ADD(ST_DT, INTERVAL 2 MONTH) AS ED_DT
	        ,MM
	        ,INST
	        ,PAY_CD
	   FROM SH
	  WHERE NUM < MM   
)
SELECT NUM AS '회차'
       ,AM AS '대상금액'
       ,ST_DT AS '시작일자'
       ,ED_DT  AS '종료일자'
       ,DIF_DT AS '일수'
       ,INST AS '이율'
       ,ROUND(AM * INST * DIF_DT/365,0) AS '이자'
       ,CASE WHEN PAY_CD = '01' AND NUM < MM THEN 0
             WHEN PAY_CD = '01' AND NUM = MM THEN AM
		       WHEN PAY_CD = '02' AND AM < PR  THEN AM
             WHEN PAY_CD = '02' AND NUM = MM AND AM > PR THEN AM
		       ELSE PR
			END  AS '원금'
  FROM (
  		 SELECT NUM 
		        ,CASE WHEN PAY_CD = '01' THEN AM
				       WHEN PAY_CD = '02' AND AM -PR * (NUM-1) >= 0  THEN AM- PR * (NUM-1)   
				       WHEN PAY_CD = '02' AND AM -PR * (NUM-1) < 0 THEN 0
						 ELSE 0  
					END AS AM
					,DATE_FORMAT(ST_DT,'%Y-%m-%d') AS ST_DT
					,DATE_FORMAT(ED_DT,'%Y-%m-%d') AS ED_DT
					,DATEDIFF(ED_DT,ST_DT) AS DIF_DT
					,INST
					,PR
					,PAY_CD
					,MM
    FROM SH
  )SH;

--2. 부서별 프로젝트 단위로 매출,금액 0원 처리
;
SELECT D.INST_CD
       ,D.DEPT_NM
       ,SUM(CASE WHEN P.PJ_CD = '002P202300001' THEN US.COST ELSE 0 END) AS '㈜KEB하나은행 기업조기경보시스템 개선사업 참여' 
  		 ,SUM(CASE WHEN P.PJ_CD = '001P202400026' THEN US.COST ELSE 0 END) AS '관리자가아니고PM이 아닌 등록테스트'
  		 ,SUM(CASE WHEN P.PJ_CD = '001P202400018' THEN US.COST ELSE 0 END) AS '식대포인트TEST'
  		 ,SUM(CASE WHEN P.PJ_CD = '001P202300036' THEN US.COST ELSE 0 END) AS '공백프로젝트'
  		 ,SUM(CASE WHEN P.PJ_CD = '001P202300035' THEN US.COST ELSE 0 END) AS '202312프로젝트'
  		 ,SUM(CASE WHEN P.PJ_CD = '001P202300006' THEN US.COST ELSE 0 END) AS '테스트 프로젝트 등록'
  		 ,SUM(CASE WHEN P.PJ_CD = '001P202300004' THEN US.COST ELSE 0 END) AS '사내 인트라넷 개발'
  FROM TPJT002_PROJECT_MANPOWER PM
 INNER JOIN TPJT001_PROJECT P
    ON PM.INST_CD = P.INST_CD
   AND PM.PJ_CD = P.PJ_CD 
 INNER JOIN (SELECT US.EMP_NO
                    ,US.DEPT_CD
				        ,US.INST_CD
				        ,CASE WHEN  US.DIF_MM >= 84 THEN 10000000
				              WHEN US.DIF_MM >= 60 AND US.DIF_MM < 84 THEN 8000000
				              WHEN US.DIF_MM >= 36 AND US.DIF_MM < 60 THEN 6000000
				              ELSE 4000000
				          END AS COST
				  FROM(
						SELECT ED.EMP_NO
						       ,ED.DEPT_CD
						       ,W.INST_CD
						       ,MAX(IFNULL(PERIOD_DIFF(DATE_FORMAT(NOW(),'%Y%m'), W.WORK_ST_YM),0)) AS DIF_MM
						  FROM TCOM010_EMP_DEPT ED
						  LEFT OUTER JOIN TUSR022_WORK_CAREER W
						    ON ED.INST_CD = W.INST_CD
						   AND ED.EMP_NO = W.EMP_NO
						 WHERE ED.MAIN_DEPT_YN = 'Y'	 
						 GROUP BY W.INST_CD,ED.DEPT_CD, ED.EMP_NO
				  ) US
       ) US      
    ON PM.INST_CD = US.INST_CD 
   AND PM.EMP_NO = US.EMP_NO 
 RIGHT OUTER JOIN TCOM003_DEPT D
    ON PM.INST_CD = D.INST_CD
   AND US.DEPT_CD = D.DEPT_CD
 WHERE D.INST_CD = '001'
 GROUP BY D.INST_CD, D.DEPT_NM;

