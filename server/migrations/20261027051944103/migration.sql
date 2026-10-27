BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "billing_payment_record" (
    "id" bigserial PRIMARY KEY,
    "store" text NOT NULL,
    "environment" text NOT NULL,
    "productId" text NOT NULL,
    "kind" text NOT NULL,
    "storeTransactionId" text,
    "originalTransactionId" text,
    "state" text NOT NULL,
    "purchasedAt" timestamp without time zone,
    "expiresAt" timestamp without time zone,
    "revokedAt" timestamp without time zone,
    "recordedAt" timestamp without time zone NOT NULL,
    "purgeAfter" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "billing_payment_record_purge" ON "billing_payment_record" USING btree ("purgeAfter");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "billing_purchase" ADD COLUMN "transactionId" text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "billing_purchase_tombstone" ADD COLUMN "retainUntil" timestamp without time zone;
CREATE INDEX "billing_tombstone_retention" ON "billing_purchase_tombstone" USING btree ("retainUntil");

--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261027051944103', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261027051944103', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();


COMMIT;
