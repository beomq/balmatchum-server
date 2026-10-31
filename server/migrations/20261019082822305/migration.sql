BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "billing_account" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "binding" text NOT NULL,
    "sequence" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "billing_account_owner" ON "billing_account" USING btree ("owner");
CREATE UNIQUE INDEX "billing_account_binding" ON "billing_account" USING btree ("binding");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "billing_purchase" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "identityHash" text NOT NULL,
    "store" text NOT NULL,
    "environment" text NOT NULL,
    "productId" text NOT NULL,
    "kind" text NOT NULL,
    "purchaseReference" text NOT NULL,
    "state" text NOT NULL,
    "sequence" bigint NOT NULL,
    "observedAt" timestamp without time zone NOT NULL,
    "purchasedAt" timestamp without time zone,
    "expiresAt" timestamp without time zone,
    "graceExpiresAt" timestamp without time zone,
    "revokedAt" timestamp without time zone,
    "acknowledgementPending" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "billing_purchase_identity" ON "billing_purchase" USING btree ("identityHash");
CREATE INDEX "billing_purchase_owner" ON "billing_purchase" USING btree ("owner");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "billing_purchase_tombstone" (
    "id" bigserial PRIMARY KEY,
    "identityHash" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "billing_tombstone_identity" ON "billing_purchase_tombstone" USING btree ("identityHash");


--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261019082822305', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261019082822305', "timestamp" = now();

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
