BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "outfit_ownership" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "outfitId" text NOT NULL,
    "purchasedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "outfit_ownership_key" ON "outfit_ownership" USING btree ("owner", "outfitId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "product_account" ADD COLUMN "equippedOutfit" text;

--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261027011118190', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261027011118190', "timestamp" = now();

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
