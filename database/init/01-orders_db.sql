-- 10-orders_db.sql
-- Orders DB with dedicated schema `orders`. Generated 2025-08-24 18:56
\set ON_ERROR_STOP on
\connect orders_db

-- Create dedicated schema and set default search_path
CREATE SCHEMA IF NOT EXISTS orders AUTHORIZATION current_user;
ALTER DATABASE orders_db SET search_path = orders, public;

BEGIN;

CREATE TABLE IF NOT EXISTS orders.orders (
  id UUID PRIMARY KEY,
  customer_id UUID NOT NULL,
  state TEXT NOT NULL CHECK (state IN ('NEW','INVENTORY_RESERVED','PAYMENT_AUTHORIZED','READY_FOR_SHIPMENT','CANCELLED','SHIPPED')),
  total_cents INTEGER NOT NULL CHECK (total_cents >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS orders.order_items (
  id BIGSERIAL PRIMARY KEY,
  order_id UUID NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
  sku TEXT NOT NULL,
  qty INTEGER NOT NULL CHECK (qty > 0),
  UNIQUE(order_id, sku)
);

CREATE TABLE IF NOT EXISTS orders.outbox (
  id UUID PRIMARY KEY,
  topic TEXT NOT NULL,
  key TEXT NOT NULL,
  payload JSONB NOT NULL,
  headers JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  published_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_orders_outbox_unpublished
  ON orders.outbox (published_at) WHERE published_at IS NULL;

CREATE TABLE IF NOT EXISTS orders.processed_events (
  event_id UUID PRIMARY KEY,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMIT;
