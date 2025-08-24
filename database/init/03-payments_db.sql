-- 30-payments_db.sql
-- Payments DB with dedicated schema `payments`. Generated 2025-08-24 18:56
\set ON_ERROR_STOP on
\connect payments_db

CREATE SCHEMA IF NOT EXISTS payments AUTHORIZATION current_user;
ALTER DATABASE payments_db SET search_path = payments, public;

BEGIN;

CREATE TABLE IF NOT EXISTS payments.payments (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('PENDING','AUTHORIZED','DECLINED')),
  auth_id TEXT,
  amount_cents INTEGER NOT NULL CHECK (amount_cents >= 0),
  currency TEXT NOT NULL DEFAULT 'USD',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_payments_order ON payments.payments(order_id);

CREATE TABLE IF NOT EXISTS payments.outbox (
  id UUID PRIMARY KEY,
  topic TEXT NOT NULL,
  key TEXT NOT NULL,
  payload JSONB NOT NULL,
  headers JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  published_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_payments_outbox_unpublished
  ON payments.outbox (published_at) WHERE published_at IS NULL;

CREATE TABLE IF NOT EXISTS payments.processed_events (
  event_id UUID PRIMARY KEY,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMIT;
