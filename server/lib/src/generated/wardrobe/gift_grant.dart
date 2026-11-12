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

/// A monthly gift handed to a paying member, at most once per user and month.
abstract class GiftGrant
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  GiftGrant._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.month,
    this.setId,
    this.itemId,
    required this.grantedAt,
    required this.reason,
  });

  factory GiftGrant({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String month,
    String? setId,
    String? itemId,
    required DateTime grantedAt,
    required String reason,
  }) = _GiftGrantImpl;

  factory GiftGrant.fromJson(Map<String, dynamic> jsonSerialization) {
    return GiftGrant(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      month: jsonSerialization['month'] as String,
      setId: jsonSerialization['setId'] as String?,
      itemId: jsonSerialization['itemId'] as String?,
      grantedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['grantedAt'],
      ),
      reason: jsonSerialization['reason'] as String,
    );
  }

  static final t = GiftGrantTable();

  static const db = GiftGrantRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  /// KST month of the gift, yyyy-MM.
  String month;

  /// Exactly one of setId / itemId: what the gift was.
  String? setId;

  String? itemId;

  DateTime grantedAt;

  /// release (monthly sweep) or subscribe (became a member in the month).
  String reason;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GiftGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GiftGrant copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? month,
    String? setId,
    String? itemId,
    DateTime? grantedAt,
    String? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GiftGrant',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'month': month,
      if (setId != null) 'setId': setId,
      if (itemId != null) 'itemId': itemId,
      'grantedAt': grantedAt.toJson(),
      'reason': reason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static GiftGrantInclude include({_iacs.AuthUserInclude? authUser}) {
    return GiftGrantInclude._(authUser: authUser);
  }

  static GiftGrantIncludeList includeList({
    _is.WhereExpressionBuilder<GiftGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GiftGrantTable>? orderBy,
    _is.OrderByListBuilder<GiftGrantTable>? orderByList,
    GiftGrantInclude? include,
  }) {
    return GiftGrantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GiftGrant.t),
      orderByList: orderByList?.call(GiftGrant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GiftGrantImpl extends GiftGrant {
  _GiftGrantImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String month,
    String? setId,
    String? itemId,
    required DateTime grantedAt,
    required String reason,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         month: month,
         setId: setId,
         itemId: itemId,
         grantedAt: grantedAt,
         reason: reason,
       );

  /// Returns a shallow copy of this [GiftGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GiftGrant copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? month,
    Object? setId = _Undefined,
    Object? itemId = _Undefined,
    DateTime? grantedAt,
    String? reason,
  }) {
    return GiftGrant(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      month: month ?? this.month,
      setId: setId is String? ? setId : this.setId,
      itemId: itemId is String? ? itemId : this.itemId,
      grantedAt: grantedAt ?? this.grantedAt,
      reason: reason ?? this.reason,
    );
  }
}

class GiftGrantUpdateTable extends _is.UpdateTable<GiftGrantTable> {
  GiftGrantUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> month(String value) => _is.ColumnValue(
    table.month,
    value,
  );

  _is.ColumnValue<String, String> setId(String? value) => _is.ColumnValue(
    table.setId,
    value,
  );

  _is.ColumnValue<String, String> itemId(String? value) => _is.ColumnValue(
    table.itemId,
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

class GiftGrantTable extends _is.Table<int?> {
  GiftGrantTable({super.tableRelation}) : super(tableName: 'gift_grant') {
    updateTable = GiftGrantUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    month = _is.ColumnString(
      'month',
      this,
    );
    setId = _is.ColumnString(
      'setId',
      this,
    );
    itemId = _is.ColumnString(
      'itemId',
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

  late final GiftGrantUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  /// KST month of the gift, yyyy-MM.
  late final _is.ColumnString month;

  /// Exactly one of setId / itemId: what the gift was.
  late final _is.ColumnString setId;

  late final _is.ColumnString itemId;

  late final _is.ColumnDateTime grantedAt;

  /// release (monthly sweep) or subscribe (became a member in the month).
  late final _is.ColumnString reason;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: GiftGrant.t.authUserId,
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
    month,
    setId,
    itemId,
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

class GiftGrantInclude extends _is.IncludeObject {
  GiftGrantInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => GiftGrant.t;
}

class GiftGrantIncludeList extends _is.IncludeList {
  GiftGrantIncludeList._({
    _is.WhereExpressionBuilder<GiftGrantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GiftGrant.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GiftGrant.t;
}

class GiftGrantRepository {
  const GiftGrantRepository._();

  final attachRow = const GiftGrantAttachRowRepository._();

  /// Returns a list of [GiftGrant]s matching the given query parameters.
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
  Future<List<GiftGrant>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GiftGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GiftGrantTable>? orderBy,
    _is.OrderByListBuilder<GiftGrantTable>? orderByList,
    _is.Transaction? transaction,
    GiftGrantInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GiftGrant>(
      where: where?.call(GiftGrant.t),
      orderBy: orderBy?.call(GiftGrant.t),
      orderByList: orderByList?.call(GiftGrant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GiftGrant] matching the given query parameters.
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
  Future<GiftGrant?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GiftGrantTable>? where,
    int? offset,
    _is.OrderByBuilder<GiftGrantTable>? orderBy,
    _is.OrderByListBuilder<GiftGrantTable>? orderByList,
    _is.Transaction? transaction,
    GiftGrantInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GiftGrant>(
      where: where?.call(GiftGrant.t),
      orderBy: orderBy?.call(GiftGrant.t),
      orderByList: orderByList?.call(GiftGrant.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GiftGrant] by its [id] or null if no such row exists.
  Future<GiftGrant?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    GiftGrantInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GiftGrant>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GiftGrant]s in the list and returns the inserted rows.
  ///
  /// The returned [GiftGrant]s will have their `id` fields set.
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
  Future<List<GiftGrant>> insert(
    _is.DatabaseSession session,
    List<GiftGrant> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GiftGrant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GiftGrant] and returns the inserted row.
  ///
  /// The returned [GiftGrant] will have its `id` field set.
  Future<GiftGrant> insertRow(
    _is.DatabaseSession session,
    GiftGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GiftGrant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GiftGrant]s in the list and returns the resulting rows.
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
  /// The returned [GiftGrant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GiftGrant>> upsert(
    _is.DatabaseSession session,
    List<GiftGrant> rows, {
    required _is.ColumnSelections<GiftGrantTable> conflictColumns,
    _is.ColumnSelections<GiftGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<GiftGrantTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GiftGrant>(
      rows,
      conflictColumns: conflictColumns(GiftGrant.t),
      updateColumns: updateColumns?.call(GiftGrant.t),
      updateWhere: updateWhere?.call(GiftGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GiftGrant] and returns the resulting row.
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
  /// The returned [GiftGrant] will have its `id` field set.
  Future<GiftGrant?> upsertRow(
    _is.DatabaseSession session,
    GiftGrant row, {
    required _is.ColumnSelections<GiftGrantTable> conflictColumns,
    _is.ColumnSelections<GiftGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<GiftGrantTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GiftGrant>(
      row,
      conflictColumns: conflictColumns(GiftGrant.t),
      updateColumns: updateColumns?.call(GiftGrant.t),
      updateWhere: updateWhere?.call(GiftGrant.t),
      transaction: transaction,
    );
  }

  /// Updates all [GiftGrant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GiftGrant>> update(
    _is.DatabaseSession session,
    List<GiftGrant> rows, {
    _is.ColumnSelections<GiftGrantTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GiftGrant>(
      rows,
      columns: columns?.call(GiftGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GiftGrant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GiftGrant> updateRow(
    _is.DatabaseSession session,
    GiftGrant row, {
    _is.ColumnSelections<GiftGrantTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GiftGrant>(
      row,
      columns: columns?.call(GiftGrant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GiftGrant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GiftGrant?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GiftGrantUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GiftGrant>(
      id,
      columnValues: columnValues(GiftGrant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GiftGrant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GiftGrant>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GiftGrantUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<GiftGrantTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GiftGrantTable>? orderBy,
    _is.OrderByListBuilder<GiftGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GiftGrant>(
      columnValues: columnValues(GiftGrant.t.updateTable),
      where: where(GiftGrant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GiftGrant.t),
      orderByList: orderByList?.call(GiftGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GiftGrant]s in the list and returns the deleted rows.
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
  Future<List<GiftGrant>> delete(
    _is.DatabaseSession session,
    List<GiftGrant> rows, {
    _is.OrderByBuilder<GiftGrantTable>? orderBy,
    _is.OrderByListBuilder<GiftGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GiftGrant>(
      rows,
      orderBy: orderBy?.call(GiftGrant.t),
      orderByList: orderByList?.call(GiftGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GiftGrant].
  Future<GiftGrant> deleteRow(
    _is.DatabaseSession session,
    GiftGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GiftGrant>(
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
  Future<List<GiftGrant>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GiftGrantTable> where,
    _is.OrderByBuilder<GiftGrantTable>? orderBy,
    _is.OrderByListBuilder<GiftGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GiftGrant>(
      where: where(GiftGrant.t),
      orderBy: orderBy?.call(GiftGrant.t),
      orderByList: orderByList?.call(GiftGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GiftGrantTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GiftGrant>(
      where: where?.call(GiftGrant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GiftGrant] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GiftGrantTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GiftGrant>(
      where: where(GiftGrant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class GiftGrantAttachRowRepository {
  const GiftGrantAttachRowRepository._();

  /// Creates a relation between the given [GiftGrant] and [AuthUser]
  /// by setting the [GiftGrant]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    GiftGrant giftGrant,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (giftGrant.id == null) {
      throw ArgumentError.notNull('giftGrant.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $giftGrant = giftGrant.copyWith(authUserId: authUser.id);
    await session.db.updateRow<GiftGrant>(
      $giftGrant,
      columns: [GiftGrant.t.authUserId],
      transaction: transaction,
    );
  }
}
