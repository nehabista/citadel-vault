// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VaultsTable extends Vaults with TableInfo<$VaultsTable, Vault> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    sortOrder,
    createdAt,
    updatedAt,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaults';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vault> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vault map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vault(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
    );
  }

  @override
  $VaultsTable createAlias(String alias) {
    return $VaultsTable(attachedDatabase, alias);
  }
}

class Vault extends DataClass implements Insertable<Vault> {
  /// UUID primary key
  final String id;

  /// Encrypted vault name
  final String name;

  /// Encrypted description (optional)
  final String? description;

  /// Display sort order
  final int sortOrder;

  /// When the vault was created
  final DateTime createdAt;

  /// When the vault was last updated
  final DateTime updatedAt;

  /// PocketBase record ID for sync
  final String? remoteId;
  const Vault({
    required this.id,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  VaultsCompanion toCompanion(bool nullToAbsent) {
    return VaultsCompanion(
      id: Value(id),
      name: Value(name),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteId:
          remoteId == null && nullToAbsent
              ? const Value.absent()
              : Value(remoteId),
    );
  }

  factory Vault.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vault(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  Vault copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> remoteId = const Value.absent(),
  }) => Vault(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
  );
  Vault copyWithCompanion(VaultsCompanion data) {
    return Vault(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vault(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    sortOrder,
    createdAt,
    updatedAt,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vault &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId);
}

class VaultsCompanion extends UpdateCompanion<Vault> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> remoteId;
  final Value<int> rowid;
  const VaultsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Vault> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? remoteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? remoteId,
    Value<int>? rowid,
  }) {
    return VaultsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaultItemsTable extends VaultItems
    with TableInfo<$VaultItemsTable, VaultItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  @override
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vaults (id)',
    ),
  );
  static const VerificationMeta _encryptedDataMeta = const VerificationMeta(
    'encryptedData',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedData =
      GeneratedColumn<Uint8List>(
        'encrypted_data',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _encryptionVersionMeta = const VerificationMeta(
    'encryptionVersion',
  );
  @override
  late final GeneratedColumn<int> encryptionVersion = GeneratedColumn<int>(
    'encryption_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vaultId,
    encryptedData,
    encryptionVersion,
    createdAt,
    updatedAt,
    remoteId,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    if (data.containsKey('encrypted_data')) {
      context.handle(
        _encryptedDataMeta,
        encryptedData.isAcceptableOrUnknown(
          data['encrypted_data']!,
          _encryptedDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedDataMeta);
    }
    if (data.containsKey('encryption_version')) {
      context.handle(
        _encryptionVersionMeta,
        encryptionVersion.isAcceptableOrUnknown(
          data['encryption_version']!,
          _encryptionVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaultItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultItem(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      vaultId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vault_id'],
          )!,
      encryptedData:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}encrypted_data'],
          )!,
      encryptionVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}encryption_version'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      isDeleted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_deleted'],
          )!,
    );
  }

  @override
  $VaultItemsTable createAlias(String alias) {
    return $VaultItemsTable(attachedDatabase, alias);
  }
}

class VaultItem extends DataClass implements Insertable<VaultItem> {
  /// UUID primary key
  final String id;

  /// Foreign key to the parent vault
  final String vaultId;

  /// The AES-256-GCM encrypted JSON blob containing ALL fields:
  /// name, url, type, favorite, notes, username, password, custom fields
  final Uint8List encryptedData;

  /// Encryption format version: 1=v1 (PBKDF2+AES-CBC), 2=v2 (Argon2id+AES-256-GCM)
  final int encryptionVersion;

  /// When the item was created
  final DateTime createdAt;

  /// When the item was last updated
  final DateTime updatedAt;

  /// PocketBase record ID for sync
  final String? remoteId;

  /// Soft delete flag per D-17 tombstone strategy
  final bool isDeleted;
  const VaultItem({
    required this.id,
    required this.vaultId,
    required this.encryptedData,
    required this.encryptionVersion,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    map['encrypted_data'] = Variable<Uint8List>(encryptedData);
    map['encryption_version'] = Variable<int>(encryptionVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  VaultItemsCompanion toCompanion(bool nullToAbsent) {
    return VaultItemsCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
      encryptedData: Value(encryptedData),
      encryptionVersion: Value(encryptionVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteId:
          remoteId == null && nullToAbsent
              ? const Value.absent()
              : Value(remoteId),
      isDeleted: Value(isDeleted),
    );
  }

  factory VaultItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultItem(
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vaultId']),
      encryptedData: serializer.fromJson<Uint8List>(json['encryptedData']),
      encryptionVersion: serializer.fromJson<int>(json['encryptionVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vaultId': serializer.toJson<String>(vaultId),
      'encryptedData': serializer.toJson<Uint8List>(encryptedData),
      'encryptionVersion': serializer.toJson<int>(encryptionVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteId': serializer.toJson<String?>(remoteId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  VaultItem copyWith({
    String? id,
    String? vaultId,
    Uint8List? encryptedData,
    int? encryptionVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> remoteId = const Value.absent(),
    bool? isDeleted,
  }) => VaultItem(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    encryptedData: encryptedData ?? this.encryptedData,
    encryptionVersion: encryptionVersion ?? this.encryptionVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  VaultItem copyWithCompanion(VaultItemsCompanion data) {
    return VaultItem(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      encryptedData:
          data.encryptedData.present
              ? data.encryptedData.value
              : this.encryptedData,
      encryptionVersion:
          data.encryptionVersion.present
              ? data.encryptionVersion.value
              : this.encryptionVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultItem(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('encryptedData: $encryptedData, ')
          ..write('encryptionVersion: $encryptionVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vaultId,
    $driftBlobEquality.hash(encryptedData),
    encryptionVersion,
    createdAt,
    updatedAt,
    remoteId,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultItem &&
          other.id == this.id &&
          other.vaultId == this.vaultId &&
          $driftBlobEquality.equals(other.encryptedData, this.encryptedData) &&
          other.encryptionVersion == this.encryptionVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId &&
          other.isDeleted == this.isDeleted);
}

class VaultItemsCompanion extends UpdateCompanion<VaultItem> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<Uint8List> encryptedData;
  final Value<int> encryptionVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> remoteId;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const VaultItemsCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.encryptedData = const Value.absent(),
    this.encryptionVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultItemsCompanion.insert({
    required String id,
    required String vaultId,
    required Uint8List encryptedData,
    this.encryptionVersion = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.remoteId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vaultId = Value(vaultId),
       encryptedData = Value(encryptedData),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VaultItem> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<Uint8List>? encryptedData,
    Expression<int>? encryptionVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? remoteId,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
      if (encryptedData != null) 'encrypted_data': encryptedData,
      if (encryptionVersion != null) 'encryption_version': encryptionVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultId,
    Value<Uint8List>? encryptedData,
    Value<int>? encryptionVersion,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? remoteId,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return VaultItemsCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      encryptedData: encryptedData ?? this.encryptedData,
      encryptionVersion: encryptionVersion ?? this.encryptionVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
    }
    if (encryptedData.present) {
      map['encrypted_data'] = Variable<Uint8List>(encryptedData.value);
    }
    if (encryptionVersion.present) {
      map['encryption_version'] = Variable<int>(encryptionVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultItemsCompanion(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('encryptedData: $encryptedData, ')
          ..write('encryptionVersion: $encryptionVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    entityTable,
    operation,
    queuedAt,
    retryCount,
    lastError,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_queuedAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      itemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_id'],
          )!,
      entityTable:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_table'],
          )!,
      operation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}operation'],
          )!,
      queuedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}queued_at'],
          )!,
      retryCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}retry_count'],
          )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      completed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}completed'],
          )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  /// Auto-incrementing primary key
  final int id;

  /// ID of the item that changed
  final String itemId;

  /// Which table the item belongs to (vault_items, vaults, etc.)
  final String entityTable;

  /// Operation type: 'create', 'update', 'delete'
  final String operation;

  /// When the change was queued
  final DateTime queuedAt;

  /// Number of sync retry attempts
  final int retryCount;

  /// Last error message from sync attempt
  final String? lastError;

  /// Whether this queue entry has been synced
  final bool completed;
  const SyncQueueData({
    required this.id,
    required this.itemId,
    required this.entityTable,
    required this.operation,
    required this.queuedAt,
    required this.retryCount,
    this.lastError,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<String>(itemId);
    map['entity_table'] = Variable<String>(entityTable);
    map['operation'] = Variable<String>(operation);
    map['queued_at'] = Variable<DateTime>(queuedAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      itemId: Value(itemId),
      entityTable: Value(entityTable),
      operation: Value(operation),
      queuedAt: Value(queuedAt),
      retryCount: Value(retryCount),
      lastError:
          lastError == null && nullToAbsent
              ? const Value.absent()
              : Value(lastError),
      completed: Value(completed),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      operation: serializer.fromJson<String>(json['operation']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<String>(itemId),
      'entityTable': serializer.toJson<String>(entityTable),
      'operation': serializer.toJson<String>(operation),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? itemId,
    String? entityTable,
    String? operation,
    DateTime? queuedAt,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    bool? completed,
  }) => SyncQueueData(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    entityTable: entityTable ?? this.entityTable,
    operation: operation ?? this.operation,
    queuedAt: queuedAt ?? this.queuedAt,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    completed: completed ?? this.completed,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      entityTable:
          data.entityTable.present ? data.entityTable.value : this.entityTable,
      operation: data.operation.present ? data.operation.value : this.operation,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('entityTable: $entityTable, ')
          ..write('operation: $operation, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    entityTable,
    operation,
    queuedAt,
    retryCount,
    lastError,
    completed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.entityTable == this.entityTable &&
          other.operation == this.operation &&
          other.queuedAt == this.queuedAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.completed == this.completed);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> itemId;
  final Value<String> entityTable;
  final Value<String> operation;
  final Value<DateTime> queuedAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<bool> completed;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.operation = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.completed = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String itemId,
    required String entityTable,
    required String operation,
    required DateTime queuedAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.completed = const Value.absent(),
  }) : itemId = Value(itemId),
       entityTable = Value(entityTable),
       operation = Value(operation),
       queuedAt = Value(queuedAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? itemId,
    Expression<String>? entityTable,
    Expression<String>? operation,
    Expression<DateTime>? queuedAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<bool>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (entityTable != null) 'entity_table': entityTable,
      if (operation != null) 'operation': operation,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (completed != null) 'completed': completed,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? itemId,
    Value<String>? entityTable,
    Value<String>? operation,
    Value<DateTime>? queuedAt,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<bool>? completed,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      entityTable: entityTable ?? this.entityTable,
      operation: operation ?? this.operation,
      queuedAt: queuedAt ?? this.queuedAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      completed: completed ?? this.completed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('entityTable: $entityTable, ')
          ..write('operation: $operation, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }
}

class $TotpEntriesTable extends TotpEntries
    with TableInfo<$TotpEntriesTable, TotpEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TotpEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaultItemIdMeta = const VerificationMeta(
    'vaultItemId',
  );
  @override
  late final GeneratedColumn<String> vaultItemId = GeneratedColumn<String>(
    'vault_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vault_items (id)',
    ),
  );
  static const VerificationMeta _encryptedSecretMeta = const VerificationMeta(
    'encryptedSecret',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedSecret =
      GeneratedColumn<Uint8List>(
        'encrypted_secret',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _digitsMeta = const VerificationMeta('digits');
  @override
  late final GeneratedColumn<int> digits = GeneratedColumn<int>(
    'digits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(6),
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<int> period = GeneratedColumn<int>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _algorithmMeta = const VerificationMeta(
    'algorithm',
  );
  @override
  late final GeneratedColumn<String> algorithm = GeneratedColumn<String>(
    'algorithm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('SHA1'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vaultItemId,
    encryptedSecret,
    digits,
    period,
    algorithm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'totp_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TotpEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vault_item_id')) {
      context.handle(
        _vaultItemIdMeta,
        vaultItemId.isAcceptableOrUnknown(
          data['vault_item_id']!,
          _vaultItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaultItemIdMeta);
    }
    if (data.containsKey('encrypted_secret')) {
      context.handle(
        _encryptedSecretMeta,
        encryptedSecret.isAcceptableOrUnknown(
          data['encrypted_secret']!,
          _encryptedSecretMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedSecretMeta);
    }
    if (data.containsKey('digits')) {
      context.handle(
        _digitsMeta,
        digits.isAcceptableOrUnknown(data['digits']!, _digitsMeta),
      );
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('algorithm')) {
      context.handle(
        _algorithmMeta,
        algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TotpEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TotpEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      vaultItemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vault_item_id'],
          )!,
      encryptedSecret:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}encrypted_secret'],
          )!,
      digits:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}digits'],
          )!,
      period:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}period'],
          )!,
      algorithm:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}algorithm'],
          )!,
    );
  }

  @override
  $TotpEntriesTable createAlias(String alias) {
    return $TotpEntriesTable(attachedDatabase, alias);
  }
}

class TotpEntry extends DataClass implements Insertable<TotpEntry> {
  /// UUID primary key
  final String id;

  /// Foreign key to the parent vault item
  final String vaultItemId;

  /// TOTP secret encrypted with vault key
  final Uint8List encryptedSecret;

  /// Number of digits in the TOTP code (default 6)
  final int digits;

  /// Time period in seconds (default 30)
  final int period;

  /// Hash algorithm: SHA1, SHA256, SHA512
  final String algorithm;
  const TotpEntry({
    required this.id,
    required this.vaultItemId,
    required this.encryptedSecret,
    required this.digits,
    required this.period,
    required this.algorithm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_item_id'] = Variable<String>(vaultItemId);
    map['encrypted_secret'] = Variable<Uint8List>(encryptedSecret);
    map['digits'] = Variable<int>(digits);
    map['period'] = Variable<int>(period);
    map['algorithm'] = Variable<String>(algorithm);
    return map;
  }

  TotpEntriesCompanion toCompanion(bool nullToAbsent) {
    return TotpEntriesCompanion(
      id: Value(id),
      vaultItemId: Value(vaultItemId),
      encryptedSecret: Value(encryptedSecret),
      digits: Value(digits),
      period: Value(period),
      algorithm: Value(algorithm),
    );
  }

  factory TotpEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TotpEntry(
      id: serializer.fromJson<String>(json['id']),
      vaultItemId: serializer.fromJson<String>(json['vaultItemId']),
      encryptedSecret: serializer.fromJson<Uint8List>(json['encryptedSecret']),
      digits: serializer.fromJson<int>(json['digits']),
      period: serializer.fromJson<int>(json['period']),
      algorithm: serializer.fromJson<String>(json['algorithm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vaultItemId': serializer.toJson<String>(vaultItemId),
      'encryptedSecret': serializer.toJson<Uint8List>(encryptedSecret),
      'digits': serializer.toJson<int>(digits),
      'period': serializer.toJson<int>(period),
      'algorithm': serializer.toJson<String>(algorithm),
    };
  }

  TotpEntry copyWith({
    String? id,
    String? vaultItemId,
    Uint8List? encryptedSecret,
    int? digits,
    int? period,
    String? algorithm,
  }) => TotpEntry(
    id: id ?? this.id,
    vaultItemId: vaultItemId ?? this.vaultItemId,
    encryptedSecret: encryptedSecret ?? this.encryptedSecret,
    digits: digits ?? this.digits,
    period: period ?? this.period,
    algorithm: algorithm ?? this.algorithm,
  );
  TotpEntry copyWithCompanion(TotpEntriesCompanion data) {
    return TotpEntry(
      id: data.id.present ? data.id.value : this.id,
      vaultItemId:
          data.vaultItemId.present ? data.vaultItemId.value : this.vaultItemId,
      encryptedSecret:
          data.encryptedSecret.present
              ? data.encryptedSecret.value
              : this.encryptedSecret,
      digits: data.digits.present ? data.digits.value : this.digits,
      period: data.period.present ? data.period.value : this.period,
      algorithm: data.algorithm.present ? data.algorithm.value : this.algorithm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TotpEntry(')
          ..write('id: $id, ')
          ..write('vaultItemId: $vaultItemId, ')
          ..write('encryptedSecret: $encryptedSecret, ')
          ..write('digits: $digits, ')
          ..write('period: $period, ')
          ..write('algorithm: $algorithm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vaultItemId,
    $driftBlobEquality.hash(encryptedSecret),
    digits,
    period,
    algorithm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TotpEntry &&
          other.id == this.id &&
          other.vaultItemId == this.vaultItemId &&
          $driftBlobEquality.equals(
            other.encryptedSecret,
            this.encryptedSecret,
          ) &&
          other.digits == this.digits &&
          other.period == this.period &&
          other.algorithm == this.algorithm);
}

class TotpEntriesCompanion extends UpdateCompanion<TotpEntry> {
  final Value<String> id;
  final Value<String> vaultItemId;
  final Value<Uint8List> encryptedSecret;
  final Value<int> digits;
  final Value<int> period;
  final Value<String> algorithm;
  final Value<int> rowid;
  const TotpEntriesCompanion({
    this.id = const Value.absent(),
    this.vaultItemId = const Value.absent(),
    this.encryptedSecret = const Value.absent(),
    this.digits = const Value.absent(),
    this.period = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TotpEntriesCompanion.insert({
    required String id,
    required String vaultItemId,
    required Uint8List encryptedSecret,
    this.digits = const Value.absent(),
    this.period = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vaultItemId = Value(vaultItemId),
       encryptedSecret = Value(encryptedSecret);
  static Insertable<TotpEntry> custom({
    Expression<String>? id,
    Expression<String>? vaultItemId,
    Expression<Uint8List>? encryptedSecret,
    Expression<int>? digits,
    Expression<int>? period,
    Expression<String>? algorithm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultItemId != null) 'vault_item_id': vaultItemId,
      if (encryptedSecret != null) 'encrypted_secret': encryptedSecret,
      if (digits != null) 'digits': digits,
      if (period != null) 'period': period,
      if (algorithm != null) 'algorithm': algorithm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TotpEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultItemId,
    Value<Uint8List>? encryptedSecret,
    Value<int>? digits,
    Value<int>? period,
    Value<String>? algorithm,
    Value<int>? rowid,
  }) {
    return TotpEntriesCompanion(
      id: id ?? this.id,
      vaultItemId: vaultItemId ?? this.vaultItemId,
      encryptedSecret: encryptedSecret ?? this.encryptedSecret,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      algorithm: algorithm ?? this.algorithm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vaultItemId.present) {
      map['vault_item_id'] = Variable<String>(vaultItemId.value);
    }
    if (encryptedSecret.present) {
      map['encrypted_secret'] = Variable<Uint8List>(encryptedSecret.value);
    }
    if (digits.present) {
      map['digits'] = Variable<int>(digits.value);
    }
    if (period.present) {
      map['period'] = Variable<int>(period.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(algorithm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TotpEntriesCompanion(')
          ..write('id: $id, ')
          ..write('vaultItemId: $vaultItemId, ')
          ..write('encryptedSecret: $encryptedSecret, ')
          ..write('digits: $digits, ')
          ..write('period: $period, ')
          ..write('algorithm: $algorithm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PasswordHistoryTable extends PasswordHistory
    with TableInfo<$PasswordHistoryTable, PasswordHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PasswordHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vaultItemIdMeta = const VerificationMeta(
    'vaultItemId',
  );
  @override
  late final GeneratedColumn<String> vaultItemId = GeneratedColumn<String>(
    'vault_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vault_items (id)',
    ),
  );
  static const VerificationMeta _encryptedPasswordMeta = const VerificationMeta(
    'encryptedPassword',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedPassword =
      GeneratedColumn<Uint8List>(
        'encrypted_password',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vaultItemId,
    encryptedPassword,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'password_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PasswordHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vault_item_id')) {
      context.handle(
        _vaultItemIdMeta,
        vaultItemId.isAcceptableOrUnknown(
          data['vault_item_id']!,
          _vaultItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaultItemIdMeta);
    }
    if (data.containsKey('encrypted_password')) {
      context.handle(
        _encryptedPasswordMeta,
        encryptedPassword.isAcceptableOrUnknown(
          data['encrypted_password']!,
          _encryptedPasswordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPasswordMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PasswordHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PasswordHistoryData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      vaultItemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vault_item_id'],
          )!,
      encryptedPassword:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}encrypted_password'],
          )!,
      changedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}changed_at'],
          )!,
    );
  }

  @override
  $PasswordHistoryTable createAlias(String alias) {
    return $PasswordHistoryTable(attachedDatabase, alias);
  }
}

class PasswordHistoryData extends DataClass
    implements Insertable<PasswordHistoryData> {
  /// Auto-incrementing primary key
  final int id;

  /// Foreign key to the vault item
  final String vaultItemId;

  /// Previous password encrypted with vault key
  final Uint8List encryptedPassword;

  /// When the password was changed
  final DateTime changedAt;
  const PasswordHistoryData({
    required this.id,
    required this.vaultItemId,
    required this.encryptedPassword,
    required this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vault_item_id'] = Variable<String>(vaultItemId);
    map['encrypted_password'] = Variable<Uint8List>(encryptedPassword);
    map['changed_at'] = Variable<DateTime>(changedAt);
    return map;
  }

  PasswordHistoryCompanion toCompanion(bool nullToAbsent) {
    return PasswordHistoryCompanion(
      id: Value(id),
      vaultItemId: Value(vaultItemId),
      encryptedPassword: Value(encryptedPassword),
      changedAt: Value(changedAt),
    );
  }

  factory PasswordHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PasswordHistoryData(
      id: serializer.fromJson<int>(json['id']),
      vaultItemId: serializer.fromJson<String>(json['vaultItemId']),
      encryptedPassword: serializer.fromJson<Uint8List>(
        json['encryptedPassword'],
      ),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vaultItemId': serializer.toJson<String>(vaultItemId),
      'encryptedPassword': serializer.toJson<Uint8List>(encryptedPassword),
      'changedAt': serializer.toJson<DateTime>(changedAt),
    };
  }

  PasswordHistoryData copyWith({
    int? id,
    String? vaultItemId,
    Uint8List? encryptedPassword,
    DateTime? changedAt,
  }) => PasswordHistoryData(
    id: id ?? this.id,
    vaultItemId: vaultItemId ?? this.vaultItemId,
    encryptedPassword: encryptedPassword ?? this.encryptedPassword,
    changedAt: changedAt ?? this.changedAt,
  );
  PasswordHistoryData copyWithCompanion(PasswordHistoryCompanion data) {
    return PasswordHistoryData(
      id: data.id.present ? data.id.value : this.id,
      vaultItemId:
          data.vaultItemId.present ? data.vaultItemId.value : this.vaultItemId,
      encryptedPassword:
          data.encryptedPassword.present
              ? data.encryptedPassword.value
              : this.encryptedPassword,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PasswordHistoryData(')
          ..write('id: $id, ')
          ..write('vaultItemId: $vaultItemId, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vaultItemId,
    $driftBlobEquality.hash(encryptedPassword),
    changedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PasswordHistoryData &&
          other.id == this.id &&
          other.vaultItemId == this.vaultItemId &&
          $driftBlobEquality.equals(
            other.encryptedPassword,
            this.encryptedPassword,
          ) &&
          other.changedAt == this.changedAt);
}

class PasswordHistoryCompanion extends UpdateCompanion<PasswordHistoryData> {
  final Value<int> id;
  final Value<String> vaultItemId;
  final Value<Uint8List> encryptedPassword;
  final Value<DateTime> changedAt;
  const PasswordHistoryCompanion({
    this.id = const Value.absent(),
    this.vaultItemId = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.changedAt = const Value.absent(),
  });
  PasswordHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String vaultItemId,
    required Uint8List encryptedPassword,
    required DateTime changedAt,
  }) : vaultItemId = Value(vaultItemId),
       encryptedPassword = Value(encryptedPassword),
       changedAt = Value(changedAt);
  static Insertable<PasswordHistoryData> custom({
    Expression<int>? id,
    Expression<String>? vaultItemId,
    Expression<Uint8List>? encryptedPassword,
    Expression<DateTime>? changedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultItemId != null) 'vault_item_id': vaultItemId,
      if (encryptedPassword != null) 'encrypted_password': encryptedPassword,
      if (changedAt != null) 'changed_at': changedAt,
    });
  }

  PasswordHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? vaultItemId,
    Value<Uint8List>? encryptedPassword,
    Value<DateTime>? changedAt,
  }) {
    return PasswordHistoryCompanion(
      id: id ?? this.id,
      vaultItemId: vaultItemId ?? this.vaultItemId,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vaultItemId.present) {
      map['vault_item_id'] = Variable<String>(vaultItemId.value);
    }
    if (encryptedPassword.present) {
      map['encrypted_password'] = Variable<Uint8List>(encryptedPassword.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PasswordHistoryCompanion(')
          ..write('id: $id, ')
          ..write('vaultItemId: $vaultItemId, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }
}

class $AutofillIndexTable extends AutofillIndex
    with TableInfo<$AutofillIndexTable, AutofillIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AutofillIndexTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vaultItemIdMeta = const VerificationMeta(
    'vaultItemId',
  );
  @override
  late final GeneratedColumn<String> vaultItemId = GeneratedColumn<String>(
    'vault_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vault_items (id)',
    ),
  );
  static const VerificationMeta _domainHashMeta = const VerificationMeta(
    'domainHash',
  );
  @override
  late final GeneratedColumn<String> domainHash = GeneratedColumn<String>(
    'domain_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageHashMeta = const VerificationMeta(
    'packageHash',
  );
  @override
  late final GeneratedColumn<String> packageHash = GeneratedColumn<String>(
    'package_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vaultItemId,
    domainHash,
    packageHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'autofill_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<AutofillIndexData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vault_item_id')) {
      context.handle(
        _vaultItemIdMeta,
        vaultItemId.isAcceptableOrUnknown(
          data['vault_item_id']!,
          _vaultItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaultItemIdMeta);
    }
    if (data.containsKey('domain_hash')) {
      context.handle(
        _domainHashMeta,
        domainHash.isAcceptableOrUnknown(data['domain_hash']!, _domainHashMeta),
      );
    } else if (isInserting) {
      context.missing(_domainHashMeta);
    }
    if (data.containsKey('package_hash')) {
      context.handle(
        _packageHashMeta,
        packageHash.isAcceptableOrUnknown(
          data['package_hash']!,
          _packageHashMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AutofillIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AutofillIndexData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      vaultItemId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vault_item_id'],
          )!,
      domainHash:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}domain_hash'],
          )!,
      packageHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_hash'],
      ),
    );
  }

  @override
  $AutofillIndexTable createAlias(String alias) {
    return $AutofillIndexTable(attachedDatabase, alias);
  }
}

class AutofillIndexData extends DataClass
    implements Insertable<AutofillIndexData> {
  /// Auto-incrementing primary key
  final int id;

  /// Foreign key to the vault item
  final String vaultItemId;

  /// SHA-256 hash of the domain (not plaintext per D-11)
  final String domainHash;

  /// SHA-256 hash of Android package name (optional)
  final String? packageHash;
  const AutofillIndexData({
    required this.id,
    required this.vaultItemId,
    required this.domainHash,
    this.packageHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vault_item_id'] = Variable<String>(vaultItemId);
    map['domain_hash'] = Variable<String>(domainHash);
    if (!nullToAbsent || packageHash != null) {
      map['package_hash'] = Variable<String>(packageHash);
    }
    return map;
  }

  AutofillIndexCompanion toCompanion(bool nullToAbsent) {
    return AutofillIndexCompanion(
      id: Value(id),
      vaultItemId: Value(vaultItemId),
      domainHash: Value(domainHash),
      packageHash:
          packageHash == null && nullToAbsent
              ? const Value.absent()
              : Value(packageHash),
    );
  }

  factory AutofillIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AutofillIndexData(
      id: serializer.fromJson<int>(json['id']),
      vaultItemId: serializer.fromJson<String>(json['vaultItemId']),
      domainHash: serializer.fromJson<String>(json['domainHash']),
      packageHash: serializer.fromJson<String?>(json['packageHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vaultItemId': serializer.toJson<String>(vaultItemId),
      'domainHash': serializer.toJson<String>(domainHash),
      'packageHash': serializer.toJson<String?>(packageHash),
    };
  }

  AutofillIndexData copyWith({
    int? id,
    String? vaultItemId,
    String? domainHash,
    Value<String?> packageHash = const Value.absent(),
  }) => AutofillIndexData(
    id: id ?? this.id,
    vaultItemId: vaultItemId ?? this.vaultItemId,
    domainHash: domainHash ?? this.domainHash,
    packageHash: packageHash.present ? packageHash.value : this.packageHash,
  );
  AutofillIndexData copyWithCompanion(AutofillIndexCompanion data) {
    return AutofillIndexData(
      id: data.id.present ? data.id.value : this.id,
      vaultItemId:
          data.vaultItemId.present ? data.vaultItemId.value : this.vaultItemId,
      domainHash:
          data.domainHash.present ? data.domainHash.value : this.domainHash,
      packageHash:
          data.packageHash.present ? data.packageHash.value : this.packageHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AutofillIndexData(')
          ..write('id: $id, ')
          ..write('vaultItemId: $vaultItemId, ')
          ..write('domainHash: $domainHash, ')
          ..write('packageHash: $packageHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, vaultItemId, domainHash, packageHash);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AutofillIndexData &&
          other.id == this.id &&
          other.vaultItemId == this.vaultItemId &&
          other.domainHash == this.domainHash &&
          other.packageHash == this.packageHash);
}

class AutofillIndexCompanion extends UpdateCompanion<AutofillIndexData> {
  final Value<int> id;
  final Value<String> vaultItemId;
  final Value<String> domainHash;
  final Value<String?> packageHash;
  const AutofillIndexCompanion({
    this.id = const Value.absent(),
    this.vaultItemId = const Value.absent(),
    this.domainHash = const Value.absent(),
    this.packageHash = const Value.absent(),
  });
  AutofillIndexCompanion.insert({
    this.id = const Value.absent(),
    required String vaultItemId,
    required String domainHash,
    this.packageHash = const Value.absent(),
  }) : vaultItemId = Value(vaultItemId),
       domainHash = Value(domainHash);
  static Insertable<AutofillIndexData> custom({
    Expression<int>? id,
    Expression<String>? vaultItemId,
    Expression<String>? domainHash,
    Expression<String>? packageHash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultItemId != null) 'vault_item_id': vaultItemId,
      if (domainHash != null) 'domain_hash': domainHash,
      if (packageHash != null) 'package_hash': packageHash,
    });
  }

  AutofillIndexCompanion copyWith({
    Value<int>? id,
    Value<String>? vaultItemId,
    Value<String>? domainHash,
    Value<String?>? packageHash,
  }) {
    return AutofillIndexCompanion(
      id: id ?? this.id,
      vaultItemId: vaultItemId ?? this.vaultItemId,
      domainHash: domainHash ?? this.domainHash,
      packageHash: packageHash ?? this.packageHash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vaultItemId.present) {
      map['vault_item_id'] = Variable<String>(vaultItemId.value);
    }
    if (domainHash.present) {
      map['domain_hash'] = Variable<String>(domainHash.value);
    }
    if (packageHash.present) {
      map['package_hash'] = Variable<String>(packageHash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AutofillIndexCompanion(')
          ..write('id: $id, ')
          ..write('vaultItemId: $vaultItemId, ')
          ..write('domainHash: $domainHash, ')
          ..write('packageHash: $packageHash')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  /// Setting key (primary key)
  final String key;

  /// Setting value
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VaultsTable vaults = $VaultsTable(this);
  late final $VaultItemsTable vaultItems = $VaultItemsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $TotpEntriesTable totpEntries = $TotpEntriesTable(this);
  late final $PasswordHistoryTable passwordHistory = $PasswordHistoryTable(
    this,
  );
  late final $AutofillIndexTable autofillIndex = $AutofillIndexTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final VaultDao vaultDao = VaultDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vaults,
    vaultItems,
    syncQueue,
    totpEntries,
    passwordHistory,
    autofillIndex,
    settings,
  ];
}

typedef $$VaultsTableCreateCompanionBuilder =
    VaultsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> remoteId,
      Value<int> rowid,
    });
typedef $$VaultsTableUpdateCompanionBuilder =
    VaultsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> remoteId,
      Value<int> rowid,
    });

final class $$VaultsTableReferences
    extends BaseReferences<_$AppDatabase, $VaultsTable, Vault> {
  $$VaultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VaultItemsTable, List<VaultItem>>
  _vaultItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vaultItems,
    aliasName: $_aliasNameGenerator(db.vaults.id, db.vaultItems.vaultId),
  );

  $$VaultItemsTableProcessedTableManager get vaultItemsRefs {
    final manager = $$VaultItemsTableTableManager(
      $_db,
      $_db.vaultItems,
    ).filter((f) => f.vaultId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vaultItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VaultsTableFilterComposer
    extends Composer<_$AppDatabase, $VaultsTable> {
  $$VaultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> vaultItemsRefs(
    Expression<bool> Function($$VaultItemsTableFilterComposer f) f,
  ) {
    final $$VaultItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.vaultId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableFilterComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VaultsTableOrderingComposer
    extends Composer<_$AppDatabase, $VaultsTable> {
  $$VaultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaultsTable> {
  $$VaultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  Expression<T> vaultItemsRefs<T extends Object>(
    Expression<T> Function($$VaultItemsTableAnnotationComposer a) f,
  ) {
    final $$VaultItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.vaultId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VaultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaultsTable,
          Vault,
          $$VaultsTableFilterComposer,
          $$VaultsTableOrderingComposer,
          $$VaultsTableAnnotationComposer,
          $$VaultsTableCreateCompanionBuilder,
          $$VaultsTableUpdateCompanionBuilder,
          (Vault, $$VaultsTableReferences),
          Vault,
          PrefetchHooks Function({bool vaultItemsRefs})
        > {
  $$VaultsTableTableManager(_$AppDatabase db, $VaultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$VaultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$VaultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$VaultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultsCompanion(
                id: id,
                name: name,
                description: description,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> remoteId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultsCompanion.insert(
                id: id,
                name: name,
                description: description,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$VaultsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({vaultItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (vaultItemsRefs) db.vaultItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vaultItemsRefs)
                    await $_getPrefetchedData<Vault, $VaultsTable, VaultItem>(
                      currentTable: table,
                      referencedTable: $$VaultsTableReferences
                          ._vaultItemsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$VaultsTableReferences(
                                db,
                                table,
                                p0,
                              ).vaultItemsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.vaultId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VaultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaultsTable,
      Vault,
      $$VaultsTableFilterComposer,
      $$VaultsTableOrderingComposer,
      $$VaultsTableAnnotationComposer,
      $$VaultsTableCreateCompanionBuilder,
      $$VaultsTableUpdateCompanionBuilder,
      (Vault, $$VaultsTableReferences),
      Vault,
      PrefetchHooks Function({bool vaultItemsRefs})
    >;
typedef $$VaultItemsTableCreateCompanionBuilder =
    VaultItemsCompanion Function({
      required String id,
      required String vaultId,
      required Uint8List encryptedData,
      Value<int> encryptionVersion,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> remoteId,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$VaultItemsTableUpdateCompanionBuilder =
    VaultItemsCompanion Function({
      Value<String> id,
      Value<String> vaultId,
      Value<Uint8List> encryptedData,
      Value<int> encryptionVersion,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> remoteId,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$VaultItemsTableReferences
    extends BaseReferences<_$AppDatabase, $VaultItemsTable, VaultItem> {
  $$VaultItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VaultsTable _vaultIdTable(_$AppDatabase db) => db.vaults.createAlias(
    $_aliasNameGenerator(db.vaultItems.vaultId, db.vaults.id),
  );

  $$VaultsTableProcessedTableManager get vaultId {
    final $_column = $_itemColumn<String>('vault_id')!;

    final manager = $$VaultsTableTableManager(
      $_db,
      $_db.vaults,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TotpEntriesTable, List<TotpEntry>>
  _totpEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.totpEntries,
    aliasName: $_aliasNameGenerator(
      db.vaultItems.id,
      db.totpEntries.vaultItemId,
    ),
  );

  $$TotpEntriesTableProcessedTableManager get totpEntriesRefs {
    final manager = $$TotpEntriesTableTableManager(
      $_db,
      $_db.totpEntries,
    ).filter((f) => f.vaultItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_totpEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PasswordHistoryTable, List<PasswordHistoryData>>
  _passwordHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.passwordHistory,
    aliasName: $_aliasNameGenerator(
      db.vaultItems.id,
      db.passwordHistory.vaultItemId,
    ),
  );

  $$PasswordHistoryTableProcessedTableManager get passwordHistoryRefs {
    final manager = $$PasswordHistoryTableTableManager(
      $_db,
      $_db.passwordHistory,
    ).filter((f) => f.vaultItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _passwordHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AutofillIndexTable, List<AutofillIndexData>>
  _autofillIndexRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.autofillIndex,
    aliasName: $_aliasNameGenerator(
      db.vaultItems.id,
      db.autofillIndex.vaultItemId,
    ),
  );

  $$AutofillIndexTableProcessedTableManager get autofillIndexRefs {
    final manager = $$AutofillIndexTableTableManager(
      $_db,
      $_db.autofillIndex,
    ).filter((f) => f.vaultItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_autofillIndexRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VaultItemsTableFilterComposer
    extends Composer<_$AppDatabase, $VaultItemsTable> {
  $$VaultItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedData => $composableBuilder(
    column: $table.encryptedData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get encryptionVersion => $composableBuilder(
    column: $table.encryptionVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$VaultsTableFilterComposer get vaultId {
    final $$VaultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultsTableFilterComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> totpEntriesRefs(
    Expression<bool> Function($$TotpEntriesTableFilterComposer f) f,
  ) {
    final $$TotpEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.totpEntries,
      getReferencedColumn: (t) => t.vaultItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TotpEntriesTableFilterComposer(
            $db: $db,
            $table: $db.totpEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> passwordHistoryRefs(
    Expression<bool> Function($$PasswordHistoryTableFilterComposer f) f,
  ) {
    final $$PasswordHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.passwordHistory,
      getReferencedColumn: (t) => t.vaultItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PasswordHistoryTableFilterComposer(
            $db: $db,
            $table: $db.passwordHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> autofillIndexRefs(
    Expression<bool> Function($$AutofillIndexTableFilterComposer f) f,
  ) {
    final $$AutofillIndexTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.autofillIndex,
      getReferencedColumn: (t) => t.vaultItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AutofillIndexTableFilterComposer(
            $db: $db,
            $table: $db.autofillIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VaultItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $VaultItemsTable> {
  $$VaultItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedData => $composableBuilder(
    column: $table.encryptedData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get encryptionVersion => $composableBuilder(
    column: $table.encryptionVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$VaultsTableOrderingComposer get vaultId {
    final $$VaultsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultsTableOrderingComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VaultItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaultItemsTable> {
  $$VaultItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get encryptedData => $composableBuilder(
    column: $table.encryptedData,
    builder: (column) => column,
  );

  GeneratedColumn<int> get encryptionVersion => $composableBuilder(
    column: $table.encryptionVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$VaultsTableAnnotationComposer get vaultId {
    final $$VaultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultId,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultsTableAnnotationComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> totpEntriesRefs<T extends Object>(
    Expression<T> Function($$TotpEntriesTableAnnotationComposer a) f,
  ) {
    final $$TotpEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.totpEntries,
      getReferencedColumn: (t) => t.vaultItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TotpEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.totpEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> passwordHistoryRefs<T extends Object>(
    Expression<T> Function($$PasswordHistoryTableAnnotationComposer a) f,
  ) {
    final $$PasswordHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.passwordHistory,
      getReferencedColumn: (t) => t.vaultItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PasswordHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.passwordHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> autofillIndexRefs<T extends Object>(
    Expression<T> Function($$AutofillIndexTableAnnotationComposer a) f,
  ) {
    final $$AutofillIndexTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.autofillIndex,
      getReferencedColumn: (t) => t.vaultItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AutofillIndexTableAnnotationComposer(
            $db: $db,
            $table: $db.autofillIndex,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VaultItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaultItemsTable,
          VaultItem,
          $$VaultItemsTableFilterComposer,
          $$VaultItemsTableOrderingComposer,
          $$VaultItemsTableAnnotationComposer,
          $$VaultItemsTableCreateCompanionBuilder,
          $$VaultItemsTableUpdateCompanionBuilder,
          (VaultItem, $$VaultItemsTableReferences),
          VaultItem,
          PrefetchHooks Function({
            bool vaultId,
            bool totpEntriesRefs,
            bool passwordHistoryRefs,
            bool autofillIndexRefs,
          })
        > {
  $$VaultItemsTableTableManager(_$AppDatabase db, $VaultItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$VaultItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$VaultItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$VaultItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vaultId = const Value.absent(),
                Value<Uint8List> encryptedData = const Value.absent(),
                Value<int> encryptionVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultItemsCompanion(
                id: id,
                vaultId: vaultId,
                encryptedData: encryptedData,
                encryptionVersion: encryptionVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vaultId,
                required Uint8List encryptedData,
                Value<int> encryptionVersion = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> remoteId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultItemsCompanion.insert(
                id: id,
                vaultId: vaultId,
                encryptedData: encryptedData,
                encryptionVersion: encryptionVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$VaultItemsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            vaultId = false,
            totpEntriesRefs = false,
            passwordHistoryRefs = false,
            autofillIndexRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (totpEntriesRefs) db.totpEntries,
                if (passwordHistoryRefs) db.passwordHistory,
                if (autofillIndexRefs) db.autofillIndex,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (vaultId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.vaultId,
                            referencedTable: $$VaultItemsTableReferences
                                ._vaultIdTable(db),
                            referencedColumn:
                                $$VaultItemsTableReferences
                                    ._vaultIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (totpEntriesRefs)
                    await $_getPrefetchedData<
                      VaultItem,
                      $VaultItemsTable,
                      TotpEntry
                    >(
                      currentTable: table,
                      referencedTable: $$VaultItemsTableReferences
                          ._totpEntriesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$VaultItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).totpEntriesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.vaultItemId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (passwordHistoryRefs)
                    await $_getPrefetchedData<
                      VaultItem,
                      $VaultItemsTable,
                      PasswordHistoryData
                    >(
                      currentTable: table,
                      referencedTable: $$VaultItemsTableReferences
                          ._passwordHistoryRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$VaultItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).passwordHistoryRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.vaultItemId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (autofillIndexRefs)
                    await $_getPrefetchedData<
                      VaultItem,
                      $VaultItemsTable,
                      AutofillIndexData
                    >(
                      currentTable: table,
                      referencedTable: $$VaultItemsTableReferences
                          ._autofillIndexRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$VaultItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).autofillIndexRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.vaultItemId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VaultItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaultItemsTable,
      VaultItem,
      $$VaultItemsTableFilterComposer,
      $$VaultItemsTableOrderingComposer,
      $$VaultItemsTableAnnotationComposer,
      $$VaultItemsTableCreateCompanionBuilder,
      $$VaultItemsTableUpdateCompanionBuilder,
      (VaultItem, $$VaultItemsTableReferences),
      VaultItem,
      PrefetchHooks Function({
        bool vaultId,
        bool totpEntriesRefs,
        bool passwordHistoryRefs,
        bool autofillIndexRefs,
      })
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String itemId,
      required String entityTable,
      required String operation,
      required DateTime queuedAt,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<bool> completed,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> itemId,
      Value<String> entityTable,
      Value<String> operation,
      Value<DateTime> queuedAt,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<bool> completed,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<DateTime> queuedAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                itemId: itemId,
                entityTable: entityTable,
                operation: operation,
                queuedAt: queuedAt,
                retryCount: retryCount,
                lastError: lastError,
                completed: completed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String itemId,
                required String entityTable,
                required String operation,
                required DateTime queuedAt,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                itemId: itemId,
                entityTable: entityTable,
                operation: operation,
                queuedAt: queuedAt,
                retryCount: retryCount,
                lastError: lastError,
                completed: completed,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$TotpEntriesTableCreateCompanionBuilder =
    TotpEntriesCompanion Function({
      required String id,
      required String vaultItemId,
      required Uint8List encryptedSecret,
      Value<int> digits,
      Value<int> period,
      Value<String> algorithm,
      Value<int> rowid,
    });
typedef $$TotpEntriesTableUpdateCompanionBuilder =
    TotpEntriesCompanion Function({
      Value<String> id,
      Value<String> vaultItemId,
      Value<Uint8List> encryptedSecret,
      Value<int> digits,
      Value<int> period,
      Value<String> algorithm,
      Value<int> rowid,
    });

final class $$TotpEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $TotpEntriesTable, TotpEntry> {
  $$TotpEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VaultItemsTable _vaultItemIdTable(_$AppDatabase db) =>
      db.vaultItems.createAlias(
        $_aliasNameGenerator(db.totpEntries.vaultItemId, db.vaultItems.id),
      );

  $$VaultItemsTableProcessedTableManager get vaultItemId {
    final $_column = $_itemColumn<String>('vault_item_id')!;

    final manager = $$VaultItemsTableTableManager(
      $_db,
      $_db.vaultItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TotpEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TotpEntriesTable> {
  $$TotpEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedSecret => $composableBuilder(
    column: $table.encryptedSecret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get digits => $composableBuilder(
    column: $table.digits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnFilters(column),
  );

  $$VaultItemsTableFilterComposer get vaultItemId {
    final $$VaultItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultItemId,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableFilterComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TotpEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TotpEntriesTable> {
  $$TotpEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedSecret => $composableBuilder(
    column: $table.encryptedSecret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get digits => $composableBuilder(
    column: $table.digits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
    builder: (column) => ColumnOrderings(column),
  );

  $$VaultItemsTableOrderingComposer get vaultItemId {
    final $$VaultItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultItemId,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableOrderingComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TotpEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TotpEntriesTable> {
  $$TotpEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get encryptedSecret => $composableBuilder(
    column: $table.encryptedSecret,
    builder: (column) => column,
  );

  GeneratedColumn<int> get digits =>
      $composableBuilder(column: $table.digits, builder: (column) => column);

  GeneratedColumn<int> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

  $$VaultItemsTableAnnotationComposer get vaultItemId {
    final $$VaultItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultItemId,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TotpEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TotpEntriesTable,
          TotpEntry,
          $$TotpEntriesTableFilterComposer,
          $$TotpEntriesTableOrderingComposer,
          $$TotpEntriesTableAnnotationComposer,
          $$TotpEntriesTableCreateCompanionBuilder,
          $$TotpEntriesTableUpdateCompanionBuilder,
          (TotpEntry, $$TotpEntriesTableReferences),
          TotpEntry,
          PrefetchHooks Function({bool vaultItemId})
        > {
  $$TotpEntriesTableTableManager(_$AppDatabase db, $TotpEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TotpEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TotpEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$TotpEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vaultItemId = const Value.absent(),
                Value<Uint8List> encryptedSecret = const Value.absent(),
                Value<int> digits = const Value.absent(),
                Value<int> period = const Value.absent(),
                Value<String> algorithm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TotpEntriesCompanion(
                id: id,
                vaultItemId: vaultItemId,
                encryptedSecret: encryptedSecret,
                digits: digits,
                period: period,
                algorithm: algorithm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vaultItemId,
                required Uint8List encryptedSecret,
                Value<int> digits = const Value.absent(),
                Value<int> period = const Value.absent(),
                Value<String> algorithm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TotpEntriesCompanion.insert(
                id: id,
                vaultItemId: vaultItemId,
                encryptedSecret: encryptedSecret,
                digits: digits,
                period: period,
                algorithm: algorithm,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TotpEntriesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({vaultItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (vaultItemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.vaultItemId,
                            referencedTable: $$TotpEntriesTableReferences
                                ._vaultItemIdTable(db),
                            referencedColumn:
                                $$TotpEntriesTableReferences
                                    ._vaultItemIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TotpEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TotpEntriesTable,
      TotpEntry,
      $$TotpEntriesTableFilterComposer,
      $$TotpEntriesTableOrderingComposer,
      $$TotpEntriesTableAnnotationComposer,
      $$TotpEntriesTableCreateCompanionBuilder,
      $$TotpEntriesTableUpdateCompanionBuilder,
      (TotpEntry, $$TotpEntriesTableReferences),
      TotpEntry,
      PrefetchHooks Function({bool vaultItemId})
    >;
typedef $$PasswordHistoryTableCreateCompanionBuilder =
    PasswordHistoryCompanion Function({
      Value<int> id,
      required String vaultItemId,
      required Uint8List encryptedPassword,
      required DateTime changedAt,
    });
typedef $$PasswordHistoryTableUpdateCompanionBuilder =
    PasswordHistoryCompanion Function({
      Value<int> id,
      Value<String> vaultItemId,
      Value<Uint8List> encryptedPassword,
      Value<DateTime> changedAt,
    });

final class $$PasswordHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PasswordHistoryTable,
          PasswordHistoryData
        > {
  $$PasswordHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VaultItemsTable _vaultItemIdTable(_$AppDatabase db) =>
      db.vaultItems.createAlias(
        $_aliasNameGenerator(db.passwordHistory.vaultItemId, db.vaultItems.id),
      );

  $$VaultItemsTableProcessedTableManager get vaultItemId {
    final $_column = $_itemColumn<String>('vault_item_id')!;

    final manager = $$VaultItemsTableTableManager(
      $_db,
      $_db.vaultItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PasswordHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PasswordHistoryTable> {
  $$PasswordHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VaultItemsTableFilterComposer get vaultItemId {
    final $$VaultItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultItemId,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableFilterComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PasswordHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PasswordHistoryTable> {
  $$PasswordHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VaultItemsTableOrderingComposer get vaultItemId {
    final $$VaultItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultItemId,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableOrderingComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PasswordHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PasswordHistoryTable> {
  $$PasswordHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  $$VaultItemsTableAnnotationComposer get vaultItemId {
    final $$VaultItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultItemId,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PasswordHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PasswordHistoryTable,
          PasswordHistoryData,
          $$PasswordHistoryTableFilterComposer,
          $$PasswordHistoryTableOrderingComposer,
          $$PasswordHistoryTableAnnotationComposer,
          $$PasswordHistoryTableCreateCompanionBuilder,
          $$PasswordHistoryTableUpdateCompanionBuilder,
          (PasswordHistoryData, $$PasswordHistoryTableReferences),
          PasswordHistoryData,
          PrefetchHooks Function({bool vaultItemId})
        > {
  $$PasswordHistoryTableTableManager(
    _$AppDatabase db,
    $PasswordHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$PasswordHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PasswordHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$PasswordHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> vaultItemId = const Value.absent(),
                Value<Uint8List> encryptedPassword = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
              }) => PasswordHistoryCompanion(
                id: id,
                vaultItemId: vaultItemId,
                encryptedPassword: encryptedPassword,
                changedAt: changedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vaultItemId,
                required Uint8List encryptedPassword,
                required DateTime changedAt,
              }) => PasswordHistoryCompanion.insert(
                id: id,
                vaultItemId: vaultItemId,
                encryptedPassword: encryptedPassword,
                changedAt: changedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PasswordHistoryTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({vaultItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (vaultItemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.vaultItemId,
                            referencedTable: $$PasswordHistoryTableReferences
                                ._vaultItemIdTable(db),
                            referencedColumn:
                                $$PasswordHistoryTableReferences
                                    ._vaultItemIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PasswordHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PasswordHistoryTable,
      PasswordHistoryData,
      $$PasswordHistoryTableFilterComposer,
      $$PasswordHistoryTableOrderingComposer,
      $$PasswordHistoryTableAnnotationComposer,
      $$PasswordHistoryTableCreateCompanionBuilder,
      $$PasswordHistoryTableUpdateCompanionBuilder,
      (PasswordHistoryData, $$PasswordHistoryTableReferences),
      PasswordHistoryData,
      PrefetchHooks Function({bool vaultItemId})
    >;
typedef $$AutofillIndexTableCreateCompanionBuilder =
    AutofillIndexCompanion Function({
      Value<int> id,
      required String vaultItemId,
      required String domainHash,
      Value<String?> packageHash,
    });
typedef $$AutofillIndexTableUpdateCompanionBuilder =
    AutofillIndexCompanion Function({
      Value<int> id,
      Value<String> vaultItemId,
      Value<String> domainHash,
      Value<String?> packageHash,
    });

final class $$AutofillIndexTableReferences
    extends
        BaseReferences<_$AppDatabase, $AutofillIndexTable, AutofillIndexData> {
  $$AutofillIndexTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VaultItemsTable _vaultItemIdTable(_$AppDatabase db) =>
      db.vaultItems.createAlias(
        $_aliasNameGenerator(db.autofillIndex.vaultItemId, db.vaultItems.id),
      );

  $$VaultItemsTableProcessedTableManager get vaultItemId {
    final $_column = $_itemColumn<String>('vault_item_id')!;

    final manager = $$VaultItemsTableTableManager(
      $_db,
      $_db.vaultItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AutofillIndexTableFilterComposer
    extends Composer<_$AppDatabase, $AutofillIndexTable> {
  $$AutofillIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainHash => $composableBuilder(
    column: $table.domainHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageHash => $composableBuilder(
    column: $table.packageHash,
    builder: (column) => ColumnFilters(column),
  );

  $$VaultItemsTableFilterComposer get vaultItemId {
    final $$VaultItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultItemId,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableFilterComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AutofillIndexTableOrderingComposer
    extends Composer<_$AppDatabase, $AutofillIndexTable> {
  $$AutofillIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainHash => $composableBuilder(
    column: $table.domainHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageHash => $composableBuilder(
    column: $table.packageHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$VaultItemsTableOrderingComposer get vaultItemId {
    final $$VaultItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultItemId,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableOrderingComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AutofillIndexTableAnnotationComposer
    extends Composer<_$AppDatabase, $AutofillIndexTable> {
  $$AutofillIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get domainHash => $composableBuilder(
    column: $table.domainHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageHash => $composableBuilder(
    column: $table.packageHash,
    builder: (column) => column,
  );

  $$VaultItemsTableAnnotationComposer get vaultItemId {
    final $$VaultItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultItemId,
      referencedTable: $db.vaultItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.vaultItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AutofillIndexTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AutofillIndexTable,
          AutofillIndexData,
          $$AutofillIndexTableFilterComposer,
          $$AutofillIndexTableOrderingComposer,
          $$AutofillIndexTableAnnotationComposer,
          $$AutofillIndexTableCreateCompanionBuilder,
          $$AutofillIndexTableUpdateCompanionBuilder,
          (AutofillIndexData, $$AutofillIndexTableReferences),
          AutofillIndexData,
          PrefetchHooks Function({bool vaultItemId})
        > {
  $$AutofillIndexTableTableManager(_$AppDatabase db, $AutofillIndexTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AutofillIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$AutofillIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AutofillIndexTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> vaultItemId = const Value.absent(),
                Value<String> domainHash = const Value.absent(),
                Value<String?> packageHash = const Value.absent(),
              }) => AutofillIndexCompanion(
                id: id,
                vaultItemId: vaultItemId,
                domainHash: domainHash,
                packageHash: packageHash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vaultItemId,
                required String domainHash,
                Value<String?> packageHash = const Value.absent(),
              }) => AutofillIndexCompanion.insert(
                id: id,
                vaultItemId: vaultItemId,
                domainHash: domainHash,
                packageHash: packageHash,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AutofillIndexTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({vaultItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (vaultItemId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.vaultItemId,
                            referencedTable: $$AutofillIndexTableReferences
                                ._vaultItemIdTable(db),
                            referencedColumn:
                                $$AutofillIndexTableReferences
                                    ._vaultItemIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AutofillIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AutofillIndexTable,
      AutofillIndexData,
      $$AutofillIndexTableFilterComposer,
      $$AutofillIndexTableOrderingComposer,
      $$AutofillIndexTableAnnotationComposer,
      $$AutofillIndexTableCreateCompanionBuilder,
      $$AutofillIndexTableUpdateCompanionBuilder,
      (AutofillIndexData, $$AutofillIndexTableReferences),
      AutofillIndexData,
      PrefetchHooks Function({bool vaultItemId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VaultsTableTableManager get vaults =>
      $$VaultsTableTableManager(_db, _db.vaults);
  $$VaultItemsTableTableManager get vaultItems =>
      $$VaultItemsTableTableManager(_db, _db.vaultItems);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$TotpEntriesTableTableManager get totpEntries =>
      $$TotpEntriesTableTableManager(_db, _db.totpEntries);
  $$PasswordHistoryTableTableManager get passwordHistory =>
      $$PasswordHistoryTableTableManager(_db, _db.passwordHistory);
  $$AutofillIndexTableTableManager get autofillIndex =>
      $$AutofillIndexTableTableManager(_db, _db.autofillIndex);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
