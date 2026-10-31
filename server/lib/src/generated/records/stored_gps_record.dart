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
import '../records/gps_record_input.dart' as _i7qho75c;

abstract class StoredGpsRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  StoredGpsRecord._({
    this.id,
    required this.owner,
    this.authUserId,
    this.authUser,
    required this.clientRecordId,
    required this.persistedAt,
    this.payload,
    bool? deleted,
    this.firstLocalDay,
    this.lastLocalDay,
  }) : deleted = deleted ?? false;

  factory StoredGpsRecord({
    _is.UuidValue? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required _is.UuidValue clientRecordId,
    required DateTime persistedAt,
    _i7qho75c.GpsRecordInput? payload,
    bool? deleted,
    int? firstLocalDay,
    int? lastLocalDay,
  }) = _StoredGpsRecordImpl;

  factory StoredGpsRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoredGpsRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      owner: jsonSerialization['owner'] as String,
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      clientRecordId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['clientRecordId'],
      ),
      persistedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['persistedAt'],
      ),
      payload: jsonSerialization['payload'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_i7qho75c.GpsRecordInput>(
              jsonSerialization['payload'],
            ),
      deleted: jsonSerialization['deleted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
      firstLocalDay: jsonSerialization['firstLocalDay'] as int?,
      lastLocalDay: jsonSerialization['lastLocalDay'] as int?,
    );
  }

  static final t = StoredGpsRecordTable();

  static const db = StoredGpsRecordRepository._();

  @override
  _is.UuidValue? id;

  String owner;

  _is.UuidValue? authUserId;

  _iacs.AuthUser? authUser;

  _is.UuidValue clientRecordId;

  DateTime persistedAt;

  _i7qho75c.GpsRecordInput? payload;

  bool deleted;

  int? firstLocalDay;

  int? lastLocalDay;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [StoredGpsRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StoredGpsRecord copyWith({
    _is.UuidValue? id,
    String? owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    _is.UuidValue? clientRecordId,
    DateTime? persistedAt,
    _i7qho75c.GpsRecordInput? payload,
    bool? deleted,
    int? firstLocalDay,
    int? lastLocalDay,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoredGpsRecord',
      if (id != null) 'id': id?.toJson(),
      'owner': owner,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'clientRecordId': clientRecordId.toJson(),
      'persistedAt': persistedAt.toJson(),
      if (payload != null) 'payload': payload?.toJson(),
      'deleted': deleted,
      if (firstLocalDay != null) 'firstLocalDay': firstLocalDay,
      if (lastLocalDay != null) 'lastLocalDay': lastLocalDay,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StoredGpsRecordInclude include({_iacs.AuthUserInclude? authUser}) {
    return StoredGpsRecordInclude._(authUser: authUser);
  }

  static StoredGpsRecordIncludeList includeList({
    _is.WhereExpressionBuilder<StoredGpsRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredGpsRecordTable>? orderBy,
    _is.OrderByListBuilder<StoredGpsRecordTable>? orderByList,
    StoredGpsRecordInclude? include,
  }) {
    return StoredGpsRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoredGpsRecord.t),
      orderByList: orderByList?.call(StoredGpsRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoredGpsRecordImpl extends StoredGpsRecord {
  _StoredGpsRecordImpl({
    _is.UuidValue? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required _is.UuidValue clientRecordId,
    required DateTime persistedAt,
    _i7qho75c.GpsRecordInput? payload,
    bool? deleted,
    int? firstLocalDay,
    int? lastLocalDay,
  }) : super._(
         id: id,
         owner: owner,
         authUserId: authUserId,
         authUser: authUser,
         clientRecordId: clientRecordId,
         persistedAt: persistedAt,
         payload: payload,
         deleted: deleted,
         firstLocalDay: firstLocalDay,
         lastLocalDay: lastLocalDay,
       );

  /// Returns a shallow copy of this [StoredGpsRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StoredGpsRecord copyWith({
    Object? id = _Undefined,
    String? owner,
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    _is.UuidValue? clientRecordId,
    DateTime? persistedAt,
    Object? payload = _Undefined,
    bool? deleted,
    Object? firstLocalDay = _Undefined,
    Object? lastLocalDay = _Undefined,
  }) {
    return StoredGpsRecord(
      id: id is _is.UuidValue? ? id : this.id,
      owner: owner ?? this.owner,
      authUserId: authUserId is _is.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      clientRecordId: clientRecordId ?? this.clientRecordId,
      persistedAt: persistedAt ?? this.persistedAt,
      payload: payload is _i7qho75c.GpsRecordInput?
          ? payload
          : this.payload?.copyWith(),
      deleted: deleted ?? this.deleted,
      firstLocalDay: firstLocalDay is int? ? firstLocalDay : this.firstLocalDay,
      lastLocalDay: lastLocalDay is int? ? lastLocalDay : this.lastLocalDay,
    );
  }
}

class StoredGpsRecordUpdateTable extends _is.UpdateTable<StoredGpsRecordTable> {
  StoredGpsRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> owner(String value) => _is.ColumnValue(
    table.owner,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> clientRecordId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.clientRecordId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> persistedAt(DateTime value) =>
      _is.ColumnValue(
        table.persistedAt,
        value,
      );

  _is.ColumnValue<_i7qho75c.GpsRecordInput, _i7qho75c.GpsRecordInput> payload(
    _i7qho75c.GpsRecordInput? value,
  ) => _is.ColumnValue(
    table.payload,
    value,
  );

  _is.ColumnValue<bool, bool> deleted(bool value) => _is.ColumnValue(
    table.deleted,
    value,
  );

  _is.ColumnValue<int, int> firstLocalDay(int? value) => _is.ColumnValue(
    table.firstLocalDay,
    value,
  );

  _is.ColumnValue<int, int> lastLocalDay(int? value) => _is.ColumnValue(
    table.lastLocalDay,
    value,
  );
}

class StoredGpsRecordTable extends _is.Table<_is.UuidValue?> {
  StoredGpsRecordTable({super.tableRelation}) : super(tableName: 'gps_record') {
    updateTable = StoredGpsRecordUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    clientRecordId = _is.ColumnUuid(
      'clientRecordId',
      this,
    );
    persistedAt = _is.ColumnDateTime(
      'persistedAt',
      this,
    );
    payload = _is.ColumnSerializable<_i7qho75c.GpsRecordInput>(
      'payload',
      this,
    );
    deleted = _is.ColumnBool(
      'deleted',
      this,
      hasDefault: true,
    );
    firstLocalDay = _is.ColumnInt(
      'firstLocalDay',
      this,
    );
    lastLocalDay = _is.ColumnInt(
      'lastLocalDay',
      this,
    );
  }

  late final StoredGpsRecordUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnUuid clientRecordId;

  late final _is.ColumnDateTime persistedAt;

  late final _is.ColumnSerializable<_i7qho75c.GpsRecordInput> payload;

  late final _is.ColumnBool deleted;

  late final _is.ColumnInt firstLocalDay;

  late final _is.ColumnInt lastLocalDay;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: StoredGpsRecord.t.authUserId,
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
    owner,
    authUserId,
    clientRecordId,
    persistedAt,
    payload,
    deleted,
    firstLocalDay,
    lastLocalDay,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class StoredGpsRecordInclude extends _is.IncludeObject {
  StoredGpsRecordInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<_is.UuidValue?> get table => StoredGpsRecord.t;
}

class StoredGpsRecordIncludeList extends _is.IncludeList {
  StoredGpsRecordIncludeList._({
    _is.WhereExpressionBuilder<StoredGpsRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StoredGpsRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => StoredGpsRecord.t;
}

class StoredGpsRecordRepository {
  const StoredGpsRecordRepository._();

  final attachRow = const StoredGpsRecordAttachRowRepository._();

  final detachRow = const StoredGpsRecordDetachRowRepository._();

  /// Returns a list of [StoredGpsRecord]s matching the given query parameters.
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
  Future<List<StoredGpsRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredGpsRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredGpsRecordTable>? orderBy,
    _is.OrderByListBuilder<StoredGpsRecordTable>? orderByList,
    _is.Transaction? transaction,
    StoredGpsRecordInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StoredGpsRecord>(
      where: where?.call(StoredGpsRecord.t),
      orderBy: orderBy?.call(StoredGpsRecord.t),
      orderByList: orderByList?.call(StoredGpsRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StoredGpsRecord] matching the given query parameters.
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
  Future<StoredGpsRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredGpsRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<StoredGpsRecordTable>? orderBy,
    _is.OrderByListBuilder<StoredGpsRecordTable>? orderByList,
    _is.Transaction? transaction,
    StoredGpsRecordInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StoredGpsRecord>(
      where: where?.call(StoredGpsRecord.t),
      orderBy: orderBy?.call(StoredGpsRecord.t),
      orderByList: orderByList?.call(StoredGpsRecord.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StoredGpsRecord] by its [id] or null if no such row exists.
  Future<StoredGpsRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    StoredGpsRecordInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StoredGpsRecord>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StoredGpsRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [StoredGpsRecord]s will have their `id` fields set.
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
  Future<List<StoredGpsRecord>> insert(
    _is.DatabaseSession session,
    List<StoredGpsRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StoredGpsRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StoredGpsRecord] and returns the inserted row.
  ///
  /// The returned [StoredGpsRecord] will have its `id` field set.
  Future<StoredGpsRecord> insertRow(
    _is.DatabaseSession session,
    StoredGpsRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StoredGpsRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StoredGpsRecord]s in the list and returns the resulting rows.
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
  /// The returned [StoredGpsRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredGpsRecord>> upsert(
    _is.DatabaseSession session,
    List<StoredGpsRecord> rows, {
    required _is.ColumnSelections<StoredGpsRecordTable> conflictColumns,
    _is.ColumnSelections<StoredGpsRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<StoredGpsRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StoredGpsRecord>(
      rows,
      conflictColumns: conflictColumns(StoredGpsRecord.t),
      updateColumns: updateColumns?.call(StoredGpsRecord.t),
      updateWhere: updateWhere?.call(StoredGpsRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StoredGpsRecord] and returns the resulting row.
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
  /// The returned [StoredGpsRecord] will have its `id` field set.
  Future<StoredGpsRecord?> upsertRow(
    _is.DatabaseSession session,
    StoredGpsRecord row, {
    required _is.ColumnSelections<StoredGpsRecordTable> conflictColumns,
    _is.ColumnSelections<StoredGpsRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<StoredGpsRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StoredGpsRecord>(
      row,
      conflictColumns: conflictColumns(StoredGpsRecord.t),
      updateColumns: updateColumns?.call(StoredGpsRecord.t),
      updateWhere: updateWhere?.call(StoredGpsRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [StoredGpsRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredGpsRecord>> update(
    _is.DatabaseSession session,
    List<StoredGpsRecord> rows, {
    _is.ColumnSelections<StoredGpsRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StoredGpsRecord>(
      rows,
      columns: columns?.call(StoredGpsRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StoredGpsRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StoredGpsRecord> updateRow(
    _is.DatabaseSession session,
    StoredGpsRecord row, {
    _is.ColumnSelections<StoredGpsRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StoredGpsRecord>(
      row,
      columns: columns?.call(StoredGpsRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoredGpsRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StoredGpsRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<StoredGpsRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StoredGpsRecord>(
      id,
      columnValues: columnValues(StoredGpsRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StoredGpsRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredGpsRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StoredGpsRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<StoredGpsRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredGpsRecordTable>? orderBy,
    _is.OrderByListBuilder<StoredGpsRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StoredGpsRecord>(
      columnValues: columnValues(StoredGpsRecord.t.updateTable),
      where: where(StoredGpsRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoredGpsRecord.t),
      orderByList: orderByList?.call(StoredGpsRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StoredGpsRecord]s in the list and returns the deleted rows.
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
  Future<List<StoredGpsRecord>> delete(
    _is.DatabaseSession session,
    List<StoredGpsRecord> rows, {
    _is.OrderByBuilder<StoredGpsRecordTable>? orderBy,
    _is.OrderByListBuilder<StoredGpsRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StoredGpsRecord>(
      rows,
      orderBy: orderBy?.call(StoredGpsRecord.t),
      orderByList: orderByList?.call(StoredGpsRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StoredGpsRecord].
  Future<StoredGpsRecord> deleteRow(
    _is.DatabaseSession session,
    StoredGpsRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StoredGpsRecord>(
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
  Future<List<StoredGpsRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StoredGpsRecordTable> where,
    _is.OrderByBuilder<StoredGpsRecordTable>? orderBy,
    _is.OrderByListBuilder<StoredGpsRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StoredGpsRecord>(
      where: where(StoredGpsRecord.t),
      orderBy: orderBy?.call(StoredGpsRecord.t),
      orderByList: orderByList?.call(StoredGpsRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredGpsRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StoredGpsRecord>(
      where: where?.call(StoredGpsRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StoredGpsRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StoredGpsRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StoredGpsRecord>(
      where: where(StoredGpsRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class StoredGpsRecordAttachRowRepository {
  const StoredGpsRecordAttachRowRepository._();

  /// Creates a relation between the given [StoredGpsRecord] and [AuthUser]
  /// by setting the [StoredGpsRecord]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    StoredGpsRecord storedGpsRecord,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (storedGpsRecord.id == null) {
      throw ArgumentError.notNull('storedGpsRecord.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $storedGpsRecord = storedGpsRecord.copyWith(authUserId: authUser.id);
    await session.db.updateRow<StoredGpsRecord>(
      $storedGpsRecord,
      columns: [StoredGpsRecord.t.authUserId],
      transaction: transaction,
    );
  }
}

class StoredGpsRecordDetachRowRepository {
  const StoredGpsRecordDetachRowRepository._();

  /// Detaches the relation between this [StoredGpsRecord] and the [AuthUser] set in `authUser`
  /// by setting the [StoredGpsRecord]'s foreign key `authUserId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> authUser(
    _is.DatabaseSession session,
    StoredGpsRecord storedGpsRecord, {
    _is.Transaction? transaction,
  }) async {
    if (storedGpsRecord.id == null) {
      throw ArgumentError.notNull('storedGpsRecord.id');
    }

    var $storedGpsRecord = storedGpsRecord.copyWith(authUserId: null);
    await session.db.updateRow<StoredGpsRecord>(
      $storedGpsRecord,
      columns: [StoredGpsRecord.t.authUserId],
      transaction: transaction,
    );
  }
}
