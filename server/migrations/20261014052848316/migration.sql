BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "gps_record" ADD COLUMN "deleted" boolean NOT NULL DEFAULT false;
ALTER TABLE "gps_record" ALTER COLUMN "payload" DROP NOT NULL;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "point_entry" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "entryKey" text NOT NULL,
    "kind" text NOT NULL,
    "date" text,
    "amount" bigint NOT NULL,
    "fromUnits" bigint,
    "throughUnits" bigint,
    "policyVersion" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "point_entry_key" ON "point_entry" USING btree ("owner", "entryKey");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product_account" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "streamGeneration" bigint NOT NULL DEFAULT 0,
    "deletionVersion" bigint NOT NULL DEFAULT 0,
    "equippedTheme" text NOT NULL DEFAULT 'sunny'::text
);

-- Indexes
CREATE UNIQUE INDEX "product_account_owner" ON "product_account" USING btree ("owner");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product_day" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "date" text NOT NULL,
    "revision" bigint NOT NULL DEFAULT 0,
    "deleted" boolean NOT NULL DEFAULT false,
    "deletionVersion" bigint NOT NULL DEFAULT 0,
    "steps" bigint,
    "availability" text NOT NULL DEFAULT 'unknown'::text,
    "streamGeneration" bigint NOT NULL DEFAULT 0,
    "stepRevision" bigint NOT NULL DEFAULT 0,
    "grantedUnits" bigint NOT NULL DEFAULT 0,
    "confirmedUnits" bigint NOT NULL DEFAULT 0,
    "policyVersion" text,
    "windows" json NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "product_day_owner_date" ON "product_day" USING btree ("owner", "date");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product_request" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "requestId" text NOT NULL,
    "digest" text NOT NULL,
    "result" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "product_request_key" ON "product_request" USING btree ("owner", "requestId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "quiz_state" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "date" text NOT NULL,
    "questionId" text NOT NULL,
    "answerIndex" bigint,
    "answeredAt" timestamp without time zone,
    "awardedPoints" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "quiz_state_key" ON "quiz_state" USING btree ("owner", "date");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "step_revision" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "date" text NOT NULL,
    "generation" bigint NOT NULL,
    "revision" bigint NOT NULL,
    "digest" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "step_revision_key" ON "step_revision" USING btree ("owner", "date", "generation", "revision");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "theme_ownership" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "themeId" text NOT NULL,
    "purchasedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "theme_ownership_key" ON "theme_ownership" USING btree ("owner", "themeId");


--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261014052848316', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014052848316', "timestamp" = now();

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
