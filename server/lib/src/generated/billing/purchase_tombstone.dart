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

abstract class PurchaseTombstone
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PurchaseTombstone._({
    this.id,
    required this.identityHash,
    this.retainUntil,
  });

  factory PurchaseTombstone({
    int? id,
    required String identityHash,
    DateTime? retainUntil,
  }) = _PurchaseTombstoneImpl;

  factory PurchaseTombstone.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseTombstone(
      id: jsonSerialization['id'] as int?,
      identityHash: jsonSerialization['identityHash'] as String,
      retainUntil: jsonSerialization['retainUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['retainUntil'],
            ),
    );
  }

  static final t = PurchaseTombstoneTable();

  static const db = PurchaseTombstoneRepository._();

  @override
  int? id;

  String identityHash;

  DateTime? retainUntil;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PurchaseTombstone]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PurchaseTombstone copyWith({
    int? id,
    String? identityHash,
    DateTime? retainUntil,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PurchaseTombstone',
      if (id != null) 'id': id,
      'identityHash': identityHash,
      if (retainUntil != null) 'retainUntil': retainUntil?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PurchaseTombstoneInclude include() {
    return PurchaseTombstoneInclude._();
  }

  static PurchaseTombstoneIncludeList includeList({
    _is.WhereExpressionBuilder<PurchaseTombstoneTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseTombstoneTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTombstoneTable>? orderByList,
    PurchaseTombstoneInclude? include,
  }) {
    return PurchaseTombstoneIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseTombstone.t),
      orderByList: orderByList?.call(PurchaseTombstone.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseTombstoneImpl extends PurchaseTombstone {
  _PurchaseTombstoneImpl({
    int? id,
    required String identityHash,
    DateTime? retainUntil,
  }) : super._(
         id: id,
         identityHash: identityHash,
         retainUntil: retainUntil,
       );

  /// Returns a shallow copy of this [PurchaseTombstone]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PurchaseTombstone copyWith({
    Object? id = _Undefined,
    String? identityHash,
    Object? retainUntil = _Undefined,
  }) {
    return PurchaseTombstone(
      id: id is int? ? id : this.id,
      identityHash: identityHash ?? this.identityHash,
      retainUntil: retainUntil is DateTime? ? retainUntil : this.retainUntil,
    );
  }
}

class PurchaseTombstoneUpdateTable
    extends _is.UpdateTable<PurchaseTombstoneTable> {
  PurchaseTombstoneUpdateTable(super.table);

  _is.ColumnValue<String, String> identityHash(String value) => _is.ColumnValue(
    table.identityHash,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> retainUntil(DateTime? value) =>
      _is.ColumnValue(
        table.retainUntil,
        value,
      );
}

class PurchaseTombstoneTable extends _is.Table<int?> {
  PurchaseTombstoneTable({super.tableRelation})
    : super(tableName: 'billing_purchase_tombstone') {
    updateTable = PurchaseTombstoneUpdateTable(this);
    identityHash = _is.ColumnString(
      'identityHash',
      this,
    );
    retainUntil = _is.ColumnDateTime(
      'retainUntil',
      this,
    );
  }

  late final PurchaseTombstoneUpdateTable updateTable;

  late final _is.ColumnString identityHash;

  late final _is.ColumnDateTime retainUntil;

  @override
  List<_is.Column> get columns => [
    id,
    identityHash,
    retainUntil,
  ];
}

class PurchaseTombstoneInclude extends _is.IncludeObject {
  PurchaseTombstoneInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PurchaseTombstone.t;
}

class PurchaseTombstoneIncludeList extends _is.IncludeList {
  PurchaseTombstoneIncludeList._({
    _is.WhereExpressionBuilder<PurchaseTombstoneTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PurchaseTombstone.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PurchaseTombstone.t;
}

class PurchaseTombstoneRepository {
  const PurchaseTombstoneRepository._();

  /// Returns a list of [PurchaseTombstone]s matching the given query parameters.
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
  Future<List<PurchaseTombstone>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseTombstoneTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseTombstoneTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTombstoneTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PurchaseTombstone>(
      where: where?.call(PurchaseTombstone.t),
      orderBy: orderBy?.call(PurchaseTombstone.t),
      orderByList: orderByList?.call(PurchaseTombstone.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PurchaseTombstone] matching the given query parameters.
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
  Future<PurchaseTombstone?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseTombstoneTable>? where,
    int? offset,
    _is.OrderByBuilder<PurchaseTombstoneTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTombstoneTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PurchaseTombstone>(
      where: where?.call(PurchaseTombstone.t),
      orderBy: orderBy?.call(PurchaseTombstone.t),
      orderByList: orderByList?.call(PurchaseTombstone.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PurchaseTombstone] by its [id] or null if no such row exists.
  Future<PurchaseTombstone?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PurchaseTombstone>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PurchaseTombstone]s in the list and returns the inserted rows.
  ///
  /// The returned [PurchaseTombstone]s will have their `id` fields set.
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
  Future<List<PurchaseTombstone>> insert(
    _is.DatabaseSession session,
    List<PurchaseTombstone> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PurchaseTombstone>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PurchaseTombstone] and returns the inserted row.
  ///
  /// The returned [PurchaseTombstone] will have its `id` field set.
  Future<PurchaseTombstone> insertRow(
    _is.DatabaseSession session,
    PurchaseTombstone row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PurchaseTombstone>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PurchaseTombstone]s in the list and returns the resulting rows.
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
  /// The returned [PurchaseTombstone]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseTombstone>> upsert(
    _is.DatabaseSession session,
    List<PurchaseTombstone> rows, {
    required _is.ColumnSelections<PurchaseTombstoneTable> conflictColumns,
    _is.ColumnSelections<PurchaseTombstoneTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseTombstoneTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PurchaseTombstone>(
      rows,
      conflictColumns: conflictColumns(PurchaseTombstone.t),
      updateColumns: updateColumns?.call(PurchaseTombstone.t),
      updateWhere: updateWhere?.call(PurchaseTombstone.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PurchaseTombstone] and returns the resulting row.
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
  /// The returned [PurchaseTombstone] will have its `id` field set.
  Future<PurchaseTombstone?> upsertRow(
    _is.DatabaseSession session,
    PurchaseTombstone row, {
    required _is.ColumnSelections<PurchaseTombstoneTable> conflictColumns,
    _is.ColumnSelections<PurchaseTombstoneTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseTombstoneTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PurchaseTombstone>(
      row,
      conflictColumns: conflictColumns(PurchaseTombstone.t),
      updateColumns: updateColumns?.call(PurchaseTombstone.t),
      updateWhere: updateWhere?.call(PurchaseTombstone.t),
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseTombstone]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseTombstone>> update(
    _is.DatabaseSession session,
    List<PurchaseTombstone> rows, {
    _is.ColumnSelections<PurchaseTombstoneTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PurchaseTombstone>(
      rows,
      columns: columns?.call(PurchaseTombstone.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PurchaseTombstone]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PurchaseTombstone> updateRow(
    _is.DatabaseSession session,
    PurchaseTombstone row, {
    _is.ColumnSelections<PurchaseTombstoneTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PurchaseTombstone>(
      row,
      columns: columns?.call(PurchaseTombstone.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PurchaseTombstone] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PurchaseTombstone?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PurchaseTombstoneUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PurchaseTombstone>(
      id,
      columnValues: columnValues(PurchaseTombstone.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseTombstone]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseTombstone>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PurchaseTombstoneUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PurchaseTombstoneTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseTombstoneTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTombstoneTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PurchaseTombstone>(
      columnValues: columnValues(PurchaseTombstone.t.updateTable),
      where: where(PurchaseTombstone.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseTombstone.t),
      orderByList: orderByList?.call(PurchaseTombstone.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PurchaseTombstone]s in the list and returns the deleted rows.
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
  Future<List<PurchaseTombstone>> delete(
    _is.DatabaseSession session,
    List<PurchaseTombstone> rows, {
    _is.OrderByBuilder<PurchaseTombstoneTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTombstoneTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PurchaseTombstone>(
      rows,
      orderBy: orderBy?.call(PurchaseTombstone.t),
      orderByList: orderByList?.call(PurchaseTombstone.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PurchaseTombstone].
  Future<PurchaseTombstone> deleteRow(
    _is.DatabaseSession session,
    PurchaseTombstone row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PurchaseTombstone>(
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
  Future<List<PurchaseTombstone>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseTombstoneTable> where,
    _is.OrderByBuilder<PurchaseTombstoneTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTombstoneTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PurchaseTombstone>(
      where: where(PurchaseTombstone.t),
      orderBy: orderBy?.call(PurchaseTombstone.t),
      orderByList: orderByList?.call(PurchaseTombstone.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseTombstoneTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PurchaseTombstone>(
      where: where?.call(PurchaseTombstone.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PurchaseTombstone] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseTombstoneTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PurchaseTombstone>(
      where: where(PurchaseTombstone.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
