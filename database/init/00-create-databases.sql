-- 00-create-databases.sql
-- Creates one database per service (idempotent) and sets owners to the bootstrap user.
-- Generated 2025-08-24 18:56
\set ON_ERROR_STOP on

-- Create DBs if missing (psql \gexec trick)
SELECT 'CREATE DATABASE orders_db OWNER ' || current_user
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'orders_db')\gexec
SELECT 'CREATE DATABASE inventory_db OWNER ' || current_user
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'inventory_db')\gexec
SELECT 'CREATE DATABASE payments_db OWNER ' || current_user
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'payments_db')\gexec
SELECT 'CREATE DATABASE read_model_db OWNER ' || current_user
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'read_model_db')\gexec
