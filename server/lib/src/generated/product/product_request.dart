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

abstract class ProductRequest
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ProductRequest._({
    this.id,
    required this.owner,
    this.authUserId,
    this.authUser,
    required this.requestId,
    required this.digest,
    required this.result,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProductRequest({
    int? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String requestId,
    required String digest,
    required String result,
    DateTime? createdAt,
  }) = _ProductRequestImpl;

  factory ProductRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductRequest(
      id: jsonSerialization['id'] as int?,
      owner: jsonSerialization['owner'] as String,
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      requestId: jsonSerialization['requestId'] as String,
      digest: jsonSerialization['digest'] as String,
      result: jsonSerialization['result'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ProductRequestTable();

  static const db = ProductRequestRepository._();

  @override
  int? id;

  String owner;

  _is.UuidValue? authUserId;

  _iacs.AuthUser? authUser;

  String requestId;

  String digest;

  String result;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProductRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ProductRequest copyWith({
    int? id,
    String? owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? requestId,
    String? digest,
    String? result,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProductRequest',
      if (id != null) 'id': id,
      'owner': owner,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'requestId': requestId,
      'digest': digest,
      'result': result,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ProductRequestInclude include({_iacs.AuthUserInclude? authUser}) {
    return ProductRequestInclude._(authUser: authUser);
  }

  static ProductRequestIncludeList includeList({
    _is.WhereExpressionBuilder<ProductRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductRequestTable>? orderBy,
    _is.OrderByListBuilder<ProductRequestTable>? orderByList,
    ProductRequestInclude? include,
  }) {
    return ProductRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductRequest.t),
      orderByList: orderByList?.call(ProductRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductRequestImpl extends ProductRequest {
  _ProductRequestImpl({
    int? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String requestId,
    required String digest,
    required String result,
    DateTime? createdAt,
  }) : super._(
         id: id,
         owner: owner,
         authUserId: authUserId,
         authUser: authUser,
         requestId: requestId,
         digest: digest,
         result: result,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ProductRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ProductRequest copyWith({
    Object? id = _Undefined,
    String? owner,
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    String? requestId,
    String? digest,
    String? result,
    DateTime? createdAt,
  }) {
    return ProductRequest(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      authUserId: authUserId is _is.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      requestId: requestId ?? this.requestId,
      digest: digest ?? this.digest,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProductRequestUpdateTable extends _is.UpdateTable<ProductRequestTable> {
  ProductRequestUpdateTable(super.table);

  _is.ColumnValue<String, String> owner(String value) => _is.ColumnValue(
    table.owner,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> requestId(String value) => _is.ColumnValue(
    table.requestId,
    value,
  );

  _is.ColumnValue<String, String> digest(String value) => _is.ColumnValue(
    table.digest,
    value,
  );

  _is.ColumnValue<String, String> result(String value) => _is.ColumnValue(
    table.result,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ProductRequestTable extends _is.Table<int?> {
  ProductRequestTable({super.tableRelation})
    : super(tableName: 'product_request') {
    updateTable = ProductRequestUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    requestId = _is.ColumnString(
      'requestId',
      this,
    );
    digest = _is.ColumnString(
      'digest',
      this,
    );
    result = _is.ColumnString(
      'result',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ProductRequestUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString requestId;

  late final _is.ColumnString digest;

  late final _is.ColumnString result;

  late final _is.ColumnDateTime createdAt;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: ProductRequest.t.authUserId,
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
    owner,
    authUserId,
    requestId,
    digest,
    result,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class ProductRequestInclude extends _is.IncludeObject {
  ProductRequestInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => ProductRequest.t;
}

class ProductRequestIncludeList extends _is.IncludeList {
  ProductRequestIncludeList._({
    _is.WhereExpressionBuilder<ProductRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProductRequest.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ProductRequest.t;
}

class ProductRequestRepository {
  const ProductRequestRepository._();

  final attachRow = const ProductRequestAttachRowRepository._();

  final detachRow = const ProductRequestDetachRowRepository._();

  /// Returns a list of [ProductRequest]s matching the given query parameters.
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
  Future<List<ProductRequest>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductRequestTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductRequestTable>? orderBy,
    _is.OrderByListBuilder<ProductRequestTable>? orderByList,
    _is.Transaction? transaction,
    ProductRequestInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProductRequest>(
      where: where?.call(ProductRequest.t),
      orderBy: orderBy?.call(ProductRequest.t),
      orderByList: orderByList?.call(ProductRequest.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProductRequest] matching the given query parameters.
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
  Future<ProductRequest?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductRequestTable>? where,
    int? offset,
    _is.OrderByBuilder<ProductRequestTable>? orderBy,
    _is.OrderByListBuilder<ProductRequestTable>? orderByList,
    _is.Transaction? transaction,
    ProductRequestInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProductRequest>(
      where: where?.call(ProductRequest.t),
      orderBy: orderBy?.call(ProductRequest.t),
      orderByList: orderByList?.call(ProductRequest.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProductRequest] by its [id] or null if no such row exists.
  Future<ProductRequest?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    ProductRequestInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProductRequest>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProductRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [ProductRequest]s will have their `id` fields set.
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
  Future<List<ProductRequest>> insert(
    _is.DatabaseSession session,
    List<ProductRequest> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ProductRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ProductRequest] and returns the inserted row.
  ///
  /// The returned [ProductRequest] will have its `id` field set.
  Future<ProductRequest> insertRow(
    _is.DatabaseSession session,
    ProductRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProductRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ProductRequest]s in the list and returns the resulting rows.
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
  /// The returned [ProductRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductRequest>> upsert(
    _is.DatabaseSession session,
    List<ProductRequest> rows, {
    required _is.ColumnSelections<ProductRequestTable> conflictColumns,
    _is.ColumnSelections<ProductRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<ProductRequestTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ProductRequest>(
      rows,
      conflictColumns: conflictColumns(ProductRequest.t),
      updateColumns: updateColumns?.call(ProductRequest.t),
      updateWhere: updateWhere?.call(ProductRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ProductRequest] and returns the resulting row.
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
  /// The returned [ProductRequest] will have its `id` field set.
  Future<ProductRequest?> upsertRow(
    _is.DatabaseSession session,
    ProductRequest row, {
    required _is.ColumnSelections<ProductRequestTable> conflictColumns,
    _is.ColumnSelections<ProductRequestTable>? updateColumns,
    _is.WhereExpressionBuilder<ProductRequestTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ProductRequest>(
      row,
      conflictColumns: conflictColumns(ProductRequest.t),
      updateColumns: updateColumns?.call(ProductRequest.t),
      updateWhere: updateWhere?.call(ProductRequest.t),
      transaction: transaction,
    );
  }

  /// Updates all [ProductRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductRequest>> update(
    _is.DatabaseSession session,
    List<ProductRequest> rows, {
    _is.ColumnSelections<ProductRequestTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ProductRequest>(
      rows,
      columns: columns?.call(ProductRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ProductRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProductRequest> updateRow(
    _is.DatabaseSession session,
    ProductRequest row, {
    _is.ColumnSelections<ProductRequestTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProductRequest>(
      row,
      columns: columns?.call(ProductRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProductRequest?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ProductRequestUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ProductRequest>(
      id,
      columnValues: columnValues(ProductRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProductRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductRequest>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ProductRequestUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ProductRequestTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductRequestTable>? orderBy,
    _is.OrderByListBuilder<ProductRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ProductRequest>(
      columnValues: columnValues(ProductRequest.t.updateTable),
      where: where(ProductRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductRequest.t),
      orderByList: orderByList?.call(ProductRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ProductRequest]s in the list and returns the deleted rows.
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
  Future<List<ProductRequest>> delete(
    _is.DatabaseSession session,
    List<ProductRequest> rows, {
    _is.OrderByBuilder<ProductRequestTable>? orderBy,
    _is.OrderByListBuilder<ProductRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ProductRequest>(
      rows,
      orderBy: orderBy?.call(ProductRequest.t),
      orderByList: orderByList?.call(ProductRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ProductRequest].
  Future<ProductRequest> deleteRow(
    _is.DatabaseSession session,
    ProductRequest row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProductRequest>(
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
  Future<List<ProductRequest>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProductRequestTable> where,
    _is.OrderByBuilder<ProductRequestTable>? orderBy,
    _is.OrderByListBuilder<ProductRequestTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ProductRequest>(
      where: where(ProductRequest.t),
      orderBy: orderBy?.call(ProductRequest.t),
      orderByList: orderByList?.call(ProductRequest.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductRequestTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ProductRequest>(
      where: where?.call(ProductRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProductRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProductRequestTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProductRequest>(
      where: where(ProductRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ProductRequestAttachRowRepository {
  const ProductRequestAttachRowRepository._();

  /// Creates a relation between the given [ProductRequest] and [AuthUser]
  /// by setting the [ProductRequest]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    ProductRequest productRequest,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (productRequest.id == null) {
      throw ArgumentError.notNull('productRequest.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $productRequest = productRequest.copyWith(authUserId: authUser.id);
    await session.db.updateRow<ProductRequest>(
      $productRequest,
      columns: [ProductRequest.t.authUserId],
      transaction: transaction,
    );
  }
}

class ProductRequestDetachRowRepository {
  const ProductRequestDetachRowRepository._();

  /// Detaches the relation between this [ProductRequest] and the [AuthUser] set in `authUser`
  /// by setting the [ProductRequest]'s foreign key `authUserId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> authUser(
    _is.DatabaseSession session,
    ProductRequest productRequest, {
    _is.Transaction? transaction,
  }) async {
    if (productRequest.id == null) {
      throw ArgumentError.notNull('productRequest.id');
    }

    var $productRequest = productRequest.copyWith(authUserId: null);
    await session.db.updateRow<ProductRequest>(
      $productRequest,
      columns: [ProductRequest.t.authUserId],
      transaction: transaction,
    );
  }
}
