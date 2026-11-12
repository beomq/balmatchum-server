BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "gift_grant" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "month" text NOT NULL,
    "setId" text,
    "itemId" text,
    "grantedAt" timestamp without time zone NOT NULL,
    "reason" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "gift_grant_auth_user_month" ON "gift_grant" USING btree ("authUserId", "month");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "outfit_equip" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "slot" text NOT NULL,
    "outfitId" text NOT NULL,
    "colourId" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "outfit_equip_auth_user_slot" ON "outfit_equip" USING btree ("authUserId", "slot");

--
-- ACTION ALTER TABLE
--
DROP INDEX "outfit_ownership_auth_user_key";
ALTER TABLE "outfit_ownership" ADD COLUMN "colourId" text NOT NULL DEFAULT 'classic'::text;
ALTER TABLE "outfit_ownership" ADD COLUMN "source" text NOT NULL DEFAULT 'purchase'::text;
CREATE UNIQUE INDEX "outfit_ownership_auth_user_key" ON "outfit_ownership" USING btree ("authUserId", "outfitId", "colourId");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "theme_ownership" ADD COLUMN "source" text NOT NULL DEFAULT 'purchase'::text;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "gift_grant"
    ADD CONSTRAINT "gift_grant_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "outfit_equip"
    ADD CONSTRAINT "outfit_equip_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- DATA MIGRATION: legacy vest -> wardrobe item vest/classic (one row per
-- colour SKU), and the single equipped outfit -> the torso slot. The old
-- ledger key outfit:vest-low-v stays as it is.
--
DELETE FROM "outfit_ownership" legacy
    USING "outfit_ownership" current
    WHERE legacy."outfitId" = 'vest-low-v'
      AND current."authUserId" = legacy."authUserId"
      AND current."outfitId" = 'vest'
      AND current."colourId" = 'classic';
UPDATE "outfit_ownership"
    SET "outfitId" = 'vest', "colourId" = 'classic', "source" = 'migration'
    WHERE "outfitId" = 'vest-low-v';
INSERT INTO "outfit_equip" ("authUserId", "slot", "outfitId", "colourId")
    SELECT "authUserId", 'torso', 'vest', 'classic'
    FROM "product_account"
    WHERE "equippedOutfit" = 'vest-low-v'
    ON CONFLICT DO NOTHING;
UPDATE "product_account" SET "equippedOutfit" = NULL
    WHERE "equippedOutfit" IS NOT NULL;

--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261112144718024-wardrobe-sets', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261112144718024-wardrobe-sets', "timestamp" = now();

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
