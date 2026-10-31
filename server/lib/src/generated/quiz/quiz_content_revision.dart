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

abstract class QuizContentRevision
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  QuizContentRevision._({
    this.id,
    required this.questionId,
    required this.version,
    required this.snapshot,
  });

  factory QuizContentRevision({
    int? id,
    required String questionId,
    required int version,
    required String snapshot,
  }) = _QuizContentRevisionImpl;

  factory QuizContentRevision.fromJson(Map<String, dynamic> jsonSerialization) {
    return QuizContentRevision(
      id: jsonSerialization['id'] as int?,
      questionId: jsonSerialization['questionId'] as String,
      version: jsonSerialization['version'] as int,
      snapshot: jsonSerialization['snapshot'] as String,
    );
  }

  static final t = QuizContentRevisionTable();

  static const db = QuizContentRevisionRepository._();

  @override
  int? id;

  String questionId;

  int version;

  String snapshot;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [QuizContentRevision]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  QuizContentRevision copyWith({
    int? id,
    String? questionId,
    int? version,
    String? snapshot,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QuizContentRevision',
      if (id != null) 'id': id,
      'questionId': questionId,
      'version': version,
      'snapshot': snapshot,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static QuizContentRevisionInclude include() {
    return QuizContentRevisionInclude._();
  }

  static QuizContentRevisionIncludeList includeList({
    _is.WhereExpressionBuilder<QuizContentRevisionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuizContentRevisionTable>? orderBy,
    _is.OrderByListBuilder<QuizContentRevisionTable>? orderByList,
    QuizContentRevisionInclude? include,
  }) {
    return QuizContentRevisionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(QuizContentRevision.t),
      orderByList: orderByList?.call(QuizContentRevision.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuizContentRevisionImpl extends QuizContentRevision {
  _QuizContentRevisionImpl({
    int? id,
    required String questionId,
    required int version,
    required String snapshot,
  }) : super._(
         id: id,
         questionId: questionId,
         version: version,
         snapshot: snapshot,
       );

  /// Returns a shallow copy of this [QuizContentRevision]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  QuizContentRevision copyWith({
    Object? id = _Undefined,
    String? questionId,
    int? version,
    String? snapshot,
  }) {
    return QuizContentRevision(
      id: id is int? ? id : this.id,
      questionId: questionId ?? this.questionId,
      version: version ?? this.version,
      snapshot: snapshot ?? this.snapshot,
    );
  }
}

class QuizContentRevisionUpdateTable
    extends _is.UpdateTable<QuizContentRevisionTable> {
  QuizContentRevisionUpdateTable(super.table);

  _is.ColumnValue<String, String> questionId(String value) => _is.ColumnValue(
    table.questionId,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<String, String> snapshot(String value) => _is.ColumnValue(
    table.snapshot,
    value,
  );
}

class QuizContentRevisionTable extends _is.Table<int?> {
  QuizContentRevisionTable({super.tableRelation})
    : super(tableName: 'quiz_content_revision') {
    updateTable = QuizContentRevisionUpdateTable(this);
    questionId = _is.ColumnString(
      'questionId',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    snapshot = _is.ColumnString(
      'snapshot',
      this,
    );
  }

  late final QuizContentRevisionUpdateTable updateTable;

  late final _is.ColumnString questionId;

  late final _is.ColumnInt version;

  late final _is.ColumnString snapshot;

  @override
  List<_is.Column> get columns => [
    id,
    questionId,
    version,
    snapshot,
  ];
}

class QuizContentRevisionInclude extends _is.IncludeObject {
  QuizContentRevisionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => QuizContentRevision.t;
}

class QuizContentRevisionIncludeList extends _is.IncludeList {
  QuizContentRevisionIncludeList._({
    _is.WhereExpressionBuilder<QuizContentRevisionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(QuizContentRevision.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => QuizContentRevision.t;
}

class QuizContentRevisionRepository {
  const QuizContentRevisionRepository._();

  /// Returns a list of [QuizContentRevision]s matching the given query parameters.
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
  Future<List<QuizContentRevision>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuizContentRevisionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuizContentRevisionTable>? orderBy,
    _is.OrderByListBuilder<QuizContentRevisionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<QuizContentRevision>(
      where: where?.call(QuizContentRevision.t),
      orderBy: orderBy?.call(QuizContentRevision.t),
      orderByList: orderByList?.call(QuizContentRevision.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [QuizContentRevision] matching the given query parameters.
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
  Future<QuizContentRevision?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuizContentRevisionTable>? where,
    int? offset,
    _is.OrderByBuilder<QuizContentRevisionTable>? orderBy,
    _is.OrderByListBuilder<QuizContentRevisionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<QuizContentRevision>(
      where: where?.call(QuizContentRevision.t),
      orderBy: orderBy?.call(QuizContentRevision.t),
      orderByList: orderByList?.call(QuizContentRevision.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [QuizContentRevision] by its [id] or null if no such row exists.
  Future<QuizContentRevision?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<QuizContentRevision>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [QuizContentRevision]s in the list and returns the inserted rows.
  ///
  /// The returned [QuizContentRevision]s will have their `id` fields set.
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
  Future<List<QuizContentRevision>> insert(
    _is.DatabaseSession session,
    List<QuizContentRevision> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<QuizContentRevision>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [QuizContentRevision] and returns the inserted row.
  ///
  /// The returned [QuizContentRevision] will have its `id` field set.
  Future<QuizContentRevision> insertRow(
    _is.DatabaseSession session,
    QuizContentRevision row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<QuizContentRevision>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [QuizContentRevision]s in the list and returns the resulting rows.
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
  /// The returned [QuizContentRevision]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuizContentRevision>> upsert(
    _is.DatabaseSession session,
    List<QuizContentRevision> rows, {
    required _is.ColumnSelections<QuizContentRevisionTable> conflictColumns,
    _is.ColumnSelections<QuizContentRevisionTable>? updateColumns,
    _is.WhereExpressionBuilder<QuizContentRevisionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<QuizContentRevision>(
      rows,
      conflictColumns: conflictColumns(QuizContentRevision.t),
      updateColumns: updateColumns?.call(QuizContentRevision.t),
      updateWhere: updateWhere?.call(QuizContentRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [QuizContentRevision] and returns the resulting row.
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
  /// The returned [QuizContentRevision] will have its `id` field set.
  Future<QuizContentRevision?> upsertRow(
    _is.DatabaseSession session,
    QuizContentRevision row, {
    required _is.ColumnSelections<QuizContentRevisionTable> conflictColumns,
    _is.ColumnSelections<QuizContentRevisionTable>? updateColumns,
    _is.WhereExpressionBuilder<QuizContentRevisionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<QuizContentRevision>(
      row,
      conflictColumns: conflictColumns(QuizContentRevision.t),
      updateColumns: updateColumns?.call(QuizContentRevision.t),
      updateWhere: updateWhere?.call(QuizContentRevision.t),
      transaction: transaction,
    );
  }

  /// Updates all [QuizContentRevision]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuizContentRevision>> update(
    _is.DatabaseSession session,
    List<QuizContentRevision> rows, {
    _is.ColumnSelections<QuizContentRevisionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<QuizContentRevision>(
      rows,
      columns: columns?.call(QuizContentRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [QuizContentRevision]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<QuizContentRevision> updateRow(
    _is.DatabaseSession session,
    QuizContentRevision row, {
    _is.ColumnSelections<QuizContentRevisionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<QuizContentRevision>(
      row,
      columns: columns?.call(QuizContentRevision.t),
      transaction: transaction,
    );
  }

  /// Updates a single [QuizContentRevision] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<QuizContentRevision?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<QuizContentRevisionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<QuizContentRevision>(
      id,
      columnValues: columnValues(QuizContentRevision.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [QuizContentRevision]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuizContentRevision>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<QuizContentRevisionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<QuizContentRevisionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuizContentRevisionTable>? orderBy,
    _is.OrderByListBuilder<QuizContentRevisionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<QuizContentRevision>(
      columnValues: columnValues(QuizContentRevision.t.updateTable),
      where: where(QuizContentRevision.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(QuizContentRevision.t),
      orderByList: orderByList?.call(QuizContentRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [QuizContentRevision]s in the list and returns the deleted rows.
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
  Future<List<QuizContentRevision>> delete(
    _is.DatabaseSession session,
    List<QuizContentRevision> rows, {
    _is.OrderByBuilder<QuizContentRevisionTable>? orderBy,
    _is.OrderByListBuilder<QuizContentRevisionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<QuizContentRevision>(
      rows,
      orderBy: orderBy?.call(QuizContentRevision.t),
      orderByList: orderByList?.call(QuizContentRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [QuizContentRevision].
  Future<QuizContentRevision> deleteRow(
    _is.DatabaseSession session,
    QuizContentRevision row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<QuizContentRevision>(
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
  Future<List<QuizContentRevision>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<QuizContentRevisionTable> where,
    _is.OrderByBuilder<QuizContentRevisionTable>? orderBy,
    _is.OrderByListBuilder<QuizContentRevisionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<QuizContentRevision>(
      where: where(QuizContentRevision.t),
      orderBy: orderBy?.call(QuizContentRevision.t),
      orderByList: orderByList?.call(QuizContentRevision.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuizContentRevisionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<QuizContentRevision>(
      where: where?.call(QuizContentRevision.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [QuizContentRevision] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<QuizContentRevisionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<QuizContentRevision>(
      where: where(QuizContentRevision.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
