
CREATE DATABASE kyc_database;

CREATE USER kyc_user WITH ENCRYPTED PASSWORD 'kyc_pass';

ALTER USER kyc_user OWNER TO kyc_database;

GRANT ALL PRIVILEGES ON DATABASE kyc_database TO kyc_user;

CREATE EXTENSION IF NOT EXISTS pgcrypto;