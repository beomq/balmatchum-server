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

abstract class StoredPhoto
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  StoredPhoto._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.objectKey,
    required this.contentType,
    required this.byteSize,
    this.width,
    this.height,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
  });

  factory StoredPhoto({
    _is.UuidValue? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String objectKey,
    required String contentType,
    required int byteSize,
    int? width,
    int? height,
    required String status,
    required DateTime createdAt,
    DateTime? confirmedAt,
  }) = _StoredPhotoImpl;

  factory StoredPhoto.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoredPhoto(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _iu3f2ih9.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      objectKey: jsonSerialization['objectKey'] as String,
      contentType: jsonSerialization['contentType'] as String,
      byteSize: jsonSerialization['byteSize'] as int,
      width: jsonSerialization['width'] as int?,
      height: jsonSerialization['height'] as int?,
      status: jsonSerialization['status'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      confirmedAt: jsonSerialization['confirmedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['confirmedAt'],
            ),
    );
  }

  static final t = StoredPhotoTable();

  static const db = StoredPhotoRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue authUserId;

  _iacs.AuthUser? authUser;

  String objectKey;

  String contentType;

  int byteSize;

  int? width;

  int? height;

  String status;

  DateTime createdAt;

  DateTime? confirmedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [StoredPhoto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StoredPhoto copyWith({
    _is.UuidValue? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? objectKey,
    String? contentType,
    int? byteSize,
    int? width,
    int? height,
    String? status,
    DateTime? createdAt,
    DateTime? confirmedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoredPhoto',
      if (id != null) 'id': id?.toJson(),
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'objectKey': objectKey,
      'contentType': contentType,
      'byteSize': byteSize,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'status': status,
      'createdAt': createdAt.toJson(),
      if (confirmedAt != null) 'confirmedAt': confirmedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StoredPhotoInclude include({_iacs.AuthUserInclude? authUser}) {
    return StoredPhotoInclude._(authUser: authUser);
  }

  static StoredPhotoIncludeList includeList({
    _is.WhereExpressionBuilder<StoredPhotoTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredPhotoTable>? orderBy,
    _is.OrderByListBuilder<StoredPhotoTable>? orderByList,
    StoredPhotoInclude? include,
  }) {
    return StoredPhotoIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoredPhoto.t),
      orderByList: orderByList?.call(StoredPhoto.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoredPhotoImpl extends StoredPhoto {
  _StoredPhotoImpl({
    _is.UuidValue? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String objectKey,
    required String contentType,
    required int byteSize,
    int? width,
    int? height,
    required String status,
    required DateTime createdAt,
    DateTime? confirmedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         objectKey: objectKey,
         contentType: contentType,
         byteSize: byteSize,
         width: width,
         height: height,
         status: status,
         createdAt: createdAt,
         confirmedAt: confirmedAt,
       );

  /// Returns a shallow copy of this [StoredPhoto]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StoredPhoto copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? objectKey,
    String? contentType,
    int? byteSize,
    Object? width = _Undefined,
    Object? height = _Undefined,
    String? status,
    DateTime? createdAt,
    Object? confirmedAt = _Undefined,
  }) {
    return StoredPhoto(
      id: id is _is.UuidValue? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      objectKey: objectKey ?? this.objectKey,
      contentType: contentType ?? this.contentType,
      byteSize: byteSize ?? this.byteSize,
      width: width is int? ? width : this.width,
      height: height is int? ? height : this.height,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt is DateTime? ? confirmedAt : this.confirmedAt,
    );
  }
}

class StoredPhotoUpdateTable extends _is.UpdateTable<StoredPhotoTable> {
  StoredPhotoUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> objectKey(String value) => _is.ColumnValue(
    table.objectKey,
    value,
  );

  _is.ColumnValue<String, String> contentType(String value) => _is.ColumnValue(
    table.contentType,
    value,
  );

  _is.ColumnValue<int, int> byteSize(int value) => _is.ColumnValue(
    table.byteSize,
    value,
  );

  _is.ColumnValue<int, int> width(int? value) => _is.ColumnValue(
    table.width,
    value,
  );

  _is.ColumnValue<int, int> height(int? value) => _is.ColumnValue(
    table.height,
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

  _is.ColumnValue<DateTime, DateTime> confirmedAt(DateTime? value) =>
      _is.ColumnValue(
        table.confirmedAt,
        value,
      );
}

class StoredPhotoTable extends _is.Table<_is.UuidValue?> {
  StoredPhotoTable({super.tableRelation}) : super(tableName: 'photo') {
    updateTable = StoredPhotoUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    objectKey = _is.ColumnString(
      'objectKey',
      this,
    );
    contentType = _is.ColumnString(
      'contentType',
      this,
    );
    byteSize = _is.ColumnInt(
      'byteSize',
      this,
    );
    width = _is.ColumnInt(
      'width',
      this,
    );
    height = _is.ColumnInt(
      'height',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    confirmedAt = _is.ColumnDateTime(
      'confirmedAt',
      this,
    );
  }

  late final StoredPhotoUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString objectKey;

  late final _is.ColumnString contentType;

  late final _is.ColumnInt byteSize;

  late final _is.ColumnInt width;

  late final _is.ColumnInt height;

  late final _is.ColumnString status;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime confirmedAt;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: StoredPhoto.t.authUserId,
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
    objectKey,
    contentType,
    byteSize,
    width,
    height,
    status,
    createdAt,
    confirmedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class StoredPhotoInclude extends _is.IncludeObject {
  StoredPhotoInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<_is.UuidValue?> get table => StoredPhoto.t;
}

class StoredPhotoIncludeList extends _is.IncludeList {
  StoredPhotoIncludeList._({
    _is.WhereExpressionBuilder<StoredPhotoTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StoredPhoto.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => StoredPhoto.t;
}

class StoredPhotoRepository {
  const StoredPhotoRepository._();

  final attachRow = const StoredPhotoAttachRowRepository._();

  /// Returns a list of [StoredPhoto]s matching the given query parameters.
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
  Future<List<StoredPhoto>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredPhotoTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredPhotoTable>? orderBy,
    _is.OrderByListBuilder<StoredPhotoTable>? orderByList,
    _is.Transaction? transaction,
    StoredPhotoInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StoredPhoto>(
      where: where?.call(StoredPhoto.t),
      orderBy: orderBy?.call(StoredPhoto.t),
      orderByList: orderByList?.call(StoredPhoto.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [StoredPhoto] matching the given query parameters.
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
  Future<StoredPhoto?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredPhotoTable>? where,
    int? offset,
    _is.OrderByBuilder<StoredPhotoTable>? orderBy,
    _is.OrderByListBuilder<StoredPhotoTable>? orderByList,
    _is.Transaction? transaction,
    StoredPhotoInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StoredPhoto>(
      where: where?.call(StoredPhoto.t),
      orderBy: orderBy?.call(StoredPhoto.t),
      orderByList: orderByList?.call(StoredPhoto.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StoredPhoto] by its [id] or null if no such row exists.
  Future<StoredPhoto?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    StoredPhotoInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StoredPhoto>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StoredPhoto]s in the list and returns the inserted rows.
  ///
  /// The returned [StoredPhoto]s will have their `id` fields set.
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
  Future<List<StoredPhoto>> insert(
    _is.DatabaseSession session,
    List<StoredPhoto> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StoredPhoto>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StoredPhoto] and returns the inserted row.
  ///
  /// The returned [StoredPhoto] will have its `id` field set.
  Future<StoredPhoto> insertRow(
    _is.DatabaseSession session,
    StoredPhoto row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StoredPhoto>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StoredPhoto]s in the list and returns the resulting rows.
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
  /// The returned [StoredPhoto]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredPhoto>> upsert(
    _is.DatabaseSession session,
    List<StoredPhoto> rows, {
    required _is.ColumnSelections<StoredPhotoTable> conflictColumns,
    _is.ColumnSelections<StoredPhotoTable>? updateColumns,
    _is.WhereExpressionBuilder<StoredPhotoTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StoredPhoto>(
      rows,
      conflictColumns: conflictColumns(StoredPhoto.t),
      updateColumns: updateColumns?.call(StoredPhoto.t),
      updateWhere: updateWhere?.call(StoredPhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StoredPhoto] and returns the resulting row.
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
  /// The returned [StoredPhoto] will have its `id` field set.
  Future<StoredPhoto?> upsertRow(
    _is.DatabaseSession session,
    StoredPhoto row, {
    required _is.ColumnSelections<StoredPhotoTable> conflictColumns,
    _is.ColumnSelections<StoredPhotoTable>? updateColumns,
    _is.WhereExpressionBuilder<StoredPhotoTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StoredPhoto>(
      row,
      conflictColumns: conflictColumns(StoredPhoto.t),
      updateColumns: updateColumns?.call(StoredPhoto.t),
      updateWhere: updateWhere?.call(StoredPhoto.t),
      transaction: transaction,
    );
  }

  /// Updates all [StoredPhoto]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredPhoto>> update(
    _is.DatabaseSession session,
    List<StoredPhoto> rows, {
    _is.ColumnSelections<StoredPhotoTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StoredPhoto>(
      rows,
      columns: columns?.call(StoredPhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StoredPhoto]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StoredPhoto> updateRow(
    _is.DatabaseSession session,
    StoredPhoto row, {
    _is.ColumnSelections<StoredPhotoTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StoredPhoto>(
      row,
      columns: columns?.call(StoredPhoto.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StoredPhoto] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StoredPhoto?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<StoredPhotoUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StoredPhoto>(
      id,
      columnValues: columnValues(StoredPhoto.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StoredPhoto]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StoredPhoto>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StoredPhotoUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StoredPhotoTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StoredPhotoTable>? orderBy,
    _is.OrderByListBuilder<StoredPhotoTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StoredPhoto>(
      columnValues: columnValues(StoredPhoto.t.updateTable),
      where: where(StoredPhoto.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StoredPhoto.t),
      orderByList: orderByList?.call(StoredPhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StoredPhoto]s in the list and returns the deleted rows.
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
  Future<List<StoredPhoto>> delete(
    _is.DatabaseSession session,
    List<StoredPhoto> rows, {
    _is.OrderByBuilder<StoredPhotoTable>? orderBy,
    _is.OrderByListBuilder<StoredPhotoTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StoredPhoto>(
      rows,
      orderBy: orderBy?.call(StoredPhoto.t),
      orderByList: orderByList?.call(StoredPhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StoredPhoto].
  Future<StoredPhoto> deleteRow(
    _is.DatabaseSession session,
    StoredPhoto row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StoredPhoto>(
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
  Future<List<StoredPhoto>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StoredPhotoTable> where,
    _is.OrderByBuilder<StoredPhotoTable>? orderBy,
    _is.OrderByListBuilder<StoredPhotoTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StoredPhoto>(
      where: where(StoredPhoto.t),
      orderBy: orderBy?.call(StoredPhoto.t),
      orderByList: orderByList?.call(StoredPhoto.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StoredPhotoTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StoredPhoto>(
      where: where?.call(StoredPhoto.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StoredPhoto] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StoredPhotoTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StoredPhoto>(
      where: where(StoredPhoto.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class StoredPhotoAttachRowRepository {
  const StoredPhotoAttachRowRepository._();

  /// Creates a relation between the given [StoredPhoto] and [AuthUser]
  /// by setting the [StoredPhoto]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    StoredPhoto storedPhoto,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (storedPhoto.id == null) {
      throw ArgumentError.notNull('storedPhoto.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $storedPhoto = storedPhoto.copyWith(authUserId: authUser.id);
    await session.db.updateRow<StoredPhoto>(
      $storedPhoto,
      columns: [StoredPhoto.t.authUserId],
      transaction: transaction,
    );
  }
}
