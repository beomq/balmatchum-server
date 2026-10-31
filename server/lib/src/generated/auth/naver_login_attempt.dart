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

abstract class NaverLoginAttempt
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  NaverLoginAttempt._({
    this.id,
    required this.stateHash,
    required this.nonceHash,
    required this.codeChallenge,
    required this.clientId,
    required this.redirectUri,
    required this.expiresAt,
    this.consumedAt,
  });

  factory NaverLoginAttempt({
    _is.UuidValue? id,
    required String stateHash,
    required String nonceHash,
    required String codeChallenge,
    required String clientId,
    required String redirectUri,
    required DateTime expiresAt,
    DateTime? consumedAt,
  }) = _NaverLoginAttemptImpl;

  factory NaverLoginAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return NaverLoginAttempt(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      stateHash: jsonSerialization['stateHash'] as String,
      nonceHash: jsonSerialization['nonceHash'] as String,
      codeChallenge: jsonSerialization['codeChallenge'] as String,
      clientId: jsonSerialization['clientId'] as String,
      redirectUri: jsonSerialization['redirectUri'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
    );
  }

  static final t = NaverLoginAttemptTable();

  static const db = NaverLoginAttemptRepository._();

  @override
  _is.UuidValue? id;

  String stateHash;

  String nonceHash;

  String codeChallenge;

  String clientId;

  String redirectUri;

  DateTime expiresAt;

  DateTime? consumedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [NaverLoginAttempt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NaverLoginAttempt copyWith({
    _is.UuidValue? id,
    String? stateHash,
    String? nonceHash,
    String? codeChallenge,
    String? clientId,
    String? redirectUri,
    DateTime? expiresAt,
    DateTime? consumedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NaverLoginAttempt',
      if (id != null) 'id': id?.toJson(),
      'stateHash': stateHash,
      'nonceHash': nonceHash,
      'codeChallenge': codeChallenge,
      'clientId': clientId,
      'redirectUri': redirectUri,
      'expiresAt': expiresAt.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static NaverLoginAttemptInclude include() {
    return NaverLoginAttemptInclude._();
  }

  static NaverLoginAttemptIncludeList includeList({
    _is.WhereExpressionBuilder<NaverLoginAttemptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NaverLoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<NaverLoginAttemptTable>? orderByList,
    NaverLoginAttemptInclude? include,
  }) {
    return NaverLoginAttemptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NaverLoginAttempt.t),
      orderByList: orderByList?.call(NaverLoginAttempt.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NaverLoginAttemptImpl extends NaverLoginAttempt {
  _NaverLoginAttemptImpl({
    _is.UuidValue? id,
    required String stateHash,
    required String nonceHash,
    required String codeChallenge,
    required String clientId,
    required String redirectUri,
    required DateTime expiresAt,
    DateTime? consumedAt,
  }) : super._(
         id: id,
         stateHash: stateHash,
         nonceHash: nonceHash,
         codeChallenge: codeChallenge,
         clientId: clientId,
         redirectUri: redirectUri,
         expiresAt: expiresAt,
         consumedAt: consumedAt,
       );

  /// Returns a shallow copy of this [NaverLoginAttempt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NaverLoginAttempt copyWith({
    Object? id = _Undefined,
    String? stateHash,
    String? nonceHash,
    String? codeChallenge,
    String? clientId,
    String? redirectUri,
    DateTime? expiresAt,
    Object? consumedAt = _Undefined,
  }) {
    return NaverLoginAttempt(
      id: id is _is.UuidValue? ? id : this.id,
      stateHash: stateHash ?? this.stateHash,
      nonceHash: nonceHash ?? this.nonceHash,
      codeChallenge: codeChallenge ?? this.codeChallenge,
      clientId: clientId ?? this.clientId,
      redirectUri: redirectUri ?? this.redirectUri,
      expiresAt: expiresAt ?? this.expiresAt,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
    );
  }
}

class NaverLoginAttemptUpdateTable
    extends _is.UpdateTable<NaverLoginAttemptTable> {
  NaverLoginAttemptUpdateTable(super.table);

  _is.ColumnValue<String, String> stateHash(String value) => _is.ColumnValue(
    table.stateHash,
    value,
  );

  _is.ColumnValue<String, String> nonceHash(String value) => _is.ColumnValue(
    table.nonceHash,
    value,
  );

  _is.ColumnValue<String, String> codeChallenge(String value) =>
      _is.ColumnValue(
        table.codeChallenge,
        value,
      );

  _is.ColumnValue<String, String> clientId(String value) => _is.ColumnValue(
    table.clientId,
    value,
  );

  _is.ColumnValue<String, String> redirectUri(String value) => _is.ColumnValue(
    table.redirectUri,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> consumedAt(DateTime? value) =>
      _is.ColumnValue(
        table.consumedAt,
        value,
      );
}

class NaverLoginAttemptTable extends _is.Table<_is.UuidValue?> {
  NaverLoginAttemptTable({super.tableRelation})
    : super(tableName: 'naver_login_attempt') {
    updateTable = NaverLoginAttemptUpdateTable(this);
    stateHash = _is.ColumnString(
      'stateHash',
      this,
    );
    nonceHash = _is.ColumnString(
      'nonceHash',
      this,
    );
    codeChallenge = _is.ColumnString(
      'codeChallenge',
      this,
    );
    clientId = _is.ColumnString(
      'clientId',
      this,
    );
    redirectUri = _is.ColumnString(
      'redirectUri',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    consumedAt = _is.ColumnDateTime(
      'consumedAt',
      this,
    );
  }

  late final NaverLoginAttemptUpdateTable updateTable;

  late final _is.ColumnString stateHash;

  late final _is.ColumnString nonceHash;

  late final _is.ColumnString codeChallenge;

  late final _is.ColumnString clientId;

  late final _is.ColumnString redirectUri;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime consumedAt;

  @override
  List<_is.Column> get columns => [
    id,
    stateHash,
    nonceHash,
    codeChallenge,
    clientId,
    redirectUri,
    expiresAt,
    consumedAt,
  ];
}

class NaverLoginAttemptInclude extends _is.IncludeObject {
  NaverLoginAttemptInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => NaverLoginAttempt.t;
}

class NaverLoginAttemptIncludeList extends _is.IncludeList {
  NaverLoginAttemptIncludeList._({
    _is.WhereExpressionBuilder<NaverLoginAttemptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(NaverLoginAttempt.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => NaverLoginAttempt.t;
}

class NaverLoginAttemptRepository {
  const NaverLoginAttemptRepository._();

  /// Returns a list of [NaverLoginAttempt]s matching the given query parameters.
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
  Future<List<NaverLoginAttempt>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NaverLoginAttemptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NaverLoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<NaverLoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<NaverLoginAttempt>(
      where: where?.call(NaverLoginAttempt.t),
      orderBy: orderBy?.call(NaverLoginAttempt.t),
      orderByList: orderByList?.call(NaverLoginAttempt.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [NaverLoginAttempt] matching the given query parameters.
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
  Future<NaverLoginAttempt?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NaverLoginAttemptTable>? where,
    int? offset,
    _is.OrderByBuilder<NaverLoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<NaverLoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<NaverLoginAttempt>(
      where: where?.call(NaverLoginAttempt.t),
      orderBy: orderBy?.call(NaverLoginAttempt.t),
      orderByList: orderByList?.call(NaverLoginAttempt.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [NaverLoginAttempt] by its [id] or null if no such row exists.
  Future<NaverLoginAttempt?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<NaverLoginAttempt>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [NaverLoginAttempt]s in the list and returns the inserted rows.
  ///
  /// The returned [NaverLoginAttempt]s will have their `id` fields set.
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
  Future<List<NaverLoginAttempt>> insert(
    _is.DatabaseSession session,
    List<NaverLoginAttempt> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<NaverLoginAttempt>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [NaverLoginAttempt] and returns the inserted row.
  ///
  /// The returned [NaverLoginAttempt] will have its `id` field set.
  Future<NaverLoginAttempt> insertRow(
    _is.DatabaseSession session,
    NaverLoginAttempt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<NaverLoginAttempt>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [NaverLoginAttempt]s in the list and returns the resulting rows.
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
  /// The returned [NaverLoginAttempt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NaverLoginAttempt>> upsert(
    _is.DatabaseSession session,
    List<NaverLoginAttempt> rows, {
    required _is.ColumnSelections<NaverLoginAttemptTable> conflictColumns,
    _is.ColumnSelections<NaverLoginAttemptTable>? updateColumns,
    _is.WhereExpressionBuilder<NaverLoginAttemptTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<NaverLoginAttempt>(
      rows,
      conflictColumns: conflictColumns(NaverLoginAttempt.t),
      updateColumns: updateColumns?.call(NaverLoginAttempt.t),
      updateWhere: updateWhere?.call(NaverLoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [NaverLoginAttempt] and returns the resulting row.
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
  /// The returned [NaverLoginAttempt] will have its `id` field set.
  Future<NaverLoginAttempt?> upsertRow(
    _is.DatabaseSession session,
    NaverLoginAttempt row, {
    required _is.ColumnSelections<NaverLoginAttemptTable> conflictColumns,
    _is.ColumnSelections<NaverLoginAttemptTable>? updateColumns,
    _is.WhereExpressionBuilder<NaverLoginAttemptTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<NaverLoginAttempt>(
      row,
      conflictColumns: conflictColumns(NaverLoginAttempt.t),
      updateColumns: updateColumns?.call(NaverLoginAttempt.t),
      updateWhere: updateWhere?.call(NaverLoginAttempt.t),
      transaction: transaction,
    );
  }

  /// Updates all [NaverLoginAttempt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NaverLoginAttempt>> update(
    _is.DatabaseSession session,
    List<NaverLoginAttempt> rows, {
    _is.ColumnSelections<NaverLoginAttemptTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<NaverLoginAttempt>(
      rows,
      columns: columns?.call(NaverLoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [NaverLoginAttempt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<NaverLoginAttempt> updateRow(
    _is.DatabaseSession session,
    NaverLoginAttempt row, {
    _is.ColumnSelections<NaverLoginAttemptTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<NaverLoginAttempt>(
      row,
      columns: columns?.call(NaverLoginAttempt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NaverLoginAttempt] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<NaverLoginAttempt?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<NaverLoginAttemptUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<NaverLoginAttempt>(
      id,
      columnValues: columnValues(NaverLoginAttempt.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [NaverLoginAttempt]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NaverLoginAttempt>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<NaverLoginAttemptUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<NaverLoginAttemptTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NaverLoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<NaverLoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<NaverLoginAttempt>(
      columnValues: columnValues(NaverLoginAttempt.t.updateTable),
      where: where(NaverLoginAttempt.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NaverLoginAttempt.t),
      orderByList: orderByList?.call(NaverLoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [NaverLoginAttempt]s in the list and returns the deleted rows.
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
  Future<List<NaverLoginAttempt>> delete(
    _is.DatabaseSession session,
    List<NaverLoginAttempt> rows, {
    _is.OrderByBuilder<NaverLoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<NaverLoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<NaverLoginAttempt>(
      rows,
      orderBy: orderBy?.call(NaverLoginAttempt.t),
      orderByList: orderByList?.call(NaverLoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [NaverLoginAttempt].
  Future<NaverLoginAttempt> deleteRow(
    _is.DatabaseSession session,
    NaverLoginAttempt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<NaverLoginAttempt>(
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
  Future<List<NaverLoginAttempt>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NaverLoginAttemptTable> where,
    _is.OrderByBuilder<NaverLoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<NaverLoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<NaverLoginAttempt>(
      where: where(NaverLoginAttempt.t),
      orderBy: orderBy?.call(NaverLoginAttempt.t),
      orderByList: orderByList?.call(NaverLoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NaverLoginAttemptTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<NaverLoginAttempt>(
      where: where?.call(NaverLoginAttempt.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [NaverLoginAttempt] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NaverLoginAttemptTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<NaverLoginAttempt>(
      where: where(NaverLoginAttempt.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
