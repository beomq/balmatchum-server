/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:balmatchum_server/src/generated/product/daily_quiz.dart'
    as _is16fueh;
import 'package:balmatchum_server/src/generated/product/daily_record.dart'
    as _iny5mdqa;
import 'package:balmatchum_server/src/generated/quiz/quiz_question.dart'
    as _i5f8suyi;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'ads/ad_exception.dart' as _i8mgtt64;
import 'ads/ad_intent.dart' as _i5ffg0dz;
import 'ads/stored_ad_intent.dart' as _ierwdq6g;
import 'auth/external_identity.dart' as _i8thru7x;
import 'auth/login_attempt.dart' as _i1apu3f2;
import 'auth/login_challenge.dart' as _izhe0wsm;
import 'auth/login_exception.dart' as _iskwpc4e;
import 'auth/naver_grant.dart' as _ilqn0sb8;
import 'auth/naver_login_attempt.dart' as _irxk6gqc;
import 'auth/naver_login_challenge.dart' as _iw8ezytr;
import 'billing/billing_account.dart' as _ifeydnhg;
import 'billing/billing_exception.dart' as _iy7y41or;
import 'billing/entitlement_view.dart' as _ixe95a4n;
import 'billing/purchase_configuration.dart' as _iqa89lpa;
import 'billing/purchase_input.dart' as _i8awtsqn;
import 'billing/purchase_product.dart' as _iiesu012;
import 'billing/purchase_tombstone.dart' as _iwil3tvo;
import 'billing/purchase_view.dart' as _i0fbcnhc;
import 'billing/stored_purchase.dart' as _i7xmzgxf;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'product/daily_quiz.dart' as _i94q6xjz;
import 'product/daily_record.dart' as _ie37ihl8;
import 'product/daily_step_input.dart' as _i4z7ptb2;
import 'product/day_route.dart' as _i7moag3o;
import 'product/point_entry.dart' as _i3g927ck;
import 'product/product_account.dart' as _itm94d4x;
import 'product/product_day.dart' as _in1xh7b4;
import 'product/product_exception.dart' as _ixe21ogc;
import 'product/product_request.dart' as _ixso8684;
import 'product/quiz_state.dart' as _i4w5p872;
import 'product/reward_grant.dart' as _iod7wzhm;
import 'product/reward_slice.dart' as _ip4tl29k;
import 'product/reward_window.dart' as _itmku246;
import 'product/step_revision.dart' as _iypt9oiw;
import 'product/theme_item.dart' as _i4gtfwun;
import 'product/theme_ownership.dart' as _ileabnff;
import 'product/theme_store.dart' as _iotuzcr6;
import 'product/wallet_view.dart' as _izf11uf3;
import 'profile/dog_profile.dart' as _i4zjkzo6;
import 'profile/profile_exception.dart' as _ie17qpis;
import 'profile/profile_input.dart' as _ib0yiys4;
import 'profile/profile_view.dart' as _i7a0m7me;
import 'quiz/quiz_assignment.dart' as _iu8isq3w;
import 'quiz/quiz_content_revision.dart' as _ioawd7cw;
import 'quiz/quiz_question.dart' as _id1a33kr;
import 'quiz/quiz_today.dart' as _iyr4ok9x;
import 'records/gps_record.dart' as _ixays1el;
import 'records/gps_record_input.dart' as _ijl0tr6b;
import 'records/record_exception.dart' as _ihyrwhon;
import 'records/record_receipt.dart' as _ipyparvp;
import 'records/route_point.dart' as _ir7rvxr1;
import 'records/stored_gps_record.dart' as _iyylbrve;
export 'ads/ad_exception.dart';
export 'ads/ad_intent.dart';
export 'ads/stored_ad_intent.dart';
export 'auth/external_identity.dart';
export 'auth/login_attempt.dart';
export 'auth/login_challenge.dart';
export 'auth/login_exception.dart';
export 'auth/naver_grant.dart';
export 'auth/naver_login_attempt.dart';
export 'auth/naver_login_challenge.dart';
export 'billing/billing_account.dart';
export 'billing/billing_exception.dart';
export 'billing/entitlement_view.dart';
export 'billing/purchase_configuration.dart';
export 'billing/purchase_input.dart';
export 'billing/purchase_product.dart';
export 'billing/purchase_tombstone.dart';
export 'billing/purchase_view.dart';
export 'billing/stored_purchase.dart';
export 'greetings/greeting.dart';
export 'product/daily_quiz.dart';
export 'product/daily_record.dart';
export 'product/daily_step_input.dart';
export 'product/day_route.dart';
export 'product/point_entry.dart';
export 'product/product_account.dart';
export 'product/product_day.dart';
export 'product/product_exception.dart';
export 'product/product_request.dart';
export 'product/quiz_state.dart';
export 'product/reward_grant.dart';
export 'product/reward_slice.dart';
export 'product/reward_window.dart';
export 'product/step_revision.dart';
export 'product/theme_item.dart';
export 'product/theme_ownership.dart';
export 'product/theme_store.dart';
export 'product/wallet_view.dart';
export 'profile/dog_profile.dart';
export 'profile/profile_exception.dart';
export 'profile/profile_input.dart';
export 'profile/profile_view.dart';
export 'quiz/quiz_assignment.dart';
export 'quiz/quiz_content_revision.dart';
export 'quiz/quiz_question.dart';
export 'quiz/quiz_today.dart';
export 'records/gps_record.dart';
export 'records/gps_record_input.dart';
export 'records/record_exception.dart';
export 'records/record_receipt.dart';
export 'records/route_point.dart';
export 'records/stored_gps_record.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'ad_intent',
      dartName: 'StoredAdIntent',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'nonce',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'purpose',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'targetDate',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'targetRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'adUnit',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'rewardItem',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'rewardAmount',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'eventExpiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'acceptUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'transactionId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'callbackDigest',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'eventAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'verifiedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'consumedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'ad_intent_nonce',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nonce',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'ad_intent_target',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'purpose',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'targetDate',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'targetRevision',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'ad_intent_transaction',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'transactionId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'billing_account',
      dartName: 'BillingAccount',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'binding',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'billing_account_owner',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'billing_account_binding',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'binding',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'billing_purchase',
      dartName: 'StoredPurchase',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'identityHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'store',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'environment',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'productId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'purchaseReference',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sequence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'observedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'purchasedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'graceExpiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'acknowledgementPending',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'billing_purchase_identity',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'identityHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'billing_purchase_owner',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'billing_purchase_tombstone',
      dartName: 'PurchaseTombstone',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'identityHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'billing_tombstone_identity',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'identityHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'dog_profile',
      dartName: 'DogProfile',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'breedId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sex',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'dailyGoal',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'firstMetAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'dog_profile_owner',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'external_identity',
      dartName: 'ExternalIdentity',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'provider',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'issuer',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'audience',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'subjectNamespace',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'subject',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'external_identity_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'external_identity_provider_subject',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'provider',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'issuer',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'audience',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'subjectNamespace',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'subject',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'gps_record',
      dartName: 'StoredGpsRecord',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'clientRecordId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'persistedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'payload',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:GpsRecordInput?',
        ),
        _isp.ColumnDefinition(
          name: 'deleted',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'gps_record_owner_client_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'clientRecordId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'login_attempt',
      dartName: 'LoginAttempt',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'nonceHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'consumedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'naver_grant',
      dartName: 'NaverGrant',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'clientId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'refreshToken',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'naver_grant_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'naver_grant_owner',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'naver_login_attempt',
      dartName: 'NaverLoginAttempt',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'stateHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'nonceHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'codeChallenge',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'clientId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'redirectUri',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'consumedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'point_entry',
      dartName: 'PointEntry',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'entryKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'date',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'amount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'fromUnits',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'throughUnits',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'policyVersion',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'slices',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'List<protocol:RewardSlice>?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'point_entry_key',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entryKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'product_account',
      dartName: 'ProductAccount',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'streamGeneration',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'deletionVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'equippedTheme',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'sunny\'',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'product_account_owner',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'product_day',
      dartName: 'ProductDay',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'date',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'deleted',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'deletionVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'steps',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'availability',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'unknown\'',
        ),
        _isp.ColumnDefinition(
          name: 'streamGeneration',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'stepRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'grantedUnits',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'confirmedUnits',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'policyVersion',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'windows',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:RewardWindow>',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'product_day_owner_date',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'date',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'product_request',
      dartName: 'ProductRequest',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'digest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'result',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'product_request_key',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'requestId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'quiz_assignment',
      dartName: 'QuizAssignment',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'date',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'slot',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'questionId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'snapshot',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'policyVersion',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'issuedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'answerIndex',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'answeredAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'awardedPoints',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'quiz_assignment_slot',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'date',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'slot',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'quiz_assignment_seen_version',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'questionId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'version',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'quiz_assignment_seen_question',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'questionId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'quiz_content_revision',
      dartName: 'QuizContentRevision',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'questionId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'snapshot',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'quiz_content_revision_key',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'questionId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'version',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'quiz_state',
      dartName: 'QuizState',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'date',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'questionId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'answerIndex',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'answeredAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'awardedPoints',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'quiz_state_key',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'date',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'step_revision',
      dartName: 'StepRevision',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'date',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'generation',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'digest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'step_revision_key',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'date',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'generation',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'theme_ownership',
      dartName: 'ThemeOwnership',
      schema: 'public',
      module: 'balmatchum',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'owner',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'themeId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'purchasedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'theme_ownership_key',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'owner',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'themeId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iacs.Protocol.targetTableDefinitions,
    ..._iais.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i8mgtt64.AdException) {
      return _i8mgtt64.AdException.fromJson(data) as T;
    }
    if (t == _i5ffg0dz.AdIntent) {
      return _i5ffg0dz.AdIntent.fromJson(data) as T;
    }
    if (t == _ierwdq6g.StoredAdIntent) {
      return _ierwdq6g.StoredAdIntent.fromJson(data) as T;
    }
    if (t == _i8thru7x.ExternalIdentity) {
      return _i8thru7x.ExternalIdentity.fromJson(data) as T;
    }
    if (t == _i1apu3f2.LoginAttempt) {
      return _i1apu3f2.LoginAttempt.fromJson(data) as T;
    }
    if (t == _izhe0wsm.LoginChallenge) {
      return _izhe0wsm.LoginChallenge.fromJson(data) as T;
    }
    if (t == _iskwpc4e.LoginException) {
      return _iskwpc4e.LoginException.fromJson(data) as T;
    }
    if (t == _ilqn0sb8.NaverGrant) {
      return _ilqn0sb8.NaverGrant.fromJson(data) as T;
    }
    if (t == _irxk6gqc.NaverLoginAttempt) {
      return _irxk6gqc.NaverLoginAttempt.fromJson(data) as T;
    }
    if (t == _iw8ezytr.NaverLoginChallenge) {
      return _iw8ezytr.NaverLoginChallenge.fromJson(data) as T;
    }
    if (t == _ifeydnhg.BillingAccount) {
      return _ifeydnhg.BillingAccount.fromJson(data) as T;
    }
    if (t == _iy7y41or.BillingException) {
      return _iy7y41or.BillingException.fromJson(data) as T;
    }
    if (t == _ixe95a4n.EntitlementView) {
      return _ixe95a4n.EntitlementView.fromJson(data) as T;
    }
    if (t == _iqa89lpa.PurchaseConfiguration) {
      return _iqa89lpa.PurchaseConfiguration.fromJson(data) as T;
    }
    if (t == _i8awtsqn.PurchaseInput) {
      return _i8awtsqn.PurchaseInput.fromJson(data) as T;
    }
    if (t == _iiesu012.PurchaseProduct) {
      return _iiesu012.PurchaseProduct.fromJson(data) as T;
    }
    if (t == _iwil3tvo.PurchaseTombstone) {
      return _iwil3tvo.PurchaseTombstone.fromJson(data) as T;
    }
    if (t == _i0fbcnhc.PurchaseView) {
      return _i0fbcnhc.PurchaseView.fromJson(data) as T;
    }
    if (t == _i7xmzgxf.StoredPurchase) {
      return _i7xmzgxf.StoredPurchase.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _i94q6xjz.DailyQuiz) {
      return _i94q6xjz.DailyQuiz.fromJson(data) as T;
    }
    if (t == _ie37ihl8.DailyRecord) {
      return _ie37ihl8.DailyRecord.fromJson(data) as T;
    }
    if (t == _i4z7ptb2.DailyStepInput) {
      return _i4z7ptb2.DailyStepInput.fromJson(data) as T;
    }
    if (t == _i7moag3o.DayRoute) {
      return _i7moag3o.DayRoute.fromJson(data) as T;
    }
    if (t == _i3g927ck.PointEntry) {
      return _i3g927ck.PointEntry.fromJson(data) as T;
    }
    if (t == _itm94d4x.ProductAccount) {
      return _itm94d4x.ProductAccount.fromJson(data) as T;
    }
    if (t == _in1xh7b4.ProductDay) {
      return _in1xh7b4.ProductDay.fromJson(data) as T;
    }
    if (t == _ixe21ogc.ProductException) {
      return _ixe21ogc.ProductException.fromJson(data) as T;
    }
    if (t == _ixso8684.ProductRequest) {
      return _ixso8684.ProductRequest.fromJson(data) as T;
    }
    if (t == _i4w5p872.QuizState) {
      return _i4w5p872.QuizState.fromJson(data) as T;
    }
    if (t == _iod7wzhm.RewardGrant) {
      return _iod7wzhm.RewardGrant.fromJson(data) as T;
    }
    if (t == _ip4tl29k.RewardSlice) {
      return _ip4tl29k.RewardSlice.fromJson(data) as T;
    }
    if (t == _itmku246.RewardWindow) {
      return _itmku246.RewardWindow.fromJson(data) as T;
    }
    if (t == _iypt9oiw.StepRevision) {
      return _iypt9oiw.StepRevision.fromJson(data) as T;
    }
    if (t == _i4gtfwun.ThemeItem) {
      return _i4gtfwun.ThemeItem.fromJson(data) as T;
    }
    if (t == _ileabnff.ThemeOwnership) {
      return _ileabnff.ThemeOwnership.fromJson(data) as T;
    }
    if (t == _iotuzcr6.ThemeStore) {
      return _iotuzcr6.ThemeStore.fromJson(data) as T;
    }
    if (t == _izf11uf3.WalletView) {
      return _izf11uf3.WalletView.fromJson(data) as T;
    }
    if (t == _i4zjkzo6.DogProfile) {
      return _i4zjkzo6.DogProfile.fromJson(data) as T;
    }
    if (t == _ie17qpis.ProfileException) {
      return _ie17qpis.ProfileException.fromJson(data) as T;
    }
    if (t == _ib0yiys4.ProfileInput) {
      return _ib0yiys4.ProfileInput.fromJson(data) as T;
    }
    if (t == _i7a0m7me.ProfileView) {
      return _i7a0m7me.ProfileView.fromJson(data) as T;
    }
    if (t == _iu8isq3w.QuizAssignment) {
      return _iu8isq3w.QuizAssignment.fromJson(data) as T;
    }
    if (t == _ioawd7cw.QuizContentRevision) {
      return _ioawd7cw.QuizContentRevision.fromJson(data) as T;
    }
    if (t == _id1a33kr.QuizQuestion) {
      return _id1a33kr.QuizQuestion.fromJson(data) as T;
    }
    if (t == _iyr4ok9x.QuizToday) {
      return _iyr4ok9x.QuizToday.fromJson(data) as T;
    }
    if (t == _ixays1el.GpsRecord) {
      return _ixays1el.GpsRecord.fromJson(data) as T;
    }
    if (t == _ijl0tr6b.GpsRecordInput) {
      return _ijl0tr6b.GpsRecordInput.fromJson(data) as T;
    }
    if (t == _ihyrwhon.RecordException) {
      return _ihyrwhon.RecordException.fromJson(data) as T;
    }
    if (t == _ipyparvp.RecordReceipt) {
      return _ipyparvp.RecordReceipt.fromJson(data) as T;
    }
    if (t == _ir7rvxr1.RoutePoint) {
      return _ir7rvxr1.RoutePoint.fromJson(data) as T;
    }
    if (t == _iyylbrve.StoredGpsRecord) {
      return _iyylbrve.StoredGpsRecord.fromJson(data) as T;
    }
    if (t == _is.getType<_i8mgtt64.AdException?>()) {
      return (data != null ? _i8mgtt64.AdException.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i5ffg0dz.AdIntent?>()) {
      return (data != null ? _i5ffg0dz.AdIntent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ierwdq6g.StoredAdIntent?>()) {
      return (data != null ? _ierwdq6g.StoredAdIntent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8thru7x.ExternalIdentity?>()) {
      return (data != null ? _i8thru7x.ExternalIdentity.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i1apu3f2.LoginAttempt?>()) {
      return (data != null ? _i1apu3f2.LoginAttempt.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izhe0wsm.LoginChallenge?>()) {
      return (data != null ? _izhe0wsm.LoginChallenge.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iskwpc4e.LoginException?>()) {
      return (data != null ? _iskwpc4e.LoginException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilqn0sb8.NaverGrant?>()) {
      return (data != null ? _ilqn0sb8.NaverGrant.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_irxk6gqc.NaverLoginAttempt?>()) {
      return (data != null ? _irxk6gqc.NaverLoginAttempt.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iw8ezytr.NaverLoginChallenge?>()) {
      return (data != null
              ? _iw8ezytr.NaverLoginChallenge.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ifeydnhg.BillingAccount?>()) {
      return (data != null ? _ifeydnhg.BillingAccount.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iy7y41or.BillingException?>()) {
      return (data != null ? _iy7y41or.BillingException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixe95a4n.EntitlementView?>()) {
      return (data != null ? _ixe95a4n.EntitlementView.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqa89lpa.PurchaseConfiguration?>()) {
      return (data != null
              ? _iqa89lpa.PurchaseConfiguration.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i8awtsqn.PurchaseInput?>()) {
      return (data != null ? _i8awtsqn.PurchaseInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iiesu012.PurchaseProduct?>()) {
      return (data != null ? _iiesu012.PurchaseProduct.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwil3tvo.PurchaseTombstone?>()) {
      return (data != null ? _iwil3tvo.PurchaseTombstone.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i0fbcnhc.PurchaseView?>()) {
      return (data != null ? _i0fbcnhc.PurchaseView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i7xmzgxf.StoredPurchase?>()) {
      return (data != null ? _i7xmzgxf.StoredPurchase.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i94q6xjz.DailyQuiz?>()) {
      return (data != null ? _i94q6xjz.DailyQuiz.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ie37ihl8.DailyRecord?>()) {
      return (data != null ? _ie37ihl8.DailyRecord.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4z7ptb2.DailyStepInput?>()) {
      return (data != null ? _i4z7ptb2.DailyStepInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i7moag3o.DayRoute?>()) {
      return (data != null ? _i7moag3o.DayRoute.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3g927ck.PointEntry?>()) {
      return (data != null ? _i3g927ck.PointEntry.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_itm94d4x.ProductAccount?>()) {
      return (data != null ? _itm94d4x.ProductAccount.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_in1xh7b4.ProductDay?>()) {
      return (data != null ? _in1xh7b4.ProductDay.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ixe21ogc.ProductException?>()) {
      return (data != null ? _ixe21ogc.ProductException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixso8684.ProductRequest?>()) {
      return (data != null ? _ixso8684.ProductRequest.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i4w5p872.QuizState?>()) {
      return (data != null ? _i4w5p872.QuizState.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iod7wzhm.RewardGrant?>()) {
      return (data != null ? _iod7wzhm.RewardGrant.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ip4tl29k.RewardSlice?>()) {
      return (data != null ? _ip4tl29k.RewardSlice.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_itmku246.RewardWindow?>()) {
      return (data != null ? _itmku246.RewardWindow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iypt9oiw.StepRevision?>()) {
      return (data != null ? _iypt9oiw.StepRevision.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4gtfwun.ThemeItem?>()) {
      return (data != null ? _i4gtfwun.ThemeItem.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ileabnff.ThemeOwnership?>()) {
      return (data != null ? _ileabnff.ThemeOwnership.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iotuzcr6.ThemeStore?>()) {
      return (data != null ? _iotuzcr6.ThemeStore.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izf11uf3.WalletView?>()) {
      return (data != null ? _izf11uf3.WalletView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4zjkzo6.DogProfile?>()) {
      return (data != null ? _i4zjkzo6.DogProfile.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ie17qpis.ProfileException?>()) {
      return (data != null ? _ie17qpis.ProfileException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ib0yiys4.ProfileInput?>()) {
      return (data != null ? _ib0yiys4.ProfileInput.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i7a0m7me.ProfileView?>()) {
      return (data != null ? _i7a0m7me.ProfileView.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iu8isq3w.QuizAssignment?>()) {
      return (data != null ? _iu8isq3w.QuizAssignment.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ioawd7cw.QuizContentRevision?>()) {
      return (data != null
              ? _ioawd7cw.QuizContentRevision.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_id1a33kr.QuizQuestion?>()) {
      return (data != null ? _id1a33kr.QuizQuestion.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iyr4ok9x.QuizToday?>()) {
      return (data != null ? _iyr4ok9x.QuizToday.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ixays1el.GpsRecord?>()) {
      return (data != null ? _ixays1el.GpsRecord.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijl0tr6b.GpsRecordInput?>()) {
      return (data != null ? _ijl0tr6b.GpsRecordInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihyrwhon.RecordException?>()) {
      return (data != null ? _ihyrwhon.RecordException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipyparvp.RecordReceipt?>()) {
      return (data != null ? _ipyparvp.RecordReceipt.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir7rvxr1.RoutePoint?>()) {
      return (data != null ? _ir7rvxr1.RoutePoint.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iyylbrve.StoredGpsRecord?>()) {
      return (data != null ? _iyylbrve.StoredGpsRecord.fromJson(data) : null)
          as T;
    }
    if (t == List<_i0fbcnhc.PurchaseView>) {
      return (data as List)
              .map((e) => deserialize<_i0fbcnhc.PurchaseView>(e))
              .toList()
          as T;
    }
    if (t == List<_iiesu012.PurchaseProduct>) {
      return (data as List)
              .map((e) => deserialize<_iiesu012.PurchaseProduct>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i7moag3o.DayRoute>) {
      return (data as List)
              .map((e) => deserialize<_i7moag3o.DayRoute>(e))
              .toList()
          as T;
    }
    if (t == List<_ir7rvxr1.RoutePoint>) {
      return (data as List)
              .map((e) => deserialize<_ir7rvxr1.RoutePoint>(e))
              .toList()
          as T;
    }
    if (t == List<_ip4tl29k.RewardSlice>) {
      return (data as List)
              .map((e) => deserialize<_ip4tl29k.RewardSlice>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_ip4tl29k.RewardSlice>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ip4tl29k.RewardSlice>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_itmku246.RewardWindow>) {
      return (data as List)
              .map((e) => deserialize<_itmku246.RewardWindow>(e))
              .toList()
          as T;
    }
    if (t == List<_i4gtfwun.ThemeItem>) {
      return (data as List)
              .map((e) => deserialize<_i4gtfwun.ThemeItem>(e))
              .toList()
          as T;
    }
    if (t == List<_iny5mdqa.DailyRecord>) {
      return (data as List)
              .map((e) => deserialize<_iny5mdqa.DailyRecord>(e))
              .toList()
          as T;
    }
    if (t == List<_is16fueh.DailyQuiz>) {
      return (data as List)
              .map((e) => deserialize<_is16fueh.DailyQuiz>(e))
              .toList()
          as T;
    }
    if (t == List<_i5f8suyi.QuizQuestion>) {
      return (data as List)
              .map((e) => deserialize<_i5f8suyi.QuizQuestion>(e))
              .toList()
          as T;
    }
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i8mgtt64.AdException => 'AdException',
      _i5ffg0dz.AdIntent => 'AdIntent',
      _ierwdq6g.StoredAdIntent => 'StoredAdIntent',
      _i8thru7x.ExternalIdentity => 'ExternalIdentity',
      _i1apu3f2.LoginAttempt => 'LoginAttempt',
      _izhe0wsm.LoginChallenge => 'LoginChallenge',
      _iskwpc4e.LoginException => 'LoginException',
      _ilqn0sb8.NaverGrant => 'NaverGrant',
      _irxk6gqc.NaverLoginAttempt => 'NaverLoginAttempt',
      _iw8ezytr.NaverLoginChallenge => 'NaverLoginChallenge',
      _ifeydnhg.BillingAccount => 'BillingAccount',
      _iy7y41or.BillingException => 'BillingException',
      _ixe95a4n.EntitlementView => 'EntitlementView',
      _iqa89lpa.PurchaseConfiguration => 'PurchaseConfiguration',
      _i8awtsqn.PurchaseInput => 'PurchaseInput',
      _iiesu012.PurchaseProduct => 'PurchaseProduct',
      _iwil3tvo.PurchaseTombstone => 'PurchaseTombstone',
      _i0fbcnhc.PurchaseView => 'PurchaseView',
      _i7xmzgxf.StoredPurchase => 'StoredPurchase',
      _izw8z7ou.Greeting => 'Greeting',
      _i94q6xjz.DailyQuiz => 'DailyQuiz',
      _ie37ihl8.DailyRecord => 'DailyRecord',
      _i4z7ptb2.DailyStepInput => 'DailyStepInput',
      _i7moag3o.DayRoute => 'DayRoute',
      _i3g927ck.PointEntry => 'PointEntry',
      _itm94d4x.ProductAccount => 'ProductAccount',
      _in1xh7b4.ProductDay => 'ProductDay',
      _ixe21ogc.ProductException => 'ProductException',
      _ixso8684.ProductRequest => 'ProductRequest',
      _i4w5p872.QuizState => 'QuizState',
      _iod7wzhm.RewardGrant => 'RewardGrant',
      _ip4tl29k.RewardSlice => 'RewardSlice',
      _itmku246.RewardWindow => 'RewardWindow',
      _iypt9oiw.StepRevision => 'StepRevision',
      _i4gtfwun.ThemeItem => 'ThemeItem',
      _ileabnff.ThemeOwnership => 'ThemeOwnership',
      _iotuzcr6.ThemeStore => 'ThemeStore',
      _izf11uf3.WalletView => 'WalletView',
      _i4zjkzo6.DogProfile => 'DogProfile',
      _ie17qpis.ProfileException => 'ProfileException',
      _ib0yiys4.ProfileInput => 'ProfileInput',
      _i7a0m7me.ProfileView => 'ProfileView',
      _iu8isq3w.QuizAssignment => 'QuizAssignment',
      _ioawd7cw.QuizContentRevision => 'QuizContentRevision',
      _id1a33kr.QuizQuestion => 'QuizQuestion',
      _iyr4ok9x.QuizToday => 'QuizToday',
      _ixays1el.GpsRecord => 'GpsRecord',
      _ijl0tr6b.GpsRecordInput => 'GpsRecordInput',
      _ihyrwhon.RecordException => 'RecordException',
      _ipyparvp.RecordReceipt => 'RecordReceipt',
      _ir7rvxr1.RoutePoint => 'RoutePoint',
      _iyylbrve.StoredGpsRecord => 'StoredGpsRecord',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('balmatchum.', '');
    }

    switch (data) {
      case _i8mgtt64.AdException():
        return 'AdException';
      case _i5ffg0dz.AdIntent():
        return 'AdIntent';
      case _ierwdq6g.StoredAdIntent():
        return 'StoredAdIntent';
      case _i8thru7x.ExternalIdentity():
        return 'ExternalIdentity';
      case _i1apu3f2.LoginAttempt():
        return 'LoginAttempt';
      case _izhe0wsm.LoginChallenge():
        return 'LoginChallenge';
      case _iskwpc4e.LoginException():
        return 'LoginException';
      case _ilqn0sb8.NaverGrant():
        return 'NaverGrant';
      case _irxk6gqc.NaverLoginAttempt():
        return 'NaverLoginAttempt';
      case _iw8ezytr.NaverLoginChallenge():
        return 'NaverLoginChallenge';
      case _ifeydnhg.BillingAccount():
        return 'BillingAccount';
      case _iy7y41or.BillingException():
        return 'BillingException';
      case _ixe95a4n.EntitlementView():
        return 'EntitlementView';
      case _iqa89lpa.PurchaseConfiguration():
        return 'PurchaseConfiguration';
      case _i8awtsqn.PurchaseInput():
        return 'PurchaseInput';
      case _iiesu012.PurchaseProduct():
        return 'PurchaseProduct';
      case _iwil3tvo.PurchaseTombstone():
        return 'PurchaseTombstone';
      case _i0fbcnhc.PurchaseView():
        return 'PurchaseView';
      case _i7xmzgxf.StoredPurchase():
        return 'StoredPurchase';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _i94q6xjz.DailyQuiz():
        return 'DailyQuiz';
      case _ie37ihl8.DailyRecord():
        return 'DailyRecord';
      case _i4z7ptb2.DailyStepInput():
        return 'DailyStepInput';
      case _i7moag3o.DayRoute():
        return 'DayRoute';
      case _i3g927ck.PointEntry():
        return 'PointEntry';
      case _itm94d4x.ProductAccount():
        return 'ProductAccount';
      case _in1xh7b4.ProductDay():
        return 'ProductDay';
      case _ixe21ogc.ProductException():
        return 'ProductException';
      case _ixso8684.ProductRequest():
        return 'ProductRequest';
      case _i4w5p872.QuizState():
        return 'QuizState';
      case _iod7wzhm.RewardGrant():
        return 'RewardGrant';
      case _ip4tl29k.RewardSlice():
        return 'RewardSlice';
      case _itmku246.RewardWindow():
        return 'RewardWindow';
      case _iypt9oiw.StepRevision():
        return 'StepRevision';
      case _i4gtfwun.ThemeItem():
        return 'ThemeItem';
      case _ileabnff.ThemeOwnership():
        return 'ThemeOwnership';
      case _iotuzcr6.ThemeStore():
        return 'ThemeStore';
      case _izf11uf3.WalletView():
        return 'WalletView';
      case _i4zjkzo6.DogProfile():
        return 'DogProfile';
      case _ie17qpis.ProfileException():
        return 'ProfileException';
      case _ib0yiys4.ProfileInput():
        return 'ProfileInput';
      case _i7a0m7me.ProfileView():
        return 'ProfileView';
      case _iu8isq3w.QuizAssignment():
        return 'QuizAssignment';
      case _ioawd7cw.QuizContentRevision():
        return 'QuizContentRevision';
      case _id1a33kr.QuizQuestion():
        return 'QuizQuestion';
      case _iyr4ok9x.QuizToday():
        return 'QuizToday';
      case _ixays1el.GpsRecord():
        return 'GpsRecord';
      case _ijl0tr6b.GpsRecordInput():
        return 'GpsRecordInput';
      case _ihyrwhon.RecordException():
        return 'RecordException';
      case _ipyparvp.RecordReceipt():
        return 'RecordReceipt';
      case _ir7rvxr1.RoutePoint():
        return 'RoutePoint';
      case _iyylbrve.StoredGpsRecord():
        return 'StoredGpsRecord';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AdException') {
      return deserialize<_i8mgtt64.AdException>(data['data']);
    }
    if (dataClassName == 'AdIntent') {
      return deserialize<_i5ffg0dz.AdIntent>(data['data']);
    }
    if (dataClassName == 'StoredAdIntent') {
      return deserialize<_ierwdq6g.StoredAdIntent>(data['data']);
    }
    if (dataClassName == 'ExternalIdentity') {
      return deserialize<_i8thru7x.ExternalIdentity>(data['data']);
    }
    if (dataClassName == 'LoginAttempt') {
      return deserialize<_i1apu3f2.LoginAttempt>(data['data']);
    }
    if (dataClassName == 'LoginChallenge') {
      return deserialize<_izhe0wsm.LoginChallenge>(data['data']);
    }
    if (dataClassName == 'LoginException') {
      return deserialize<_iskwpc4e.LoginException>(data['data']);
    }
    if (dataClassName == 'NaverGrant') {
      return deserialize<_ilqn0sb8.NaverGrant>(data['data']);
    }
    if (dataClassName == 'NaverLoginAttempt') {
      return deserialize<_irxk6gqc.NaverLoginAttempt>(data['data']);
    }
    if (dataClassName == 'NaverLoginChallenge') {
      return deserialize<_iw8ezytr.NaverLoginChallenge>(data['data']);
    }
    if (dataClassName == 'BillingAccount') {
      return deserialize<_ifeydnhg.BillingAccount>(data['data']);
    }
    if (dataClassName == 'BillingException') {
      return deserialize<_iy7y41or.BillingException>(data['data']);
    }
    if (dataClassName == 'EntitlementView') {
      return deserialize<_ixe95a4n.EntitlementView>(data['data']);
    }
    if (dataClassName == 'PurchaseConfiguration') {
      return deserialize<_iqa89lpa.PurchaseConfiguration>(data['data']);
    }
    if (dataClassName == 'PurchaseInput') {
      return deserialize<_i8awtsqn.PurchaseInput>(data['data']);
    }
    if (dataClassName == 'PurchaseProduct') {
      return deserialize<_iiesu012.PurchaseProduct>(data['data']);
    }
    if (dataClassName == 'PurchaseTombstone') {
      return deserialize<_iwil3tvo.PurchaseTombstone>(data['data']);
    }
    if (dataClassName == 'PurchaseView') {
      return deserialize<_i0fbcnhc.PurchaseView>(data['data']);
    }
    if (dataClassName == 'StoredPurchase') {
      return deserialize<_i7xmzgxf.StoredPurchase>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'DailyQuiz') {
      return deserialize<_i94q6xjz.DailyQuiz>(data['data']);
    }
    if (dataClassName == 'DailyRecord') {
      return deserialize<_ie37ihl8.DailyRecord>(data['data']);
    }
    if (dataClassName == 'DailyStepInput') {
      return deserialize<_i4z7ptb2.DailyStepInput>(data['data']);
    }
    if (dataClassName == 'DayRoute') {
      return deserialize<_i7moag3o.DayRoute>(data['data']);
    }
    if (dataClassName == 'PointEntry') {
      return deserialize<_i3g927ck.PointEntry>(data['data']);
    }
    if (dataClassName == 'ProductAccount') {
      return deserialize<_itm94d4x.ProductAccount>(data['data']);
    }
    if (dataClassName == 'ProductDay') {
      return deserialize<_in1xh7b4.ProductDay>(data['data']);
    }
    if (dataClassName == 'ProductException') {
      return deserialize<_ixe21ogc.ProductException>(data['data']);
    }
    if (dataClassName == 'ProductRequest') {
      return deserialize<_ixso8684.ProductRequest>(data['data']);
    }
    if (dataClassName == 'QuizState') {
      return deserialize<_i4w5p872.QuizState>(data['data']);
    }
    if (dataClassName == 'RewardGrant') {
      return deserialize<_iod7wzhm.RewardGrant>(data['data']);
    }
    if (dataClassName == 'RewardSlice') {
      return deserialize<_ip4tl29k.RewardSlice>(data['data']);
    }
    if (dataClassName == 'RewardWindow') {
      return deserialize<_itmku246.RewardWindow>(data['data']);
    }
    if (dataClassName == 'StepRevision') {
      return deserialize<_iypt9oiw.StepRevision>(data['data']);
    }
    if (dataClassName == 'ThemeItem') {
      return deserialize<_i4gtfwun.ThemeItem>(data['data']);
    }
    if (dataClassName == 'ThemeOwnership') {
      return deserialize<_ileabnff.ThemeOwnership>(data['data']);
    }
    if (dataClassName == 'ThemeStore') {
      return deserialize<_iotuzcr6.ThemeStore>(data['data']);
    }
    if (dataClassName == 'WalletView') {
      return deserialize<_izf11uf3.WalletView>(data['data']);
    }
    if (dataClassName == 'DogProfile') {
      return deserialize<_i4zjkzo6.DogProfile>(data['data']);
    }
    if (dataClassName == 'ProfileException') {
      return deserialize<_ie17qpis.ProfileException>(data['data']);
    }
    if (dataClassName == 'ProfileInput') {
      return deserialize<_ib0yiys4.ProfileInput>(data['data']);
    }
    if (dataClassName == 'ProfileView') {
      return deserialize<_i7a0m7me.ProfileView>(data['data']);
    }
    if (dataClassName == 'QuizAssignment') {
      return deserialize<_iu8isq3w.QuizAssignment>(data['data']);
    }
    if (dataClassName == 'QuizContentRevision') {
      return deserialize<_ioawd7cw.QuizContentRevision>(data['data']);
    }
    if (dataClassName == 'QuizQuestion') {
      return deserialize<_id1a33kr.QuizQuestion>(data['data']);
    }
    if (dataClassName == 'QuizToday') {
      return deserialize<_iyr4ok9x.QuizToday>(data['data']);
    }
    if (dataClassName == 'GpsRecord') {
      return deserialize<_ixays1el.GpsRecord>(data['data']);
    }
    if (dataClassName == 'GpsRecordInput') {
      return deserialize<_ijl0tr6b.GpsRecordInput>(data['data']);
    }
    if (dataClassName == 'RecordException') {
      return deserialize<_ihyrwhon.RecordException>(data['data']);
    }
    if (dataClassName == 'RecordReceipt') {
      return deserialize<_ipyparvp.RecordReceipt>(data['data']);
    }
    if (dataClassName == 'RoutePoint') {
      return deserialize<_ir7rvxr1.RoutePoint>(data['data']);
    }
    if (dataClassName == 'StoredGpsRecord') {
      return deserialize<_iyylbrve.StoredGpsRecord>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iacs.Protocol().registerHostProtocol('balmatchum', this);
    _iais.Protocol().registerHostProtocol('balmatchum', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ierwdq6g.StoredAdIntent:
        return _ierwdq6g.StoredAdIntent.t;
      case _i8thru7x.ExternalIdentity:
        return _i8thru7x.ExternalIdentity.t;
      case _i1apu3f2.LoginAttempt:
        return _i1apu3f2.LoginAttempt.t;
      case _ilqn0sb8.NaverGrant:
        return _ilqn0sb8.NaverGrant.t;
      case _irxk6gqc.NaverLoginAttempt:
        return _irxk6gqc.NaverLoginAttempt.t;
      case _ifeydnhg.BillingAccount:
        return _ifeydnhg.BillingAccount.t;
      case _iwil3tvo.PurchaseTombstone:
        return _iwil3tvo.PurchaseTombstone.t;
      case _i7xmzgxf.StoredPurchase:
        return _i7xmzgxf.StoredPurchase.t;
      case _i3g927ck.PointEntry:
        return _i3g927ck.PointEntry.t;
      case _itm94d4x.ProductAccount:
        return _itm94d4x.ProductAccount.t;
      case _in1xh7b4.ProductDay:
        return _in1xh7b4.ProductDay.t;
      case _ixso8684.ProductRequest:
        return _ixso8684.ProductRequest.t;
      case _i4w5p872.QuizState:
        return _i4w5p872.QuizState.t;
      case _iypt9oiw.StepRevision:
        return _iypt9oiw.StepRevision.t;
      case _ileabnff.ThemeOwnership:
        return _ileabnff.ThemeOwnership.t;
      case _i4zjkzo6.DogProfile:
        return _i4zjkzo6.DogProfile.t;
      case _iu8isq3w.QuizAssignment:
        return _iu8isq3w.QuizAssignment.t;
      case _ioawd7cw.QuizContentRevision:
        return _ioawd7cw.QuizContentRevision.t;
      case _iyylbrve.StoredGpsRecord:
        return _iyylbrve.StoredGpsRecord.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'balmatchum';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
