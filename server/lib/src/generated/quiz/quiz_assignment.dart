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

abstract class QuizAssignment
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  QuizAssignment._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.date,
    required this.slot,
    required this.questionId,
    required this.version,
    required this.policyVersion,
    required this.issuedAt,
    this.answerIndex,
    this.answeredAt,
    int? awardedPoints,
  }) : awardedPoints = awardedPoints ?? 0;

  factory QuizAssignment({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String date,
    required String slot,
    required String questionId,
    required int version,
    required String policyVersion,
    required DateTime issuedAt,
    int? answerIndex,
    DateTime? answeredAt,
    int? awardedPoints,
  }) = _QuizAssignmentImpl;

  factory QuizAssignment.fromJson(Map<String, dynamic> jsonSerialization) {
    return QuizAssignment(
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
      slot: jsonSerialization['slot'] as String,
      questionId: jsonSerialization['questionId'] as String,
      version: jsonSerialization['version'] as int,
      policyVersion: jsonSerialization['policyVersion'] as String,
      issuedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['issuedAt'],
      ),
      answerIndex: jsonSerialization['answerIndex'] as int?,
      answeredAt: jsonSerialization['answeredAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['answeredAt']),
      awardedPoints: jsonSerialization['awardedPoints'] as int?,
    );
  }

  static final t = QuizAssignmentTable();

  static const db = QuizAssignmentRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String date;

  String slot;

  String questionId;

  int version;

  String policyVersion;

  DateTime issuedAt;

  int? answerIndex;

  DateTime? answeredAt;

  int awardedPoints;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [QuizAssignment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  QuizAssignment copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? date,
    String? slot,
    String? questionId,
    int? version,
    String? policyVersion,
    DateTime? issuedAt,
    int? answerIndex,
    DateTime? answeredAt,
    int? awardedPoints,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QuizAssignment',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'date': date,
      'slot': slot,
      'questionId': questionId,
      'version': version,
      'policyVersion': policyVersion,
      'issuedAt': issuedAt.toJson(),
      if (answerIndex != null) 'answerIndex': answerIndex,
      if (answeredAt != null) 'answeredAt': answeredAt?.toJson(),
      'awardedPoints': awardedPoints,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static QuizAssignmentInclude include({_iacs.AuthUserInclude? authUser}) {
    return QuizAssignmentInclude._(authUser: authUser);
  }

  static QuizAssignmentIncludeList includeList({
    _is.WhereExpressionBuilder<QuizAssignmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuizAssignmentTable>? orderBy,
    _is.OrderByListBuilder<QuizAssignmentTable>? orderByList,
    QuizAssignmentInclude? include,
  }) {
    return QuizAssignmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(QuizAssignment.t),
      orderByList: orderByList?.call(QuizAssignment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuizAssignmentImpl extends QuizAssignment {
  _QuizAssignmentImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String date,
    required String slot,
    required String questionId,
    required int version,
    required String policyVersion,
    required DateTime issuedAt,
    int? answerIndex,
    DateTime? answeredAt,
    int? awardedPoints,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         date: date,
         slot: slot,
         questionId: questionId,
         version: version,
         policyVersion: policyVersion,
         issuedAt: issuedAt,
         answerIndex: answerIndex,
         answeredAt: answeredAt,
         awardedPoints: awardedPoints,
       );

  /// Returns a shallow copy of this [QuizAssignment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  QuizAssignment copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? date,
    String? slot,
    String? questionId,
    int? version,
    String? policyVersion,
    DateTime? issuedAt,
    Object? answerIndex = _Undefined,
    Object? answeredAt = _Undefined,
    int? awardedPoints,
  }) {
    return QuizAssignment(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      date: date ?? this.date,
      slot: slot ?? this.slot,
      questionId: questionId ?? this.questionId,
      version: version ?? this.version,
      policyVersion: policyVersion ?? this.policyVersion,
      issuedAt: issuedAt ?? this.issuedAt,
      answerIndex: answerIndex is int? ? answerIndex : this.answerIndex,
      answeredAt: answeredAt is DateTime? ? answeredAt : this.answeredAt,
      awardedPoints: awardedPoints ?? this.awardedPoints,
    );
  }
}

class QuizAssignmentUpdateTable extends _is.UpdateTable<QuizAssignmentTable> {
  QuizAssignmentUpdateTable(super.table);

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

  _is.ColumnValue<String, String> slot(String value) => _is.ColumnValue(
    table.slot,
    value,
  );

  _is.ColumnValue<String, String> questionId(String value) => _is.ColumnValue(
    table.questionId,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<String, String> policyVersion(String value) =>
      _is.ColumnValue(
        table.policyVersion,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> issuedAt(DateTime value) =>
      _is.ColumnValue(
        table.issuedAt,
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

class QuizAssignmentTable extends _is.Table<int?> {
  QuizAssignmentTable({super.tableRelation})
    : super(tableName: 'quiz_assignment') {
    updateTable = QuizAssignmentUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    date = _is.ColumnString(
      'date',
      this,
    );
    slot = _is.ColumnString(
      'slot',
      this,
    );
    questionId = _is.ColumnString(
      'questionId',
      this,
    );
    version = _is.ColumnInt(
      'version',
      this,
    );
    policyVersion = _is.ColumnString(
      'policyVersion',
      this,
    );
    issuedAt = _is.ColumnDateTime(
      'issuedAt',
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

  late final QuizAssignmentUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString date;

  late final _is.ColumnString slot;

  late final _is.ColumnString questionId;

  late final _is.ColumnInt version;

  late final _is.ColumnString policyVersion;

  late final _is.ColumnDateTime issuedAt;

  late final _is.ColumnInt answerIndex;

  late final _is.ColumnDateTime answeredAt;

  late final _is.ColumnInt awardedPoints;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: QuizAssignment.t.authUserId,
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
    slot,
    questionId,
    version,
    policyVersion,
    issuedAt,
    answerIndex,
    answeredAt,
    awardedPoints,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class QuizAssignmentInclude extends _is.IncludeObject {
  QuizAssignmentInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => QuizAssignment.t;
}

class QuizAssignmentIncludeList extends _is.IncludeList {
  QuizAssignmentIncludeList._({
    _is.WhereExpressionBuilder<QuizAssignmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(QuizAssignment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => QuizAssignment.t;
}

class QuizAssignmentRepository {
  const QuizAssignmentRepository._();

  final attachRow = const QuizAssignmentAttachRowRepository._();

  /// Returns a list of [QuizAssignment]s matching the given query parameters.
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
  Future<List<QuizAssignment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuizAssignmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuizAssignmentTable>? orderBy,
    _is.OrderByListBuilder<QuizAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    QuizAssignmentInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<QuizAssignment>(
      where: where?.call(QuizAssignment.t),
      orderBy: orderBy?.call(QuizAssignment.t),
      orderByList: orderByList?.call(QuizAssignment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [QuizAssignment] matching the given query parameters.
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
  Future<QuizAssignment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuizAssignmentTable>? where,
    int? offset,
    _is.OrderByBuilder<QuizAssignmentTable>? orderBy,
    _is.OrderByListBuilder<QuizAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    QuizAssignmentInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<QuizAssignment>(
      where: where?.call(QuizAssignment.t),
      orderBy: orderBy?.call(QuizAssignment.t),
      orderByList: orderByList?.call(QuizAssignment.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [QuizAssignment] by its [id] or null if no such row exists.
  Future<QuizAssignment?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    QuizAssignmentInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<QuizAssignment>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [QuizAssignment]s in the list and returns the inserted rows.
  ///
  /// The returned [QuizAssignment]s will have their `id` fields set.
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
  Future<List<QuizAssignment>> insert(
    _is.DatabaseSession session,
    List<QuizAssignment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<QuizAssignment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [QuizAssignment] and returns the inserted row.
  ///
  /// The returned [QuizAssignment] will have its `id` field set.
  Future<QuizAssignment> insertRow(
    _is.DatabaseSession session,
    QuizAssignment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<QuizAssignment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [QuizAssignment]s in the list and returns the resulting rows.
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
  /// The returned [QuizAssignment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuizAssignment>> upsert(
    _is.DatabaseSession session,
    List<QuizAssignment> rows, {
    required _is.ColumnSelections<QuizAssignmentTable> conflictColumns,
    _is.ColumnSelections<QuizAssignmentTable>? updateColumns,
    _is.WhereExpressionBuilder<QuizAssignmentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<QuizAssignment>(
      rows,
      conflictColumns: conflictColumns(QuizAssignment.t),
      updateColumns: updateColumns?.call(QuizAssignment.t),
      updateWhere: updateWhere?.call(QuizAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [QuizAssignment] and returns the resulting row.
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
  /// The returned [QuizAssignment] will have its `id` field set.
  Future<QuizAssignment?> upsertRow(
    _is.DatabaseSession session,
    QuizAssignment row, {
    required _is.ColumnSelections<QuizAssignmentTable> conflictColumns,
    _is.ColumnSelections<QuizAssignmentTable>? updateColumns,
    _is.WhereExpressionBuilder<QuizAssignmentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<QuizAssignment>(
      row,
      conflictColumns: conflictColumns(QuizAssignment.t),
      updateColumns: updateColumns?.call(QuizAssignment.t),
      updateWhere: updateWhere?.call(QuizAssignment.t),
      transaction: transaction,
    );
  }

  /// Updates all [QuizAssignment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuizAssignment>> update(
    _is.DatabaseSession session,
    List<QuizAssignment> rows, {
    _is.ColumnSelections<QuizAssignmentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<QuizAssignment>(
      rows,
      columns: columns?.call(QuizAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [QuizAssignment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<QuizAssignment> updateRow(
    _is.DatabaseSession session,
    QuizAssignment row, {
    _is.ColumnSelections<QuizAssignmentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<QuizAssignment>(
      row,
      columns: columns?.call(QuizAssignment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [QuizAssignment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<QuizAssignment?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<QuizAssignmentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<QuizAssignment>(
      id,
      columnValues: columnValues(QuizAssignment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [QuizAssignment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuizAssignment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<QuizAssignmentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<QuizAssignmentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuizAssignmentTable>? orderBy,
    _is.OrderByListBuilder<QuizAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<QuizAssignment>(
      columnValues: columnValues(QuizAssignment.t.updateTable),
      where: where(QuizAssignment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(QuizAssignment.t),
      orderByList: orderByList?.call(QuizAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [QuizAssignment]s in the list and returns the deleted rows.
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
  Future<List<QuizAssignment>> delete(
    _is.DatabaseSession session,
    List<QuizAssignment> rows, {
    _is.OrderByBuilder<QuizAssignmentTable>? orderBy,
    _is.OrderByListBuilder<QuizAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<QuizAssignment>(
      rows,
      orderBy: orderBy?.call(QuizAssignment.t),
      orderByList: orderByList?.call(QuizAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [QuizAssignment].
  Future<QuizAssignment> deleteRow(
    _is.DatabaseSession session,
    QuizAssignment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<QuizAssignment>(
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
  Future<List<QuizAssignment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<QuizAssignmentTable> where,
    _is.OrderByBuilder<QuizAssignmentTable>? orderBy,
    _is.OrderByListBuilder<QuizAssignmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<QuizAssignment>(
      where: where(QuizAssignment.t),
      orderBy: orderBy?.call(QuizAssignment.t),
      orderByList: orderByList?.call(QuizAssignment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuizAssignmentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<QuizAssignment>(
      where: where?.call(QuizAssignment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [QuizAssignment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<QuizAssignmentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<QuizAssignment>(
      where: where(QuizAssignment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class QuizAssignmentAttachRowRepository {
  const QuizAssignmentAttachRowRepository._();

  /// Creates a relation between the given [QuizAssignment] and [AuthUser]
  /// by setting the [QuizAssignment]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    QuizAssignment quizAssignment,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (quizAssignment.id == null) {
      throw ArgumentError.notNull('quizAssignment.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $quizAssignment = quizAssignment.copyWith(authUserId: authUser.id);
    await session.db.updateRow<QuizAssignment>(
      $quizAssignment,
      columns: [QuizAssignment.t.authUserId],
      transaction: transaction,
    );
  }
}
