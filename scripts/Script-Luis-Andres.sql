alter session set "_ORACLE_SCRIPT"=true;
-- Tablespaces
CREATE SMALLFILE TABLESPACE BET_ITM
    DATAFILE '/u02/app/oracle/oradata/ORCL/BET_ITM1.DBF' SIZE 512M, '/u02/app/oracle/oradata/ORCL/BET_ITM2.DBF' SIZE 512M
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;

CREATE BIGFILE TABLESPACE BET_AUDITING
    DATAFILE '/u02/app/oracle/oradata/ORCL/BET_AUDITING.DBF' SIZE 2G
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;

CREATE UNDO TABLESPACE UNDO_BET_ITM
    DATAFILE '/u02/app/oracle/oradata/ORCL/BET_ITM_UNDO.DBF' SIZE 500M;

ALTER SYSTEM SET UNDO_TABLESPACE = UNDO_BET_ITM;

-- Profiles

CREATE PROFILE developer LIMIT
    SESSIONS_PER_USER 1
    CONNECT_TIME 60
    IDLE_TIME 30
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LIFE_TIME 90;
   

CREATE PROFILE web_application LIMIT
    SESSIONS_PER_USER 5
    CONNECT_TIME UNLIMITED
    IDLE_TIME UNLIMITED
    FAILED_LOGIN_ATTEMPTS 2
    PASSWORD_LIFE_TIME 30;

CREATE PROFILE dba_admin LIMIT
    SESSIONS_PER_USER 1
    CONNECT_TIME 30
    IDLE_TIME UNLIMITED
    FAILED_LOGIN_ATTEMPTS 2
    PASSWORD_LIFE_TIME 30;

CREATE PROFILE analyst LIMIT
    SESSIONS_PER_USER 1
    CONNECT_TIME 30
    IDLE_TIME 5
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LIFE_TIME 30
    PASSWORD_GRACE_TIME 3;

CREATE PROFILE support_iii LIMIT
    SESSIONS_PER_USER 1
    CONNECT_TIME 240
    IDLE_TIME 5
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LIFE_TIME 20
    PASSWORD_GRACE_TIME 5;

CREATE PROFILE reporter LIMIT
    SESSIONS_PER_USER 1
    CONNECT_TIME 90
    IDLE_TIME 15
    FAILED_LOGIN_ATTEMPTS 4
    PASSWORD_LIFE_TIME UNLIMITED
    PASSWORD_GRACE_TIME 5;

CREATE PROFILE auditor LIMIT
    SESSIONS_PER_USER 1
    CONNECT_TIME 90
    IDLE_TIME 15
    FAILED_LOGIN_ATTEMPTS 4
    PASSWORD_LIFE_TIME UNLIMITED
    PASSWORD_GRACE_TIME 5;

-- Users
CREATE USER developer_user
    IDENTIFIED BY developer
    PROFILE developer
    DEFAULT TABLESPACE BET_ITM;

CREATE USER web_user
    IDENTIFIED BY webpage
    PROFILE web_application
    DEFAULT TABLESPACE BET_ITM;

CREATE USER dba_user
    IDENTIFIED BY dba
    PROFILE dba_admin
    DEFAULT TABLESPACE BET_ITM;

CREATE USER analyst_user
    IDENTIFIED BY analyst
    PROFILE analyst
    DEFAULT TABLESPACE BET_ITM;

CREATE USER support_user
    IDENTIFIED BY support
    PROFILE support_iii
    DEFAULT TABLESPACE BET_ITM;

CREATE USER reporter_user
    IDENTIFIED BY reporter
    PROFILE reporter
    DEFAULT TABLESPACE BET_ITM;

CREATE USER auditor_user
    IDENTIFIED BY auditor
    PROFILE auditor
    DEFAULT TABLESPACE BET_ITM;

CREATE USER backup_dba
    IDENTIFIED BY dbabackup
    PROFILE dba_admin
    DEFAULT TABLESPACE BET_ITM;

CREATE USER backup_developer
    IDENTIFIED BY devbackup
    PROFILE developer
    DEFAULT TABLESPACE BET_ITM;

CREATE USER backup_web
    IDENTIFIED BY webbackup
    PROFILE web_application
    DEFAULT TABLESPACE BET_ITM;
   
GRANT CREATE SESSION TO 
	developer_user, 
	web_user, 
	dba_user, 
	analyst_user, 
	support_user, 
	reporter_user, 
	auditor_user, 
	backup_dba, 
	backup_developer, 
	backup_web;

GRANT CREATE TABLE TO
	dba_user, 
	backup_dba, 
	backup_developer, 
	backup_web;

-- Tables

CREATE TABLE COUNTRIES(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	COUNTRY_NAME VARCHAR2(255) NOT NULL CONSTRAINT COUNTRIES_CHECK CHECK (COUNTRY_NAME IN 'COLOMBIA'),
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT COUNTRIES_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED'))
	) 
	TABLESPACE BET_ITM;

CREATE TABLE PROVIDENCES(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	PROVIDENCE_NAME VARCHAR2(100) NOT NULL,
	COUNTRY_ID NUMBER(22,0) NOT NULL REFERENCES COUNTRIES(ID),
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT PROVIDENCES_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE CITIES(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	CITY_NAME VARCHAR2(50) NOT NULL,
	PROVIDENCE_ID NUMBER(22,0) NOT NULL REFERENCES PROVIDENCES(ID),
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT CITIES_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE DOCUMENTS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	DOCUMENT_TYPE VARCHAR2(100) NOT NULL CONSTRAINT DOCUMENTS_TYPES CHECK (DOCUMENT_TYPE IN ('CC')),
	DOCUMENT_NAME VARCHAR2(100) NOT NULL,
	EXPEDITION_CITY_ID NUMBER(22,0) NOT NULL REFERENCES COUNTRIES(ID),
	EXPEDITION_DATE DATE,
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT DOCUMENTS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE PREFERENCES(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	ACCEPTED_TERMS VARCHAR2(8) NOT NULL CONSTRAINT TERMS_CHECK CHECK (ACCEPTED_TERMS IN ('CHECKED', 'NOT CHECKED')),
	ACCEPTED_BULLETIN VARCHAR2(8) CONSTRAINT BULLETIN_CHECK CHECK (ACCEPTED_BULLETIN IN ('CHECKED', 'NOT CHECKED')),
	SPORT_BETS_EMAILS VARCHAR2(8) CONSTRAINT SPORTS_EMAILS_CHECK CHECK (SPORT_BETS_EMAILS IN ('CHECKED', 'NOT CHECKED')),
	SMS VARCHAR2(8) CONSTRAINT SMS_CHECK CHECK (SMS IN ('CHECKED', 'NOT CHECKED')),
	BROWSER_NOTIFICATIONS VARCHAR2(8) CONSTRAINT BROWSER_CHECK CHECK (BROWSER_NOTIFICATIONS IN ('CHECKED', 'NOT CHECKED')),
	BET_CHART_NOTIFICATION VARCHAR2(8) CONSTRAINT BET_CHART_TERMS CHECK (BET_CHART_NOTIFICATION IN ('CHECKED', 'NOT CHECKED')),
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT PREFERENCES_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE PROMO_CODES(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	START_DATE DATE,
	END_DATE DATE,
	STATUS VARCHAR2(8) NOT NULL CONSTRAINT CODE_STATE CHECK (STATUS IN ('PENDIENTE', 'EN PROCESO', 'RECHAZADA', 'EXITOSO')),
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT PROMO_CODES_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLE')))
	TABLESPACE BET_ITM;

CREATE TABLE DEPOSIT_LIMITS(
	ID NUMBER (22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	DAILY_DEPOSIT_LIMIT NUMBER(22,0) CONSTRAINT DAILY_DEPOSIT_CHECK CHECK (DAILY_DEPOSIT_LIMIT > 0),
	DAILY_DEPOSIT_TIMESTAMP TIMESTAMP,
	DAILY_BET_LIMIT NUMBER(22,0) CONSTRAINT DAILY_BET_CHECK CHECK (DAILY_BET_LIMIT > 0),
	DAILY_BET_TIMESTAMP TIMESTAMP,
	WEEKLY_DEPOSIT_LIMIT NUMBER(22,0) CONSTRAINT WEEKLY_DEPOSIT_CHECK CHECK (WEEKLY_DEPOSIT_LIMIT > 0),
	WEEKLY_DEPOSIT_TIMESTAMP TIMESTAMP,
	WEEKLY_BET_LIMIT NUMBER(22,0) CONSTRAINT WEEKLY_BET_CHECK CHECK (WEEKLY_BET_LIMIT > 0),
	WEEKLY_BET_TIMESTAMP TIMESTAMP,
	MONTHLY_DEPOSIT_LIMIT NUMBER(22,0) CONSTRAINT MONTHLY_DEPOSIT_CHECK CHECK (MONTHLY_DEPOSIT_LIMIT > 0),
	MONTHLY_DEPOSIT_TIMESTAMP TIMESTAMP,
	MONTHLY_BET_LIMIT NUMBER(22,0) CONSTRAINT MONTHLY_BET_CHECK CHECK (MONTHLY_BET_LIMIT > 0),
	MONTHLY_BET_TIMESTAMP TIMESTAMP,
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT DEPOSIT_LIMITS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLE')))
	TABLESPACE BET_ITM;

CREATE TABLE BET_USERS(	
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	USER_NAME VARCHAR2(255) NOT NULL,
	MIDDLE_NAME VARCHAR2(255),	
	LAST_NAME VARCHAR2(255) NOT NULL,	
	SECOND_LAST_NAME VARCHAR2(255),	
	DOCUMENT_ID NUMBER(22,0) NOT NULL REFERENCES DOCUMENTs(ID),	
	FORMALITY VARCHAR2(255) CONSTRAINT FORMALITIES CHECK (FORMALITY IN ('MR', 'MSS')),
	NATIONALITY_ID NUMBER(22,0) NOT NULL REFERENCES COUNTRIES(ID),
	BIRTHDATE DATE NOT NULL,	
	BIRTH_COUNTRY_ID  NUMBER(22,0) NOT NULL REFERENCES COUNTRIES(ID),
	BIRTH_PROVIDENCE_ID  NUMBER(22,0) NOT NULL REFERENCES PROVIDENCES(ID),	
	BIRTH_CITY_ID  NUMBER(22,0) NOT NULL REFERENCES CITIES(ID),	
	POSTAL_CODE VARCHAR(8),
	ADDRESS VARCHAR2(255) NOT NULL,	
	ADDRESS_DETAIL  VARCHAR2(255),	
	EMAIL  VARCHAR2(255) NOT NULL,	
	PHONE_COUNTRY_PREFIX VARCHAR2(5) NOT NULL,	
	CELLPHONE  VARCHAR2(255) NOT NULL,	
	USER_PASSWORD  VARCHAR2(255) NOT NULL,	
	PREFERENCE_ID NUMBER(22,0) NOT NULL REFERENCES PREFERENCES(ID),
	PROMO_CODE_ID NUMBER(22,0) REFERENCES PROMO_CODES(ID),
	DEPOSIT_LIMIT_ID NUMBER(22,0) REFERENCES DEPOSIT_LIMITS(ID),
	BALANCE_AMOUNT VARCHAR2(255) NOT NULL,
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT USERS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE MATCHES(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	LOCAL_TEAM VARCHAR2(255) NOT NULL,
	VISITOR_TEAM VARCHAR2(255) NOT NULL,
	MATCH_DATE DATE NOT NULL,
	MATCH_TIME TIMESTAMP NOT NULL,
	WINNER_TEAM VARCHAR2(255),
	STATUS VARCHAR2(15) NOT NULL CONSTRAINT MATCH_STATUS CHECK (STATUS IN ('PROGRAMADO', 'EN CURSO', 'FINALIZADO')),
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT MATCHES_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE BETS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	MATCH_ID NUMBER(22,0) REFERENCES MATCHES(ID),
	BET_STATE VARCHAR2(15) NOT NULL CONSTRAINT BET_STATES CHECK (BET_STATE IN ('ABIERTA', 'GANADA', 'PERDIDA', 'VENDIDA', 'CANCELADA', 'REEMBOLSADA', 'INVALIDA', 'RECHAZADO', 'PEDIDO', 'PARTE-APROBADO')),
	BET_MULTIPLIER_1 NUMBER CONSTRAINT BET_MULTIPLIER_1_CHECK CHECK (BET_MULTIPLIER_1 >= 1),
	BET_MULTIPLIER_2 NUMBER CONSTRAINT BET_MULTIPLIER_2_CHECK CHECK (BET_MULTIPLIER_2 >= 1),
	BET_MULTIPLIER_3 NUMBER CONSTRAINT BET_MULTIPLIER_3_CHECK CHECK (BET_MULTIPLIER_3 >= 1),
	WINNER_TEAM VARCHAR2(255) NOT NULL,
	TOTAL_AMOUNT VARCHAR2(8),
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT BETS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE BETS_DETAILS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	BET_ID NUMBER(22,0) NOT NULL REFERENCES BETS(ID),
	MATCH_ID NUMBER(22,0) NOT NULL REFERENCES MATCHES(ID),
	BET_OPTION  VARCHAR2(1) NOT NULL CONSTRAINT BET_OPTION_CHECK CHECK (BET_OPTION IN ('1', '2', '3')),
	BET_MULTIPLIER NUMBER NOT NULL CONSTRAINT BET_MULTIPLIER_CHECK CHECK (BET_MULTIPLIER >= 1),
	BET_AMOUNT VARCHAR2(8) NOT NULL,
	BET_TYPE VARCHAR2(8) NOT NULL CONSTRAINT BET_TYPES CHECK (BET_TYPE IN ('SIMPLE')),
	BET_TIMESTAMP TIMESTAMP NOT NULL,
	SOFT_DELETION VARCHAR2(8) NOT NULL CONSTRAINT BETS_DETAILS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE USERS_BETS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	BET_USER_ID NUMBER(22,0) NOT NULL REFERENCES BET_USERS(ID),
	BET_DETAIL_ID NUMBER(22,0) NOT NULL REFERENCES BETS_DETAILS(ID),
	SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT USER_BETS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE PAYMENTS_RESTRICTIONS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	PAYMENT_LOWER_LIMIT NUMBER(38,0) NOT NULL,
	PAYMENT_UPPER_LIMIT NUMBER(38,0) NOT NULL,
	SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT PAYMENT_RESTRICTIONS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE PAYMENT_METHODS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	PAYMENT_NAME VARCHAR2(50) NOT NULL,
	PAYMENT_RESTRICTION_ID NUMBER(22,0) NOT NULL REFERENCES PAYMENTS_RESTRICTIONS(ID),
	SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE DEPOSITS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	DEPOSIT_AMOUNT VARCHAR2(255) NOT NULL,
	PAYMENT_METHOD_ID NUMBER(22,0) NOT NULL REFERENCES PAYMENT_METHODS(ID),
	DEPOSIT_DESCRIPTION VARCHAR2(255),
	STATUS VARCHAR2(15) NOT NULL CONSTRAINT DEPOSIT_STATE_STATE CHECK (STATUS IN ('PENDIENTE', 'EN PROCESO', 'RECHAZADA', 'EXITOSO')),
	DEPOSIT_TIMESTAMP TIMESTAMP,
	SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT DEPOSITS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE BANKS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	BANK_NAME VARCHAR2(50) NOT NULL,
	SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT BANKS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE USER_BANKS_ACCOUNTS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	BET_USER_ID NUMBER(22,0) NOT NULL REFERENCES BET_USERS(ID),
	BANK_ID NUMBER(22,0) NOT NULL REFERENCES BANKS(ID),
	ACCOUNT_NUMBER  VARCHAR2(255) NOT NULL,
	SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT USER_BANKS_ACCOUNTS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE USERS_DEPOSITS(
    ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    USER_ID NUMBER(22,0) NOT NULL REFERENCES BET_USERS(ID),
    DEPOSIT_ID NUMBER(22,0) NOT NULL REFERENCES DEPOSITS(ID),
    USER_BANK_ID NUMBER(22,0) NOT NULL REFERENCES USER_BANKS_ACCOUNTS(ID),
    SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT USERS_DEPOSITS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
    TABLESPACE BET_ITM;

CREATE TABLE SECURITY_DOCUMENTS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	SECURITY_NAME VARCHAR2(50) NOT NULL,
	SECURITY_DOCUMENT_TYPE VARCHAR2(50) NOT NULL CONSTRAINT SECURITY_DOCUMENT_TYPE_CHECK CHECK (SECURITY_DOCUMENT_TYPE IN ('FACTURA-SERVICIOS', 'COMPROBANTE', 'IDENTIFICACION', 'FOTO')),
	FILE_SIZE VARCHAR2(50) NOT NULL,
	FILE_EXTENSION VARCHAR2(50) NOT NULL,
	FILE_URL VARCHAR2(50) NOT NULL,
	SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT SECURITY_DOCUMENTS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE USER_SECURITY_DOCUMENTS(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	BET_USER_ID NUMBER(22,0) NOT NULL REFERENCES BET_USERS(ID),
	SECURITY_DOCUMENT_ID NUMBER(22,0) NOT NULL REFERENCES SECURITY_DOCUMENTS(ID),
	SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT USER_SECURITY_DOCUMENTS_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE WITHDRAWAL(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	WITHDRAWAL_AMOUNT NUMBER(38,0) NOT NULL,
	BET_USER_ID NUMBER(22,0) NOT NULL REFERENCES BET_USERS(ID),
	USER_BANKS_ACCOUNT_ID NUMBER(22,0) NOT NULL REFERENCES USER_BANKS_ACCOUNTS(ID),
	WITHDRAWAL_REQUIREMENTS VARCHAR2(2) NOT NULL CONSTRAINT WITHDRAWAL_REQUIREMENTS_CHECK CHECK (WITHDRAWAL_REQUIREMENTS IN ('SI', 'NO')),
	USER_SECURITY_DOCUMENT_ID NUMBER(22,0) NOT NULL REFERENCES USER_SECURITY_DOCUMENTS(ID),
	TIME_TIMESTAMP TIMESTAMP NOT NULL,
	STATUS VARCHAR2(10) NOT NULL CONSTRAINT WITHDRAWAL_STATE CHECK (STATUS IN ('SIN RETIRAR', 'RETIRADO')),
	SOFT_DELETION VARCHAR2(100) NOT NULL CONSTRAINT WITHDRAWAL_DELETIONS CHECK (SOFT_DELETION IN ('DELETED', 'ENABLED')))
	TABLESPACE BET_ITM;

CREATE TABLE BET_AUDITING_TABLE(
	ID NUMBER(22,0) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	DATE_TIME TIMESTAMP NOT NULL,
	TABLE_NAME VARCHAR2(255) NOT NULL,
	RECORD_ID NUMBER(22,0) NOT NULL,
	AUDITING_ACTION VARCHAR2(10) NOT NULL CONSTRAINT ACTION_CHECK CHECK (AUDITING_ACTION IN ('INSERT', 'UPDATE', 'DELETE')),
	BET_USER_ID NUMBER(22,0) NOT NULL REFERENCES BET_USERS(ID),
	IP varchar2(20) NOT NULL)
	TABLESPACE BET_AUDITING;
	
-- Views

-- WEEKLY WINNERS
CREATE OR REPLACE VIEW WEEKLY_WINNERS_VIEW AS
	SELECT
		BET_USERS.USER_NAME || '' || BET_USERS.MIDDLE_NAME || '' || BET_USERS.LAST_NAME || '' BET_USERS.SECOND_LAST_NAME AS FULL_NAME, SUM(BET_DETAILS.BET_AMOUNT)
	FROM
		BET_USERS INNER JOIN USERS_BETS ON USERS_BETS.USER_ID = BET_USERS.ID
		INNER JOIN BETS_DETAILS ON USERS_BETS.BET_DETAIL_ID = BETS_DETAILS.ID
		INNER JOIN BETS ON BETS.ID = BETS_DETAILS.BET_ID
		INNER JOIN MATCHES ON BETS.MATCH_ID = MATCHES.ID
	WHERE
		BETS_DETAILS.BET_TIMESTAMP BETWEEN TRUNC(sysdate, 'SUNDAY') AND trunc(sysdate, 'SATURDAY')
	GROUP BY BET_USERS.USER_NAME || '' || BET_USERS.MIDDLE_NAME || '' || BET_USERS.LAST_NAME || '' || BET_USERS.SECOND_LAST_NAME
	ORDER BY SUM(BETS_DETAILS.BET_AMOUNT) DESC;
	
-- BETS DETAILS
CREATE OR REPLACE VIEW BETS_DETAILS_VIEW AS
	SELECT * 
	FROM BETS_DETAILS INNER JOIN BETS ON BETS.ID = BETS_DETAILS.BET_ID
	WHERE BETS_DETAILS.BET_TYPE LIKE 'SIMPLE';

-- BETS REVIEW
CREATE OR REPLACE VIEW BETS_REVIEW
	SELECT BETS.ID, COUNT (*) BETS_QUANTITY, SUM(BD.BET_AMOUNT) TOTAL_BET, MAX(
	CASE WHEN BD.BET_MULTIPLIER IS NOT NULL THEN BD.BET_MULTIPLIER ELSE 0 END
	) FROM BETS_DETAILS BD INNER JOIN BETS ON BETS.ID = BD.BET_ID
	GROUP BY BETS_DETAILS;
	
-- SESSION MANAGEMENT

-- Triggers
-- AUDIT TRIGGER
CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_COUNTRIES
AFTER INSERT OR UPDATE ON COUNTRIES
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'COUNTRIES', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'COUNTRIES', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'COUNTRIES', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_PROVIDENCES
AFTER INSERT OR UPDATE ON PROVIDENCES
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PROVIDENCES', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PROVIDENCES', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PROVIDENCES', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_CITIES
AFTER INSERT OR UPDATE ON CITIES
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'CITIES', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'CITIES', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'CITIES', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_DOCUMENTS
AFTER INSERT OR UPDATE ON DOCUMENTS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'DOCUMENTS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'DOCUMENTS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'DOCUMENTS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_PREFERENCES
AFTER INSERT OR UPDATE ON PREFERENCES
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PREFERENCES', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PREFERENCES', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PREFERENCES', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_PROMO_CODES
AFTER INSERT OR UPDATE ON PROMO_CODES
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PROMO_CODES', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PROMO_CODES', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PROMO_CODES', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_DEPOSIT_LIMITS
AFTER INSERT OR UPDATE ON DEPOSIT_LIMITES
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'DEPOSIT_LIMITS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'DEPOSIT_LIMITS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'DEPOSIT_LIMITS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_BET_USERS
AFTER INSERT OR UPDATE ON BET_USERS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BET_USERS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BET_USERS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BET_USERS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_MATCHES
AFTER INSERT OR UPDATE ON MATCHES
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'MATCHES', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'MATCHES', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'MATCHES', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_BETS
AFTER INSERT OR UPDATE ON BETS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BETS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BETS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BETS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_BETS_DETAILS
AFTER INSERT OR UPDATE ON BETS_DETAILS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BETS_DETAILS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BETS_DETAILS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BETS_DETAILS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_USERS_BETS
AFTER INSERT OR UPDATE ON USERS_BETS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USERS_BETS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USERS_BETS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USERS_BETS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_PAYMENTS_RESTRICTIONS
AFTER INSERT OR UPDATE ON PAYMENTS_RESTRICTIONS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PAYMENTS_RESTRICTIONS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PAYMENTS_RESTRICTIONS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PAYMENTS_RESTRICTIONS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_PAYMENT_METHODS
AFTER INSERT OR UPDATE ON PAYMENT_METHODS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PAYMENT_METHODS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PAYMENT_METHODS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'PAYMENT_METHODS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_DEPOSITS
AFTER INSERT OR UPDATE ON DEPOSITS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'DEPOSITS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'DEPOSITS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'DEPOSITS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_BANKS
AFTER INSERT OR UPDATE ON BANKS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BANKS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BANKS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'BANKS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_USER_BANKS_ACCOUNTS
AFTER INSERT OR UPDATE ON USER_BANKS_ACCOUNTS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USER_BANKS_ACCOUNTS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USER_BANKS_ACCOUNTS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USER_BANKS_ACCOUNTS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;


CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_USERS_DEPOSITS
AFTER INSERT OR UPDATE ON USERS_DEPOSITS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USERS_DEPOSITS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USERS_DEPOSITS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USERS_DEPOSITS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;


CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_SECURITY_DOCUMENTS
AFTER INSERT OR UPDATE ON SECURITY_DOCUMENTS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'SECURITY_DOCUMENTS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'SECURITY_DOCUMENTS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'SECURITY_DOCUMENTS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_USER_SECURITY_DOCUMENTS
AFTER INSERT OR UPDATE ON USER_SECURITY_DOCUMENTS
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USER_SECURITY_DOCUMENTS', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USER_SECURITY_DOCUMENTS', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF :NEW.SOFT_DELETION LIKE 'DELETED' THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'USER_SECURITY_DOCUMENTS', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

CREATE OR REPLACE TRIGGER BETS_AUDIT_REGISTER_WITHDRAWAL
AFTER INSERT OR UPDATE ON WITHDRAWAL
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'WITHDRAWAL', RECORD_ID,'INSERT',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF UPDATING THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'WITHDRAWAL', RECORD_ID,'UPDATE',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
	IF (NEW.SOFT_DELETION LIKE 'DELETED') THEN
		INSERT INTO BET_AUDITING_TABLE(DATE_TIME, TABLE_NAME, RECORD_ID, AUDITING_ACTION, BET_USER_ID, IP) 
		VALUES(CURRENT_TIMESTAMP,'WITHDRAWAL', RECORD_ID,'DELETED',:NEW.ID,SYS_CONTEXT('USERENV','IP_ADDRESS'));
	END IF;
END;

-- BALANCE TRIGGERS
-- UPDATE DEPOSITS BALANCE
CREATE OR REPLACE TRIGGER UPDATE_DEPOSIT_BALANCE 
AFTER  INSERT OR UPDATE ON DEPOSITS 
FOR EACH ROW 
WHEN (NEW.STATUS = 'EXITOSO') 
DECLARE 
   CURRENT_BALANCE VARCHAR;
   DEPOSIT_AMOUNT NUMBER;
   NEW_BALANCE NUMBER;
   BET_USER_ID NUMBER;
BEGIN 
	BET_USER_ID := SELECT BET_USER_ID FROM USERS_DEPOSITS WHERE USERS_DEPOSITS.DEPOSIT_ID = :NEW.ID;
	CURRENT_BALANCE := SELECT BALANCE_AMOUNT FROM BET_USERS INNER JOIN USERS_DEPOSITS ON USERS_DEPOSITS.USER_ID = BET_USERS.ID WHERE USERS_DEPOSITS.DEPOSIT_ID = :NEW.ID;
	DEPOSIT_AMOUNT := :NEW.DEPOSIT_AMOUNT;
	NEW_BALANCE := CURRENT_BALANCE + DEPOSIT_AMOUNT;

    IF INSERTING THEN 
        UPDATE BET_USERS SET BET_USERS.BALANCE_AMOUNT = NEW_BALANCE WHERE BET_USERS.ID = BET_USER_ID;
    END IF;
   
   	IF UPDATING THEN 
		UPDATE BET_USERS SET BET_USERS.BALANCE_AMOUNT = NEW_BALANCE WHERE BET_USERS.ID = BET_USER_ID;
    END IF;
END;

-- UPDATE WITHDRAWAL BALANCE
CREATE OR REPLACE TRIGGER UPDATE_WITHDRAWAL_BALANCE 
AFTER  INSERT OR UPDATE ON WITHDRAWAL 
FOR EACH ROW 
WHEN (NEW.STATUS = 'RETIRADO') 
DECLARE 
   CURRENT_BALANCE VARCHAR;
   WITHDRAWAL_AMOUNT NUMBER;
   NEW_BALANCE NUMBER;
   BET_USER_ID NUMBER;
BEGIN 
	BET_USER_ID := :NEW.BET_USER_ID;
	CURRENT_BALANCE := SELECT BALANCE_AMOUNT FROM BET_USERS INNER JOIN USERS_DEPOSITS ON USERS_DEPOSITS.USER_ID = BET_USERS.ID WHERE USERS_DEPOSITS.DEPOSIT_ID = :NEW.ID;
	WITHDRAWAL_AMOUNT := :NEW.WITHDRAWAL_AMOUNT;
	NEW_BALANCE := CURRENT_BALANCE + WITHDRAWAL_AMOUNT;

    IF INSERTING THEN 
        UPDATE BET_USERS SET BET_USERS.BALANCE_AMOUNT = NEW_BALANCE WHERE BET_USERS.ID = BET_USER_ID;
    END IF;
   
   	IF UPDATING THEN 
		UPDATE BET_USERS SET BET_USERS.BALANCE_AMOUNT = NEW_BALANCE WHERE BET_USERS.ID = BET_USER_ID;
    END IF;
END;

-- UPDATE BET WON BALANCE
CREATE OR REPLACE TRIGGER UPDATE_BET_BALANCE 
AFTER  INSERT OR UPDATE ON BETS 
FOR EACH ROW 
WHEN (NEW.BET_STATE = 'GANADO') 
DECLARE 
   CURRENT_BALANCE VARCHAR;
   WITHDRAWAL_AMOUNT NUMBER;
   NEW_BALANCE NUMBER;
   BET_USER_ID NUMBER;
BEGIN 
	BET_USER_ID := SELECT UB.BET_USER_ID FROM USERS_BETS UB 
		INNER JOIN BETS_DETAILS BDET ON BDET.ID = UB.BET_DETAIL_ID 
		INNER JOIN BETS ON BETS.ID = BDET.BET_ID 
		WHERE BDET.BET_ID = :NEW.ID;
	CURRENT_BALANCE := SELECT BALANCE_AMOUNT FROM BET_USERS WHERE BET_USERS.ID = BET_USER_ID;
	BET_AMOUNT := SELECT BET_AMOUNT FROM BETS_DETAILS WHERE BETS_DETAILS.BET_ID = :NEW.ID;
	NEW_BALANCE := CURRENT_BALANCE + BET_AMOUNT;

    IF INSERTING THEN 
        UPDATE BET_USERS SET BET_USERS.BALANCE_AMOUNT = NEW_BALANCE WHERE BET_USERS.ID = BET_USER_ID;
    END IF;
   
   	IF UPDATING THEN 
		UPDATE BET_USERS SET BET_USERS.BALANCE_AMOUNT = NEW_BALANCE WHERE BET_USERS.ID = BET_USER_ID;
    END IF;
END;

-- UPDATE BETS BALANCE
CREATE OR REPLACE TRIGGER UPDATE_BET_BALANCE 
AFTER  INSERT OR UPDATE ON BETS 
FOR EACH ROW 
WHEN (NEW.BET_STATE = 'PERDIDO') 
DECLARE 
   CURRENT_BALANCE VARCHAR;
   WITHDRAWAL_AMOUNT NUMBER;
   NEW_BALANCE NUMBER;
   BET_USER_ID NUMBER;
BEGIN 
	BET_USER_ID := SELECT UB.BET_USER_ID FROM USERS_BETS UB 
		INNER JOIN BETS_DETAILS BDET ON BDET.ID = UB.BET_DETAIL_ID 
		INNER JOIN BETS ON BETS.ID = BDET.BET_ID 
		WHERE BDET.BET_ID = :NEW.ID;
	CURRENT_BALANCE := SELECT BALANCE_AMOUNT FROM BET_USERS WHERE BET_USERS.ID = BET_USER_ID;
	BET_AMOUNT := SELECT BET_AMOUNT FROM BETS_DETAILS WHERE BETS_DETAILS.BET_ID = :NEW.ID;
	NEW_BALANCE := CURRENT_BALANCE - BET_AMOUNT;

    IF INSERTING THEN 
        UPDATE BET_USERS SET BET_USERS.BALANCE_AMOUNT = NEW_BALANCE WHERE BET_USERS.ID = BET_USER_ID;
    END IF;
   
   	IF UPDATING THEN 
		UPDATE BET_USERS SET BET_USERS.BALANCE_AMOUNT = NEW_BALANCE WHERE BET_USERS.ID = BET_USER_ID;
    END IF;
END;

-- MATCHES TRIGGER
CREATE OR REPLACE TRIGGER ENDED_MATCHES 
AFTER  INSERT OR UPDATE ON MATCHES 
FOR EACH ROW 
WHEN (NEW.STATUS = 'FINALIZADO')
DECLARE
	WINNER_TEAM VARCHAR;
BEGIN
	WINNER_TEAM := :NEW.WINNER_TEAM;
	DECLARE
		ID BETS.ID%TYPE;
		BET_WINNER_TEAM BETS.WINNER_TEAM%TYPE;
		CURSOR C_BETS IS SELECT BETS.ID, BETS.WINNER_TEAM FROM BETS WHERE BETS.MATCH_ID = :NEW.ID;
	BEGIN
		OPEN C_BETS:
			LOOP
				FETCH C_BETS INTO ID, BET_WINNER_TEAM;
				IF WINNER_TEAM LIKE BET_WINNER_TEAM
					UPDATE BETS SET BETS.BET_STATE = 'GANADO' WHERE BETS.ID = ID;
				END IF;
				EXIT WHEN C_BETS%NOTFOUND;
			END LOOP;
		CLOSE C_BETS;
	END;
END;

-- BETS
CREATE OR REPLACE TRIGGER TOTAL_AMOUNT_BETS
AFTER INSERT OR UPDATE ON BETS_DETAILS_VIEW
FOR EACH ROW
DECLARE
	BET_ID := NUMBER;
	CURRENT_AMOUNT := NUMBER;
	NEW_TOTAL_AMOUNT NUMBER := 0;
BEGIN
	BET_ID := SELECT BETS.ID FROM BETS INNER JOIN BETS_DETAILS ON BETS.ID = BETS_DETAILS.BET_ID WHERE BETS.ID = :NEW.ID;
	CURRENT_AMOUNT := SELECT BETS.TOTAL_AMOUNT FROM BETS WHERE BETS.ID = BET_ID;

	DECLARE
		ID BETS_DETAILS.ID%TYPE;
		BET_AMOUNT BETS_DETAILS.BET_AMOUNT%TYPE;
		RESULTADO NUMBER := 0;
		CURSOR C_BETS IS SELECT ID, BET_AMOUNT FROM BETS_DETAILS WHERE BETS_DETAILS.BET_ID = BET_ID;
		BEGIN
			OPEN C_BETS;
				LOOP
					FETCH C_BETS INTO ID, BET_AMOUNT;
					RESULTADO := RESULTADO + BET_AMOUNT;
					EXIT WHEN C_BETS%NOTFOUND;
				END LOOP;
			CLOSE C_BETS;
			NEW_TOTAL_AMOUNT := RESULTADO;
		END;

	IF INSERTING THEN 
        UPDATE BETS SET BETS.TOTAL_AMOUNT = NEW_TOTAL_AMOUNT WHERE BETS.ID = BET_ID;
    END IF;
   
   	IF UPDATING THEN 
		UPDATE BETS SET BETS.TOTAL_AMOUNT = NEW_TOTAL_AMOUNT WHERE BETS.ID = BET_ID;
    END IF;
END;