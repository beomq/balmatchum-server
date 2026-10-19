BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "quiz_assignment" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "date" text NOT NULL,
    "slot" text NOT NULL,
    "questionId" text NOT NULL,
    "version" bigint NOT NULL,
    "snapshot" text NOT NULL,
    "policyVersion" text NOT NULL,
    "issuedAt" timestamp without time zone NOT NULL,
    "answerIndex" bigint,
    "answeredAt" timestamp without time zone,
    "awardedPoints" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE UNIQUE INDEX "quiz_assignment_slot" ON "quiz_assignment" USING btree ("owner", "date", "slot");
CREATE UNIQUE INDEX "quiz_assignment_seen_version" ON "quiz_assignment" USING btree ("owner", "questionId", "version");
CREATE UNIQUE INDEX "quiz_assignment_seen_question" ON "quiz_assignment" USING btree ("owner", "questionId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "quiz_content_revision" (
    "id" bigserial PRIMARY KEY,
    "questionId" text NOT NULL,
    "version" bigint NOT NULL,
    "snapshot" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "quiz_content_revision_key" ON "quiz_content_revision" USING btree ("questionId", "version");


--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261019055832745', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261019055832745', "timestamp" = now();

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
