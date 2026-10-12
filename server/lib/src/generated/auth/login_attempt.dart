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

abstract class LoginAttempt
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  LoginAttempt._({
    this.id,
    required this.nonceHash,
    required this.expiresAt,
    this.consumedAt,
  });

  factory LoginAttempt({
    _is.UuidValue? id,
    required String nonceHash,
    required DateTime expiresAt,
    DateTime? consumedAt,
  }) = _LoginAttemptImpl;

  factory LoginAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return LoginAttempt(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      nonceHash: jsonSerialization['nonceHash'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
    );
  }

  static final t = LoginAttemptTable();

  static const db = LoginAttemptRepository._();

  @override
  _is.UuidValue? id;

  String nonceHash;

  DateTime expiresAt;

  DateTime? consumedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [LoginAttempt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LoginAttempt copyWith({
    _is.UuidValue? id,
    String? nonceHash,
    DateTime? expiresAt,
    DateTime? consumedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LoginAttempt',
      if (id != null) 'id': id?.toJson(),
      'nonceHash': nonceHash,
      'expiresAt': expiresAt.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static LoginAttemptInclude include() {
    return LoginAttemptInclude._();
  }

  static LoginAttemptIncludeList includeList({
    _is.WhereExpressionBuilder<LoginAttemptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<LoginAttemptTable>? orderByList,
    LoginAttemptInclude? include,
  }) {
    return LoginAttemptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LoginAttempt.t),
      orderByList: orderByList?.call(LoginAttempt.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LoginAttemptImpl extends LoginAttempt {
  _LoginAttemptImpl({
    _is.UuidValue? id,
    required String nonceHash,
    required DateTime expiresAt,
    DateTime? consumedAt,
  }) : super._(
         id: id,
         nonceHash: nonceHash,
         expiresAt: expiresAt,
         consumedAt: consumedAt,
       );

  /// Returns a shallow copy of this [LoginAttempt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LoginAttempt copyWith({
    Object? id = _Undefined,
    String? nonceHash,
    DateTime? expiresAt,
    Object? consumedAt = _Undefined,
  }) {
    return LoginAttempt(
      id: id is _is.UuidValue? ? id : this.id,
      nonceHash: nonceHash ?? this.nonceHash,
      expiresAt: expiresAt ?? this.expiresAt,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
    );
  }
}

class LoginAttemptUpdateTable extends _is.UpdateTable<LoginAttemptTable> {
  LoginAttemptUpdateTable(super.table);

  _is.ColumnValue<String, String> nonceHash(String value) => _is.ColumnValue(
    table.nonceHash,
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

class LoginAttemptTable extends _is.Table<_is.UuidValue?> {
  LoginAttemptTable({super.tableRelation}) : super(tableName: 'login_attempt') {
    updateTable = LoginAttemptUpdateTable(this);
    nonceHash = _is.ColumnString(
      'nonceHash',
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

  late final LoginAttemptUpdateTable updateTable;

  late final _is.ColumnString nonceHash;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime consumedAt;

  @override
  List<_is.Column> get columns => [
    id,
    nonceHash,
    expiresAt,
    consumedAt,
  ];
}

class LoginAttemptInclude extends _is.IncludeObject {
  LoginAttemptInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => LoginAttempt.t;
}

class LoginAttemptIncludeList extends _is.IncludeList {
  LoginAttemptIncludeList._({
    _is.WhereExpressionBuilder<LoginAttemptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LoginAttempt.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => LoginAttempt.t;
}

class LoginAttemptRepository {
  const LoginAttemptRepository._();

  /// Returns a list of [LoginAttempt]s matching the given query parameters.
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
  Future<List<LoginAttempt>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LoginAttemptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<LoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LoginAttempt>(
      where: where?.call(LoginAttempt.t),
      orderBy: orderBy?.call(LoginAttempt.t),
      orderByList: orderByList?.call(LoginAttempt.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [LoginAttempt] matching the given query parameters.
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
  Future<LoginAttempt?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LoginAttemptTable>? where,
    int? offset,
    _is.OrderByBuilder<LoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<LoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LoginAttempt>(
      where: where?.call(LoginAttempt.t),
      orderBy: orderBy?.call(LoginAttempt.t),
      orderByList: orderByList?.call(LoginAttempt.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LoginAttempt] by its [id] or null if no such row exists.
  Future<LoginAttempt?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LoginAttempt>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LoginAttempt]s in the list and returns the inserted rows.
  ///
  /// The returned [LoginAttempt]s will have their `id` fields set.
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
  Future<List<LoginAttempt>> insert(
    _is.DatabaseSession session,
    List<LoginAttempt> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LoginAttempt>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LoginAttempt] and returns the inserted row.
  ///
  /// The returned [LoginAttempt] will have its `id` field set.
  Future<LoginAttempt> insertRow(
    _is.DatabaseSession session,
    LoginAttempt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<LoginAttempt>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [LoginAttempt]s in the list and returns the resulting rows.
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
  /// The returned [LoginAttempt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LoginAttempt>> upsert(
    _is.DatabaseSession session,
    List<LoginAttempt> rows, {
    required _is.ColumnSelections<LoginAttemptTable> conflictColumns,
    _is.ColumnSelections<LoginAttemptTable>? updateColumns,
    _is.WhereExpressionBuilder<LoginAttemptTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LoginAttempt>(
      rows,
      conflictColumns: conflictColumns(LoginAttempt.t),
      updateColumns: updateColumns?.call(LoginAttempt.t),
      updateWhere: updateWhere?.call(LoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LoginAttempt] and returns the resulting row.
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
  /// The returned [LoginAttempt] will have its `id` field set.
  Future<LoginAttempt?> upsertRow(
    _is.DatabaseSession session,
    LoginAttempt row, {
    required _is.ColumnSelections<LoginAttemptTable> conflictColumns,
    _is.ColumnSelections<LoginAttemptTable>? updateColumns,
    _is.WhereExpressionBuilder<LoginAttemptTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LoginAttempt>(
      row,
      conflictColumns: conflictColumns(LoginAttempt.t),
      updateColumns: updateColumns?.call(LoginAttempt.t),
      updateWhere: updateWhere?.call(LoginAttempt.t),
      transaction: transaction,
    );
  }

  /// Updates all [LoginAttempt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LoginAttempt>> update(
    _is.DatabaseSession session,
    List<LoginAttempt> rows, {
    _is.ColumnSelections<LoginAttemptTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LoginAttempt>(
      rows,
      columns: columns?.call(LoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LoginAttempt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LoginAttempt> updateRow(
    _is.DatabaseSession session,
    LoginAttempt row, {
    _is.ColumnSelections<LoginAttemptTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<LoginAttempt>(
      row,
      columns: columns?.call(LoginAttempt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LoginAttempt] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LoginAttempt?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<LoginAttemptUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<LoginAttempt>(
      id,
      columnValues: columnValues(LoginAttempt.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LoginAttempt]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LoginAttempt>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<LoginAttemptUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<LoginAttemptTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<LoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LoginAttempt>(
      columnValues: columnValues(LoginAttempt.t.updateTable),
      where: where(LoginAttempt.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LoginAttempt.t),
      orderByList: orderByList?.call(LoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LoginAttempt]s in the list and returns the deleted rows.
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
  Future<List<LoginAttempt>> delete(
    _is.DatabaseSession session,
    List<LoginAttempt> rows, {
    _is.OrderByBuilder<LoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<LoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LoginAttempt>(
      rows,
      orderBy: orderBy?.call(LoginAttempt.t),
      orderByList: orderByList?.call(LoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LoginAttempt].
  Future<LoginAttempt> deleteRow(
    _is.DatabaseSession session,
    LoginAttempt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LoginAttempt>(
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
  Future<List<LoginAttempt>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LoginAttemptTable> where,
    _is.OrderByBuilder<LoginAttemptTable>? orderBy,
    _is.OrderByListBuilder<LoginAttemptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LoginAttempt>(
      where: where(LoginAttempt.t),
      orderBy: orderBy?.call(LoginAttempt.t),
      orderByList: orderByList?.call(LoginAttempt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LoginAttemptTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<LoginAttempt>(
      where: where?.call(LoginAttempt.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LoginAttempt] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LoginAttemptTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LoginAttempt>(
      where: where(LoginAttempt.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
