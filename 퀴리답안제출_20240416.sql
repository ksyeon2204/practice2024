-- (1) FROM절에 넣기 
SELECT A.ASST_NO
       ,B.USE_EMP_NO
       ,C.USE_EMP_NO
  FROM (
		SELECT  ASST_NO
		        ,INST_CD AS INST_CD
		        ,MIN(SEQ_NO) AS MIN_SEQ_NO
		        ,MAX(SEQ_NO) AS MAX_SEQ_NO
		  FROM TCOM024_ASST_USE_D 
		 GROUP BY ASST_NO, INST_CD
		HAVING COUNT(ASST_NO) > 1
		) A
  LEFT OUTER JOIN TCOM024_ASST_USE_D B
    ON A.ASST_NO = B.ASST_NO
   AND A.INST_CD = B.INST_CD
   AND A.MIN_SEQ_NO = B.SEQ_NO
  LEFT OUTER JOIN TCOM024_ASST_USE_D C
    ON A.ASST_NO = C.ASST_NO
   AND A.INST_CD = C.INST_CD
   AND A.MAX_SEQ_NO = C.SEQ_NO
;

-- (2)-1. WHERE절에 넣기 
SELECT  A.ASST_NO
       ,B.USE_EMP_NO
       ,C.USE_EMP_NO
  FROM (
			SELECT SUB_1.ASST_NO
			      ,SUB_1.INST_CD
				   ,MAX(SUB_1.SEQ_NO) AS MAX_SEQ_NO
				   ,MIN(SUB_1.SEQ_NO) AS MIN_SEQ_NO
			  FROM (
				  SELECT SUB.*
				    FROM (
							SELECT  *
									  ,COUNT(ASST_NO) OVER(PARTITION BY ASST_NO,INST_CD) AS CNT
							  FROM TCOM024_ASST_USE_D
							) SUB
					WHERE SUB.CNT > 1	
			        ) SUB_1
			 GROUP BY SUB_1.ASST_NO, SUB_1.INST_CD
		) A
  LEFT OUTER JOIN TCOM024_ASST_USE_D B
    ON A.ASST_NO = B.ASST_NO
   AND A.INST_CD = B.INST_CD
   AND A.MIN_SEQ_NO = B.SEQ_NO
  LEFT OUTER JOIN TCOM024_ASST_USE_D C
    ON A.ASST_NO = C.ASST_NO
   AND A.INST_CD = C.INST_CD
   AND A.MAX_SEQ_NO = C.SEQ_NO
	;
	
-- (2)-2. WHERE절에 넣기 
SELECT  A.ASST_NO
       ,B.USE_EMP_NO
       ,C.USE_EMP_NO
  FROM (
			SELECT ASST_NO
			     , INST_CD
			     , MIN(SEQ_NO) AS MIN_SEQ_NO
			     , MAX(SEQ_NO) AS MAX_SEQ_NO
			FROM TCOM024_ASST_USE_D 
			WHERE ASST_NO IN (
			    SELECT ASST_NO
			    FROM TCOM024_ASST_USE_D 
			    GROUP BY ASST_NO, INST_CD
			    HAVING COUNT(ASST_NO) > 1
			)
			GROUP BY ASST_NO, INST_CD
		) A
  LEFT OUTER JOIN TCOM024_ASST_USE_D B
    ON A.ASST_NO = B.ASST_NO
   AND A.INST_CD = B.INST_CD
   AND A.MIN_SEQ_NO = B.SEQ_NO
  LEFT OUTER JOIN TCOM024_ASST_USE_D C
    ON A.ASST_NO = C.ASST_NO
   AND A.INST_CD = C.INST_CD
   AND A.MAX_SEQ_NO = C.SEQ_NO
   ;

-- (2)-3. WHERE절에 넣기 
SELECT  A.ASST_NO
       ,B.USE_EMP_NO
       ,C.USE_EMP_NO
  FROM (
			SELECT ASST_NO
			     , INST_CD
			     , MIN(SEQ_NO) AS MIN_SEQ_NO
			     , MAX(SEQ_NO) AS MAX_SEQ_NO
			     ,COUNT(ASST_NO) AS CNT
			FROM TCOM024_ASST_USE_D 
			GROUP BY ASST_NO, INST_CD
		) A
  LEFT OUTER JOIN TCOM024_ASST_USE_D B
    ON A.ASST_NO = B.ASST_NO
   AND A.INST_CD = B.INST_CD
   AND A.MIN_SEQ_NO = B.SEQ_NO
  LEFT OUTER JOIN TCOM024_ASST_USE_D C
    ON A.ASST_NO = C.ASST_NO
   AND A.INST_CD = C.INST_CD
   AND A.MAX_SEQ_NO = C.SEQ_NO
WHERE A.CNT > 1
;

-- 
show full PROCESSLIST;

select * from INFORMATION_SCHEMA.PROCESSLIST;

SELECT esc.THREAD_ID, t.processlist_id, esc.SQL_TEXT
  FROM performance_schema.events_statements_current esc
  JOIN performance_schema.threads t 
	 ON t.thread_id = esc.thread_id;
   
SELECT esc.THREAD_ID, t.processlist_id, esc.*
  FROM performance_schema.events_statements_current esc
  JOIN performance_schema.threads t 
	 ON t.thread_id = esc.thread_id;