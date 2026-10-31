/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:balmatchum_server/src/generated/protocol.dart' as _iu3f2ih9;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;

abstract class StoredPurchase
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  StoredPurchase._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.identityHash,
    required this.store,
    required this.environment,
    required this.productId,
    required this.kind,
    required this.purchaseReference,
    this.transactionId,
    required this.state,
    required this.sequence,
    required this.observedAt,
    this.purchasedAt,
    this.expiresAt,
    this.graceExpiresAt,
    this.revokedAt,
    required this.acknowledgementPending,
  });

  factory StoredPurchase({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String identityHash,
    required String store,
    required String environment,
    required String productId,
    required String kind,
    required String purchaseReference,
    String? transactionId,
    required String state,
    required int sequence,
    required DateTime observedAt,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    DateTime? graceExpiresAt,
    DateTime? revokedAt,
    required bool acknowledgementPending,
  }) = _StoredPurchaseImpl;

  factory StoredPurchase.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoredPurchase(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      identityHash: jsonSerialization['identityHash'] as String,
      store: jsonSerialization['store'] as String,
      environment: jsonSerialization['environment'] as String,
      productId: jsonSerialization['productId'] as String,
      kind: jsonSerialization['kind'] as String,
      purchaseReference: jsonSerialization['purchaseReference'] as String,
      transactionId: jsonSerialization['transactionId'] as String?,
      state: jsonSerialization['state'] as String,
      sequence: jsonSerialization['sequence'] as int,
      observedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['observedAt'],
      ),
      purchasedAt: jsonSerialization['purchasedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['purchasedAt'],
            ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      graceExpiresAt: jsonSerialization['graceExpiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['graceExpiresAt'],
            ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      acknowledgementPending: _is.BoolJsonExtension.fromJson(
        jsonSerialization['acknowledgementPending'],
      ),
    );
  }

  static final t = StoredPurchaseTable();

  static const db = StoredPurchaseRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String identityHash;

  String store;

  String environment;

  String productId;

  String kind;

  String purchaseReference;

  String? transactionId;

  String state;

  int sequence;

  DateTime observedAt;

  DateTime? purchasedAt;

  DateTime? expiresAt;

  DateTime? graceExpiresAt;

  DateTime? revokedAt;

  bool acknowledgementPending;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [StoredPurchase]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StoredPurchase copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? identityHash,
    String? store,
    String? environment,
    String? productId,
    String? kind,
    String? purchaseReference,
    String? transactionId,
    String? state,
    int? sequence,
    DateTime? observedAt,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    DateTime? graceExpiresAt,
    DateTime? revokedAt,
    bool? acknowledgementPending,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoredPurchase',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'identityHash': identityHash,
      'store': store,
      'environment': environment,
      'productId': productId,
      'kind': kind,
      'purchaseReference': purchaseReference,
      if (transactionId != null) 'transactionId': transactionId,
      'state': state,
      'sequence': sequence,
      'observedAt': observedAt.toJson(),
      if (purchasedAt != null) 'purchasedAt': purchasedAt?.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      if (graceExpiresAt != null) 'graceExpiresAt': graceExpiresAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'acknowledgementPending': acknowledgementPending,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StoredPurchaseInclude include({_iacs.AuthUserInclude? authUser}) {
    return StoredPurchaseInclude._(authUser: authUser);
  }

  static StoredPurchaseIncludeList includeList({
    _is.WhereExpressionBuilder<StoredPurchaseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredPurchaseTable>? orderBy,
    _is.OrderByListBuilder<StoredPurchaseTable>? orderByList,
    StoredPurchaseInclude? include,
  }) {
    return StoredPurchaseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoredPurchase.t),
      orderByList: orderByList?.call(StoredPurchase.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoredPurchaseImpl extends StoredPurchase {
  _StoredPurchaseImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String identityHash,
    required String store,
    required String environment,
    required String productId,
    required String kind,
    required String purchaseReference,
    String? transactionId,
    required String state,
    required int sequence,
    required DateTime observedAt,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    DateTime? graceExpiresAt,
    DateTime? revokedAt,
    required bool acknowledgementPending,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         identityHash: identityHash,
         store: store,
         environment: environment,
         productId: productId,
         kind: kind,
         purchaseReference: purchaseReference,
         transactionId: transactionId,
         state: state,
         sequence: sequence,
         observedAt: observedAt,
         purchasedAt: purchasedAt,
         expiresAt: expiresAt,
         graceExpiresAt: graceExpiresAt,
         revokedAt: revokedAt,
         acknowledgementPending: acknowledgementPending,
       );

  /// Returns a shallow copy of this [StoredPurchase]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StoredPurchase copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? identityHash,
    String? store,
    String? environment,
    String? productId,
    String? kind,
    String? purchaseReference,
    Object? transactionId = _Undefined,
    String? state,
    int? sequence,
    DateTime? observedAt,
    Object? purchasedAt = _Undefined,
    Object? expiresAt = _Undefined,
    Object? graceExpiresAt = _Undefined,
    Object? revokedAt = _Undefined,
    bool? acknowledgementPending,
  }) {
    return StoredPurchase(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      identityHash: identityHash ?? this.identityHash,
      store: store ?? this.store,
      environment: environment ?? this.environment,
      productId: productId ?? this.productId,
      kind: kind ?? this.kind,
      purchaseReference: purchaseReference ?? this.purchaseReference,
      transactionId: transactionId is String?
          ? transactionId
          : this.transactionId,
      state: state ?? this.state,
      sequence: sequence ?? this.sequence,
      observedAt: observedAt ?? this.observedAt,
      purchasedAt: purchasedAt is DateTime? ? purchasedAt : this.purchasedAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      graceExpiresAt: graceExpiresAt is DateTime?
          ? graceExpiresAt
          : this.graceExpiresAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      acknowledgementPending:
          acknowledgementPending ?? this.acknowledgementPending,
    );
  }
}

class StoredPurchaseUpdateTable extends _is.UpdateTable<StoredPurchaseTable> {
  StoredPurchaseUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> identityHash(String value) => _is.ColumnValue(
    table.identityHash,
    value,
  );

  _is.ColumnValue<String, String> store(String value) => _is.ColumnValue(
    table.store,
    value,
  );

  _is.ColumnValue<String, String> environment(String value) => _is.ColumnValue(
    table.environment,
    value,
  );

  _is.ColumnValue<String, String> productId(String value) => _is.ColumnValue(
    table.productId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> purchaseReference(String value) =>
      _is.ColumnValue(
        table.purchaseReference,
        value,
      );

  _is.ColumnValue<String, String> transactionId(String? value) =>
      _is.ColumnValue(
        table.transactionId,
        value,
      );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<int, int> sequence(int value) => _is.ColumnValue(
    table.sequence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> observedAt(DateTime value) =>
      _is.ColumnValue(
        table.observedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> purchasedAt(DateTime? value) =>
      _is.ColumnValue(
        table.purchasedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime? value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> graceExpiresAt(DateTime? value) =>
      _is.ColumnValue(
        table.graceExpiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(
        table.revokedAt,
        value,
      );

  _is.ColumnValue<bool, bool> acknowledgementPending(bool value) =>
      _is.ColumnValue(
        table.acknowledgementPending,
        value,
      );
}

class StoredPurchaseTable extends _is.Table<int?> {
  StoredPurchaseTable({super.tableRelation})
    : super(tableName: 'billing_purchase') {
    updateTable = StoredPurchaseUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    identityHash = _is.ColumnString(
      'identityHash',
      this,
    );
    store = _is.ColumnString(
      'store',
      this,
    );
    environment = _is.ColumnString(
      'environment',
      this,
    );
    productId = _is.ColumnString(
      'productId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    purchaseReference = _is.ColumnString(
      'purchaseReference',
      this,
    );
    transactionId = _is.ColumnString(
      'transactionId',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
    );
    sequence = _is.ColumnInt(
      'sequence',
      this,
    );
    observedAt = _is.ColumnDateTime(
      'observedAt',
      this,
    );
    purchasedAt = _is.ColumnDateTime(
      'purchasedAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    graceExpiresAt = _is.ColumnDateTime(
      'graceExpiresAt',
      this,
    );
    revokedAt = _is.ColumnDateTime(
      'revokedAt',
      this,
    );
    acknowledgementPending = _is.ColumnBool(
      'acknowledgementPending',
      this,
    );
  }

  late final StoredPurchaseUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString identityHash;

  late final _is.ColumnString store;

  late final _is.ColumnString environment;

  late final _is.ColumnString productId;

  late final _is.ColumnString kind;

  late final _is.ColumnString purchaseReference;

  late final _is.ColumnString transactionId;

  late final _is.ColumnString state;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime observedAt;

  late final _is.ColumnDateTime purchasedAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime graceExpiresAt;

  late final _is.ColumnDateTime revokedAt;

  late final _is.ColumnBool acknowledgementPending;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: StoredPurchase.t.authUserId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    identityHash,
    store,
    environment,
    productId,
    kind,
    purchaseReference,
    transactionId,
    state,
    sequence,
    observedAt,
    purchasedAt,
    expiresAt,
    graceExpiresAt,
    revokedAt,
    acknowledgementPending,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class StoredPurchaseInclude extends _is.IncludeObject {
  StoredPurchaseInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => StoredPurchase.t;
}

class StoredPurchaseIncludeList extends _is.IncludeList {
  StoredPurchaseIncludeList._({
    _is.WhereExpressionBuilder<StoredPurchaseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StoredPurchase.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => StoredPurchase.t;
}

class StoredPurchaseRepository {
  const StoredPurchaseRepository._();

  final attachRow = const StoredPurchaseAttachRowRepository._();

  /// Returns a list of [StoredPurchase]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<StoredPurchase>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredPurchaseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredPurchaseTable>? orderBy,
    _is.OrderByListBuilder<StoredPurchaseTable>? orderByList,
    _is.Transaction? transaction,
    StoredPurchaseInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StoredPurchase>(
      where: where?.call(StoredPurchase.t),
      orderBy: orderBy?.call(StoredPurchase.t),
      orderByList: orderByList?.call(StoredPurchase.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StoredPurchase] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<StoredPurchase?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredPurchaseTable>? where,
    int? offset,
    _is.OrderByBuilder<StoredPurchaseTable>? orderBy,
    _is.OrderByListBuilder<StoredPurchaseTable>? orderByList,
    _is.Transaction? transaction,
    StoredPurchaseInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StoredPurchase>(
      where: where?.call(StoredPurchase.t),
      orderBy: orderBy?.call(StoredPurchase.t),
      orderByList: orderByList?.call(StoredPurchase.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StoredPurchase] by its [id] or null if no such row exists.
  Future<StoredPurchase?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    StoredPurchaseInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StoredPurchase>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StoredPurchase]s in the list and returns the inserted rows.
  ///
  /// The returned [StoredPurchase]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredPurchase>> insert(
    _is.DatabaseSession session,
    List<StoredPurchase> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StoredPurchase>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StoredPurchase] and returns the inserted row.
  ///
  /// The returned [StoredPurchase] will have its `id` field set.
  Future<StoredPurchase> insertRow(
    _is.DatabaseSession session,
    StoredPurchase row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StoredPurchase>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StoredPurchase]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [StoredPurchase]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredPurchase>> upsert(
    _is.DatabaseSession session,
    List<StoredPurchase> rows, {
    required _is.ColumnSelections<StoredPurchaseTable> conflictColumns,
    _is.ColumnSelections<StoredPurchaseTable>? updateColumns,
    _is.WhereExpressionBuilder<StoredPurchaseTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StoredPurchase>(
      rows,
      conflictColumns: conflictColumns(StoredPurchase.t),
      updateColumns: updateColumns?.call(StoredPurchase.t),
      updateWhere: updateWhere?.call(StoredPurchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StoredPurchase] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [StoredPurchase] will have its `id` field set.
  Future<StoredPurchase?> upsertRow(
    _is.DatabaseSession session,
    StoredPurchase row, {
    required _is.ColumnSelections<StoredPurchaseTable> conflictColumns,
    _is.ColumnSelections<StoredPurchaseTable>? updateColumns,
    _is.WhereExpressionBuilder<StoredPurchaseTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StoredPurchase>(
      row,
      conflictColumns: conflictColumns(StoredPurchase.t),
      updateColumns: updateColumns?.call(StoredPurchase.t),
      updateWhere: updateWhere?.call(StoredPurchase.t),
      transaction: transaction,
    );
  }

  /// Updates all [StoredPurchase]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredPurchase>> update(
    _is.DatabaseSession session,
    List<StoredPurchase> rows, {
    _is.ColumnSelections<StoredPurchaseTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StoredPurchase>(
      rows,
      columns: columns?.call(StoredPurchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StoredPurchase]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StoredPurchase> updateRow(
    _is.DatabaseSession session,
    StoredPurchase row, {
    _is.ColumnSelections<StoredPurchaseTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StoredPurchase>(
      row,
      columns: columns?.call(StoredPurchase.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoredPurchase] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StoredPurchase?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StoredPurchaseUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StoredPurchase>(
      id,
      columnValues: columnValues(StoredPurchase.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StoredPurchase]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredPurchase>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StoredPurchaseUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StoredPurchaseTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredPurchaseTable>? orderBy,
    _is.OrderByListBuilder<StoredPurchaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StoredPurchase>(
      columnValues: columnValues(StoredPurchase.t.updateTable),
      where: where(StoredPurchase.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoredPurchase.t),
      orderByList: orderByList?.call(StoredPurchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StoredPurchase]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredPurchase>> delete(
    _is.DatabaseSession session,
    List<StoredPurchase> rows, {
    _is.OrderByBuilder<StoredPurchaseTable>? orderBy,
    _is.OrderByListBuilder<StoredPurchaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StoredPurchase>(
      rows,
      orderBy: orderBy?.call(StoredPurchase.t),
      orderByList: orderByList?.call(StoredPurchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StoredPurchase].
  Future<StoredPurchase> deleteRow(
    _is.DatabaseSession session,
    StoredPurchase row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StoredPurchase>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredPurchase>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StoredPurchaseTable> where,
    _is.OrderByBuilder<StoredPurchaseTable>? orderBy,
    _is.OrderByListBuilder<StoredPurchaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StoredPurchase>(
      where: where(StoredPurchase.t),
      orderBy: orderBy?.call(StoredPurchase.t),
      orderByList: orderByList?.call(StoredPurchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredPurchaseTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StoredPurchase>(
      where: where?.call(StoredPurchase.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StoredPurchase] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StoredPurchaseTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StoredPurchase>(
      where: where(StoredPurchase.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class StoredPurchaseAttachRowRepository {
  const StoredPurchaseAttachRowRepository._();

  /// Creates a relation between the given [StoredPurchase] and [AuthUser]
  /// by setting the [StoredPurchase]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    StoredPurchase storedPurchase,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (storedPurchase.id == null) {
      throw ArgumentError.notNull('storedPurchase.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $storedPurchase = storedPurchase.copyWith(authUserId: authUser.id);
    await session.db.updateRow<StoredPurchase>(
      $storedPurchase,
      columns: [StoredPurchase.t.authUserId],
      transaction: transaction,
    );
  }
}
