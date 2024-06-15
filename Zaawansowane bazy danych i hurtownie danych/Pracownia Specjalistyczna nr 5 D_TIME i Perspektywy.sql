DROP TABLE D_TIME;

CREATE TABLE D_TIME

(ID_TIME NUMBER(4) PRIMARY KEY, 

ORDERDATE DATE,

DAY_NAME VARCHAR2(13),

WEEK_DAY_NUMBER NUMBER(1),

MONTH_DAY_NUMBER NUMBER(2),

WEEK_NUMBER NUMBER(2),

YEAR_DAY_NUMBER NUMBER(3),

IS_WEEKEND NUMBER(1),

MONTH_NAME VARCHAR2(12),

MONTH_NUMBER NUMBER(2),

QUARTER NUMBER(1),

YEAR NUMBER(4)

);







----------------FUNKCJA F_IS_WEEKEND----------------



CREATE OR REPLACE FUNCTION F_IS_WEEKEND

        (P_ORDERDATE ORDERS.ORDERDATE%TYPE) RETURN NUMBER IS

BEGIN

    IF SUBSTR(TO_CHAR(P_ORDERDATE,'DAY'),1,1)='S' OR

       SUBSTR(TO_CHAR(P_ORDERDATE,'DAY'),1,1)='N' THEN

        RETURN 1;

    END IF;

    RETURN 0;

END;

/



DROP SEQUENCE S_D_TIME;

CREATE SEQUENCE S_D_TIME;

---------------------------------------------------------



DROP VIEW V_ORDER_DATES;

CREATE VIEW V_ORDER_DATES AS

SELECT 

        DISTINCT ORDERDATE,

        TO_CHAR(ORDERDATE,'DAY') DAY_NAME,

        TO_NUMBER(TO_CHAR(ORDERDATE,'D')) WEEK_DAY_NUMBER,

        TO_NUMBER(TO_CHAR(ORDERDATE,'DD')) MONTH_DAY_NUMBER,

        TO_NUMBER(TO_CHAR(ORDERDATE,'WW')) WEEK_NUMBER,

        TO_NUMBER(TO_CHAR(ORDERDATE,'DDD')) YEAR_DAY_NUMBER,

        F_IS_WEEKEND(ORDERDATE) IS_WEEKEND,

        TO_CHAR(ORDERDATE,'MONTH') MONTH_NAME,

        TO_NUMBER(TO_CHAR(ORDERDATE,'MM')) MONTH_NUMBER,

        TO_NUMBER(TO_CHAR(ORDERDATE,'Q')) QUARTER,

        TO_NUMBER(TO_CHAR(ORDERDATE,'YYYY')) YEAR_NUMBER

FROM ORDERS

UNION

SELECT 

        DISTINCT SHIPDATE,

        TO_CHAR(SHIPDATE,'DAY') DAY_NAME,

        TO_NUMBER(TO_CHAR(SHIPDATE,'D')) WEEK_DAY_NUMBER,

        TO_NUMBER(TO_CHAR(SHIPDATE,'DD')) MONTH_DAY_NUMBER,

        TO_NUMBER(TO_CHAR(SHIPDATE,'WW')) WEEK_NUMBER,

        TO_NUMBER(TO_CHAR(SHIPDATE,'DDD')) YEAR_DAY_NUMBER,

        F_IS_WEEKEND(SHIPDATE) IS_WEEKEND,

        TO_CHAR(SHIPDATE,'MONTH') MONTH_NAME,

        TO_NUMBER(TO_CHAR(SHIPDATE,'MM')) MONTH_NUMBER,

        TO_NUMBER(TO_CHAR(SHIPDATE,'Q')) QUARTER,

        TO_NUMBER(TO_CHAR(SHIPDATE,'YYYY')) YEAR_NUMBER

FROM ORDERS

WHERE SHIPDATE IS NOT NULL;

--------------------------------------------------------

CREATE OR REPLACE PROCEDURE P_LOAD_D_TIME IS

BEGIN

    MERGE

    INTO D_TIME T

    USING V_ORDER_DATES V

    ON (T.ORDERDATE=V.ORDERDATE)

    WHEN NOT MATCHED THEN

        INSERT VALUES(

                S_D_TIME.NEXTVAL, 

                V.ORDERDATE,

                V.DAY_NAME,

                V.WEEK_DAY_NUMBER,

                V.MONTH_DAY_NUMBER,

                V.WEEK_NUMBER,

                V.YEAR_DAY_NUMBER,

                V.IS_WEEKEND,

                V.MONTH_NAME,

                V.MONTH_NUMBER,

                V.QUARTER,

                V.YEAR_NUMBER);

END;

/

EXECUTE P_LOAD_D_TIME; 



//// PERSPEKTYWY 



CREATE VIEW V_BOOKS AS SELECT * FROM BOOKS;

CREATE VIEW V_CUSTOMERS AS SELECT * FROM CUSTOMERS;

CREATE VIEW V_PUBLISHER AS SELECT * FROM PUBLISHER;

CREATE VIEW V_TIME AS SELECT * FROM D_TIME;



DROP VIEW V_SALE;

CREATE VIEW V_SALE AS 

        SELECT b.ISBN, p.PUBID, o.CUSTOMER#, ID_TIME, a.authorid, 

        SUM(OI.QUANTITY*B.RETAIL) SALE_AMOUNT, 

        SUM(OI.QUANTITY*(B.RETAIL-B.COST)) PROFIT, 

        SUM(OI.QUANTITY) QUANTITY

        FROM PUBLISHER P 

        JOIN BOOKS B on P.PUBID=B.PUBID 

        JOIN ORDERITEMS OI ON B.ISBN=OI.ISBN 

        JOIN ORDERS O ON OI.ORDER#=O.ORDER# 

        JOIN CUSTOMERS C ON O.CUSTOMER#=C.CUSTOMER# 

        JOIN D_TIME t ON t.ORDERDATE=O.ORDERDATE

JOIN BOOKAUTHOR BA ON BA.ISBN=B.ISBN

JOIN AUTHOR A ON A.AUTHORID=BA.AUTHORID 

        GROUP BY b.ISBN, p.PUBID, o.CUSTOMER#, t.ID_TIME,a.authorid;