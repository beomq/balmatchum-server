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
import 'package:balmatchum_server/src/generated/protocol.dart' as _iu3f2ih9;
import 'package:serverpod/serverpod.dart' as _is;
import '../product/reward_slice.dart' as _i03s1ada;

abstract class PointEntry
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PointEntry._({
    this.id,
    required this.owner,
    required this.entryKey,
    required this.kind,
    this.date,
    required this.amount,
    this.fromUnits,
    this.throughUnits,
    required this.policyVersion,
    required this.createdAt,
    this.slices,
  });

  factory PointEntry({
    int? id,
    required String owner,
    required String entryKey,
    required String kind,
    String? date,
    required int amount,
    int? fromUnits,
    int? throughUnits,
    required String policyVersion,
    required DateTime createdAt,
    List<_i03s1ada.RewardSlice>? slices,
  }) = _PointEntryImpl;

  factory PointEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return PointEntry(
      id: jsonSerialization['id'] as int?,
      owner: jsonSerialization['owner'] as String,
      entryKey: jsonSerialization['entryKey'] as String,
      kind: jsonSerialization['kind'] as String,
      date: jsonSerialization['date'] as String?,
      amount: jsonSerialization['amount'] as int,
      fromUnits: jsonSerialization['fromUnits'] as int?,
      throughUnits: jsonSerialization['throughUnits'] as int?,
      policyVersion: jsonSerialization['policyVersion'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      slices: jsonSerialization['slices'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<List<_i03s1ada.RewardSlice>>(
              jsonSerialization['slices'],
            ),
    );
  }

  static final t = PointEntryTable();

  static const db = PointEntryRepository._();

  @override
  int? id;

  String owner;

  String entryKey;

  String kind;

  String? date;

  int amount;

  int? fromUnits;

  int? throughUnits;

  String policyVersion;

  DateTime createdAt;

  List<_i03s1ada.RewardSlice>? slices;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PointEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PointEntry copyWith({
    int? id,
    String? owner,
    String? entryKey,
    String? kind,
    String? date,
    int? amount,
    int? fromUnits,
    int? throughUnits,
    String? policyVersion,
    DateTime? createdAt,
    List<_i03s1ada.RewardSlice>? slices,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PointEntry',
      if (id != null) 'id': id,
      'owner': owner,
      'entryKey': entryKey,
      'kind': kind,
      if (date != null) 'date': date,
      'amount': amount,
      if (fromUnits != null) 'fromUnits': fromUnits,
      if (throughUnits != null) 'throughUnits': throughUnits,
      'policyVersion': policyVersion,
      'createdAt': createdAt.toJson(),
      if (slices != null)
        'slices': slices?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PointEntryInclude include() {
    return PointEntryInclude._();
  }

  static PointEntryIncludeList includeList({
    _is.WhereExpressionBuilder<PointEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PointEntryTable>? orderBy,
    _is.OrderByListBuilder<PointEntryTable>? orderByList,
    PointEntryInclude? include,
  }) {
    return PointEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PointEntry.t),
      orderByList: orderByList?.call(PointEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PointEntryImpl extends PointEntry {
  _PointEntryImpl({
    int? id,
    required String owner,
    required String entryKey,
    required String kind,
    String? date,
    required int amount,
    int? fromUnits,
    int? throughUnits,
    required String policyVersion,
    required DateTime createdAt,
    List<_i03s1ada.RewardSlice>? slices,
  }) : super._(
         id: id,
         owner: owner,
         entryKey: entryKey,
         kind: kind,
         date: date,
         amount: amount,
         fromUnits: fromUnits,
         throughUnits: throughUnits,
         policyVersion: policyVersion,
         createdAt: createdAt,
         slices: slices,
       );

  /// Returns a shallow copy of this [PointEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PointEntry copyWith({
    Object? id = _Undefined,
    String? owner,
    String? entryKey,
    String? kind,
    Object? date = _Undefined,
    int? amount,
    Object? fromUnits = _Undefined,
    Object? throughUnits = _Undefined,
    String? policyVersion,
    DateTime? createdAt,
    Object? slices = _Undefined,
  }) {
    return PointEntry(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      entryKey: entryKey ?? this.entryKey,
      kind: kind ?? this.kind,
      date: date is String? ? date : this.date,
      amount: amount ?? this.amount,
      fromUnits: fromUnits is int? ? fromUnits : this.fromUnits,
      throughUnits: throughUnits is int? ? throughUnits : this.throughUnits,
      policyVersion: policyVersion ?? this.policyVersion,
      createdAt: createdAt ?? this.createdAt,
      slices: slices is List<_i03s1ada.RewardSlice>?
          ? slices
          : this.slices?.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class PointEntryUpdateTable extends _is.UpdateTable<PointEntryTable> {
  PointEntryUpdateTable(super.table);

  _is.ColumnValue<String, String> owner(String value) => _is.ColumnValue(
    table.owner,
    value,
  );

  _is.ColumnValue<String, String> entryKey(String value) => _is.ColumnValue(
    table.entryKey,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> date(String? value) => _is.ColumnValue(
    table.date,
    value,
  );

  _is.ColumnValue<int, int> amount(int value) => _is.ColumnValue(
    table.amount,
    value,
  );

  _is.ColumnValue<int, int> fromUnits(int? value) => _is.ColumnValue(
    table.fromUnits,
    value,
  );

  _is.ColumnValue<int, int> throughUnits(int? value) => _is.ColumnValue(
    table.throughUnits,
    value,
  );

  _is.ColumnValue<String, String> policyVersion(String value) =>
      _is.ColumnValue(
        table.policyVersion,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<List<_i03s1ada.RewardSlice>, List<_i03s1ada.RewardSlice>>
  slices(List<_i03s1ada.RewardSlice>? value) => _is.ColumnValue(
    table.slices,
    value,
  );
}

class PointEntryTable extends _is.Table<int?> {
  PointEntryTable({super.tableRelation}) : super(tableName: 'point_entry') {
    updateTable = PointEntryUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    entryKey = _is.ColumnString(
      'entryKey',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    date = _is.ColumnString(
      'date',
      this,
    );
    amount = _is.ColumnInt(
      'amount',
      this,
    );
    fromUnits = _is.ColumnInt(
      'fromUnits',
      this,
    );
    throughUnits = _is.ColumnInt(
      'throughUnits',
      this,
    );
    policyVersion = _is.ColumnString(
      'policyVersion',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    slices = _is.ColumnSerializable<List<_i03s1ada.RewardSlice>>(
      'slices',
      this,
    );
  }

  late final PointEntryUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnString entryKey;

  late final _is.ColumnString kind;

  late final _is.ColumnString date;

  late final _is.ColumnInt amount;

  late final _is.ColumnInt fromUnits;

  late final _is.ColumnInt throughUnits;

  late final _is.ColumnString policyVersion;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnSerializable<List<_i03s1ada.RewardSlice>> slices;

  @override
  List<_is.Column> get columns => [
    id,
    owner,
    entryKey,
    kind,
    date,
    amount,
    fromUnits,
    throughUnits,
    policyVersion,
    createdAt,
    slices,
  ];
}

class PointEntryInclude extends _is.IncludeObject {
  PointEntryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PointEntry.t;
}

class PointEntryIncludeList extends _is.IncludeList {
  PointEntryIncludeList._({
    _is.WhereExpressionBuilder<PointEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PointEntry.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PointEntry.t;
}

class PointEntryRepository {
  const PointEntryRepository._();

  /// Returns a list of [PointEntry]s matching the given query parameters.
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
  Future<List<PointEntry>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PointEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PointEntryTable>? orderBy,
    _is.OrderByListBuilder<PointEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PointEntry>(
      where: where?.call(PointEntry.t),
      orderBy: orderBy?.call(PointEntry.t),
      orderByList: orderByList?.call(PointEntry.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PointEntry] matching the given query parameters.
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
  Future<PointEntry?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PointEntryTable>? where,
    int? offset,
    _is.OrderByBuilder<PointEntryTable>? orderBy,
    _is.OrderByListBuilder<PointEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PointEntry>(
      where: where?.call(PointEntry.t),
      orderBy: orderBy?.call(PointEntry.t),
      orderByList: orderByList?.call(PointEntry.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PointEntry] by its [id] or null if no such row exists.
  Future<PointEntry?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PointEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PointEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [PointEntry]s will have their `id` fields set.
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
  Future<List<PointEntry>> insert(
    _is.DatabaseSession session,
    List<PointEntry> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PointEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PointEntry] and returns the inserted row.
  ///
  /// The returned [PointEntry] will have its `id` field set.
  Future<PointEntry> insertRow(
    _is.DatabaseSession session,
    PointEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PointEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PointEntry]s in the list and returns the resulting rows.
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
  /// The returned [PointEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PointEntry>> upsert(
    _is.DatabaseSession session,
    List<PointEntry> rows, {
    required _is.ColumnSelections<PointEntryTable> conflictColumns,
    _is.ColumnSelections<PointEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<PointEntryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PointEntry>(
      rows,
      conflictColumns: conflictColumns(PointEntry.t),
      updateColumns: updateColumns?.call(PointEntry.t),
      updateWhere: updateWhere?.call(PointEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PointEntry] and returns the resulting row.
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
  /// The returned [PointEntry] will have its `id` field set.
  Future<PointEntry?> upsertRow(
    _is.DatabaseSession session,
    PointEntry row, {
    required _is.ColumnSelections<PointEntryTable> conflictColumns,
    _is.ColumnSelections<PointEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<PointEntryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PointEntry>(
      row,
      conflictColumns: conflictColumns(PointEntry.t),
      updateColumns: updateColumns?.call(PointEntry.t),
      updateWhere: updateWhere?.call(PointEntry.t),
      transaction: transaction,
    );
  }

  /// Updates all [PointEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PointEntry>> update(
    _is.DatabaseSession session,
    List<PointEntry> rows, {
    _is.ColumnSelections<PointEntryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PointEntry>(
      rows,
      columns: columns?.call(PointEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PointEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PointEntry> updateRow(
    _is.DatabaseSession session,
    PointEntry row, {
    _is.ColumnSelections<PointEntryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PointEntry>(
      row,
      columns: columns?.call(PointEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PointEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PointEntry?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PointEntryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PointEntry>(
      id,
      columnValues: columnValues(PointEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PointEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PointEntry>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PointEntryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PointEntryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PointEntryTable>? orderBy,
    _is.OrderByListBuilder<PointEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PointEntry>(
      columnValues: columnValues(PointEntry.t.updateTable),
      where: where(PointEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PointEntry.t),
      orderByList: orderByList?.call(PointEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PointEntry]s in the list and returns the deleted rows.
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
  Future<List<PointEntry>> delete(
    _is.DatabaseSession session,
    List<PointEntry> rows, {
    _is.OrderByBuilder<PointEntryTable>? orderBy,
    _is.OrderByListBuilder<PointEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PointEntry>(
      rows,
      orderBy: orderBy?.call(PointEntry.t),
      orderByList: orderByList?.call(PointEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PointEntry].
  Future<PointEntry> deleteRow(
    _is.DatabaseSession session,
    PointEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PointEntry>(
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
  Future<List<PointEntry>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PointEntryTable> where,
    _is.OrderByBuilder<PointEntryTable>? orderBy,
    _is.OrderByListBuilder<PointEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PointEntry>(
      where: where(PointEntry.t),
      orderBy: orderBy?.call(PointEntry.t),
      orderByList: orderByList?.call(PointEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PointEntryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PointEntry>(
      where: where?.call(PointEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PointEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PointEntryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PointEntry>(
      where: where(PointEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
