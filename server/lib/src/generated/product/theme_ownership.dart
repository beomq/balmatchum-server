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

abstract class ThemeOwnership
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ThemeOwnership._({
    this.id,
    required this.owner,
    this.authUserId,
    this.authUser,
    required this.themeId,
    required this.purchasedAt,
  });

  factory ThemeOwnership({
    int? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String themeId,
    required DateTime purchasedAt,
  }) = _ThemeOwnershipImpl;

  factory ThemeOwnership.fromJson(Map<String, dynamic> jsonSerialization) {
    return ThemeOwnership(
      id: jsonSerialization['id'] as int?,
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
      themeId: jsonSerialization['themeId'] as String,
      purchasedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['purchasedAt'],
      ),
    );
  }

  static final t = ThemeOwnershipTable();

  static const db = ThemeOwnershipRepository._();

  @override
  int? id;

  String owner;

  _is.UuidValue? authUserId;

  _iacs.AuthUser? authUser;

  String themeId;

  DateTime purchasedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ThemeOwnership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ThemeOwnership copyWith({
    int? id,
    String? owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? themeId,
    DateTime? purchasedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ThemeOwnership',
      if (id != null) 'id': id,
      'owner': owner,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'themeId': themeId,
      'purchasedAt': purchasedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ThemeOwnershipInclude include({_iacs.AuthUserInclude? authUser}) {
    return ThemeOwnershipInclude._(authUser: authUser);
  }

  static ThemeOwnershipIncludeList includeList({
    _is.WhereExpressionBuilder<ThemeOwnershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ThemeOwnershipTable>? orderBy,
    _is.OrderByListBuilder<ThemeOwnershipTable>? orderByList,
    ThemeOwnershipInclude? include,
  }) {
    return ThemeOwnershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ThemeOwnership.t),
      orderByList: orderByList?.call(ThemeOwnership.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ThemeOwnershipImpl extends ThemeOwnership {
  _ThemeOwnershipImpl({
    int? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String themeId,
    required DateTime purchasedAt,
  }) : super._(
         id: id,
         owner: owner,
         authUserId: authUserId,
         authUser: authUser,
         themeId: themeId,
         purchasedAt: purchasedAt,
       );

  /// Returns a shallow copy of this [ThemeOwnership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ThemeOwnership copyWith({
    Object? id = _Undefined,
    String? owner,
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    String? themeId,
    DateTime? purchasedAt,
  }) {
    return ThemeOwnership(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      authUserId: authUserId is _is.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      themeId: themeId ?? this.themeId,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}

class ThemeOwnershipUpdateTable extends _is.UpdateTable<ThemeOwnershipTable> {
  ThemeOwnershipUpdateTable(super.table);

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

  _is.ColumnValue<String, String> themeId(String value) => _is.ColumnValue(
    table.themeId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> purchasedAt(DateTime value) =>
      _is.ColumnValue(
        table.purchasedAt,
        value,
      );
}

class ThemeOwnershipTable extends _is.Table<int?> {
  ThemeOwnershipTable({super.tableRelation})
    : super(tableName: 'theme_ownership') {
    updateTable = ThemeOwnershipUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    themeId = _is.ColumnString(
      'themeId',
      this,
    );
    purchasedAt = _is.ColumnDateTime(
      'purchasedAt',
      this,
    );
  }

  late final ThemeOwnershipUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString themeId;

  late final _is.ColumnDateTime purchasedAt;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: ThemeOwnership.t.authUserId,
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
    themeId,
    purchasedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class ThemeOwnershipInclude extends _is.IncludeObject {
  ThemeOwnershipInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => ThemeOwnership.t;
}

class ThemeOwnershipIncludeList extends _is.IncludeList {
  ThemeOwnershipIncludeList._({
    _is.WhereExpressionBuilder<ThemeOwnershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ThemeOwnership.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ThemeOwnership.t;
}

class ThemeOwnershipRepository {
  const ThemeOwnershipRepository._();

  final attachRow = const ThemeOwnershipAttachRowRepository._();

  final detachRow = const ThemeOwnershipDetachRowRepository._();

  /// Returns a list of [ThemeOwnership]s matching the given query parameters.
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
  Future<List<ThemeOwnership>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ThemeOwnershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ThemeOwnershipTable>? orderBy,
    _is.OrderByListBuilder<ThemeOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    ThemeOwnershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ThemeOwnership>(
      where: where?.call(ThemeOwnership.t),
      orderBy: orderBy?.call(ThemeOwnership.t),
      orderByList: orderByList?.call(ThemeOwnership.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ThemeOwnership] matching the given query parameters.
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
  Future<ThemeOwnership?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ThemeOwnershipTable>? where,
    int? offset,
    _is.OrderByBuilder<ThemeOwnershipTable>? orderBy,
    _is.OrderByListBuilder<ThemeOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    ThemeOwnershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ThemeOwnership>(
      where: where?.call(ThemeOwnership.t),
      orderBy: orderBy?.call(ThemeOwnership.t),
      orderByList: orderByList?.call(ThemeOwnership.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ThemeOwnership] by its [id] or null if no such row exists.
  Future<ThemeOwnership?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    ThemeOwnershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ThemeOwnership>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ThemeOwnership]s in the list and returns the inserted rows.
  ///
  /// The returned [ThemeOwnership]s will have their `id` fields set.
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
  Future<List<ThemeOwnership>> insert(
    _is.DatabaseSession session,
    List<ThemeOwnership> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ThemeOwnership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ThemeOwnership] and returns the inserted row.
  ///
  /// The returned [ThemeOwnership] will have its `id` field set.
  Future<ThemeOwnership> insertRow(
    _is.DatabaseSession session,
    ThemeOwnership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ThemeOwnership>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ThemeOwnership]s in the list and returns the resulting rows.
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
  /// The returned [ThemeOwnership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ThemeOwnership>> upsert(
    _is.DatabaseSession session,
    List<ThemeOwnership> rows, {
    required _is.ColumnSelections<ThemeOwnershipTable> conflictColumns,
    _is.ColumnSelections<ThemeOwnershipTable>? updateColumns,
    _is.WhereExpressionBuilder<ThemeOwnershipTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ThemeOwnership>(
      rows,
      conflictColumns: conflictColumns(ThemeOwnership.t),
      updateColumns: updateColumns?.call(ThemeOwnership.t),
      updateWhere: updateWhere?.call(ThemeOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ThemeOwnership] and returns the resulting row.
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
  /// The returned [ThemeOwnership] will have its `id` field set.
  Future<ThemeOwnership?> upsertRow(
    _is.DatabaseSession session,
    ThemeOwnership row, {
    required _is.ColumnSelections<ThemeOwnershipTable> conflictColumns,
    _is.ColumnSelections<ThemeOwnershipTable>? updateColumns,
    _is.WhereExpressionBuilder<ThemeOwnershipTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ThemeOwnership>(
      row,
      conflictColumns: conflictColumns(ThemeOwnership.t),
      updateColumns: updateColumns?.call(ThemeOwnership.t),
      updateWhere: updateWhere?.call(ThemeOwnership.t),
      transaction: transaction,
    );
  }

  /// Updates all [ThemeOwnership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ThemeOwnership>> update(
    _is.DatabaseSession session,
    List<ThemeOwnership> rows, {
    _is.ColumnSelections<ThemeOwnershipTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ThemeOwnership>(
      rows,
      columns: columns?.call(ThemeOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ThemeOwnership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ThemeOwnership> updateRow(
    _is.DatabaseSession session,
    ThemeOwnership row, {
    _is.ColumnSelections<ThemeOwnershipTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ThemeOwnership>(
      row,
      columns: columns?.call(ThemeOwnership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ThemeOwnership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ThemeOwnership?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ThemeOwnershipUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ThemeOwnership>(
      id,
      columnValues: columnValues(ThemeOwnership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ThemeOwnership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ThemeOwnership>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ThemeOwnershipUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ThemeOwnershipTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ThemeOwnershipTable>? orderBy,
    _is.OrderByListBuilder<ThemeOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ThemeOwnership>(
      columnValues: columnValues(ThemeOwnership.t.updateTable),
      where: where(ThemeOwnership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ThemeOwnership.t),
      orderByList: orderByList?.call(ThemeOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ThemeOwnership]s in the list and returns the deleted rows.
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
  Future<List<ThemeOwnership>> delete(
    _is.DatabaseSession session,
    List<ThemeOwnership> rows, {
    _is.OrderByBuilder<ThemeOwnershipTable>? orderBy,
    _is.OrderByListBuilder<ThemeOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ThemeOwnership>(
      rows,
      orderBy: orderBy?.call(ThemeOwnership.t),
      orderByList: orderByList?.call(ThemeOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ThemeOwnership].
  Future<ThemeOwnership> deleteRow(
    _is.DatabaseSession session,
    ThemeOwnership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ThemeOwnership>(
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
  Future<List<ThemeOwnership>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ThemeOwnershipTable> where,
    _is.OrderByBuilder<ThemeOwnershipTable>? orderBy,
    _is.OrderByListBuilder<ThemeOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ThemeOwnership>(
      where: where(ThemeOwnership.t),
      orderBy: orderBy?.call(ThemeOwnership.t),
      orderByList: orderByList?.call(ThemeOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ThemeOwnershipTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ThemeOwnership>(
      where: where?.call(ThemeOwnership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ThemeOwnership] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ThemeOwnershipTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ThemeOwnership>(
      where: where(ThemeOwnership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ThemeOwnershipAttachRowRepository {
  const ThemeOwnershipAttachRowRepository._();

  /// Creates a relation between the given [ThemeOwnership] and [AuthUser]
  /// by setting the [ThemeOwnership]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    ThemeOwnership themeOwnership,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (themeOwnership.id == null) {
      throw ArgumentError.notNull('themeOwnership.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $themeOwnership = themeOwnership.copyWith(authUserId: authUser.id);
    await session.db.updateRow<ThemeOwnership>(
      $themeOwnership,
      columns: [ThemeOwnership.t.authUserId],
      transaction: transaction,
    );
  }
}

class ThemeOwnershipDetachRowRepository {
  const ThemeOwnershipDetachRowRepository._();

  /// Detaches the relation between this [ThemeOwnership] and the [AuthUser] set in `authUser`
  /// by setting the [ThemeOwnership]'s foreign key `authUserId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> authUser(
    _is.DatabaseSession session,
    ThemeOwnership themeOwnership, {
    _is.Transaction? transaction,
  }) async {
    if (themeOwnership.id == null) {
      throw ArgumentError.notNull('themeOwnership.id');
    }

    var $themeOwnership = themeOwnership.copyWith(authUserId: null);
    await session.db.updateRow<ThemeOwnership>(
      $themeOwnership,
      columns: [ThemeOwnership.t.authUserId],
      transaction: transaction,
    );
  }
}
