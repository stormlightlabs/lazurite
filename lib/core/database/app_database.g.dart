// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<String> did = GeneratedColumn<String>(
    'did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handleMeta = const VerificationMeta('handle');
  @override
  late final GeneratedColumn<String> handle = GeneratedColumn<String>(
    'handle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accessTokenMeta = const VerificationMeta(
    'accessToken',
  );
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
    'access_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refreshTokenMeta = const VerificationMeta(
    'refreshToken',
  );
  @override
  late final GeneratedColumn<String> refreshToken = GeneratedColumn<String>(
    'refresh_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dpopPublicKeyMeta = const VerificationMeta(
    'dpopPublicKey',
  );
  @override
  late final GeneratedColumn<String> dpopPublicKey = GeneratedColumn<String>(
    'dpop_public_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dpopPrivateKeyMeta = const VerificationMeta(
    'dpopPrivateKey',
  );
  @override
  late final GeneratedColumn<String> dpopPrivateKey = GeneratedColumn<String>(
    'dpop_private_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dpopNonceMeta = const VerificationMeta(
    'dpopNonce',
  );
  @override
  late final GeneratedColumn<String> dpopNonce = GeneratedColumn<String>(
    'dpop_nonce',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    did,
    handle,
    displayName,
    service,
    accessToken,
    refreshToken,
    dpopPublicKey,
    dpopPrivateKey,
    dpopNonce,
    expiresAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('did')) {
      context.handle(
        _didMeta,
        did.isAcceptableOrUnknown(data['did']!, _didMeta),
      );
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('handle')) {
      context.handle(
        _handleMeta,
        handle.isAcceptableOrUnknown(data['handle']!, _handleMeta),
      );
    } else if (isInserting) {
      context.missing(_handleMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    }
    if (data.containsKey('access_token')) {
      context.handle(
        _accessTokenMeta,
        accessToken.isAcceptableOrUnknown(
          data['access_token']!,
          _accessTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessTokenMeta);
    }
    if (data.containsKey('refresh_token')) {
      context.handle(
        _refreshTokenMeta,
        refreshToken.isAcceptableOrUnknown(
          data['refresh_token']!,
          _refreshTokenMeta,
        ),
      );
    }
    if (data.containsKey('dpop_public_key')) {
      context.handle(
        _dpopPublicKeyMeta,
        dpopPublicKey.isAcceptableOrUnknown(
          data['dpop_public_key']!,
          _dpopPublicKeyMeta,
        ),
      );
    }
    if (data.containsKey('dpop_private_key')) {
      context.handle(
        _dpopPrivateKeyMeta,
        dpopPrivateKey.isAcceptableOrUnknown(
          data['dpop_private_key']!,
          _dpopPrivateKeyMeta,
        ),
      );
    }
    if (data.containsKey('dpop_nonce')) {
      context.handle(
        _dpopNonceMeta,
        dpopNonce.isAcceptableOrUnknown(data['dpop_nonce']!, _dpopNonceMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {did};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      did: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}did'],
      )!,
      handle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handle'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      ),
      accessToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_token'],
      )!,
      refreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refresh_token'],
      ),
      dpopPublicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dpop_public_key'],
      ),
      dpopPrivateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dpop_private_key'],
      ),
      dpopNonce: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dpop_nonce'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String did;
  final String handle;
  final String? displayName;
  final String? service;
  final String accessToken;
  final String? refreshToken;
  final String? dpopPublicKey;
  final String? dpopPrivateKey;
  final String? dpopNonce;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Account({
    required this.did,
    required this.handle,
    this.displayName,
    this.service,
    required this.accessToken,
    this.refreshToken,
    this.dpopPublicKey,
    this.dpopPrivateKey,
    this.dpopNonce,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['did'] = Variable<String>(did);
    map['handle'] = Variable<String>(handle);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || service != null) {
      map['service'] = Variable<String>(service);
    }
    map['access_token'] = Variable<String>(accessToken);
    if (!nullToAbsent || refreshToken != null) {
      map['refresh_token'] = Variable<String>(refreshToken);
    }
    if (!nullToAbsent || dpopPublicKey != null) {
      map['dpop_public_key'] = Variable<String>(dpopPublicKey);
    }
    if (!nullToAbsent || dpopPrivateKey != null) {
      map['dpop_private_key'] = Variable<String>(dpopPrivateKey);
    }
    if (!nullToAbsent || dpopNonce != null) {
      map['dpop_nonce'] = Variable<String>(dpopNonce);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      did: Value(did),
      handle: Value(handle),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      service: service == null && nullToAbsent
          ? const Value.absent()
          : Value(service),
      accessToken: Value(accessToken),
      refreshToken: refreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(refreshToken),
      dpopPublicKey: dpopPublicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(dpopPublicKey),
      dpopPrivateKey: dpopPrivateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(dpopPrivateKey),
      dpopNonce: dpopNonce == null && nullToAbsent
          ? const Value.absent()
          : Value(dpopNonce),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      did: serializer.fromJson<String>(json['did']),
      handle: serializer.fromJson<String>(json['handle']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      service: serializer.fromJson<String?>(json['service']),
      accessToken: serializer.fromJson<String>(json['accessToken']),
      refreshToken: serializer.fromJson<String?>(json['refreshToken']),
      dpopPublicKey: serializer.fromJson<String?>(json['dpopPublicKey']),
      dpopPrivateKey: serializer.fromJson<String?>(json['dpopPrivateKey']),
      dpopNonce: serializer.fromJson<String?>(json['dpopNonce']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'did': serializer.toJson<String>(did),
      'handle': serializer.toJson<String>(handle),
      'displayName': serializer.toJson<String?>(displayName),
      'service': serializer.toJson<String?>(service),
      'accessToken': serializer.toJson<String>(accessToken),
      'refreshToken': serializer.toJson<String?>(refreshToken),
      'dpopPublicKey': serializer.toJson<String?>(dpopPublicKey),
      'dpopPrivateKey': serializer.toJson<String?>(dpopPrivateKey),
      'dpopNonce': serializer.toJson<String?>(dpopNonce),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Account copyWith({
    String? did,
    String? handle,
    Value<String?> displayName = const Value.absent(),
    Value<String?> service = const Value.absent(),
    String? accessToken,
    Value<String?> refreshToken = const Value.absent(),
    Value<String?> dpopPublicKey = const Value.absent(),
    Value<String?> dpopPrivateKey = const Value.absent(),
    Value<String?> dpopNonce = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Account(
    did: did ?? this.did,
    handle: handle ?? this.handle,
    displayName: displayName.present ? displayName.value : this.displayName,
    service: service.present ? service.value : this.service,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken.present ? refreshToken.value : this.refreshToken,
    dpopPublicKey: dpopPublicKey.present
        ? dpopPublicKey.value
        : this.dpopPublicKey,
    dpopPrivateKey: dpopPrivateKey.present
        ? dpopPrivateKey.value
        : this.dpopPrivateKey,
    dpopNonce: dpopNonce.present ? dpopNonce.value : this.dpopNonce,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      did: data.did.present ? data.did.value : this.did,
      handle: data.handle.present ? data.handle.value : this.handle,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      service: data.service.present ? data.service.value : this.service,
      accessToken: data.accessToken.present
          ? data.accessToken.value
          : this.accessToken,
      refreshToken: data.refreshToken.present
          ? data.refreshToken.value
          : this.refreshToken,
      dpopPublicKey: data.dpopPublicKey.present
          ? data.dpopPublicKey.value
          : this.dpopPublicKey,
      dpopPrivateKey: data.dpopPrivateKey.present
          ? data.dpopPrivateKey.value
          : this.dpopPrivateKey,
      dpopNonce: data.dpopNonce.present ? data.dpopNonce.value : this.dpopNonce,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('did: $did, ')
          ..write('handle: $handle, ')
          ..write('displayName: $displayName, ')
          ..write('service: $service, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('dpopPublicKey: $dpopPublicKey, ')
          ..write('dpopPrivateKey: $dpopPrivateKey, ')
          ..write('dpopNonce: $dpopNonce, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    did,
    handle,
    displayName,
    service,
    accessToken,
    refreshToken,
    dpopPublicKey,
    dpopPrivateKey,
    dpopNonce,
    expiresAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.did == this.did &&
          other.handle == this.handle &&
          other.displayName == this.displayName &&
          other.service == this.service &&
          other.accessToken == this.accessToken &&
          other.refreshToken == this.refreshToken &&
          other.dpopPublicKey == this.dpopPublicKey &&
          other.dpopPrivateKey == this.dpopPrivateKey &&
          other.dpopNonce == this.dpopNonce &&
          other.expiresAt == this.expiresAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> did;
  final Value<String> handle;
  final Value<String?> displayName;
  final Value<String?> service;
  final Value<String> accessToken;
  final Value<String?> refreshToken;
  final Value<String?> dpopPublicKey;
  final Value<String?> dpopPrivateKey;
  final Value<String?> dpopNonce;
  final Value<DateTime?> expiresAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.did = const Value.absent(),
    this.handle = const Value.absent(),
    this.displayName = const Value.absent(),
    this.service = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.dpopPublicKey = const Value.absent(),
    this.dpopPrivateKey = const Value.absent(),
    this.dpopNonce = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String did,
    required String handle,
    this.displayName = const Value.absent(),
    this.service = const Value.absent(),
    required String accessToken,
    this.refreshToken = const Value.absent(),
    this.dpopPublicKey = const Value.absent(),
    this.dpopPrivateKey = const Value.absent(),
    this.dpopNonce = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : did = Value(did),
       handle = Value(handle),
       accessToken = Value(accessToken);
  static Insertable<Account> custom({
    Expression<String>? did,
    Expression<String>? handle,
    Expression<String>? displayName,
    Expression<String>? service,
    Expression<String>? accessToken,
    Expression<String>? refreshToken,
    Expression<String>? dpopPublicKey,
    Expression<String>? dpopPrivateKey,
    Expression<String>? dpopNonce,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (did != null) 'did': did,
      if (handle != null) 'handle': handle,
      if (displayName != null) 'display_name': displayName,
      if (service != null) 'service': service,
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (dpopPublicKey != null) 'dpop_public_key': dpopPublicKey,
      if (dpopPrivateKey != null) 'dpop_private_key': dpopPrivateKey,
      if (dpopNonce != null) 'dpop_nonce': dpopNonce,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? did,
    Value<String>? handle,
    Value<String?>? displayName,
    Value<String?>? service,
    Value<String>? accessToken,
    Value<String?>? refreshToken,
    Value<String?>? dpopPublicKey,
    Value<String?>? dpopPrivateKey,
    Value<String?>? dpopNonce,
    Value<DateTime?>? expiresAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      did: did ?? this.did,
      handle: handle ?? this.handle,
      displayName: displayName ?? this.displayName,
      service: service ?? this.service,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      dpopPublicKey: dpopPublicKey ?? this.dpopPublicKey,
      dpopPrivateKey: dpopPrivateKey ?? this.dpopPrivateKey,
      dpopNonce: dpopNonce ?? this.dpopNonce,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (did.present) {
      map['did'] = Variable<String>(did.value);
    }
    if (handle.present) {
      map['handle'] = Variable<String>(handle.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (refreshToken.present) {
      map['refresh_token'] = Variable<String>(refreshToken.value);
    }
    if (dpopPublicKey.present) {
      map['dpop_public_key'] = Variable<String>(dpopPublicKey.value);
    }
    if (dpopPrivateKey.present) {
      map['dpop_private_key'] = Variable<String>(dpopPrivateKey.value);
    }
    if (dpopNonce.present) {
      map['dpop_nonce'] = Variable<String>(dpopNonce.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('did: $did, ')
          ..write('handle: $handle, ')
          ..write('displayName: $displayName, ')
          ..write('service: $service, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('dpopPublicKey: $dpopPublicKey, ')
          ..write('dpopPrivateKey: $dpopPrivateKey, ')
          ..write('dpopNonce: $dpopNonce, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedProfilesTable extends CachedProfiles
    with TableInfo<$CachedProfilesTable, CachedProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<String> did = GeneratedColumn<String>(
    'did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handleMeta = const VerificationMeta('handle');
  @override
  late final GeneratedColumn<String> handle = GeneratedColumn<String>(
    'handle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [did, handle, payload, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('did')) {
      context.handle(
        _didMeta,
        did.isAcceptableOrUnknown(data['did']!, _didMeta),
      );
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('handle')) {
      context.handle(
        _handleMeta,
        handle.isAcceptableOrUnknown(data['handle']!, _handleMeta),
      );
    } else if (isInserting) {
      context.missing(_handleMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {did};
  @override
  CachedProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProfile(
      did: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}did'],
      )!,
      handle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handle'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedProfilesTable createAlias(String alias) {
    return $CachedProfilesTable(attachedDatabase, alias);
  }
}

class CachedProfile extends DataClass implements Insertable<CachedProfile> {
  final String did;
  final String handle;
  final String payload;
  final DateTime fetchedAt;
  const CachedProfile({
    required this.did,
    required this.handle,
    required this.payload,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['did'] = Variable<String>(did);
    map['handle'] = Variable<String>(handle);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedProfilesCompanion toCompanion(bool nullToAbsent) {
    return CachedProfilesCompanion(
      did: Value(did),
      handle: Value(handle),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProfile(
      did: serializer.fromJson<String>(json['did']),
      handle: serializer.fromJson<String>(json['handle']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'did': serializer.toJson<String>(did),
      'handle': serializer.toJson<String>(handle),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedProfile copyWith({
    String? did,
    String? handle,
    String? payload,
    DateTime? fetchedAt,
  }) => CachedProfile(
    did: did ?? this.did,
    handle: handle ?? this.handle,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedProfile copyWithCompanion(CachedProfilesCompanion data) {
    return CachedProfile(
      did: data.did.present ? data.did.value : this.did,
      handle: data.handle.present ? data.handle.value : this.handle,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfile(')
          ..write('did: $did, ')
          ..write('handle: $handle, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(did, handle, payload, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProfile &&
          other.did == this.did &&
          other.handle == this.handle &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt);
}

class CachedProfilesCompanion extends UpdateCompanion<CachedProfile> {
  final Value<String> did;
  final Value<String> handle;
  final Value<String> payload;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedProfilesCompanion({
    this.did = const Value.absent(),
    this.handle = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProfilesCompanion.insert({
    required String did,
    required String handle,
    required String payload,
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : did = Value(did),
       handle = Value(handle),
       payload = Value(payload);
  static Insertable<CachedProfile> custom({
    Expression<String>? did,
    Expression<String>? handle,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (did != null) 'did': did,
      if (handle != null) 'handle': handle,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProfilesCompanion copyWith({
    Value<String>? did,
    Value<String>? handle,
    Value<String>? payload,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedProfilesCompanion(
      did: did ?? this.did,
      handle: handle ?? this.handle,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (did.present) {
      map['did'] = Variable<String>(did.value);
    }
    if (handle.present) {
      map['handle'] = Variable<String>(handle.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfilesCompanion(')
          ..write('did: $did, ')
          ..write('handle: $handle, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPostsTable extends CachedPosts
    with TableInfo<$CachedPostsTable, CachedPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorDidMeta = const VerificationMeta(
    'authorDid',
  );
  @override
  late final GeneratedColumn<String> authorDid = GeneratedColumn<String>(
    'author_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uri,
    authorDid,
    payload,
    createdAt,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('author_did')) {
      context.handle(
        _authorDidMeta,
        authorDid.isAcceptableOrUnknown(data['author_did']!, _authorDidMeta),
      );
    } else if (isInserting) {
      context.missing(_authorDidMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uri};
  @override
  CachedPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPost(
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      authorDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_did'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedPostsTable createAlias(String alias) {
    return $CachedPostsTable(attachedDatabase, alias);
  }
}

class CachedPost extends DataClass implements Insertable<CachedPost> {
  final String uri;
  final String authorDid;
  final String payload;
  final DateTime? createdAt;
  final DateTime fetchedAt;
  const CachedPost({
    required this.uri,
    required this.authorDid,
    required this.payload,
    this.createdAt,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uri'] = Variable<String>(uri);
    map['author_did'] = Variable<String>(authorDid);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedPostsCompanion toCompanion(bool nullToAbsent) {
    return CachedPostsCompanion(
      uri: Value(uri),
      authorDid: Value(authorDid),
      payload: Value(payload),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedPost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPost(
      uri: serializer.fromJson<String>(json['uri']),
      authorDid: serializer.fromJson<String>(json['authorDid']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uri': serializer.toJson<String>(uri),
      'authorDid': serializer.toJson<String>(authorDid),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedPost copyWith({
    String? uri,
    String? authorDid,
    String? payload,
    Value<DateTime?> createdAt = const Value.absent(),
    DateTime? fetchedAt,
  }) => CachedPost(
    uri: uri ?? this.uri,
    authorDid: authorDid ?? this.authorDid,
    payload: payload ?? this.payload,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedPost copyWithCompanion(CachedPostsCompanion data) {
    return CachedPost(
      uri: data.uri.present ? data.uri.value : this.uri,
      authorDid: data.authorDid.present ? data.authorDid.value : this.authorDid,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPost(')
          ..write('uri: $uri, ')
          ..write('authorDid: $authorDid, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uri, authorDid, payload, createdAt, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPost &&
          other.uri == this.uri &&
          other.authorDid == this.authorDid &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.fetchedAt == this.fetchedAt);
}

class CachedPostsCompanion extends UpdateCompanion<CachedPost> {
  final Value<String> uri;
  final Value<String> authorDid;
  final Value<String> payload;
  final Value<DateTime?> createdAt;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedPostsCompanion({
    this.uri = const Value.absent(),
    this.authorDid = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPostsCompanion.insert({
    required String uri,
    required String authorDid,
    required String payload,
    this.createdAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uri = Value(uri),
       authorDid = Value(authorDid),
       payload = Value(payload);
  static Insertable<CachedPost> custom({
    Expression<String>? uri,
    Expression<String>? authorDid,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uri != null) 'uri': uri,
      if (authorDid != null) 'author_did': authorDid,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPostsCompanion copyWith({
    Value<String>? uri,
    Value<String>? authorDid,
    Value<String>? payload,
    Value<DateTime?>? createdAt,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedPostsCompanion(
      uri: uri ?? this.uri,
      authorDid: authorDid ?? this.authorDid,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (authorDid.present) {
      map['author_did'] = Variable<String>(authorDid.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPostsCompanion(')
          ..write('uri: $uri, ')
          ..write('authorDid: $authorDid, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingsEntry> {
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsEntry> instance, {
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingsEntry extends DataClass implements Insertable<SettingsEntry> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const SettingsEntry({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SettingsEntry copyWith({String? key, String? value, DateTime? updatedAt}) =>
      SettingsEntry(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingsEntry copyWithCompanion(SettingsCompanion data) {
    return SettingsEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntry(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsEntry &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<SettingsEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingsEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedFeedsTable extends SavedFeeds
    with TableInfo<$SavedFeedsTable, SavedFeedEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedFeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountDidMeta = const VerificationMeta(
    'accountDid',
  );
  @override
  late final GeneratedColumn<String> accountDid = GeneratedColumn<String>(
    'account_did',
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
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountDid,
    type,
    value,
    pinned,
    sortOrder,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_feeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedFeedEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_did')) {
      context.handle(
        _accountDidMeta,
        accountDid.isAcceptableOrUnknown(data['account_did']!, _accountDidMeta),
      );
    } else if (isInserting) {
      context.missing(_accountDidMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, accountDid};
  @override
  SavedFeedEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedFeedEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_did'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SavedFeedsTable createAlias(String alias) {
    return $SavedFeedsTable(attachedDatabase, alias);
  }
}

class SavedFeedEntry extends DataClass implements Insertable<SavedFeedEntry> {
  final String id;
  final String accountDid;
  final String type;
  final String value;
  final bool pinned;
  final int sortOrder;
  final DateTime updatedAt;
  const SavedFeedEntry({
    required this.id,
    required this.accountDid,
    required this.type,
    required this.value,
    required this.pinned,
    required this.sortOrder,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_did'] = Variable<String>(accountDid);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<String>(value);
    map['pinned'] = Variable<bool>(pinned);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SavedFeedsCompanion toCompanion(bool nullToAbsent) {
    return SavedFeedsCompanion(
      id: Value(id),
      accountDid: Value(accountDid),
      type: Value(type),
      value: Value(value),
      pinned: Value(pinned),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavedFeedEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedFeedEntry(
      id: serializer.fromJson<String>(json['id']),
      accountDid: serializer.fromJson<String>(json['accountDid']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<String>(json['value']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountDid': serializer.toJson<String>(accountDid),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<String>(value),
      'pinned': serializer.toJson<bool>(pinned),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SavedFeedEntry copyWith({
    String? id,
    String? accountDid,
    String? type,
    String? value,
    bool? pinned,
    int? sortOrder,
    DateTime? updatedAt,
  }) => SavedFeedEntry(
    id: id ?? this.id,
    accountDid: accountDid ?? this.accountDid,
    type: type ?? this.type,
    value: value ?? this.value,
    pinned: pinned ?? this.pinned,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SavedFeedEntry copyWithCompanion(SavedFeedsCompanion data) {
    return SavedFeedEntry(
      id: data.id.present ? data.id.value : this.id,
      accountDid: data.accountDid.present
          ? data.accountDid.value
          : this.accountDid,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedFeedEntry(')
          ..write('id: $id, ')
          ..write('accountDid: $accountDid, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('pinned: $pinned, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, accountDid, type, value, pinned, sortOrder, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedFeedEntry &&
          other.id == this.id &&
          other.accountDid == this.accountDid &&
          other.type == this.type &&
          other.value == this.value &&
          other.pinned == this.pinned &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt);
}

class SavedFeedsCompanion extends UpdateCompanion<SavedFeedEntry> {
  final Value<String> id;
  final Value<String> accountDid;
  final Value<String> type;
  final Value<String> value;
  final Value<bool> pinned;
  final Value<int> sortOrder;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SavedFeedsCompanion({
    this.id = const Value.absent(),
    this.accountDid = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.pinned = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedFeedsCompanion.insert({
    required String id,
    required String accountDid,
    required String type,
    required String value,
    this.pinned = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountDid = Value(accountDid),
       type = Value(type),
       value = Value(value);
  static Insertable<SavedFeedEntry> custom({
    Expression<String>? id,
    Expression<String>? accountDid,
    Expression<String>? type,
    Expression<String>? value,
    Expression<bool>? pinned,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountDid != null) 'account_did': accountDid,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (pinned != null) 'pinned': pinned,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedFeedsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountDid,
    Value<String>? type,
    Value<String>? value,
    Value<bool>? pinned,
    Value<int>? sortOrder,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SavedFeedsCompanion(
      id: id ?? this.id,
      accountDid: accountDid ?? this.accountDid,
      type: type ?? this.type,
      value: value ?? this.value,
      pinned: pinned ?? this.pinned,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountDid.present) {
      map['account_did'] = Variable<String>(accountDid.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedFeedsCompanion(')
          ..write('id: $id, ')
          ..write('accountDid: $accountDid, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('pinned: $pinned, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryTable extends SearchHistory
    with TableInfo<$SearchHistoryTable, SearchHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
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
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _accountDidMeta = const VerificationMeta(
    'accountDid',
  );
  @override
  late final GeneratedColumn<String> accountDid = GeneratedColumn<String>(
    'account_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    query,
    type,
    searchedAt,
    accountDid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    }
    if (data.containsKey('account_did')) {
      context.handle(
        _accountDidMeta,
        accountDid.isAcceptableOrUnknown(data['account_did']!, _accountDidMeta),
      );
    } else if (isInserting) {
      context.missing(_accountDidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
      accountDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_did'],
      )!,
    );
  }

  @override
  $SearchHistoryTable createAlias(String alias) {
    return $SearchHistoryTable(attachedDatabase, alias);
  }
}

class SearchHistoryEntry extends DataClass
    implements Insertable<SearchHistoryEntry> {
  final int id;
  final String query;
  final String type;
  final DateTime searchedAt;
  final String accountDid;
  const SearchHistoryEntry({
    required this.id,
    required this.query,
    required this.type,
    required this.searchedAt,
    required this.accountDid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['type'] = Variable<String>(type);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    map['account_did'] = Variable<String>(accountDid);
    return map;
  }

  SearchHistoryCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryCompanion(
      id: Value(id),
      query: Value(query),
      type: Value(type),
      searchedAt: Value(searchedAt),
      accountDid: Value(accountDid),
    );
  }

  factory SearchHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      type: serializer.fromJson<String>(json['type']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
      accountDid: serializer.fromJson<String>(json['accountDid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'type': serializer.toJson<String>(type),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
      'accountDid': serializer.toJson<String>(accountDid),
    };
  }

  SearchHistoryEntry copyWith({
    int? id,
    String? query,
    String? type,
    DateTime? searchedAt,
    String? accountDid,
  }) => SearchHistoryEntry(
    id: id ?? this.id,
    query: query ?? this.query,
    type: type ?? this.type,
    searchedAt: searchedAt ?? this.searchedAt,
    accountDid: accountDid ?? this.accountDid,
  );
  SearchHistoryEntry copyWithCompanion(SearchHistoryCompanion data) {
    return SearchHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      type: data.type.present ? data.type.value : this.type,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
      accountDid: data.accountDid.present
          ? data.accountDid.value
          : this.accountDid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryEntry(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('type: $type, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('accountDid: $accountDid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, type, searchedAt, accountDid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryEntry &&
          other.id == this.id &&
          other.query == this.query &&
          other.type == this.type &&
          other.searchedAt == this.searchedAt &&
          other.accountDid == this.accountDid);
}

class SearchHistoryCompanion extends UpdateCompanion<SearchHistoryEntry> {
  final Value<int> id;
  final Value<String> query;
  final Value<String> type;
  final Value<DateTime> searchedAt;
  final Value<String> accountDid;
  const SearchHistoryCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.type = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.accountDid = const Value.absent(),
  });
  SearchHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required String type,
    this.searchedAt = const Value.absent(),
    required String accountDid,
  }) : query = Value(query),
       type = Value(type),
       accountDid = Value(accountDid);
  static Insertable<SearchHistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<String>? type,
    Expression<DateTime>? searchedAt,
    Expression<String>? accountDid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (type != null) 'type': type,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (accountDid != null) 'account_did': accountDid,
    });
  }

  SearchHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<String>? type,
    Value<DateTime>? searchedAt,
    Value<String>? accountDid,
  }) {
    return SearchHistoryCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      type: type ?? this.type,
      searchedAt: searchedAt ?? this.searchedAt,
      accountDid: accountDid ?? this.accountDid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    if (accountDid.present) {
      map['account_did'] = Variable<String>(accountDid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('type: $type, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('accountDid: $accountDid')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, DraftEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _accountDidMeta = const VerificationMeta(
    'accountDid',
  );
  @override
  late final GeneratedColumn<String> accountDid = GeneratedColumn<String>(
    'account_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _replyUriMeta = const VerificationMeta(
    'replyUri',
  );
  @override
  late final GeneratedColumn<String> replyUri = GeneratedColumn<String>(
    'reply_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyCidMeta = const VerificationMeta(
    'replyCid',
  );
  @override
  late final GeneratedColumn<String> replyCid = GeneratedColumn<String>(
    'reply_cid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rootUriMeta = const VerificationMeta(
    'rootUri',
  );
  @override
  late final GeneratedColumn<String> rootUri = GeneratedColumn<String>(
    'root_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rootCidMeta = const VerificationMeta(
    'rootCid',
  );
  @override
  late final GeneratedColumn<String> rootCid = GeneratedColumn<String>(
    'root_cid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _embedJsonMeta = const VerificationMeta(
    'embedJson',
  );
  @override
  late final GeneratedColumn<String> embedJson = GeneratedColumn<String>(
    'embed_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaPathsMeta = const VerificationMeta(
    'mediaPaths',
  );
  @override
  late final GeneratedColumn<String> mediaPaths = GeneratedColumn<String>(
    'media_paths',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountDid,
    content,
    replyUri,
    replyCid,
    rootUri,
    rootCid,
    embedJson,
    mediaPaths,
    createdAt,
    updatedAt,
    scheduledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_did')) {
      context.handle(
        _accountDidMeta,
        accountDid.isAcceptableOrUnknown(data['account_did']!, _accountDidMeta),
      );
    } else if (isInserting) {
      context.missing(_accountDidMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('reply_uri')) {
      context.handle(
        _replyUriMeta,
        replyUri.isAcceptableOrUnknown(data['reply_uri']!, _replyUriMeta),
      );
    }
    if (data.containsKey('reply_cid')) {
      context.handle(
        _replyCidMeta,
        replyCid.isAcceptableOrUnknown(data['reply_cid']!, _replyCidMeta),
      );
    }
    if (data.containsKey('root_uri')) {
      context.handle(
        _rootUriMeta,
        rootUri.isAcceptableOrUnknown(data['root_uri']!, _rootUriMeta),
      );
    }
    if (data.containsKey('root_cid')) {
      context.handle(
        _rootCidMeta,
        rootCid.isAcceptableOrUnknown(data['root_cid']!, _rootCidMeta),
      );
    }
    if (data.containsKey('embed_json')) {
      context.handle(
        _embedJsonMeta,
        embedJson.isAcceptableOrUnknown(data['embed_json']!, _embedJsonMeta),
      );
    }
    if (data.containsKey('media_paths')) {
      context.handle(
        _mediaPathsMeta,
        mediaPaths.isAcceptableOrUnknown(data['media_paths']!, _mediaPathsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_did'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      replyUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_uri'],
      ),
      replyCid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_cid'],
      ),
      rootUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_uri'],
      ),
      rootCid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_cid'],
      ),
      embedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embed_json'],
      ),
      mediaPaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_paths'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class DraftEntry extends DataClass implements Insertable<DraftEntry> {
  final int id;
  final String accountDid;
  final String content;
  final String? replyUri;
  final String? replyCid;
  final String? rootUri;
  final String? rootCid;
  final String? embedJson;
  final String? mediaPaths;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? scheduledAt;
  const DraftEntry({
    required this.id,
    required this.accountDid,
    required this.content,
    this.replyUri,
    this.replyCid,
    this.rootUri,
    this.rootCid,
    this.embedJson,
    this.mediaPaths,
    required this.createdAt,
    required this.updatedAt,
    this.scheduledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_did'] = Variable<String>(accountDid);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || replyUri != null) {
      map['reply_uri'] = Variable<String>(replyUri);
    }
    if (!nullToAbsent || replyCid != null) {
      map['reply_cid'] = Variable<String>(replyCid);
    }
    if (!nullToAbsent || rootUri != null) {
      map['root_uri'] = Variable<String>(rootUri);
    }
    if (!nullToAbsent || rootCid != null) {
      map['root_cid'] = Variable<String>(rootCid);
    }
    if (!nullToAbsent || embedJson != null) {
      map['embed_json'] = Variable<String>(embedJson);
    }
    if (!nullToAbsent || mediaPaths != null) {
      map['media_paths'] = Variable<String>(mediaPaths);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      accountDid: Value(accountDid),
      content: Value(content),
      replyUri: replyUri == null && nullToAbsent
          ? const Value.absent()
          : Value(replyUri),
      replyCid: replyCid == null && nullToAbsent
          ? const Value.absent()
          : Value(replyCid),
      rootUri: rootUri == null && nullToAbsent
          ? const Value.absent()
          : Value(rootUri),
      rootCid: rootCid == null && nullToAbsent
          ? const Value.absent()
          : Value(rootCid),
      embedJson: embedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(embedJson),
      mediaPaths: mediaPaths == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaPaths),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
    );
  }

  factory DraftEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftEntry(
      id: serializer.fromJson<int>(json['id']),
      accountDid: serializer.fromJson<String>(json['accountDid']),
      content: serializer.fromJson<String>(json['content']),
      replyUri: serializer.fromJson<String?>(json['replyUri']),
      replyCid: serializer.fromJson<String?>(json['replyCid']),
      rootUri: serializer.fromJson<String?>(json['rootUri']),
      rootCid: serializer.fromJson<String?>(json['rootCid']),
      embedJson: serializer.fromJson<String?>(json['embedJson']),
      mediaPaths: serializer.fromJson<String?>(json['mediaPaths']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountDid': serializer.toJson<String>(accountDid),
      'content': serializer.toJson<String>(content),
      'replyUri': serializer.toJson<String?>(replyUri),
      'replyCid': serializer.toJson<String?>(replyCid),
      'rootUri': serializer.toJson<String?>(rootUri),
      'rootCid': serializer.toJson<String?>(rootCid),
      'embedJson': serializer.toJson<String?>(embedJson),
      'mediaPaths': serializer.toJson<String?>(mediaPaths),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
    };
  }

  DraftEntry copyWith({
    int? id,
    String? accountDid,
    String? content,
    Value<String?> replyUri = const Value.absent(),
    Value<String?> replyCid = const Value.absent(),
    Value<String?> rootUri = const Value.absent(),
    Value<String?> rootCid = const Value.absent(),
    Value<String?> embedJson = const Value.absent(),
    Value<String?> mediaPaths = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> scheduledAt = const Value.absent(),
  }) => DraftEntry(
    id: id ?? this.id,
    accountDid: accountDid ?? this.accountDid,
    content: content ?? this.content,
    replyUri: replyUri.present ? replyUri.value : this.replyUri,
    replyCid: replyCid.present ? replyCid.value : this.replyCid,
    rootUri: rootUri.present ? rootUri.value : this.rootUri,
    rootCid: rootCid.present ? rootCid.value : this.rootCid,
    embedJson: embedJson.present ? embedJson.value : this.embedJson,
    mediaPaths: mediaPaths.present ? mediaPaths.value : this.mediaPaths,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
  );
  DraftEntry copyWithCompanion(DraftsCompanion data) {
    return DraftEntry(
      id: data.id.present ? data.id.value : this.id,
      accountDid: data.accountDid.present
          ? data.accountDid.value
          : this.accountDid,
      content: data.content.present ? data.content.value : this.content,
      replyUri: data.replyUri.present ? data.replyUri.value : this.replyUri,
      replyCid: data.replyCid.present ? data.replyCid.value : this.replyCid,
      rootUri: data.rootUri.present ? data.rootUri.value : this.rootUri,
      rootCid: data.rootCid.present ? data.rootCid.value : this.rootCid,
      embedJson: data.embedJson.present ? data.embedJson.value : this.embedJson,
      mediaPaths: data.mediaPaths.present
          ? data.mediaPaths.value
          : this.mediaPaths,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftEntry(')
          ..write('id: $id, ')
          ..write('accountDid: $accountDid, ')
          ..write('content: $content, ')
          ..write('replyUri: $replyUri, ')
          ..write('replyCid: $replyCid, ')
          ..write('rootUri: $rootUri, ')
          ..write('rootCid: $rootCid, ')
          ..write('embedJson: $embedJson, ')
          ..write('mediaPaths: $mediaPaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('scheduledAt: $scheduledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountDid,
    content,
    replyUri,
    replyCid,
    rootUri,
    rootCid,
    embedJson,
    mediaPaths,
    createdAt,
    updatedAt,
    scheduledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftEntry &&
          other.id == this.id &&
          other.accountDid == this.accountDid &&
          other.content == this.content &&
          other.replyUri == this.replyUri &&
          other.replyCid == this.replyCid &&
          other.rootUri == this.rootUri &&
          other.rootCid == this.rootCid &&
          other.embedJson == this.embedJson &&
          other.mediaPaths == this.mediaPaths &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.scheduledAt == this.scheduledAt);
}

class DraftsCompanion extends UpdateCompanion<DraftEntry> {
  final Value<int> id;
  final Value<String> accountDid;
  final Value<String> content;
  final Value<String?> replyUri;
  final Value<String?> replyCid;
  final Value<String?> rootUri;
  final Value<String?> rootCid;
  final Value<String?> embedJson;
  final Value<String?> mediaPaths;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> scheduledAt;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.accountDid = const Value.absent(),
    this.content = const Value.absent(),
    this.replyUri = const Value.absent(),
    this.replyCid = const Value.absent(),
    this.rootUri = const Value.absent(),
    this.rootCid = const Value.absent(),
    this.embedJson = const Value.absent(),
    this.mediaPaths = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
  });
  DraftsCompanion.insert({
    this.id = const Value.absent(),
    required String accountDid,
    required String content,
    this.replyUri = const Value.absent(),
    this.replyCid = const Value.absent(),
    this.rootUri = const Value.absent(),
    this.rootCid = const Value.absent(),
    this.embedJson = const Value.absent(),
    this.mediaPaths = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
  }) : accountDid = Value(accountDid),
       content = Value(content);
  static Insertable<DraftEntry> custom({
    Expression<int>? id,
    Expression<String>? accountDid,
    Expression<String>? content,
    Expression<String>? replyUri,
    Expression<String>? replyCid,
    Expression<String>? rootUri,
    Expression<String>? rootCid,
    Expression<String>? embedJson,
    Expression<String>? mediaPaths,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? scheduledAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountDid != null) 'account_did': accountDid,
      if (content != null) 'content': content,
      if (replyUri != null) 'reply_uri': replyUri,
      if (replyCid != null) 'reply_cid': replyCid,
      if (rootUri != null) 'root_uri': rootUri,
      if (rootCid != null) 'root_cid': rootCid,
      if (embedJson != null) 'embed_json': embedJson,
      if (mediaPaths != null) 'media_paths': mediaPaths,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
    });
  }

  DraftsCompanion copyWith({
    Value<int>? id,
    Value<String>? accountDid,
    Value<String>? content,
    Value<String?>? replyUri,
    Value<String?>? replyCid,
    Value<String?>? rootUri,
    Value<String?>? rootCid,
    Value<String?>? embedJson,
    Value<String?>? mediaPaths,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? scheduledAt,
  }) {
    return DraftsCompanion(
      id: id ?? this.id,
      accountDid: accountDid ?? this.accountDid,
      content: content ?? this.content,
      replyUri: replyUri ?? this.replyUri,
      replyCid: replyCid ?? this.replyCid,
      rootUri: rootUri ?? this.rootUri,
      rootCid: rootCid ?? this.rootCid,
      embedJson: embedJson ?? this.embedJson,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountDid.present) {
      map['account_did'] = Variable<String>(accountDid.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (replyUri.present) {
      map['reply_uri'] = Variable<String>(replyUri.value);
    }
    if (replyCid.present) {
      map['reply_cid'] = Variable<String>(replyCid.value);
    }
    if (rootUri.present) {
      map['root_uri'] = Variable<String>(rootUri.value);
    }
    if (rootCid.present) {
      map['root_cid'] = Variable<String>(rootCid.value);
    }
    if (embedJson.present) {
      map['embed_json'] = Variable<String>(embedJson.value);
    }
    if (mediaPaths.present) {
      map['media_paths'] = Variable<String>(mediaPaths.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('accountDid: $accountDid, ')
          ..write('content: $content, ')
          ..write('replyUri: $replyUri, ')
          ..write('replyCid: $replyCid, ')
          ..write('rootUri: $rootUri, ')
          ..write('rootCid: $rootCid, ')
          ..write('embedJson: $embedJson, ')
          ..write('mediaPaths: $mediaPaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('scheduledAt: $scheduledAt')
          ..write(')'))
        .toString();
  }
}

class $SavedPostsTable extends SavedPosts
    with TableInfo<$SavedPostsTable, SavedPostEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedPostsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _accountDidMeta = const VerificationMeta(
    'accountDid',
  );
  @override
  late final GeneratedColumn<String> accountDid = GeneratedColumn<String>(
    'account_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postUriMeta = const VerificationMeta(
    'postUri',
  );
  @override
  late final GeneratedColumn<String> postUri = GeneratedColumn<String>(
    'post_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postJsonMeta = const VerificationMeta(
    'postJson',
  );
  @override
  late final GeneratedColumn<String> postJson = GeneratedColumn<String>(
    'post_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountDid,
    postUri,
    postJson,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedPostEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_did')) {
      context.handle(
        _accountDidMeta,
        accountDid.isAcceptableOrUnknown(data['account_did']!, _accountDidMeta),
      );
    } else if (isInserting) {
      context.missing(_accountDidMeta);
    }
    if (data.containsKey('post_uri')) {
      context.handle(
        _postUriMeta,
        postUri.isAcceptableOrUnknown(data['post_uri']!, _postUriMeta),
      );
    } else if (isInserting) {
      context.missing(_postUriMeta);
    }
    if (data.containsKey('post_json')) {
      context.handle(
        _postJsonMeta,
        postJson.isAcceptableOrUnknown(data['post_json']!, _postJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_postJsonMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedPostEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedPostEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_did'],
      )!,
      postUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_uri'],
      )!,
      postJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_json'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $SavedPostsTable createAlias(String alias) {
    return $SavedPostsTable(attachedDatabase, alias);
  }
}

class SavedPostEntry extends DataClass implements Insertable<SavedPostEntry> {
  final int id;
  final String accountDid;
  final String postUri;
  final String postJson;
  final DateTime savedAt;
  const SavedPostEntry({
    required this.id,
    required this.accountDid,
    required this.postUri,
    required this.postJson,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_did'] = Variable<String>(accountDid);
    map['post_uri'] = Variable<String>(postUri);
    map['post_json'] = Variable<String>(postJson);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  SavedPostsCompanion toCompanion(bool nullToAbsent) {
    return SavedPostsCompanion(
      id: Value(id),
      accountDid: Value(accountDid),
      postUri: Value(postUri),
      postJson: Value(postJson),
      savedAt: Value(savedAt),
    );
  }

  factory SavedPostEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedPostEntry(
      id: serializer.fromJson<int>(json['id']),
      accountDid: serializer.fromJson<String>(json['accountDid']),
      postUri: serializer.fromJson<String>(json['postUri']),
      postJson: serializer.fromJson<String>(json['postJson']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountDid': serializer.toJson<String>(accountDid),
      'postUri': serializer.toJson<String>(postUri),
      'postJson': serializer.toJson<String>(postJson),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  SavedPostEntry copyWith({
    int? id,
    String? accountDid,
    String? postUri,
    String? postJson,
    DateTime? savedAt,
  }) => SavedPostEntry(
    id: id ?? this.id,
    accountDid: accountDid ?? this.accountDid,
    postUri: postUri ?? this.postUri,
    postJson: postJson ?? this.postJson,
    savedAt: savedAt ?? this.savedAt,
  );
  SavedPostEntry copyWithCompanion(SavedPostsCompanion data) {
    return SavedPostEntry(
      id: data.id.present ? data.id.value : this.id,
      accountDid: data.accountDid.present
          ? data.accountDid.value
          : this.accountDid,
      postUri: data.postUri.present ? data.postUri.value : this.postUri,
      postJson: data.postJson.present ? data.postJson.value : this.postJson,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedPostEntry(')
          ..write('id: $id, ')
          ..write('accountDid: $accountDid, ')
          ..write('postUri: $postUri, ')
          ..write('postJson: $postJson, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountDid, postUri, postJson, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedPostEntry &&
          other.id == this.id &&
          other.accountDid == this.accountDid &&
          other.postUri == this.postUri &&
          other.postJson == this.postJson &&
          other.savedAt == this.savedAt);
}

class SavedPostsCompanion extends UpdateCompanion<SavedPostEntry> {
  final Value<int> id;
  final Value<String> accountDid;
  final Value<String> postUri;
  final Value<String> postJson;
  final Value<DateTime> savedAt;
  const SavedPostsCompanion({
    this.id = const Value.absent(),
    this.accountDid = const Value.absent(),
    this.postUri = const Value.absent(),
    this.postJson = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  SavedPostsCompanion.insert({
    this.id = const Value.absent(),
    required String accountDid,
    required String postUri,
    required String postJson,
    this.savedAt = const Value.absent(),
  }) : accountDid = Value(accountDid),
       postUri = Value(postUri),
       postJson = Value(postJson);
  static Insertable<SavedPostEntry> custom({
    Expression<int>? id,
    Expression<String>? accountDid,
    Expression<String>? postUri,
    Expression<String>? postJson,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountDid != null) 'account_did': accountDid,
      if (postUri != null) 'post_uri': postUri,
      if (postJson != null) 'post_json': postJson,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  SavedPostsCompanion copyWith({
    Value<int>? id,
    Value<String>? accountDid,
    Value<String>? postUri,
    Value<String>? postJson,
    Value<DateTime>? savedAt,
  }) {
    return SavedPostsCompanion(
      id: id ?? this.id,
      accountDid: accountDid ?? this.accountDid,
      postUri: postUri ?? this.postUri,
      postJson: postJson ?? this.postJson,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountDid.present) {
      map['account_did'] = Variable<String>(accountDid.value);
    }
    if (postUri.present) {
      map['post_uri'] = Variable<String>(postUri.value);
    }
    if (postJson.present) {
      map['post_json'] = Variable<String>(postJson.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedPostsCompanion(')
          ..write('id: $id, ')
          ..write('accountDid: $accountDid, ')
          ..write('postUri: $postUri, ')
          ..write('postJson: $postJson, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CachedProfilesTable cachedProfiles = $CachedProfilesTable(this);
  late final $CachedPostsTable cachedPosts = $CachedPostsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $SavedFeedsTable savedFeeds = $SavedFeedsTable(this);
  late final $SearchHistoryTable searchHistory = $SearchHistoryTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final $SavedPostsTable savedPosts = $SavedPostsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    cachedProfiles,
    cachedPosts,
    settings,
    savedFeeds,
    searchHistory,
    drafts,
    savedPosts,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String did,
      required String handle,
      Value<String?> displayName,
      Value<String?> service,
      required String accessToken,
      Value<String?> refreshToken,
      Value<String?> dpopPublicKey,
      Value<String?> dpopPrivateKey,
      Value<String?> dpopNonce,
      Value<DateTime?> expiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> did,
      Value<String> handle,
      Value<String?> displayName,
      Value<String?> service,
      Value<String> accessToken,
      Value<String?> refreshToken,
      Value<String?> dpopPublicKey,
      Value<String?> dpopPrivateKey,
      Value<String?> dpopNonce,
      Value<DateTime?> expiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get did => $composableBuilder(
    column: $table.did,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dpopPublicKey => $composableBuilder(
    column: $table.dpopPublicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dpopPrivateKey => $composableBuilder(
    column: $table.dpopPrivateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dpopNonce => $composableBuilder(
    column: $table.dpopNonce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
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
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get did => $composableBuilder(
    column: $table.did,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dpopPublicKey => $composableBuilder(
    column: $table.dpopPublicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dpopPrivateKey => $composableBuilder(
    column: $table.dpopPrivateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dpopNonce => $composableBuilder(
    column: $table.dpopNonce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
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
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get did =>
      $composableBuilder(column: $table.did, builder: (column) => column);

  GeneratedColumn<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dpopPublicKey => $composableBuilder(
    column: $table.dpopPublicKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dpopPrivateKey => $composableBuilder(
    column: $table.dpopPrivateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dpopNonce =>
      $composableBuilder(column: $table.dpopNonce, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> did = const Value.absent(),
                Value<String> handle = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> service = const Value.absent(),
                Value<String> accessToken = const Value.absent(),
                Value<String?> refreshToken = const Value.absent(),
                Value<String?> dpopPublicKey = const Value.absent(),
                Value<String?> dpopPrivateKey = const Value.absent(),
                Value<String?> dpopNonce = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                did: did,
                handle: handle,
                displayName: displayName,
                service: service,
                accessToken: accessToken,
                refreshToken: refreshToken,
                dpopPublicKey: dpopPublicKey,
                dpopPrivateKey: dpopPrivateKey,
                dpopNonce: dpopNonce,
                expiresAt: expiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String did,
                required String handle,
                Value<String?> displayName = const Value.absent(),
                Value<String?> service = const Value.absent(),
                required String accessToken,
                Value<String?> refreshToken = const Value.absent(),
                Value<String?> dpopPublicKey = const Value.absent(),
                Value<String?> dpopPrivateKey = const Value.absent(),
                Value<String?> dpopNonce = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                did: did,
                handle: handle,
                displayName: displayName,
                service: service,
                accessToken: accessToken,
                refreshToken: refreshToken,
                dpopPublicKey: dpopPublicKey,
                dpopPrivateKey: dpopPrivateKey,
                dpopNonce: dpopNonce,
                expiresAt: expiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$CachedProfilesTableCreateCompanionBuilder =
    CachedProfilesCompanion Function({
      required String did,
      required String handle,
      required String payload,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedProfilesTableUpdateCompanionBuilder =
    CachedProfilesCompanion Function({
      Value<String> did,
      Value<String> handle,
      Value<String> payload,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$CachedProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get did => $composableBuilder(
    column: $table.did,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get did => $composableBuilder(
    column: $table.did,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get did =>
      $composableBuilder(column: $table.did, builder: (column) => column);

  GeneratedColumn<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedProfilesTable,
          CachedProfile,
          $$CachedProfilesTableFilterComposer,
          $$CachedProfilesTableOrderingComposer,
          $$CachedProfilesTableAnnotationComposer,
          $$CachedProfilesTableCreateCompanionBuilder,
          $$CachedProfilesTableUpdateCompanionBuilder,
          (
            CachedProfile,
            BaseReferences<_$AppDatabase, $CachedProfilesTable, CachedProfile>,
          ),
          CachedProfile,
          PrefetchHooks Function()
        > {
  $$CachedProfilesTableTableManager(
    _$AppDatabase db,
    $CachedProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> did = const Value.absent(),
                Value<String> handle = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedProfilesCompanion(
                did: did,
                handle: handle,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String did,
                required String handle,
                required String payload,
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedProfilesCompanion.insert(
                did: did,
                handle: handle,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedProfilesTable,
      CachedProfile,
      $$CachedProfilesTableFilterComposer,
      $$CachedProfilesTableOrderingComposer,
      $$CachedProfilesTableAnnotationComposer,
      $$CachedProfilesTableCreateCompanionBuilder,
      $$CachedProfilesTableUpdateCompanionBuilder,
      (
        CachedProfile,
        BaseReferences<_$AppDatabase, $CachedProfilesTable, CachedProfile>,
      ),
      CachedProfile,
      PrefetchHooks Function()
    >;
typedef $$CachedPostsTableCreateCompanionBuilder =
    CachedPostsCompanion Function({
      required String uri,
      required String authorDid,
      required String payload,
      Value<DateTime?> createdAt,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedPostsTableUpdateCompanionBuilder =
    CachedPostsCompanion Function({
      Value<String> uri,
      Value<String> authorDid,
      Value<String> payload,
      Value<DateTime?> createdAt,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$CachedPostsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPostsTable> {
  $$CachedPostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorDid => $composableBuilder(
    column: $table.authorDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPostsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPostsTable> {
  $$CachedPostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorDid => $composableBuilder(
    column: $table.authorDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPostsTable> {
  $$CachedPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get authorDid =>
      $composableBuilder(column: $table.authorDid, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedPostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPostsTable,
          CachedPost,
          $$CachedPostsTableFilterComposer,
          $$CachedPostsTableOrderingComposer,
          $$CachedPostsTableAnnotationComposer,
          $$CachedPostsTableCreateCompanionBuilder,
          $$CachedPostsTableUpdateCompanionBuilder,
          (
            CachedPost,
            BaseReferences<_$AppDatabase, $CachedPostsTable, CachedPost>,
          ),
          CachedPost,
          PrefetchHooks Function()
        > {
  $$CachedPostsTableTableManager(_$AppDatabase db, $CachedPostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uri = const Value.absent(),
                Value<String> authorDid = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPostsCompanion(
                uri: uri,
                authorDid: authorDid,
                payload: payload,
                createdAt: createdAt,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uri,
                required String authorDid,
                required String payload,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPostsCompanion.insert(
                uri: uri,
                authorDid: authorDid,
                payload: payload,
                createdAt: createdAt,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPostsTable,
      CachedPost,
      $$CachedPostsTableFilterComposer,
      $$CachedPostsTableOrderingComposer,
      $$CachedPostsTableAnnotationComposer,
      $$CachedPostsTableCreateCompanionBuilder,
      $$CachedPostsTableUpdateCompanionBuilder,
      (
        CachedPost,
        BaseReferences<_$AppDatabase, $CachedPostsTable, CachedPost>,
      ),
      CachedPost,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingsEntry,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingsEntry,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingsEntry>,
          ),
          SettingsEntry,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingsEntry,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (
        SettingsEntry,
        BaseReferences<_$AppDatabase, $SettingsTable, SettingsEntry>,
      ),
      SettingsEntry,
      PrefetchHooks Function()
    >;
typedef $$SavedFeedsTableCreateCompanionBuilder =
    SavedFeedsCompanion Function({
      required String id,
      required String accountDid,
      required String type,
      required String value,
      Value<bool> pinned,
      Value<int> sortOrder,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SavedFeedsTableUpdateCompanionBuilder =
    SavedFeedsCompanion Function({
      Value<String> id,
      Value<String> accountDid,
      Value<String> type,
      Value<String> value,
      Value<bool> pinned,
      Value<int> sortOrder,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SavedFeedsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedFeedsTable> {
  $$SavedFeedsTableFilterComposer({
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

  ColumnFilters<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedFeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedFeedsTable> {
  $$SavedFeedsTableOrderingComposer({
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

  ColumnOrderings<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedFeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedFeedsTable> {
  $$SavedFeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SavedFeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedFeedsTable,
          SavedFeedEntry,
          $$SavedFeedsTableFilterComposer,
          $$SavedFeedsTableOrderingComposer,
          $$SavedFeedsTableAnnotationComposer,
          $$SavedFeedsTableCreateCompanionBuilder,
          $$SavedFeedsTableUpdateCompanionBuilder,
          (
            SavedFeedEntry,
            BaseReferences<_$AppDatabase, $SavedFeedsTable, SavedFeedEntry>,
          ),
          SavedFeedEntry,
          PrefetchHooks Function()
        > {
  $$SavedFeedsTableTableManager(_$AppDatabase db, $SavedFeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedFeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedFeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedFeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountDid = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedFeedsCompanion(
                id: id,
                accountDid: accountDid,
                type: type,
                value: value,
                pinned: pinned,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountDid,
                required String type,
                required String value,
                Value<bool> pinned = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedFeedsCompanion.insert(
                id: id,
                accountDid: accountDid,
                type: type,
                value: value,
                pinned: pinned,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedFeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedFeedsTable,
      SavedFeedEntry,
      $$SavedFeedsTableFilterComposer,
      $$SavedFeedsTableOrderingComposer,
      $$SavedFeedsTableAnnotationComposer,
      $$SavedFeedsTableCreateCompanionBuilder,
      $$SavedFeedsTableUpdateCompanionBuilder,
      (
        SavedFeedEntry,
        BaseReferences<_$AppDatabase, $SavedFeedsTable, SavedFeedEntry>,
      ),
      SavedFeedEntry,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryTableCreateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<int> id,
      required String query,
      required String type,
      Value<DateTime> searchedAt,
      required String accountDid,
    });
typedef $$SearchHistoryTableUpdateCompanionBuilder =
    SearchHistoryCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<String> type,
      Value<DateTime> searchedAt,
      Value<String> accountDid,
    });

class $$SearchHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableFilterComposer({
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

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryTable> {
  $$SearchHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => column,
  );
}

class $$SearchHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryTable,
          SearchHistoryEntry,
          $$SearchHistoryTableFilterComposer,
          $$SearchHistoryTableOrderingComposer,
          $$SearchHistoryTableAnnotationComposer,
          $$SearchHistoryTableCreateCompanionBuilder,
          $$SearchHistoryTableUpdateCompanionBuilder,
          (
            SearchHistoryEntry,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryTable,
              SearchHistoryEntry
            >,
          ),
          SearchHistoryEntry,
          PrefetchHooks Function()
        > {
  $$SearchHistoryTableTableManager(_$AppDatabase db, $SearchHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
                Value<String> accountDid = const Value.absent(),
              }) => SearchHistoryCompanion(
                id: id,
                query: query,
                type: type,
                searchedAt: searchedAt,
                accountDid: accountDid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required String type,
                Value<DateTime> searchedAt = const Value.absent(),
                required String accountDid,
              }) => SearchHistoryCompanion.insert(
                id: id,
                query: query,
                type: type,
                searchedAt: searchedAt,
                accountDid: accountDid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryTable,
      SearchHistoryEntry,
      $$SearchHistoryTableFilterComposer,
      $$SearchHistoryTableOrderingComposer,
      $$SearchHistoryTableAnnotationComposer,
      $$SearchHistoryTableCreateCompanionBuilder,
      $$SearchHistoryTableUpdateCompanionBuilder,
      (
        SearchHistoryEntry,
        BaseReferences<_$AppDatabase, $SearchHistoryTable, SearchHistoryEntry>,
      ),
      SearchHistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$DraftsTableCreateCompanionBuilder =
    DraftsCompanion Function({
      Value<int> id,
      required String accountDid,
      required String content,
      Value<String?> replyUri,
      Value<String?> replyCid,
      Value<String?> rootUri,
      Value<String?> rootCid,
      Value<String?> embedJson,
      Value<String?> mediaPaths,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> scheduledAt,
    });
typedef $$DraftsTableUpdateCompanionBuilder =
    DraftsCompanion Function({
      Value<int> id,
      Value<String> accountDid,
      Value<String> content,
      Value<String?> replyUri,
      Value<String?> replyCid,
      Value<String?> rootUri,
      Value<String?> rootCid,
      Value<String?> embedJson,
      Value<String?> mediaPaths,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> scheduledAt,
    });

class $$DraftsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
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

  ColumnFilters<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyUri => $composableBuilder(
    column: $table.replyUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyCid => $composableBuilder(
    column: $table.replyCid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootUri => $composableBuilder(
    column: $table.rootUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootCid => $composableBuilder(
    column: $table.rootCid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get embedJson => $composableBuilder(
    column: $table.embedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaPaths => $composableBuilder(
    column: $table.mediaPaths,
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

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
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

  ColumnOrderings<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyUri => $composableBuilder(
    column: $table.replyUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyCid => $composableBuilder(
    column: $table.replyCid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootUri => $composableBuilder(
    column: $table.rootUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootCid => $composableBuilder(
    column: $table.rootCid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get embedJson => $composableBuilder(
    column: $table.embedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaPaths => $composableBuilder(
    column: $table.mediaPaths,
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

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get replyUri =>
      $composableBuilder(column: $table.replyUri, builder: (column) => column);

  GeneratedColumn<String> get replyCid =>
      $composableBuilder(column: $table.replyCid, builder: (column) => column);

  GeneratedColumn<String> get rootUri =>
      $composableBuilder(column: $table.rootUri, builder: (column) => column);

  GeneratedColumn<String> get rootCid =>
      $composableBuilder(column: $table.rootCid, builder: (column) => column);

  GeneratedColumn<String> get embedJson =>
      $composableBuilder(column: $table.embedJson, builder: (column) => column);

  GeneratedColumn<String> get mediaPaths => $composableBuilder(
    column: $table.mediaPaths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );
}

class $$DraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftsTable,
          DraftEntry,
          $$DraftsTableFilterComposer,
          $$DraftsTableOrderingComposer,
          $$DraftsTableAnnotationComposer,
          $$DraftsTableCreateCompanionBuilder,
          $$DraftsTableUpdateCompanionBuilder,
          (DraftEntry, BaseReferences<_$AppDatabase, $DraftsTable, DraftEntry>),
          DraftEntry,
          PrefetchHooks Function()
        > {
  $$DraftsTableTableManager(_$AppDatabase db, $DraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> accountDid = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> replyUri = const Value.absent(),
                Value<String?> replyCid = const Value.absent(),
                Value<String?> rootUri = const Value.absent(),
                Value<String?> rootCid = const Value.absent(),
                Value<String?> embedJson = const Value.absent(),
                Value<String?> mediaPaths = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
              }) => DraftsCompanion(
                id: id,
                accountDid: accountDid,
                content: content,
                replyUri: replyUri,
                replyCid: replyCid,
                rootUri: rootUri,
                rootCid: rootCid,
                embedJson: embedJson,
                mediaPaths: mediaPaths,
                createdAt: createdAt,
                updatedAt: updatedAt,
                scheduledAt: scheduledAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String accountDid,
                required String content,
                Value<String?> replyUri = const Value.absent(),
                Value<String?> replyCid = const Value.absent(),
                Value<String?> rootUri = const Value.absent(),
                Value<String?> rootCid = const Value.absent(),
                Value<String?> embedJson = const Value.absent(),
                Value<String?> mediaPaths = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
              }) => DraftsCompanion.insert(
                id: id,
                accountDid: accountDid,
                content: content,
                replyUri: replyUri,
                replyCid: replyCid,
                rootUri: rootUri,
                rootCid: rootCid,
                embedJson: embedJson,
                mediaPaths: mediaPaths,
                createdAt: createdAt,
                updatedAt: updatedAt,
                scheduledAt: scheduledAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftsTable,
      DraftEntry,
      $$DraftsTableFilterComposer,
      $$DraftsTableOrderingComposer,
      $$DraftsTableAnnotationComposer,
      $$DraftsTableCreateCompanionBuilder,
      $$DraftsTableUpdateCompanionBuilder,
      (DraftEntry, BaseReferences<_$AppDatabase, $DraftsTable, DraftEntry>),
      DraftEntry,
      PrefetchHooks Function()
    >;
typedef $$SavedPostsTableCreateCompanionBuilder =
    SavedPostsCompanion Function({
      Value<int> id,
      required String accountDid,
      required String postUri,
      required String postJson,
      Value<DateTime> savedAt,
    });
typedef $$SavedPostsTableUpdateCompanionBuilder =
    SavedPostsCompanion Function({
      Value<int> id,
      Value<String> accountDid,
      Value<String> postUri,
      Value<String> postJson,
      Value<DateTime> savedAt,
    });

class $$SavedPostsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedPostsTable> {
  $$SavedPostsTableFilterComposer({
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

  ColumnFilters<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postUri => $composableBuilder(
    column: $table.postUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postJson => $composableBuilder(
    column: $table.postJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedPostsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedPostsTable> {
  $$SavedPostsTableOrderingComposer({
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

  ColumnOrderings<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postUri => $composableBuilder(
    column: $table.postUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postJson => $composableBuilder(
    column: $table.postJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedPostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedPostsTable> {
  $$SavedPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountDid => $composableBuilder(
    column: $table.accountDid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postUri =>
      $composableBuilder(column: $table.postUri, builder: (column) => column);

  GeneratedColumn<String> get postJson =>
      $composableBuilder(column: $table.postJson, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$SavedPostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedPostsTable,
          SavedPostEntry,
          $$SavedPostsTableFilterComposer,
          $$SavedPostsTableOrderingComposer,
          $$SavedPostsTableAnnotationComposer,
          $$SavedPostsTableCreateCompanionBuilder,
          $$SavedPostsTableUpdateCompanionBuilder,
          (
            SavedPostEntry,
            BaseReferences<_$AppDatabase, $SavedPostsTable, SavedPostEntry>,
          ),
          SavedPostEntry,
          PrefetchHooks Function()
        > {
  $$SavedPostsTableTableManager(_$AppDatabase db, $SavedPostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> accountDid = const Value.absent(),
                Value<String> postUri = const Value.absent(),
                Value<String> postJson = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => SavedPostsCompanion(
                id: id,
                accountDid: accountDid,
                postUri: postUri,
                postJson: postJson,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String accountDid,
                required String postUri,
                required String postJson,
                Value<DateTime> savedAt = const Value.absent(),
              }) => SavedPostsCompanion.insert(
                id: id,
                accountDid: accountDid,
                postUri: postUri,
                postJson: postJson,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedPostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedPostsTable,
      SavedPostEntry,
      $$SavedPostsTableFilterComposer,
      $$SavedPostsTableOrderingComposer,
      $$SavedPostsTableAnnotationComposer,
      $$SavedPostsTableCreateCompanionBuilder,
      $$SavedPostsTableUpdateCompanionBuilder,
      (
        SavedPostEntry,
        BaseReferences<_$AppDatabase, $SavedPostsTable, SavedPostEntry>,
      ),
      SavedPostEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CachedProfilesTableTableManager get cachedProfiles =>
      $$CachedProfilesTableTableManager(_db, _db.cachedProfiles);
  $$CachedPostsTableTableManager get cachedPosts =>
      $$CachedPostsTableTableManager(_db, _db.cachedPosts);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$SavedFeedsTableTableManager get savedFeeds =>
      $$SavedFeedsTableTableManager(_db, _db.savedFeeds);
  $$SearchHistoryTableTableManager get searchHistory =>
      $$SearchHistoryTableTableManager(_db, _db.searchHistory);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db, _db.drafts);
  $$SavedPostsTableTableManager get savedPosts =>
      $$SavedPostsTableTableManager(_db, _db.savedPosts);
}
