DROP PROCEDURE IF EXISTS SP_KYC_PROCESS_CUSTOMER;
DROP FUNCTION IF EXISTS SP_KYC_GET_ID_CUSTOMER;

-- SP_KYC_GET_ID_CUSTOMER
CREATE OR REPLACE FUNCTION SP_KYC_GET_ID_CUSTOMER(
P_FIRST_NAME VARCHAR,
P_SECOND_NAME VARCHAR,
P_LAST_NAME VARCHAR,
P_SECOND_LAST_NAME VARCHAR,
P_RFC VARCHAR
)
RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE
    ID_CUSTOMER integer;
BEGIN

    SELECT ID INTO ID_CUSTOMER FROM KYC_CUSTOMER
    WHERE FIRST_NAME = UPPER(P_FIRST_NAME)
    AND COALESCE(SECOND_NAME,'') = COALESCE(UPPER(P_SECOND_NAME),'')
    AND LAST_NAME = UPPER(P_LAST_NAME)
    AND SECOND_LAST_NAME = COALESCE(UPPER(P_SECOND_LAST_NAME),'')
    AND RFC LIKE ('%' || P_RFC || '%');

    IF NOT found THEN
        ID_CUSTOMER = 0;
    END IF;
    RETURN ID_CUSTOMER;

END; $$

-- SP_KYC_PROCESS_CUSTOMER
CREATE OR REPLACE PROCEDURE SP_KYC_PROCESS_CUSTOMER(
OPERATION INTEGER,
P_ID_CUSTOMER INTEGER,
P_FIRST_NAME VARCHAR,
P_SECOND_NAME VARCHAR,
P_LAST_NAME VARCHAR,
P_SECOND_LAST_NAME VARCHAR,
P_RFC VARCHAR,
P_AGE VARCHAR,
P_HOME_PHONE VARCHAR,
P_CELL_PHONE VARCHAR,
P_EMAIL VARCHAR,
P_ACTIVE BOOLEAN,
P_STREET VARCHAR,
P_STREET_NUMBER VARCHAR,
P_POSTAL_CODE VARCHAR,
P_ID_NEIGHBORHOOD INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    V_ID_CUSTOMER INTEGER;
    NEW_ID_CUSTOMER INTEGER;
    V_FIRST_NAME VARCHAR;
    V_SECOND_NAME VARCHAR;
    V_LAST_NAME VARCHAR;
    V_SECOND_LAST_NAME VARCHAR;
    V_RFC VARCHAR;
    V_AGE VARCHAR;
    V_HOME_PHONE VARCHAR;
    V_CELL_PHONE VARCHAR;
    V_EMAIL VARCHAR;
    V_ACTIVE BOOLEAN;
    V_STREET VARCHAR;
    V_STREET_NUMBER VARCHAR;
    V_POSTAL_CODE VARCHAR;
    V_ID_NEIGHBORHOOD INTEGER;
    V_UPDATE_CUSTOMER TEXT;
    V_UPDATE_CUSTOMER_ADDRESS TEXT;

BEGIN

    P_FIRST_NAME = UPPER(P_FIRST_NAME);
    P_SECOND_NAME = UPPER(P_SECOND_NAME);
    P_LAST_NAME = UPPER(P_LAST_NAME);
    P_SECOND_LAST_NAME = UPPER(P_SECOND_LAST_NAME);
    P_STREET = UPPER(P_STREET);
    P_STREET_NUMBER = UPPER(P_STREET_NUMBER);

    IF OPERATION IS NULL THEN

        RAISE EXCEPTION 'IT MUST SPECIFIC A OPERATION VALUE INSERT(0), UPDATE(1), LOGICAL DELETE(2), PHYSICAL DELETE(3)';

    ELSEIF (OPERATION = 0) THEN

        SELECT SP_KYC_GET_ID_CUSTOMER(P_FIRST_NAME,P_SECOND_NAME,P_LAST_NAME,P_SECOND_LAST_NAME,P_RFC) INTO V_ID_CUSTOMER;

    ELSE
        V_ID_CUSTOMER = P_ID_CUSTOMER;
    END IF;

    IF OPERATION = 0 AND V_ID_CUSTOMER <> 0 THEN

        RAISE EXCEPTION 'CANNOT CREATE NEW CUSTOMER WITH THIS INFO BECAUSE ALREADY EXISTS A CUSTOMER WITH THIS INFO AND ID=%',V_ID_CUSTOMER;

    END IF;

    IF (OPERATION = 2 OR OPERATION = 3)  AND
        NOT EXISTS(SELECT C.ID FROM KYC_CUSTOMER C WHERE C.ID=P_ID_CUSTOMER) THEN

        RAISE EXCEPTION 'CANNOT EXECUTE THIS OPERATION BECAUSE THE CUSTOMER DOES NOT EXISTS';

    END IF;

    IF OPERATION = 1 and V_ID_CUSTOMER = 0 THEN
        OPERATION = 0;
    END IF;

    IF OPERATION = 0 THEN

        INSERT INTO KYC_CUSTOMER (FIRST_NAME,SECOND_NAME,LAST_NAME,SECOND_LAST_NAME,RFC,AGE,HOME_PHONE,CELL_PHONE,EMAIL,ACTIVE,DATE_CREATED,DATE_MODIFIED)
            VALUES(P_FIRST_NAME,P_SECOND_NAME,P_LAST_NAME,P_SECOND_LAST_NAME,
            P_RFC,P_AGE,P_HOME_PHONE,P_CELL_PHONE,P_EMAIL,P_ACTIVE,CURRENT_DATE,NULL);
        SELECT MAX(ID) INTO NEW_ID_CUSTOMER FROM KYC_CUSTOMER WHERE RFC = P_RFC;
        INSERT INTO KYC_CUSTOMER_ADDRESS VALUES(NEW_ID_CUSTOMER,P_STREET,P_STREET_NUMBER,P_POSTAL_CODE,P_ID_NEIGHBORHOOD,CURRENT_DATE,NULL);
        COMMIT;

    ELSIF OPERATION = 1 THEN

        SELECT C.FIRST_NAME,C.SECOND_NAME,C.LAST_NAME,C.SECOND_LAST_NAME,C.RFC,C.AGE,EMAIL,C.HOME_PHONE,C.CELL_PHONE,C.ACTIVE,
        A.STREET,A.STREET_NUMBER,A.POSTAL_CODE, A.ID_NEIGHBORHOOD
        INTO V_FIRST_NAME,V_SECOND_NAME,V_LAST_NAME,V_SECOND_LAST_NAME,V_RFC,V_AGE,V_EMAIL,V_HOME_PHONE,V_CELL_PHONE,V_ACTIVE,
        V_STREET,V_STREET_NUMBER,V_POSTAL_CODE,V_ID_NEIGHBORHOOD
        FROM KYC_CUSTOMER C INNER JOIN KYC_CUSTOMER_ADDRESS A ON C.ID = A.ID_CUSTOMER
        WHERE C.ID = V_ID_CUSTOMER;

        V_UPDATE_CUSTOMER = 'UPDATE KYC_CUSTOMER SET FIRST_NAME=$1,SECOND_NAME=$2, LAST_NAME=$3,SECOND_LAST_NAME=$4,RFC=$5,AGE=$6
        ,CELL_PHONE=$7,HOME_PHONE=$8,EMAIL=$9,ACTIVE=$10,DATE_MODIFIED=CURRENT_DATE WHERE ID=$11';
        V_UPDATE_CUSTOMER_ADDRESS = 'UPDATE KYC_CUSTOMER_ADDRESS SET STREET=$1,STREET_NUMBER=$2,POSTAL_CODE=$3
        ,ID_NEIGHBORHOOD=$4,DATE_MODIFIED=CURRENT_DATE WHERE ID_CUSTOMER=$5';
        
        IF P_FIRST_NAME IS NOT NULL AND V_FIRST_NAME <> P_FIRST_NAME THEN
            V_FIRST_NAME = P_FIRST_NAME;
        END IF;

        IF  COALESCE(V_SECOND_NAME,'') <> P_SECOND_NAME THEN
            V_SECOND_NAME = P_SECOND_NAME;
        END IF;

        IF P_LAST_NAME IS NOT NULL AND V_LAST_NAME <> P_LAST_NAME THEN
            V_LAST_NAME = P_LAST_NAME;
        END IF;

        IF P_SECOND_LAST_NAME IS NOT NULL AND V_SECOND_LAST_NAME <> P_SECOND_LAST_NAME THEN
            V_SECOND_LAST_NAME = P_SECOND_LAST_NAME;
        END IF;

        IF P_RFC IS NOT NULL AND V_RFC <> P_RFC THEN
            V_RFC = P_RFC;
        END IF;

        IF P_AGE IS NOT NULL AND V_AGE <> P_AGE THEN
            V_AGE = P_AGE;
        END IF;

        IF P_CELL_PHONE IS NOT NULL AND V_CELL_PHONE <> P_CELL_PHONE THEN
            V_CELL_PHONE = P_CELL_PHONE;
        END IF;

        IF COALESCE(V_HOME_PHONE,'') <> P_HOME_PHONE THEN
            V_HOME_PHONE = P_HOME_PHONE;
        END IF;

        IF P_EMAIL IS NOT NULL AND V_EMAIL <> P_EMAIL THEN
            V_EMAIL = P_EMAIL;
        END IF;

        IF P_ACTIVE IS NOT NULL AND V_ACTIVE <> P_ACTIVE THEN
            V_ACTIVE = P_ACTIVE;
        END IF;

        IF P_STREET IS NOT NULL AND V_STREET <> P_STREET THEN
            V_STREET = P_STREET;
        END IF;

        IF P_STREET_NUMBER IS NOT NULL AND V_STREET_NUMBER <> P_STREET_NUMBER THEN
            V_STREET_NUMBER = P_STREET_NUMBER;
        END IF;

        IF P_POSTAL_CODE IS NOT NULL AND V_POSTAL_CODE <> P_POSTAL_CODE THEN
            V_POSTAL_CODE = P_POSTAL_CODE;
        END IF;

        IF P_ID_NEIGHBORHOOD IS NOT NULL AND V_ID_NEIGHBORHOOD <> P_ID_NEIGHBORHOOD THEN
            V_ID_NEIGHBORHOOD = P_ID_NEIGHBORHOOD;
        END IF;

        EXECUTE V_UPDATE_CUSTOMER USING V_FIRST_NAME,V_SECOND_NAME,V_LAST_NAME,V_SECOND_LAST_NAME,V_RFC,V_AGE,
                V_CELL_PHONE,V_HOME_PHONE,V_EMAIL,V_ACTIVE,V_ID_CUSTOMER;
        EXECUTE V_UPDATE_CUSTOMER_ADDRESS USING V_STREET,V_STREET_NUMBER,V_POSTAL_CODE,V_ID_NEIGHBORHOOD,V_ID_CUSTOMER;
        COMMIT;

    ELSIF OPERATION = 2 THEN

        UPDATE KYC_CUSTOMER SET ACTIVE='0' WHERE ID=V_ID_CUSTOMER;
        COMMIT;
        
    ELSIF OPERATION = 3 THEN
        
        DELETE FROM KYC_CUSTOMER_ADDRESS CA WHERE CA.ID_CUSTOMER=V_ID_CUSTOMER;
        DELETE FROM KYC_CUSTOMER WHERE ID = V_ID_CUSTOMER;
        COMMIT;

    ELSE
        RAISE EXCEPTION 'THE VALUE OF OPERATION IS NOT VALID: %',OPERATION;
    END IF;

END; $$