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

abstract class BillingAccount
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  BillingAccount._({
    this.id,
    required this.owner,
    this.authUserId,
    this.authUser,
    required this.binding,
    int? sequence,
  }) : sequence = sequence ?? 0;

  factory BillingAccount({
    int? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String binding,
    int? sequence,
  }) = _BillingAccountImpl;

  factory BillingAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return BillingAccount(
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
      binding: jsonSerialization['binding'] as String,
      sequence: jsonSerialization['sequence'] as int?,
    );
  }

  static final t = BillingAccountTable();

  static const db = BillingAccountRepository._();

  @override
  int? id;

  String owner;

  _is.UuidValue? authUserId;

  _iacs.AuthUser? authUser;

  String binding;

  int sequence;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [BillingAccount]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BillingAccount copyWith({
    int? id,
    String? owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? binding,
    int? sequence,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BillingAccount',
      if (id != null) 'id': id,
      'owner': owner,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'binding': binding,
      'sequence': sequence,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static BillingAccountInclude include({_iacs.AuthUserInclude? authUser}) {
    return BillingAccountInclude._(authUser: authUser);
  }

  static BillingAccountIncludeList includeList({
    _is.WhereExpressionBuilder<BillingAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillingAccountTable>? orderBy,
    _is.OrderByListBuilder<BillingAccountTable>? orderByList,
    BillingAccountInclude? include,
  }) {
    return BillingAccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillingAccount.t),
      orderByList: orderByList?.call(BillingAccount.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BillingAccountImpl extends BillingAccount {
  _BillingAccountImpl({
    int? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String binding,
    int? sequence,
  }) : super._(
         id: id,
         owner: owner,
         authUserId: authUserId,
         authUser: authUser,
         binding: binding,
         sequence: sequence,
       );

  /// Returns a shallow copy of this [BillingAccount]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BillingAccount copyWith({
    Object? id = _Undefined,
    String? owner,
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    String? binding,
    int? sequence,
  }) {
    return BillingAccount(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      authUserId: authUserId is _is.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      binding: binding ?? this.binding,
      sequence: sequence ?? this.sequence,
    );
  }
}

class BillingAccountUpdateTable extends _is.UpdateTable<BillingAccountTable> {
  BillingAccountUpdateTable(super.table);

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

  _is.ColumnValue<String, String> binding(String value) => _is.ColumnValue(
    table.binding,
    value,
  );

  _is.ColumnValue<int, int> sequence(int value) => _is.ColumnValue(
    table.sequence,
    value,
  );
}

class BillingAccountTable extends _is.Table<int?> {
  BillingAccountTable({super.tableRelation})
    : super(tableName: 'billing_account') {
    updateTable = BillingAccountUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    binding = _is.ColumnString(
      'binding',
      this,
    );
    sequence = _is.ColumnInt(
      'sequence',
      this,
      hasDefault: true,
    );
  }

  late final BillingAccountUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString binding;

  late final _is.ColumnInt sequence;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: BillingAccount.t.authUserId,
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
    binding,
    sequence,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class BillingAccountInclude extends _is.IncludeObject {
  BillingAccountInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => BillingAccount.t;
}

class BillingAccountIncludeList extends _is.IncludeList {
  BillingAccountIncludeList._({
    _is.WhereExpressionBuilder<BillingAccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BillingAccount.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => BillingAccount.t;
}

class BillingAccountRepository {
  const BillingAccountRepository._();

  final attachRow = const BillingAccountAttachRowRepository._();

  final detachRow = const BillingAccountDetachRowRepository._();

  /// Returns a list of [BillingAccount]s matching the given query parameters.
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
  Future<List<BillingAccount>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillingAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillingAccountTable>? orderBy,
    _is.OrderByListBuilder<BillingAccountTable>? orderByList,
    _is.Transaction? transaction,
    BillingAccountInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BillingAccount>(
      where: where?.call(BillingAccount.t),
      orderBy: orderBy?.call(BillingAccount.t),
      orderByList: orderByList?.call(BillingAccount.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [BillingAccount] matching the given query parameters.
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
  Future<BillingAccount?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillingAccountTable>? where,
    int? offset,
    _is.OrderByBuilder<BillingAccountTable>? orderBy,
    _is.OrderByListBuilder<BillingAccountTable>? orderByList,
    _is.Transaction? transaction,
    BillingAccountInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BillingAccount>(
      where: where?.call(BillingAccount.t),
      orderBy: orderBy?.call(BillingAccount.t),
      orderByList: orderByList?.call(BillingAccount.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BillingAccount] by its [id] or null if no such row exists.
  Future<BillingAccount?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    BillingAccountInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BillingAccount>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BillingAccount]s in the list and returns the inserted rows.
  ///
  /// The returned [BillingAccount]s will have their `id` fields set.
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
  Future<List<BillingAccount>> insert(
    _is.DatabaseSession session,
    List<BillingAccount> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<BillingAccount>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [BillingAccount] and returns the inserted row.
  ///
  /// The returned [BillingAccount] will have its `id` field set.
  Future<BillingAccount> insertRow(
    _is.DatabaseSession session,
    BillingAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<BillingAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [BillingAccount]s in the list and returns the resulting rows.
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
  /// The returned [BillingAccount]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillingAccount>> upsert(
    _is.DatabaseSession session,
    List<BillingAccount> rows, {
    required _is.ColumnSelections<BillingAccountTable> conflictColumns,
    _is.ColumnSelections<BillingAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<BillingAccountTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<BillingAccount>(
      rows,
      conflictColumns: conflictColumns(BillingAccount.t),
      updateColumns: updateColumns?.call(BillingAccount.t),
      updateWhere: updateWhere?.call(BillingAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [BillingAccount] and returns the resulting row.
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
  /// The returned [BillingAccount] will have its `id` field set.
  Future<BillingAccount?> upsertRow(
    _is.DatabaseSession session,
    BillingAccount row, {
    required _is.ColumnSelections<BillingAccountTable> conflictColumns,
    _is.ColumnSelections<BillingAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<BillingAccountTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<BillingAccount>(
      row,
      conflictColumns: conflictColumns(BillingAccount.t),
      updateColumns: updateColumns?.call(BillingAccount.t),
      updateWhere: updateWhere?.call(BillingAccount.t),
      transaction: transaction,
    );
  }

  /// Updates all [BillingAccount]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillingAccount>> update(
    _is.DatabaseSession session,
    List<BillingAccount> rows, {
    _is.ColumnSelections<BillingAccountTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<BillingAccount>(
      rows,
      columns: columns?.call(BillingAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [BillingAccount]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BillingAccount> updateRow(
    _is.DatabaseSession session,
    BillingAccount row, {
    _is.ColumnSelections<BillingAccountTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<BillingAccount>(
      row,
      columns: columns?.call(BillingAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BillingAccount] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BillingAccount?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<BillingAccountUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<BillingAccount>(
      id,
      columnValues: columnValues(BillingAccount.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BillingAccount]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BillingAccount>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BillingAccountUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BillingAccountTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BillingAccountTable>? orderBy,
    _is.OrderByListBuilder<BillingAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<BillingAccount>(
      columnValues: columnValues(BillingAccount.t.updateTable),
      where: where(BillingAccount.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BillingAccount.t),
      orderByList: orderByList?.call(BillingAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [BillingAccount]s in the list and returns the deleted rows.
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
  Future<List<BillingAccount>> delete(
    _is.DatabaseSession session,
    List<BillingAccount> rows, {
    _is.OrderByBuilder<BillingAccountTable>? orderBy,
    _is.OrderByListBuilder<BillingAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<BillingAccount>(
      rows,
      orderBy: orderBy?.call(BillingAccount.t),
      orderByList: orderByList?.call(BillingAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [BillingAccount].
  Future<BillingAccount> deleteRow(
    _is.DatabaseSession session,
    BillingAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BillingAccount>(
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
  Future<List<BillingAccount>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillingAccountTable> where,
    _is.OrderByBuilder<BillingAccountTable>? orderBy,
    _is.OrderByListBuilder<BillingAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<BillingAccount>(
      where: where(BillingAccount.t),
      orderBy: orderBy?.call(BillingAccount.t),
      orderByList: orderByList?.call(BillingAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BillingAccountTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<BillingAccount>(
      where: where?.call(BillingAccount.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BillingAccount] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BillingAccountTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BillingAccount>(
      where: where(BillingAccount.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class BillingAccountAttachRowRepository {
  const BillingAccountAttachRowRepository._();

  /// Creates a relation between the given [BillingAccount] and [AuthUser]
  /// by setting the [BillingAccount]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    BillingAccount billingAccount,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (billingAccount.id == null) {
      throw ArgumentError.notNull('billingAccount.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $billingAccount = billingAccount.copyWith(authUserId: authUser.id);
    await session.db.updateRow<BillingAccount>(
      $billingAccount,
      columns: [BillingAccount.t.authUserId],
      transaction: transaction,
    );
  }
}

class BillingAccountDetachRowRepository {
  const BillingAccountDetachRowRepository._();

  /// Detaches the relation between this [BillingAccount] and the [AuthUser] set in `authUser`
  /// by setting the [BillingAccount]'s foreign key `authUserId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> authUser(
    _is.DatabaseSession session,
    BillingAccount billingAccount, {
    _is.Transaction? transaction,
  }) async {
    if (billingAccount.id == null) {
      throw ArgumentError.notNull('billingAccount.id');
    }

    var $billingAccount = billingAccount.copyWith(authUserId: null);
    await session.db.updateRow<BillingAccount>(
      $billingAccount,
      columns: [BillingAccount.t.authUserId],
      transaction: transaction,
    );
  }
}
