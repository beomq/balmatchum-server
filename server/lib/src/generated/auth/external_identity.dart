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

abstract class ExternalIdentity
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ExternalIdentity._({
    this.id,
    required this.provider,
    required this.issuer,
    required this.audience,
    required this.subjectNamespace,
    required this.subject,
    required this.authUserId,
  });

  factory ExternalIdentity({
    int? id,
    required String provider,
    required String issuer,
    required String audience,
    required String subjectNamespace,
    required String subject,
    required _is.UuidValue authUserId,
  }) = _ExternalIdentityImpl;

  factory ExternalIdentity.fromJson(Map<String, dynamic> jsonSerialization) {
    return ExternalIdentity(
      id: jsonSerialization['id'] as int?,
      provider: jsonSerialization['provider'] as String,
      issuer: jsonSerialization['issuer'] as String,
      audience: jsonSerialization['audience'] as String,
      subjectNamespace: jsonSerialization['subjectNamespace'] as String,
      subject: jsonSerialization['subject'] as String,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
    );
  }

  static final t = ExternalIdentityTable();

  static const db = ExternalIdentityRepository._();

  @override
  int? id;

  String provider;

  String issuer;

  String audience;

  String subjectNamespace;

  String subject;

  _is.UuidValue authUserId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ExternalIdentity]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ExternalIdentity copyWith({
    int? id,
    String? provider,
    String? issuer,
    String? audience,
    String? subjectNamespace,
    String? subject,
    _is.UuidValue? authUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ExternalIdentity',
      if (id != null) 'id': id,
      'provider': provider,
      'issuer': issuer,
      'audience': audience,
      'subjectNamespace': subjectNamespace,
      'subject': subject,
      'authUserId': authUserId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ExternalIdentityInclude include() {
    return ExternalIdentityInclude._();
  }

  static ExternalIdentityIncludeList includeList({
    _is.WhereExpressionBuilder<ExternalIdentityTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ExternalIdentityTable>? orderBy,
    _is.OrderByListBuilder<ExternalIdentityTable>? orderByList,
    ExternalIdentityInclude? include,
  }) {
    return ExternalIdentityIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ExternalIdentity.t),
      orderByList: orderByList?.call(ExternalIdentity.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ExternalIdentityImpl extends ExternalIdentity {
  _ExternalIdentityImpl({
    int? id,
    required String provider,
    required String issuer,
    required String audience,
    required String subjectNamespace,
    required String subject,
    required _is.UuidValue authUserId,
  }) : super._(
         id: id,
         provider: provider,
         issuer: issuer,
         audience: audience,
         subjectNamespace: subjectNamespace,
         subject: subject,
         authUserId: authUserId,
       );

  /// Returns a shallow copy of this [ExternalIdentity]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ExternalIdentity copyWith({
    Object? id = _Undefined,
    String? provider,
    String? issuer,
    String? audience,
    String? subjectNamespace,
    String? subject,
    _is.UuidValue? authUserId,
  }) {
    return ExternalIdentity(
      id: id is int? ? id : this.id,
      provider: provider ?? this.provider,
      issuer: issuer ?? this.issuer,
      audience: audience ?? this.audience,
      subjectNamespace: subjectNamespace ?? this.subjectNamespace,
      subject: subject ?? this.subject,
      authUserId: authUserId ?? this.authUserId,
    );
  }
}

class ExternalIdentityUpdateTable
    extends _is.UpdateTable<ExternalIdentityTable> {
  ExternalIdentityUpdateTable(super.table);

  _is.ColumnValue<String, String> provider(String value) => _is.ColumnValue(
    table.provider,
    value,
  );

  _is.ColumnValue<String, String> issuer(String value) => _is.ColumnValue(
    table.issuer,
    value,
  );

  _is.ColumnValue<String, String> audience(String value) => _is.ColumnValue(
    table.audience,
    value,
  );

  _is.ColumnValue<String, String> subjectNamespace(String value) =>
      _is.ColumnValue(
        table.subjectNamespace,
        value,
      );

  _is.ColumnValue<String, String> subject(String value) => _is.ColumnValue(
    table.subject,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );
}

class ExternalIdentityTable extends _is.Table<int?> {
  ExternalIdentityTable({super.tableRelation})
    : super(tableName: 'external_identity') {
    updateTable = ExternalIdentityUpdateTable(this);
    provider = _is.ColumnString(
      'provider',
      this,
    );
    issuer = _is.ColumnString(
      'issuer',
      this,
    );
    audience = _is.ColumnString(
      'audience',
      this,
    );
    subjectNamespace = _is.ColumnString(
      'subjectNamespace',
      this,
    );
    subject = _is.ColumnString(
      'subject',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
  }

  late final ExternalIdentityUpdateTable updateTable;

  late final _is.ColumnString provider;

  late final _is.ColumnString issuer;

  late final _is.ColumnString audience;

  late final _is.ColumnString subjectNamespace;

  late final _is.ColumnString subject;

  late final _is.ColumnUuid authUserId;

  @override
  List<_is.Column> get columns => [
    id,
    provider,
    issuer,
    audience,
    subjectNamespace,
    subject,
    authUserId,
  ];
}

class ExternalIdentityInclude extends _is.IncludeObject {
  ExternalIdentityInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ExternalIdentity.t;
}

class ExternalIdentityIncludeList extends _is.IncludeList {
  ExternalIdentityIncludeList._({
    _is.WhereExpressionBuilder<ExternalIdentityTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ExternalIdentity.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ExternalIdentity.t;
}

class ExternalIdentityRepository {
  const ExternalIdentityRepository._();

  /// Returns a list of [ExternalIdentity]s matching the given query parameters.
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
  Future<List<ExternalIdentity>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ExternalIdentityTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ExternalIdentityTable>? orderBy,
    _is.OrderByListBuilder<ExternalIdentityTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ExternalIdentity>(
      where: where?.call(ExternalIdentity.t),
      orderBy: orderBy?.call(ExternalIdentity.t),
      orderByList: orderByList?.call(ExternalIdentity.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ExternalIdentity] matching the given query parameters.
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
  Future<ExternalIdentity?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ExternalIdentityTable>? where,
    int? offset,
    _is.OrderByBuilder<ExternalIdentityTable>? orderBy,
    _is.OrderByListBuilder<ExternalIdentityTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ExternalIdentity>(
      where: where?.call(ExternalIdentity.t),
      orderBy: orderBy?.call(ExternalIdentity.t),
      orderByList: orderByList?.call(ExternalIdentity.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ExternalIdentity] by its [id] or null if no such row exists.
  Future<ExternalIdentity?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ExternalIdentity>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ExternalIdentity]s in the list and returns the inserted rows.
  ///
  /// The returned [ExternalIdentity]s will have their `id` fields set.
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
  Future<List<ExternalIdentity>> insert(
    _is.DatabaseSession session,
    List<ExternalIdentity> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ExternalIdentity>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ExternalIdentity] and returns the inserted row.
  ///
  /// The returned [ExternalIdentity] will have its `id` field set.
  Future<ExternalIdentity> insertRow(
    _is.DatabaseSession session,
    ExternalIdentity row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ExternalIdentity>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ExternalIdentity]s in the list and returns the resulting rows.
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
  /// The returned [ExternalIdentity]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ExternalIdentity>> upsert(
    _is.DatabaseSession session,
    List<ExternalIdentity> rows, {
    required _is.ColumnSelections<ExternalIdentityTable> conflictColumns,
    _is.ColumnSelections<ExternalIdentityTable>? updateColumns,
    _is.WhereExpressionBuilder<ExternalIdentityTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ExternalIdentity>(
      rows,
      conflictColumns: conflictColumns(ExternalIdentity.t),
      updateColumns: updateColumns?.call(ExternalIdentity.t),
      updateWhere: updateWhere?.call(ExternalIdentity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ExternalIdentity] and returns the resulting row.
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
  /// The returned [ExternalIdentity] will have its `id` field set.
  Future<ExternalIdentity?> upsertRow(
    _is.DatabaseSession session,
    ExternalIdentity row, {
    required _is.ColumnSelections<ExternalIdentityTable> conflictColumns,
    _is.ColumnSelections<ExternalIdentityTable>? updateColumns,
    _is.WhereExpressionBuilder<ExternalIdentityTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ExternalIdentity>(
      row,
      conflictColumns: conflictColumns(ExternalIdentity.t),
      updateColumns: updateColumns?.call(ExternalIdentity.t),
      updateWhere: updateWhere?.call(ExternalIdentity.t),
      transaction: transaction,
    );
  }

  /// Updates all [ExternalIdentity]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ExternalIdentity>> update(
    _is.DatabaseSession session,
    List<ExternalIdentity> rows, {
    _is.ColumnSelections<ExternalIdentityTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ExternalIdentity>(
      rows,
      columns: columns?.call(ExternalIdentity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ExternalIdentity]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ExternalIdentity> updateRow(
    _is.DatabaseSession session,
    ExternalIdentity row, {
    _is.ColumnSelections<ExternalIdentityTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ExternalIdentity>(
      row,
      columns: columns?.call(ExternalIdentity.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ExternalIdentity] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ExternalIdentity?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ExternalIdentityUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ExternalIdentity>(
      id,
      columnValues: columnValues(ExternalIdentity.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ExternalIdentity]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ExternalIdentity>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ExternalIdentityUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ExternalIdentityTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ExternalIdentityTable>? orderBy,
    _is.OrderByListBuilder<ExternalIdentityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ExternalIdentity>(
      columnValues: columnValues(ExternalIdentity.t.updateTable),
      where: where(ExternalIdentity.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ExternalIdentity.t),
      orderByList: orderByList?.call(ExternalIdentity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ExternalIdentity]s in the list and returns the deleted rows.
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
  Future<List<ExternalIdentity>> delete(
    _is.DatabaseSession session,
    List<ExternalIdentity> rows, {
    _is.OrderByBuilder<ExternalIdentityTable>? orderBy,
    _is.OrderByListBuilder<ExternalIdentityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ExternalIdentity>(
      rows,
      orderBy: orderBy?.call(ExternalIdentity.t),
      orderByList: orderByList?.call(ExternalIdentity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ExternalIdentity].
  Future<ExternalIdentity> deleteRow(
    _is.DatabaseSession session,
    ExternalIdentity row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ExternalIdentity>(
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
  Future<List<ExternalIdentity>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ExternalIdentityTable> where,
    _is.OrderByBuilder<ExternalIdentityTable>? orderBy,
    _is.OrderByListBuilder<ExternalIdentityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ExternalIdentity>(
      where: where(ExternalIdentity.t),
      orderBy: orderBy?.call(ExternalIdentity.t),
      orderByList: orderByList?.call(ExternalIdentity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ExternalIdentityTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ExternalIdentity>(
      where: where?.call(ExternalIdentity.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ExternalIdentity] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ExternalIdentityTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ExternalIdentity>(
      where: where(ExternalIdentity.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
