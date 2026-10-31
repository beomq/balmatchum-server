BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "naver_grant" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "clientId" text NOT NULL,
    "refreshToken" text NOT NULL
);

-- Indexes
CREATE INDEX "naver_grant_owner" ON "naver_grant" USING btree ("authUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "naver_login_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "stateHash" text NOT NULL,
    "nonceHash" text NOT NULL,
    "codeChallenge" text NOT NULL,
    "clientId" text NOT NULL,
    "redirectUri" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "consumedAt" timestamp without time zone
);

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "naver_grant"
    ADD CONSTRAINT "naver_grant_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR balmatchum
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('balmatchum', '20261021025533591', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261021025533591', "timestamp" = now();

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
