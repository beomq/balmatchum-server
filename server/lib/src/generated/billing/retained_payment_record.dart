/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class RetainedPaymentRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  RetainedPaymentRecord._({
    this.id,
    required this.store,
    required this.environment,
    required this.productId,
    required this.kind,
    this.storeTransactionId,
    this.originalTransactionId,
    required this.state,
    this.purchasedAt,
    this.expiresAt,
    this.revokedAt,
    required this.recordedAt,
    required this.purgeAfter,
  });

  factory RetainedPaymentRecord({
    int? id,
    required String store,
    required String environment,
    required String productId,
    required String kind,
    String? storeTransactionId,
    String? originalTransactionId,
    required String state,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    DateTime? revokedAt,
    required DateTime recordedAt,
    required DateTime purgeAfter,
  }) = _RetainedPaymentRecordImpl;

  factory RetainedPaymentRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RetainedPaymentRecord(
      id: jsonSerialization['id'] as int?,
      store: jsonSerialization['store'] as String,
      environment: jsonSerialization['environment'] as String,
      productId: jsonSerialization['productId'] as String,
      kind: jsonSerialization['kind'] as String,
      storeTransactionId: jsonSerialization['storeTransactionId'] as String?,
      originalTransactionId:
          jsonSerialization['originalTransactionId'] as String?,
      state: jsonSerialization['state'] as String,
      purchasedAt: jsonSerialization['purchasedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['purchasedAt'],
            ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      recordedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['recordedAt'],
      ),
      purgeAfter: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['purgeAfter'],
      ),
    );
  }

  static final t = RetainedPaymentRecordTable();

  static const db = RetainedPaymentRecordRepository._();

  @override
  int? id;

  String store;

  String environment;

  String productId;

  String kind;

  String? storeTransactionId;

  String? originalTransactionId;

  String state;

  DateTime? purchasedAt;

  DateTime? expiresAt;

  DateTime? revokedAt;

  DateTime recordedAt;

  DateTime purgeAfter;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [RetainedPaymentRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RetainedPaymentRecord copyWith({
    int? id,
    String? store,
    String? environment,
    String? productId,
    String? kind,
    String? storeTransactionId,
    String? originalTransactionId,
    String? state,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    DateTime? revokedAt,
    DateTime? recordedAt,
    DateTime? purgeAfter,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RetainedPaymentRecord',
      if (id != null) 'id': id,
      'store': store,
      'environment': environment,
      'productId': productId,
      'kind': kind,
      if (storeTransactionId != null) 'storeTransactionId': storeTransactionId,
      if (originalTransactionId != null)
        'originalTransactionId': originalTransactionId,
      'state': state,
      if (purchasedAt != null) 'purchasedAt': purchasedAt?.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'recordedAt': recordedAt.toJson(),
      'purgeAfter': purgeAfter.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static RetainedPaymentRecordInclude include() {
    return RetainedPaymentRecordInclude._();
  }

  static RetainedPaymentRecordIncludeList includeList({
    _is.WhereExpressionBuilder<RetainedPaymentRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RetainedPaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<RetainedPaymentRecordTable>? orderByList,
    RetainedPaymentRecordInclude? include,
  }) {
    return RetainedPaymentRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RetainedPaymentRecord.t),
      orderByList: orderByList?.call(RetainedPaymentRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RetainedPaymentRecordImpl extends RetainedPaymentRecord {
  _RetainedPaymentRecordImpl({
    int? id,
    required String store,
    required String environment,
    required String productId,
    required String kind,
    String? storeTransactionId,
    String? originalTransactionId,
    required String state,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    DateTime? revokedAt,
    required DateTime recordedAt,
    required DateTime purgeAfter,
  }) : super._(
         id: id,
         store: store,
         environment: environment,
         productId: productId,
         kind: kind,
         storeTransactionId: storeTransactionId,
         originalTransactionId: originalTransactionId,
         state: state,
         purchasedAt: purchasedAt,
         expiresAt: expiresAt,
         revokedAt: revokedAt,
         recordedAt: recordedAt,
         purgeAfter: purgeAfter,
       );

  /// Returns a shallow copy of this [RetainedPaymentRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RetainedPaymentRecord copyWith({
    Object? id = _Undefined,
    String? store,
    String? environment,
    String? productId,
    String? kind,
    Object? storeTransactionId = _Undefined,
    Object? originalTransactionId = _Undefined,
    String? state,
    Object? purchasedAt = _Undefined,
    Object? expiresAt = _Undefined,
    Object? revokedAt = _Undefined,
    DateTime? recordedAt,
    DateTime? purgeAfter,
  }) {
    return RetainedPaymentRecord(
      id: id is int? ? id : this.id,
      store: store ?? this.store,
      environment: environment ?? this.environment,
      productId: productId ?? this.productId,
      kind: kind ?? this.kind,
      storeTransactionId: storeTransactionId is String?
          ? storeTransactionId
          : this.storeTransactionId,
      originalTransactionId: originalTransactionId is String?
          ? originalTransactionId
          : this.originalTransactionId,
      state: state ?? this.state,
      purchasedAt: purchasedAt is DateTime? ? purchasedAt : this.purchasedAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      recordedAt: recordedAt ?? this.recordedAt,
      purgeAfter: purgeAfter ?? this.purgeAfter,
    );
  }
}

class RetainedPaymentRecordUpdateTable
    extends _is.UpdateTable<RetainedPaymentRecordTable> {
  RetainedPaymentRecordUpdateTable(super.table);

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

  _is.ColumnValue<String, String> storeTransactionId(String? value) =>
      _is.ColumnValue(
        table.storeTransactionId,
        value,
      );

  _is.ColumnValue<String, String> originalTransactionId(String? value) =>
      _is.ColumnValue(
        table.originalTransactionId,
        value,
      );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
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

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(
        table.revokedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> recordedAt(DateTime value) =>
      _is.ColumnValue(
        table.recordedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> purgeAfter(DateTime value) =>
      _is.ColumnValue(
        table.purgeAfter,
        value,
      );
}

class RetainedPaymentRecordTable extends _is.Table<int?> {
  RetainedPaymentRecordTable({super.tableRelation})
    : super(tableName: 'billing_payment_record') {
    updateTable = RetainedPaymentRecordUpdateTable(this);
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
    storeTransactionId = _is.ColumnString(
      'storeTransactionId',
      this,
    );
    originalTransactionId = _is.ColumnString(
      'originalTransactionId',
      this,
    );
    state = _is.ColumnString(
      'state',
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
    revokedAt = _is.ColumnDateTime(
      'revokedAt',
      this,
    );
    recordedAt = _is.ColumnDateTime(
      'recordedAt',
      this,
    );
    purgeAfter = _is.ColumnDateTime(
      'purgeAfter',
      this,
    );
  }

  late final RetainedPaymentRecordUpdateTable updateTable;

  late final _is.ColumnString store;

  late final _is.ColumnString environment;

  late final _is.ColumnString productId;

  late final _is.ColumnString kind;

  late final _is.ColumnString storeTransactionId;

  late final _is.ColumnString originalTransactionId;

  late final _is.ColumnString state;

  late final _is.ColumnDateTime purchasedAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime revokedAt;

  late final _is.ColumnDateTime recordedAt;

  late final _is.ColumnDateTime purgeAfter;

  @override
  List<_is.Column> get columns => [
    id,
    store,
    environment,
    productId,
    kind,
    storeTransactionId,
    originalTransactionId,
    state,
    purchasedAt,
    expiresAt,
    revokedAt,
    recordedAt,
    purgeAfter,
  ];
}

class RetainedPaymentRecordInclude extends _is.IncludeObject {
  RetainedPaymentRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => RetainedPaymentRecord.t;
}

class RetainedPaymentRecordIncludeList extends _is.IncludeList {
  RetainedPaymentRecordIncludeList._({
    _is.WhereExpressionBuilder<RetainedPaymentRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RetainedPaymentRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => RetainedPaymentRecord.t;
}

class RetainedPaymentRecordRepository {
  const RetainedPaymentRecordRepository._();

  /// Returns a list of [RetainedPaymentRecord]s matching the given query parameters.
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
  Future<List<RetainedPaymentRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RetainedPaymentRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RetainedPaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<RetainedPaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RetainedPaymentRecord>(
      where: where?.call(RetainedPaymentRecord.t),
      orderBy: orderBy?.call(RetainedPaymentRecord.t),
      orderByList: orderByList?.call(RetainedPaymentRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RetainedPaymentRecord] matching the given query parameters.
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
  Future<RetainedPaymentRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RetainedPaymentRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<RetainedPaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<RetainedPaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RetainedPaymentRecord>(
      where: where?.call(RetainedPaymentRecord.t),
      orderBy: orderBy?.call(RetainedPaymentRecord.t),
      orderByList: orderByList?.call(RetainedPaymentRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RetainedPaymentRecord] by its [id] or null if no such row exists.
  Future<RetainedPaymentRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RetainedPaymentRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RetainedPaymentRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [RetainedPaymentRecord]s will have their `id` fields set.
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
  Future<List<RetainedPaymentRecord>> insert(
    _is.DatabaseSession session,
    List<RetainedPaymentRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RetainedPaymentRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RetainedPaymentRecord] and returns the inserted row.
  ///
  /// The returned [RetainedPaymentRecord] will have its `id` field set.
  Future<RetainedPaymentRecord> insertRow(
    _is.DatabaseSession session,
    RetainedPaymentRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RetainedPaymentRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RetainedPaymentRecord]s in the list and returns the resulting rows.
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
  /// The returned [RetainedPaymentRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RetainedPaymentRecord>> upsert(
    _is.DatabaseSession session,
    List<RetainedPaymentRecord> rows, {
    required _is.ColumnSelections<RetainedPaymentRecordTable> conflictColumns,
    _is.ColumnSelections<RetainedPaymentRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<RetainedPaymentRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RetainedPaymentRecord>(
      rows,
      conflictColumns: conflictColumns(RetainedPaymentRecord.t),
      updateColumns: updateColumns?.call(RetainedPaymentRecord.t),
      updateWhere: updateWhere?.call(RetainedPaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RetainedPaymentRecord] and returns the resulting row.
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
  /// The returned [RetainedPaymentRecord] will have its `id` field set.
  Future<RetainedPaymentRecord?> upsertRow(
    _is.DatabaseSession session,
    RetainedPaymentRecord row, {
    required _is.ColumnSelections<RetainedPaymentRecordTable> conflictColumns,
    _is.ColumnSelections<RetainedPaymentRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<RetainedPaymentRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RetainedPaymentRecord>(
      row,
      conflictColumns: conflictColumns(RetainedPaymentRecord.t),
      updateColumns: updateColumns?.call(RetainedPaymentRecord.t),
      updateWhere: updateWhere?.call(RetainedPaymentRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [RetainedPaymentRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RetainedPaymentRecord>> update(
    _is.DatabaseSession session,
    List<RetainedPaymentRecord> rows, {
    _is.ColumnSelections<RetainedPaymentRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RetainedPaymentRecord>(
      rows,
      columns: columns?.call(RetainedPaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RetainedPaymentRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RetainedPaymentRecord> updateRow(
    _is.DatabaseSession session,
    RetainedPaymentRecord row, {
    _is.ColumnSelections<RetainedPaymentRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RetainedPaymentRecord>(
      row,
      columns: columns?.call(RetainedPaymentRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RetainedPaymentRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RetainedPaymentRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<RetainedPaymentRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RetainedPaymentRecord>(
      id,
      columnValues: columnValues(RetainedPaymentRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RetainedPaymentRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RetainedPaymentRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RetainedPaymentRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RetainedPaymentRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RetainedPaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<RetainedPaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RetainedPaymentRecord>(
      columnValues: columnValues(RetainedPaymentRecord.t.updateTable),
      where: where(RetainedPaymentRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RetainedPaymentRecord.t),
      orderByList: orderByList?.call(RetainedPaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RetainedPaymentRecord]s in the list and returns the deleted rows.
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
  Future<List<RetainedPaymentRecord>> delete(
    _is.DatabaseSession session,
    List<RetainedPaymentRecord> rows, {
    _is.OrderByBuilder<RetainedPaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<RetainedPaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RetainedPaymentRecord>(
      rows,
      orderBy: orderBy?.call(RetainedPaymentRecord.t),
      orderByList: orderByList?.call(RetainedPaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RetainedPaymentRecord].
  Future<RetainedPaymentRecord> deleteRow(
    _is.DatabaseSession session,
    RetainedPaymentRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RetainedPaymentRecord>(
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
  Future<List<RetainedPaymentRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RetainedPaymentRecordTable> where,
    _is.OrderByBuilder<RetainedPaymentRecordTable>? orderBy,
    _is.OrderByListBuilder<RetainedPaymentRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RetainedPaymentRecord>(
      where: where(RetainedPaymentRecord.t),
      orderBy: orderBy?.call(RetainedPaymentRecord.t),
      orderByList: orderByList?.call(RetainedPaymentRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RetainedPaymentRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RetainedPaymentRecord>(
      where: where?.call(RetainedPaymentRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RetainedPaymentRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RetainedPaymentRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RetainedPaymentRecord>(
      where: where(RetainedPaymentRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
