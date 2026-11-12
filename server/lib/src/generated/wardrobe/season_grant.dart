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

/// A season set handed to a paid subscriber, at most once per user and set.
abstract class SeasonGrant
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SeasonGrant._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.setId,
    required this.grantedAt,
    required this.reason,
  });

  factory SeasonGrant({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String setId,
    required DateTime grantedAt,
    required String reason,
  }) = _SeasonGrantImpl;

  factory SeasonGrant.fromJson(Map<String, dynamic> jsonSerialization) {
    return SeasonGrant(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      setId: jsonSerialization['setId'] as String,
      grantedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['grantedAt'],
      ),
      reason: jsonSerialization['reason'] as String,
    );
  }

  static final t = SeasonGrantTable();

  static const db = SeasonGrantRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String setId;

  DateTime grantedAt;

  /// release (window-open sweep) or subscribe (became active in the window).
  String reason;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SeasonGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SeasonGrant copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? setId,
    DateTime? grantedAt,
    String? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SeasonGrant',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'setId': setId,
      'grantedAt': grantedAt.toJson(),
      'reason': reason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SeasonGrantInclude include({_iacs.AuthUserInclude? authUser}) {
    return SeasonGrantInclude._(authUser: authUser);
  }

  static SeasonGrantIncludeList includeList({
    _is.WhereExpressionBuilder<SeasonGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SeasonGrantTable>? orderBy,
    _is.OrderByListBuilder<SeasonGrantTable>? orderByList,
    SeasonGrantInclude? include,
  }) {
    return SeasonGrantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SeasonGrant.t),
      orderByList: orderByList?.call(SeasonGrant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SeasonGrantImpl extends SeasonGrant {
  _SeasonGrantImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String setId,
    required DateTime grantedAt,
    required String reason,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         setId: setId,
         grantedAt: grantedAt,
         reason: reason,
       );

  /// Returns a shallow copy of this [SeasonGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SeasonGrant copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? setId,
    DateTime? grantedAt,
    String? reason,
  }) {
    return SeasonGrant(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      setId: setId ?? this.setId,
      grantedAt: grantedAt ?? this.grantedAt,
      reason: reason ?? this.reason,
    );
  }
}

class SeasonGrantUpdateTable extends _is.UpdateTable<SeasonGrantTable> {
  SeasonGrantUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> setId(String value) => _is.ColumnValue(
    table.setId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> grantedAt(DateTime value) =>
      _is.ColumnValue(
        table.grantedAt,
        value,
      );

  _is.ColumnValue<String, String> reason(String value) => _is.ColumnValue(
    table.reason,
    value,
  );
}

class SeasonGrantTable extends _is.Table<int?> {
  SeasonGrantTable({super.tableRelation}) : super(tableName: 'season_grant') {
    updateTable = SeasonGrantUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    setId = _is.ColumnString(
      'setId',
      this,
    );
    grantedAt = _is.ColumnDateTime(
      'grantedAt',
      this,
    );
    reason = _is.ColumnString(
      'reason',
      this,
    );
  }

  late final SeasonGrantUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString setId;

  late final _is.ColumnDateTime grantedAt;

  /// release (window-open sweep) or subscribe (became active in the window).
  late final _is.ColumnString reason;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: SeasonGrant.t.authUserId,
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
    setId,
    grantedAt,
    reason,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class SeasonGrantInclude extends _is.IncludeObject {
  SeasonGrantInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => SeasonGrant.t;
}

class SeasonGrantIncludeList extends _is.IncludeList {
  SeasonGrantIncludeList._({
    _is.WhereExpressionBuilder<SeasonGrantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SeasonGrant.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SeasonGrant.t;
}

class SeasonGrantRepository {
  const SeasonGrantRepository._();

  final attachRow = const SeasonGrantAttachRowRepository._();

  /// Returns a list of [SeasonGrant]s matching the given query parameters.
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
  Future<List<SeasonGrant>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SeasonGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SeasonGrantTable>? orderBy,
    _is.OrderByListBuilder<SeasonGrantTable>? orderByList,
    _is.Transaction? transaction,
    SeasonGrantInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SeasonGrant>(
      where: where?.call(SeasonGrant.t),
      orderBy: orderBy?.call(SeasonGrant.t),
      orderByList: orderByList?.call(SeasonGrant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SeasonGrant] matching the given query parameters.
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
  Future<SeasonGrant?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SeasonGrantTable>? where,
    int? offset,
    _is.OrderByBuilder<SeasonGrantTable>? orderBy,
    _is.OrderByListBuilder<SeasonGrantTable>? orderByList,
    _is.Transaction? transaction,
    SeasonGrantInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SeasonGrant>(
      where: where?.call(SeasonGrant.t),
      orderBy: orderBy?.call(SeasonGrant.t),
      orderByList: orderByList?.call(SeasonGrant.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SeasonGrant] by its [id] or null if no such row exists.
  Future<SeasonGrant?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    SeasonGrantInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SeasonGrant>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SeasonGrant]s in the list and returns the inserted rows.
  ///
  /// The returned [SeasonGrant]s will have their `id` fields set.
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
  Future<List<SeasonGrant>> insert(
    _is.DatabaseSession session,
    List<SeasonGrant> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SeasonGrant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SeasonGrant] and returns the inserted row.
  ///
  /// The returned [SeasonGrant] will have its `id` field set.
  Future<SeasonGrant> insertRow(
    _is.DatabaseSession session,
    SeasonGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SeasonGrant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SeasonGrant]s in the list and returns the resulting rows.
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
  /// The returned [SeasonGrant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SeasonGrant>> upsert(
    _is.DatabaseSession session,
    List<SeasonGrant> rows, {
    required _is.ColumnSelections<SeasonGrantTable> conflictColumns,
    _is.ColumnSelections<SeasonGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<SeasonGrantTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SeasonGrant>(
      rows,
      conflictColumns: conflictColumns(SeasonGrant.t),
      updateColumns: updateColumns?.call(SeasonGrant.t),
      updateWhere: updateWhere?.call(SeasonGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SeasonGrant] and returns the resulting row.
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
  /// The returned [SeasonGrant] will have its `id` field set.
  Future<SeasonGrant?> upsertRow(
    _is.DatabaseSession session,
    SeasonGrant row, {
    required _is.ColumnSelections<SeasonGrantTable> conflictColumns,
    _is.ColumnSelections<SeasonGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<SeasonGrantTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SeasonGrant>(
      row,
      conflictColumns: conflictColumns(SeasonGrant.t),
      updateColumns: updateColumns?.call(SeasonGrant.t),
      updateWhere: updateWhere?.call(SeasonGrant.t),
      transaction: transaction,
    );
  }

  /// Updates all [SeasonGrant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SeasonGrant>> update(
    _is.DatabaseSession session,
    List<SeasonGrant> rows, {
    _is.ColumnSelections<SeasonGrantTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SeasonGrant>(
      rows,
      columns: columns?.call(SeasonGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SeasonGrant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SeasonGrant> updateRow(
    _is.DatabaseSession session,
    SeasonGrant row, {
    _is.ColumnSelections<SeasonGrantTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SeasonGrant>(
      row,
      columns: columns?.call(SeasonGrant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SeasonGrant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SeasonGrant?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SeasonGrantUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SeasonGrant>(
      id,
      columnValues: columnValues(SeasonGrant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SeasonGrant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SeasonGrant>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SeasonGrantUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SeasonGrantTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SeasonGrantTable>? orderBy,
    _is.OrderByListBuilder<SeasonGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SeasonGrant>(
      columnValues: columnValues(SeasonGrant.t.updateTable),
      where: where(SeasonGrant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SeasonGrant.t),
      orderByList: orderByList?.call(SeasonGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SeasonGrant]s in the list and returns the deleted rows.
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
  Future<List<SeasonGrant>> delete(
    _is.DatabaseSession session,
    List<SeasonGrant> rows, {
    _is.OrderByBuilder<SeasonGrantTable>? orderBy,
    _is.OrderByListBuilder<SeasonGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SeasonGrant>(
      rows,
      orderBy: orderBy?.call(SeasonGrant.t),
      orderByList: orderByList?.call(SeasonGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SeasonGrant].
  Future<SeasonGrant> deleteRow(
    _is.DatabaseSession session,
    SeasonGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SeasonGrant>(
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
  Future<List<SeasonGrant>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SeasonGrantTable> where,
    _is.OrderByBuilder<SeasonGrantTable>? orderBy,
    _is.OrderByListBuilder<SeasonGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SeasonGrant>(
      where: where(SeasonGrant.t),
      orderBy: orderBy?.call(SeasonGrant.t),
      orderByList: orderByList?.call(SeasonGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SeasonGrantTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SeasonGrant>(
      where: where?.call(SeasonGrant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SeasonGrant] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SeasonGrantTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SeasonGrant>(
      where: where(SeasonGrant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class SeasonGrantAttachRowRepository {
  const SeasonGrantAttachRowRepository._();

  /// Creates a relation between the given [SeasonGrant] and [AuthUser]
  /// by setting the [SeasonGrant]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    SeasonGrant seasonGrant,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (seasonGrant.id == null) {
      throw ArgumentError.notNull('seasonGrant.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $seasonGrant = seasonGrant.copyWith(authUserId: authUser.id);
    await session.db.updateRow<SeasonGrant>(
      $seasonGrant,
      columns: [SeasonGrant.t.authUserId],
      transaction: transaction,
    );
  }
}
