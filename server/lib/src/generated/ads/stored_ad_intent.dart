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

abstract class StoredAdIntent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  StoredAdIntent._({
    this.id,
    required this.owner,
    required this.nonce,
    required this.purpose,
    required this.targetDate,
    required this.targetRevision,
    required this.adUnit,
    required this.rewardItem,
    required this.rewardAmount,
    String? status,
    required this.createdAt,
    required this.eventExpiresAt,
    required this.acceptUntil,
    this.transactionId,
    this.callbackDigest,
    this.eventAt,
    this.verifiedAt,
    this.consumedAt,
  }) : status = status ?? 'pending';

  factory StoredAdIntent({
    int? id,
    required String owner,
    required String nonce,
    required String purpose,
    required String targetDate,
    required int targetRevision,
    required String adUnit,
    required String rewardItem,
    required String rewardAmount,
    String? status,
    required DateTime createdAt,
    required DateTime eventExpiresAt,
    required DateTime acceptUntil,
    String? transactionId,
    String? callbackDigest,
    DateTime? eventAt,
    DateTime? verifiedAt,
    DateTime? consumedAt,
  }) = _StoredAdIntentImpl;

  factory StoredAdIntent.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoredAdIntent(
      id: jsonSerialization['id'] as int?,
      owner: jsonSerialization['owner'] as String,
      nonce: jsonSerialization['nonce'] as String,
      purpose: jsonSerialization['purpose'] as String,
      targetDate: jsonSerialization['targetDate'] as String,
      targetRevision: jsonSerialization['targetRevision'] as int,
      adUnit: jsonSerialization['adUnit'] as String,
      rewardItem: jsonSerialization['rewardItem'] as String,
      rewardAmount: jsonSerialization['rewardAmount'] as String,
      status: jsonSerialization['status'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      eventExpiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['eventExpiresAt'],
      ),
      acceptUntil: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['acceptUntil'],
      ),
      transactionId: jsonSerialization['transactionId'] as String?,
      callbackDigest: jsonSerialization['callbackDigest'] as String?,
      eventAt: jsonSerialization['eventAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['eventAt']),
      verifiedAt: jsonSerialization['verifiedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['verifiedAt']),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
    );
  }

  static final t = StoredAdIntentTable();

  static const db = StoredAdIntentRepository._();

  @override
  int? id;

  String owner;

  String nonce;

  String purpose;

  String targetDate;

  int targetRevision;

  String adUnit;

  String rewardItem;

  String rewardAmount;

  String status;

  DateTime createdAt;

  DateTime eventExpiresAt;

  DateTime acceptUntil;

  String? transactionId;

  String? callbackDigest;

  DateTime? eventAt;

  DateTime? verifiedAt;

  DateTime? consumedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [StoredAdIntent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StoredAdIntent copyWith({
    int? id,
    String? owner,
    String? nonce,
    String? purpose,
    String? targetDate,
    int? targetRevision,
    String? adUnit,
    String? rewardItem,
    String? rewardAmount,
    String? status,
    DateTime? createdAt,
    DateTime? eventExpiresAt,
    DateTime? acceptUntil,
    String? transactionId,
    String? callbackDigest,
    DateTime? eventAt,
    DateTime? verifiedAt,
    DateTime? consumedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoredAdIntent',
      if (id != null) 'id': id,
      'owner': owner,
      'nonce': nonce,
      'purpose': purpose,
      'targetDate': targetDate,
      'targetRevision': targetRevision,
      'adUnit': adUnit,
      'rewardItem': rewardItem,
      'rewardAmount': rewardAmount,
      'status': status,
      'createdAt': createdAt.toJson(),
      'eventExpiresAt': eventExpiresAt.toJson(),
      'acceptUntil': acceptUntil.toJson(),
      if (transactionId != null) 'transactionId': transactionId,
      if (callbackDigest != null) 'callbackDigest': callbackDigest,
      if (eventAt != null) 'eventAt': eventAt?.toJson(),
      if (verifiedAt != null) 'verifiedAt': verifiedAt?.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StoredAdIntentInclude include() {
    return StoredAdIntentInclude._();
  }

  static StoredAdIntentIncludeList includeList({
    _is.WhereExpressionBuilder<StoredAdIntentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredAdIntentTable>? orderBy,
    _is.OrderByListBuilder<StoredAdIntentTable>? orderByList,
    StoredAdIntentInclude? include,
  }) {
    return StoredAdIntentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoredAdIntent.t),
      orderByList: orderByList?.call(StoredAdIntent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoredAdIntentImpl extends StoredAdIntent {
  _StoredAdIntentImpl({
    int? id,
    required String owner,
    required String nonce,
    required String purpose,
    required String targetDate,
    required int targetRevision,
    required String adUnit,
    required String rewardItem,
    required String rewardAmount,
    String? status,
    required DateTime createdAt,
    required DateTime eventExpiresAt,
    required DateTime acceptUntil,
    String? transactionId,
    String? callbackDigest,
    DateTime? eventAt,
    DateTime? verifiedAt,
    DateTime? consumedAt,
  }) : super._(
         id: id,
         owner: owner,
         nonce: nonce,
         purpose: purpose,
         targetDate: targetDate,
         targetRevision: targetRevision,
         adUnit: adUnit,
         rewardItem: rewardItem,
         rewardAmount: rewardAmount,
         status: status,
         createdAt: createdAt,
         eventExpiresAt: eventExpiresAt,
         acceptUntil: acceptUntil,
         transactionId: transactionId,
         callbackDigest: callbackDigest,
         eventAt: eventAt,
         verifiedAt: verifiedAt,
         consumedAt: consumedAt,
       );

  /// Returns a shallow copy of this [StoredAdIntent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StoredAdIntent copyWith({
    Object? id = _Undefined,
    String? owner,
    String? nonce,
    String? purpose,
    String? targetDate,
    int? targetRevision,
    String? adUnit,
    String? rewardItem,
    String? rewardAmount,
    String? status,
    DateTime? createdAt,
    DateTime? eventExpiresAt,
    DateTime? acceptUntil,
    Object? transactionId = _Undefined,
    Object? callbackDigest = _Undefined,
    Object? eventAt = _Undefined,
    Object? verifiedAt = _Undefined,
    Object? consumedAt = _Undefined,
  }) {
    return StoredAdIntent(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      nonce: nonce ?? this.nonce,
      purpose: purpose ?? this.purpose,
      targetDate: targetDate ?? this.targetDate,
      targetRevision: targetRevision ?? this.targetRevision,
      adUnit: adUnit ?? this.adUnit,
      rewardItem: rewardItem ?? this.rewardItem,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      eventExpiresAt: eventExpiresAt ?? this.eventExpiresAt,
      acceptUntil: acceptUntil ?? this.acceptUntil,
      transactionId: transactionId is String?
          ? transactionId
          : this.transactionId,
      callbackDigest: callbackDigest is String?
          ? callbackDigest
          : this.callbackDigest,
      eventAt: eventAt is DateTime? ? eventAt : this.eventAt,
      verifiedAt: verifiedAt is DateTime? ? verifiedAt : this.verifiedAt,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
    );
  }
}

class StoredAdIntentUpdateTable extends _is.UpdateTable<StoredAdIntentTable> {
  StoredAdIntentUpdateTable(super.table);

  _is.ColumnValue<String, String> owner(String value) => _is.ColumnValue(
    table.owner,
    value,
  );

  _is.ColumnValue<String, String> nonce(String value) => _is.ColumnValue(
    table.nonce,
    value,
  );

  _is.ColumnValue<String, String> purpose(String value) => _is.ColumnValue(
    table.purpose,
    value,
  );

  _is.ColumnValue<String, String> targetDate(String value) => _is.ColumnValue(
    table.targetDate,
    value,
  );

  _is.ColumnValue<int, int> targetRevision(int value) => _is.ColumnValue(
    table.targetRevision,
    value,
  );

  _is.ColumnValue<String, String> adUnit(String value) => _is.ColumnValue(
    table.adUnit,
    value,
  );

  _is.ColumnValue<String, String> rewardItem(String value) => _is.ColumnValue(
    table.rewardItem,
    value,
  );

  _is.ColumnValue<String, String> rewardAmount(String value) => _is.ColumnValue(
    table.rewardAmount,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> eventExpiresAt(DateTime value) =>
      _is.ColumnValue(
        table.eventExpiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> acceptUntil(DateTime value) =>
      _is.ColumnValue(
        table.acceptUntil,
        value,
      );

  _is.ColumnValue<String, String> transactionId(String? value) =>
      _is.ColumnValue(
        table.transactionId,
        value,
      );

  _is.ColumnValue<String, String> callbackDigest(String? value) =>
      _is.ColumnValue(
        table.callbackDigest,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> eventAt(DateTime? value) =>
      _is.ColumnValue(
        table.eventAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> verifiedAt(DateTime? value) =>
      _is.ColumnValue(
        table.verifiedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> consumedAt(DateTime? value) =>
      _is.ColumnValue(
        table.consumedAt,
        value,
      );
}

class StoredAdIntentTable extends _is.Table<int?> {
  StoredAdIntentTable({super.tableRelation}) : super(tableName: 'ad_intent') {
    updateTable = StoredAdIntentUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    nonce = _is.ColumnString(
      'nonce',
      this,
    );
    purpose = _is.ColumnString(
      'purpose',
      this,
    );
    targetDate = _is.ColumnString(
      'targetDate',
      this,
    );
    targetRevision = _is.ColumnInt(
      'targetRevision',
      this,
    );
    adUnit = _is.ColumnString(
      'adUnit',
      this,
    );
    rewardItem = _is.ColumnString(
      'rewardItem',
      this,
    );
    rewardAmount = _is.ColumnString(
      'rewardAmount',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    eventExpiresAt = _is.ColumnDateTime(
      'eventExpiresAt',
      this,
    );
    acceptUntil = _is.ColumnDateTime(
      'acceptUntil',
      this,
    );
    transactionId = _is.ColumnString(
      'transactionId',
      this,
    );
    callbackDigest = _is.ColumnString(
      'callbackDigest',
      this,
    );
    eventAt = _is.ColumnDateTime(
      'eventAt',
      this,
    );
    verifiedAt = _is.ColumnDateTime(
      'verifiedAt',
      this,
    );
    consumedAt = _is.ColumnDateTime(
      'consumedAt',
      this,
    );
  }

  late final StoredAdIntentUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnString nonce;

  late final _is.ColumnString purpose;

  late final _is.ColumnString targetDate;

  late final _is.ColumnInt targetRevision;

  late final _is.ColumnString adUnit;

  late final _is.ColumnString rewardItem;

  late final _is.ColumnString rewardAmount;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime eventExpiresAt;

  late final _is.ColumnDateTime acceptUntil;

  late final _is.ColumnString transactionId;

  late final _is.ColumnString callbackDigest;

  late final _is.ColumnDateTime eventAt;

  late final _is.ColumnDateTime verifiedAt;

  late final _is.ColumnDateTime consumedAt;

  @override
  List<_is.Column> get columns => [
    id,
    owner,
    nonce,
    purpose,
    targetDate,
    targetRevision,
    adUnit,
    rewardItem,
    rewardAmount,
    status,
    createdAt,
    eventExpiresAt,
    acceptUntil,
    transactionId,
    callbackDigest,
    eventAt,
    verifiedAt,
    consumedAt,
  ];
}

class StoredAdIntentInclude extends _is.IncludeObject {
  StoredAdIntentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => StoredAdIntent.t;
}

class StoredAdIntentIncludeList extends _is.IncludeList {
  StoredAdIntentIncludeList._({
    _is.WhereExpressionBuilder<StoredAdIntentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StoredAdIntent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => StoredAdIntent.t;
}

class StoredAdIntentRepository {
  const StoredAdIntentRepository._();

  /// Returns a list of [StoredAdIntent]s matching the given query parameters.
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
  Future<List<StoredAdIntent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredAdIntentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredAdIntentTable>? orderBy,
    _is.OrderByListBuilder<StoredAdIntentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StoredAdIntent>(
      where: where?.call(StoredAdIntent.t),
      orderBy: orderBy?.call(StoredAdIntent.t),
      orderByList: orderByList?.call(StoredAdIntent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StoredAdIntent] matching the given query parameters.
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
  Future<StoredAdIntent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredAdIntentTable>? where,
    int? offset,
    _is.OrderByBuilder<StoredAdIntentTable>? orderBy,
    _is.OrderByListBuilder<StoredAdIntentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StoredAdIntent>(
      where: where?.call(StoredAdIntent.t),
      orderBy: orderBy?.call(StoredAdIntent.t),
      orderByList: orderByList?.call(StoredAdIntent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StoredAdIntent] by its [id] or null if no such row exists.
  Future<StoredAdIntent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StoredAdIntent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StoredAdIntent]s in the list and returns the inserted rows.
  ///
  /// The returned [StoredAdIntent]s will have their `id` fields set.
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
  Future<List<StoredAdIntent>> insert(
    _is.DatabaseSession session,
    List<StoredAdIntent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StoredAdIntent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StoredAdIntent] and returns the inserted row.
  ///
  /// The returned [StoredAdIntent] will have its `id` field set.
  Future<StoredAdIntent> insertRow(
    _is.DatabaseSession session,
    StoredAdIntent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StoredAdIntent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StoredAdIntent]s in the list and returns the resulting rows.
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
  /// The returned [StoredAdIntent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredAdIntent>> upsert(
    _is.DatabaseSession session,
    List<StoredAdIntent> rows, {
    required _is.ColumnSelections<StoredAdIntentTable> conflictColumns,
    _is.ColumnSelections<StoredAdIntentTable>? updateColumns,
    _is.WhereExpressionBuilder<StoredAdIntentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StoredAdIntent>(
      rows,
      conflictColumns: conflictColumns(StoredAdIntent.t),
      updateColumns: updateColumns?.call(StoredAdIntent.t),
      updateWhere: updateWhere?.call(StoredAdIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StoredAdIntent] and returns the resulting row.
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
  /// The returned [StoredAdIntent] will have its `id` field set.
  Future<StoredAdIntent?> upsertRow(
    _is.DatabaseSession session,
    StoredAdIntent row, {
    required _is.ColumnSelections<StoredAdIntentTable> conflictColumns,
    _is.ColumnSelections<StoredAdIntentTable>? updateColumns,
    _is.WhereExpressionBuilder<StoredAdIntentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StoredAdIntent>(
      row,
      conflictColumns: conflictColumns(StoredAdIntent.t),
      updateColumns: updateColumns?.call(StoredAdIntent.t),
      updateWhere: updateWhere?.call(StoredAdIntent.t),
      transaction: transaction,
    );
  }

  /// Updates all [StoredAdIntent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredAdIntent>> update(
    _is.DatabaseSession session,
    List<StoredAdIntent> rows, {
    _is.ColumnSelections<StoredAdIntentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StoredAdIntent>(
      rows,
      columns: columns?.call(StoredAdIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StoredAdIntent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StoredAdIntent> updateRow(
    _is.DatabaseSession session,
    StoredAdIntent row, {
    _is.ColumnSelections<StoredAdIntentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StoredAdIntent>(
      row,
      columns: columns?.call(StoredAdIntent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoredAdIntent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StoredAdIntent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StoredAdIntentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StoredAdIntent>(
      id,
      columnValues: columnValues(StoredAdIntent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StoredAdIntent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredAdIntent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StoredAdIntentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StoredAdIntentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredAdIntentTable>? orderBy,
    _is.OrderByListBuilder<StoredAdIntentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StoredAdIntent>(
      columnValues: columnValues(StoredAdIntent.t.updateTable),
      where: where(StoredAdIntent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoredAdIntent.t),
      orderByList: orderByList?.call(StoredAdIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StoredAdIntent]s in the list and returns the deleted rows.
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
  Future<List<StoredAdIntent>> delete(
    _is.DatabaseSession session,
    List<StoredAdIntent> rows, {
    _is.OrderByBuilder<StoredAdIntentTable>? orderBy,
    _is.OrderByListBuilder<StoredAdIntentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StoredAdIntent>(
      rows,
      orderBy: orderBy?.call(StoredAdIntent.t),
      orderByList: orderByList?.call(StoredAdIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StoredAdIntent].
  Future<StoredAdIntent> deleteRow(
    _is.DatabaseSession session,
    StoredAdIntent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StoredAdIntent>(
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
  Future<List<StoredAdIntent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StoredAdIntentTable> where,
    _is.OrderByBuilder<StoredAdIntentTable>? orderBy,
    _is.OrderByListBuilder<StoredAdIntentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StoredAdIntent>(
      where: where(StoredAdIntent.t),
      orderBy: orderBy?.call(StoredAdIntent.t),
      orderByList: orderByList?.call(StoredAdIntent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredAdIntentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StoredAdIntent>(
      where: where?.call(StoredAdIntent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StoredAdIntent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StoredAdIntentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StoredAdIntent>(
      where: where(StoredAdIntent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
