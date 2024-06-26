-- 2024.04.22 (월) 쿼리문제 답안제출
-- 3문제 모두 공통적으로 INST_CD는 001로 조건에 추가하여 작성했습니다.

-- 2번 문제 자산별 마지막사용이력 은 대상건을  where 절에 넣어서 결과가 나오게끔 -> 총결과건수 (33건)
SELECT M.ASST_NO AS 자산번호
       ,C.CD_NM AS 자산종류
       ,M.SEQ_NO AS SEQ
       ,D.CD_NM AS 자산상태명
       ,U.USER_NM AS 직원명
       ,DEP.DEPT_NM AS 부서명
FROM (
 		SELECT M.ASST_NO AS ASST_NO
		       ,M.INST_CD AS INST_CD
		       ,M.ASST_KND_CD AS ASST_KND_CD
		       ,MAX(M.ASST_STS_CD) AS ASST_STS_CD
		       ,MAX(D.SEQ_NO) AS SEQ_NO
		       ,MAX(D.USE_EMP_NO) AS USE_EMP_NO
		  FROM TCOM023_ASST_AMN_M M 
		  LEFT OUTER JOIN TCOM024_ASST_USE_D D
		    ON M.INST_CD = D.INST_CD
		   AND M.ASST_NO = D.ASST_NO
		 WHERE M.INST_CD = '001'
		 GROUP BY M.ASST_NO, M.INST_CD ,M.ASST_KND_CD
     ) M
 LEFT OUTER JOIN TCOM002_CODE C
    ON M.INST_CD = C.INST_CD
   AND C.CD_GRP_ID = '052'
   AND M.ASST_KND_CD = C.CD
 LEFT OUTER JOIN TCOM002_CODE D
    ON M.INST_CD = D.INST_CD
   AND D.CD_GRP_ID = '053'
   AND M.ASST_STS_CD = D.CD
 LEFT OUTER JOIN TUSR001_USER U
    ON M.INST_CD = U.INST_CD
   AND M.USE_EMP_NO = U.EMP_NO
 LEFT OUTER JOIN TCOM010_EMP_DEPT ED
    ON M.INST_CD = ED.INST_CD
   AND U.EMP_NO = ED.EMP_NO
   AND ED.MAIN_DEPT_YN = 'Y'
 LEFT OUTER JOIN TCOM003_DEPT DEP
    ON M.INST_CD = DEP.INST_CD
   AND ED.DEPT_CD = DEP.DEPT_CD
 ORDER BY M.ASST_NO
 ;

-- 3번 문제 부서별자격증보유현황은 부서별 자격증(3)개가 무조건 나오게끔  -> 총결과건수 (114건(부서(38)))
 SELECT D.INST_CD AS INST_CD
       ,MAX(D.DEPT_NM) AS DEPT_NM
       ,MAX(CO.CD_NM) AS CD_NM
       ,CASE WHEN SUM(C1.EMP_NO) IS NULL THEN 0 ELSE SUM(C1.EMP_NO) END AS '2023(건수)'
       ,CASE WHEN SUM(C2.EMP_NO) IS NULL THEN 0 ELSE SUM(C2.EMP_NO) END AS '2024(건수)'
       ,GROUP_CONCAT(USER1.USER_NM) '2023(이름) - 검증용'
       ,GROUP_CONCAT(USER2.USER_NM) '2024(이름) - 검증용'
  FROM TCOM003_DEPT D
 INNER JOIN TCOM002_CODE CO
    ON CO.CD_GRP_ID = '023'
  LEFT OUTER JOIN TCOM010_EMP_DEPT ED
    ON D.INST_CD = ED.INST_CD
   AND D.DEPT_CD = ED.DEPT_CD
   AND ED.MAIN_DEPT_YN = 'Y'
  LEFT OUTER JOIN TUSR001_USER U
    ON D.INST_CD = U.INST_CD
   AND ED.EMP_NO = U.EMP_NO
  LEFT OUTER JOIN TUSR012_CERT C1
    ON D.INST_CD = C1.INST_CD
   AND CO.CD = C1.CERT_TP_CD
   AND ED.EMP_NO = C1.EMP_NO
   AND SUBSTR(C1.CERT_DT, 1,4) = '2023'
  LEFT OUTER JOIN TUSR012_CERT C2
    ON D.INST_CD = C2.INST_CD
   AND CO.CD = C2.CERT_TP_CD
   AND ED.EMP_NO = C2.EMP_NO
   AND SUBSTR(C2.CERT_DT, 1,4) = '2024'
  LEFT OUTER JOIN TUSR001_USER USER1
    ON USER1.INST_CD = C1.INST_CD
   AND USER1.EMP_NO = C1.EMP_NO
  LEFT OUTER JOIN TUSR001_USER USER2
    ON USER2.INST_CD = C2.INST_CD
   AND USER2.EMP_NO = C2.EMP_NO
  WHERE D.INST_CD = '001' -- 공통적으로 INST_CD = '001'적용 시 36건 출력(WHERE절 주석처리하면 114건 출력)
 GROUP BY D.INST_CD, D.DEPT_CD, CO.CD;
 
 --4번 문제는 자격증은 Y/N으로 휴가는 건수 없으면 NULL이 아니라 0으로 처리. -> 직원별 총건수(45건)
 ;
 SELECT U.USER_NM
       ,MAX(CASE WHEN C.CERT_TP_CD = '01' THEN 'Y' ELSE 'N' END) AS 'CERT_1(정보처리기사)'
       ,MAX(CASE WHEN C.CERT_TP_CD = '02' THEN 'Y' ELSE 'N' END) AS 'CERT_1(정보처리산업기사)'
       ,MAX(CASE WHEN C.CERT_TP_CD = '03' THEN 'Y' ELSE 'N' END) AS 'CERT_1(SQLD)'
       ,IFNULL(UOS.GIVE_OFF_DAYS, 0) AS '부여휴가일수'
       ,IFNULL(UOS.USE_OFF_DAYS,0) AS '휴가사용일수'
  FROM TUSR001_USER U
  LEFT OUTER JOIN TUSR012_CERT C
    ON C.INST_CD = U.INST_CD
	AND C.EMP_NO = U.EMP_NO
  LEFT OUTER JOIN TUSR002_USER_OFF_STATUS UOS
    ON U.INST_CD = UOS.INST_CD
   AND U.EMP_NO = UOS.EMP_NO
	AND UOS.BASE_YY = '2024'	
 WHERE U.INST_CD = '001'
 GROUP BY U.INST_CD, U.USER_NM, UOS.GIVE_OFF_DAYS, UOS.USE_OFF_DAYS;

--------------------------------------------------------------------------------------
-- 안녕하세요, 이사님.
-- 어제 피드백주신 부분 반영한 쿼리 보내드립니다.

-- 2번
SELECT M.ASST_NO AS 자산번호
       ,C.CD_NM AS 자산종류
       ,M.SEQ_NO AS SEQ
       ,D.CD_NM AS 자산상태명
       ,U.USER_NM AS 직원명
       ,DEP.DEPT_NM AS 부서명
FROM (
		SELECT ASST.ASST_NO  AS ASST_NO
		       ,ASST.INST_CD AS INST_CD
		       ,ASST.ASST_KND_CD AS ASST_KND_CD
		       ,D.USE_EMP_NO AS USE_EMP_NO
		       ,D.ASST_STS_CD AS ASST_STS_CD
		       ,D.SEQ_NO AS SEQ_NO
		  FROM (
					SELECT M.ASST_NO AS ASST_NO
					       ,M.INST_CD AS INST_CD
					       ,M.ASST_KND_CD AS ASST_KND_CD
					       ,MAX(D.SEQ_NO) AS SEQ_NO
					FROM TCOM023_ASST_AMN_M M 
					LEFT OUTER JOIN TCOM024_ASST_USE_D D
					ON M.INST_CD = D.INST_CD
				  AND M.ASST_NO = D.ASST_NO
				GROUP BY M.ASST_NO, M.INST_CD, M.ASST_KND_CD
		       ) ASST
		  LEFT OUTER JOIN TCOM024_ASST_USE_D D
		    ON ASST.INST_CD = D.INST_CD
		   AND ASST.ASST_NO = D.ASST_NO
		   AND D.SEQ_NO = ASST.SEQ_NO
		 WHERE ASST.INST_CD = '001'
     ) M
 LEFT OUTER JOIN TCOM002_CODE C
    ON M.INST_CD = C.INST_CD
   AND C.CD_GRP_ID = '052'
   AND M.ASST_KND_CD = C.CD
 LEFT OUTER JOIN TCOM002_CODE D
    ON M.INST_CD = D.INST_CD
   AND D.CD_GRP_ID = '053'
   AND M.ASST_STS_CD = D.CD
 LEFT OUTER JOIN TUSR001_USER U
    ON M.INST_CD = U.INST_CD
   AND M.USE_EMP_NO = U.EMP_NO
 LEFT OUTER JOIN TCOM010_EMP_DEPT ED
    ON M.INST_CD = ED.INST_CD
   AND U.EMP_NO = ED.EMP_NO
   AND ED.MAIN_DEPT_YN = 'Y'
 LEFT OUTER JOIN TCOM003_DEPT DEP
    ON M.INST_CD = DEP.INST_CD
   AND ED.DEPT_CD = DEP.DEPT_CD
 ORDER BY M.ASST_NO
 ;
	
-- 3번 
 SELECT D.INST_CD AS INST_CD
       ,MAX(D.DEPT_NM) AS DEPT_NM
       ,MAX(CO.CD_NM) AS CD_NM
       ,SUM(CASE WHEN SUBSTR(C.CERT_DT, 1,4) = '2023' THEN 1 ELSE 0 END) AS '2023(건수)'
       ,SUM(CASE WHEN SUBSTR(C.CERT_DT, 1,4) = '2024' THEN 1 ELSE 0 END) AS '2024(건수)'
  FROM TCOM003_DEPT D
 INNER JOIN TCOM002_CODE CO
    ON CO.CD_GRP_ID = '023'
  LEFT OUTER JOIN TCOM010_EMP_DEPT ED
    ON D.INST_CD = ED.INST_CD
   AND D.DEPT_CD = ED.DEPT_CD
   AND ED.MAIN_DEPT_YN = 'Y'
  LEFT OUTER JOIN TUSR012_CERT C
    ON D.INST_CD = C.INST_CD
   AND CO.CD = C.CERT_TP_CD
   AND ED.EMP_NO = C.EMP_NO
  WHERE D.INST_CD = '001'
 GROUP BY D.INST_CD, D.DEPT_CD, CO.CD;
 -- 
 
 -- 2번 문제 WHERE절 수정하여 보내드립니다.
SELECT M.ASST_NO AS 자산번호
       ,C.CD_NM AS 자산종류
       ,M.SEQ_NO AS SEQ
       ,D.CD_NM AS 자산상태명
       ,U.USER_NM AS 직원명
       ,DEP.DEPT_NM AS 부서명
FROM (
		SELECT ASST_M.ASST_NO  AS ASST_NO
		       ,ASST_M.INST_CD AS INST_CD
		       ,ASST_M.ASST_KND_CD AS ASST_KND_CD
		       ,ASST_D.USE_EMP_NO AS USE_EMP_NO
		       ,ASST_D.ASST_STS_CD AS ASST_STS_CD
		       ,ASST_D.SEQ_NO AS SEQ_NO
		  FROM TCOM023_ASST_AMN_M ASST_M
		  LEFT OUTER JOIN TCOM024_ASST_USE_D ASST_D
		    ON ASST_D.INST_CD = ASST_M.INST_CD
	      AND ASST_D.ASST_NO = ASST_M.ASST_NO
		 WHERE (ASST_M.ASST_NO, ASST_M.INST_CD, COALESCE(ASST_D.SEQ_NO, -1)) IN (
								 SELECT M.ASST_NO
								        ,M.INST_CD
								        ,MAX(COALESCE(D.SEQ_NO, -1)) AS SEQ_NO
									FROM TCOM023_ASST_AMN_M M 
									LEFT OUTER JOIN TCOM024_ASST_USE_D D
									  ON M.INST_CD = D.INST_CD
								    AND M.ASST_NO = D.ASST_NO
								    WHERE M.INST_CD = '001'
								  GROUP BY M.ASST_NO, M.INST_CD
					)
     ) M
 LEFT OUTER JOIN TCOM002_CODE C
    ON M.INST_CD = C.INST_CD
   AND C.CD_GRP_ID = '052'
   AND M.ASST_KND_CD = C.CD
 LEFT OUTER JOIN TCOM002_CODE D
    ON M.INST_CD = D.INST_CD
   AND D.CD_GRP_ID = '053'
   AND M.ASST_STS_CD = D.CD
 LEFT OUTER JOIN TUSR001_USER U
    ON M.INST_CD = U.INST_CD
   AND M.USE_EMP_NO = U.EMP_NO
 LEFT OUTER JOIN TCOM010_EMP_DEPT ED
    ON M.INST_CD = ED.INST_CD
   AND U.EMP_NO = ED.EMP_NO
   AND ED.MAIN_DEPT_YN = 'Y'
 LEFT OUTER JOIN TCOM003_DEPT DEP
    ON M.INST_CD = DEP.INST_CD
   AND ED.DEPT_CD = DEP.DEPT_CD
 ORDER BY M.ASST_NO
 ;
 