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

abstract class QuizState
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  QuizState._({
    this.id,
    required this.owner,
    required this.date,
    required this.questionId,
    this.answerIndex,
    this.answeredAt,
    int? awardedPoints,
  }) : awardedPoints = awardedPoints ?? 0;

  factory QuizState({
    int? id,
    required String owner,
    required String date,
    required String questionId,
    int? answerIndex,
    DateTime? answeredAt,
    int? awardedPoints,
  }) = _QuizStateImpl;

  factory QuizState.fromJson(Map<String, dynamic> jsonSerialization) {
    return QuizState(
      id: jsonSerialization['id'] as int?,
      owner: jsonSerialization['owner'] as String,
      date: jsonSerialization['date'] as String,
      questionId: jsonSerialization['questionId'] as String,
      answerIndex: jsonSerialization['answerIndex'] as int?,
      answeredAt: jsonSerialization['answeredAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['answeredAt']),
      awardedPoints: jsonSerialization['awardedPoints'] as int?,
    );
  }

  static final t = QuizStateTable();

  static const db = QuizStateRepository._();

  @override
  int? id;

  String owner;

  String date;

  String questionId;

  int? answerIndex;

  DateTime? answeredAt;

  int awardedPoints;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [QuizState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  QuizState copyWith({
    int? id,
    String? owner,
    String? date,
    String? questionId,
    int? answerIndex,
    DateTime? answeredAt,
    int? awardedPoints,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QuizState',
      if (id != null) 'id': id,
      'owner': owner,
      'date': date,
      'questionId': questionId,
      if (answerIndex != null) 'answerIndex': answerIndex,
      if (answeredAt != null) 'answeredAt': answeredAt?.toJson(),
      'awardedPoints': awardedPoints,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static QuizStateInclude include() {
    return QuizStateInclude._();
  }

  static QuizStateIncludeList includeList({
    _is.WhereExpressionBuilder<QuizStateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuizStateTable>? orderBy,
    _is.OrderByListBuilder<QuizStateTable>? orderByList,
    QuizStateInclude? include,
  }) {
    return QuizStateIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(QuizState.t),
      orderByList: orderByList?.call(QuizState.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuizStateImpl extends QuizState {
  _QuizStateImpl({
    int? id,
    required String owner,
    required String date,
    required String questionId,
    int? answerIndex,
    DateTime? answeredAt,
    int? awardedPoints,
  }) : super._(
         id: id,
         owner: owner,
         date: date,
         questionId: questionId,
         answerIndex: answerIndex,
         answeredAt: answeredAt,
         awardedPoints: awardedPoints,
       );

  /// Returns a shallow copy of this [QuizState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  QuizState copyWith({
    Object? id = _Undefined,
    String? owner,
    String? date,
    String? questionId,
    Object? answerIndex = _Undefined,
    Object? answeredAt = _Undefined,
    int? awardedPoints,
  }) {
    return QuizState(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      date: date ?? this.date,
      questionId: questionId ?? this.questionId,
      answerIndex: answerIndex is int? ? answerIndex : this.answerIndex,
      answeredAt: answeredAt is DateTime? ? answeredAt : this.answeredAt,
      awardedPoints: awardedPoints ?? this.awardedPoints,
    );
  }
}

class QuizStateUpdateTable extends _is.UpdateTable<QuizStateTable> {
  QuizStateUpdateTable(super.table);

  _is.ColumnValue<String, String> owner(String value) => _is.ColumnValue(
    table.owner,
    value,
  );

  _is.ColumnValue<String, String> date(String value) => _is.ColumnValue(
    table.date,
    value,
  );

  _is.ColumnValue<String, String> questionId(String value) => _is.ColumnValue(
    table.questionId,
    value,
  );

  _is.ColumnValue<int, int> answerIndex(int? value) => _is.ColumnValue(
    table.answerIndex,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> answeredAt(DateTime? value) =>
      _is.ColumnValue(
        table.answeredAt,
        value,
      );

  _is.ColumnValue<int, int> awardedPoints(int value) => _is.ColumnValue(
    table.awardedPoints,
    value,
  );
}

class QuizStateTable extends _is.Table<int?> {
  QuizStateTable({super.tableRelation}) : super(tableName: 'quiz_state') {
    updateTable = QuizStateUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    date = _is.ColumnString(
      'date',
      this,
    );
    questionId = _is.ColumnString(
      'questionId',
      this,
    );
    answerIndex = _is.ColumnInt(
      'answerIndex',
      this,
    );
    answeredAt = _is.ColumnDateTime(
      'answeredAt',
      this,
    );
    awardedPoints = _is.ColumnInt(
      'awardedPoints',
      this,
      hasDefault: true,
    );
  }

  late final QuizStateUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnString date;

  late final _is.ColumnString questionId;

  late final _is.ColumnInt answerIndex;

  late final _is.ColumnDateTime answeredAt;

  late final _is.ColumnInt awardedPoints;

  @override
  List<_is.Column> get columns => [
    id,
    owner,
    date,
    questionId,
    answerIndex,
    answeredAt,
    awardedPoints,
  ];
}

class QuizStateInclude extends _is.IncludeObject {
  QuizStateInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => QuizState.t;
}

class QuizStateIncludeList extends _is.IncludeList {
  QuizStateIncludeList._({
    _is.WhereExpressionBuilder<QuizStateTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(QuizState.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => QuizState.t;
}

class QuizStateRepository {
  const QuizStateRepository._();

  /// Returns a list of [QuizState]s matching the given query parameters.
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
  Future<List<QuizState>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuizStateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuizStateTable>? orderBy,
    _is.OrderByListBuilder<QuizStateTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<QuizState>(
      where: where?.call(QuizState.t),
      orderBy: orderBy?.call(QuizState.t),
      orderByList: orderByList?.call(QuizState.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [QuizState] matching the given query parameters.
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
  Future<QuizState?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuizStateTable>? where,
    int? offset,
    _is.OrderByBuilder<QuizStateTable>? orderBy,
    _is.OrderByListBuilder<QuizStateTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<QuizState>(
      where: where?.call(QuizState.t),
      orderBy: orderBy?.call(QuizState.t),
      orderByList: orderByList?.call(QuizState.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [QuizState] by its [id] or null if no such row exists.
  Future<QuizState?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<QuizState>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [QuizState]s in the list and returns the inserted rows.
  ///
  /// The returned [QuizState]s will have their `id` fields set.
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
  Future<List<QuizState>> insert(
    _is.DatabaseSession session,
    List<QuizState> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<QuizState>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [QuizState] and returns the inserted row.
  ///
  /// The returned [QuizState] will have its `id` field set.
  Future<QuizState> insertRow(
    _is.DatabaseSession session,
    QuizState row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<QuizState>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [QuizState]s in the list and returns the resulting rows.
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
  /// The returned [QuizState]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuizState>> upsert(
    _is.DatabaseSession session,
    List<QuizState> rows, {
    required _is.ColumnSelections<QuizStateTable> conflictColumns,
    _is.ColumnSelections<QuizStateTable>? updateColumns,
    _is.WhereExpressionBuilder<QuizStateTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<QuizState>(
      rows,
      conflictColumns: conflictColumns(QuizState.t),
      updateColumns: updateColumns?.call(QuizState.t),
      updateWhere: updateWhere?.call(QuizState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [QuizState] and returns the resulting row.
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
  /// The returned [QuizState] will have its `id` field set.
  Future<QuizState?> upsertRow(
    _is.DatabaseSession session,
    QuizState row, {
    required _is.ColumnSelections<QuizStateTable> conflictColumns,
    _is.ColumnSelections<QuizStateTable>? updateColumns,
    _is.WhereExpressionBuilder<QuizStateTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<QuizState>(
      row,
      conflictColumns: conflictColumns(QuizState.t),
      updateColumns: updateColumns?.call(QuizState.t),
      updateWhere: updateWhere?.call(QuizState.t),
      transaction: transaction,
    );
  }

  /// Updates all [QuizState]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuizState>> update(
    _is.DatabaseSession session,
    List<QuizState> rows, {
    _is.ColumnSelections<QuizStateTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<QuizState>(
      rows,
      columns: columns?.call(QuizState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [QuizState]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<QuizState> updateRow(
    _is.DatabaseSession session,
    QuizState row, {
    _is.ColumnSelections<QuizStateTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<QuizState>(
      row,
      columns: columns?.call(QuizState.t),
      transaction: transaction,
    );
  }

  /// Updates a single [QuizState] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<QuizState?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<QuizStateUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<QuizState>(
      id,
      columnValues: columnValues(QuizState.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [QuizState]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuizState>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<QuizStateUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<QuizStateTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuizStateTable>? orderBy,
    _is.OrderByListBuilder<QuizStateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<QuizState>(
      columnValues: columnValues(QuizState.t.updateTable),
      where: where(QuizState.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(QuizState.t),
      orderByList: orderByList?.call(QuizState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [QuizState]s in the list and returns the deleted rows.
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
  Future<List<QuizState>> delete(
    _is.DatabaseSession session,
    List<QuizState> rows, {
    _is.OrderByBuilder<QuizStateTable>? orderBy,
    _is.OrderByListBuilder<QuizStateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<QuizState>(
      rows,
      orderBy: orderBy?.call(QuizState.t),
      orderByList: orderByList?.call(QuizState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [QuizState].
  Future<QuizState> deleteRow(
    _is.DatabaseSession session,
    QuizState row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<QuizState>(
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
  Future<List<QuizState>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<QuizStateTable> where,
    _is.OrderByBuilder<QuizStateTable>? orderBy,
    _is.OrderByListBuilder<QuizStateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<QuizState>(
      where: where(QuizState.t),
      orderBy: orderBy?.call(QuizState.t),
      orderByList: orderByList?.call(QuizState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuizStateTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<QuizState>(
      where: where?.call(QuizState.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [QuizState] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<QuizStateTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<QuizState>(
      where: where(QuizState.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
