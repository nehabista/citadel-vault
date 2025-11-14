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
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#4D4DCD'),
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('shield'),
  );
  static const VerificationMeta _isTravelSafeMeta = const VerificationMeta(
    'isTravelSafe',
  );
  @override
  late final GeneratedColumn<bool> isTravelSafe = GeneratedColumn<bool>(
    'is_travel_safe',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_travel_safe" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isHiddenByTravelMeta = const VerificationMeta(
    'isHiddenByTravel',
  );
  @override
  late final GeneratedColumn<bool> isHiddenByTravel = GeneratedColumn<bool>(
    'is_hidden_by_travel',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden_by_travel" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    colorHex,
    iconName,
    isTravelSafe,
    isHiddenByTravel,
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
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('is_travel_safe')) {
      context.handle(
        _isTravelSafeMeta,
        isTravelSafe.isAcceptableOrUnknown(
          data['is_travel_safe']!,
          _isTravelSafeMeta,
        ),
      );
    }
    if (data.containsKey('is_hidden_by_travel')) {
      context.handle(
        _isHiddenByTravelMeta,
        isHiddenByTravel.isAcceptableOrUnknown(
          data['is_hidden_by_travel']!,
          _isHiddenByTravelMeta,
        ),
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
      colorHex:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}color_hex'],
          )!,
      iconName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}icon_name'],
          )!,
      isTravelSafe:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_travel_safe'],
          )!,
      isHiddenByTravel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_hidden_by_travel'],
          )!,
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

  /// Hex color code for vault display (default: brand purple)
  final String colorHex;

  /// Icon name for vault display (default: shield)
  final String iconName;

  /// Whether this vault is visible in travel mode. Default: true (visible).
  /// Per D-01: stored encrypted in metadata blob as source of truth.
  /// This plaintext column is a mirror for query filtering per D-04.
  final bool isTravelSafe;

  /// Whether this vault is currently hidden by an active travel mode session.
  /// When true, the vault is soft-hidden from normal queries but NOT deleted.
  /// Flipped back to false when travel mode is deactivated.
  final bool isHiddenByTravel;
  const Vault({
    required this.id,
    required this.name,
    this.description,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    required this.colorHex,
    required this.iconName,
    required this.isTravelSafe,
    required this.isHiddenByTravel,
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
    map['color_hex'] = Variable<String>(colorHex);
    map['icon_name'] = Variable<String>(iconName);
    map['is_travel_safe'] = Variable<bool>(isTravelSafe);
    map['is_hidden_by_travel'] = Variable<bool>(isHiddenByTravel);
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
      colorHex: Value(colorHex),
      iconName: Value(iconName),
      isTravelSafe: Value(isTravelSafe),
      isHiddenByTravel: Value(isHiddenByTravel),
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
      colorHex: serializer.fromJson<String>(json['colorHex']),
      iconName: serializer.fromJson<String>(json['iconName']),
      isTravelSafe: serializer.fromJson<bool>(json['isTravelSafe']),
      isHiddenByTravel: serializer.fromJson<bool>(json['isHiddenByTravel']),
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
      'colorHex': serializer.toJson<String>(colorHex),
      'iconName': serializer.toJson<String>(iconName),
      'isTravelSafe': serializer.toJson<bool>(isTravelSafe),
      'isHiddenByTravel': serializer.toJson<bool>(isHiddenByTravel),
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
    String? colorHex,
    String? iconName,
    bool? isTravelSafe,
    bool? isHiddenByTravel,
  }) => Vault(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    colorHex: colorHex ?? this.colorHex,
    iconName: iconName ?? this.iconName,
    isTravelSafe: isTravelSafe ?? this.isTravelSafe,
    isHiddenByTravel: isHiddenByTravel ?? this.isHiddenByTravel,
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
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      isTravelSafe:
          data.isTravelSafe.present
              ? data.isTravelSafe.value
              : this.isTravelSafe,
      isHiddenByTravel:
          data.isHiddenByTravel.present
              ? data.isHiddenByTravel.value
              : this.isHiddenByTravel,
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
          ..write('remoteId: $remoteId, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconName: $iconName, ')
          ..write('isTravelSafe: $isTravelSafe, ')
          ..write('isHiddenByTravel: $isHiddenByTravel')
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
    colorHex,
    iconName,
    isTravelSafe,
    isHiddenByTravel,
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
          other.remoteId == this.remoteId &&
          other.colorHex == this.colorHex &&
          other.iconName == this.iconName &&
          other.isTravelSafe == this.isTravelSafe &&
          other.isHiddenByTravel == this.isHiddenByTravel);
}

class VaultsCompanion extends UpdateCompanion<Vault> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> remoteId;
  final Value<String> colorHex;
  final Value<String> iconName;
  final Value<bool> isTravelSafe;
  final Value<bool> isHiddenByTravel;
  final Value<int> rowid;
  const VaultsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.iconName = const Value.absent(),
    this.isTravelSafe = const Value.absent(),
    this.isHiddenByTravel = const Value.absent(),
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
    this.colorHex = const Value.absent(),
    this.iconName = const Value.absent(),
    this.isTravelSafe = const Value.absent(),
    this.isHiddenByTravel = const Value.absent(),
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
    Expression<String>? colorHex,
    Expression<String>? iconName,
    Expression<bool>? isTravelSafe,
    Expression<bool>? isHiddenByTravel,
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
      if (colorHex != null) 'color_hex': colorHex,
      if (iconName != null) 'icon_name': iconName,
      if (isTravelSafe != null) 'is_travel_safe': isTravelSafe,
      if (isHiddenByTravel != null) 'is_hidden_by_travel': isHiddenByTravel,
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
    Value<String>? colorHex,
    Value<String>? iconName,
    Value<bool>? isTravelSafe,
    Value<bool>? isHiddenByTravel,
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
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      isTravelSafe: isTravelSafe ?? this.isTravelSafe,
      isHiddenByTravel: isHiddenByTravel ?? this.isHiddenByTravel,
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
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (isTravelSafe.present) {
      map['is_travel_safe'] = Variable<bool>(isTravelSafe.value);
    }
    if (isHiddenByTravel.present) {
      map['is_hidden_by_travel'] = Variable<bool>(isHiddenByTravel.value);
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
          ..write('colorHex: $colorHex, ')
          ..write('iconName: $iconName, ')
          ..write('isTravelSafe: $isTravelSafe, ')
          ..write('isHiddenByTravel: $isHiddenByTravel, ')
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

class $SharedItemsTable extends SharedItems
    with TableInfo<$SharedItemsTable, SharedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SharedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipientIdMeta = const VerificationMeta(
    'recipientId',
  );
  @override
  late final GeneratedColumn<String> recipientId = GeneratedColumn<String>(
    'recipient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedDataMeta = const VerificationMeta(
    'encryptedData',
  );
  @override
  late final GeneratedColumn<String> encryptedData = GeneratedColumn<String>(
    'encrypted_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderPublicKeyMeta = const VerificationMeta(
    'senderPublicKey',
  );
  @override
  late final GeneratedColumn<String> senderPublicKey = GeneratedColumn<String>(
    'sender_public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    senderId,
    recipientId,
    encryptedData,
    senderPublicKey,
    createdAt,
    expiresAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shared_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SharedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('recipient_id')) {
      context.handle(
        _recipientIdMeta,
        recipientId.isAcceptableOrUnknown(
          data['recipient_id']!,
          _recipientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recipientIdMeta);
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
    if (data.containsKey('sender_public_key')) {
      context.handle(
        _senderPublicKeyMeta,
        senderPublicKey.isAcceptableOrUnknown(
          data['sender_public_key']!,
          _senderPublicKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderPublicKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SharedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SharedItem(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      senderId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sender_id'],
          )!,
      recipientId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}recipient_id'],
          )!,
      encryptedData:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}encrypted_data'],
          )!,
      senderPublicKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sender_public_key'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
    );
  }

  @override
  $SharedItemsTable createAlias(String alias) {
    return $SharedItemsTable(attachedDatabase, alias);
  }
}

class SharedItem extends DataClass implements Insertable<SharedItem> {
  /// PocketBase record ID
  final String id;

  /// ID of the user who shared the item
  final String senderId;

  /// ID of the user receiving the shared item
  final String recipientId;

  /// Base64-encoded AES-256-GCM encrypted item data
  final String encryptedData;

  /// Base64-encoded X25519 public key of the sender
  final String senderPublicKey;

  /// When the share was created
  final DateTime createdAt;

  /// Optional expiration time
  final DateTime? expiresAt;

  /// Share status: pending, accepted, declined
  final String status;
  const SharedItem({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.encryptedData,
    required this.senderPublicKey,
    required this.createdAt,
    this.expiresAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sender_id'] = Variable<String>(senderId);
    map['recipient_id'] = Variable<String>(recipientId);
    map['encrypted_data'] = Variable<String>(encryptedData);
    map['sender_public_key'] = Variable<String>(senderPublicKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  SharedItemsCompanion toCompanion(bool nullToAbsent) {
    return SharedItemsCompanion(
      id: Value(id),
      senderId: Value(senderId),
      recipientId: Value(recipientId),
      encryptedData: Value(encryptedData),
      senderPublicKey: Value(senderPublicKey),
      createdAt: Value(createdAt),
      expiresAt:
          expiresAt == null && nullToAbsent
              ? const Value.absent()
              : Value(expiresAt),
      status: Value(status),
    );
  }

  factory SharedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SharedItem(
      id: serializer.fromJson<String>(json['id']),
      senderId: serializer.fromJson<String>(json['senderId']),
      recipientId: serializer.fromJson<String>(json['recipientId']),
      encryptedData: serializer.fromJson<String>(json['encryptedData']),
      senderPublicKey: serializer.fromJson<String>(json['senderPublicKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'senderId': serializer.toJson<String>(senderId),
      'recipientId': serializer.toJson<String>(recipientId),
      'encryptedData': serializer.toJson<String>(encryptedData),
      'senderPublicKey': serializer.toJson<String>(senderPublicKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'status': serializer.toJson<String>(status),
    };
  }

  SharedItem copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? encryptedData,
    String? senderPublicKey,
    DateTime? createdAt,
    Value<DateTime?> expiresAt = const Value.absent(),
    String? status,
  }) => SharedItem(
    id: id ?? this.id,
    senderId: senderId ?? this.senderId,
    recipientId: recipientId ?? this.recipientId,
    encryptedData: encryptedData ?? this.encryptedData,
    senderPublicKey: senderPublicKey ?? this.senderPublicKey,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    status: status ?? this.status,
  );
  SharedItem copyWithCompanion(SharedItemsCompanion data) {
    return SharedItem(
      id: data.id.present ? data.id.value : this.id,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      recipientId:
          data.recipientId.present ? data.recipientId.value : this.recipientId,
      encryptedData:
          data.encryptedData.present
              ? data.encryptedData.value
              : this.encryptedData,
      senderPublicKey:
          data.senderPublicKey.present
              ? data.senderPublicKey.value
              : this.senderPublicKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SharedItem(')
          ..write('id: $id, ')
          ..write('senderId: $senderId, ')
          ..write('recipientId: $recipientId, ')
          ..write('encryptedData: $encryptedData, ')
          ..write('senderPublicKey: $senderPublicKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    senderId,
    recipientId,
    encryptedData,
    senderPublicKey,
    createdAt,
    expiresAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SharedItem &&
          other.id == this.id &&
          other.senderId == this.senderId &&
          other.recipientId == this.recipientId &&
          other.encryptedData == this.encryptedData &&
          other.senderPublicKey == this.senderPublicKey &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt &&
          other.status == this.status);
}

class SharedItemsCompanion extends UpdateCompanion<SharedItem> {
  final Value<String> id;
  final Value<String> senderId;
  final Value<String> recipientId;
  final Value<String> encryptedData;
  final Value<String> senderPublicKey;
  final Value<DateTime> createdAt;
  final Value<DateTime?> expiresAt;
  final Value<String> status;
  final Value<int> rowid;
  const SharedItemsCompanion({
    this.id = const Value.absent(),
    this.senderId = const Value.absent(),
    this.recipientId = const Value.absent(),
    this.encryptedData = const Value.absent(),
    this.senderPublicKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SharedItemsCompanion.insert({
    required String id,
    required String senderId,
    required String recipientId,
    required String encryptedData,
    required String senderPublicKey,
    required DateTime createdAt,
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       senderId = Value(senderId),
       recipientId = Value(recipientId),
       encryptedData = Value(encryptedData),
       senderPublicKey = Value(senderPublicKey),
       createdAt = Value(createdAt);
  static Insertable<SharedItem> custom({
    Expression<String>? id,
    Expression<String>? senderId,
    Expression<String>? recipientId,
    Expression<String>? encryptedData,
    Expression<String>? senderPublicKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (senderId != null) 'sender_id': senderId,
      if (recipientId != null) 'recipient_id': recipientId,
      if (encryptedData != null) 'encrypted_data': encryptedData,
      if (senderPublicKey != null) 'sender_public_key': senderPublicKey,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SharedItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? senderId,
    Value<String>? recipientId,
    Value<String>? encryptedData,
    Value<String>? senderPublicKey,
    Value<DateTime>? createdAt,
    Value<DateTime?>? expiresAt,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return SharedItemsCompanion(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      encryptedData: encryptedData ?? this.encryptedData,
      senderPublicKey: senderPublicKey ?? this.senderPublicKey,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (recipientId.present) {
      map['recipient_id'] = Variable<String>(recipientId.value);
    }
    if (encryptedData.present) {
      map['encrypted_data'] = Variable<String>(encryptedData.value);
    }
    if (senderPublicKey.present) {
      map['sender_public_key'] = Variable<String>(senderPublicKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SharedItemsCompanion(')
          ..write('id: $id, ')
          ..write('senderId: $senderId, ')
          ..write('recipientId: $recipientId, ')
          ..write('encryptedData: $encryptedData, ')
          ..write('senderPublicKey: $senderPublicKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaultMembersTable extends VaultMembers
    with TableInfo<$VaultMembersTable, VaultMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultMembersTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('viewer'),
  );
  static const VerificationMeta _encryptedVaultKeyMeta = const VerificationMeta(
    'encryptedVaultKey',
  );
  @override
  late final GeneratedColumn<String> encryptedVaultKey =
      GeneratedColumn<String>(
        'encrypted_vault_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ownerPublicKeyMeta = const VerificationMeta(
    'ownerPublicKey',
  );
  @override
  late final GeneratedColumn<String> ownerPublicKey = GeneratedColumn<String>(
    'owner_public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invitedAtMeta = const VerificationMeta(
    'invitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> invitedAt = GeneratedColumn<DateTime>(
    'invited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acceptedAtMeta = const VerificationMeta(
    'acceptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acceptedAt = GeneratedColumn<DateTime>(
    'accepted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vaultId,
    userId,
    role,
    encryptedVaultKey,
    ownerPublicKey,
    invitedAt,
    acceptedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaultMember> instance, {
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
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('encrypted_vault_key')) {
      context.handle(
        _encryptedVaultKeyMeta,
        encryptedVaultKey.isAcceptableOrUnknown(
          data['encrypted_vault_key']!,
          _encryptedVaultKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedVaultKeyMeta);
    }
    if (data.containsKey('owner_public_key')) {
      context.handle(
        _ownerPublicKeyMeta,
        ownerPublicKey.isAcceptableOrUnknown(
          data['owner_public_key']!,
          _ownerPublicKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerPublicKeyMeta);
    }
    if (data.containsKey('invited_at')) {
      context.handle(
        _invitedAtMeta,
        invitedAt.isAcceptableOrUnknown(data['invited_at']!, _invitedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_invitedAtMeta);
    }
    if (data.containsKey('accepted_at')) {
      context.handle(
        _acceptedAtMeta,
        acceptedAt.isAcceptableOrUnknown(data['accepted_at']!, _acceptedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaultMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaultMember(
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
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      role:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}role'],
          )!,
      encryptedVaultKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}encrypted_vault_key'],
          )!,
      ownerPublicKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_public_key'],
          )!,
      invitedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}invited_at'],
          )!,
      acceptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}accepted_at'],
      ),
    );
  }

  @override
  $VaultMembersTable createAlias(String alias) {
    return $VaultMembersTable(attachedDatabase, alias);
  }
}

class VaultMember extends DataClass implements Insertable<VaultMember> {
  /// PocketBase record ID
  final String id;

  /// ID of the shared vault
  final String vaultId;

  /// ID of the member user
  final String userId;

  /// Role in the vault: owner, editor, viewer
  final String role;

  /// Base64-encoded vault key encrypted with X25519 shared secret
  final String encryptedVaultKey;

  /// Base64-encoded X25519 public key of the vault owner
  final String ownerPublicKey;

  /// When the invitation was sent
  final DateTime invitedAt;

  /// When the member accepted (null if pending)
  final DateTime? acceptedAt;
  const VaultMember({
    required this.id,
    required this.vaultId,
    required this.userId,
    required this.role,
    required this.encryptedVaultKey,
    required this.ownerPublicKey,
    required this.invitedAt,
    this.acceptedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    map['encrypted_vault_key'] = Variable<String>(encryptedVaultKey);
    map['owner_public_key'] = Variable<String>(ownerPublicKey);
    map['invited_at'] = Variable<DateTime>(invitedAt);
    if (!nullToAbsent || acceptedAt != null) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt);
    }
    return map;
  }

  VaultMembersCompanion toCompanion(bool nullToAbsent) {
    return VaultMembersCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
      userId: Value(userId),
      role: Value(role),
      encryptedVaultKey: Value(encryptedVaultKey),
      ownerPublicKey: Value(ownerPublicKey),
      invitedAt: Value(invitedAt),
      acceptedAt:
          acceptedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(acceptedAt),
    );
  }

  factory VaultMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaultMember(
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vaultId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      encryptedVaultKey: serializer.fromJson<String>(json['encryptedVaultKey']),
      ownerPublicKey: serializer.fromJson<String>(json['ownerPublicKey']),
      invitedAt: serializer.fromJson<DateTime>(json['invitedAt']),
      acceptedAt: serializer.fromJson<DateTime?>(json['acceptedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vaultId': serializer.toJson<String>(vaultId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'encryptedVaultKey': serializer.toJson<String>(encryptedVaultKey),
      'ownerPublicKey': serializer.toJson<String>(ownerPublicKey),
      'invitedAt': serializer.toJson<DateTime>(invitedAt),
      'acceptedAt': serializer.toJson<DateTime?>(acceptedAt),
    };
  }

  VaultMember copyWith({
    String? id,
    String? vaultId,
    String? userId,
    String? role,
    String? encryptedVaultKey,
    String? ownerPublicKey,
    DateTime? invitedAt,
    Value<DateTime?> acceptedAt = const Value.absent(),
  }) => VaultMember(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    encryptedVaultKey: encryptedVaultKey ?? this.encryptedVaultKey,
    ownerPublicKey: ownerPublicKey ?? this.ownerPublicKey,
    invitedAt: invitedAt ?? this.invitedAt,
    acceptedAt: acceptedAt.present ? acceptedAt.value : this.acceptedAt,
  );
  VaultMember copyWithCompanion(VaultMembersCompanion data) {
    return VaultMember(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      encryptedVaultKey:
          data.encryptedVaultKey.present
              ? data.encryptedVaultKey.value
              : this.encryptedVaultKey,
      ownerPublicKey:
          data.ownerPublicKey.present
              ? data.ownerPublicKey.value
              : this.ownerPublicKey,
      invitedAt: data.invitedAt.present ? data.invitedAt.value : this.invitedAt,
      acceptedAt:
          data.acceptedAt.present ? data.acceptedAt.value : this.acceptedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaultMember(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('encryptedVaultKey: $encryptedVaultKey, ')
          ..write('ownerPublicKey: $ownerPublicKey, ')
          ..write('invitedAt: $invitedAt, ')
          ..write('acceptedAt: $acceptedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vaultId,
    userId,
    role,
    encryptedVaultKey,
    ownerPublicKey,
    invitedAt,
    acceptedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaultMember &&
          other.id == this.id &&
          other.vaultId == this.vaultId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.encryptedVaultKey == this.encryptedVaultKey &&
          other.ownerPublicKey == this.ownerPublicKey &&
          other.invitedAt == this.invitedAt &&
          other.acceptedAt == this.acceptedAt);
}

class VaultMembersCompanion extends UpdateCompanion<VaultMember> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<String> userId;
  final Value<String> role;
  final Value<String> encryptedVaultKey;
  final Value<String> ownerPublicKey;
  final Value<DateTime> invitedAt;
  final Value<DateTime?> acceptedAt;
  final Value<int> rowid;
  const VaultMembersCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.encryptedVaultKey = const Value.absent(),
    this.ownerPublicKey = const Value.absent(),
    this.invitedAt = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultMembersCompanion.insert({
    required String id,
    required String vaultId,
    required String userId,
    this.role = const Value.absent(),
    required String encryptedVaultKey,
    required String ownerPublicKey,
    required DateTime invitedAt,
    this.acceptedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vaultId = Value(vaultId),
       userId = Value(userId),
       encryptedVaultKey = Value(encryptedVaultKey),
       ownerPublicKey = Value(ownerPublicKey),
       invitedAt = Value(invitedAt);
  static Insertable<VaultMember> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<String>? encryptedVaultKey,
    Expression<String>? ownerPublicKey,
    Expression<DateTime>? invitedAt,
    Expression<DateTime>? acceptedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (encryptedVaultKey != null) 'encrypted_vault_key': encryptedVaultKey,
      if (ownerPublicKey != null) 'owner_public_key': ownerPublicKey,
      if (invitedAt != null) 'invited_at': invitedAt,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultId,
    Value<String>? userId,
    Value<String>? role,
    Value<String>? encryptedVaultKey,
    Value<String>? ownerPublicKey,
    Value<DateTime>? invitedAt,
    Value<DateTime?>? acceptedAt,
    Value<int>? rowid,
  }) {
    return VaultMembersCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      encryptedVaultKey: encryptedVaultKey ?? this.encryptedVaultKey,
      ownerPublicKey: ownerPublicKey ?? this.ownerPublicKey,
      invitedAt: invitedAt ?? this.invitedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (encryptedVaultKey.present) {
      map['encrypted_vault_key'] = Variable<String>(encryptedVaultKey.value);
    }
    if (ownerPublicKey.present) {
      map['owner_public_key'] = Variable<String>(ownerPublicKey.value);
    }
    if (invitedAt.present) {
      map['invited_at'] = Variable<DateTime>(invitedAt.value);
    }
    if (acceptedAt.present) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaultMembersCompanion(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('encryptedVaultKey: $encryptedVaultKey, ')
          ..write('ownerPublicKey: $ownerPublicKey, ')
          ..write('invitedAt: $invitedAt, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmergencyContactsTable extends EmergencyContacts
    with TableInfo<$EmergencyContactsTable, EmergencyContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmergencyContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grantorIdMeta = const VerificationMeta(
    'grantorId',
  );
  @override
  late final GeneratedColumn<String> grantorId = GeneratedColumn<String>(
    'grantor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _granteeIdMeta = const VerificationMeta(
    'granteeId',
  );
  @override
  late final GeneratedColumn<String> granteeId = GeneratedColumn<String>(
    'grantee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waitingPeriodDaysMeta = const VerificationMeta(
    'waitingPeriodDays',
  );
  @override
  late final GeneratedColumn<int> waitingPeriodDays = GeneratedColumn<int>(
    'waiting_period_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _encryptedVaultKeyMeta = const VerificationMeta(
    'encryptedVaultKey',
  );
  @override
  late final GeneratedColumn<String> encryptedVaultKey =
      GeneratedColumn<String>(
        'encrypted_vault_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _granteePublicKeyMeta = const VerificationMeta(
    'granteePublicKey',
  );
  @override
  late final GeneratedColumn<String> granteePublicKey = GeneratedColumn<String>(
    'grantee_public_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedAtMeta = const VerificationMeta(
    'requestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> requestedAt = GeneratedColumn<DateTime>(
    'requested_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    grantorId,
    granteeId,
    waitingPeriodDays,
    status,
    encryptedVaultKey,
    granteePublicKey,
    requestedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emergency_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmergencyContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('grantor_id')) {
      context.handle(
        _grantorIdMeta,
        grantorId.isAcceptableOrUnknown(data['grantor_id']!, _grantorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_grantorIdMeta);
    }
    if (data.containsKey('grantee_id')) {
      context.handle(
        _granteeIdMeta,
        granteeId.isAcceptableOrUnknown(data['grantee_id']!, _granteeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_granteeIdMeta);
    }
    if (data.containsKey('waiting_period_days')) {
      context.handle(
        _waitingPeriodDaysMeta,
        waitingPeriodDays.isAcceptableOrUnknown(
          data['waiting_period_days']!,
          _waitingPeriodDaysMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('encrypted_vault_key')) {
      context.handle(
        _encryptedVaultKeyMeta,
        encryptedVaultKey.isAcceptableOrUnknown(
          data['encrypted_vault_key']!,
          _encryptedVaultKeyMeta,
        ),
      );
    }
    if (data.containsKey('grantee_public_key')) {
      context.handle(
        _granteePublicKeyMeta,
        granteePublicKey.isAcceptableOrUnknown(
          data['grantee_public_key']!,
          _granteePublicKeyMeta,
        ),
      );
    }
    if (data.containsKey('requested_at')) {
      context.handle(
        _requestedAtMeta,
        requestedAt.isAcceptableOrUnknown(
          data['requested_at']!,
          _requestedAtMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmergencyContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmergencyContact(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      grantorId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}grantor_id'],
          )!,
      granteeId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}grantee_id'],
          )!,
      waitingPeriodDays:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}waiting_period_days'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      encryptedVaultKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_vault_key'],
      ),
      granteePublicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grantee_public_key'],
      ),
      requestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}requested_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $EmergencyContactsTable createAlias(String alias) {
    return $EmergencyContactsTable(attachedDatabase, alias);
  }
}

class EmergencyContact extends DataClass
    implements Insertable<EmergencyContact> {
  /// PocketBase record ID
  final String id;

  /// ID of the user granting emergency access
  final String grantorId;

  /// ID of the trusted person who can request access
  final String granteeId;

  /// Days the grantor has to reject before access is granted (1-30)
  final int waitingPeriodDays;

  /// Status: pending, active, waiting, rejected, revoked
  final String status;

  /// Base64-encoded vault key (only populated after waiting period elapses)
  final String? encryptedVaultKey;

  /// Base64-encoded X25519 public key of the grantee
  final String? granteePublicKey;

  /// When the grantee requested emergency access
  final DateTime? requestedAt;

  /// When the emergency contact relationship was created
  final DateTime createdAt;
  const EmergencyContact({
    required this.id,
    required this.grantorId,
    required this.granteeId,
    required this.waitingPeriodDays,
    required this.status,
    this.encryptedVaultKey,
    this.granteePublicKey,
    this.requestedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['grantor_id'] = Variable<String>(grantorId);
    map['grantee_id'] = Variable<String>(granteeId);
    map['waiting_period_days'] = Variable<int>(waitingPeriodDays);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || encryptedVaultKey != null) {
      map['encrypted_vault_key'] = Variable<String>(encryptedVaultKey);
    }
    if (!nullToAbsent || granteePublicKey != null) {
      map['grantee_public_key'] = Variable<String>(granteePublicKey);
    }
    if (!nullToAbsent || requestedAt != null) {
      map['requested_at'] = Variable<DateTime>(requestedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EmergencyContactsCompanion toCompanion(bool nullToAbsent) {
    return EmergencyContactsCompanion(
      id: Value(id),
      grantorId: Value(grantorId),
      granteeId: Value(granteeId),
      waitingPeriodDays: Value(waitingPeriodDays),
      status: Value(status),
      encryptedVaultKey:
          encryptedVaultKey == null && nullToAbsent
              ? const Value.absent()
              : Value(encryptedVaultKey),
      granteePublicKey:
          granteePublicKey == null && nullToAbsent
              ? const Value.absent()
              : Value(granteePublicKey),
      requestedAt:
          requestedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(requestedAt),
      createdAt: Value(createdAt),
    );
  }

  factory EmergencyContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmergencyContact(
      id: serializer.fromJson<String>(json['id']),
      grantorId: serializer.fromJson<String>(json['grantorId']),
      granteeId: serializer.fromJson<String>(json['granteeId']),
      waitingPeriodDays: serializer.fromJson<int>(json['waitingPeriodDays']),
      status: serializer.fromJson<String>(json['status']),
      encryptedVaultKey: serializer.fromJson<String?>(
        json['encryptedVaultKey'],
      ),
      granteePublicKey: serializer.fromJson<String?>(json['granteePublicKey']),
      requestedAt: serializer.fromJson<DateTime?>(json['requestedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'grantorId': serializer.toJson<String>(grantorId),
      'granteeId': serializer.toJson<String>(granteeId),
      'waitingPeriodDays': serializer.toJson<int>(waitingPeriodDays),
      'status': serializer.toJson<String>(status),
      'encryptedVaultKey': serializer.toJson<String?>(encryptedVaultKey),
      'granteePublicKey': serializer.toJson<String?>(granteePublicKey),
      'requestedAt': serializer.toJson<DateTime?>(requestedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? grantorId,
    String? granteeId,
    int? waitingPeriodDays,
    String? status,
    Value<String?> encryptedVaultKey = const Value.absent(),
    Value<String?> granteePublicKey = const Value.absent(),
    Value<DateTime?> requestedAt = const Value.absent(),
    DateTime? createdAt,
  }) => EmergencyContact(
    id: id ?? this.id,
    grantorId: grantorId ?? this.grantorId,
    granteeId: granteeId ?? this.granteeId,
    waitingPeriodDays: waitingPeriodDays ?? this.waitingPeriodDays,
    status: status ?? this.status,
    encryptedVaultKey:
        encryptedVaultKey.present
            ? encryptedVaultKey.value
            : this.encryptedVaultKey,
    granteePublicKey:
        granteePublicKey.present
            ? granteePublicKey.value
            : this.granteePublicKey,
    requestedAt: requestedAt.present ? requestedAt.value : this.requestedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  EmergencyContact copyWithCompanion(EmergencyContactsCompanion data) {
    return EmergencyContact(
      id: data.id.present ? data.id.value : this.id,
      grantorId: data.grantorId.present ? data.grantorId.value : this.grantorId,
      granteeId: data.granteeId.present ? data.granteeId.value : this.granteeId,
      waitingPeriodDays:
          data.waitingPeriodDays.present
              ? data.waitingPeriodDays.value
              : this.waitingPeriodDays,
      status: data.status.present ? data.status.value : this.status,
      encryptedVaultKey:
          data.encryptedVaultKey.present
              ? data.encryptedVaultKey.value
              : this.encryptedVaultKey,
      granteePublicKey:
          data.granteePublicKey.present
              ? data.granteePublicKey.value
              : this.granteePublicKey,
      requestedAt:
          data.requestedAt.present ? data.requestedAt.value : this.requestedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyContact(')
          ..write('id: $id, ')
          ..write('grantorId: $grantorId, ')
          ..write('granteeId: $granteeId, ')
          ..write('waitingPeriodDays: $waitingPeriodDays, ')
          ..write('status: $status, ')
          ..write('encryptedVaultKey: $encryptedVaultKey, ')
          ..write('granteePublicKey: $granteePublicKey, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    grantorId,
    granteeId,
    waitingPeriodDays,
    status,
    encryptedVaultKey,
    granteePublicKey,
    requestedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmergencyContact &&
          other.id == this.id &&
          other.grantorId == this.grantorId &&
          other.granteeId == this.granteeId &&
          other.waitingPeriodDays == this.waitingPeriodDays &&
          other.status == this.status &&
          other.encryptedVaultKey == this.encryptedVaultKey &&
          other.granteePublicKey == this.granteePublicKey &&
          other.requestedAt == this.requestedAt &&
          other.createdAt == this.createdAt);
}

class EmergencyContactsCompanion extends UpdateCompanion<EmergencyContact> {
  final Value<String> id;
  final Value<String> grantorId;
  final Value<String> granteeId;
  final Value<int> waitingPeriodDays;
  final Value<String> status;
  final Value<String?> encryptedVaultKey;
  final Value<String?> granteePublicKey;
  final Value<DateTime?> requestedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EmergencyContactsCompanion({
    this.id = const Value.absent(),
    this.grantorId = const Value.absent(),
    this.granteeId = const Value.absent(),
    this.waitingPeriodDays = const Value.absent(),
    this.status = const Value.absent(),
    this.encryptedVaultKey = const Value.absent(),
    this.granteePublicKey = const Value.absent(),
    this.requestedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmergencyContactsCompanion.insert({
    required String id,
    required String grantorId,
    required String granteeId,
    this.waitingPeriodDays = const Value.absent(),
    this.status = const Value.absent(),
    this.encryptedVaultKey = const Value.absent(),
    this.granteePublicKey = const Value.absent(),
    this.requestedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       grantorId = Value(grantorId),
       granteeId = Value(granteeId),
       createdAt = Value(createdAt);
  static Insertable<EmergencyContact> custom({
    Expression<String>? id,
    Expression<String>? grantorId,
    Expression<String>? granteeId,
    Expression<int>? waitingPeriodDays,
    Expression<String>? status,
    Expression<String>? encryptedVaultKey,
    Expression<String>? granteePublicKey,
    Expression<DateTime>? requestedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (grantorId != null) 'grantor_id': grantorId,
      if (granteeId != null) 'grantee_id': granteeId,
      if (waitingPeriodDays != null) 'waiting_period_days': waitingPeriodDays,
      if (status != null) 'status': status,
      if (encryptedVaultKey != null) 'encrypted_vault_key': encryptedVaultKey,
      if (granteePublicKey != null) 'grantee_public_key': granteePublicKey,
      if (requestedAt != null) 'requested_at': requestedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmergencyContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? grantorId,
    Value<String>? granteeId,
    Value<int>? waitingPeriodDays,
    Value<String>? status,
    Value<String?>? encryptedVaultKey,
    Value<String?>? granteePublicKey,
    Value<DateTime?>? requestedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EmergencyContactsCompanion(
      id: id ?? this.id,
      grantorId: grantorId ?? this.grantorId,
      granteeId: granteeId ?? this.granteeId,
      waitingPeriodDays: waitingPeriodDays ?? this.waitingPeriodDays,
      status: status ?? this.status,
      encryptedVaultKey: encryptedVaultKey ?? this.encryptedVaultKey,
      granteePublicKey: granteePublicKey ?? this.granteePublicKey,
      requestedAt: requestedAt ?? this.requestedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (grantorId.present) {
      map['grantor_id'] = Variable<String>(grantorId.value);
    }
    if (granteeId.present) {
      map['grantee_id'] = Variable<String>(granteeId.value);
    }
    if (waitingPeriodDays.present) {
      map['waiting_period_days'] = Variable<int>(waitingPeriodDays.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (encryptedVaultKey.present) {
      map['encrypted_vault_key'] = Variable<String>(encryptedVaultKey.value);
    }
    if (granteePublicKey.present) {
      map['grantee_public_key'] = Variable<String>(granteePublicKey.value);
    }
    if (requestedAt.present) {
      map['requested_at'] = Variable<DateTime>(requestedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyContactsCompanion(')
          ..write('id: $id, ')
          ..write('grantorId: $grantorId, ')
          ..write('granteeId: $granteeId, ')
          ..write('waitingPeriodDays: $waitingPeriodDays, ')
          ..write('status: $status, ')
          ..write('encryptedVaultKey: $encryptedVaultKey, ')
          ..write('granteePublicKey: $granteePublicKey, ')
          ..write('requestedAt: $requestedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationRecordsTable extends NotificationRecords
    with TableInfo<$NotificationRecordsTable, NotificationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    body,
    referenceId,
    read,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRecord(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      body:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}body'],
          )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      read:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}read'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $NotificationRecordsTable createAlias(String alias) {
    return $NotificationRecordsTable(attachedDatabase, alias);
  }
}

class NotificationRecord extends DataClass
    implements Insertable<NotificationRecord> {
  /// Unique notification ID
  final String id;

  /// Notification type: breach_alert, emergency_request, emergency_approved,
  /// emergency_rejected, shared_item, expiry_reminder
  final String type;

  /// Human-readable notification title
  final String title;

  /// Human-readable notification body
  final String body;

  /// Optional reference to a source record (shared item ID, breach ID, etc.)
  final String? referenceId;

  /// Whether the user has read this notification
  final bool read;

  /// When the notification was created
  final DateTime createdAt;
  const NotificationRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    required this.read,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    map['read'] = Variable<bool>(read);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationRecordsCompanion toCompanion(bool nullToAbsent) {
    return NotificationRecordsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      referenceId:
          referenceId == null && nullToAbsent
              ? const Value.absent()
              : Value(referenceId),
      read: Value(read),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRecord(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      read: serializer.fromJson<bool>(json['read']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'referenceId': serializer.toJson<String?>(referenceId),
      'read': serializer.toJson<bool>(read),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationRecord copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    Value<String?> referenceId = const Value.absent(),
    bool? read,
    DateTime? createdAt,
  }) => NotificationRecord(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    read: read ?? this.read,
    createdAt: createdAt ?? this.createdAt,
  );
  NotificationRecord copyWithCompanion(NotificationRecordsCompanion data) {
    return NotificationRecord(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      read: data.read.present ? data.read.value : this.read,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRecord(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('referenceId: $referenceId, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, title, body, referenceId, read, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRecord &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.referenceId == this.referenceId &&
          other.read == this.read &&
          other.createdAt == this.createdAt);
}

class NotificationRecordsCompanion extends UpdateCompanion<NotificationRecord> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> referenceId;
  final Value<bool> read;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotificationRecordsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.read = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationRecordsCompanion.insert({
    required String id,
    required String type,
    required String title,
    required String body,
    this.referenceId = const Value.absent(),
    this.read = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       title = Value(title),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<NotificationRecord> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? referenceId,
    Expression<bool>? read,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (referenceId != null) 'reference_id': referenceId,
      if (read != null) 'read': read,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? referenceId,
    Value<bool>? read,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NotificationRecordsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      referenceId: referenceId ?? this.referenceId,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('referenceId: $referenceId, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FileAttachmentsTable extends FileAttachments
    with TableInfo<$FileAttachmentsTable, FileAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileAttachmentsTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPathMeta = const VerificationMeta(
    'encryptedPath',
  );
  @override
  late final GeneratedColumn<String> encryptedPath = GeneratedColumn<String>(
    'encrypted_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vaultId,
    fileName,
    mimeType,
    sizeBytes,
    encryptedPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileAttachment> instance, {
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
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('encrypted_path')) {
      context.handle(
        _encryptedPathMeta,
        encryptedPath.isAcceptableOrUnknown(
          data['encrypted_path']!,
          _encryptedPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FileAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileAttachment(
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
      fileName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_name'],
          )!,
      mimeType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}mime_type'],
          )!,
      sizeBytes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}size_bytes'],
          )!,
      encryptedPath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}encrypted_path'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $FileAttachmentsTable createAlias(String alias) {
    return $FileAttachmentsTable(attachedDatabase, alias);
  }
}

class FileAttachment extends DataClass implements Insertable<FileAttachment> {
  /// UUID primary key
  final String id;

  /// The vault this attachment belongs to
  final String vaultId;

  /// Original file name (encrypted at rest in the vault blob)
  final String fileName;

  /// MIME type of the original file (e.g., 'application/pdf')
  final String mimeType;

  /// Size of the original file in bytes
  final int sizeBytes;

  /// Path to the encrypted file on local storage
  final String encryptedPath;

  /// When the attachment was added
  final DateTime createdAt;
  const FileAttachment({
    required this.id,
    required this.vaultId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.encryptedPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['encrypted_path'] = Variable<String>(encryptedPath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FileAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return FileAttachmentsCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      encryptedPath: Value(encryptedPath),
      createdAt: Value(createdAt),
    );
  }

  factory FileAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileAttachment(
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vaultId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      encryptedPath: serializer.fromJson<String>(json['encryptedPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vaultId': serializer.toJson<String>(vaultId),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'encryptedPath': serializer.toJson<String>(encryptedPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FileAttachment copyWith({
    String? id,
    String? vaultId,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    String? encryptedPath,
    DateTime? createdAt,
  }) => FileAttachment(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    encryptedPath: encryptedPath ?? this.encryptedPath,
    createdAt: createdAt ?? this.createdAt,
  );
  FileAttachment copyWithCompanion(FileAttachmentsCompanion data) {
    return FileAttachment(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      encryptedPath:
          data.encryptedPath.present
              ? data.encryptedPath.value
              : this.encryptedPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileAttachment(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vaultId,
    fileName,
    mimeType,
    sizeBytes,
    encryptedPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileAttachment &&
          other.id == this.id &&
          other.vaultId == this.vaultId &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.encryptedPath == this.encryptedPath &&
          other.createdAt == this.createdAt);
}

class FileAttachmentsCompanion extends UpdateCompanion<FileAttachment> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String> encryptedPath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FileAttachmentsCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.encryptedPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileAttachmentsCompanion.insert({
    required String id,
    required String vaultId,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    required String encryptedPath,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vaultId = Value(vaultId),
       fileName = Value(fileName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       encryptedPath = Value(encryptedPath),
       createdAt = Value(createdAt);
  static Insertable<FileAttachment> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? encryptedPath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (encryptedPath != null) 'encrypted_path': encryptedPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultId,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String>? encryptedPath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FileAttachmentsCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      createdAt: createdAt ?? this.createdAt,
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
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (encryptedPath.present) {
      map['encrypted_path'] = Variable<String>(encryptedPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('createdAt: $createdAt, ')
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
  late final $SharedItemsTable sharedItems = $SharedItemsTable(this);
  late final $VaultMembersTable vaultMembers = $VaultMembersTable(this);
  late final $EmergencyContactsTable emergencyContacts =
      $EmergencyContactsTable(this);
  late final $NotificationRecordsTable notificationRecords =
      $NotificationRecordsTable(this);
  late final $FileAttachmentsTable fileAttachments = $FileAttachmentsTable(
    this,
  );
  late final VaultDao vaultDao = VaultDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final PasswordHistoryDao passwordHistoryDao = PasswordHistoryDao(
    this as AppDatabase,
  );
  late final TotpDao totpDao = TotpDao(this as AppDatabase);
  late final AutofillIndexDao autofillIndexDao = AutofillIndexDao(
    this as AppDatabase,
  );
  late final SharingDao sharingDao = SharingDao(this as AppDatabase);
  late final NotificationDao notificationDao = NotificationDao(
    this as AppDatabase,
  );
  late final FileAttachmentDao fileAttachmentDao = FileAttachmentDao(
    this as AppDatabase,
  );
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
    sharedItems,
    vaultMembers,
    emergencyContacts,
    notificationRecords,
    fileAttachments,
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
      Value<String> colorHex,
      Value<String> iconName,
      Value<bool> isTravelSafe,
      Value<bool> isHiddenByTravel,
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
      Value<String> colorHex,
      Value<String> iconName,
      Value<bool> isTravelSafe,
      Value<bool> isHiddenByTravel,
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

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTravelSafe => $composableBuilder(
    column: $table.isTravelSafe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHiddenByTravel => $composableBuilder(
    column: $table.isHiddenByTravel,
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

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTravelSafe => $composableBuilder(
    column: $table.isTravelSafe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHiddenByTravel => $composableBuilder(
    column: $table.isHiddenByTravel,
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

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<bool> get isTravelSafe => $composableBuilder(
    column: $table.isTravelSafe,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHiddenByTravel => $composableBuilder(
    column: $table.isHiddenByTravel,
    builder: (column) => column,
  );

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
                Value<String> colorHex = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<bool> isTravelSafe = const Value.absent(),
                Value<bool> isHiddenByTravel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultsCompanion(
                id: id,
                name: name,
                description: description,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                colorHex: colorHex,
                iconName: iconName,
                isTravelSafe: isTravelSafe,
                isHiddenByTravel: isHiddenByTravel,
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
                Value<String> colorHex = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<bool> isTravelSafe = const Value.absent(),
                Value<bool> isHiddenByTravel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultsCompanion.insert(
                id: id,
                name: name,
                description: description,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                colorHex: colorHex,
                iconName: iconName,
                isTravelSafe: isTravelSafe,
                isHiddenByTravel: isHiddenByTravel,
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
typedef $$SharedItemsTableCreateCompanionBuilder =
    SharedItemsCompanion Function({
      required String id,
      required String senderId,
      required String recipientId,
      required String encryptedData,
      required String senderPublicKey,
      required DateTime createdAt,
      Value<DateTime?> expiresAt,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$SharedItemsTableUpdateCompanionBuilder =
    SharedItemsCompanion Function({
      Value<String> id,
      Value<String> senderId,
      Value<String> recipientId,
      Value<String> encryptedData,
      Value<String> senderPublicKey,
      Value<DateTime> createdAt,
      Value<DateTime?> expiresAt,
      Value<String> status,
      Value<int> rowid,
    });

class $$SharedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SharedItemsTable> {
  $$SharedItemsTableFilterComposer({
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

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipientId => $composableBuilder(
    column: $table.recipientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedData => $composableBuilder(
    column: $table.encryptedData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderPublicKey => $composableBuilder(
    column: $table.senderPublicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SharedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SharedItemsTable> {
  $$SharedItemsTableOrderingComposer({
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

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipientId => $composableBuilder(
    column: $table.recipientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedData => $composableBuilder(
    column: $table.encryptedData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderPublicKey => $composableBuilder(
    column: $table.senderPublicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SharedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SharedItemsTable> {
  $$SharedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get recipientId => $composableBuilder(
    column: $table.recipientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedData => $composableBuilder(
    column: $table.encryptedData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderPublicKey => $composableBuilder(
    column: $table.senderPublicKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SharedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SharedItemsTable,
          SharedItem,
          $$SharedItemsTableFilterComposer,
          $$SharedItemsTableOrderingComposer,
          $$SharedItemsTableAnnotationComposer,
          $$SharedItemsTableCreateCompanionBuilder,
          $$SharedItemsTableUpdateCompanionBuilder,
          (
            SharedItem,
            BaseReferences<_$AppDatabase, $SharedItemsTable, SharedItem>,
          ),
          SharedItem,
          PrefetchHooks Function()
        > {
  $$SharedItemsTableTableManager(_$AppDatabase db, $SharedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SharedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SharedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$SharedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> recipientId = const Value.absent(),
                Value<String> encryptedData = const Value.absent(),
                Value<String> senderPublicKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SharedItemsCompanion(
                id: id,
                senderId: senderId,
                recipientId: recipientId,
                encryptedData: encryptedData,
                senderPublicKey: senderPublicKey,
                createdAt: createdAt,
                expiresAt: expiresAt,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String senderId,
                required String recipientId,
                required String encryptedData,
                required String senderPublicKey,
                required DateTime createdAt,
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SharedItemsCompanion.insert(
                id: id,
                senderId: senderId,
                recipientId: recipientId,
                encryptedData: encryptedData,
                senderPublicKey: senderPublicKey,
                createdAt: createdAt,
                expiresAt: expiresAt,
                status: status,
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

typedef $$SharedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SharedItemsTable,
      SharedItem,
      $$SharedItemsTableFilterComposer,
      $$SharedItemsTableOrderingComposer,
      $$SharedItemsTableAnnotationComposer,
      $$SharedItemsTableCreateCompanionBuilder,
      $$SharedItemsTableUpdateCompanionBuilder,
      (
        SharedItem,
        BaseReferences<_$AppDatabase, $SharedItemsTable, SharedItem>,
      ),
      SharedItem,
      PrefetchHooks Function()
    >;
typedef $$VaultMembersTableCreateCompanionBuilder =
    VaultMembersCompanion Function({
      required String id,
      required String vaultId,
      required String userId,
      Value<String> role,
      required String encryptedVaultKey,
      required String ownerPublicKey,
      required DateTime invitedAt,
      Value<DateTime?> acceptedAt,
      Value<int> rowid,
    });
typedef $$VaultMembersTableUpdateCompanionBuilder =
    VaultMembersCompanion Function({
      Value<String> id,
      Value<String> vaultId,
      Value<String> userId,
      Value<String> role,
      Value<String> encryptedVaultKey,
      Value<String> ownerPublicKey,
      Value<DateTime> invitedAt,
      Value<DateTime?> acceptedAt,
      Value<int> rowid,
    });

class $$VaultMembersTableFilterComposer
    extends Composer<_$AppDatabase, $VaultMembersTable> {
  $$VaultMembersTableFilterComposer({
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

  ColumnFilters<String> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedVaultKey => $composableBuilder(
    column: $table.encryptedVaultKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerPublicKey => $composableBuilder(
    column: $table.ownerPublicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get invitedAt => $composableBuilder(
    column: $table.invitedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaultMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $VaultMembersTable> {
  $$VaultMembersTableOrderingComposer({
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

  ColumnOrderings<String> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedVaultKey => $composableBuilder(
    column: $table.encryptedVaultKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerPublicKey => $composableBuilder(
    column: $table.ownerPublicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get invitedAt => $composableBuilder(
    column: $table.invitedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaultMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaultMembersTable> {
  $$VaultMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vaultId =>
      $composableBuilder(column: $table.vaultId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get encryptedVaultKey => $composableBuilder(
    column: $table.encryptedVaultKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerPublicKey => $composableBuilder(
    column: $table.ownerPublicKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get invitedAt =>
      $composableBuilder(column: $table.invitedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => column,
  );
}

class $$VaultMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaultMembersTable,
          VaultMember,
          $$VaultMembersTableFilterComposer,
          $$VaultMembersTableOrderingComposer,
          $$VaultMembersTableAnnotationComposer,
          $$VaultMembersTableCreateCompanionBuilder,
          $$VaultMembersTableUpdateCompanionBuilder,
          (
            VaultMember,
            BaseReferences<_$AppDatabase, $VaultMembersTable, VaultMember>,
          ),
          VaultMember,
          PrefetchHooks Function()
        > {
  $$VaultMembersTableTableManager(_$AppDatabase db, $VaultMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$VaultMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$VaultMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$VaultMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vaultId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> encryptedVaultKey = const Value.absent(),
                Value<String> ownerPublicKey = const Value.absent(),
                Value<DateTime> invitedAt = const Value.absent(),
                Value<DateTime?> acceptedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultMembersCompanion(
                id: id,
                vaultId: vaultId,
                userId: userId,
                role: role,
                encryptedVaultKey: encryptedVaultKey,
                ownerPublicKey: ownerPublicKey,
                invitedAt: invitedAt,
                acceptedAt: acceptedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vaultId,
                required String userId,
                Value<String> role = const Value.absent(),
                required String encryptedVaultKey,
                required String ownerPublicKey,
                required DateTime invitedAt,
                Value<DateTime?> acceptedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultMembersCompanion.insert(
                id: id,
                vaultId: vaultId,
                userId: userId,
                role: role,
                encryptedVaultKey: encryptedVaultKey,
                ownerPublicKey: ownerPublicKey,
                invitedAt: invitedAt,
                acceptedAt: acceptedAt,
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

typedef $$VaultMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaultMembersTable,
      VaultMember,
      $$VaultMembersTableFilterComposer,
      $$VaultMembersTableOrderingComposer,
      $$VaultMembersTableAnnotationComposer,
      $$VaultMembersTableCreateCompanionBuilder,
      $$VaultMembersTableUpdateCompanionBuilder,
      (
        VaultMember,
        BaseReferences<_$AppDatabase, $VaultMembersTable, VaultMember>,
      ),
      VaultMember,
      PrefetchHooks Function()
    >;
typedef $$EmergencyContactsTableCreateCompanionBuilder =
    EmergencyContactsCompanion Function({
      required String id,
      required String grantorId,
      required String granteeId,
      Value<int> waitingPeriodDays,
      Value<String> status,
      Value<String?> encryptedVaultKey,
      Value<String?> granteePublicKey,
      Value<DateTime?> requestedAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$EmergencyContactsTableUpdateCompanionBuilder =
    EmergencyContactsCompanion Function({
      Value<String> id,
      Value<String> grantorId,
      Value<String> granteeId,
      Value<int> waitingPeriodDays,
      Value<String> status,
      Value<String?> encryptedVaultKey,
      Value<String?> granteePublicKey,
      Value<DateTime?> requestedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$EmergencyContactsTableFilterComposer
    extends Composer<_$AppDatabase, $EmergencyContactsTable> {
  $$EmergencyContactsTableFilterComposer({
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

  ColumnFilters<String> get grantorId => $composableBuilder(
    column: $table.grantorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get granteeId => $composableBuilder(
    column: $table.granteeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waitingPeriodDays => $composableBuilder(
    column: $table.waitingPeriodDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedVaultKey => $composableBuilder(
    column: $table.encryptedVaultKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get granteePublicKey => $composableBuilder(
    column: $table.granteePublicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmergencyContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmergencyContactsTable> {
  $$EmergencyContactsTableOrderingComposer({
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

  ColumnOrderings<String> get grantorId => $composableBuilder(
    column: $table.grantorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get granteeId => $composableBuilder(
    column: $table.granteeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waitingPeriodDays => $composableBuilder(
    column: $table.waitingPeriodDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedVaultKey => $composableBuilder(
    column: $table.encryptedVaultKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get granteePublicKey => $composableBuilder(
    column: $table.granteePublicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmergencyContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmergencyContactsTable> {
  $$EmergencyContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get grantorId =>
      $composableBuilder(column: $table.grantorId, builder: (column) => column);

  GeneratedColumn<String> get granteeId =>
      $composableBuilder(column: $table.granteeId, builder: (column) => column);

  GeneratedColumn<int> get waitingPeriodDays => $composableBuilder(
    column: $table.waitingPeriodDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get encryptedVaultKey => $composableBuilder(
    column: $table.encryptedVaultKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get granteePublicKey => $composableBuilder(
    column: $table.granteePublicKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get requestedAt => $composableBuilder(
    column: $table.requestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$EmergencyContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmergencyContactsTable,
          EmergencyContact,
          $$EmergencyContactsTableFilterComposer,
          $$EmergencyContactsTableOrderingComposer,
          $$EmergencyContactsTableAnnotationComposer,
          $$EmergencyContactsTableCreateCompanionBuilder,
          $$EmergencyContactsTableUpdateCompanionBuilder,
          (
            EmergencyContact,
            BaseReferences<
              _$AppDatabase,
              $EmergencyContactsTable,
              EmergencyContact
            >,
          ),
          EmergencyContact,
          PrefetchHooks Function()
        > {
  $$EmergencyContactsTableTableManager(
    _$AppDatabase db,
    $EmergencyContactsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$EmergencyContactsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$EmergencyContactsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$EmergencyContactsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> grantorId = const Value.absent(),
                Value<String> granteeId = const Value.absent(),
                Value<int> waitingPeriodDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> encryptedVaultKey = const Value.absent(),
                Value<String?> granteePublicKey = const Value.absent(),
                Value<DateTime?> requestedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmergencyContactsCompanion(
                id: id,
                grantorId: grantorId,
                granteeId: granteeId,
                waitingPeriodDays: waitingPeriodDays,
                status: status,
                encryptedVaultKey: encryptedVaultKey,
                granteePublicKey: granteePublicKey,
                requestedAt: requestedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String grantorId,
                required String granteeId,
                Value<int> waitingPeriodDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> encryptedVaultKey = const Value.absent(),
                Value<String?> granteePublicKey = const Value.absent(),
                Value<DateTime?> requestedAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EmergencyContactsCompanion.insert(
                id: id,
                grantorId: grantorId,
                granteeId: granteeId,
                waitingPeriodDays: waitingPeriodDays,
                status: status,
                encryptedVaultKey: encryptedVaultKey,
                granteePublicKey: granteePublicKey,
                requestedAt: requestedAt,
                createdAt: createdAt,
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

typedef $$EmergencyContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmergencyContactsTable,
      EmergencyContact,
      $$EmergencyContactsTableFilterComposer,
      $$EmergencyContactsTableOrderingComposer,
      $$EmergencyContactsTableAnnotationComposer,
      $$EmergencyContactsTableCreateCompanionBuilder,
      $$EmergencyContactsTableUpdateCompanionBuilder,
      (
        EmergencyContact,
        BaseReferences<
          _$AppDatabase,
          $EmergencyContactsTable,
          EmergencyContact
        >,
      ),
      EmergencyContact,
      PrefetchHooks Function()
    >;
typedef $$NotificationRecordsTableCreateCompanionBuilder =
    NotificationRecordsCompanion Function({
      required String id,
      required String type,
      required String title,
      required String body,
      Value<String?> referenceId,
      Value<bool> read,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$NotificationRecordsTableUpdateCompanionBuilder =
    NotificationRecordsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> title,
      Value<String> body,
      Value<String?> referenceId,
      Value<bool> read,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$NotificationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationRecordsTable> {
  $$NotificationRecordsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationRecordsTable> {
  $$NotificationRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationRecordsTable> {
  $$NotificationRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationRecordsTable,
          NotificationRecord,
          $$NotificationRecordsTableFilterComposer,
          $$NotificationRecordsTableOrderingComposer,
          $$NotificationRecordsTableAnnotationComposer,
          $$NotificationRecordsTableCreateCompanionBuilder,
          $$NotificationRecordsTableUpdateCompanionBuilder,
          (
            NotificationRecord,
            BaseReferences<
              _$AppDatabase,
              $NotificationRecordsTable,
              NotificationRecord
            >,
          ),
          NotificationRecord,
          PrefetchHooks Function()
        > {
  $$NotificationRecordsTableTableManager(
    _$AppDatabase db,
    $NotificationRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$NotificationRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$NotificationRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$NotificationRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationRecordsCompanion(
                id: id,
                type: type,
                title: title,
                body: body,
                referenceId: referenceId,
                read: read,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String title,
                required String body,
                Value<String?> referenceId = const Value.absent(),
                Value<bool> read = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => NotificationRecordsCompanion.insert(
                id: id,
                type: type,
                title: title,
                body: body,
                referenceId: referenceId,
                read: read,
                createdAt: createdAt,
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

typedef $$NotificationRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationRecordsTable,
      NotificationRecord,
      $$NotificationRecordsTableFilterComposer,
      $$NotificationRecordsTableOrderingComposer,
      $$NotificationRecordsTableAnnotationComposer,
      $$NotificationRecordsTableCreateCompanionBuilder,
      $$NotificationRecordsTableUpdateCompanionBuilder,
      (
        NotificationRecord,
        BaseReferences<
          _$AppDatabase,
          $NotificationRecordsTable,
          NotificationRecord
        >,
      ),
      NotificationRecord,
      PrefetchHooks Function()
    >;
typedef $$FileAttachmentsTableCreateCompanionBuilder =
    FileAttachmentsCompanion Function({
      required String id,
      required String vaultId,
      required String fileName,
      required String mimeType,
      required int sizeBytes,
      required String encryptedPath,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FileAttachmentsTableUpdateCompanionBuilder =
    FileAttachmentsCompanion Function({
      Value<String> id,
      Value<String> vaultId,
      Value<String> fileName,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String> encryptedPath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FileAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $FileAttachmentsTable> {
  $$FileAttachmentsTableFilterComposer({
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

  ColumnFilters<String> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FileAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $FileAttachmentsTable> {
  $$FileAttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FileAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FileAttachmentsTable> {
  $$FileAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vaultId =>
      $composableBuilder(column: $table.vaultId, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FileAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FileAttachmentsTable,
          FileAttachment,
          $$FileAttachmentsTableFilterComposer,
          $$FileAttachmentsTableOrderingComposer,
          $$FileAttachmentsTableAnnotationComposer,
          $$FileAttachmentsTableCreateCompanionBuilder,
          $$FileAttachmentsTableUpdateCompanionBuilder,
          (
            FileAttachment,
            BaseReferences<
              _$AppDatabase,
              $FileAttachmentsTable,
              FileAttachment
            >,
          ),
          FileAttachment,
          PrefetchHooks Function()
        > {
  $$FileAttachmentsTableTableManager(
    _$AppDatabase db,
    $FileAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$FileAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FileAttachmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$FileAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vaultId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> encryptedPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileAttachmentsCompanion(
                id: id,
                vaultId: vaultId,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                encryptedPath: encryptedPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vaultId,
                required String fileName,
                required String mimeType,
                required int sizeBytes,
                required String encryptedPath,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FileAttachmentsCompanion.insert(
                id: id,
                vaultId: vaultId,
                fileName: fileName,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                encryptedPath: encryptedPath,
                createdAt: createdAt,
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

typedef $$FileAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FileAttachmentsTable,
      FileAttachment,
      $$FileAttachmentsTableFilterComposer,
      $$FileAttachmentsTableOrderingComposer,
      $$FileAttachmentsTableAnnotationComposer,
      $$FileAttachmentsTableCreateCompanionBuilder,
      $$FileAttachmentsTableUpdateCompanionBuilder,
      (
        FileAttachment,
        BaseReferences<_$AppDatabase, $FileAttachmentsTable, FileAttachment>,
      ),
      FileAttachment,
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
  $$SharedItemsTableTableManager get sharedItems =>
      $$SharedItemsTableTableManager(_db, _db.sharedItems);
  $$VaultMembersTableTableManager get vaultMembers =>
      $$VaultMembersTableTableManager(_db, _db.vaultMembers);
  $$EmergencyContactsTableTableManager get emergencyContacts =>
      $$EmergencyContactsTableTableManager(_db, _db.emergencyContacts);
  $$NotificationRecordsTableTableManager get notificationRecords =>
      $$NotificationRecordsTableTableManager(_db, _db.notificationRecords);
  $$FileAttachmentsTableTableManager get fileAttachments =>
      $$FileAttachmentsTableTableManager(_db, _db.fileAttachments);
}
