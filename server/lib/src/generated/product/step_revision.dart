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

abstract class StepRevision
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  StepRevision._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.date,
    required this.generation,
    required this.revision,
    required this.digest,
  });

  factory StepRevision({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String date,
    required int generation,
    required int revision,
    required String digest,
  }) = _StepRevisionImpl;

  factory StepRevision.fromJson(Map<String, dynamic> jsonSerialization) {
    return StepRevision(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      date: jsonSerialization['date'] as String,
      generation: jsonSerialization['generation'] as int,
      revision: jsonSerialization['revision'] as int,
      digest: jsonSerialization['digest'] as String,
    );
  }

  static final t = StepRevisionTable();

  static const db = StepRevisionRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String date;

  int generation;

  int revision;

  String digest;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [StepRevision]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StepRevision copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? date,
    int? generation,
    int? revision,
    String? digest,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StepRevision',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'date': date,
      'generation': generation,
      'revision': revision,
      'digest': digest,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StepRevisionInclude include({_iacs.AuthUserInclude? authUser}) {
    return StepRevisionInclude._(authUser: authUser);
  }

  static StepRevisionIncludeList includeList({
    _is.WhereExpressionBuilder<StepRevisionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StepRevisionTable>? orderBy,
    _is.OrderByListBuilder<StepRevisionTable>? orderByList,
    StepRevisionInclude? include,
  }) {
    return StepRevisionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StepRevision.t),
      orderByList: orderByList?.call(StepRevision.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StepRevisionImpl extends StepRevision {
  _StepRevisionImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String date,
    required int generation,
    required int revision,
    required String digest,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         date: date,
         generation: generation,
         revision: revision,
         digest: digest,
       );

  /// Returns a shallow copy of this [StepRevision]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StepRevision copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? date,
    int? generation,
    int? revision,
    String? digest,
  }) {
    return StepRevision(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      date: date ?? this.date,
      generation: generation ?? this.generation,
      revision: revision ?? this.revision,
      digest: digest ?? this.digest,
    );
  }
}

class StepRevisionUpdateTable extends _is.UpdateTable<StepRevisionTable> {
  StepRevisionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> date(String value) => _is.ColumnValue(
    table.date,
    value,
  );

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<String, String> digest(String value) => _is.ColumnValue(
    table.digest,
    value,
  );
}

class StepRevisionTable extends _is.Table<int?> {
  StepRevisionTable({super.tableRelation}) : super(tableName: 'step_revision') {
    updateTable = StepRevisionUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    date = _is.ColumnString(
      'date',
      this,
    );
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    digest = _is.ColumnString(
      'digest',
      this,
    );
  }

  late final StepRevisionUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString date;

  late final _is.ColumnInt generation;

  late final _is.ColumnInt revision;

  late final _is.ColumnString digest;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: StepRevision.t.authUserId,
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
    date,
    generation,
    revision,
    digest,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class StepRevisionInclude extends _is.IncludeObject {
  StepRevisionInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => StepRevision.t;
}

class StepRevisionIncludeList extends _is.IncludeList {
  StepRevisionIncludeList._({
    _is.WhereExpressionBuilder<StepRevisionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StepRevision.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => StepRevision.t;
}

class StepRevisionRepository {
  const StepRevisionRepository._();

  final attachRow = const StepRevisionAttachRowRepository._();

  /// Returns a list of [StepRevision]s matching the given query parameters.
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
  Future<List<StepRevision>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StepRevisionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StepRevisionTable>? orderBy,
    _is.OrderByListBuilder<StepRevisionTable>? orderByList,
    _is.Transaction? transaction,
    StepRevisionInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StepRevision>(
      where: where?.call(StepRevision.t),
      orderBy: orderBy?.call(StepRevision.t),
      orderByList: orderByList?.call(StepRevision.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StepRevision] matching the given query parameters.
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
  Future<StepRevision?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StepRevisionTable>? where,
    int? offset,
    _is.OrderByBuilder<StepRevisionTable>? orderBy,
    _is.OrderByListBuilder<StepRevisionTable>? orderByList,
    _is.Transaction? transaction,
    StepRevisionInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StepRevision>(
      where: where?.call(StepRevision.t),
      orderBy: orderBy?.call(StepRevision.t),
      orderByList: orderByList?.call(StepRevision.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StepRevision] by its [id] or null if no such row exists.
  Future<StepRevision?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    StepRevisionInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StepRevision>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StepRevision]s in the list and returns the inserted rows.
  ///
  /// The returned [StepRevision]s will have their `id` fields set.
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
  Future<List<StepRevision>> insert(
    _is.DatabaseSession session,
    List<StepRevision> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StepRevision>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StepRevision] and returns the inserted row.
  ///
  /// The returned [StepRevision] will have its `id` field set.
  Future<StepRevision> insertRow(
    _is.DatabaseSession session,
    StepRevision row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StepRevision>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StepRevision]s in the list and returns the resulting rows.
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
  /// The returned [StepRevision]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StepRevision>> upsert(
    _is.DatabaseSession session,
    List<StepRevision> rows, {
    required _is.ColumnSelections<StepRevisionTable> conflictColumns,
    _is.ColumnSelections<StepRevisionTable>? updateColumns,
    _is.WhereExpressionBuilder<StepRevisionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StepRevision>(
      rows,
      conflictColumns: conflictColumns(StepRevision.t),
      updateColumns: updateColumns?.call(StepRevision.t),
      updateWhere: updateWhere?.call(StepRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StepRevision] and returns the resulting row.
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
  /// The returned [StepRevision] will have its `id` field set.
  Future<StepRevision?> upsertRow(
    _is.DatabaseSession session,
    StepRevision row, {
    required _is.ColumnSelections<StepRevisionTable> conflictColumns,
    _is.ColumnSelections<StepRevisionTable>? updateColumns,
    _is.WhereExpressionBuilder<StepRevisionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StepRevision>(
      row,
      conflictColumns: conflictColumns(StepRevision.t),
      updateColumns: updateColumns?.call(StepRevision.t),
      updateWhere: updateWhere?.call(StepRevision.t),
      transaction: transaction,
    );
  }

  /// Updates all [StepRevision]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StepRevision>> update(
    _is.DatabaseSession session,
    List<StepRevision> rows, {
    _is.ColumnSelections<StepRevisionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StepRevision>(
      rows,
      columns: columns?.call(StepRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StepRevision]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StepRevision> updateRow(
    _is.DatabaseSession session,
    StepRevision row, {
    _is.ColumnSelections<StepRevisionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StepRevision>(
      row,
      columns: columns?.call(StepRevision.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StepRevision] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StepRevision?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StepRevisionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StepRevision>(
      id,
      columnValues: columnValues(StepRevision.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StepRevision]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StepRevision>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StepRevisionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StepRevisionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StepRevisionTable>? orderBy,
    _is.OrderByListBuilder<StepRevisionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StepRevision>(
      columnValues: columnValues(StepRevision.t.updateTable),
      where: where(StepRevision.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StepRevision.t),
      orderByList: orderByList?.call(StepRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StepRevision]s in the list and returns the deleted rows.
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
  Future<List<StepRevision>> delete(
    _is.DatabaseSession session,
    List<StepRevision> rows, {
    _is.OrderByBuilder<StepRevisionTable>? orderBy,
    _is.OrderByListBuilder<StepRevisionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StepRevision>(
      rows,
      orderBy: orderBy?.call(StepRevision.t),
      orderByList: orderByList?.call(StepRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StepRevision].
  Future<StepRevision> deleteRow(
    _is.DatabaseSession session,
    StepRevision row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StepRevision>(
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
  Future<List<StepRevision>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StepRevisionTable> where,
    _is.OrderByBuilder<StepRevisionTable>? orderBy,
    _is.OrderByListBuilder<StepRevisionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StepRevision>(
      where: where(StepRevision.t),
      orderBy: orderBy?.call(StepRevision.t),
      orderByList: orderByList?.call(StepRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StepRevisionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StepRevision>(
      where: where?.call(StepRevision.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StepRevision] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StepRevisionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StepRevision>(
      where: where(StepRevision.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class StepRevisionAttachRowRepository {
  const StepRevisionAttachRowRepository._();

  /// Creates a relation between the given [StepRevision] and [AuthUser]
  /// by setting the [StepRevision]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    StepRevision stepRevision,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (stepRevision.id == null) {
      throw ArgumentError.notNull('stepRevision.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $stepRevision = stepRevision.copyWith(authUserId: authUser.id);
    await session.db.updateRow<StepRevision>(
      $stepRevision,
      columns: [StepRevision.t.authUserId],
      transaction: transaction,
    );
  }
}
