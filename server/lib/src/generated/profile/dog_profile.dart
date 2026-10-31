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

abstract class DogProfile
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DogProfile._({
    this.id,
    required this.owner,
    this.authUserId,
    this.authUser,
    required this.breedId,
    required this.name,
    required this.sex,
    required this.dailyGoal,
    required this.firstMetAt,
    int? revision,
  }) : revision = revision ?? 1;

  factory DogProfile({
    int? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String breedId,
    required String name,
    required String sex,
    required int dailyGoal,
    required DateTime firstMetAt,
    int? revision,
  }) = _DogProfileImpl;

  factory DogProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return DogProfile(
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
      breedId: jsonSerialization['breedId'] as String,
      name: jsonSerialization['name'] as String,
      sex: jsonSerialization['sex'] as String,
      dailyGoal: jsonSerialization['dailyGoal'] as int,
      firstMetAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['firstMetAt'],
      ),
      revision: jsonSerialization['revision'] as int?,
    );
  }

  static final t = DogProfileTable();

  static const db = DogProfileRepository._();

  @override
  int? id;

  String owner;

  _is.UuidValue? authUserId;

  _iacs.AuthUser? authUser;

  String breedId;

  String name;

  String sex;

  int dailyGoal;

  DateTime firstMetAt;

  int revision;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DogProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DogProfile copyWith({
    int? id,
    String? owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? breedId,
    String? name,
    String? sex,
    int? dailyGoal,
    DateTime? firstMetAt,
    int? revision,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DogProfile',
      if (id != null) 'id': id,
      'owner': owner,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'breedId': breedId,
      'name': name,
      'sex': sex,
      'dailyGoal': dailyGoal,
      'firstMetAt': firstMetAt.toJson(),
      'revision': revision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DogProfileInclude include({_iacs.AuthUserInclude? authUser}) {
    return DogProfileInclude._(authUser: authUser);
  }

  static DogProfileIncludeList includeList({
    _is.WhereExpressionBuilder<DogProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DogProfileTable>? orderBy,
    _is.OrderByListBuilder<DogProfileTable>? orderByList,
    DogProfileInclude? include,
  }) {
    return DogProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DogProfile.t),
      orderByList: orderByList?.call(DogProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DogProfileImpl extends DogProfile {
  _DogProfileImpl({
    int? id,
    required String owner,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    required String breedId,
    required String name,
    required String sex,
    required int dailyGoal,
    required DateTime firstMetAt,
    int? revision,
  }) : super._(
         id: id,
         owner: owner,
         authUserId: authUserId,
         authUser: authUser,
         breedId: breedId,
         name: name,
         sex: sex,
         dailyGoal: dailyGoal,
         firstMetAt: firstMetAt,
         revision: revision,
       );

  /// Returns a shallow copy of this [DogProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DogProfile copyWith({
    Object? id = _Undefined,
    String? owner,
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    String? breedId,
    String? name,
    String? sex,
    int? dailyGoal,
    DateTime? firstMetAt,
    int? revision,
  }) {
    return DogProfile(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      authUserId: authUserId is _is.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      breedId: breedId ?? this.breedId,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      firstMetAt: firstMetAt ?? this.firstMetAt,
      revision: revision ?? this.revision,
    );
  }
}

class DogProfileUpdateTable extends _is.UpdateTable<DogProfileTable> {
  DogProfileUpdateTable(super.table);

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

  _is.ColumnValue<String, String> breedId(String value) => _is.ColumnValue(
    table.breedId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> sex(String value) => _is.ColumnValue(
    table.sex,
    value,
  );

  _is.ColumnValue<int, int> dailyGoal(int value) => _is.ColumnValue(
    table.dailyGoal,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> firstMetAt(DateTime value) =>
      _is.ColumnValue(
        table.firstMetAt,
        value,
      );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );
}

class DogProfileTable extends _is.Table<int?> {
  DogProfileTable({super.tableRelation}) : super(tableName: 'dog_profile') {
    updateTable = DogProfileUpdateTable(this);
    owner = _is.ColumnString(
      'owner',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    breedId = _is.ColumnString(
      'breedId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    sex = _is.ColumnString(
      'sex',
      this,
    );
    dailyGoal = _is.ColumnInt(
      'dailyGoal',
      this,
    );
    firstMetAt = _is.ColumnDateTime(
      'firstMetAt',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
      hasDefault: true,
    );
  }

  late final DogProfileUpdateTable updateTable;

  late final _is.ColumnString owner;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString breedId;

  late final _is.ColumnString name;

  late final _is.ColumnString sex;

  late final _is.ColumnInt dailyGoal;

  late final _is.ColumnDateTime firstMetAt;

  late final _is.ColumnInt revision;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: DogProfile.t.authUserId,
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
    breedId,
    name,
    sex,
    dailyGoal,
    firstMetAt,
    revision,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class DogProfileInclude extends _is.IncludeObject {
  DogProfileInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => DogProfile.t;
}

class DogProfileIncludeList extends _is.IncludeList {
  DogProfileIncludeList._({
    _is.WhereExpressionBuilder<DogProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DogProfile.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DogProfile.t;
}

class DogProfileRepository {
  const DogProfileRepository._();

  final attachRow = const DogProfileAttachRowRepository._();

  final detachRow = const DogProfileDetachRowRepository._();

  /// Returns a list of [DogProfile]s matching the given query parameters.
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
  Future<List<DogProfile>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DogProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DogProfileTable>? orderBy,
    _is.OrderByListBuilder<DogProfileTable>? orderByList,
    _is.Transaction? transaction,
    DogProfileInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DogProfile>(
      where: where?.call(DogProfile.t),
      orderBy: orderBy?.call(DogProfile.t),
      orderByList: orderByList?.call(DogProfile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DogProfile] matching the given query parameters.
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
  Future<DogProfile?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DogProfileTable>? where,
    int? offset,
    _is.OrderByBuilder<DogProfileTable>? orderBy,
    _is.OrderByListBuilder<DogProfileTable>? orderByList,
    _is.Transaction? transaction,
    DogProfileInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DogProfile>(
      where: where?.call(DogProfile.t),
      orderBy: orderBy?.call(DogProfile.t),
      orderByList: orderByList?.call(DogProfile.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DogProfile] by its [id] or null if no such row exists.
  Future<DogProfile?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    DogProfileInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DogProfile>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DogProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [DogProfile]s will have their `id` fields set.
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
  Future<List<DogProfile>> insert(
    _is.DatabaseSession session,
    List<DogProfile> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DogProfile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DogProfile] and returns the inserted row.
  ///
  /// The returned [DogProfile] will have its `id` field set.
  Future<DogProfile> insertRow(
    _is.DatabaseSession session,
    DogProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DogProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DogProfile]s in the list and returns the resulting rows.
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
  /// The returned [DogProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DogProfile>> upsert(
    _is.DatabaseSession session,
    List<DogProfile> rows, {
    required _is.ColumnSelections<DogProfileTable> conflictColumns,
    _is.ColumnSelections<DogProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<DogProfileTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DogProfile>(
      rows,
      conflictColumns: conflictColumns(DogProfile.t),
      updateColumns: updateColumns?.call(DogProfile.t),
      updateWhere: updateWhere?.call(DogProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DogProfile] and returns the resulting row.
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
  /// The returned [DogProfile] will have its `id` field set.
  Future<DogProfile?> upsertRow(
    _is.DatabaseSession session,
    DogProfile row, {
    required _is.ColumnSelections<DogProfileTable> conflictColumns,
    _is.ColumnSelections<DogProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<DogProfileTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DogProfile>(
      row,
      conflictColumns: conflictColumns(DogProfile.t),
      updateColumns: updateColumns?.call(DogProfile.t),
      updateWhere: updateWhere?.call(DogProfile.t),
      transaction: transaction,
    );
  }

  /// Updates all [DogProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DogProfile>> update(
    _is.DatabaseSession session,
    List<DogProfile> rows, {
    _is.ColumnSelections<DogProfileTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DogProfile>(
      rows,
      columns: columns?.call(DogProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DogProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DogProfile> updateRow(
    _is.DatabaseSession session,
    DogProfile row, {
    _is.ColumnSelections<DogProfileTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DogProfile>(
      row,
      columns: columns?.call(DogProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DogProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DogProfile?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DogProfileUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DogProfile>(
      id,
      columnValues: columnValues(DogProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DogProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DogProfile>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DogProfileUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DogProfileTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DogProfileTable>? orderBy,
    _is.OrderByListBuilder<DogProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DogProfile>(
      columnValues: columnValues(DogProfile.t.updateTable),
      where: where(DogProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DogProfile.t),
      orderByList: orderByList?.call(DogProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DogProfile]s in the list and returns the deleted rows.
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
  Future<List<DogProfile>> delete(
    _is.DatabaseSession session,
    List<DogProfile> rows, {
    _is.OrderByBuilder<DogProfileTable>? orderBy,
    _is.OrderByListBuilder<DogProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DogProfile>(
      rows,
      orderBy: orderBy?.call(DogProfile.t),
      orderByList: orderByList?.call(DogProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DogProfile].
  Future<DogProfile> deleteRow(
    _is.DatabaseSession session,
    DogProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DogProfile>(
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
  Future<List<DogProfile>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DogProfileTable> where,
    _is.OrderByBuilder<DogProfileTable>? orderBy,
    _is.OrderByListBuilder<DogProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DogProfile>(
      where: where(DogProfile.t),
      orderBy: orderBy?.call(DogProfile.t),
      orderByList: orderByList?.call(DogProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DogProfileTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DogProfile>(
      where: where?.call(DogProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DogProfile] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DogProfileTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DogProfile>(
      where: where(DogProfile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class DogProfileAttachRowRepository {
  const DogProfileAttachRowRepository._();

  /// Creates a relation between the given [DogProfile] and [AuthUser]
  /// by setting the [DogProfile]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    DogProfile dogProfile,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (dogProfile.id == null) {
      throw ArgumentError.notNull('dogProfile.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $dogProfile = dogProfile.copyWith(authUserId: authUser.id);
    await session.db.updateRow<DogProfile>(
      $dogProfile,
      columns: [DogProfile.t.authUserId],
      transaction: transaction,
    );
  }
}

class DogProfileDetachRowRepository {
  const DogProfileDetachRowRepository._();

  /// Detaches the relation between this [DogProfile] and the [AuthUser] set in `authUser`
  /// by setting the [DogProfile]'s foreign key `authUserId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> authUser(
    _is.DatabaseSession session,
    DogProfile dogProfile, {
    _is.Transaction? transaction,
  }) async {
    if (dogProfile.id == null) {
      throw ArgumentError.notNull('dogProfile.id');
    }

    var $dogProfile = dogProfile.copyWith(authUserId: null);
    await session.db.updateRow<DogProfile>(
      $dogProfile,
      columns: [DogProfile.t.authUserId],
      transaction: transaction,
    );
  }
}
