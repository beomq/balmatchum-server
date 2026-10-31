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
import '../product/reward_window.dart' as _izf8seq4;

abstract class ProductDay
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ProductDay._({
    this.id,
    required this.owner,
    required this.date,
    int? revision,
    bool? deleted,
    int? deletionVersion,
    this.steps,
    String? availability,
    int? streamGeneration,
    int? stepRevision,
    int? grantedUnits,
    int? confirmedUnits,
    this.policyVersion,
    required this.windows,
  }) : revision = revision ?? 0,
       deleted = deleted ?? false,
       deletionVersion = deletionVersion ?? 0,
       availability = availability ?? 'unknown',
       streamGeneration = streamGeneration ?? 0,
       stepRevision = stepRevision ?? 0,
       grantedUnits = grantedUnits ?? 0,
       confirmedUnits = confirmedUnits ?? 0;

  factory ProductDay({
    int? id,
    required String owner,
    required String date,
    int? revision,
    bool? deleted,
    int? deletionVersion,
    int? steps,
    String? availability,
    int? streamGeneration,
    int? stepRevision,
    int? grantedUnits,
    int? confirmedUnits,
    String? policyVersion,
    required List<_izf8seq4.RewardWindow> windows,
  }) = _ProductDayImpl;

  factory ProductDay.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductDay(
      id: jsonSerialization['id'] as int?,
      owner: jsonSerialization['owner'] as String,
      date: jsonSerialization['date'] as String,
      revision: jsonSerialization['revision'] as int?,
      deleted: jsonSerialization['deleted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
      deletionVersion: jsonSerialization['deletionVersion'] as int?,
      steps: jsonSerialization['steps'] as int?,
      availability: jsonSerialization['availability'] as String?,
      streamGeneration: jsonSerialization['streamGeneration'] as int?,
      stepRevision: jsonSerialization['stepRevision'] as int?,
      grantedUnits: jsonSerialization['grantedUnits'] as int?,
      confirmedUnits: jsonSerialization['confirmedUnits'] as int?,
      policyVersion: jsonSerialization['policyVersion'] as String?,
      windows: _iu3f2ih9.Protocol().deserialize<List<_izf8seq4.RewardWindow>>(
        jsonSerialization['windows'],
      ),
    );
  }

  static final t = ProductDayTable();

  static const db = ProductDayRepository._();

  @override
  int? id;

  String owner;

  String date;

  int revision;

  bool deleted;

  int deletionVersion;

  int? steps;

  String availability;

  int streamGeneration;

  int stepRevision;

  int grantedUnits;

  int confirmedUnits;

  String? policyVersion;

  List<_izf8seq4.RewardWindow> windows;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProductDay]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ProductDay copyWith({
    int? id,
    String? owner,
    String? date,
    int? revision,
    bool? deleted,
    int? deletionVersion,
    int? steps,
    String? availability,
    int? streamGeneration,
    int? stepRevision,
    int? grantedUnits,
    int? confirmedUnits,
    String? policyVersion,
    List<_izf8seq4.RewardWindow>? windows,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProductDay',
      if (id != null) 'id': id,
      'owner': owner,
      'date': date,
      'revision': revision,
      'deleted': deleted,
      'deletionVersion': deletionVersion,
      if (steps != null) 'steps': steps,
      'availability': availability,
      'streamGeneration': streamGeneration,
      'stepRevision': stepRevision,
      'grantedUnits': grantedUnits,
      'confirmedUnits': confirmedUnits,
      if (policyVersion != null) 'policyVersion': policyVersion,
      'windows': windows.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ProductDayInclude include() {
    return ProductDayInclude._();
  }

  static ProductDayIncludeList includeList({
    _is.WhereExpressionBuilder<ProductDayTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductDayTable>? orderBy,
    _is.OrderByListBuilder<ProductDayTable>? orderByList,
    ProductDayInclude? include,
  }) {
    return ProductDayIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductDay.t),
      orderByList: orderByList?.call(ProductDay.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductDayImpl extends ProductDay {
  _ProductDayImpl({
    int? id,
    required String owner,
    required String date,
    int? revision,
    bool? deleted,
    int? deletionVersion,
    int? steps,
    String? availability,
    int? streamGeneration,
    int? stepRevision,
    int? grantedUnits,
    int? confirmedUnits,
    String? policyVersion,
    required List<_izf8seq4.RewardWindow> windows,
  }) : super._(
         id: id,
         owner: owner,
         date: date,
         revision: revision,
         deleted: deleted,
         deletionVersion: deletionVersion,
         steps: steps,
         availability: availability,
         streamGeneration: streamGeneration,
         stepRevision: stepRevision,
         grantedUnits: grantedUnits,
         confirmedUnits: confirmedUnits,
         policyVersion: policyVersion,
         windows: windows,
       );

  /// Returns a shallow copy of this [ProductDay]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ProductDay copyWith({
    Object? id = _Undefined,
    String? owner,
    String? date,
    int? revision,
    bool? deleted,
    int? deletionVersion,
    Object? steps = _Undefined,
    String? availability,
    int? streamGeneration,
    int? stepRevision,
    int? grantedUnits,
    int? confirmedUnits,
    Object? policyVersion = _Undefined,
    List<_izf8seq4.RewardWindow>? windows,
  }) {
    return ProductDay(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      date: date ?? this.date,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
      deletionVersion: deletionVersion ?? this.deletionVersion,
      steps: steps is int? ? steps : this.steps,
      availability: availability ?? this.availability,
      streamGeneration: streamGeneration ?? this.streamGeneration,
      stepRevision: stepRevision ?? this.stepRevision,
      grantedUnits: grantedUnits ?? this.grantedUnits,
      confirmedUnits: confirmedUnits ?? this.confirmedUnits,
      policyVersion: policyVersion is String?
          ? policyVersion
          : this.policyVersion,
      windows: windows ?? this.windows.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class ProductDayUpdateTable extends _is.UpdateTable<ProductDayTable> {
  ProductDayUpdateTable(super.table);

  _is.ColumnValue<String, String> owner(String value) => _is.ColumnValue(
    table.owner,
    value,
  );

  _is.ColumnValue<String, String> date(String value) => _is.ColumnValue(
    table.date,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<bool, bool> deleted(bool value) => _is.ColumnValue(
    table.deleted,
    value,
  );

  _is.ColumnValue<int, int> deletionVersion(int value) => _is.ColumnValue(
    table.deletionVersion,
    value,
  );

  _is.ColumnValue<int, int> steps(int? value) => _is.ColumnValue(
    table.steps,
    value,
  );

  _is.ColumnValue<String, String> availability(String value) => _is.ColumnValue(
    table.availability,
    value,
  );

  _is.ColumnValue<int, int> streamGeneration(int value) => _is.ColumnValue(
    table.streamGeneration,
    value,
  );

  _is.ColumnValue<int, int> stepRevision(int value) => _is.ColumnValue(
    table.stepRevision,
    value,
  );

  _is.ColumnValue<int, int> grantedUnits(int value) => _is.ColumnValue(
    table.grantedUnits,
    value,
  );

  _is.ColumnValue<int, int> confirmedUnits(int value) => _is.ColumnValue(
    table.confirmedUnits,
    value,
  );

  _is.ColumnValue<String, String> policyVersion(String? value) =>
      _is.ColumnValue(
        table.policyVersion,
        value,
      );

  _is.ColumnValue<List<_izf8seq4.RewardWindow>, List<_izf8seq4.RewardWindow>>
  windows(List<_izf8seq4.RewardWindow> value) => _is.ColumnValue(
    table.windows,
    value,
  );
}

class ProductDayTable extends _is.Table<int?> {
  ProductDayTable({super.tableRelation}) : super(tableName: 'product_day') {
    updateTable = ProductDayUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    date = _is.ColumnString(
      'date',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
      hasDefault: true,
    );
    deleted = _is.ColumnBool(
      'deleted',
      this,
      hasDefault: true,
    );
    deletionVersion = _is.ColumnInt(
      'deletionVersion',
      this,
      hasDefault: true,
    );
    steps = _is.ColumnInt(
      'steps',
      this,
    );
    availability = _is.ColumnString(
      'availability',
      this,
      hasDefault: true,
    );
    streamGeneration = _is.ColumnInt(
      'streamGeneration',
      this,
      hasDefault: true,
    );
    stepRevision = _is.ColumnInt(
      'stepRevision',
      this,
      hasDefault: true,
    );
    grantedUnits = _is.ColumnInt(
      'grantedUnits',
      this,
      hasDefault: true,
    );
    confirmedUnits = _is.ColumnInt(
      'confirmedUnits',
      this,
      hasDefault: true,
    );
    policyVersion = _is.ColumnString(
      'policyVersion',
      this,
    );
    windows = _is.ColumnSerializable<List<_izf8seq4.RewardWindow>>(
      'windows',
      this,
    );
  }

  late final ProductDayUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnString date;

  late final _is.ColumnInt revision;

  late final _is.ColumnBool deleted;

  late final _is.ColumnInt deletionVersion;

  late final _is.ColumnInt steps;

  late final _is.ColumnString availability;

  late final _is.ColumnInt streamGeneration;

  late final _is.ColumnInt stepRevision;

  late final _is.ColumnInt grantedUnits;

  late final _is.ColumnInt confirmedUnits;

  late final _is.ColumnString policyVersion;

  late final _is.ColumnSerializable<List<_izf8seq4.RewardWindow>> windows;

  @override
  List<_is.Column> get columns => [
    id,
    owner,
    date,
    revision,
    deleted,
    deletionVersion,
    steps,
    availability,
    streamGeneration,
    stepRevision,
    grantedUnits,
    confirmedUnits,
    policyVersion,
    windows,
  ];
}

class ProductDayInclude extends _is.IncludeObject {
  ProductDayInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ProductDay.t;
}

class ProductDayIncludeList extends _is.IncludeList {
  ProductDayIncludeList._({
    _is.WhereExpressionBuilder<ProductDayTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProductDay.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ProductDay.t;
}

class ProductDayRepository {
  const ProductDayRepository._();

  /// Returns a list of [ProductDay]s matching the given query parameters.
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
  Future<List<ProductDay>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductDayTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductDayTable>? orderBy,
    _is.OrderByListBuilder<ProductDayTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProductDay>(
      where: where?.call(ProductDay.t),
      orderBy: orderBy?.call(ProductDay.t),
      orderByList: orderByList?.call(ProductDay.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProductDay] matching the given query parameters.
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
  Future<ProductDay?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductDayTable>? where,
    int? offset,
    _is.OrderByBuilder<ProductDayTable>? orderBy,
    _is.OrderByListBuilder<ProductDayTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProductDay>(
      where: where?.call(ProductDay.t),
      orderBy: orderBy?.call(ProductDay.t),
      orderByList: orderByList?.call(ProductDay.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProductDay] by its [id] or null if no such row exists.
  Future<ProductDay?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProductDay>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProductDay]s in the list and returns the inserted rows.
  ///
  /// The returned [ProductDay]s will have their `id` fields set.
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
  Future<List<ProductDay>> insert(
    _is.DatabaseSession session,
    List<ProductDay> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ProductDay>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ProductDay] and returns the inserted row.
  ///
  /// The returned [ProductDay] will have its `id` field set.
  Future<ProductDay> insertRow(
    _is.DatabaseSession session,
    ProductDay row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProductDay>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ProductDay]s in the list and returns the resulting rows.
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
  /// The returned [ProductDay]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductDay>> upsert(
    _is.DatabaseSession session,
    List<ProductDay> rows, {
    required _is.ColumnSelections<ProductDayTable> conflictColumns,
    _is.ColumnSelections<ProductDayTable>? updateColumns,
    _is.WhereExpressionBuilder<ProductDayTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ProductDay>(
      rows,
      conflictColumns: conflictColumns(ProductDay.t),
      updateColumns: updateColumns?.call(ProductDay.t),
      updateWhere: updateWhere?.call(ProductDay.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ProductDay] and returns the resulting row.
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
  /// The returned [ProductDay] will have its `id` field set.
  Future<ProductDay?> upsertRow(
    _is.DatabaseSession session,
    ProductDay row, {
    required _is.ColumnSelections<ProductDayTable> conflictColumns,
    _is.ColumnSelections<ProductDayTable>? updateColumns,
    _is.WhereExpressionBuilder<ProductDayTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ProductDay>(
      row,
      conflictColumns: conflictColumns(ProductDay.t),
      updateColumns: updateColumns?.call(ProductDay.t),
      updateWhere: updateWhere?.call(ProductDay.t),
      transaction: transaction,
    );
  }

  /// Updates all [ProductDay]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductDay>> update(
    _is.DatabaseSession session,
    List<ProductDay> rows, {
    _is.ColumnSelections<ProductDayTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ProductDay>(
      rows,
      columns: columns?.call(ProductDay.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ProductDay]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProductDay> updateRow(
    _is.DatabaseSession session,
    ProductDay row, {
    _is.ColumnSelections<ProductDayTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProductDay>(
      row,
      columns: columns?.call(ProductDay.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductDay] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProductDay?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ProductDayUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ProductDay>(
      id,
      columnValues: columnValues(ProductDay.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProductDay]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductDay>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ProductDayUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ProductDayTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductDayTable>? orderBy,
    _is.OrderByListBuilder<ProductDayTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ProductDay>(
      columnValues: columnValues(ProductDay.t.updateTable),
      where: where(ProductDay.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductDay.t),
      orderByList: orderByList?.call(ProductDay.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ProductDay]s in the list and returns the deleted rows.
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
  Future<List<ProductDay>> delete(
    _is.DatabaseSession session,
    List<ProductDay> rows, {
    _is.OrderByBuilder<ProductDayTable>? orderBy,
    _is.OrderByListBuilder<ProductDayTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ProductDay>(
      rows,
      orderBy: orderBy?.call(ProductDay.t),
      orderByList: orderByList?.call(ProductDay.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ProductDay].
  Future<ProductDay> deleteRow(
    _is.DatabaseSession session,
    ProductDay row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProductDay>(
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
  Future<List<ProductDay>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProductDayTable> where,
    _is.OrderByBuilder<ProductDayTable>? orderBy,
    _is.OrderByListBuilder<ProductDayTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ProductDay>(
      where: where(ProductDay.t),
      orderBy: orderBy?.call(ProductDay.t),
      orderByList: orderByList?.call(ProductDay.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductDayTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ProductDay>(
      where: where?.call(ProductDay.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProductDay] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProductDayTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProductDay>(
      where: where(ProductDay.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
