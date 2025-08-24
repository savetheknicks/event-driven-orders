-- 20-inventory_db.sql
-- Inventory DB with dedicated schema `inventory`. Generated 2025-08-24 18:56
\set ON_ERROR_STOP on
\connect inventory_db

CREATE SCHEMA IF NOT EXISTS inventory AUTHORIZATION current_user;
ALTER DATABASE inventory_db SET search_path = inventory, public;

BEGIN;

CREATE TABLE IF NOT EXISTS inventory.reservations (
  order_id UUID NOT NULL,
  sku TEXT NOT NULL,
  qty INTEGER NOT NULL CHECK (qty > 0),
  reserved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (order_id, sku)
);

CREATE TABLE IF NOT EXISTS inventory.outbox (
  id UUID PRIMARY KEY,
  topic TEXT NOT NULL,
  key TEXT NOT NULL,
  payload JSONB NOT NULL,
  headers JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  published_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_inventory_outbox_unpublished
  ON inventory.outbox (published_at) WHERE published_at IS NULL;

CREATE TABLE IF NOT EXISTS inventory.processed_events (
  event_id UUID PRIMARY KEY,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMIT;
