-------------------------ZADANIE 1,2---------------------------

SELECT *

FROM

(

    SELECT P.NAME PUBLISHER, COUNT(B.ISBN) COUNT,

            RANK() 

                OVER (ORDER BY COUNT(B.ISBN) DESC) RANK,

            DENSE_RANK() 

                OVER (ORDER BY COUNT(B.ISBN) DESC) DENSE_RANK

    FROM BOOKS B JOIN PUBLISHER P ON B.PUBID=P.PUBID

    GROUP BY P.PUBID, P.NAME

) X

WHERE  X.RANK IN (1,2) OR X.DENSE_RANK IN (1,2);

-------------------------ZADANIE 3---------------------------

SELECT C.CITY, SUM(S.QUANTITY) QUANTITY,

        NTILE(4) OVER (ORDER BY SUM(S.QUANTITY)) NTILE

FROM V_CUSTOMERS C JOIN V_SALE S ON C.CUSTOMER#=S.CUSTOMER#

GROUP BY C.CITY;

-------------------------ZADANIE 4---------------------------

SELECT P.NAME, T.YEAR, T.MONTH_NUMBER, SUM(S.PROFIT) PROFIT,

        SUM(SUM(S.PROFIT)) 

        OVER (PARTITION BY P.NAME ORDER BY T.YEAR,T.MONTH_NUMBER

        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) CUM_SUM

FROM V_TIME T JOIN V_SALE S ON T.ID_TIME=S.ID_TIME

        JOIN V_PUBLISHER P ON P.PUBID=S.PUBID

GROUP BY P.NAME, T.YEAR, T.MONTH_NUMBER

ORDER BY 1, 2,3;

-------------------------ZADANIE 5,6---------------------------

SELECT P.NAME, T.YEAR, T.MONTH_NUMBER, SUM(S.PROFIT) PROFIT,

        ROUND(AVG(SUM(S.PROFIT)) 

        OVER (PARTITION BY P.NAME ORDER BY T.YEAR,T.MONTH_NUMBER

        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING),2) MOV_AVG

FROM V_TIME T JOIN V_SALE S ON T.ID_TIME=S.ID_TIME

        JOIN V_PUBLISHER P ON P.PUBID=S.PUBID

GROUP BY P.NAME, T.YEAR, T.MONTH_NUMBER

ORDER BY 1, 2,3;

-------------------------ZADANIE 7---------------------------

SELECT B.CATEGORY, T.MONTH_NAME, SUM(S.QUANTITY) QUANTITY,

        ROUND(AVG(SUM(S.QUANTITY)) 

            OVER (PARTITION BY T.MONTH_NAME),2) AVG

FROM V_BOOKS B JOIN V_SALE S ON B.ISBN=S.ISBN 

        JOIN V_TIME T ON T.ID_TIME=S.ID_TIME

GROUP BY B.CATEGORY, T.MONTH_NAME;

-------------------------ZADANIE 8---------------------------

SELECT P.NAME, SUM(S.PROFIT) PROFIT,

    SUM(S.PROFIT) -  FIRST_VALUE(SUM(S.PROFIT)) 

      OVER (ORDER BY SUM(S.PROFIT) DESC) FIRST,

    SUM(S.PROFIT) - LAST_VALUE(SUM(S.PROFIT)) OVER () LAST

FROM V_SALE S JOIN V_PUBLISHER P ON P.PUBID=S.PUBID

GROUP BY P.NAME

ORDER BY 2 DESC;

-------------------------ZADANIE 9---------------------------

SELECT B.CATEGORY, T.MONTH_NAME, SUM(S.PROFIT) PROFIT,

        ROUND(RATIO_TO_REPORT(SUM(S.PROFIT)) 

                OVER (PARTITION BY T.MONTH_NAME),3)*100 PERCENT

FROM V_BOOKS B JOIN V_SALE S ON B.ISBN=S.ISBN 

        JOIN V_TIME T ON T.ID_TIME=S.ID_TIME

GROUP BY B.CATEGORY, T.MONTH_NAME;

-------------------------ZADANIE 10---------------------------

SELECT *

FROM

(

    SELECT B.CATEGORY, 

            DECODE(TRIM(T.MONTH_NAME),NULL,'SUMMARY',TRIM(T.MONTH_NAME)) MONTH_NAME, 

            SUM(S.PROFIT) PROFIT

    FROM V_BOOKS B JOIN V_SALE S ON B.ISBN=S.ISBN 

            JOIN V_TIME T ON T.ID_TIME=S.ID_TIME

    GROUP BY CUBE(B.CATEGORY, T.MONTH_NAME)

) PIVOT (SUM(PROFIT) FOR 

            MONTH_NAME IN ('MARCH','APRIL','MAY','JUNE', 'SUMMARY'));