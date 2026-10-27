BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "ad_intent" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "nonce" text NOT NULL,
    "purpose" text NOT NULL,
    "targetDate" text NOT NULL,
    "targetRevision" bigint NOT NULL,
    "adUnit" text NOT NULL,
    "rewardItem" text NOT NULL,
    "rewardAmount" text NOT NULL,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "createdAt" timestamp without time zone NOT NULL,
    "eventExpiresAt" timestamp without time zone NOT NULL,
    "acceptUntil" timestamp without time zone NOT NULL,
    "transactionId" text,
    "callbackDigest" text,
    "eventAt" timestamp without time zone,
    "verifiedAt" timestamp without time zone,
    "consumedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "ad_intent_nonce" ON "ad_intent" USING btree ("nonce");
CREATE UNIQUE INDEX "ad_intent_target" ON "ad_intent" USING btree ("owner", "purpose", "targetDate", "targetRevision");
CREATE UNIQUE INDEX "ad_intent_transaction" ON "ad_intent" USING btree ("transactionId");


--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261019052118996', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261019052118996', "timestamp" = now();

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
