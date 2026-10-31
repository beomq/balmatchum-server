BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "ad_intent" ADD COLUMN "authUserId" uuid;
CREATE UNIQUE INDEX "ad_intent_auth_user_target" ON "ad_intent" USING btree ("authUserId", "purpose", "targetDate", "targetRevision");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "billing_account" ADD COLUMN "authUserId" uuid;
CREATE UNIQUE INDEX "billing_account_auth_user" ON "billing_account" USING btree ("authUserId");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "billing_purchase" ADD COLUMN "authUserId" uuid;
CREATE INDEX "billing_purchase_auth_user_id" ON "billing_purchase" USING btree ("authUserId", "id");
CREATE INDEX "billing_purchase_auth_user_identity" ON "billing_purchase" USING btree ("authUserId", "identityHash");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "dog_profile" ADD COLUMN "authUserId" uuid;
CREATE UNIQUE INDEX "dog_profile_auth_user" ON "dog_profile" USING btree ("authUserId");
--
-- ACTION ALTER TABLE
--
CREATE INDEX "external_identity_auth_user" ON "external_identity" USING btree ("authUserId");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "gps_record" ADD COLUMN "authUserId" uuid;
ALTER TABLE "gps_record" ADD COLUMN "firstLocalDay" bigint;
ALTER TABLE "gps_record" ADD COLUMN "lastLocalDay" bigint;
CREATE UNIQUE INDEX "gps_record_auth_user_client" ON "gps_record" USING btree ("authUserId", "clientRecordId");
CREATE INDEX "gps_record_auth_user_day" ON "gps_record" USING btree ("authUserId", "deleted", "lastLocalDay", "firstLocalDay");
--
-- ACTION ALTER TABLE
--
CREATE INDEX "login_attempt_expires_at" ON "login_attempt" USING btree ("expiresAt");
--
-- ACTION ALTER TABLE
--
DROP INDEX "naver_grant_owner";
CREATE INDEX "naver_grant_owner" ON "naver_grant" USING btree ("authUserId", "id");
--
-- ACTION ALTER TABLE
--
CREATE INDEX "naver_login_attempt_expires_at" ON "naver_login_attempt" USING btree ("expiresAt");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "outfit_ownership" ADD COLUMN "authUserId" uuid;
CREATE UNIQUE INDEX "outfit_ownership_auth_user_key" ON "outfit_ownership" USING btree ("authUserId", "outfitId");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "point_entry" ADD COLUMN "authUserId" uuid;
CREATE UNIQUE INDEX "point_entry_auth_user_key" ON "point_entry" USING btree ("authUserId", "entryKey");
CREATE INDEX "point_entry_auth_user_date" ON "point_entry" USING btree ("authUserId", "date");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "product_account" ADD COLUMN "authUserId" uuid;
ALTER TABLE "product_account" ADD COLUMN "balance" bigint NOT NULL DEFAULT 0;
ALTER TABLE "product_account" ADD COLUMN "fixtureBalance" bigint NOT NULL DEFAULT 0;
CREATE UNIQUE INDEX "product_account_auth_user" ON "product_account" USING btree ("authUserId");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "product_day" ADD COLUMN "authUserId" uuid;
CREATE UNIQUE INDEX "product_day_auth_user_date" ON "product_day" USING btree ("authUserId", "date");
CREATE INDEX "product_day_auth_user_deleted" ON "product_day" USING btree ("authUserId", "deleted", "deletionVersion");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "product_request" ADD COLUMN "authUserId" uuid;
ALTER TABLE "product_request" ADD COLUMN "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP;
CREATE UNIQUE INDEX "product_request_auth_user_key" ON "product_request" USING btree ("authUserId", "requestId");
CREATE INDEX "product_request_created_at" ON "product_request" USING btree ("createdAt");
--
-- ACTION ALTER TABLE
--
DROP INDEX "quiz_assignment_seen_version";
ALTER TABLE "quiz_assignment" ADD COLUMN "authUserId" uuid;
ALTER TABLE "quiz_assignment" ALTER COLUMN "snapshot" DROP NOT NULL;
CREATE UNIQUE INDEX "quiz_assignment_auth_user_slot" ON "quiz_assignment" USING btree ("authUserId", "date", "slot");
CREATE UNIQUE INDEX "quiz_assignment_auth_user_question" ON "quiz_assignment" USING btree ("authUserId", "questionId");
CREATE INDEX "quiz_assignment_auth_user_id" ON "quiz_assignment" USING btree ("authUserId", "id");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "quiz_state" ADD COLUMN "authUserId" uuid;
CREATE UNIQUE INDEX "quiz_state_auth_user_key" ON "quiz_state" USING btree ("authUserId", "date");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "step_revision" ADD COLUMN "authUserId" uuid;
CREATE UNIQUE INDEX "step_revision_auth_user_key" ON "step_revision" USING btree ("authUserId", "date", "generation", "revision");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "theme_ownership" ADD COLUMN "authUserId" uuid;
CREATE UNIQUE INDEX "theme_ownership_auth_user_key" ON "theme_ownership" USING btree ("authUserId", "themeId");
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ad_intent"
    ADD CONSTRAINT "ad_intent_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "billing_account"
    ADD CONSTRAINT "billing_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "billing_purchase"
    ADD CONSTRAINT "billing_purchase_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "dog_profile"
    ADD CONSTRAINT "dog_profile_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "gps_record"
    ADD CONSTRAINT "gps_record_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "outfit_ownership"
    ADD CONSTRAINT "outfit_ownership_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "point_entry"
    ADD CONSTRAINT "point_entry_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "product_account"
    ADD CONSTRAINT "product_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "product_day"
    ADD CONSTRAINT "product_day_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "product_request"
    ADD CONSTRAINT "product_request_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "quiz_assignment"
    ADD CONSTRAINT "quiz_assignment_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "quiz_state"
    ADD CONSTRAINT "quiz_state_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "step_revision"
    ADD CONSTRAINT "step_revision_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "theme_ownership"
    ADD CONSTRAINT "theme_ownership_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261031074250432-normalization-step1', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261031074250432-normalization-step1', "timestamp" = now();

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


--
-- BACKFILL normalization-step1 (idempotent; orphan rows keep NULL "authUserId")
--
UPDATE "ad_intent" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "ad_intent".owner::uuid);
UPDATE "billing_account" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "billing_account".owner::uuid);
UPDATE "billing_purchase" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "billing_purchase".owner::uuid);
UPDATE "dog_profile" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "dog_profile".owner::uuid);
UPDATE "gps_record" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "gps_record".owner::uuid);
UPDATE "outfit_ownership" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "outfit_ownership".owner::uuid);
UPDATE "point_entry" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "point_entry".owner::uuid);
UPDATE "product_account" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "product_account".owner::uuid);
UPDATE "product_day" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "product_day".owner::uuid);
UPDATE "product_request" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "product_request".owner::uuid);
UPDATE "quiz_assignment" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "quiz_assignment".owner::uuid);
UPDATE "quiz_state" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "quiz_state".owner::uuid);
UPDATE "step_revision" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "step_revision".owner::uuid);
UPDATE "theme_ownership" SET "authUserId" = owner::uuid WHERE "authUserId" IS NULL AND EXISTS (SELECT 1 FROM serverpod_auth_core_user u WHERE u.id = "theme_ownership".owner::uuid);
UPDATE "gps_record" SET "firstLocalDay" = floor((extract(epoch from (payload->>'startedAt')::timestamptz) + 32400) / 86400)::int, "lastLocalDay" = floor((extract(epoch from (payload->>'endedAt')::timestamptz) + 32400) / 86400)::int WHERE payload IS NOT NULL AND NOT deleted AND "firstLocalDay" IS NULL;
UPDATE "product_request" SET "createdAt" = now() WHERE "createdAt" IS NULL;
UPDATE "product_account" a SET "balance" = COALESCE((SELECT SUM(amount) FROM point_entry e WHERE e.owner = a.owner AND e."policyVersion" IN ('steps-v1-20261019','quiz-v1-20261019','theme-purchase-v1-20261027','outfit-purchase-v1-20261027')),0), "fixtureBalance" = COALESCE((SELECT SUM(amount) FROM point_entry e WHERE e.owner = a.owner AND e."policyVersion" = 'development-fixture-v1-not-production'),0);

COMMIT;
