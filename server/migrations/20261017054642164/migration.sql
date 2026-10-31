BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "dog_profile" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "breedId" text NOT NULL,
    "name" text NOT NULL,
    "sex" text NOT NULL,
    "dailyGoal" bigint NOT NULL,
    "firstMetAt" timestamp without time zone NOT NULL,
    "revision" bigint NOT NULL DEFAULT 1
);

-- Indexes
CREATE UNIQUE INDEX "dog_profile_owner" ON "dog_profile" USING btree ("owner");


--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261017054642164', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261017054642164', "timestamp" = now();

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
