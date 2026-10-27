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

abstract class ProductAccount
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ProductAccount._({
    this.id,
    required this.owner,
    int? streamGeneration,
    int? deletionVersion,
    String? equippedTheme,
    this.equippedOutfit,
  }) : streamGeneration = streamGeneration ?? 0,
       deletionVersion = deletionVersion ?? 0,
       equippedTheme = equippedTheme ?? 'sunny';

  factory ProductAccount({
    int? id,
    required String owner,
    int? streamGeneration,
    int? deletionVersion,
    String? equippedTheme,
    String? equippedOutfit,
  }) = _ProductAccountImpl;

  factory ProductAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductAccount(
      id: jsonSerialization['id'] as int?,
      owner: jsonSerialization['owner'] as String,
      streamGeneration: jsonSerialization['streamGeneration'] as int?,
      deletionVersion: jsonSerialization['deletionVersion'] as int?,
      equippedTheme: jsonSerialization['equippedTheme'] as String?,
      equippedOutfit: jsonSerialization['equippedOutfit'] as String?,
    );
  }

  static final t = ProductAccountTable();

  static const db = ProductAccountRepository._();

  @override
  int? id;

  String owner;

  int streamGeneration;

  int deletionVersion;

  String equippedTheme;

  String? equippedOutfit;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProductAccount]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ProductAccount copyWith({
    int? id,
    String? owner,
    int? streamGeneration,
    int? deletionVersion,
    String? equippedTheme,
    String? equippedOutfit,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProductAccount',
      if (id != null) 'id': id,
      'owner': owner,
      'streamGeneration': streamGeneration,
      'deletionVersion': deletionVersion,
      'equippedTheme': equippedTheme,
      if (equippedOutfit != null) 'equippedOutfit': equippedOutfit,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ProductAccountInclude include() {
    return ProductAccountInclude._();
  }

  static ProductAccountIncludeList includeList({
    _is.WhereExpressionBuilder<ProductAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductAccountTable>? orderBy,
    _is.OrderByListBuilder<ProductAccountTable>? orderByList,
    ProductAccountInclude? include,
  }) {
    return ProductAccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductAccount.t),
      orderByList: orderByList?.call(ProductAccount.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductAccountImpl extends ProductAccount {
  _ProductAccountImpl({
    int? id,
    required String owner,
    int? streamGeneration,
    int? deletionVersion,
    String? equippedTheme,
    String? equippedOutfit,
  }) : super._(
         id: id,
         owner: owner,
         streamGeneration: streamGeneration,
         deletionVersion: deletionVersion,
         equippedTheme: equippedTheme,
         equippedOutfit: equippedOutfit,
       );

  /// Returns a shallow copy of this [ProductAccount]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ProductAccount copyWith({
    Object? id = _Undefined,
    String? owner,
    int? streamGeneration,
    int? deletionVersion,
    String? equippedTheme,
    Object? equippedOutfit = _Undefined,
  }) {
    return ProductAccount(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      streamGeneration: streamGeneration ?? this.streamGeneration,
      deletionVersion: deletionVersion ?? this.deletionVersion,
      equippedTheme: equippedTheme ?? this.equippedTheme,
      equippedOutfit: equippedOutfit is String?
          ? equippedOutfit
          : this.equippedOutfit,
    );
  }
}

class ProductAccountUpdateTable extends _is.UpdateTable<ProductAccountTable> {
  ProductAccountUpdateTable(super.table);

  _is.ColumnValue<String, String> owner(String value) => _is.ColumnValue(
    table.owner,
    value,
  );

  _is.ColumnValue<int, int> streamGeneration(int value) => _is.ColumnValue(
    table.streamGeneration,
    value,
  );

  _is.ColumnValue<int, int> deletionVersion(int value) => _is.ColumnValue(
    table.deletionVersion,
    value,
  );

  _is.ColumnValue<String, String> equippedTheme(String value) =>
      _is.ColumnValue(
        table.equippedTheme,
        value,
      );

  _is.ColumnValue<String, String> equippedOutfit(String? value) =>
      _is.ColumnValue(
        table.equippedOutfit,
        value,
      );
}

class ProductAccountTable extends _is.Table<int?> {
  ProductAccountTable({super.tableRelation})
    : super(tableName: 'product_account') {
    updateTable = ProductAccountUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    streamGeneration = _is.ColumnInt(
      'streamGeneration',
      this,
      hasDefault: true,
    );
    deletionVersion = _is.ColumnInt(
      'deletionVersion',
      this,
      hasDefault: true,
    );
    equippedTheme = _is.ColumnString(
      'equippedTheme',
      this,
      hasDefault: true,
    );
    equippedOutfit = _is.ColumnString(
      'equippedOutfit',
      this,
    );
  }

  late final ProductAccountUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnInt streamGeneration;

  late final _is.ColumnInt deletionVersion;

  late final _is.ColumnString equippedTheme;

  late final _is.ColumnString equippedOutfit;

  @override
  List<_is.Column> get columns => [
    id,
    owner,
    streamGeneration,
    deletionVersion,
    equippedTheme,
    equippedOutfit,
  ];
}

class ProductAccountInclude extends _is.IncludeObject {
  ProductAccountInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ProductAccount.t;
}

class ProductAccountIncludeList extends _is.IncludeList {
  ProductAccountIncludeList._({
    _is.WhereExpressionBuilder<ProductAccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProductAccount.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ProductAccount.t;
}

class ProductAccountRepository {
  const ProductAccountRepository._();

  /// Returns a list of [ProductAccount]s matching the given query parameters.
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
  Future<List<ProductAccount>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductAccountTable>? orderBy,
    _is.OrderByListBuilder<ProductAccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProductAccount>(
      where: where?.call(ProductAccount.t),
      orderBy: orderBy?.call(ProductAccount.t),
      orderByList: orderByList?.call(ProductAccount.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProductAccount] matching the given query parameters.
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
  Future<ProductAccount?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductAccountTable>? where,
    int? offset,
    _is.OrderByBuilder<ProductAccountTable>? orderBy,
    _is.OrderByListBuilder<ProductAccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProductAccount>(
      where: where?.call(ProductAccount.t),
      orderBy: orderBy?.call(ProductAccount.t),
      orderByList: orderByList?.call(ProductAccount.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProductAccount] by its [id] or null if no such row exists.
  Future<ProductAccount?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProductAccount>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProductAccount]s in the list and returns the inserted rows.
  ///
  /// The returned [ProductAccount]s will have their `id` fields set.
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
  Future<List<ProductAccount>> insert(
    _is.DatabaseSession session,
    List<ProductAccount> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ProductAccount>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ProductAccount] and returns the inserted row.
  ///
  /// The returned [ProductAccount] will have its `id` field set.
  Future<ProductAccount> insertRow(
    _is.DatabaseSession session,
    ProductAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProductAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ProductAccount]s in the list and returns the resulting rows.
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
  /// The returned [ProductAccount]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductAccount>> upsert(
    _is.DatabaseSession session,
    List<ProductAccount> rows, {
    required _is.ColumnSelections<ProductAccountTable> conflictColumns,
    _is.ColumnSelections<ProductAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<ProductAccountTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ProductAccount>(
      rows,
      conflictColumns: conflictColumns(ProductAccount.t),
      updateColumns: updateColumns?.call(ProductAccount.t),
      updateWhere: updateWhere?.call(ProductAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ProductAccount] and returns the resulting row.
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
  /// The returned [ProductAccount] will have its `id` field set.
  Future<ProductAccount?> upsertRow(
    _is.DatabaseSession session,
    ProductAccount row, {
    required _is.ColumnSelections<ProductAccountTable> conflictColumns,
    _is.ColumnSelections<ProductAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<ProductAccountTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ProductAccount>(
      row,
      conflictColumns: conflictColumns(ProductAccount.t),
      updateColumns: updateColumns?.call(ProductAccount.t),
      updateWhere: updateWhere?.call(ProductAccount.t),
      transaction: transaction,
    );
  }

  /// Updates all [ProductAccount]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductAccount>> update(
    _is.DatabaseSession session,
    List<ProductAccount> rows, {
    _is.ColumnSelections<ProductAccountTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ProductAccount>(
      rows,
      columns: columns?.call(ProductAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ProductAccount]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProductAccount> updateRow(
    _is.DatabaseSession session,
    ProductAccount row, {
    _is.ColumnSelections<ProductAccountTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProductAccount>(
      row,
      columns: columns?.call(ProductAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductAccount] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProductAccount?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ProductAccountUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ProductAccount>(
      id,
      columnValues: columnValues(ProductAccount.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProductAccount]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductAccount>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ProductAccountUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ProductAccountTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductAccountTable>? orderBy,
    _is.OrderByListBuilder<ProductAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ProductAccount>(
      columnValues: columnValues(ProductAccount.t.updateTable),
      where: where(ProductAccount.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductAccount.t),
      orderByList: orderByList?.call(ProductAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ProductAccount]s in the list and returns the deleted rows.
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
  Future<List<ProductAccount>> delete(
    _is.DatabaseSession session,
    List<ProductAccount> rows, {
    _is.OrderByBuilder<ProductAccountTable>? orderBy,
    _is.OrderByListBuilder<ProductAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ProductAccount>(
      rows,
      orderBy: orderBy?.call(ProductAccount.t),
      orderByList: orderByList?.call(ProductAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ProductAccount].
  Future<ProductAccount> deleteRow(
    _is.DatabaseSession session,
    ProductAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProductAccount>(
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
  Future<List<ProductAccount>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProductAccountTable> where,
    _is.OrderByBuilder<ProductAccountTable>? orderBy,
    _is.OrderByListBuilder<ProductAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ProductAccount>(
      where: where(ProductAccount.t),
      orderBy: orderBy?.call(ProductAccount.t),
      orderByList: orderByList?.call(ProductAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductAccountTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ProductAccount>(
      where: where?.call(ProductAccount.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProductAccount] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProductAccountTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProductAccount>(
      where: where(ProductAccount.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
