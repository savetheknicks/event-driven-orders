-- 40-read_model_db.sql
-- Read-Model DB with dedicated schema `read_model`. Generated 2025-08-24 18:56
\set ON_ERROR_STOP on
\connect read_model_db

CREATE SCHEMA IF NOT EXISTS read_model AUTHORIZATION current_user;
ALTER DATABASE read_model_db SET search_path = read_model, public;

BEGIN;

CREATE TABLE IF NOT EXISTS read_model.orders_view (
  order_id UUID PRIMARY KEY,
  state TEXT NOT NULL,
  items JSONB NOT NULL,
  total_cents INTEGER NOT NULL,
  last_event_number BIGINT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS read_model.projector_checkpoints (
  projector_name TEXT NOT NULL,
  partition INT NOT NULL,
  offset BIGINT NOT NULL,
  PRIMARY KEY (projector_name, partition)
);

CREATE TABLE IF NOT EXISTS read_model.outbox (
  id UUID PRIMARY KEY,
  topic TEXT NOT NULL,
  key TEXT NOT NULL,
  payload JSONB NOT NULL,
  headers JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  published_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_readmodel_outbox_unpublished
  ON read_model.outbox (published_at) WHERE published_at IS NULL;

CREATE TABLE IF NOT EXISTS read_model.processed_events (
  event_id UUID PRIMARY KEY,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMIT;
