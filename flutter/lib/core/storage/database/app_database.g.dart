// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _addressNameMeta =
      const VerificationMeta('addressName');
  @override
  late final GeneratedColumn<String> addressName = GeneratedColumn<String>(
      'address_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
      'device_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recordMeta = const VerificationMeta('record');
  @override
  late final GeneratedColumn<Uint8List> record = GeneratedColumn<Uint8List>(
      'record', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<int> lastUpdated = GeneratedColumn<int>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, addressName, deviceId, record, createdAt, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('address_name')) {
      context.handle(
          _addressNameMeta,
          addressName.isAcceptableOrUnknown(
              data['address_name']!, _addressNameMeta));
    } else if (isInserting) {
      context.missing(_addressNameMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('record')) {
      context.handle(_recordMeta,
          record.isAcceptableOrUnknown(data['record']!, _recordMeta));
    } else if (isInserting) {
      context.missing(_recordMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {addressName, deviceId},
      ];
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      addressName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address_name'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}device_id'])!,
      record: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}record'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_updated'])!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String addressName;
  final int deviceId;
  final Uint8List record;
  final int createdAt;
  final int lastUpdated;
  const Session(
      {required this.id,
      required this.addressName,
      required this.deviceId,
      required this.record,
      required this.createdAt,
      required this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['address_name'] = Variable<String>(addressName);
    map['device_id'] = Variable<int>(deviceId);
    map['record'] = Variable<Uint8List>(record);
    map['created_at'] = Variable<int>(createdAt);
    map['last_updated'] = Variable<int>(lastUpdated);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      addressName: Value(addressName),
      deviceId: Value(deviceId),
      record: Value(record),
      createdAt: Value(createdAt),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      addressName: serializer.fromJson<String>(json['addressName']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      record: serializer.fromJson<Uint8List>(json['record']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastUpdated: serializer.fromJson<int>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'addressName': serializer.toJson<String>(addressName),
      'deviceId': serializer.toJson<int>(deviceId),
      'record': serializer.toJson<Uint8List>(record),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastUpdated': serializer.toJson<int>(lastUpdated),
    };
  }

  Session copyWith(
          {int? id,
          String? addressName,
          int? deviceId,
          Uint8List? record,
          int? createdAt,
          int? lastUpdated}) =>
      Session(
        id: id ?? this.id,
        addressName: addressName ?? this.addressName,
        deviceId: deviceId ?? this.deviceId,
        record: record ?? this.record,
        createdAt: createdAt ?? this.createdAt,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      addressName:
          data.addressName.present ? data.addressName.value : this.addressName,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      record: data.record.present ? data.record.value : this.record,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('addressName: $addressName, ')
          ..write('deviceId: $deviceId, ')
          ..write('record: $record, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, addressName, deviceId,
      $driftBlobEquality.hash(record), createdAt, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.addressName == this.addressName &&
          other.deviceId == this.deviceId &&
          $driftBlobEquality.equals(other.record, this.record) &&
          other.createdAt == this.createdAt &&
          other.lastUpdated == this.lastUpdated);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> addressName;
  final Value<int> deviceId;
  final Value<Uint8List> record;
  final Value<int> createdAt;
  final Value<int> lastUpdated;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.addressName = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.record = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String addressName,
    required int deviceId,
    required Uint8List record,
    required int createdAt,
    required int lastUpdated,
  })  : addressName = Value(addressName),
        deviceId = Value(deviceId),
        record = Value(record),
        createdAt = Value(createdAt),
        lastUpdated = Value(lastUpdated);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? addressName,
    Expression<int>? deviceId,
    Expression<Uint8List>? record,
    Expression<int>? createdAt,
    Expression<int>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (addressName != null) 'address_name': addressName,
      if (deviceId != null) 'device_id': deviceId,
      if (record != null) 'record': record,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  SessionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? addressName,
      Value<int>? deviceId,
      Value<Uint8List>? record,
      Value<int>? createdAt,
      Value<int>? lastUpdated}) {
    return SessionsCompanion(
      id: id ?? this.id,
      addressName: addressName ?? this.addressName,
      deviceId: deviceId ?? this.deviceId,
      record: record ?? this.record,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (addressName.present) {
      map['address_name'] = Variable<String>(addressName.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (record.present) {
      map['record'] = Variable<Uint8List>(record.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<int>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('addressName: $addressName, ')
          ..write('deviceId: $deviceId, ')
          ..write('record: $record, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $IdentityKeysTable extends IdentityKeys
    with TableInfo<$IdentityKeysTable, IdentityKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentityKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _addressNameMeta =
      const VerificationMeta('addressName');
  @override
  late final GeneratedColumn<String> addressName = GeneratedColumn<String>(
      'address_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
      'device_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _identityKeyMeta =
      const VerificationMeta('identityKey');
  @override
  late final GeneratedColumn<Uint8List> identityKey =
      GeneratedColumn<Uint8List>('identity_key', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, addressName, deviceId, identityKey, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identity_keys';
  @override
  VerificationContext validateIntegrity(Insertable<IdentityKey> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('address_name')) {
      context.handle(
          _addressNameMeta,
          addressName.isAcceptableOrUnknown(
              data['address_name']!, _addressNameMeta));
    } else if (isInserting) {
      context.missing(_addressNameMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('identity_key')) {
      context.handle(
          _identityKeyMeta,
          identityKey.isAcceptableOrUnknown(
              data['identity_key']!, _identityKeyMeta));
    } else if (isInserting) {
      context.missing(_identityKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {addressName, deviceId},
      ];
  @override
  IdentityKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentityKey(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      addressName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address_name'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}device_id'])!,
      identityKey: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}identity_key'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $IdentityKeysTable createAlias(String alias) {
    return $IdentityKeysTable(attachedDatabase, alias);
  }
}

class IdentityKey extends DataClass implements Insertable<IdentityKey> {
  final int id;
  final String addressName;
  final int deviceId;
  final Uint8List identityKey;
  final int createdAt;
  const IdentityKey(
      {required this.id,
      required this.addressName,
      required this.deviceId,
      required this.identityKey,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['address_name'] = Variable<String>(addressName);
    map['device_id'] = Variable<int>(deviceId);
    map['identity_key'] = Variable<Uint8List>(identityKey);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  IdentityKeysCompanion toCompanion(bool nullToAbsent) {
    return IdentityKeysCompanion(
      id: Value(id),
      addressName: Value(addressName),
      deviceId: Value(deviceId),
      identityKey: Value(identityKey),
      createdAt: Value(createdAt),
    );
  }

  factory IdentityKey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentityKey(
      id: serializer.fromJson<int>(json['id']),
      addressName: serializer.fromJson<String>(json['addressName']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      identityKey: serializer.fromJson<Uint8List>(json['identityKey']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'addressName': serializer.toJson<String>(addressName),
      'deviceId': serializer.toJson<int>(deviceId),
      'identityKey': serializer.toJson<Uint8List>(identityKey),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  IdentityKey copyWith(
          {int? id,
          String? addressName,
          int? deviceId,
          Uint8List? identityKey,
          int? createdAt}) =>
      IdentityKey(
        id: id ?? this.id,
        addressName: addressName ?? this.addressName,
        deviceId: deviceId ?? this.deviceId,
        identityKey: identityKey ?? this.identityKey,
        createdAt: createdAt ?? this.createdAt,
      );
  IdentityKey copyWithCompanion(IdentityKeysCompanion data) {
    return IdentityKey(
      id: data.id.present ? data.id.value : this.id,
      addressName:
          data.addressName.present ? data.addressName.value : this.addressName,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      identityKey:
          data.identityKey.present ? data.identityKey.value : this.identityKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentityKey(')
          ..write('id: $id, ')
          ..write('addressName: $addressName, ')
          ..write('deviceId: $deviceId, ')
          ..write('identityKey: $identityKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, addressName, deviceId,
      $driftBlobEquality.hash(identityKey), createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentityKey &&
          other.id == this.id &&
          other.addressName == this.addressName &&
          other.deviceId == this.deviceId &&
          $driftBlobEquality.equals(other.identityKey, this.identityKey) &&
          other.createdAt == this.createdAt);
}

class IdentityKeysCompanion extends UpdateCompanion<IdentityKey> {
  final Value<int> id;
  final Value<String> addressName;
  final Value<int> deviceId;
  final Value<Uint8List> identityKey;
  final Value<int> createdAt;
  const IdentityKeysCompanion({
    this.id = const Value.absent(),
    this.addressName = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.identityKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  IdentityKeysCompanion.insert({
    this.id = const Value.absent(),
    required String addressName,
    required int deviceId,
    required Uint8List identityKey,
    required int createdAt,
  })  : addressName = Value(addressName),
        deviceId = Value(deviceId),
        identityKey = Value(identityKey),
        createdAt = Value(createdAt);
  static Insertable<IdentityKey> custom({
    Expression<int>? id,
    Expression<String>? addressName,
    Expression<int>? deviceId,
    Expression<Uint8List>? identityKey,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (addressName != null) 'address_name': addressName,
      if (deviceId != null) 'device_id': deviceId,
      if (identityKey != null) 'identity_key': identityKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  IdentityKeysCompanion copyWith(
      {Value<int>? id,
      Value<String>? addressName,
      Value<int>? deviceId,
      Value<Uint8List>? identityKey,
      Value<int>? createdAt}) {
    return IdentityKeysCompanion(
      id: id ?? this.id,
      addressName: addressName ?? this.addressName,
      deviceId: deviceId ?? this.deviceId,
      identityKey: identityKey ?? this.identityKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (addressName.present) {
      map['address_name'] = Variable<String>(addressName.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (identityKey.present) {
      map['identity_key'] = Variable<Uint8List>(identityKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentityKeysCompanion(')
          ..write('id: $id, ')
          ..write('addressName: $addressName, ')
          ..write('deviceId: $deviceId, ')
          ..write('identityKey: $identityKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PreKeysTable extends PreKeys with TableInfo<$PreKeysTable, PreKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _preKeyIdMeta =
      const VerificationMeta('preKeyId');
  @override
  late final GeneratedColumn<int> preKeyId = GeneratedColumn<int>(
      'pre_key_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _recordMeta = const VerificationMeta('record');
  @override
  late final GeneratedColumn<Uint8List> record = GeneratedColumn<Uint8List>(
      'record', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, preKeyId, record, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pre_keys';
  @override
  VerificationContext validateIntegrity(Insertable<PreKey> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pre_key_id')) {
      context.handle(_preKeyIdMeta,
          preKeyId.isAcceptableOrUnknown(data['pre_key_id']!, _preKeyIdMeta));
    } else if (isInserting) {
      context.missing(_preKeyIdMeta);
    }
    if (data.containsKey('record')) {
      context.handle(_recordMeta,
          record.isAcceptableOrUnknown(data['record']!, _recordMeta));
    } else if (isInserting) {
      context.missing(_recordMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreKey(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      preKeyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pre_key_id'])!,
      record: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}record'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PreKeysTable createAlias(String alias) {
    return $PreKeysTable(attachedDatabase, alias);
  }
}

class PreKey extends DataClass implements Insertable<PreKey> {
  final int id;
  final int preKeyId;
  final Uint8List record;
  final int createdAt;
  const PreKey(
      {required this.id,
      required this.preKeyId,
      required this.record,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pre_key_id'] = Variable<int>(preKeyId);
    map['record'] = Variable<Uint8List>(record);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  PreKeysCompanion toCompanion(bool nullToAbsent) {
    return PreKeysCompanion(
      id: Value(id),
      preKeyId: Value(preKeyId),
      record: Value(record),
      createdAt: Value(createdAt),
    );
  }

  factory PreKey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreKey(
      id: serializer.fromJson<int>(json['id']),
      preKeyId: serializer.fromJson<int>(json['preKeyId']),
      record: serializer.fromJson<Uint8List>(json['record']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'preKeyId': serializer.toJson<int>(preKeyId),
      'record': serializer.toJson<Uint8List>(record),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  PreKey copyWith(
          {int? id, int? preKeyId, Uint8List? record, int? createdAt}) =>
      PreKey(
        id: id ?? this.id,
        preKeyId: preKeyId ?? this.preKeyId,
        record: record ?? this.record,
        createdAt: createdAt ?? this.createdAt,
      );
  PreKey copyWithCompanion(PreKeysCompanion data) {
    return PreKey(
      id: data.id.present ? data.id.value : this.id,
      preKeyId: data.preKeyId.present ? data.preKeyId.value : this.preKeyId,
      record: data.record.present ? data.record.value : this.record,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreKey(')
          ..write('id: $id, ')
          ..write('preKeyId: $preKeyId, ')
          ..write('record: $record, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, preKeyId, $driftBlobEquality.hash(record), createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreKey &&
          other.id == this.id &&
          other.preKeyId == this.preKeyId &&
          $driftBlobEquality.equals(other.record, this.record) &&
          other.createdAt == this.createdAt);
}

class PreKeysCompanion extends UpdateCompanion<PreKey> {
  final Value<int> id;
  final Value<int> preKeyId;
  final Value<Uint8List> record;
  final Value<int> createdAt;
  const PreKeysCompanion({
    this.id = const Value.absent(),
    this.preKeyId = const Value.absent(),
    this.record = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PreKeysCompanion.insert({
    this.id = const Value.absent(),
    required int preKeyId,
    required Uint8List record,
    required int createdAt,
  })  : preKeyId = Value(preKeyId),
        record = Value(record),
        createdAt = Value(createdAt);
  static Insertable<PreKey> custom({
    Expression<int>? id,
    Expression<int>? preKeyId,
    Expression<Uint8List>? record,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (preKeyId != null) 'pre_key_id': preKeyId,
      if (record != null) 'record': record,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PreKeysCompanion copyWith(
      {Value<int>? id,
      Value<int>? preKeyId,
      Value<Uint8List>? record,
      Value<int>? createdAt}) {
    return PreKeysCompanion(
      id: id ?? this.id,
      preKeyId: preKeyId ?? this.preKeyId,
      record: record ?? this.record,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (preKeyId.present) {
      map['pre_key_id'] = Variable<int>(preKeyId.value);
    }
    if (record.present) {
      map['record'] = Variable<Uint8List>(record.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreKeysCompanion(')
          ..write('id: $id, ')
          ..write('preKeyId: $preKeyId, ')
          ..write('record: $record, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SignedPreKeysTable extends SignedPreKeys
    with TableInfo<$SignedPreKeysTable, SignedPreKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignedPreKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _signedPreKeyIdMeta =
      const VerificationMeta('signedPreKeyId');
  @override
  late final GeneratedColumn<int> signedPreKeyId = GeneratedColumn<int>(
      'signed_pre_key_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _recordMeta = const VerificationMeta('record');
  @override
  late final GeneratedColumn<Uint8List> record = GeneratedColumn<Uint8List>(
      'record', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, signedPreKeyId, record, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signed_pre_keys';
  @override
  VerificationContext validateIntegrity(Insertable<SignedPreKey> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('signed_pre_key_id')) {
      context.handle(
          _signedPreKeyIdMeta,
          signedPreKeyId.isAcceptableOrUnknown(
              data['signed_pre_key_id']!, _signedPreKeyIdMeta));
    } else if (isInserting) {
      context.missing(_signedPreKeyIdMeta);
    }
    if (data.containsKey('record')) {
      context.handle(_recordMeta,
          record.isAcceptableOrUnknown(data['record']!, _recordMeta));
    } else if (isInserting) {
      context.missing(_recordMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SignedPreKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignedPreKey(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      signedPreKeyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}signed_pre_key_id'])!,
      record: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}record'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SignedPreKeysTable createAlias(String alias) {
    return $SignedPreKeysTable(attachedDatabase, alias);
  }
}

class SignedPreKey extends DataClass implements Insertable<SignedPreKey> {
  final int id;
  final int signedPreKeyId;
  final Uint8List record;
  final int createdAt;
  const SignedPreKey(
      {required this.id,
      required this.signedPreKeyId,
      required this.record,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['signed_pre_key_id'] = Variable<int>(signedPreKeyId);
    map['record'] = Variable<Uint8List>(record);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SignedPreKeysCompanion toCompanion(bool nullToAbsent) {
    return SignedPreKeysCompanion(
      id: Value(id),
      signedPreKeyId: Value(signedPreKeyId),
      record: Value(record),
      createdAt: Value(createdAt),
    );
  }

  factory SignedPreKey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignedPreKey(
      id: serializer.fromJson<int>(json['id']),
      signedPreKeyId: serializer.fromJson<int>(json['signedPreKeyId']),
      record: serializer.fromJson<Uint8List>(json['record']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'signedPreKeyId': serializer.toJson<int>(signedPreKeyId),
      'record': serializer.toJson<Uint8List>(record),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SignedPreKey copyWith(
          {int? id, int? signedPreKeyId, Uint8List? record, int? createdAt}) =>
      SignedPreKey(
        id: id ?? this.id,
        signedPreKeyId: signedPreKeyId ?? this.signedPreKeyId,
        record: record ?? this.record,
        createdAt: createdAt ?? this.createdAt,
      );
  SignedPreKey copyWithCompanion(SignedPreKeysCompanion data) {
    return SignedPreKey(
      id: data.id.present ? data.id.value : this.id,
      signedPreKeyId: data.signedPreKeyId.present
          ? data.signedPreKeyId.value
          : this.signedPreKeyId,
      record: data.record.present ? data.record.value : this.record,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignedPreKey(')
          ..write('id: $id, ')
          ..write('signedPreKeyId: $signedPreKeyId, ')
          ..write('record: $record, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, signedPreKeyId, $driftBlobEquality.hash(record), createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignedPreKey &&
          other.id == this.id &&
          other.signedPreKeyId == this.signedPreKeyId &&
          $driftBlobEquality.equals(other.record, this.record) &&
          other.createdAt == this.createdAt);
}

class SignedPreKeysCompanion extends UpdateCompanion<SignedPreKey> {
  final Value<int> id;
  final Value<int> signedPreKeyId;
  final Value<Uint8List> record;
  final Value<int> createdAt;
  const SignedPreKeysCompanion({
    this.id = const Value.absent(),
    this.signedPreKeyId = const Value.absent(),
    this.record = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SignedPreKeysCompanion.insert({
    this.id = const Value.absent(),
    required int signedPreKeyId,
    required Uint8List record,
    required int createdAt,
  })  : signedPreKeyId = Value(signedPreKeyId),
        record = Value(record),
        createdAt = Value(createdAt);
  static Insertable<SignedPreKey> custom({
    Expression<int>? id,
    Expression<int>? signedPreKeyId,
    Expression<Uint8List>? record,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (signedPreKeyId != null) 'signed_pre_key_id': signedPreKeyId,
      if (record != null) 'record': record,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SignedPreKeysCompanion copyWith(
      {Value<int>? id,
      Value<int>? signedPreKeyId,
      Value<Uint8List>? record,
      Value<int>? createdAt}) {
    return SignedPreKeysCompanion(
      id: id ?? this.id,
      signedPreKeyId: signedPreKeyId ?? this.signedPreKeyId,
      record: record ?? this.record,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (signedPreKeyId.present) {
      map['signed_pre_key_id'] = Variable<int>(signedPreKeyId.value);
    }
    if (record.present) {
      map['record'] = Variable<Uint8List>(record.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignedPreKeysCompanion(')
          ..write('id: $id, ')
          ..write('signedPreKeyId: $signedPreKeyId, ')
          ..write('record: $record, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $KyberPreKeysTable extends KyberPreKeys
    with TableInfo<$KyberPreKeysTable, KyberPreKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KyberPreKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _kyberPreKeyIdMeta =
      const VerificationMeta('kyberPreKeyId');
  @override
  late final GeneratedColumn<int> kyberPreKeyId = GeneratedColumn<int>(
      'kyber_pre_key_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _recordMeta = const VerificationMeta('record');
  @override
  late final GeneratedColumn<Uint8List> record = GeneratedColumn<Uint8List>(
      'record', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _isUsedMeta = const VerificationMeta('isUsed');
  @override
  late final GeneratedColumn<bool> isUsed = GeneratedColumn<bool>(
      'is_used', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_used" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, kyberPreKeyId, record, isUsed, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kyber_pre_keys';
  @override
  VerificationContext validateIntegrity(Insertable<KyberPreKey> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kyber_pre_key_id')) {
      context.handle(
          _kyberPreKeyIdMeta,
          kyberPreKeyId.isAcceptableOrUnknown(
              data['kyber_pre_key_id']!, _kyberPreKeyIdMeta));
    } else if (isInserting) {
      context.missing(_kyberPreKeyIdMeta);
    }
    if (data.containsKey('record')) {
      context.handle(_recordMeta,
          record.isAcceptableOrUnknown(data['record']!, _recordMeta));
    } else if (isInserting) {
      context.missing(_recordMeta);
    }
    if (data.containsKey('is_used')) {
      context.handle(_isUsedMeta,
          isUsed.isAcceptableOrUnknown(data['is_used']!, _isUsedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KyberPreKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KyberPreKey(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kyberPreKeyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kyber_pre_key_id'])!,
      record: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}record'])!,
      isUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_used'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $KyberPreKeysTable createAlias(String alias) {
    return $KyberPreKeysTable(attachedDatabase, alias);
  }
}

class KyberPreKey extends DataClass implements Insertable<KyberPreKey> {
  final int id;
  final int kyberPreKeyId;
  final Uint8List record;
  final bool isUsed;
  final int createdAt;
  const KyberPreKey(
      {required this.id,
      required this.kyberPreKeyId,
      required this.record,
      required this.isUsed,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kyber_pre_key_id'] = Variable<int>(kyberPreKeyId);
    map['record'] = Variable<Uint8List>(record);
    map['is_used'] = Variable<bool>(isUsed);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  KyberPreKeysCompanion toCompanion(bool nullToAbsent) {
    return KyberPreKeysCompanion(
      id: Value(id),
      kyberPreKeyId: Value(kyberPreKeyId),
      record: Value(record),
      isUsed: Value(isUsed),
      createdAt: Value(createdAt),
    );
  }

  factory KyberPreKey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KyberPreKey(
      id: serializer.fromJson<int>(json['id']),
      kyberPreKeyId: serializer.fromJson<int>(json['kyberPreKeyId']),
      record: serializer.fromJson<Uint8List>(json['record']),
      isUsed: serializer.fromJson<bool>(json['isUsed']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kyberPreKeyId': serializer.toJson<int>(kyberPreKeyId),
      'record': serializer.toJson<Uint8List>(record),
      'isUsed': serializer.toJson<bool>(isUsed),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  KyberPreKey copyWith(
          {int? id,
          int? kyberPreKeyId,
          Uint8List? record,
          bool? isUsed,
          int? createdAt}) =>
      KyberPreKey(
        id: id ?? this.id,
        kyberPreKeyId: kyberPreKeyId ?? this.kyberPreKeyId,
        record: record ?? this.record,
        isUsed: isUsed ?? this.isUsed,
        createdAt: createdAt ?? this.createdAt,
      );
  KyberPreKey copyWithCompanion(KyberPreKeysCompanion data) {
    return KyberPreKey(
      id: data.id.present ? data.id.value : this.id,
      kyberPreKeyId: data.kyberPreKeyId.present
          ? data.kyberPreKeyId.value
          : this.kyberPreKeyId,
      record: data.record.present ? data.record.value : this.record,
      isUsed: data.isUsed.present ? data.isUsed.value : this.isUsed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KyberPreKey(')
          ..write('id: $id, ')
          ..write('kyberPreKeyId: $kyberPreKeyId, ')
          ..write('record: $record, ')
          ..write('isUsed: $isUsed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, kyberPreKeyId, $driftBlobEquality.hash(record), isUsed, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KyberPreKey &&
          other.id == this.id &&
          other.kyberPreKeyId == this.kyberPreKeyId &&
          $driftBlobEquality.equals(other.record, this.record) &&
          other.isUsed == this.isUsed &&
          other.createdAt == this.createdAt);
}

class KyberPreKeysCompanion extends UpdateCompanion<KyberPreKey> {
  final Value<int> id;
  final Value<int> kyberPreKeyId;
  final Value<Uint8List> record;
  final Value<bool> isUsed;
  final Value<int> createdAt;
  const KyberPreKeysCompanion({
    this.id = const Value.absent(),
    this.kyberPreKeyId = const Value.absent(),
    this.record = const Value.absent(),
    this.isUsed = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  KyberPreKeysCompanion.insert({
    this.id = const Value.absent(),
    required int kyberPreKeyId,
    required Uint8List record,
    this.isUsed = const Value.absent(),
    required int createdAt,
  })  : kyberPreKeyId = Value(kyberPreKeyId),
        record = Value(record),
        createdAt = Value(createdAt);
  static Insertable<KyberPreKey> custom({
    Expression<int>? id,
    Expression<int>? kyberPreKeyId,
    Expression<Uint8List>? record,
    Expression<bool>? isUsed,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kyberPreKeyId != null) 'kyber_pre_key_id': kyberPreKeyId,
      if (record != null) 'record': record,
      if (isUsed != null) 'is_used': isUsed,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  KyberPreKeysCompanion copyWith(
      {Value<int>? id,
      Value<int>? kyberPreKeyId,
      Value<Uint8List>? record,
      Value<bool>? isUsed,
      Value<int>? createdAt}) {
    return KyberPreKeysCompanion(
      id: id ?? this.id,
      kyberPreKeyId: kyberPreKeyId ?? this.kyberPreKeyId,
      record: record ?? this.record,
      isUsed: isUsed ?? this.isUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kyberPreKeyId.present) {
      map['kyber_pre_key_id'] = Variable<int>(kyberPreKeyId.value);
    }
    if (record.present) {
      map['record'] = Variable<Uint8List>(record.value);
    }
    if (isUsed.present) {
      map['is_used'] = Variable<bool>(isUsed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KyberPreKeysCompanion(')
          ..write('id: $id, ')
          ..write('kyberPreKeyId: $kyberPreKeyId, ')
          ..write('record: $record, ')
          ..write('isUsed: $isUsed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SkippedMessageKeysTable extends SkippedMessageKeys
    with TableInfo<$SkippedMessageKeysTable, SkippedMessageKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkippedMessageKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratchetKeyMeta =
      const VerificationMeta('ratchetKey');
  @override
  late final GeneratedColumn<Uint8List> ratchetKey = GeneratedColumn<Uint8List>(
      'ratchet_key', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _messageIndexMeta =
      const VerificationMeta('messageIndex');
  @override
  late final GeneratedColumn<int> messageIndex = GeneratedColumn<int>(
      'message_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _messageKeyMeta =
      const VerificationMeta('messageKey');
  @override
  late final GeneratedColumn<Uint8List> messageKey = GeneratedColumn<Uint8List>(
      'message_key', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _storedAtMeta =
      const VerificationMeta('storedAt');
  @override
  late final GeneratedColumn<int> storedAt = GeneratedColumn<int>(
      'stored_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, senderId, ratchetKey, messageIndex, messageKey, storedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skipped_message_keys';
  @override
  VerificationContext validateIntegrity(Insertable<SkippedMessageKey> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('ratchet_key')) {
      context.handle(
          _ratchetKeyMeta,
          ratchetKey.isAcceptableOrUnknown(
              data['ratchet_key']!, _ratchetKeyMeta));
    } else if (isInserting) {
      context.missing(_ratchetKeyMeta);
    }
    if (data.containsKey('message_index')) {
      context.handle(
          _messageIndexMeta,
          messageIndex.isAcceptableOrUnknown(
              data['message_index']!, _messageIndexMeta));
    } else if (isInserting) {
      context.missing(_messageIndexMeta);
    }
    if (data.containsKey('message_key')) {
      context.handle(
          _messageKeyMeta,
          messageKey.isAcceptableOrUnknown(
              data['message_key']!, _messageKeyMeta));
    } else if (isInserting) {
      context.missing(_messageKeyMeta);
    }
    if (data.containsKey('stored_at')) {
      context.handle(_storedAtMeta,
          storedAt.isAcceptableOrUnknown(data['stored_at']!, _storedAtMeta));
    } else if (isInserting) {
      context.missing(_storedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {senderId, ratchetKey, messageIndex},
      ];
  @override
  SkippedMessageKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkippedMessageKey(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      ratchetKey: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}ratchet_key'])!,
      messageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_index'])!,
      messageKey: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}message_key'])!,
      storedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stored_at'])!,
    );
  }

  @override
  $SkippedMessageKeysTable createAlias(String alias) {
    return $SkippedMessageKeysTable(attachedDatabase, alias);
  }
}

class SkippedMessageKey extends DataClass
    implements Insertable<SkippedMessageKey> {
  final int id;
  final String senderId;
  final Uint8List ratchetKey;
  final int messageIndex;
  final Uint8List messageKey;
  final int storedAt;
  const SkippedMessageKey(
      {required this.id,
      required this.senderId,
      required this.ratchetKey,
      required this.messageIndex,
      required this.messageKey,
      required this.storedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sender_id'] = Variable<String>(senderId);
    map['ratchet_key'] = Variable<Uint8List>(ratchetKey);
    map['message_index'] = Variable<int>(messageIndex);
    map['message_key'] = Variable<Uint8List>(messageKey);
    map['stored_at'] = Variable<int>(storedAt);
    return map;
  }

  SkippedMessageKeysCompanion toCompanion(bool nullToAbsent) {
    return SkippedMessageKeysCompanion(
      id: Value(id),
      senderId: Value(senderId),
      ratchetKey: Value(ratchetKey),
      messageIndex: Value(messageIndex),
      messageKey: Value(messageKey),
      storedAt: Value(storedAt),
    );
  }

  factory SkippedMessageKey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkippedMessageKey(
      id: serializer.fromJson<int>(json['id']),
      senderId: serializer.fromJson<String>(json['senderId']),
      ratchetKey: serializer.fromJson<Uint8List>(json['ratchetKey']),
      messageIndex: serializer.fromJson<int>(json['messageIndex']),
      messageKey: serializer.fromJson<Uint8List>(json['messageKey']),
      storedAt: serializer.fromJson<int>(json['storedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'senderId': serializer.toJson<String>(senderId),
      'ratchetKey': serializer.toJson<Uint8List>(ratchetKey),
      'messageIndex': serializer.toJson<int>(messageIndex),
      'messageKey': serializer.toJson<Uint8List>(messageKey),
      'storedAt': serializer.toJson<int>(storedAt),
    };
  }

  SkippedMessageKey copyWith(
          {int? id,
          String? senderId,
          Uint8List? ratchetKey,
          int? messageIndex,
          Uint8List? messageKey,
          int? storedAt}) =>
      SkippedMessageKey(
        id: id ?? this.id,
        senderId: senderId ?? this.senderId,
        ratchetKey: ratchetKey ?? this.ratchetKey,
        messageIndex: messageIndex ?? this.messageIndex,
        messageKey: messageKey ?? this.messageKey,
        storedAt: storedAt ?? this.storedAt,
      );
  SkippedMessageKey copyWithCompanion(SkippedMessageKeysCompanion data) {
    return SkippedMessageKey(
      id: data.id.present ? data.id.value : this.id,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      ratchetKey:
          data.ratchetKey.present ? data.ratchetKey.value : this.ratchetKey,
      messageIndex: data.messageIndex.present
          ? data.messageIndex.value
          : this.messageIndex,
      messageKey:
          data.messageKey.present ? data.messageKey.value : this.messageKey,
      storedAt: data.storedAt.present ? data.storedAt.value : this.storedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkippedMessageKey(')
          ..write('id: $id, ')
          ..write('senderId: $senderId, ')
          ..write('ratchetKey: $ratchetKey, ')
          ..write('messageIndex: $messageIndex, ')
          ..write('messageKey: $messageKey, ')
          ..write('storedAt: $storedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      senderId,
      $driftBlobEquality.hash(ratchetKey),
      messageIndex,
      $driftBlobEquality.hash(messageKey),
      storedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkippedMessageKey &&
          other.id == this.id &&
          other.senderId == this.senderId &&
          $driftBlobEquality.equals(other.ratchetKey, this.ratchetKey) &&
          other.messageIndex == this.messageIndex &&
          $driftBlobEquality.equals(other.messageKey, this.messageKey) &&
          other.storedAt == this.storedAt);
}

class SkippedMessageKeysCompanion extends UpdateCompanion<SkippedMessageKey> {
  final Value<int> id;
  final Value<String> senderId;
  final Value<Uint8List> ratchetKey;
  final Value<int> messageIndex;
  final Value<Uint8List> messageKey;
  final Value<int> storedAt;
  const SkippedMessageKeysCompanion({
    this.id = const Value.absent(),
    this.senderId = const Value.absent(),
    this.ratchetKey = const Value.absent(),
    this.messageIndex = const Value.absent(),
    this.messageKey = const Value.absent(),
    this.storedAt = const Value.absent(),
  });
  SkippedMessageKeysCompanion.insert({
    this.id = const Value.absent(),
    required String senderId,
    required Uint8List ratchetKey,
    required int messageIndex,
    required Uint8List messageKey,
    required int storedAt,
  })  : senderId = Value(senderId),
        ratchetKey = Value(ratchetKey),
        messageIndex = Value(messageIndex),
        messageKey = Value(messageKey),
        storedAt = Value(storedAt);
  static Insertable<SkippedMessageKey> custom({
    Expression<int>? id,
    Expression<String>? senderId,
    Expression<Uint8List>? ratchetKey,
    Expression<int>? messageIndex,
    Expression<Uint8List>? messageKey,
    Expression<int>? storedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (senderId != null) 'sender_id': senderId,
      if (ratchetKey != null) 'ratchet_key': ratchetKey,
      if (messageIndex != null) 'message_index': messageIndex,
      if (messageKey != null) 'message_key': messageKey,
      if (storedAt != null) 'stored_at': storedAt,
    });
  }

  SkippedMessageKeysCompanion copyWith(
      {Value<int>? id,
      Value<String>? senderId,
      Value<Uint8List>? ratchetKey,
      Value<int>? messageIndex,
      Value<Uint8List>? messageKey,
      Value<int>? storedAt}) {
    return SkippedMessageKeysCompanion(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      ratchetKey: ratchetKey ?? this.ratchetKey,
      messageIndex: messageIndex ?? this.messageIndex,
      messageKey: messageKey ?? this.messageKey,
      storedAt: storedAt ?? this.storedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (ratchetKey.present) {
      map['ratchet_key'] = Variable<Uint8List>(ratchetKey.value);
    }
    if (messageIndex.present) {
      map['message_index'] = Variable<int>(messageIndex.value);
    }
    if (messageKey.present) {
      map['message_key'] = Variable<Uint8List>(messageKey.value);
    }
    if (storedAt.present) {
      map['stored_at'] = Variable<int>(storedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkippedMessageKeysCompanion(')
          ..write('id: $id, ')
          ..write('senderId: $senderId, ')
          ..write('ratchetKey: $ratchetKey, ')
          ..write('messageIndex: $messageIndex, ')
          ..write('messageKey: $messageKey, ')
          ..write('storedAt: $storedAt')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiverIdMeta =
      const VerificationMeta('receiverId');
  @override
  late final GeneratedColumn<String> receiverId = GeneratedColumn<String>(
      'receiver_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plaintextMeta =
      const VerificationMeta('plaintext');
  @override
  late final GeneratedColumn<String> plaintext = GeneratedColumn<String>(
      'plaintext', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ciphertextMeta =
      const VerificationMeta('ciphertext');
  @override
  late final GeneratedColumn<String> ciphertext = GeneratedColumn<String>(
      'ciphertext', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _otherUserIdMeta =
      const VerificationMeta('otherUserId');
  @override
  late final GeneratedColumn<String> otherUserId = GeneratedColumn<String>(
      'other_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        messageId,
        conversationId,
        senderId,
        receiverId,
        plaintext,
        ciphertext,
        type,
        otherUserId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('receiver_id')) {
      context.handle(
          _receiverIdMeta,
          receiverId.isAcceptableOrUnknown(
              data['receiver_id']!, _receiverIdMeta));
    } else if (isInserting) {
      context.missing(_receiverIdMeta);
    }
    if (data.containsKey('plaintext')) {
      context.handle(_plaintextMeta,
          plaintext.isAcceptableOrUnknown(data['plaintext']!, _plaintextMeta));
    } else if (isInserting) {
      context.missing(_plaintextMeta);
    }
    if (data.containsKey('ciphertext')) {
      context.handle(
          _ciphertextMeta,
          ciphertext.isAcceptableOrUnknown(
              data['ciphertext']!, _ciphertextMeta));
    } else if (isInserting) {
      context.missing(_ciphertextMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('other_user_id')) {
      context.handle(
          _otherUserIdMeta,
          otherUserId.isAcceptableOrUnknown(
              data['other_user_id']!, _otherUserIdMeta));
    } else if (isInserting) {
      context.missing(_otherUserIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      receiverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_id'])!,
      plaintext: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plaintext'])!,
      ciphertext: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ciphertext'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      otherUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}other_user_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final String messageId;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String plaintext;
  final String ciphertext;
  final String type;
  final String otherUserId;
  final int createdAt;
  const ChatMessage(
      {required this.id,
      required this.messageId,
      required this.conversationId,
      required this.senderId,
      required this.receiverId,
      required this.plaintext,
      required this.ciphertext,
      required this.type,
      required this.otherUserId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_id'] = Variable<String>(senderId);
    map['receiver_id'] = Variable<String>(receiverId);
    map['plaintext'] = Variable<String>(plaintext);
    map['ciphertext'] = Variable<String>(ciphertext);
    map['type'] = Variable<String>(type);
    map['other_user_id'] = Variable<String>(otherUserId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      messageId: Value(messageId),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      receiverId: Value(receiverId),
      plaintext: Value(plaintext),
      ciphertext: Value(ciphertext),
      type: Value(type),
      otherUserId: Value(otherUserId),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      receiverId: serializer.fromJson<String>(json['receiverId']),
      plaintext: serializer.fromJson<String>(json['plaintext']),
      ciphertext: serializer.fromJson<String>(json['ciphertext']),
      type: serializer.fromJson<String>(json['type']),
      otherUserId: serializer.fromJson<String>(json['otherUserId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderId': serializer.toJson<String>(senderId),
      'receiverId': serializer.toJson<String>(receiverId),
      'plaintext': serializer.toJson<String>(plaintext),
      'ciphertext': serializer.toJson<String>(ciphertext),
      'type': serializer.toJson<String>(type),
      'otherUserId': serializer.toJson<String>(otherUserId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ChatMessage copyWith(
          {int? id,
          String? messageId,
          String? conversationId,
          String? senderId,
          String? receiverId,
          String? plaintext,
          String? ciphertext,
          String? type,
          String? otherUserId,
          int? createdAt}) =>
      ChatMessage(
        id: id ?? this.id,
        messageId: messageId ?? this.messageId,
        conversationId: conversationId ?? this.conversationId,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        plaintext: plaintext ?? this.plaintext,
        ciphertext: ciphertext ?? this.ciphertext,
        type: type ?? this.type,
        otherUserId: otherUserId ?? this.otherUserId,
        createdAt: createdAt ?? this.createdAt,
      );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      receiverId:
          data.receiverId.present ? data.receiverId.value : this.receiverId,
      plaintext: data.plaintext.present ? data.plaintext.value : this.plaintext,
      ciphertext:
          data.ciphertext.present ? data.ciphertext.value : this.ciphertext,
      type: data.type.present ? data.type.value : this.type,
      otherUserId:
          data.otherUserId.present ? data.otherUserId.value : this.otherUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('plaintext: $plaintext, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('type: $type, ')
          ..write('otherUserId: $otherUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, messageId, conversationId, senderId,
      receiverId, plaintext, ciphertext, type, otherUserId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.conversationId == this.conversationId &&
          other.senderId == this.senderId &&
          other.receiverId == this.receiverId &&
          other.plaintext == this.plaintext &&
          other.ciphertext == this.ciphertext &&
          other.type == this.type &&
          other.otherUserId == this.otherUserId &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> conversationId;
  final Value<String> senderId;
  final Value<String> receiverId;
  final Value<String> plaintext;
  final Value<String> ciphertext;
  final Value<String> type;
  final Value<String> otherUserId;
  final Value<int> createdAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.receiverId = const Value.absent(),
    this.plaintext = const Value.absent(),
    this.ciphertext = const Value.absent(),
    this.type = const Value.absent(),
    this.otherUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String plaintext,
    required String ciphertext,
    required String type,
    required String otherUserId,
    required int createdAt,
  })  : messageId = Value(messageId),
        conversationId = Value(conversationId),
        senderId = Value(senderId),
        receiverId = Value(receiverId),
        plaintext = Value(plaintext),
        ciphertext = Value(ciphertext),
        type = Value(type),
        otherUserId = Value(otherUserId),
        createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? conversationId,
    Expression<String>? senderId,
    Expression<String>? receiverId,
    Expression<String>? plaintext,
    Expression<String>? ciphertext,
    Expression<String>? type,
    Expression<String>? otherUserId,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderId != null) 'sender_id': senderId,
      if (receiverId != null) 'receiver_id': receiverId,
      if (plaintext != null) 'plaintext': plaintext,
      if (ciphertext != null) 'ciphertext': ciphertext,
      if (type != null) 'type': type,
      if (otherUserId != null) 'other_user_id': otherUserId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? messageId,
      Value<String>? conversationId,
      Value<String>? senderId,
      Value<String>? receiverId,
      Value<String>? plaintext,
      Value<String>? ciphertext,
      Value<String>? type,
      Value<String>? otherUserId,
      Value<int>? createdAt}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      plaintext: plaintext ?? this.plaintext,
      ciphertext: ciphertext ?? this.ciphertext,
      type: type ?? this.type,
      otherUserId: otherUserId ?? this.otherUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (receiverId.present) {
      map['receiver_id'] = Variable<String>(receiverId.value);
    }
    if (plaintext.present) {
      map['plaintext'] = Variable<String>(plaintext.value);
    }
    if (ciphertext.present) {
      map['ciphertext'] = Variable<String>(ciphertext.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (otherUserId.present) {
      map['other_user_id'] = Variable<String>(otherUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('plaintext: $plaintext, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('type: $type, ')
          ..write('otherUserId: $otherUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $IdentityKeysTable identityKeys = $IdentityKeysTable(this);
  late final $PreKeysTable preKeys = $PreKeysTable(this);
  late final $SignedPreKeysTable signedPreKeys = $SignedPreKeysTable(this);
  late final $KyberPreKeysTable kyberPreKeys = $KyberPreKeysTable(this);
  late final $SkippedMessageKeysTable skippedMessageKeys =
      $SkippedMessageKeysTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        sessions,
        identityKeys,
        preKeys,
        signedPreKeys,
        kyberPreKeys,
        skippedMessageKeys,
        chatMessages
      ];
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required String addressName,
  required int deviceId,
  required Uint8List record,
  required int createdAt,
  required int lastUpdated,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<String> addressName,
  Value<int> deviceId,
  Value<Uint8List> record,
  Value<int> createdAt,
  Value<int> lastUpdated,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addressName => $composableBuilder(
      column: $table.addressName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get record => $composableBuilder(
      column: $table.record, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addressName => $composableBuilder(
      column: $table.addressName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get record => $composableBuilder(
      column: $table.record, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get addressName => $composableBuilder(
      column: $table.addressName, builder: (column) => column);

  GeneratedColumn<int> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<Uint8List> get record =>
      $composableBuilder(column: $table.record, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> addressName = const Value.absent(),
            Value<int> deviceId = const Value.absent(),
            Value<Uint8List> record = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> lastUpdated = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            addressName: addressName,
            deviceId: deviceId,
            record: record,
            createdAt: createdAt,
            lastUpdated: lastUpdated,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String addressName,
            required int deviceId,
            required Uint8List record,
            required int createdAt,
            required int lastUpdated,
          }) =>
              SessionsCompanion.insert(
            id: id,
            addressName: addressName,
            deviceId: deviceId,
            record: record,
            createdAt: createdAt,
            lastUpdated: lastUpdated,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()>;
typedef $$IdentityKeysTableCreateCompanionBuilder = IdentityKeysCompanion
    Function({
  Value<int> id,
  required String addressName,
  required int deviceId,
  required Uint8List identityKey,
  required int createdAt,
});
typedef $$IdentityKeysTableUpdateCompanionBuilder = IdentityKeysCompanion
    Function({
  Value<int> id,
  Value<String> addressName,
  Value<int> deviceId,
  Value<Uint8List> identityKey,
  Value<int> createdAt,
});

class $$IdentityKeysTableFilterComposer
    extends Composer<_$AppDatabase, $IdentityKeysTable> {
  $$IdentityKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addressName => $composableBuilder(
      column: $table.addressName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get identityKey => $composableBuilder(
      column: $table.identityKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$IdentityKeysTableOrderingComposer
    extends Composer<_$AppDatabase, $IdentityKeysTable> {
  $$IdentityKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addressName => $composableBuilder(
      column: $table.addressName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get identityKey => $composableBuilder(
      column: $table.identityKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$IdentityKeysTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdentityKeysTable> {
  $$IdentityKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get addressName => $composableBuilder(
      column: $table.addressName, builder: (column) => column);

  GeneratedColumn<int> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<Uint8List> get identityKey => $composableBuilder(
      column: $table.identityKey, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IdentityKeysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IdentityKeysTable,
    IdentityKey,
    $$IdentityKeysTableFilterComposer,
    $$IdentityKeysTableOrderingComposer,
    $$IdentityKeysTableAnnotationComposer,
    $$IdentityKeysTableCreateCompanionBuilder,
    $$IdentityKeysTableUpdateCompanionBuilder,
    (
      IdentityKey,
      BaseReferences<_$AppDatabase, $IdentityKeysTable, IdentityKey>
    ),
    IdentityKey,
    PrefetchHooks Function()> {
  $$IdentityKeysTableTableManager(_$AppDatabase db, $IdentityKeysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdentityKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdentityKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdentityKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> addressName = const Value.absent(),
            Value<int> deviceId = const Value.absent(),
            Value<Uint8List> identityKey = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              IdentityKeysCompanion(
            id: id,
            addressName: addressName,
            deviceId: deviceId,
            identityKey: identityKey,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String addressName,
            required int deviceId,
            required Uint8List identityKey,
            required int createdAt,
          }) =>
              IdentityKeysCompanion.insert(
            id: id,
            addressName: addressName,
            deviceId: deviceId,
            identityKey: identityKey,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IdentityKeysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IdentityKeysTable,
    IdentityKey,
    $$IdentityKeysTableFilterComposer,
    $$IdentityKeysTableOrderingComposer,
    $$IdentityKeysTableAnnotationComposer,
    $$IdentityKeysTableCreateCompanionBuilder,
    $$IdentityKeysTableUpdateCompanionBuilder,
    (
      IdentityKey,
      BaseReferences<_$AppDatabase, $IdentityKeysTable, IdentityKey>
    ),
    IdentityKey,
    PrefetchHooks Function()>;
typedef $$PreKeysTableCreateCompanionBuilder = PreKeysCompanion Function({
  Value<int> id,
  required int preKeyId,
  required Uint8List record,
  required int createdAt,
});
typedef $$PreKeysTableUpdateCompanionBuilder = PreKeysCompanion Function({
  Value<int> id,
  Value<int> preKeyId,
  Value<Uint8List> record,
  Value<int> createdAt,
});

class $$PreKeysTableFilterComposer
    extends Composer<_$AppDatabase, $PreKeysTable> {
  $$PreKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get preKeyId => $composableBuilder(
      column: $table.preKeyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get record => $composableBuilder(
      column: $table.record, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PreKeysTableOrderingComposer
    extends Composer<_$AppDatabase, $PreKeysTable> {
  $$PreKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get preKeyId => $composableBuilder(
      column: $table.preKeyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get record => $composableBuilder(
      column: $table.record, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PreKeysTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreKeysTable> {
  $$PreKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get preKeyId =>
      $composableBuilder(column: $table.preKeyId, builder: (column) => column);

  GeneratedColumn<Uint8List> get record =>
      $composableBuilder(column: $table.record, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PreKeysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PreKeysTable,
    PreKey,
    $$PreKeysTableFilterComposer,
    $$PreKeysTableOrderingComposer,
    $$PreKeysTableAnnotationComposer,
    $$PreKeysTableCreateCompanionBuilder,
    $$PreKeysTableUpdateCompanionBuilder,
    (PreKey, BaseReferences<_$AppDatabase, $PreKeysTable, PreKey>),
    PreKey,
    PrefetchHooks Function()> {
  $$PreKeysTableTableManager(_$AppDatabase db, $PreKeysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> preKeyId = const Value.absent(),
            Value<Uint8List> record = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              PreKeysCompanion(
            id: id,
            preKeyId: preKeyId,
            record: record,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int preKeyId,
            required Uint8List record,
            required int createdAt,
          }) =>
              PreKeysCompanion.insert(
            id: id,
            preKeyId: preKeyId,
            record: record,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PreKeysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PreKeysTable,
    PreKey,
    $$PreKeysTableFilterComposer,
    $$PreKeysTableOrderingComposer,
    $$PreKeysTableAnnotationComposer,
    $$PreKeysTableCreateCompanionBuilder,
    $$PreKeysTableUpdateCompanionBuilder,
    (PreKey, BaseReferences<_$AppDatabase, $PreKeysTable, PreKey>),
    PreKey,
    PrefetchHooks Function()>;
typedef $$SignedPreKeysTableCreateCompanionBuilder = SignedPreKeysCompanion
    Function({
  Value<int> id,
  required int signedPreKeyId,
  required Uint8List record,
  required int createdAt,
});
typedef $$SignedPreKeysTableUpdateCompanionBuilder = SignedPreKeysCompanion
    Function({
  Value<int> id,
  Value<int> signedPreKeyId,
  Value<Uint8List> record,
  Value<int> createdAt,
});

class $$SignedPreKeysTableFilterComposer
    extends Composer<_$AppDatabase, $SignedPreKeysTable> {
  $$SignedPreKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get signedPreKeyId => $composableBuilder(
      column: $table.signedPreKeyId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get record => $composableBuilder(
      column: $table.record, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SignedPreKeysTableOrderingComposer
    extends Composer<_$AppDatabase, $SignedPreKeysTable> {
  $$SignedPreKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get signedPreKeyId => $composableBuilder(
      column: $table.signedPreKeyId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get record => $composableBuilder(
      column: $table.record, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SignedPreKeysTableAnnotationComposer
    extends Composer<_$AppDatabase, $SignedPreKeysTable> {
  $$SignedPreKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get signedPreKeyId => $composableBuilder(
      column: $table.signedPreKeyId, builder: (column) => column);

  GeneratedColumn<Uint8List> get record =>
      $composableBuilder(column: $table.record, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SignedPreKeysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SignedPreKeysTable,
    SignedPreKey,
    $$SignedPreKeysTableFilterComposer,
    $$SignedPreKeysTableOrderingComposer,
    $$SignedPreKeysTableAnnotationComposer,
    $$SignedPreKeysTableCreateCompanionBuilder,
    $$SignedPreKeysTableUpdateCompanionBuilder,
    (
      SignedPreKey,
      BaseReferences<_$AppDatabase, $SignedPreKeysTable, SignedPreKey>
    ),
    SignedPreKey,
    PrefetchHooks Function()> {
  $$SignedPreKeysTableTableManager(_$AppDatabase db, $SignedPreKeysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignedPreKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignedPreKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignedPreKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> signedPreKeyId = const Value.absent(),
            Value<Uint8List> record = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              SignedPreKeysCompanion(
            id: id,
            signedPreKeyId: signedPreKeyId,
            record: record,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int signedPreKeyId,
            required Uint8List record,
            required int createdAt,
          }) =>
              SignedPreKeysCompanion.insert(
            id: id,
            signedPreKeyId: signedPreKeyId,
            record: record,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SignedPreKeysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SignedPreKeysTable,
    SignedPreKey,
    $$SignedPreKeysTableFilterComposer,
    $$SignedPreKeysTableOrderingComposer,
    $$SignedPreKeysTableAnnotationComposer,
    $$SignedPreKeysTableCreateCompanionBuilder,
    $$SignedPreKeysTableUpdateCompanionBuilder,
    (
      SignedPreKey,
      BaseReferences<_$AppDatabase, $SignedPreKeysTable, SignedPreKey>
    ),
    SignedPreKey,
    PrefetchHooks Function()>;
typedef $$KyberPreKeysTableCreateCompanionBuilder = KyberPreKeysCompanion
    Function({
  Value<int> id,
  required int kyberPreKeyId,
  required Uint8List record,
  Value<bool> isUsed,
  required int createdAt,
});
typedef $$KyberPreKeysTableUpdateCompanionBuilder = KyberPreKeysCompanion
    Function({
  Value<int> id,
  Value<int> kyberPreKeyId,
  Value<Uint8List> record,
  Value<bool> isUsed,
  Value<int> createdAt,
});

class $$KyberPreKeysTableFilterComposer
    extends Composer<_$AppDatabase, $KyberPreKeysTable> {
  $$KyberPreKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kyberPreKeyId => $composableBuilder(
      column: $table.kyberPreKeyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get record => $composableBuilder(
      column: $table.record, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUsed => $composableBuilder(
      column: $table.isUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$KyberPreKeysTableOrderingComposer
    extends Composer<_$AppDatabase, $KyberPreKeysTable> {
  $$KyberPreKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kyberPreKeyId => $composableBuilder(
      column: $table.kyberPreKeyId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get record => $composableBuilder(
      column: $table.record, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUsed => $composableBuilder(
      column: $table.isUsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$KyberPreKeysTableAnnotationComposer
    extends Composer<_$AppDatabase, $KyberPreKeysTable> {
  $$KyberPreKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kyberPreKeyId => $composableBuilder(
      column: $table.kyberPreKeyId, builder: (column) => column);

  GeneratedColumn<Uint8List> get record =>
      $composableBuilder(column: $table.record, builder: (column) => column);

  GeneratedColumn<bool> get isUsed =>
      $composableBuilder(column: $table.isUsed, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$KyberPreKeysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KyberPreKeysTable,
    KyberPreKey,
    $$KyberPreKeysTableFilterComposer,
    $$KyberPreKeysTableOrderingComposer,
    $$KyberPreKeysTableAnnotationComposer,
    $$KyberPreKeysTableCreateCompanionBuilder,
    $$KyberPreKeysTableUpdateCompanionBuilder,
    (
      KyberPreKey,
      BaseReferences<_$AppDatabase, $KyberPreKeysTable, KyberPreKey>
    ),
    KyberPreKey,
    PrefetchHooks Function()> {
  $$KyberPreKeysTableTableManager(_$AppDatabase db, $KyberPreKeysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KyberPreKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KyberPreKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KyberPreKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> kyberPreKeyId = const Value.absent(),
            Value<Uint8List> record = const Value.absent(),
            Value<bool> isUsed = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              KyberPreKeysCompanion(
            id: id,
            kyberPreKeyId: kyberPreKeyId,
            record: record,
            isUsed: isUsed,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int kyberPreKeyId,
            required Uint8List record,
            Value<bool> isUsed = const Value.absent(),
            required int createdAt,
          }) =>
              KyberPreKeysCompanion.insert(
            id: id,
            kyberPreKeyId: kyberPreKeyId,
            record: record,
            isUsed: isUsed,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$KyberPreKeysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KyberPreKeysTable,
    KyberPreKey,
    $$KyberPreKeysTableFilterComposer,
    $$KyberPreKeysTableOrderingComposer,
    $$KyberPreKeysTableAnnotationComposer,
    $$KyberPreKeysTableCreateCompanionBuilder,
    $$KyberPreKeysTableUpdateCompanionBuilder,
    (
      KyberPreKey,
      BaseReferences<_$AppDatabase, $KyberPreKeysTable, KyberPreKey>
    ),
    KyberPreKey,
    PrefetchHooks Function()>;
typedef $$SkippedMessageKeysTableCreateCompanionBuilder
    = SkippedMessageKeysCompanion Function({
  Value<int> id,
  required String senderId,
  required Uint8List ratchetKey,
  required int messageIndex,
  required Uint8List messageKey,
  required int storedAt,
});
typedef $$SkippedMessageKeysTableUpdateCompanionBuilder
    = SkippedMessageKeysCompanion Function({
  Value<int> id,
  Value<String> senderId,
  Value<Uint8List> ratchetKey,
  Value<int> messageIndex,
  Value<Uint8List> messageKey,
  Value<int> storedAt,
});

class $$SkippedMessageKeysTableFilterComposer
    extends Composer<_$AppDatabase, $SkippedMessageKeysTable> {
  $$SkippedMessageKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get ratchetKey => $composableBuilder(
      column: $table.ratchetKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get messageIndex => $composableBuilder(
      column: $table.messageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get messageKey => $composableBuilder(
      column: $table.messageKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get storedAt => $composableBuilder(
      column: $table.storedAt, builder: (column) => ColumnFilters(column));
}

class $$SkippedMessageKeysTableOrderingComposer
    extends Composer<_$AppDatabase, $SkippedMessageKeysTable> {
  $$SkippedMessageKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get ratchetKey => $composableBuilder(
      column: $table.ratchetKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get messageIndex => $composableBuilder(
      column: $table.messageIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get messageKey => $composableBuilder(
      column: $table.messageKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get storedAt => $composableBuilder(
      column: $table.storedAt, builder: (column) => ColumnOrderings(column));
}

class $$SkippedMessageKeysTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkippedMessageKeysTable> {
  $$SkippedMessageKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<Uint8List> get ratchetKey => $composableBuilder(
      column: $table.ratchetKey, builder: (column) => column);

  GeneratedColumn<int> get messageIndex => $composableBuilder(
      column: $table.messageIndex, builder: (column) => column);

  GeneratedColumn<Uint8List> get messageKey => $composableBuilder(
      column: $table.messageKey, builder: (column) => column);

  GeneratedColumn<int> get storedAt =>
      $composableBuilder(column: $table.storedAt, builder: (column) => column);
}

class $$SkippedMessageKeysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SkippedMessageKeysTable,
    SkippedMessageKey,
    $$SkippedMessageKeysTableFilterComposer,
    $$SkippedMessageKeysTableOrderingComposer,
    $$SkippedMessageKeysTableAnnotationComposer,
    $$SkippedMessageKeysTableCreateCompanionBuilder,
    $$SkippedMessageKeysTableUpdateCompanionBuilder,
    (
      SkippedMessageKey,
      BaseReferences<_$AppDatabase, $SkippedMessageKeysTable, SkippedMessageKey>
    ),
    SkippedMessageKey,
    PrefetchHooks Function()> {
  $$SkippedMessageKeysTableTableManager(
      _$AppDatabase db, $SkippedMessageKeysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkippedMessageKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkippedMessageKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkippedMessageKeysTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<Uint8List> ratchetKey = const Value.absent(),
            Value<int> messageIndex = const Value.absent(),
            Value<Uint8List> messageKey = const Value.absent(),
            Value<int> storedAt = const Value.absent(),
          }) =>
              SkippedMessageKeysCompanion(
            id: id,
            senderId: senderId,
            ratchetKey: ratchetKey,
            messageIndex: messageIndex,
            messageKey: messageKey,
            storedAt: storedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String senderId,
            required Uint8List ratchetKey,
            required int messageIndex,
            required Uint8List messageKey,
            required int storedAt,
          }) =>
              SkippedMessageKeysCompanion.insert(
            id: id,
            senderId: senderId,
            ratchetKey: ratchetKey,
            messageIndex: messageIndex,
            messageKey: messageKey,
            storedAt: storedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SkippedMessageKeysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SkippedMessageKeysTable,
    SkippedMessageKey,
    $$SkippedMessageKeysTableFilterComposer,
    $$SkippedMessageKeysTableOrderingComposer,
    $$SkippedMessageKeysTableAnnotationComposer,
    $$SkippedMessageKeysTableCreateCompanionBuilder,
    $$SkippedMessageKeysTableUpdateCompanionBuilder,
    (
      SkippedMessageKey,
      BaseReferences<_$AppDatabase, $SkippedMessageKeysTable, SkippedMessageKey>
    ),
    SkippedMessageKey,
    PrefetchHooks Function()>;
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  required String messageId,
  required String conversationId,
  required String senderId,
  required String receiverId,
  required String plaintext,
  required String ciphertext,
  required String type,
  required String otherUserId,
  required int createdAt,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  Value<String> messageId,
  Value<String> conversationId,
  Value<String> senderId,
  Value<String> receiverId,
  Value<String> plaintext,
  Value<String> ciphertext,
  Value<String> type,
  Value<String> otherUserId,
  Value<int> createdAt,
});

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverId => $composableBuilder(
      column: $table.receiverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plaintext => $composableBuilder(
      column: $table.plaintext, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ciphertext => $composableBuilder(
      column: $table.ciphertext, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get otherUserId => $composableBuilder(
      column: $table.otherUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverId => $composableBuilder(
      column: $table.receiverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plaintext => $composableBuilder(
      column: $table.plaintext, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ciphertext => $composableBuilder(
      column: $table.ciphertext, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get otherUserId => $composableBuilder(
      column: $table.otherUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get receiverId => $composableBuilder(
      column: $table.receiverId, builder: (column) => column);

  GeneratedColumn<String> get plaintext =>
      $composableBuilder(column: $table.plaintext, builder: (column) => column);

  GeneratedColumn<String> get ciphertext => $composableBuilder(
      column: $table.ciphertext, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get otherUserId => $composableBuilder(
      column: $table.otherUserId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessage,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessage,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>
    ),
    ChatMessage,
    PrefetchHooks Function()> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> messageId = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<String> receiverId = const Value.absent(),
            Value<String> plaintext = const Value.absent(),
            Value<String> ciphertext = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> otherUserId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            messageId: messageId,
            conversationId: conversationId,
            senderId: senderId,
            receiverId: receiverId,
            plaintext: plaintext,
            ciphertext: ciphertext,
            type: type,
            otherUserId: otherUserId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String messageId,
            required String conversationId,
            required String senderId,
            required String receiverId,
            required String plaintext,
            required String ciphertext,
            required String type,
            required String otherUserId,
            required int createdAt,
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            messageId: messageId,
            conversationId: conversationId,
            senderId: senderId,
            receiverId: receiverId,
            plaintext: plaintext,
            ciphertext: ciphertext,
            type: type,
            otherUserId: otherUserId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessage,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessage,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>
    ),
    ChatMessage,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$IdentityKeysTableTableManager get identityKeys =>
      $$IdentityKeysTableTableManager(_db, _db.identityKeys);
  $$PreKeysTableTableManager get preKeys =>
      $$PreKeysTableTableManager(_db, _db.preKeys);
  $$SignedPreKeysTableTableManager get signedPreKeys =>
      $$SignedPreKeysTableTableManager(_db, _db.signedPreKeys);
  $$KyberPreKeysTableTableManager get kyberPreKeys =>
      $$KyberPreKeysTableTableManager(_db, _db.kyberPreKeys);
  $$SkippedMessageKeysTableTableManager get skippedMessageKeys =>
      $$SkippedMessageKeysTableTableManager(_db, _db.skippedMessageKeys);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
}
