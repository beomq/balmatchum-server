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

/// One worn item per slot. The background stays in product_account.equippedTheme.
abstract class OutfitEquip
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  OutfitEquip._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.slot,
    required this.outfitId,
    required this.colourId,
  });

  factory OutfitEquip({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String slot,
    required String outfitId,
    required String colourId,
  }) = _OutfitEquipImpl;

  factory OutfitEquip.fromJson(Map<String, dynamic> jsonSerialization) {
    return OutfitEquip(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      slot: jsonSerialization['slot'] as String,
      outfitId: jsonSerialization['outfitId'] as String,
      colourId: jsonSerialization['colourId'] as String,
    );
  }

  static final t = OutfitEquipTable();

  static const db = OutfitEquipRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String slot;

  String outfitId;

  String colourId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [OutfitEquip]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OutfitEquip copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? slot,
    String? outfitId,
    String? colourId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OutfitEquip',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'slot': slot,
      'outfitId': outfitId,
      'colourId': colourId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static OutfitEquipInclude include({_iacs.AuthUserInclude? authUser}) {
    return OutfitEquipInclude._(authUser: authUser);
  }

  static OutfitEquipIncludeList includeList({
    _is.WhereExpressionBuilder<OutfitEquipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutfitEquipTable>? orderBy,
    _is.OrderByListBuilder<OutfitEquipTable>? orderByList,
    OutfitEquipInclude? include,
  }) {
    return OutfitEquipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OutfitEquip.t),
      orderByList: orderByList?.call(OutfitEquip.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OutfitEquipImpl extends OutfitEquip {
  _OutfitEquipImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String slot,
    required String outfitId,
    required String colourId,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         slot: slot,
         outfitId: outfitId,
         colourId: colourId,
       );

  /// Returns a shallow copy of this [OutfitEquip]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OutfitEquip copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? slot,
    String? outfitId,
    String? colourId,
  }) {
    return OutfitEquip(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      slot: slot ?? this.slot,
      outfitId: outfitId ?? this.outfitId,
      colourId: colourId ?? this.colourId,
    );
  }
}

class OutfitEquipUpdateTable extends _is.UpdateTable<OutfitEquipTable> {
  OutfitEquipUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> slot(String value) => _is.ColumnValue(
    table.slot,
    value,
  );

  _is.ColumnValue<String, String> outfitId(String value) => _is.ColumnValue(
    table.outfitId,
    value,
  );

  _is.ColumnValue<String, String> colourId(String value) => _is.ColumnValue(
    table.colourId,
    value,
  );
}

class OutfitEquipTable extends _is.Table<int?> {
  OutfitEquipTable({super.tableRelation}) : super(tableName: 'outfit_equip') {
    updateTable = OutfitEquipUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    slot = _is.ColumnString(
      'slot',
      this,
    );
    outfitId = _is.ColumnString(
      'outfitId',
      this,
    );
    colourId = _is.ColumnString(
      'colourId',
      this,
    );
  }

  late final OutfitEquipUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString slot;

  late final _is.ColumnString outfitId;

  late final _is.ColumnString colourId;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: OutfitEquip.t.authUserId,
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
    slot,
    outfitId,
    colourId,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class OutfitEquipInclude extends _is.IncludeObject {
  OutfitEquipInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => OutfitEquip.t;
}

class OutfitEquipIncludeList extends _is.IncludeList {
  OutfitEquipIncludeList._({
    _is.WhereExpressionBuilder<OutfitEquipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OutfitEquip.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => OutfitEquip.t;
}

class OutfitEquipRepository {
  const OutfitEquipRepository._();

  final attachRow = const OutfitEquipAttachRowRepository._();

  /// Returns a list of [OutfitEquip]s matching the given query parameters.
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
  Future<List<OutfitEquip>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutfitEquipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutfitEquipTable>? orderBy,
    _is.OrderByListBuilder<OutfitEquipTable>? orderByList,
    _is.Transaction? transaction,
    OutfitEquipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OutfitEquip>(
      where: where?.call(OutfitEquip.t),
      orderBy: orderBy?.call(OutfitEquip.t),
      orderByList: orderByList?.call(OutfitEquip.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OutfitEquip] matching the given query parameters.
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
  Future<OutfitEquip?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutfitEquipTable>? where,
    int? offset,
    _is.OrderByBuilder<OutfitEquipTable>? orderBy,
    _is.OrderByListBuilder<OutfitEquipTable>? orderByList,
    _is.Transaction? transaction,
    OutfitEquipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OutfitEquip>(
      where: where?.call(OutfitEquip.t),
      orderBy: orderBy?.call(OutfitEquip.t),
      orderByList: orderByList?.call(OutfitEquip.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OutfitEquip] by its [id] or null if no such row exists.
  Future<OutfitEquip?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    OutfitEquipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OutfitEquip>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OutfitEquip]s in the list and returns the inserted rows.
  ///
  /// The returned [OutfitEquip]s will have their `id` fields set.
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
  Future<List<OutfitEquip>> insert(
    _is.DatabaseSession session,
    List<OutfitEquip> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<OutfitEquip>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [OutfitEquip] and returns the inserted row.
  ///
  /// The returned [OutfitEquip] will have its `id` field set.
  Future<OutfitEquip> insertRow(
    _is.DatabaseSession session,
    OutfitEquip row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<OutfitEquip>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [OutfitEquip]s in the list and returns the resulting rows.
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
  /// The returned [OutfitEquip]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OutfitEquip>> upsert(
    _is.DatabaseSession session,
    List<OutfitEquip> rows, {
    required _is.ColumnSelections<OutfitEquipTable> conflictColumns,
    _is.ColumnSelections<OutfitEquipTable>? updateColumns,
    _is.WhereExpressionBuilder<OutfitEquipTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<OutfitEquip>(
      rows,
      conflictColumns: conflictColumns(OutfitEquip.t),
      updateColumns: updateColumns?.call(OutfitEquip.t),
      updateWhere: updateWhere?.call(OutfitEquip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [OutfitEquip] and returns the resulting row.
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
  /// The returned [OutfitEquip] will have its `id` field set.
  Future<OutfitEquip?> upsertRow(
    _is.DatabaseSession session,
    OutfitEquip row, {
    required _is.ColumnSelections<OutfitEquipTable> conflictColumns,
    _is.ColumnSelections<OutfitEquipTable>? updateColumns,
    _is.WhereExpressionBuilder<OutfitEquipTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<OutfitEquip>(
      row,
      conflictColumns: conflictColumns(OutfitEquip.t),
      updateColumns: updateColumns?.call(OutfitEquip.t),
      updateWhere: updateWhere?.call(OutfitEquip.t),
      transaction: transaction,
    );
  }

  /// Updates all [OutfitEquip]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OutfitEquip>> update(
    _is.DatabaseSession session,
    List<OutfitEquip> rows, {
    _is.ColumnSelections<OutfitEquipTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<OutfitEquip>(
      rows,
      columns: columns?.call(OutfitEquip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [OutfitEquip]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OutfitEquip> updateRow(
    _is.DatabaseSession session,
    OutfitEquip row, {
    _is.ColumnSelections<OutfitEquipTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<OutfitEquip>(
      row,
      columns: columns?.call(OutfitEquip.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OutfitEquip] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OutfitEquip?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<OutfitEquipUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<OutfitEquip>(
      id,
      columnValues: columnValues(OutfitEquip.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OutfitEquip]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OutfitEquip>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<OutfitEquipUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<OutfitEquipTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutfitEquipTable>? orderBy,
    _is.OrderByListBuilder<OutfitEquipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<OutfitEquip>(
      columnValues: columnValues(OutfitEquip.t.updateTable),
      where: where(OutfitEquip.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OutfitEquip.t),
      orderByList: orderByList?.call(OutfitEquip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [OutfitEquip]s in the list and returns the deleted rows.
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
  Future<List<OutfitEquip>> delete(
    _is.DatabaseSession session,
    List<OutfitEquip> rows, {
    _is.OrderByBuilder<OutfitEquipTable>? orderBy,
    _is.OrderByListBuilder<OutfitEquipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<OutfitEquip>(
      rows,
      orderBy: orderBy?.call(OutfitEquip.t),
      orderByList: orderByList?.call(OutfitEquip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [OutfitEquip].
  Future<OutfitEquip> deleteRow(
    _is.DatabaseSession session,
    OutfitEquip row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OutfitEquip>(
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
  Future<List<OutfitEquip>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OutfitEquipTable> where,
    _is.OrderByBuilder<OutfitEquipTable>? orderBy,
    _is.OrderByListBuilder<OutfitEquipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<OutfitEquip>(
      where: where(OutfitEquip.t),
      orderBy: orderBy?.call(OutfitEquip.t),
      orderByList: orderByList?.call(OutfitEquip.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutfitEquipTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<OutfitEquip>(
      where: where?.call(OutfitEquip.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OutfitEquip] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OutfitEquipTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OutfitEquip>(
      where: where(OutfitEquip.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class OutfitEquipAttachRowRepository {
  const OutfitEquipAttachRowRepository._();

  /// Creates a relation between the given [OutfitEquip] and [AuthUser]
  /// by setting the [OutfitEquip]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    OutfitEquip outfitEquip,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (outfitEquip.id == null) {
      throw ArgumentError.notNull('outfitEquip.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $outfitEquip = outfitEquip.copyWith(authUserId: authUser.id);
    await session.db.updateRow<OutfitEquip>(
      $outfitEquip,
      columns: [OutfitEquip.t.authUserId],
      transaction: transaction,
    );
  }
}
