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

abstract class NaverGrant
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  NaverGrant._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.clientId,
    required this.refreshToken,
  });

  factory NaverGrant({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String clientId,
    required String refreshToken,
  }) = _NaverGrantImpl;

  factory NaverGrant.fromJson(Map<String, dynamic> jsonSerialization) {
    return NaverGrant(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      clientId: jsonSerialization['clientId'] as String,
      refreshToken: jsonSerialization['refreshToken'] as String,
    );
  }

  static final t = NaverGrantTable();

  static const db = NaverGrantRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String clientId;

  String refreshToken;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [NaverGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NaverGrant copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? clientId,
    String? refreshToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NaverGrant',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'clientId': clientId,
      'refreshToken': refreshToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static NaverGrantInclude include({_iacs.AuthUserInclude? authUser}) {
    return NaverGrantInclude._(authUser: authUser);
  }

  static NaverGrantIncludeList includeList({
    _is.WhereExpressionBuilder<NaverGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NaverGrantTable>? orderBy,
    _is.OrderByListBuilder<NaverGrantTable>? orderByList,
    NaverGrantInclude? include,
  }) {
    return NaverGrantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NaverGrant.t),
      orderByList: orderByList?.call(NaverGrant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NaverGrantImpl extends NaverGrant {
  _NaverGrantImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String clientId,
    required String refreshToken,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         clientId: clientId,
         refreshToken: refreshToken,
       );

  /// Returns a shallow copy of this [NaverGrant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NaverGrant copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? clientId,
    String? refreshToken,
  }) {
    return NaverGrant(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      clientId: clientId ?? this.clientId,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

class NaverGrantUpdateTable extends _is.UpdateTable<NaverGrantTable> {
  NaverGrantUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> clientId(String value) => _is.ColumnValue(
    table.clientId,
    value,
  );

  _is.ColumnValue<String, String> refreshToken(String value) => _is.ColumnValue(
    table.refreshToken,
    value,
  );
}

class NaverGrantTable extends _is.Table<int?> {
  NaverGrantTable({super.tableRelation}) : super(tableName: 'naver_grant') {
    updateTable = NaverGrantUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    clientId = _is.ColumnString(
      'clientId',
      this,
    );
    refreshToken = _is.ColumnString(
      'refreshToken',
      this,
    );
  }

  late final NaverGrantUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString clientId;

  late final _is.ColumnString refreshToken;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: NaverGrant.t.authUserId,
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
    clientId,
    refreshToken,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class NaverGrantInclude extends _is.IncludeObject {
  NaverGrantInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => NaverGrant.t;
}

class NaverGrantIncludeList extends _is.IncludeList {
  NaverGrantIncludeList._({
    _is.WhereExpressionBuilder<NaverGrantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(NaverGrant.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => NaverGrant.t;
}

class NaverGrantRepository {
  const NaverGrantRepository._();

  final attachRow = const NaverGrantAttachRowRepository._();

  /// Returns a list of [NaverGrant]s matching the given query parameters.
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
  Future<List<NaverGrant>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NaverGrantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NaverGrantTable>? orderBy,
    _is.OrderByListBuilder<NaverGrantTable>? orderByList,
    _is.Transaction? transaction,
    NaverGrantInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<NaverGrant>(
      where: where?.call(NaverGrant.t),
      orderBy: orderBy?.call(NaverGrant.t),
      orderByList: orderByList?.call(NaverGrant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [NaverGrant] matching the given query parameters.
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
  Future<NaverGrant?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NaverGrantTable>? where,
    int? offset,
    _is.OrderByBuilder<NaverGrantTable>? orderBy,
    _is.OrderByListBuilder<NaverGrantTable>? orderByList,
    _is.Transaction? transaction,
    NaverGrantInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<NaverGrant>(
      where: where?.call(NaverGrant.t),
      orderBy: orderBy?.call(NaverGrant.t),
      orderByList: orderByList?.call(NaverGrant.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [NaverGrant] by its [id] or null if no such row exists.
  Future<NaverGrant?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    NaverGrantInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<NaverGrant>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [NaverGrant]s in the list and returns the inserted rows.
  ///
  /// The returned [NaverGrant]s will have their `id` fields set.
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
  Future<List<NaverGrant>> insert(
    _is.DatabaseSession session,
    List<NaverGrant> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<NaverGrant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [NaverGrant] and returns the inserted row.
  ///
  /// The returned [NaverGrant] will have its `id` field set.
  Future<NaverGrant> insertRow(
    _is.DatabaseSession session,
    NaverGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<NaverGrant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [NaverGrant]s in the list and returns the resulting rows.
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
  /// The returned [NaverGrant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NaverGrant>> upsert(
    _is.DatabaseSession session,
    List<NaverGrant> rows, {
    required _is.ColumnSelections<NaverGrantTable> conflictColumns,
    _is.ColumnSelections<NaverGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<NaverGrantTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<NaverGrant>(
      rows,
      conflictColumns: conflictColumns(NaverGrant.t),
      updateColumns: updateColumns?.call(NaverGrant.t),
      updateWhere: updateWhere?.call(NaverGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [NaverGrant] and returns the resulting row.
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
  /// The returned [NaverGrant] will have its `id` field set.
  Future<NaverGrant?> upsertRow(
    _is.DatabaseSession session,
    NaverGrant row, {
    required _is.ColumnSelections<NaverGrantTable> conflictColumns,
    _is.ColumnSelections<NaverGrantTable>? updateColumns,
    _is.WhereExpressionBuilder<NaverGrantTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<NaverGrant>(
      row,
      conflictColumns: conflictColumns(NaverGrant.t),
      updateColumns: updateColumns?.call(NaverGrant.t),
      updateWhere: updateWhere?.call(NaverGrant.t),
      transaction: transaction,
    );
  }

  /// Updates all [NaverGrant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NaverGrant>> update(
    _is.DatabaseSession session,
    List<NaverGrant> rows, {
    _is.ColumnSelections<NaverGrantTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<NaverGrant>(
      rows,
      columns: columns?.call(NaverGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [NaverGrant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<NaverGrant> updateRow(
    _is.DatabaseSession session,
    NaverGrant row, {
    _is.ColumnSelections<NaverGrantTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<NaverGrant>(
      row,
      columns: columns?.call(NaverGrant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NaverGrant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<NaverGrant?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<NaverGrantUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<NaverGrant>(
      id,
      columnValues: columnValues(NaverGrant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [NaverGrant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NaverGrant>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<NaverGrantUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<NaverGrantTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NaverGrantTable>? orderBy,
    _is.OrderByListBuilder<NaverGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<NaverGrant>(
      columnValues: columnValues(NaverGrant.t.updateTable),
      where: where(NaverGrant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NaverGrant.t),
      orderByList: orderByList?.call(NaverGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [NaverGrant]s in the list and returns the deleted rows.
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
  Future<List<NaverGrant>> delete(
    _is.DatabaseSession session,
    List<NaverGrant> rows, {
    _is.OrderByBuilder<NaverGrantTable>? orderBy,
    _is.OrderByListBuilder<NaverGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<NaverGrant>(
      rows,
      orderBy: orderBy?.call(NaverGrant.t),
      orderByList: orderByList?.call(NaverGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [NaverGrant].
  Future<NaverGrant> deleteRow(
    _is.DatabaseSession session,
    NaverGrant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<NaverGrant>(
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
  Future<List<NaverGrant>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NaverGrantTable> where,
    _is.OrderByBuilder<NaverGrantTable>? orderBy,
    _is.OrderByListBuilder<NaverGrantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<NaverGrant>(
      where: where(NaverGrant.t),
      orderBy: orderBy?.call(NaverGrant.t),
      orderByList: orderByList?.call(NaverGrant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NaverGrantTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<NaverGrant>(
      where: where?.call(NaverGrant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [NaverGrant] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NaverGrantTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<NaverGrant>(
      where: where(NaverGrant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class NaverGrantAttachRowRepository {
  const NaverGrantAttachRowRepository._();

  /// Creates a relation between the given [NaverGrant] and [AuthUser]
  /// by setting the [NaverGrant]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    NaverGrant naverGrant,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (naverGrant.id == null) {
      throw ArgumentError.notNull('naverGrant.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $naverGrant = naverGrant.copyWith(authUserId: authUser.id);
    await session.db.updateRow<NaverGrant>(
      $naverGrant,
      columns: [NaverGrant.t.authUserId],
      transaction: transaction,
    );
  }
}
