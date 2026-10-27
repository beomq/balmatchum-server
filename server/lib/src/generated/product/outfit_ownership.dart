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

abstract class OutfitOwnership
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  OutfitOwnership._({
    this.id,
    required this.owner,
    required this.outfitId,
    required this.purchasedAt,
  });

  factory OutfitOwnership({
    int? id,
    required String owner,
    required String outfitId,
    required DateTime purchasedAt,
  }) = _OutfitOwnershipImpl;

  factory OutfitOwnership.fromJson(Map<String, dynamic> jsonSerialization) {
    return OutfitOwnership(
      id: jsonSerialization['id'] as int?,
      owner: jsonSerialization['owner'] as String,
      outfitId: jsonSerialization['outfitId'] as String,
      purchasedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['purchasedAt'],
      ),
    );
  }

  static final t = OutfitOwnershipTable();

  static const db = OutfitOwnershipRepository._();

  @override
  int? id;

  String owner;

  String outfitId;

  DateTime purchasedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [OutfitOwnership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OutfitOwnership copyWith({
    int? id,
    String? owner,
    String? outfitId,
    DateTime? purchasedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OutfitOwnership',
      if (id != null) 'id': id,
      'owner': owner,
      'outfitId': outfitId,
      'purchasedAt': purchasedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static OutfitOwnershipInclude include() {
    return OutfitOwnershipInclude._();
  }

  static OutfitOwnershipIncludeList includeList({
    _is.WhereExpressionBuilder<OutfitOwnershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutfitOwnershipTable>? orderBy,
    _is.OrderByListBuilder<OutfitOwnershipTable>? orderByList,
    OutfitOwnershipInclude? include,
  }) {
    return OutfitOwnershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OutfitOwnership.t),
      orderByList: orderByList?.call(OutfitOwnership.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OutfitOwnershipImpl extends OutfitOwnership {
  _OutfitOwnershipImpl({
    int? id,
    required String owner,
    required String outfitId,
    required DateTime purchasedAt,
  }) : super._(
         id: id,
         owner: owner,
         outfitId: outfitId,
         purchasedAt: purchasedAt,
       );

  /// Returns a shallow copy of this [OutfitOwnership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OutfitOwnership copyWith({
    Object? id = _Undefined,
    String? owner,
    String? outfitId,
    DateTime? purchasedAt,
  }) {
    return OutfitOwnership(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      outfitId: outfitId ?? this.outfitId,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}

class OutfitOwnershipUpdateTable extends _is.UpdateTable<OutfitOwnershipTable> {
  OutfitOwnershipUpdateTable(super.table);

  _is.ColumnValue<String, String> owner(String value) => _is.ColumnValue(
    table.owner,
    value,
  );

  _is.ColumnValue<String, String> outfitId(String value) => _is.ColumnValue(
    table.outfitId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> purchasedAt(DateTime value) =>
      _is.ColumnValue(
        table.purchasedAt,
        value,
      );
}

class OutfitOwnershipTable extends _is.Table<int?> {
  OutfitOwnershipTable({super.tableRelation})
    : super(tableName: 'outfit_ownership') {
    updateTable = OutfitOwnershipUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    outfitId = _is.ColumnString(
      'outfitId',
      this,
    );
    purchasedAt = _is.ColumnDateTime(
      'purchasedAt',
      this,
    );
  }

  late final OutfitOwnershipUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnString outfitId;

  late final _is.ColumnDateTime purchasedAt;

  @override
  List<_is.Column> get columns => [
    id,
    owner,
    outfitId,
    purchasedAt,
  ];
}

class OutfitOwnershipInclude extends _is.IncludeObject {
  OutfitOwnershipInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => OutfitOwnership.t;
}

class OutfitOwnershipIncludeList extends _is.IncludeList {
  OutfitOwnershipIncludeList._({
    _is.WhereExpressionBuilder<OutfitOwnershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OutfitOwnership.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => OutfitOwnership.t;
}

class OutfitOwnershipRepository {
  const OutfitOwnershipRepository._();

  /// Returns a list of [OutfitOwnership]s matching the given query parameters.
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
  Future<List<OutfitOwnership>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutfitOwnershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutfitOwnershipTable>? orderBy,
    _is.OrderByListBuilder<OutfitOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OutfitOwnership>(
      where: where?.call(OutfitOwnership.t),
      orderBy: orderBy?.call(OutfitOwnership.t),
      orderByList: orderByList?.call(OutfitOwnership.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OutfitOwnership] matching the given query parameters.
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
  Future<OutfitOwnership?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutfitOwnershipTable>? where,
    int? offset,
    _is.OrderByBuilder<OutfitOwnershipTable>? orderBy,
    _is.OrderByListBuilder<OutfitOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OutfitOwnership>(
      where: where?.call(OutfitOwnership.t),
      orderBy: orderBy?.call(OutfitOwnership.t),
      orderByList: orderByList?.call(OutfitOwnership.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OutfitOwnership] by its [id] or null if no such row exists.
  Future<OutfitOwnership?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OutfitOwnership>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OutfitOwnership]s in the list and returns the inserted rows.
  ///
  /// The returned [OutfitOwnership]s will have their `id` fields set.
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
  Future<List<OutfitOwnership>> insert(
    _is.DatabaseSession session,
    List<OutfitOwnership> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<OutfitOwnership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [OutfitOwnership] and returns the inserted row.
  ///
  /// The returned [OutfitOwnership] will have its `id` field set.
  Future<OutfitOwnership> insertRow(
    _is.DatabaseSession session,
    OutfitOwnership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<OutfitOwnership>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [OutfitOwnership]s in the list and returns the resulting rows.
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
  /// The returned [OutfitOwnership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OutfitOwnership>> upsert(
    _is.DatabaseSession session,
    List<OutfitOwnership> rows, {
    required _is.ColumnSelections<OutfitOwnershipTable> conflictColumns,
    _is.ColumnSelections<OutfitOwnershipTable>? updateColumns,
    _is.WhereExpressionBuilder<OutfitOwnershipTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<OutfitOwnership>(
      rows,
      conflictColumns: conflictColumns(OutfitOwnership.t),
      updateColumns: updateColumns?.call(OutfitOwnership.t),
      updateWhere: updateWhere?.call(OutfitOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [OutfitOwnership] and returns the resulting row.
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
  /// The returned [OutfitOwnership] will have its `id` field set.
  Future<OutfitOwnership?> upsertRow(
    _is.DatabaseSession session,
    OutfitOwnership row, {
    required _is.ColumnSelections<OutfitOwnershipTable> conflictColumns,
    _is.ColumnSelections<OutfitOwnershipTable>? updateColumns,
    _is.WhereExpressionBuilder<OutfitOwnershipTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<OutfitOwnership>(
      row,
      conflictColumns: conflictColumns(OutfitOwnership.t),
      updateColumns: updateColumns?.call(OutfitOwnership.t),
      updateWhere: updateWhere?.call(OutfitOwnership.t),
      transaction: transaction,
    );
  }

  /// Updates all [OutfitOwnership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OutfitOwnership>> update(
    _is.DatabaseSession session,
    List<OutfitOwnership> rows, {
    _is.ColumnSelections<OutfitOwnershipTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<OutfitOwnership>(
      rows,
      columns: columns?.call(OutfitOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [OutfitOwnership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OutfitOwnership> updateRow(
    _is.DatabaseSession session,
    OutfitOwnership row, {
    _is.ColumnSelections<OutfitOwnershipTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<OutfitOwnership>(
      row,
      columns: columns?.call(OutfitOwnership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OutfitOwnership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OutfitOwnership?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<OutfitOwnershipUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<OutfitOwnership>(
      id,
      columnValues: columnValues(OutfitOwnership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OutfitOwnership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OutfitOwnership>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<OutfitOwnershipUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<OutfitOwnershipTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutfitOwnershipTable>? orderBy,
    _is.OrderByListBuilder<OutfitOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<OutfitOwnership>(
      columnValues: columnValues(OutfitOwnership.t.updateTable),
      where: where(OutfitOwnership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OutfitOwnership.t),
      orderByList: orderByList?.call(OutfitOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [OutfitOwnership]s in the list and returns the deleted rows.
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
  Future<List<OutfitOwnership>> delete(
    _is.DatabaseSession session,
    List<OutfitOwnership> rows, {
    _is.OrderByBuilder<OutfitOwnershipTable>? orderBy,
    _is.OrderByListBuilder<OutfitOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<OutfitOwnership>(
      rows,
      orderBy: orderBy?.call(OutfitOwnership.t),
      orderByList: orderByList?.call(OutfitOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [OutfitOwnership].
  Future<OutfitOwnership> deleteRow(
    _is.DatabaseSession session,
    OutfitOwnership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OutfitOwnership>(
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
  Future<List<OutfitOwnership>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OutfitOwnershipTable> where,
    _is.OrderByBuilder<OutfitOwnershipTable>? orderBy,
    _is.OrderByListBuilder<OutfitOwnershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<OutfitOwnership>(
      where: where(OutfitOwnership.t),
      orderBy: orderBy?.call(OutfitOwnership.t),
      orderByList: orderByList?.call(OutfitOwnership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutfitOwnershipTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<OutfitOwnership>(
      where: where?.call(OutfitOwnership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OutfitOwnership] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OutfitOwnershipTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OutfitOwnership>(
      where: where(OutfitOwnership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
