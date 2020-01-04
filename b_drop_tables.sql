DROP VIEW b_stocks_temp_v;
DROP VIEW b_users_temp_v;

-- drop temp tables
DROP TABLE b_users_temp purge;
DROP TABLE b_dealers_temp purge;
DROP TABLE b_shops_temp purge;
DROP TABLE b_stocks_temp purge;
DROP TABLE b_cars_temp purge;

-- drop main tables
DROP TABLE b_codes purge;
DROP TABLE b_stocks_log  purge;
DROP TABLE b_users purge;
DROP TABLE b_shops purge;
DROP TABLE b_dealer_types purge;
DROP TABLE b_dealers purge;
DROP TABLE b_cars purge;
DROP TABLE b_stocks purge;

-- drop sequence
DROP SEQUENCE b_codes_seq;
DROP SEQUENCE b_stocks_log_seq;
DROP SEQUENCE b_shops_seq;
DROP SEQUENCE b_dealer_types_seq;
DROP SEQUENCE b_dealers_seq;
DROP SEQUENCE b_cars_seq;
DROP SEQUENCE b_stocks_seq;
