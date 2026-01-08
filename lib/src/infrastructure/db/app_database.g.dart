// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bannerMeta = const VerificationMeta('banner');
  @override
  late final GeneratedColumn<String> banner = GeneratedColumn<String>(
    'banner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indexedAtMeta = const VerificationMeta('indexedAt');
  @override
  late final GeneratedColumn<DateTime> indexedAt = GeneratedColumn<DateTime>(
    'indexed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pronounsMeta = const VerificationMeta('pronouns');
  @override
  late final GeneratedColumn<String> pronouns = GeneratedColumn<String>(
    'pronouns',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _websiteMeta = const VerificationMeta('website');
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verificationStatusMeta = const VerificationMeta(
    'verificationStatus',
  );
  @override
  late final GeneratedColumn<String> verificationStatus = GeneratedColumn<String>(
    'verification_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedPostUriMeta = const VerificationMeta('pinnedPostUri');
  @override
  late final GeneratedColumn<String> pinnedPostUri = GeneratedColumn<String>(
    'pinned_post_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    did,
    handle,
    displayName,
    description,
    avatar,
    banner,
    indexedAt,
    pronouns,
    website,
    createdAt,
    verificationStatus,
    labels,
    pinnedPostUri,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('did')) {
      context.handle(_didMeta, did.isAcceptableOrUnknown(data['did']!, _didMeta));
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('handle')) {
      context.handle(_handleMeta, handle.isAcceptableOrUnknown(data['handle']!, _handleMeta));
    } else if (isInserting) {
      context.missing(_handleMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(data['display_name']!, _displayNameMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(data['description']!, _descriptionMeta),
      );
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta, avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('banner')) {
      context.handle(_bannerMeta, banner.isAcceptableOrUnknown(data['banner']!, _bannerMeta));
    }
    if (data.containsKey('indexed_at')) {
      context.handle(
        _indexedAtMeta,
        indexedAt.isAcceptableOrUnknown(data['indexed_at']!, _indexedAtMeta),
      );
    }
    if (data.containsKey('pronouns')) {
      context.handle(
        _pronounsMeta,
        pronouns.isAcceptableOrUnknown(data['pronouns']!, _pronounsMeta),
      );
    }
    if (data.containsKey('website')) {
      context.handle(_websiteMeta, website.isAcceptableOrUnknown(data['website']!, _websiteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('verification_status')) {
      context.handle(
        _verificationStatusMeta,
        verificationStatus.isAcceptableOrUnknown(
          data['verification_status']!,
          _verificationStatusMeta,
        ),
      );
    }
    if (data.containsKey('labels')) {
      context.handle(_labelsMeta, labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta));
    }
    if (data.containsKey('pinned_post_uri')) {
      context.handle(
        _pinnedPostUriMeta,
        pinnedPostUri.isAcceptableOrUnknown(data['pinned_post_uri']!, _pinnedPostUriMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {did};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      did: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}did'])!,
      handle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handle'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      banner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}banner'],
      ),
      indexedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}indexed_at'],
      ),
      pronouns: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pronouns'],
      ),
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      verificationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verification_status'],
      ),
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      ),
      pinnedPostUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinned_post_uri'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String did;
  final String handle;
  final String? displayName;
  final String? description;
  final String? avatar;
  final String? banner;
  final DateTime? indexedAt;
  final String? pronouns;
  final String? website;
  final DateTime? createdAt;
  final String? verificationStatus;
  final String? labels;
  final String? pinnedPostUri;
  const Profile({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
    this.banner,
    this.indexedAt,
    this.pronouns,
    this.website,
    this.createdAt,
    this.verificationStatus,
    this.labels,
    this.pinnedPostUri,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['did'] = Variable<String>(did);
    map['handle'] = Variable<String>(handle);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || banner != null) {
      map['banner'] = Variable<String>(banner);
    }
    if (!nullToAbsent || indexedAt != null) {
      map['indexed_at'] = Variable<DateTime>(indexedAt);
    }
    if (!nullToAbsent || pronouns != null) {
      map['pronouns'] = Variable<String>(pronouns);
    }
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || verificationStatus != null) {
      map['verification_status'] = Variable<String>(verificationStatus);
    }
    if (!nullToAbsent || labels != null) {
      map['labels'] = Variable<String>(labels);
    }
    if (!nullToAbsent || pinnedPostUri != null) {
      map['pinned_post_uri'] = Variable<String>(pinnedPostUri);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      did: Value(did),
      handle: Value(handle),
      displayName: displayName == null && nullToAbsent ? const Value.absent() : Value(displayName),
      description: description == null && nullToAbsent ? const Value.absent() : Value(description),
      avatar: avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      banner: banner == null && nullToAbsent ? const Value.absent() : Value(banner),
      indexedAt: indexedAt == null && nullToAbsent ? const Value.absent() : Value(indexedAt),
      pronouns: pronouns == null && nullToAbsent ? const Value.absent() : Value(pronouns),
      website: website == null && nullToAbsent ? const Value.absent() : Value(website),
      createdAt: createdAt == null && nullToAbsent ? const Value.absent() : Value(createdAt),
      verificationStatus: verificationStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(verificationStatus),
      labels: labels == null && nullToAbsent ? const Value.absent() : Value(labels),
      pinnedPostUri: pinnedPostUri == null && nullToAbsent
          ? const Value.absent()
          : Value(pinnedPostUri),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      did: serializer.fromJson<String>(json['did']),
      handle: serializer.fromJson<String>(json['handle']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      description: serializer.fromJson<String?>(json['description']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      banner: serializer.fromJson<String?>(json['banner']),
      indexedAt: serializer.fromJson<DateTime?>(json['indexedAt']),
      pronouns: serializer.fromJson<String?>(json['pronouns']),
      website: serializer.fromJson<String?>(json['website']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      verificationStatus: serializer.fromJson<String?>(json['verificationStatus']),
      labels: serializer.fromJson<String?>(json['labels']),
      pinnedPostUri: serializer.fromJson<String?>(json['pinnedPostUri']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'did': serializer.toJson<String>(did),
      'handle': serializer.toJson<String>(handle),
      'displayName': serializer.toJson<String?>(displayName),
      'description': serializer.toJson<String?>(description),
      'avatar': serializer.toJson<String?>(avatar),
      'banner': serializer.toJson<String?>(banner),
      'indexedAt': serializer.toJson<DateTime?>(indexedAt),
      'pronouns': serializer.toJson<String?>(pronouns),
      'website': serializer.toJson<String?>(website),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'verificationStatus': serializer.toJson<String?>(verificationStatus),
      'labels': serializer.toJson<String?>(labels),
      'pinnedPostUri': serializer.toJson<String?>(pinnedPostUri),
    };
  }

  Profile copyWith({
    String? did,
    String? handle,
    Value<String?> displayName = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> avatar = const Value.absent(),
    Value<String?> banner = const Value.absent(),
    Value<DateTime?> indexedAt = const Value.absent(),
    Value<String?> pronouns = const Value.absent(),
    Value<String?> website = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<String?> verificationStatus = const Value.absent(),
    Value<String?> labels = const Value.absent(),
    Value<String?> pinnedPostUri = const Value.absent(),
  }) => Profile(
    did: did ?? this.did,
    handle: handle ?? this.handle,
    displayName: displayName.present ? displayName.value : this.displayName,
    description: description.present ? description.value : this.description,
    avatar: avatar.present ? avatar.value : this.avatar,
    banner: banner.present ? banner.value : this.banner,
    indexedAt: indexedAt.present ? indexedAt.value : this.indexedAt,
    pronouns: pronouns.present ? pronouns.value : this.pronouns,
    website: website.present ? website.value : this.website,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    verificationStatus: verificationStatus.present
        ? verificationStatus.value
        : this.verificationStatus,
    labels: labels.present ? labels.value : this.labels,
    pinnedPostUri: pinnedPostUri.present ? pinnedPostUri.value : this.pinnedPostUri,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      did: data.did.present ? data.did.value : this.did,
      handle: data.handle.present ? data.handle.value : this.handle,
      displayName: data.displayName.present ? data.displayName.value : this.displayName,
      description: data.description.present ? data.description.value : this.description,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      banner: data.banner.present ? data.banner.value : this.banner,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
      pronouns: data.pronouns.present ? data.pronouns.value : this.pronouns,
      website: data.website.present ? data.website.value : this.website,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      verificationStatus: data.verificationStatus.present
          ? data.verificationStatus.value
          : this.verificationStatus,
      labels: data.labels.present ? data.labels.value : this.labels,
      pinnedPostUri: data.pinnedPostUri.present ? data.pinnedPostUri.value : this.pinnedPostUri,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('did: $did, ')
          ..write('handle: $handle, ')
          ..write('displayName: $displayName, ')
          ..write('description: $description, ')
          ..write('avatar: $avatar, ')
          ..write('banner: $banner, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('pronouns: $pronouns, ')
          ..write('website: $website, ')
          ..write('createdAt: $createdAt, ')
          ..write('verificationStatus: $verificationStatus, ')
          ..write('labels: $labels, ')
          ..write('pinnedPostUri: $pinnedPostUri')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    did,
    handle,
    displayName,
    description,
    avatar,
    banner,
    indexedAt,
    pronouns,
    website,
    createdAt,
    verificationStatus,
    labels,
    pinnedPostUri,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.did == this.did &&
          other.handle == this.handle &&
          other.displayName == this.displayName &&
          other.description == this.description &&
          other.avatar == this.avatar &&
          other.banner == this.banner &&
          other.indexedAt == this.indexedAt &&
          other.pronouns == this.pronouns &&
          other.website == this.website &&
          other.createdAt == this.createdAt &&
          other.verificationStatus == this.verificationStatus &&
          other.labels == this.labels &&
          other.pinnedPostUri == this.pinnedPostUri);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> did;
  final Value<String> handle;
  final Value<String?> displayName;
  final Value<String?> description;
  final Value<String?> avatar;
  final Value<String?> banner;
  final Value<DateTime?> indexedAt;
  final Value<String?> pronouns;
  final Value<String?> website;
  final Value<DateTime?> createdAt;
  final Value<String?> verificationStatus;
  final Value<String?> labels;
  final Value<String?> pinnedPostUri;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.did = const Value.absent(),
    this.handle = const Value.absent(),
    this.displayName = const Value.absent(),
    this.description = const Value.absent(),
    this.avatar = const Value.absent(),
    this.banner = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.pronouns = const Value.absent(),
    this.website = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.verificationStatus = const Value.absent(),
    this.labels = const Value.absent(),
    this.pinnedPostUri = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String did,
    required String handle,
    this.displayName = const Value.absent(),
    this.description = const Value.absent(),
    this.avatar = const Value.absent(),
    this.banner = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.pronouns = const Value.absent(),
    this.website = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.verificationStatus = const Value.absent(),
    this.labels = const Value.absent(),
    this.pinnedPostUri = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : did = Value(did),
       handle = Value(handle);
  static Insertable<Profile> custom({
    Expression<String>? did,
    Expression<String>? handle,
    Expression<String>? displayName,
    Expression<String>? description,
    Expression<String>? avatar,
    Expression<String>? banner,
    Expression<DateTime>? indexedAt,
    Expression<String>? pronouns,
    Expression<String>? website,
    Expression<DateTime>? createdAt,
    Expression<String>? verificationStatus,
    Expression<String>? labels,
    Expression<String>? pinnedPostUri,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (did != null) 'did': did,
      if (handle != null) 'handle': handle,
      if (displayName != null) 'display_name': displayName,
      if (description != null) 'description': description,
      if (avatar != null) 'avatar': avatar,
      if (banner != null) 'banner': banner,
      if (indexedAt != null) 'indexed_at': indexedAt,
      if (pronouns != null) 'pronouns': pronouns,
      if (website != null) 'website': website,
      if (createdAt != null) 'created_at': createdAt,
      if (verificationStatus != null) 'verification_status': verificationStatus,
      if (labels != null) 'labels': labels,
      if (pinnedPostUri != null) 'pinned_post_uri': pinnedPostUri,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? did,
    Value<String>? handle,
    Value<String?>? displayName,
    Value<String?>? description,
    Value<String?>? avatar,
    Value<String?>? banner,
    Value<DateTime?>? indexedAt,
    Value<String?>? pronouns,
    Value<String?>? website,
    Value<DateTime?>? createdAt,
    Value<String?>? verificationStatus,
    Value<String?>? labels,
    Value<String?>? pinnedPostUri,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      did: did ?? this.did,
      handle: handle ?? this.handle,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      banner: banner ?? this.banner,
      indexedAt: indexedAt ?? this.indexedAt,
      pronouns: pronouns ?? this.pronouns,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      labels: labels ?? this.labels,
      pinnedPostUri: pinnedPostUri ?? this.pinnedPostUri,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (banner.present) {
      map['banner'] = Variable<String>(banner.value);
    }
    if (indexedAt.present) {
      map['indexed_at'] = Variable<DateTime>(indexedAt.value);
    }
    if (pronouns.present) {
      map['pronouns'] = Variable<String>(pronouns.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (verificationStatus.present) {
      map['verification_status'] = Variable<String>(verificationStatus.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (pinnedPostUri.present) {
      map['pinned_post_uri'] = Variable<String>(pinnedPostUri.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('did: $did, ')
          ..write('handle: $handle, ')
          ..write('displayName: $displayName, ')
          ..write('description: $description, ')
          ..write('avatar: $avatar, ')
          ..write('banner: $banner, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('pronouns: $pronouns, ')
          ..write('website: $website, ')
          ..write('createdAt: $createdAt, ')
          ..write('verificationStatus: $verificationStatus, ')
          ..write('labels: $labels, ')
          ..write('pinnedPostUri: $pinnedPostUri, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostsTable extends Posts with TableInfo<$PostsTable, Post> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cidMeta = const VerificationMeta('cid');
  @override
  late final GeneratedColumn<String> cid = GeneratedColumn<String>(
    'cid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorDidMeta = const VerificationMeta('authorDid');
  @override
  late final GeneratedColumn<String> authorDid = GeneratedColumn<String>(
    'author_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES profiles (did)'),
  );
  static const VerificationMeta _recordMeta = const VerificationMeta('record');
  @override
  late final GeneratedColumn<String> record = GeneratedColumn<String>(
    'record',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _embedMeta = const VerificationMeta('embed');
  @override
  late final GeneratedColumn<String> embed = GeneratedColumn<String>(
    'embed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indexedAtMeta = const VerificationMeta('indexedAt');
  @override
  late final GeneratedColumn<DateTime> indexedAt = GeneratedColumn<DateTime>(
    'indexed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyCountMeta = const VerificationMeta('replyCount');
  @override
  late final GeneratedColumn<int> replyCount = GeneratedColumn<int>(
    'reply_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repostCountMeta = const VerificationMeta('repostCount');
  @override
  late final GeneratedColumn<int> repostCount = GeneratedColumn<int>(
    'repost_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta('likeCount');
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quoteCountMeta = const VerificationMeta('quoteCount');
  @override
  late final GeneratedColumn<int> quoteCount = GeneratedColumn<int>(
    'quote_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bookmarkCountMeta = const VerificationMeta('bookmarkCount');
  @override
  late final GeneratedColumn<int> bookmarkCount = GeneratedColumn<int>(
    'bookmark_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewerLikeUriMeta = const VerificationMeta('viewerLikeUri');
  @override
  late final GeneratedColumn<String> viewerLikeUri = GeneratedColumn<String>(
    'viewer_like_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewerRepostUriMeta = const VerificationMeta('viewerRepostUri');
  @override
  late final GeneratedColumn<String> viewerRepostUri = GeneratedColumn<String>(
    'viewer_repost_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewerBookmarkedMeta = const VerificationMeta('viewerBookmarked');
  @override
  late final GeneratedColumn<bool> viewerBookmarked = GeneratedColumn<bool>(
    'viewer_bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("viewer_bookmarked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _viewerThreadMutedMeta = const VerificationMeta(
    'viewerThreadMuted',
  );
  @override
  late final GeneratedColumn<bool> viewerThreadMuted = GeneratedColumn<bool>(
    'viewer_thread_muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("viewer_thread_muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _viewerReplyDisabledMeta = const VerificationMeta(
    'viewerReplyDisabled',
  );
  @override
  late final GeneratedColumn<bool> viewerReplyDisabled = GeneratedColumn<bool>(
    'viewer_reply_disabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("viewer_reply_disabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    uri,
    cid,
    authorDid,
    record,
    embed,
    indexedAt,
    replyCount,
    repostCount,
    likeCount,
    quoteCount,
    bookmarkCount,
    labels,
    viewerLikeUri,
    viewerRepostUri,
    viewerBookmarked,
    viewerThreadMuted,
    viewerReplyDisabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(Insertable<Post> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uri')) {
      context.handle(_uriMeta, uri.isAcceptableOrUnknown(data['uri']!, _uriMeta));
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('cid')) {
      context.handle(_cidMeta, cid.isAcceptableOrUnknown(data['cid']!, _cidMeta));
    } else if (isInserting) {
      context.missing(_cidMeta);
    }
    if (data.containsKey('author_did')) {
      context.handle(
        _authorDidMeta,
        authorDid.isAcceptableOrUnknown(data['author_did']!, _authorDidMeta),
      );
    } else if (isInserting) {
      context.missing(_authorDidMeta);
    }
    if (data.containsKey('record')) {
      context.handle(_recordMeta, record.isAcceptableOrUnknown(data['record']!, _recordMeta));
    } else if (isInserting) {
      context.missing(_recordMeta);
    }
    if (data.containsKey('embed')) {
      context.handle(_embedMeta, embed.isAcceptableOrUnknown(data['embed']!, _embedMeta));
    }
    if (data.containsKey('indexed_at')) {
      context.handle(
        _indexedAtMeta,
        indexedAt.isAcceptableOrUnknown(data['indexed_at']!, _indexedAtMeta),
      );
    }
    if (data.containsKey('reply_count')) {
      context.handle(
        _replyCountMeta,
        replyCount.isAcceptableOrUnknown(data['reply_count']!, _replyCountMeta),
      );
    }
    if (data.containsKey('repost_count')) {
      context.handle(
        _repostCountMeta,
        repostCount.isAcceptableOrUnknown(data['repost_count']!, _repostCountMeta),
      );
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    }
    if (data.containsKey('quote_count')) {
      context.handle(
        _quoteCountMeta,
        quoteCount.isAcceptableOrUnknown(data['quote_count']!, _quoteCountMeta),
      );
    }
    if (data.containsKey('bookmark_count')) {
      context.handle(
        _bookmarkCountMeta,
        bookmarkCount.isAcceptableOrUnknown(data['bookmark_count']!, _bookmarkCountMeta),
      );
    }
    if (data.containsKey('labels')) {
      context.handle(_labelsMeta, labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta));
    }
    if (data.containsKey('viewer_like_uri')) {
      context.handle(
        _viewerLikeUriMeta,
        viewerLikeUri.isAcceptableOrUnknown(data['viewer_like_uri']!, _viewerLikeUriMeta),
      );
    }
    if (data.containsKey('viewer_repost_uri')) {
      context.handle(
        _viewerRepostUriMeta,
        viewerRepostUri.isAcceptableOrUnknown(data['viewer_repost_uri']!, _viewerRepostUriMeta),
      );
    }
    if (data.containsKey('viewer_bookmarked')) {
      context.handle(
        _viewerBookmarkedMeta,
        viewerBookmarked.isAcceptableOrUnknown(data['viewer_bookmarked']!, _viewerBookmarkedMeta),
      );
    }
    if (data.containsKey('viewer_thread_muted')) {
      context.handle(
        _viewerThreadMutedMeta,
        viewerThreadMuted.isAcceptableOrUnknown(
          data['viewer_thread_muted']!,
          _viewerThreadMutedMeta,
        ),
      );
    }
    if (data.containsKey('viewer_reply_disabled')) {
      context.handle(
        _viewerReplyDisabledMeta,
        viewerReplyDisabled.isAcceptableOrUnknown(
          data['viewer_reply_disabled']!,
          _viewerReplyDisabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uri};
  @override
  Post map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Post(
      uri: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uri'])!,
      cid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cid'])!,
      authorDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_did'],
      )!,
      record: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record'],
      )!,
      embed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}embed'],
      ),
      indexedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}indexed_at'],
      ),
      replyCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reply_count'],
      )!,
      repostCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repost_count'],
      )!,
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      )!,
      quoteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quote_count'],
      )!,
      bookmarkCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bookmark_count'],
      )!,
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      ),
      viewerLikeUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}viewer_like_uri'],
      ),
      viewerRepostUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}viewer_repost_uri'],
      ),
      viewerBookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}viewer_bookmarked'],
      )!,
      viewerThreadMuted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}viewer_thread_muted'],
      )!,
      viewerReplyDisabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}viewer_reply_disabled'],
      )!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class Post extends DataClass implements Insertable<Post> {
  final String uri;
  final String cid;
  final String authorDid;
  final String record;
  final String? embed;
  final DateTime? indexedAt;
  final int replyCount;
  final int repostCount;
  final int likeCount;
  final int quoteCount;
  final int bookmarkCount;
  final String? labels;
  final String? viewerLikeUri;
  final String? viewerRepostUri;
  final bool viewerBookmarked;
  final bool viewerThreadMuted;
  final bool viewerReplyDisabled;
  const Post({
    required this.uri,
    required this.cid,
    required this.authorDid,
    required this.record,
    this.embed,
    this.indexedAt,
    required this.replyCount,
    required this.repostCount,
    required this.likeCount,
    required this.quoteCount,
    required this.bookmarkCount,
    this.labels,
    this.viewerLikeUri,
    this.viewerRepostUri,
    required this.viewerBookmarked,
    required this.viewerThreadMuted,
    required this.viewerReplyDisabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uri'] = Variable<String>(uri);
    map['cid'] = Variable<String>(cid);
    map['author_did'] = Variable<String>(authorDid);
    map['record'] = Variable<String>(record);
    if (!nullToAbsent || embed != null) {
      map['embed'] = Variable<String>(embed);
    }
    if (!nullToAbsent || indexedAt != null) {
      map['indexed_at'] = Variable<DateTime>(indexedAt);
    }
    map['reply_count'] = Variable<int>(replyCount);
    map['repost_count'] = Variable<int>(repostCount);
    map['like_count'] = Variable<int>(likeCount);
    map['quote_count'] = Variable<int>(quoteCount);
    map['bookmark_count'] = Variable<int>(bookmarkCount);
    if (!nullToAbsent || labels != null) {
      map['labels'] = Variable<String>(labels);
    }
    if (!nullToAbsent || viewerLikeUri != null) {
      map['viewer_like_uri'] = Variable<String>(viewerLikeUri);
    }
    if (!nullToAbsent || viewerRepostUri != null) {
      map['viewer_repost_uri'] = Variable<String>(viewerRepostUri);
    }
    map['viewer_bookmarked'] = Variable<bool>(viewerBookmarked);
    map['viewer_thread_muted'] = Variable<bool>(viewerThreadMuted);
    map['viewer_reply_disabled'] = Variable<bool>(viewerReplyDisabled);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      uri: Value(uri),
      cid: Value(cid),
      authorDid: Value(authorDid),
      record: Value(record),
      embed: embed == null && nullToAbsent ? const Value.absent() : Value(embed),
      indexedAt: indexedAt == null && nullToAbsent ? const Value.absent() : Value(indexedAt),
      replyCount: Value(replyCount),
      repostCount: Value(repostCount),
      likeCount: Value(likeCount),
      quoteCount: Value(quoteCount),
      bookmarkCount: Value(bookmarkCount),
      labels: labels == null && nullToAbsent ? const Value.absent() : Value(labels),
      viewerLikeUri: viewerLikeUri == null && nullToAbsent
          ? const Value.absent()
          : Value(viewerLikeUri),
      viewerRepostUri: viewerRepostUri == null && nullToAbsent
          ? const Value.absent()
          : Value(viewerRepostUri),
      viewerBookmarked: Value(viewerBookmarked),
      viewerThreadMuted: Value(viewerThreadMuted),
      viewerReplyDisabled: Value(viewerReplyDisabled),
    );
  }

  factory Post.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Post(
      uri: serializer.fromJson<String>(json['uri']),
      cid: serializer.fromJson<String>(json['cid']),
      authorDid: serializer.fromJson<String>(json['authorDid']),
      record: serializer.fromJson<String>(json['record']),
      embed: serializer.fromJson<String?>(json['embed']),
      indexedAt: serializer.fromJson<DateTime?>(json['indexedAt']),
      replyCount: serializer.fromJson<int>(json['replyCount']),
      repostCount: serializer.fromJson<int>(json['repostCount']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      quoteCount: serializer.fromJson<int>(json['quoteCount']),
      bookmarkCount: serializer.fromJson<int>(json['bookmarkCount']),
      labels: serializer.fromJson<String?>(json['labels']),
      viewerLikeUri: serializer.fromJson<String?>(json['viewerLikeUri']),
      viewerRepostUri: serializer.fromJson<String?>(json['viewerRepostUri']),
      viewerBookmarked: serializer.fromJson<bool>(json['viewerBookmarked']),
      viewerThreadMuted: serializer.fromJson<bool>(json['viewerThreadMuted']),
      viewerReplyDisabled: serializer.fromJson<bool>(json['viewerReplyDisabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uri': serializer.toJson<String>(uri),
      'cid': serializer.toJson<String>(cid),
      'authorDid': serializer.toJson<String>(authorDid),
      'record': serializer.toJson<String>(record),
      'embed': serializer.toJson<String?>(embed),
      'indexedAt': serializer.toJson<DateTime?>(indexedAt),
      'replyCount': serializer.toJson<int>(replyCount),
      'repostCount': serializer.toJson<int>(repostCount),
      'likeCount': serializer.toJson<int>(likeCount),
      'quoteCount': serializer.toJson<int>(quoteCount),
      'bookmarkCount': serializer.toJson<int>(bookmarkCount),
      'labels': serializer.toJson<String?>(labels),
      'viewerLikeUri': serializer.toJson<String?>(viewerLikeUri),
      'viewerRepostUri': serializer.toJson<String?>(viewerRepostUri),
      'viewerBookmarked': serializer.toJson<bool>(viewerBookmarked),
      'viewerThreadMuted': serializer.toJson<bool>(viewerThreadMuted),
      'viewerReplyDisabled': serializer.toJson<bool>(viewerReplyDisabled),
    };
  }

  Post copyWith({
    String? uri,
    String? cid,
    String? authorDid,
    String? record,
    Value<String?> embed = const Value.absent(),
    Value<DateTime?> indexedAt = const Value.absent(),
    int? replyCount,
    int? repostCount,
    int? likeCount,
    int? quoteCount,
    int? bookmarkCount,
    Value<String?> labels = const Value.absent(),
    Value<String?> viewerLikeUri = const Value.absent(),
    Value<String?> viewerRepostUri = const Value.absent(),
    bool? viewerBookmarked,
    bool? viewerThreadMuted,
    bool? viewerReplyDisabled,
  }) => Post(
    uri: uri ?? this.uri,
    cid: cid ?? this.cid,
    authorDid: authorDid ?? this.authorDid,
    record: record ?? this.record,
    embed: embed.present ? embed.value : this.embed,
    indexedAt: indexedAt.present ? indexedAt.value : this.indexedAt,
    replyCount: replyCount ?? this.replyCount,
    repostCount: repostCount ?? this.repostCount,
    likeCount: likeCount ?? this.likeCount,
    quoteCount: quoteCount ?? this.quoteCount,
    bookmarkCount: bookmarkCount ?? this.bookmarkCount,
    labels: labels.present ? labels.value : this.labels,
    viewerLikeUri: viewerLikeUri.present ? viewerLikeUri.value : this.viewerLikeUri,
    viewerRepostUri: viewerRepostUri.present ? viewerRepostUri.value : this.viewerRepostUri,
    viewerBookmarked: viewerBookmarked ?? this.viewerBookmarked,
    viewerThreadMuted: viewerThreadMuted ?? this.viewerThreadMuted,
    viewerReplyDisabled: viewerReplyDisabled ?? this.viewerReplyDisabled,
  );
  Post copyWithCompanion(PostsCompanion data) {
    return Post(
      uri: data.uri.present ? data.uri.value : this.uri,
      cid: data.cid.present ? data.cid.value : this.cid,
      authorDid: data.authorDid.present ? data.authorDid.value : this.authorDid,
      record: data.record.present ? data.record.value : this.record,
      embed: data.embed.present ? data.embed.value : this.embed,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
      replyCount: data.replyCount.present ? data.replyCount.value : this.replyCount,
      repostCount: data.repostCount.present ? data.repostCount.value : this.repostCount,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      quoteCount: data.quoteCount.present ? data.quoteCount.value : this.quoteCount,
      bookmarkCount: data.bookmarkCount.present ? data.bookmarkCount.value : this.bookmarkCount,
      labels: data.labels.present ? data.labels.value : this.labels,
      viewerLikeUri: data.viewerLikeUri.present ? data.viewerLikeUri.value : this.viewerLikeUri,
      viewerRepostUri: data.viewerRepostUri.present
          ? data.viewerRepostUri.value
          : this.viewerRepostUri,
      viewerBookmarked: data.viewerBookmarked.present
          ? data.viewerBookmarked.value
          : this.viewerBookmarked,
      viewerThreadMuted: data.viewerThreadMuted.present
          ? data.viewerThreadMuted.value
          : this.viewerThreadMuted,
      viewerReplyDisabled: data.viewerReplyDisabled.present
          ? data.viewerReplyDisabled.value
          : this.viewerReplyDisabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Post(')
          ..write('uri: $uri, ')
          ..write('cid: $cid, ')
          ..write('authorDid: $authorDid, ')
          ..write('record: $record, ')
          ..write('embed: $embed, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('replyCount: $replyCount, ')
          ..write('repostCount: $repostCount, ')
          ..write('likeCount: $likeCount, ')
          ..write('quoteCount: $quoteCount, ')
          ..write('bookmarkCount: $bookmarkCount, ')
          ..write('labels: $labels, ')
          ..write('viewerLikeUri: $viewerLikeUri, ')
          ..write('viewerRepostUri: $viewerRepostUri, ')
          ..write('viewerBookmarked: $viewerBookmarked, ')
          ..write('viewerThreadMuted: $viewerThreadMuted, ')
          ..write('viewerReplyDisabled: $viewerReplyDisabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uri,
    cid,
    authorDid,
    record,
    embed,
    indexedAt,
    replyCount,
    repostCount,
    likeCount,
    quoteCount,
    bookmarkCount,
    labels,
    viewerLikeUri,
    viewerRepostUri,
    viewerBookmarked,
    viewerThreadMuted,
    viewerReplyDisabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Post &&
          other.uri == this.uri &&
          other.cid == this.cid &&
          other.authorDid == this.authorDid &&
          other.record == this.record &&
          other.embed == this.embed &&
          other.indexedAt == this.indexedAt &&
          other.replyCount == this.replyCount &&
          other.repostCount == this.repostCount &&
          other.likeCount == this.likeCount &&
          other.quoteCount == this.quoteCount &&
          other.bookmarkCount == this.bookmarkCount &&
          other.labels == this.labels &&
          other.viewerLikeUri == this.viewerLikeUri &&
          other.viewerRepostUri == this.viewerRepostUri &&
          other.viewerBookmarked == this.viewerBookmarked &&
          other.viewerThreadMuted == this.viewerThreadMuted &&
          other.viewerReplyDisabled == this.viewerReplyDisabled);
}

class PostsCompanion extends UpdateCompanion<Post> {
  final Value<String> uri;
  final Value<String> cid;
  final Value<String> authorDid;
  final Value<String> record;
  final Value<String?> embed;
  final Value<DateTime?> indexedAt;
  final Value<int> replyCount;
  final Value<int> repostCount;
  final Value<int> likeCount;
  final Value<int> quoteCount;
  final Value<int> bookmarkCount;
  final Value<String?> labels;
  final Value<String?> viewerLikeUri;
  final Value<String?> viewerRepostUri;
  final Value<bool> viewerBookmarked;
  final Value<bool> viewerThreadMuted;
  final Value<bool> viewerReplyDisabled;
  final Value<int> rowid;
  const PostsCompanion({
    this.uri = const Value.absent(),
    this.cid = const Value.absent(),
    this.authorDid = const Value.absent(),
    this.record = const Value.absent(),
    this.embed = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.repostCount = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.quoteCount = const Value.absent(),
    this.bookmarkCount = const Value.absent(),
    this.labels = const Value.absent(),
    this.viewerLikeUri = const Value.absent(),
    this.viewerRepostUri = const Value.absent(),
    this.viewerBookmarked = const Value.absent(),
    this.viewerThreadMuted = const Value.absent(),
    this.viewerReplyDisabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsCompanion.insert({
    required String uri,
    required String cid,
    required String authorDid,
    required String record,
    this.embed = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.replyCount = const Value.absent(),
    this.repostCount = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.quoteCount = const Value.absent(),
    this.bookmarkCount = const Value.absent(),
    this.labels = const Value.absent(),
    this.viewerLikeUri = const Value.absent(),
    this.viewerRepostUri = const Value.absent(),
    this.viewerBookmarked = const Value.absent(),
    this.viewerThreadMuted = const Value.absent(),
    this.viewerReplyDisabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uri = Value(uri),
       cid = Value(cid),
       authorDid = Value(authorDid),
       record = Value(record);
  static Insertable<Post> custom({
    Expression<String>? uri,
    Expression<String>? cid,
    Expression<String>? authorDid,
    Expression<String>? record,
    Expression<String>? embed,
    Expression<DateTime>? indexedAt,
    Expression<int>? replyCount,
    Expression<int>? repostCount,
    Expression<int>? likeCount,
    Expression<int>? quoteCount,
    Expression<int>? bookmarkCount,
    Expression<String>? labels,
    Expression<String>? viewerLikeUri,
    Expression<String>? viewerRepostUri,
    Expression<bool>? viewerBookmarked,
    Expression<bool>? viewerThreadMuted,
    Expression<bool>? viewerReplyDisabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uri != null) 'uri': uri,
      if (cid != null) 'cid': cid,
      if (authorDid != null) 'author_did': authorDid,
      if (record != null) 'record': record,
      if (embed != null) 'embed': embed,
      if (indexedAt != null) 'indexed_at': indexedAt,
      if (replyCount != null) 'reply_count': replyCount,
      if (repostCount != null) 'repost_count': repostCount,
      if (likeCount != null) 'like_count': likeCount,
      if (quoteCount != null) 'quote_count': quoteCount,
      if (bookmarkCount != null) 'bookmark_count': bookmarkCount,
      if (labels != null) 'labels': labels,
      if (viewerLikeUri != null) 'viewer_like_uri': viewerLikeUri,
      if (viewerRepostUri != null) 'viewer_repost_uri': viewerRepostUri,
      if (viewerBookmarked != null) 'viewer_bookmarked': viewerBookmarked,
      if (viewerThreadMuted != null) 'viewer_thread_muted': viewerThreadMuted,
      if (viewerReplyDisabled != null) 'viewer_reply_disabled': viewerReplyDisabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsCompanion copyWith({
    Value<String>? uri,
    Value<String>? cid,
    Value<String>? authorDid,
    Value<String>? record,
    Value<String?>? embed,
    Value<DateTime?>? indexedAt,
    Value<int>? replyCount,
    Value<int>? repostCount,
    Value<int>? likeCount,
    Value<int>? quoteCount,
    Value<int>? bookmarkCount,
    Value<String?>? labels,
    Value<String?>? viewerLikeUri,
    Value<String?>? viewerRepostUri,
    Value<bool>? viewerBookmarked,
    Value<bool>? viewerThreadMuted,
    Value<bool>? viewerReplyDisabled,
    Value<int>? rowid,
  }) {
    return PostsCompanion(
      uri: uri ?? this.uri,
      cid: cid ?? this.cid,
      authorDid: authorDid ?? this.authorDid,
      record: record ?? this.record,
      embed: embed ?? this.embed,
      indexedAt: indexedAt ?? this.indexedAt,
      replyCount: replyCount ?? this.replyCount,
      repostCount: repostCount ?? this.repostCount,
      likeCount: likeCount ?? this.likeCount,
      quoteCount: quoteCount ?? this.quoteCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      labels: labels ?? this.labels,
      viewerLikeUri: viewerLikeUri ?? this.viewerLikeUri,
      viewerRepostUri: viewerRepostUri ?? this.viewerRepostUri,
      viewerBookmarked: viewerBookmarked ?? this.viewerBookmarked,
      viewerThreadMuted: viewerThreadMuted ?? this.viewerThreadMuted,
      viewerReplyDisabled: viewerReplyDisabled ?? this.viewerReplyDisabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (cid.present) {
      map['cid'] = Variable<String>(cid.value);
    }
    if (authorDid.present) {
      map['author_did'] = Variable<String>(authorDid.value);
    }
    if (record.present) {
      map['record'] = Variable<String>(record.value);
    }
    if (embed.present) {
      map['embed'] = Variable<String>(embed.value);
    }
    if (indexedAt.present) {
      map['indexed_at'] = Variable<DateTime>(indexedAt.value);
    }
    if (replyCount.present) {
      map['reply_count'] = Variable<int>(replyCount.value);
    }
    if (repostCount.present) {
      map['repost_count'] = Variable<int>(repostCount.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (quoteCount.present) {
      map['quote_count'] = Variable<int>(quoteCount.value);
    }
    if (bookmarkCount.present) {
      map['bookmark_count'] = Variable<int>(bookmarkCount.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (viewerLikeUri.present) {
      map['viewer_like_uri'] = Variable<String>(viewerLikeUri.value);
    }
    if (viewerRepostUri.present) {
      map['viewer_repost_uri'] = Variable<String>(viewerRepostUri.value);
    }
    if (viewerBookmarked.present) {
      map['viewer_bookmarked'] = Variable<bool>(viewerBookmarked.value);
    }
    if (viewerThreadMuted.present) {
      map['viewer_thread_muted'] = Variable<bool>(viewerThreadMuted.value);
    }
    if (viewerReplyDisabled.present) {
      map['viewer_reply_disabled'] = Variable<bool>(viewerReplyDisabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('uri: $uri, ')
          ..write('cid: $cid, ')
          ..write('authorDid: $authorDid, ')
          ..write('record: $record, ')
          ..write('embed: $embed, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('replyCount: $replyCount, ')
          ..write('repostCount: $repostCount, ')
          ..write('likeCount: $likeCount, ')
          ..write('quoteCount: $quoteCount, ')
          ..write('bookmarkCount: $bookmarkCount, ')
          ..write('labels: $labels, ')
          ..write('viewerLikeUri: $viewerLikeUri, ')
          ..write('viewerRepostUri: $viewerRepostUri, ')
          ..write('viewerBookmarked: $viewerBookmarked, ')
          ..write('viewerThreadMuted: $viewerThreadMuted, ')
          ..write('viewerReplyDisabled: $viewerReplyDisabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedContentItemsTable extends FeedContentItems
    with TableInfo<$FeedContentItemsTable, FeedContentItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedContentItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedKeyMeta = const VerificationMeta('feedKey');
  @override
  late final GeneratedColumn<String> feedKey = GeneratedColumn<String>(
    'feed_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postUriMeta = const VerificationMeta('postUri');
  @override
  late final GeneratedColumn<String> postUri = GeneratedColumn<String>(
    'post_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES posts (uri)'),
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [feedKey, postUri, ownerDid, reason, sortKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_content_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedContentItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_key')) {
      context.handle(_feedKeyMeta, feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta));
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
    }
    if (data.containsKey('post_uri')) {
      context.handle(_postUriMeta, postUri.isAcceptableOrUnknown(data['post_uri']!, _postUriMeta));
    } else if (isInserting) {
      context.missing(_postUriMeta);
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta, reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta, sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedKey, postUri, ownerDid};
  @override
  FeedContentItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedContentItem(
      feedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_key'],
      )!,
      postUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_uri'],
      )!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      sortKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_key'],
      )!,
    );
  }

  @override
  $FeedContentItemsTable createAlias(String alias) {
    return $FeedContentItemsTable(attachedDatabase, alias);
  }
}

class FeedContentItem extends DataClass implements Insertable<FeedContentItem> {
  final String feedKey;
  final String postUri;
  final String ownerDid;
  final String? reason;
  final String sortKey;
  const FeedContentItem({
    required this.feedKey,
    required this.postUri,
    required this.ownerDid,
    this.reason,
    required this.sortKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_key'] = Variable<String>(feedKey);
    map['post_uri'] = Variable<String>(postUri);
    map['owner_did'] = Variable<String>(ownerDid);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['sort_key'] = Variable<String>(sortKey);
    return map;
  }

  FeedContentItemsCompanion toCompanion(bool nullToAbsent) {
    return FeedContentItemsCompanion(
      feedKey: Value(feedKey),
      postUri: Value(postUri),
      ownerDid: Value(ownerDid),
      reason: reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      sortKey: Value(sortKey),
    );
  }

  factory FeedContentItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedContentItem(
      feedKey: serializer.fromJson<String>(json['feedKey']),
      postUri: serializer.fromJson<String>(json['postUri']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      reason: serializer.fromJson<String?>(json['reason']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedKey': serializer.toJson<String>(feedKey),
      'postUri': serializer.toJson<String>(postUri),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'reason': serializer.toJson<String?>(reason),
      'sortKey': serializer.toJson<String>(sortKey),
    };
  }

  FeedContentItem copyWith({
    String? feedKey,
    String? postUri,
    String? ownerDid,
    Value<String?> reason = const Value.absent(),
    String? sortKey,
  }) => FeedContentItem(
    feedKey: feedKey ?? this.feedKey,
    postUri: postUri ?? this.postUri,
    ownerDid: ownerDid ?? this.ownerDid,
    reason: reason.present ? reason.value : this.reason,
    sortKey: sortKey ?? this.sortKey,
  );
  FeedContentItem copyWithCompanion(FeedContentItemsCompanion data) {
    return FeedContentItem(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      postUri: data.postUri.present ? data.postUri.value : this.postUri,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      reason: data.reason.present ? data.reason.value : this.reason,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedContentItem(')
          ..write('feedKey: $feedKey, ')
          ..write('postUri: $postUri, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('reason: $reason, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feedKey, postUri, ownerDid, reason, sortKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedContentItem &&
          other.feedKey == this.feedKey &&
          other.postUri == this.postUri &&
          other.ownerDid == this.ownerDid &&
          other.reason == this.reason &&
          other.sortKey == this.sortKey);
}

class FeedContentItemsCompanion extends UpdateCompanion<FeedContentItem> {
  final Value<String> feedKey;
  final Value<String> postUri;
  final Value<String> ownerDid;
  final Value<String?> reason;
  final Value<String> sortKey;
  final Value<int> rowid;
  const FeedContentItemsCompanion({
    this.feedKey = const Value.absent(),
    this.postUri = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.reason = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedContentItemsCompanion.insert({
    required String feedKey,
    required String postUri,
    required String ownerDid,
    this.reason = const Value.absent(),
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey),
       postUri = Value(postUri),
       ownerDid = Value(ownerDid),
       sortKey = Value(sortKey);
  static Insertable<FeedContentItem> custom({
    Expression<String>? feedKey,
    Expression<String>? postUri,
    Expression<String>? ownerDid,
    Expression<String>? reason,
    Expression<String>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedKey != null) 'feed_key': feedKey,
      if (postUri != null) 'post_uri': postUri,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (reason != null) 'reason': reason,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedContentItemsCompanion copyWith({
    Value<String>? feedKey,
    Value<String>? postUri,
    Value<String>? ownerDid,
    Value<String?>? reason,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return FeedContentItemsCompanion(
      feedKey: feedKey ?? this.feedKey,
      postUri: postUri ?? this.postUri,
      ownerDid: ownerDid ?? this.ownerDid,
      reason: reason ?? this.reason,
      sortKey: sortKey ?? this.sortKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedKey.present) {
      map['feed_key'] = Variable<String>(feedKey.value);
    }
    if (postUri.present) {
      map['post_uri'] = Variable<String>(postUri.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedContentItemsCompanion(')
          ..write('feedKey: $feedKey, ')
          ..write('postUri: $postUri, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('reason: $reason, ')
          ..write('sortKey: $sortKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _pdsUrlMeta = const VerificationMeta('pdsUrl');
  @override
  late final GeneratedColumn<String> pdsUrl = GeneratedColumn<String>(
    'pds_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [did, handle, pdsUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('did')) {
      context.handle(_didMeta, did.isAcceptableOrUnknown(data['did']!, _didMeta));
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('handle')) {
      context.handle(_handleMeta, handle.isAcceptableOrUnknown(data['handle']!, _handleMeta));
    } else if (isInserting) {
      context.missing(_handleMeta);
    }
    if (data.containsKey('pds_url')) {
      context.handle(_pdsUrlMeta, pdsUrl.isAcceptableOrUnknown(data['pds_url']!, _pdsUrlMeta));
    } else if (isInserting) {
      context.missing(_pdsUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {did};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      did: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}did'])!,
      handle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handle'],
      )!,
      pdsUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pds_url'],
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
  final String pdsUrl;
  const Account({required this.did, required this.handle, required this.pdsUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['did'] = Variable<String>(did);
    map['handle'] = Variable<String>(handle);
    map['pds_url'] = Variable<String>(pdsUrl);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(did: Value(did), handle: Value(handle), pdsUrl: Value(pdsUrl));
  }

  factory Account.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      did: serializer.fromJson<String>(json['did']),
      handle: serializer.fromJson<String>(json['handle']),
      pdsUrl: serializer.fromJson<String>(json['pdsUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'did': serializer.toJson<String>(did),
      'handle': serializer.toJson<String>(handle),
      'pdsUrl': serializer.toJson<String>(pdsUrl),
    };
  }

  Account copyWith({String? did, String? handle, String? pdsUrl}) =>
      Account(did: did ?? this.did, handle: handle ?? this.handle, pdsUrl: pdsUrl ?? this.pdsUrl);
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      did: data.did.present ? data.did.value : this.did,
      handle: data.handle.present ? data.handle.value : this.handle,
      pdsUrl: data.pdsUrl.present ? data.pdsUrl.value : this.pdsUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('did: $did, ')
          ..write('handle: $handle, ')
          ..write('pdsUrl: $pdsUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(did, handle, pdsUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.did == this.did &&
          other.handle == this.handle &&
          other.pdsUrl == this.pdsUrl);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> did;
  final Value<String> handle;
  final Value<String> pdsUrl;
  final Value<int> rowid;
  const AccountsCompanion({
    this.did = const Value.absent(),
    this.handle = const Value.absent(),
    this.pdsUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String did,
    required String handle,
    required String pdsUrl,
    this.rowid = const Value.absent(),
  }) : did = Value(did),
       handle = Value(handle),
       pdsUrl = Value(pdsUrl);
  static Insertable<Account> custom({
    Expression<String>? did,
    Expression<String>? handle,
    Expression<String>? pdsUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (did != null) 'did': did,
      if (handle != null) 'handle': handle,
      if (pdsUrl != null) 'pds_url': pdsUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? did,
    Value<String>? handle,
    Value<String>? pdsUrl,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      did: did ?? this.did,
      handle: handle ?? this.handle,
      pdsUrl: pdsUrl ?? this.pdsUrl,
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
    if (pdsUrl.present) {
      map['pds_url'] = Variable<String>(pdsUrl.value);
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
          ..write('pdsUrl: $pdsUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedCursorsTable extends FeedCursors with TableInfo<$FeedCursorsTable, FeedCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedKeyMeta = const VerificationMeta('feedKey');
  @override
  late final GeneratedColumn<String> feedKey = GeneratedColumn<String>(
    'feed_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [feedKey, ownerDid, cursor, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_key')) {
      context.handle(_feedKeyMeta, feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta));
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta, cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(data['last_updated']!, _lastUpdatedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedKey, ownerDid};
  @override
  FeedCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedCursor(
      feedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_key'],
      )!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      ),
    );
  }

  @override
  $FeedCursorsTable createAlias(String alias) {
    return $FeedCursorsTable(attachedDatabase, alias);
  }
}

class FeedCursor extends DataClass implements Insertable<FeedCursor> {
  final String feedKey;
  final String ownerDid;
  final String cursor;
  final DateTime? lastUpdated;
  const FeedCursor({
    required this.feedKey,
    required this.ownerDid,
    required this.cursor,
    this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_key'] = Variable<String>(feedKey);
    map['owner_did'] = Variable<String>(ownerDid);
    map['cursor'] = Variable<String>(cursor);
    if (!nullToAbsent || lastUpdated != null) {
      map['last_updated'] = Variable<DateTime>(lastUpdated);
    }
    return map;
  }

  FeedCursorsCompanion toCompanion(bool nullToAbsent) {
    return FeedCursorsCompanion(
      feedKey: Value(feedKey),
      ownerDid: Value(ownerDid),
      cursor: Value(cursor),
      lastUpdated: lastUpdated == null && nullToAbsent ? const Value.absent() : Value(lastUpdated),
    );
  }

  factory FeedCursor.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedCursor(
      feedKey: serializer.fromJson<String>(json['feedKey']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      cursor: serializer.fromJson<String>(json['cursor']),
      lastUpdated: serializer.fromJson<DateTime?>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedKey': serializer.toJson<String>(feedKey),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'cursor': serializer.toJson<String>(cursor),
      'lastUpdated': serializer.toJson<DateTime?>(lastUpdated),
    };
  }

  FeedCursor copyWith({
    String? feedKey,
    String? ownerDid,
    String? cursor,
    Value<DateTime?> lastUpdated = const Value.absent(),
  }) => FeedCursor(
    feedKey: feedKey ?? this.feedKey,
    ownerDid: ownerDid ?? this.ownerDid,
    cursor: cursor ?? this.cursor,
    lastUpdated: lastUpdated.present ? lastUpdated.value : this.lastUpdated,
  );
  FeedCursor copyWithCompanion(FeedCursorsCompanion data) {
    return FeedCursor(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastUpdated: data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedCursor(')
          ..write('feedKey: $feedKey, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('cursor: $cursor, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feedKey, ownerDid, cursor, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedCursor &&
          other.feedKey == this.feedKey &&
          other.ownerDid == this.ownerDid &&
          other.cursor == this.cursor &&
          other.lastUpdated == this.lastUpdated);
}

class FeedCursorsCompanion extends UpdateCompanion<FeedCursor> {
  final Value<String> feedKey;
  final Value<String> ownerDid;
  final Value<String> cursor;
  final Value<DateTime?> lastUpdated;
  final Value<int> rowid;
  const FeedCursorsCompanion({
    this.feedKey = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedCursorsCompanion.insert({
    required String feedKey,
    required String ownerDid,
    required String cursor,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey),
       ownerDid = Value(ownerDid),
       cursor = Value(cursor);
  static Insertable<FeedCursor> custom({
    Expression<String>? feedKey,
    Expression<String>? ownerDid,
    Expression<String>? cursor,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedKey != null) 'feed_key': feedKey,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (cursor != null) 'cursor': cursor,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedCursorsCompanion copyWith({
    Value<String>? feedKey,
    Value<String>? ownerDid,
    Value<String>? cursor,
    Value<DateTime?>? lastUpdated,
    Value<int>? rowid,
  }) {
    return FeedCursorsCompanion(
      feedKey: feedKey ?? this.feedKey,
      ownerDid: ownerDid ?? this.ownerDid,
      cursor: cursor ?? this.cursor,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedKey.present) {
      map['feed_key'] = Variable<String>(feedKey.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedCursorsCompanion(')
          ..write('feedKey: $feedKey, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('cursor: $cursor, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta('searchedAt');
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, query, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentSearche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(_queryMeta, query.isAcceptableOrUnknown(data['query']!, _queryMeta));
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentSearche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearche(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearche extends DataClass implements Insertable<RecentSearche> {
  final int id;
  final String query;
  final DateTime searchedAt;
  const RecentSearche({required this.id, required this.query, required this.searchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      id: Value(id),
      query: Value(query),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearche.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearche(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  RecentSearche copyWith({int? id, String? query, DateTime? searchedAt}) => RecentSearche(
    id: id ?? this.id,
    query: query ?? this.query,
    searchedAt: searchedAt ?? this.searchedAt,
  );
  RecentSearche copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearche(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      searchedAt: data.searchedAt.present ? data.searchedAt.value : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearche(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearche &&
          other.id == this.id &&
          other.query == this.query &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearche> {
  final Value<int> id;
  final Value<String> query;
  final Value<DateTime> searchedAt;
  const RecentSearchesCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.searchedAt = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required DateTime searchedAt,
  }) : query = Value(query),
       searchedAt = Value(searchedAt);
  static Insertable<RecentSearche> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<DateTime>? searchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (searchedAt != null) 'searched_at': searchedAt,
    });
  }

  RecentSearchesCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<DateTime>? searchedAt,
  }) {
    return RecentSearchesCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      searchedAt: searchedAt ?? this.searchedAt,
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
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }
}

class $SearchCacheItemsTable extends SearchCacheItems
    with TableInfo<$SearchCacheItemsTable, SearchCacheItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchCacheItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryKeyMeta = const VerificationMeta('queryKey');
  @override
  late final GeneratedColumn<String> queryKey = GeneratedColumn<String>(
    'query_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postUriMeta = const VerificationMeta('postUri');
  @override
  late final GeneratedColumn<String> postUri = GeneratedColumn<String>(
    'post_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES posts (uri)'),
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta('sortKey');
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [queryKey, postUri, sortKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_cache_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchCacheItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query_key')) {
      context.handle(
        _queryKeyMeta,
        queryKey.isAcceptableOrUnknown(data['query_key']!, _queryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_queryKeyMeta);
    }
    if (data.containsKey('post_uri')) {
      context.handle(_postUriMeta, postUri.isAcceptableOrUnknown(data['post_uri']!, _postUriMeta));
    } else if (isInserting) {
      context.missing(_postUriMeta);
    }
    if (data.containsKey('sort_key')) {
      context.handle(_sortKeyMeta, sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta));
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {queryKey, postUri};
  @override
  SearchCacheItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchCacheItem(
      queryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query_key'],
      )!,
      postUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_uri'],
      )!,
      sortKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_key'],
      )!,
    );
  }

  @override
  $SearchCacheItemsTable createAlias(String alias) {
    return $SearchCacheItemsTable(attachedDatabase, alias);
  }
}

class SearchCacheItem extends DataClass implements Insertable<SearchCacheItem> {
  /// Normalized search query as cache key.
  final String queryKey;

  /// Reference to cached post.
  final String postUri;

  /// Ordering within results (index-based).
  final String sortKey;
  const SearchCacheItem({required this.queryKey, required this.postUri, required this.sortKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query_key'] = Variable<String>(queryKey);
    map['post_uri'] = Variable<String>(postUri);
    map['sort_key'] = Variable<String>(sortKey);
    return map;
  }

  SearchCacheItemsCompanion toCompanion(bool nullToAbsent) {
    return SearchCacheItemsCompanion(
      queryKey: Value(queryKey),
      postUri: Value(postUri),
      sortKey: Value(sortKey),
    );
  }

  factory SearchCacheItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchCacheItem(
      queryKey: serializer.fromJson<String>(json['queryKey']),
      postUri: serializer.fromJson<String>(json['postUri']),
      sortKey: serializer.fromJson<String>(json['sortKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'queryKey': serializer.toJson<String>(queryKey),
      'postUri': serializer.toJson<String>(postUri),
      'sortKey': serializer.toJson<String>(sortKey),
    };
  }

  SearchCacheItem copyWith({String? queryKey, String? postUri, String? sortKey}) =>
      SearchCacheItem(
        queryKey: queryKey ?? this.queryKey,
        postUri: postUri ?? this.postUri,
        sortKey: sortKey ?? this.sortKey,
      );
  SearchCacheItem copyWithCompanion(SearchCacheItemsCompanion data) {
    return SearchCacheItem(
      queryKey: data.queryKey.present ? data.queryKey.value : this.queryKey,
      postUri: data.postUri.present ? data.postUri.value : this.postUri,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchCacheItem(')
          ..write('queryKey: $queryKey, ')
          ..write('postUri: $postUri, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(queryKey, postUri, sortKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchCacheItem &&
          other.queryKey == this.queryKey &&
          other.postUri == this.postUri &&
          other.sortKey == this.sortKey);
}

class SearchCacheItemsCompanion extends UpdateCompanion<SearchCacheItem> {
  final Value<String> queryKey;
  final Value<String> postUri;
  final Value<String> sortKey;
  final Value<int> rowid;
  const SearchCacheItemsCompanion({
    this.queryKey = const Value.absent(),
    this.postUri = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchCacheItemsCompanion.insert({
    required String queryKey,
    required String postUri,
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : queryKey = Value(queryKey),
       postUri = Value(postUri),
       sortKey = Value(sortKey);
  static Insertable<SearchCacheItem> custom({
    Expression<String>? queryKey,
    Expression<String>? postUri,
    Expression<String>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (queryKey != null) 'query_key': queryKey,
      if (postUri != null) 'post_uri': postUri,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchCacheItemsCompanion copyWith({
    Value<String>? queryKey,
    Value<String>? postUri,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return SearchCacheItemsCompanion(
      queryKey: queryKey ?? this.queryKey,
      postUri: postUri ?? this.postUri,
      sortKey: sortKey ?? this.sortKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (queryKey.present) {
      map['query_key'] = Variable<String>(queryKey.value);
    }
    if (postUri.present) {
      map['post_uri'] = Variable<String>(postUri.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<String>(sortKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchCacheItemsCompanion(')
          ..write('queryKey: $queryKey, ')
          ..write('postUri: $postUri, ')
          ..write('sortKey: $sortKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SearchCacheCursorsTable extends SearchCacheCursors
    with TableInfo<$SearchCacheCursorsTable, SearchCacheCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchCacheCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryKeyMeta = const VerificationMeta('queryKey');
  @override
  late final GeneratedColumn<String> queryKey = GeneratedColumn<String>(
    'query_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [queryKey, cursor, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_cache_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchCacheCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query_key')) {
      context.handle(
        _queryKeyMeta,
        queryKey.isAcceptableOrUnknown(data['query_key']!, _queryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_queryKeyMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta, cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(data['last_updated']!, _lastUpdatedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {queryKey};
  @override
  SearchCacheCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchCacheCursor(
      queryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query_key'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      ),
    );
  }

  @override
  $SearchCacheCursorsTable createAlias(String alias) {
    return $SearchCacheCursorsTable(attachedDatabase, alias);
  }
}

class SearchCacheCursor extends DataClass implements Insertable<SearchCacheCursor> {
  /// Normalized search query as cache key.
  final String queryKey;

  /// Pagination cursor from API.
  final String cursor;

  /// When the cache was last updated (for 7-day retention).
  final DateTime? lastUpdated;
  const SearchCacheCursor({required this.queryKey, required this.cursor, this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query_key'] = Variable<String>(queryKey);
    map['cursor'] = Variable<String>(cursor);
    if (!nullToAbsent || lastUpdated != null) {
      map['last_updated'] = Variable<DateTime>(lastUpdated);
    }
    return map;
  }

  SearchCacheCursorsCompanion toCompanion(bool nullToAbsent) {
    return SearchCacheCursorsCompanion(
      queryKey: Value(queryKey),
      cursor: Value(cursor),
      lastUpdated: lastUpdated == null && nullToAbsent ? const Value.absent() : Value(lastUpdated),
    );
  }

  factory SearchCacheCursor.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchCacheCursor(
      queryKey: serializer.fromJson<String>(json['queryKey']),
      cursor: serializer.fromJson<String>(json['cursor']),
      lastUpdated: serializer.fromJson<DateTime?>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'queryKey': serializer.toJson<String>(queryKey),
      'cursor': serializer.toJson<String>(cursor),
      'lastUpdated': serializer.toJson<DateTime?>(lastUpdated),
    };
  }

  SearchCacheCursor copyWith({
    String? queryKey,
    String? cursor,
    Value<DateTime?> lastUpdated = const Value.absent(),
  }) => SearchCacheCursor(
    queryKey: queryKey ?? this.queryKey,
    cursor: cursor ?? this.cursor,
    lastUpdated: lastUpdated.present ? lastUpdated.value : this.lastUpdated,
  );
  SearchCacheCursor copyWithCompanion(SearchCacheCursorsCompanion data) {
    return SearchCacheCursor(
      queryKey: data.queryKey.present ? data.queryKey.value : this.queryKey,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastUpdated: data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchCacheCursor(')
          ..write('queryKey: $queryKey, ')
          ..write('cursor: $cursor, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(queryKey, cursor, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchCacheCursor &&
          other.queryKey == this.queryKey &&
          other.cursor == this.cursor &&
          other.lastUpdated == this.lastUpdated);
}

class SearchCacheCursorsCompanion extends UpdateCompanion<SearchCacheCursor> {
  final Value<String> queryKey;
  final Value<String> cursor;
  final Value<DateTime?> lastUpdated;
  final Value<int> rowid;
  const SearchCacheCursorsCompanion({
    this.queryKey = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchCacheCursorsCompanion.insert({
    required String queryKey,
    required String cursor,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : queryKey = Value(queryKey),
       cursor = Value(cursor);
  static Insertable<SearchCacheCursor> custom({
    Expression<String>? queryKey,
    Expression<String>? cursor,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (queryKey != null) 'query_key': queryKey,
      if (cursor != null) 'cursor': cursor,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchCacheCursorsCompanion copyWith({
    Value<String>? queryKey,
    Value<String>? cursor,
    Value<DateTime?>? lastUpdated,
    Value<int>? rowid,
  }) {
    return SearchCacheCursorsCompanion(
      queryKey: queryKey ?? this.queryKey,
      cursor: cursor ?? this.cursor,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (queryKey.present) {
      map['query_key'] = Variable<String>(queryKey.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchCacheCursorsCompanion(')
          ..write('queryKey: $queryKey, ')
          ..write('cursor: $cursor, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FollowsTable extends Follows with TableInfo<$FollowsTable, Follow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _actorDidMeta = const VerificationMeta('actorDid');
  @override
  late final GeneratedColumn<String> actorDid = GeneratedColumn<String>(
    'actor_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectDidMeta = const VerificationMeta('subjectDid');
  @override
  late final GeneratedColumn<String> subjectDid = GeneratedColumn<String>(
    'subject_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [actorDid, subjectDid, uri, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follows';
  @override
  VerificationContext validateIntegrity(Insertable<Follow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('actor_did')) {
      context.handle(
        _actorDidMeta,
        actorDid.isAcceptableOrUnknown(data['actor_did']!, _actorDidMeta),
      );
    } else if (isInserting) {
      context.missing(_actorDidMeta);
    }
    if (data.containsKey('subject_did')) {
      context.handle(
        _subjectDidMeta,
        subjectDid.isAcceptableOrUnknown(data['subject_did']!, _subjectDidMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectDidMeta);
    }
    if (data.containsKey('uri')) {
      context.handle(_uriMeta, uri.isAcceptableOrUnknown(data['uri']!, _uriMeta));
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {actorDid, subjectDid};
  @override
  Follow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Follow(
      actorDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_did'],
      )!,
      subjectDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_did'],
      )!,
      uri: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uri'])!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $FollowsTable createAlias(String alias) {
    return $FollowsTable(attachedDatabase, alias);
  }
}

class Follow extends DataClass implements Insertable<Follow> {
  /// The DID of the user doing the following.
  final String actorDid;

  /// The DID of the user being followed.
  final String subjectDid;

  /// The AT URI of the follow record (at://did:plc:xxx/app.bsky.graph.follow/yyy).
  final String uri;

  /// When the follow was created.
  final DateTime? createdAt;
  const Follow({
    required this.actorDid,
    required this.subjectDid,
    required this.uri,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['actor_did'] = Variable<String>(actorDid);
    map['subject_did'] = Variable<String>(subjectDid);
    map['uri'] = Variable<String>(uri);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  FollowsCompanion toCompanion(bool nullToAbsent) {
    return FollowsCompanion(
      actorDid: Value(actorDid),
      subjectDid: Value(subjectDid),
      uri: Value(uri),
      createdAt: createdAt == null && nullToAbsent ? const Value.absent() : Value(createdAt),
    );
  }

  factory Follow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Follow(
      actorDid: serializer.fromJson<String>(json['actorDid']),
      subjectDid: serializer.fromJson<String>(json['subjectDid']),
      uri: serializer.fromJson<String>(json['uri']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'actorDid': serializer.toJson<String>(actorDid),
      'subjectDid': serializer.toJson<String>(subjectDid),
      'uri': serializer.toJson<String>(uri),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Follow copyWith({
    String? actorDid,
    String? subjectDid,
    String? uri,
    Value<DateTime?> createdAt = const Value.absent(),
  }) => Follow(
    actorDid: actorDid ?? this.actorDid,
    subjectDid: subjectDid ?? this.subjectDid,
    uri: uri ?? this.uri,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  Follow copyWithCompanion(FollowsCompanion data) {
    return Follow(
      actorDid: data.actorDid.present ? data.actorDid.value : this.actorDid,
      subjectDid: data.subjectDid.present ? data.subjectDid.value : this.subjectDid,
      uri: data.uri.present ? data.uri.value : this.uri,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Follow(')
          ..write('actorDid: $actorDid, ')
          ..write('subjectDid: $subjectDid, ')
          ..write('uri: $uri, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(actorDid, subjectDid, uri, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Follow &&
          other.actorDid == this.actorDid &&
          other.subjectDid == this.subjectDid &&
          other.uri == this.uri &&
          other.createdAt == this.createdAt);
}

class FollowsCompanion extends UpdateCompanion<Follow> {
  final Value<String> actorDid;
  final Value<String> subjectDid;
  final Value<String> uri;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const FollowsCompanion({
    this.actorDid = const Value.absent(),
    this.subjectDid = const Value.absent(),
    this.uri = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FollowsCompanion.insert({
    required String actorDid,
    required String subjectDid,
    required String uri,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : actorDid = Value(actorDid),
       subjectDid = Value(subjectDid),
       uri = Value(uri);
  static Insertable<Follow> custom({
    Expression<String>? actorDid,
    Expression<String>? subjectDid,
    Expression<String>? uri,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (actorDid != null) 'actor_did': actorDid,
      if (subjectDid != null) 'subject_did': subjectDid,
      if (uri != null) 'uri': uri,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FollowsCompanion copyWith({
    Value<String>? actorDid,
    Value<String>? subjectDid,
    Value<String>? uri,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return FollowsCompanion(
      actorDid: actorDid ?? this.actorDid,
      subjectDid: subjectDid ?? this.subjectDid,
      uri: uri ?? this.uri,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (actorDid.present) {
      map['actor_did'] = Variable<String>(actorDid.value);
    }
    if (subjectDid.present) {
      map['subject_did'] = Variable<String>(subjectDid.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
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
    return (StringBuffer('FollowsCompanion(')
          ..write('actorDid: $actorDid, ')
          ..write('subjectDid: $subjectDid, ')
          ..write('uri: $uri, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedFeedsTable extends SavedFeeds with TableInfo<$SavedFeedsTable, SavedFeed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedFeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creatorDidMeta = const VerificationMeta('creatorDid');
  @override
  late final GeneratedColumn<String> creatorDid = GeneratedColumn<String>(
    'creator_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES profiles (did)'),
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta('likeCount');
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta('lastSynced');
  @override
  late final GeneratedColumn<DateTime> lastSynced = GeneratedColumn<DateTime>(
    'last_synced',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localUpdatedAtMeta = const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt = GeneratedColumn<DateTime>(
    'local_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uri,
    ownerDid,
    displayName,
    description,
    avatar,
    creatorDid,
    likeCount,
    sortOrder,
    isPinned,
    lastSynced,
    localUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_feeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedFeed> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uri')) {
      context.handle(_uriMeta, uri.isAcceptableOrUnknown(data['uri']!, _uriMeta));
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(data['display_name']!, _displayNameMeta),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(data['description']!, _descriptionMeta),
      );
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta, avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('creator_did')) {
      context.handle(
        _creatorDidMeta,
        creatorDid.isAcceptableOrUnknown(data['creator_did']!, _creatorDidMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorDidMeta);
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('last_synced')) {
      context.handle(
        _lastSyncedMeta,
        lastSynced.isAcceptableOrUnknown(data['last_synced']!, _lastSyncedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedMeta);
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
        _localUpdatedAtMeta,
        localUpdatedAt.isAcceptableOrUnknown(data['local_updated_at']!, _localUpdatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uri, ownerDid};
  @override
  SavedFeed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedFeed(
      uri: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uri'])!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      creatorDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_did'],
      )!,
      likeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like_count'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      lastSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced'],
      )!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}local_updated_at'],
      ),
    );
  }

  @override
  $SavedFeedsTable createAlias(String alias) {
    return $SavedFeedsTable(attachedDatabase, alias);
  }
}

class SavedFeed extends DataClass implements Insertable<SavedFeed> {
  /// Feed generator AT URI (at://did:plc:xxx/app.bsky.feed.generator/yyy).
  final String uri;

  /// The DID of the user who saved this feed.
  final String ownerDid;

  /// Display name of the feed.
  final String displayName;

  /// Feed description.
  final String? description;

  /// Feed avatar URL.
  final String? avatar;

  /// DID of the feed creator.
  final String creatorDid;

  /// Number of likes the feed has received.
  final int likeCount;

  /// Sort order for display (lower values appear first).
  final int sortOrder;

  /// Whether the feed is pinned by the user.
  final bool isPinned;

  /// When the feed metadata was last synced from remote.
  final DateTime lastSynced;

  /// When this feed was last modified locally (save, pin, reorder).
  /// Null means no local modifications since the last remote sync.
  final DateTime? localUpdatedAt;
  const SavedFeed({
    required this.uri,
    required this.ownerDid,
    required this.displayName,
    this.description,
    this.avatar,
    required this.creatorDid,
    required this.likeCount,
    required this.sortOrder,
    required this.isPinned,
    required this.lastSynced,
    this.localUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uri'] = Variable<String>(uri);
    map['owner_did'] = Variable<String>(ownerDid);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['creator_did'] = Variable<String>(creatorDid);
    map['like_count'] = Variable<int>(likeCount);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['last_synced'] = Variable<DateTime>(lastSynced);
    if (!nullToAbsent || localUpdatedAt != null) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    }
    return map;
  }

  SavedFeedsCompanion toCompanion(bool nullToAbsent) {
    return SavedFeedsCompanion(
      uri: Value(uri),
      ownerDid: Value(ownerDid),
      displayName: Value(displayName),
      description: description == null && nullToAbsent ? const Value.absent() : Value(description),
      avatar: avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      creatorDid: Value(creatorDid),
      likeCount: Value(likeCount),
      sortOrder: Value(sortOrder),
      isPinned: Value(isPinned),
      lastSynced: Value(lastSynced),
      localUpdatedAt: localUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(localUpdatedAt),
    );
  }

  factory SavedFeed.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedFeed(
      uri: serializer.fromJson<String>(json['uri']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      displayName: serializer.fromJson<String>(json['displayName']),
      description: serializer.fromJson<String?>(json['description']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      creatorDid: serializer.fromJson<String>(json['creatorDid']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      lastSynced: serializer.fromJson<DateTime>(json['lastSynced']),
      localUpdatedAt: serializer.fromJson<DateTime?>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uri': serializer.toJson<String>(uri),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'displayName': serializer.toJson<String>(displayName),
      'description': serializer.toJson<String?>(description),
      'avatar': serializer.toJson<String?>(avatar),
      'creatorDid': serializer.toJson<String>(creatorDid),
      'likeCount': serializer.toJson<int>(likeCount),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isPinned': serializer.toJson<bool>(isPinned),
      'lastSynced': serializer.toJson<DateTime>(lastSynced),
      'localUpdatedAt': serializer.toJson<DateTime?>(localUpdatedAt),
    };
  }

  SavedFeed copyWith({
    String? uri,
    String? ownerDid,
    String? displayName,
    Value<String?> description = const Value.absent(),
    Value<String?> avatar = const Value.absent(),
    String? creatorDid,
    int? likeCount,
    int? sortOrder,
    bool? isPinned,
    DateTime? lastSynced,
    Value<DateTime?> localUpdatedAt = const Value.absent(),
  }) => SavedFeed(
    uri: uri ?? this.uri,
    ownerDid: ownerDid ?? this.ownerDid,
    displayName: displayName ?? this.displayName,
    description: description.present ? description.value : this.description,
    avatar: avatar.present ? avatar.value : this.avatar,
    creatorDid: creatorDid ?? this.creatorDid,
    likeCount: likeCount ?? this.likeCount,
    sortOrder: sortOrder ?? this.sortOrder,
    isPinned: isPinned ?? this.isPinned,
    lastSynced: lastSynced ?? this.lastSynced,
    localUpdatedAt: localUpdatedAt.present ? localUpdatedAt.value : this.localUpdatedAt,
  );
  SavedFeed copyWithCompanion(SavedFeedsCompanion data) {
    return SavedFeed(
      uri: data.uri.present ? data.uri.value : this.uri,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      displayName: data.displayName.present ? data.displayName.value : this.displayName,
      description: data.description.present ? data.description.value : this.description,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      creatorDid: data.creatorDid.present ? data.creatorDid.value : this.creatorDid,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      lastSynced: data.lastSynced.present ? data.lastSynced.value : this.lastSynced,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedFeed(')
          ..write('uri: $uri, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('displayName: $displayName, ')
          ..write('description: $description, ')
          ..write('avatar: $avatar, ')
          ..write('creatorDid: $creatorDid, ')
          ..write('likeCount: $likeCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPinned: $isPinned, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uri,
    ownerDid,
    displayName,
    description,
    avatar,
    creatorDid,
    likeCount,
    sortOrder,
    isPinned,
    lastSynced,
    localUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedFeed &&
          other.uri == this.uri &&
          other.ownerDid == this.ownerDid &&
          other.displayName == this.displayName &&
          other.description == this.description &&
          other.avatar == this.avatar &&
          other.creatorDid == this.creatorDid &&
          other.likeCount == this.likeCount &&
          other.sortOrder == this.sortOrder &&
          other.isPinned == this.isPinned &&
          other.lastSynced == this.lastSynced &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class SavedFeedsCompanion extends UpdateCompanion<SavedFeed> {
  final Value<String> uri;
  final Value<String> ownerDid;
  final Value<String> displayName;
  final Value<String?> description;
  final Value<String?> avatar;
  final Value<String> creatorDid;
  final Value<int> likeCount;
  final Value<int> sortOrder;
  final Value<bool> isPinned;
  final Value<DateTime> lastSynced;
  final Value<DateTime?> localUpdatedAt;
  final Value<int> rowid;
  const SavedFeedsCompanion({
    this.uri = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.displayName = const Value.absent(),
    this.description = const Value.absent(),
    this.avatar = const Value.absent(),
    this.creatorDid = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedFeedsCompanion.insert({
    required String uri,
    required String ownerDid,
    required String displayName,
    this.description = const Value.absent(),
    this.avatar = const Value.absent(),
    required String creatorDid,
    this.likeCount = const Value.absent(),
    required int sortOrder,
    this.isPinned = const Value.absent(),
    required DateTime lastSynced,
    this.localUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uri = Value(uri),
       ownerDid = Value(ownerDid),
       displayName = Value(displayName),
       creatorDid = Value(creatorDid),
       sortOrder = Value(sortOrder),
       lastSynced = Value(lastSynced);
  static Insertable<SavedFeed> custom({
    Expression<String>? uri,
    Expression<String>? ownerDid,
    Expression<String>? displayName,
    Expression<String>? description,
    Expression<String>? avatar,
    Expression<String>? creatorDid,
    Expression<int>? likeCount,
    Expression<int>? sortOrder,
    Expression<bool>? isPinned,
    Expression<DateTime>? lastSynced,
    Expression<DateTime>? localUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uri != null) 'uri': uri,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (displayName != null) 'display_name': displayName,
      if (description != null) 'description': description,
      if (avatar != null) 'avatar': avatar,
      if (creatorDid != null) 'creator_did': creatorDid,
      if (likeCount != null) 'like_count': likeCount,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isPinned != null) 'is_pinned': isPinned,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedFeedsCompanion copyWith({
    Value<String>? uri,
    Value<String>? ownerDid,
    Value<String>? displayName,
    Value<String?>? description,
    Value<String?>? avatar,
    Value<String>? creatorDid,
    Value<int>? likeCount,
    Value<int>? sortOrder,
    Value<bool>? isPinned,
    Value<DateTime>? lastSynced,
    Value<DateTime?>? localUpdatedAt,
    Value<int>? rowid,
  }) {
    return SavedFeedsCompanion(
      uri: uri ?? this.uri,
      ownerDid: ownerDid ?? this.ownerDid,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      creatorDid: creatorDid ?? this.creatorDid,
      likeCount: likeCount ?? this.likeCount,
      sortOrder: sortOrder ?? this.sortOrder,
      isPinned: isPinned ?? this.isPinned,
      lastSynced: lastSynced ?? this.lastSynced,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (creatorDid.present) {
      map['creator_did'] = Variable<String>(creatorDid.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<DateTime>(lastSynced.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedFeedsCompanion(')
          ..write('uri: $uri, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('displayName: $displayName, ')
          ..write('description: $description, ')
          ..write('avatar: $avatar, ')
          ..write('creatorDid: $creatorDid, ')
          ..write('likeCount: $likeCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPinned: $isPinned, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('localUpdatedAt: $localUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferenceSyncQueueTable extends PreferenceSyncQueue
    with TableInfo<$PreferenceSyncQueueTable, PreferenceSyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenceSyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('feed'),
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
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerDid,
    category,
    type,
    payload,
    createdAt,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preference_sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferenceSyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreferenceSyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceSyncQueueData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $PreferenceSyncQueueTable createAlias(String alias) {
    return $PreferenceSyncQueueTable(attachedDatabase, alias);
  }
}

class PreferenceSyncQueueData extends DataClass implements Insertable<PreferenceSyncQueueData> {
  final int id;

  /// The DID of the user who owns this action.
  final String ownerDid;

  /// Category of preference being synced: 'feed' or 'bluesky_pref'.
  final String category;

  /// Type of operation.
  ///
  /// For feeds: 'save', 'remove', or 'reorder'.
  /// For bluesky preferences: 'update'.
  final String type;

  /// Payload data for the sync operation.
  ///
  /// For feeds: the feed URI (or comma-separated URIs for reorder).
  /// For bluesky preferences: JSON string of the preference data.
  final String payload;

  /// When the item was queued.
  final DateTime createdAt;

  /// Number of times we've tried to process this item.
  final int retryCount;
  const PreferenceSyncQueueData({
    required this.id,
    required this.ownerDid,
    required this.category,
    required this.type,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['owner_did'] = Variable<String>(ownerDid);
    map['category'] = Variable<String>(category);
    map['type'] = Variable<String>(type);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  PreferenceSyncQueueCompanion toCompanion(bool nullToAbsent) {
    return PreferenceSyncQueueCompanion(
      id: Value(id),
      ownerDid: Value(ownerDid),
      category: Value(category),
      type: Value(type),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory PreferenceSyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenceSyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      category: serializer.fromJson<String>(json['category']),
      type: serializer.fromJson<String>(json['type']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'category': serializer.toJson<String>(category),
      'type': serializer.toJson<String>(type),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  PreferenceSyncQueueData copyWith({
    int? id,
    String? ownerDid,
    String? category,
    String? type,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
  }) => PreferenceSyncQueueData(
    id: id ?? this.id,
    ownerDid: ownerDid ?? this.ownerDid,
    category: category ?? this.category,
    type: type ?? this.type,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  PreferenceSyncQueueData copyWithCompanion(PreferenceSyncQueueCompanion data) {
    return PreferenceSyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      category: data.category.present ? data.category.value : this.category,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceSyncQueueData(')
          ..write('id: $id, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerDid, category, type, payload, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceSyncQueueData &&
          other.id == this.id &&
          other.ownerDid == this.ownerDid &&
          other.category == this.category &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class PreferenceSyncQueueCompanion extends UpdateCompanion<PreferenceSyncQueueData> {
  final Value<int> id;
  final Value<String> ownerDid;
  final Value<String> category;
  final Value<String> type;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const PreferenceSyncQueueCompanion({
    this.id = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  PreferenceSyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String ownerDid,
    this.category = const Value.absent(),
    required String type,
    required String payload,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
  }) : ownerDid = Value(ownerDid),
       type = Value(type),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<PreferenceSyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? ownerDid,
    Expression<String>? category,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  PreferenceSyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? ownerDid,
    Value<String>? category,
    Value<String>? type,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
  }) {
    return PreferenceSyncQueueCompanion(
      id: id ?? this.id,
      ownerDid: ownerDid ?? this.ownerDid,
      category: category ?? this.category,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceSyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, Draft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _replyParentUriMeta = const VerificationMeta('replyParentUri');
  @override
  late final GeneratedColumn<String> replyParentUri = GeneratedColumn<String>(
    'reply_parent_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyParentCidMeta = const VerificationMeta('replyParentCid');
  @override
  late final GeneratedColumn<String> replyParentCid = GeneratedColumn<String>(
    'reply_parent_cid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyRootUriMeta = const VerificationMeta('replyRootUri');
  @override
  late final GeneratedColumn<String> replyRootUri = GeneratedColumn<String>(
    'reply_root_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replyRootCidMeta = const VerificationMeta('replyRootCid');
  @override
  late final GeneratedColumn<String> replyRootCid = GeneratedColumn<String>(
    'reply_root_cid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quoteUriMeta = const VerificationMeta('quoteUri');
  @override
  late final GeneratedColumn<String> quoteUri = GeneratedColumn<String>(
    'quote_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quoteCidMeta = const VerificationMeta('quoteCid');
  @override
  late final GeneratedColumn<String> quoteCid = GeneratedColumn<String>(
    'quote_cid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _facetsJsonMeta = const VerificationMeta('facetsJson');
  @override
  late final GeneratedColumn<String> facetsJson = GeneratedColumn<String>(
    'facets_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalUriMeta = const VerificationMeta('externalUri');
  @override
  late final GeneratedColumn<String> externalUri = GeneratedColumn<String>(
    'external_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalTitleMeta = const VerificationMeta('externalTitle');
  @override
  late final GeneratedColumn<String> externalTitle = GeneratedColumn<String>(
    'external_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalDescriptionMeta = const VerificationMeta(
    'externalDescription',
  );
  @override
  late final GeneratedColumn<String> externalDescription = GeneratedColumn<String>(
    'external_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalThumbBlobJsonMeta = const VerificationMeta(
    'externalThumbBlobJson',
  );
  @override
  late final GeneratedColumn<String> externalThumbBlobJson = GeneratedColumn<String>(
    'external_thumb_blob_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    replyParentUri,
    replyParentCid,
    replyRootUri,
    replyRootCid,
    quoteUri,
    quoteCid,
    facetsJson,
    externalUri,
    externalTitle,
    externalDescription,
    externalThumbBlobJson,
    status,
    errorMessage,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(Insertable<Draft> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta, content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('reply_parent_uri')) {
      context.handle(
        _replyParentUriMeta,
        replyParentUri.isAcceptableOrUnknown(data['reply_parent_uri']!, _replyParentUriMeta),
      );
    }
    if (data.containsKey('reply_parent_cid')) {
      context.handle(
        _replyParentCidMeta,
        replyParentCid.isAcceptableOrUnknown(data['reply_parent_cid']!, _replyParentCidMeta),
      );
    }
    if (data.containsKey('reply_root_uri')) {
      context.handle(
        _replyRootUriMeta,
        replyRootUri.isAcceptableOrUnknown(data['reply_root_uri']!, _replyRootUriMeta),
      );
    }
    if (data.containsKey('reply_root_cid')) {
      context.handle(
        _replyRootCidMeta,
        replyRootCid.isAcceptableOrUnknown(data['reply_root_cid']!, _replyRootCidMeta),
      );
    }
    if (data.containsKey('quote_uri')) {
      context.handle(
        _quoteUriMeta,
        quoteUri.isAcceptableOrUnknown(data['quote_uri']!, _quoteUriMeta),
      );
    }
    if (data.containsKey('quote_cid')) {
      context.handle(
        _quoteCidMeta,
        quoteCid.isAcceptableOrUnknown(data['quote_cid']!, _quoteCidMeta),
      );
    }
    if (data.containsKey('facets_json')) {
      context.handle(
        _facetsJsonMeta,
        facetsJson.isAcceptableOrUnknown(data['facets_json']!, _facetsJsonMeta),
      );
    }
    if (data.containsKey('external_uri')) {
      context.handle(
        _externalUriMeta,
        externalUri.isAcceptableOrUnknown(data['external_uri']!, _externalUriMeta),
      );
    }
    if (data.containsKey('external_title')) {
      context.handle(
        _externalTitleMeta,
        externalTitle.isAcceptableOrUnknown(data['external_title']!, _externalTitleMeta),
      );
    }
    if (data.containsKey('external_description')) {
      context.handle(
        _externalDescriptionMeta,
        externalDescription.isAcceptableOrUnknown(
          data['external_description']!,
          _externalDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('external_thumb_blob_json')) {
      context.handle(
        _externalThumbBlobJsonMeta,
        externalThumbBlobJson.isAcceptableOrUnknown(
          data['external_thumb_blob_json']!,
          _externalThumbBlobJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(data['error_message']!, _errorMessageMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Draft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Draft(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      replyParentUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_parent_uri'],
      ),
      replyParentCid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_parent_cid'],
      ),
      replyRootUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_root_uri'],
      ),
      replyRootCid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_root_cid'],
      ),
      quoteUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_uri'],
      ),
      quoteCid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_cid'],
      ),
      facetsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facets_json'],
      ),
      externalUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_uri'],
      ),
      externalTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_title'],
      ),
      externalDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_description'],
      ),
      externalThumbBlobJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_thumb_blob_json'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
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
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }
}

class Draft extends DataClass implements Insertable<Draft> {
  final String id;
  final String content;
  final String? replyParentUri;
  final String? replyParentCid;
  final String? replyRootUri;
  final String? replyRootCid;
  final String? quoteUri;
  final String? quoteCid;
  final String? facetsJson;
  final String? externalUri;
  final String? externalTitle;
  final String? externalDescription;
  final String? externalThumbBlobJson;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Draft({
    required this.id,
    required this.content,
    this.replyParentUri,
    this.replyParentCid,
    this.replyRootUri,
    this.replyRootCid,
    this.quoteUri,
    this.quoteCid,
    this.facetsJson,
    this.externalUri,
    this.externalTitle,
    this.externalDescription,
    this.externalThumbBlobJson,
    required this.status,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || replyParentUri != null) {
      map['reply_parent_uri'] = Variable<String>(replyParentUri);
    }
    if (!nullToAbsent || replyParentCid != null) {
      map['reply_parent_cid'] = Variable<String>(replyParentCid);
    }
    if (!nullToAbsent || replyRootUri != null) {
      map['reply_root_uri'] = Variable<String>(replyRootUri);
    }
    if (!nullToAbsent || replyRootCid != null) {
      map['reply_root_cid'] = Variable<String>(replyRootCid);
    }
    if (!nullToAbsent || quoteUri != null) {
      map['quote_uri'] = Variable<String>(quoteUri);
    }
    if (!nullToAbsent || quoteCid != null) {
      map['quote_cid'] = Variable<String>(quoteCid);
    }
    if (!nullToAbsent || facetsJson != null) {
      map['facets_json'] = Variable<String>(facetsJson);
    }
    if (!nullToAbsent || externalUri != null) {
      map['external_uri'] = Variable<String>(externalUri);
    }
    if (!nullToAbsent || externalTitle != null) {
      map['external_title'] = Variable<String>(externalTitle);
    }
    if (!nullToAbsent || externalDescription != null) {
      map['external_description'] = Variable<String>(externalDescription);
    }
    if (!nullToAbsent || externalThumbBlobJson != null) {
      map['external_thumb_blob_json'] = Variable<String>(externalThumbBlobJson);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      content: Value(content),
      replyParentUri: replyParentUri == null && nullToAbsent
          ? const Value.absent()
          : Value(replyParentUri),
      replyParentCid: replyParentCid == null && nullToAbsent
          ? const Value.absent()
          : Value(replyParentCid),
      replyRootUri: replyRootUri == null && nullToAbsent
          ? const Value.absent()
          : Value(replyRootUri),
      replyRootCid: replyRootCid == null && nullToAbsent
          ? const Value.absent()
          : Value(replyRootCid),
      quoteUri: quoteUri == null && nullToAbsent ? const Value.absent() : Value(quoteUri),
      quoteCid: quoteCid == null && nullToAbsent ? const Value.absent() : Value(quoteCid),
      facetsJson: facetsJson == null && nullToAbsent ? const Value.absent() : Value(facetsJson),
      externalUri: externalUri == null && nullToAbsent ? const Value.absent() : Value(externalUri),
      externalTitle: externalTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(externalTitle),
      externalDescription: externalDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(externalDescription),
      externalThumbBlobJson: externalThumbBlobJson == null && nullToAbsent
          ? const Value.absent()
          : Value(externalThumbBlobJson),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Draft.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Draft(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      replyParentUri: serializer.fromJson<String?>(json['replyParentUri']),
      replyParentCid: serializer.fromJson<String?>(json['replyParentCid']),
      replyRootUri: serializer.fromJson<String?>(json['replyRootUri']),
      replyRootCid: serializer.fromJson<String?>(json['replyRootCid']),
      quoteUri: serializer.fromJson<String?>(json['quoteUri']),
      quoteCid: serializer.fromJson<String?>(json['quoteCid']),
      facetsJson: serializer.fromJson<String?>(json['facetsJson']),
      externalUri: serializer.fromJson<String?>(json['externalUri']),
      externalTitle: serializer.fromJson<String?>(json['externalTitle']),
      externalDescription: serializer.fromJson<String?>(json['externalDescription']),
      externalThumbBlobJson: serializer.fromJson<String?>(json['externalThumbBlobJson']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'replyParentUri': serializer.toJson<String?>(replyParentUri),
      'replyParentCid': serializer.toJson<String?>(replyParentCid),
      'replyRootUri': serializer.toJson<String?>(replyRootUri),
      'replyRootCid': serializer.toJson<String?>(replyRootCid),
      'quoteUri': serializer.toJson<String?>(quoteUri),
      'quoteCid': serializer.toJson<String?>(quoteCid),
      'facetsJson': serializer.toJson<String?>(facetsJson),
      'externalUri': serializer.toJson<String?>(externalUri),
      'externalTitle': serializer.toJson<String?>(externalTitle),
      'externalDescription': serializer.toJson<String?>(externalDescription),
      'externalThumbBlobJson': serializer.toJson<String?>(externalThumbBlobJson),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Draft copyWith({
    String? id,
    String? content,
    Value<String?> replyParentUri = const Value.absent(),
    Value<String?> replyParentCid = const Value.absent(),
    Value<String?> replyRootUri = const Value.absent(),
    Value<String?> replyRootCid = const Value.absent(),
    Value<String?> quoteUri = const Value.absent(),
    Value<String?> quoteCid = const Value.absent(),
    Value<String?> facetsJson = const Value.absent(),
    Value<String?> externalUri = const Value.absent(),
    Value<String?> externalTitle = const Value.absent(),
    Value<String?> externalDescription = const Value.absent(),
    Value<String?> externalThumbBlobJson = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Draft(
    id: id ?? this.id,
    content: content ?? this.content,
    replyParentUri: replyParentUri.present ? replyParentUri.value : this.replyParentUri,
    replyParentCid: replyParentCid.present ? replyParentCid.value : this.replyParentCid,
    replyRootUri: replyRootUri.present ? replyRootUri.value : this.replyRootUri,
    replyRootCid: replyRootCid.present ? replyRootCid.value : this.replyRootCid,
    quoteUri: quoteUri.present ? quoteUri.value : this.quoteUri,
    quoteCid: quoteCid.present ? quoteCid.value : this.quoteCid,
    facetsJson: facetsJson.present ? facetsJson.value : this.facetsJson,
    externalUri: externalUri.present ? externalUri.value : this.externalUri,
    externalTitle: externalTitle.present ? externalTitle.value : this.externalTitle,
    externalDescription: externalDescription.present
        ? externalDescription.value
        : this.externalDescription,
    externalThumbBlobJson: externalThumbBlobJson.present
        ? externalThumbBlobJson.value
        : this.externalThumbBlobJson,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Draft copyWithCompanion(DraftsCompanion data) {
    return Draft(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      replyParentUri: data.replyParentUri.present
          ? data.replyParentUri.value
          : this.replyParentUri,
      replyParentCid: data.replyParentCid.present
          ? data.replyParentCid.value
          : this.replyParentCid,
      replyRootUri: data.replyRootUri.present ? data.replyRootUri.value : this.replyRootUri,
      replyRootCid: data.replyRootCid.present ? data.replyRootCid.value : this.replyRootCid,
      quoteUri: data.quoteUri.present ? data.quoteUri.value : this.quoteUri,
      quoteCid: data.quoteCid.present ? data.quoteCid.value : this.quoteCid,
      facetsJson: data.facetsJson.present ? data.facetsJson.value : this.facetsJson,
      externalUri: data.externalUri.present ? data.externalUri.value : this.externalUri,
      externalTitle: data.externalTitle.present ? data.externalTitle.value : this.externalTitle,
      externalDescription: data.externalDescription.present
          ? data.externalDescription.value
          : this.externalDescription,
      externalThumbBlobJson: data.externalThumbBlobJson.present
          ? data.externalThumbBlobJson.value
          : this.externalThumbBlobJson,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present ? data.errorMessage.value : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Draft(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('replyParentUri: $replyParentUri, ')
          ..write('replyParentCid: $replyParentCid, ')
          ..write('replyRootUri: $replyRootUri, ')
          ..write('replyRootCid: $replyRootCid, ')
          ..write('quoteUri: $quoteUri, ')
          ..write('quoteCid: $quoteCid, ')
          ..write('facetsJson: $facetsJson, ')
          ..write('externalUri: $externalUri, ')
          ..write('externalTitle: $externalTitle, ')
          ..write('externalDescription: $externalDescription, ')
          ..write('externalThumbBlobJson: $externalThumbBlobJson, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    replyParentUri,
    replyParentCid,
    replyRootUri,
    replyRootCid,
    quoteUri,
    quoteCid,
    facetsJson,
    externalUri,
    externalTitle,
    externalDescription,
    externalThumbBlobJson,
    status,
    errorMessage,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Draft &&
          other.id == this.id &&
          other.content == this.content &&
          other.replyParentUri == this.replyParentUri &&
          other.replyParentCid == this.replyParentCid &&
          other.replyRootUri == this.replyRootUri &&
          other.replyRootCid == this.replyRootCid &&
          other.quoteUri == this.quoteUri &&
          other.quoteCid == this.quoteCid &&
          other.facetsJson == this.facetsJson &&
          other.externalUri == this.externalUri &&
          other.externalTitle == this.externalTitle &&
          other.externalDescription == this.externalDescription &&
          other.externalThumbBlobJson == this.externalThumbBlobJson &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DraftsCompanion extends UpdateCompanion<Draft> {
  final Value<String> id;
  final Value<String> content;
  final Value<String?> replyParentUri;
  final Value<String?> replyParentCid;
  final Value<String?> replyRootUri;
  final Value<String?> replyRootCid;
  final Value<String?> quoteUri;
  final Value<String?> quoteCid;
  final Value<String?> facetsJson;
  final Value<String?> externalUri;
  final Value<String?> externalTitle;
  final Value<String?> externalDescription;
  final Value<String?> externalThumbBlobJson;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.replyParentUri = const Value.absent(),
    this.replyParentCid = const Value.absent(),
    this.replyRootUri = const Value.absent(),
    this.replyRootCid = const Value.absent(),
    this.quoteUri = const Value.absent(),
    this.quoteCid = const Value.absent(),
    this.facetsJson = const Value.absent(),
    this.externalUri = const Value.absent(),
    this.externalTitle = const Value.absent(),
    this.externalDescription = const Value.absent(),
    this.externalThumbBlobJson = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String id,
    this.content = const Value.absent(),
    this.replyParentUri = const Value.absent(),
    this.replyParentCid = const Value.absent(),
    this.replyRootUri = const Value.absent(),
    this.replyRootCid = const Value.absent(),
    this.quoteUri = const Value.absent(),
    this.quoteCid = const Value.absent(),
    this.facetsJson = const Value.absent(),
    this.externalUri = const Value.absent(),
    this.externalTitle = const Value.absent(),
    this.externalDescription = const Value.absent(),
    this.externalThumbBlobJson = const Value.absent(),
    required String status,
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Draft> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? replyParentUri,
    Expression<String>? replyParentCid,
    Expression<String>? replyRootUri,
    Expression<String>? replyRootCid,
    Expression<String>? quoteUri,
    Expression<String>? quoteCid,
    Expression<String>? facetsJson,
    Expression<String>? externalUri,
    Expression<String>? externalTitle,
    Expression<String>? externalDescription,
    Expression<String>? externalThumbBlobJson,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (replyParentUri != null) 'reply_parent_uri': replyParentUri,
      if (replyParentCid != null) 'reply_parent_cid': replyParentCid,
      if (replyRootUri != null) 'reply_root_uri': replyRootUri,
      if (replyRootCid != null) 'reply_root_cid': replyRootCid,
      if (quoteUri != null) 'quote_uri': quoteUri,
      if (quoteCid != null) 'quote_cid': quoteCid,
      if (facetsJson != null) 'facets_json': facetsJson,
      if (externalUri != null) 'external_uri': externalUri,
      if (externalTitle != null) 'external_title': externalTitle,
      if (externalDescription != null) 'external_description': externalDescription,
      if (externalThumbBlobJson != null) 'external_thumb_blob_json': externalThumbBlobJson,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<String?>? replyParentUri,
    Value<String?>? replyParentCid,
    Value<String?>? replyRootUri,
    Value<String?>? replyRootCid,
    Value<String?>? quoteUri,
    Value<String?>? quoteCid,
    Value<String?>? facetsJson,
    Value<String?>? externalUri,
    Value<String?>? externalTitle,
    Value<String?>? externalDescription,
    Value<String?>? externalThumbBlobJson,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DraftsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      replyParentUri: replyParentUri ?? this.replyParentUri,
      replyParentCid: replyParentCid ?? this.replyParentCid,
      replyRootUri: replyRootUri ?? this.replyRootUri,
      replyRootCid: replyRootCid ?? this.replyRootCid,
      quoteUri: quoteUri ?? this.quoteUri,
      quoteCid: quoteCid ?? this.quoteCid,
      facetsJson: facetsJson ?? this.facetsJson,
      externalUri: externalUri ?? this.externalUri,
      externalTitle: externalTitle ?? this.externalTitle,
      externalDescription: externalDescription ?? this.externalDescription,
      externalThumbBlobJson: externalThumbBlobJson ?? this.externalThumbBlobJson,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
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
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (replyParentUri.present) {
      map['reply_parent_uri'] = Variable<String>(replyParentUri.value);
    }
    if (replyParentCid.present) {
      map['reply_parent_cid'] = Variable<String>(replyParentCid.value);
    }
    if (replyRootUri.present) {
      map['reply_root_uri'] = Variable<String>(replyRootUri.value);
    }
    if (replyRootCid.present) {
      map['reply_root_cid'] = Variable<String>(replyRootCid.value);
    }
    if (quoteUri.present) {
      map['quote_uri'] = Variable<String>(quoteUri.value);
    }
    if (quoteCid.present) {
      map['quote_cid'] = Variable<String>(quoteCid.value);
    }
    if (facetsJson.present) {
      map['facets_json'] = Variable<String>(facetsJson.value);
    }
    if (externalUri.present) {
      map['external_uri'] = Variable<String>(externalUri.value);
    }
    if (externalTitle.present) {
      map['external_title'] = Variable<String>(externalTitle.value);
    }
    if (externalDescription.present) {
      map['external_description'] = Variable<String>(externalDescription.value);
    }
    if (externalThumbBlobJson.present) {
      map['external_thumb_blob_json'] = Variable<String>(externalThumbBlobJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
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
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('replyParentUri: $replyParentUri, ')
          ..write('replyParentCid: $replyParentCid, ')
          ..write('replyRootUri: $replyRootUri, ')
          ..write('replyRootCid: $replyRootCid, ')
          ..write('quoteUri: $quoteUri, ')
          ..write('quoteCid: $quoteCid, ')
          ..write('facetsJson: $facetsJson, ')
          ..write('externalUri: $externalUri, ')
          ..write('externalTitle: $externalTitle, ')
          ..write('externalDescription: $externalDescription, ')
          ..write('externalThumbBlobJson: $externalThumbBlobJson, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftMediaTable extends DraftMedia with TableInfo<$DraftMediaTable, DraftMediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftMediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _draftIdMeta = const VerificationMeta('draftId');
  @override
  late final GeneratedColumn<String> draftId = GeneratedColumn<String>(
    'draft_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES drafts (id)'),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altTextMeta = const VerificationMeta('altText');
  @override
  late final GeneratedColumn<String> altText = GeneratedColumn<String>(
    'alt_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadCidMeta = const VerificationMeta('uploadCid');
  @override
  late final GeneratedColumn<String> uploadCid = GeneratedColumn<String>(
    'upload_cid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blobRefJsonMeta = const VerificationMeta('blobRefJson');
  @override
  late final GeneratedColumn<String> blobRefJson = GeneratedColumn<String>(
    'blob_ref_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
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
    draftId,
    localPath,
    mimeType,
    altText,
    uploadCid,
    blobRefJson,
    status,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draft_media';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftMediaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('draft_id')) {
      context.handle(_draftIdMeta, draftId.isAcceptableOrUnknown(data['draft_id']!, _draftIdMeta));
    } else if (isInserting) {
      context.missing(_draftIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('alt_text')) {
      context.handle(_altTextMeta, altText.isAcceptableOrUnknown(data['alt_text']!, _altTextMeta));
    }
    if (data.containsKey('upload_cid')) {
      context.handle(
        _uploadCidMeta,
        uploadCid.isAcceptableOrUnknown(data['upload_cid']!, _uploadCidMeta),
      );
    }
    if (data.containsKey('blob_ref_json')) {
      context.handle(
        _blobRefJsonMeta,
        blobRefJson.isAcceptableOrUnknown(data['blob_ref_json']!, _blobRefJsonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
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
  DraftMediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftMediaData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      draftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      altText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_text'],
      ),
      uploadCid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_cid'],
      ),
      blobRefJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blob_ref_json'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DraftMediaTable createAlias(String alias) {
    return $DraftMediaTable(attachedDatabase, alias);
  }
}

class DraftMediaData extends DataClass implements Insertable<DraftMediaData> {
  final int id;
  final String draftId;
  final String localPath;
  final String mimeType;
  final String? altText;
  final String? uploadCid;
  final String? blobRefJson;
  final String status;
  final int sortOrder;
  final DateTime createdAt;
  const DraftMediaData({
    required this.id,
    required this.draftId,
    required this.localPath,
    required this.mimeType,
    this.altText,
    this.uploadCid,
    this.blobRefJson,
    required this.status,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['draft_id'] = Variable<String>(draftId);
    map['local_path'] = Variable<String>(localPath);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || altText != null) {
      map['alt_text'] = Variable<String>(altText);
    }
    if (!nullToAbsent || uploadCid != null) {
      map['upload_cid'] = Variable<String>(uploadCid);
    }
    if (!nullToAbsent || blobRefJson != null) {
      map['blob_ref_json'] = Variable<String>(blobRefJson);
    }
    map['status'] = Variable<String>(status);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DraftMediaCompanion toCompanion(bool nullToAbsent) {
    return DraftMediaCompanion(
      id: Value(id),
      draftId: Value(draftId),
      localPath: Value(localPath),
      mimeType: Value(mimeType),
      altText: altText == null && nullToAbsent ? const Value.absent() : Value(altText),
      uploadCid: uploadCid == null && nullToAbsent ? const Value.absent() : Value(uploadCid),
      blobRefJson: blobRefJson == null && nullToAbsent ? const Value.absent() : Value(blobRefJson),
      status: Value(status),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory DraftMediaData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftMediaData(
      id: serializer.fromJson<int>(json['id']),
      draftId: serializer.fromJson<String>(json['draftId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      altText: serializer.fromJson<String?>(json['altText']),
      uploadCid: serializer.fromJson<String?>(json['uploadCid']),
      blobRefJson: serializer.fromJson<String?>(json['blobRefJson']),
      status: serializer.fromJson<String>(json['status']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'draftId': serializer.toJson<String>(draftId),
      'localPath': serializer.toJson<String>(localPath),
      'mimeType': serializer.toJson<String>(mimeType),
      'altText': serializer.toJson<String?>(altText),
      'uploadCid': serializer.toJson<String?>(uploadCid),
      'blobRefJson': serializer.toJson<String?>(blobRefJson),
      'status': serializer.toJson<String>(status),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DraftMediaData copyWith({
    int? id,
    String? draftId,
    String? localPath,
    String? mimeType,
    Value<String?> altText = const Value.absent(),
    Value<String?> uploadCid = const Value.absent(),
    Value<String?> blobRefJson = const Value.absent(),
    String? status,
    int? sortOrder,
    DateTime? createdAt,
  }) => DraftMediaData(
    id: id ?? this.id,
    draftId: draftId ?? this.draftId,
    localPath: localPath ?? this.localPath,
    mimeType: mimeType ?? this.mimeType,
    altText: altText.present ? altText.value : this.altText,
    uploadCid: uploadCid.present ? uploadCid.value : this.uploadCid,
    blobRefJson: blobRefJson.present ? blobRefJson.value : this.blobRefJson,
    status: status ?? this.status,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  DraftMediaData copyWithCompanion(DraftMediaCompanion data) {
    return DraftMediaData(
      id: data.id.present ? data.id.value : this.id,
      draftId: data.draftId.present ? data.draftId.value : this.draftId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      altText: data.altText.present ? data.altText.value : this.altText,
      uploadCid: data.uploadCid.present ? data.uploadCid.value : this.uploadCid,
      blobRefJson: data.blobRefJson.present ? data.blobRefJson.value : this.blobRefJson,
      status: data.status.present ? data.status.value : this.status,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftMediaData(')
          ..write('id: $id, ')
          ..write('draftId: $draftId, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('altText: $altText, ')
          ..write('uploadCid: $uploadCid, ')
          ..write('blobRefJson: $blobRefJson, ')
          ..write('status: $status, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    draftId,
    localPath,
    mimeType,
    altText,
    uploadCid,
    blobRefJson,
    status,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftMediaData &&
          other.id == this.id &&
          other.draftId == this.draftId &&
          other.localPath == this.localPath &&
          other.mimeType == this.mimeType &&
          other.altText == this.altText &&
          other.uploadCid == this.uploadCid &&
          other.blobRefJson == this.blobRefJson &&
          other.status == this.status &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class DraftMediaCompanion extends UpdateCompanion<DraftMediaData> {
  final Value<int> id;
  final Value<String> draftId;
  final Value<String> localPath;
  final Value<String> mimeType;
  final Value<String?> altText;
  final Value<String?> uploadCid;
  final Value<String?> blobRefJson;
  final Value<String> status;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const DraftMediaCompanion({
    this.id = const Value.absent(),
    this.draftId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.altText = const Value.absent(),
    this.uploadCid = const Value.absent(),
    this.blobRefJson = const Value.absent(),
    this.status = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DraftMediaCompanion.insert({
    this.id = const Value.absent(),
    required String draftId,
    required String localPath,
    required String mimeType,
    this.altText = const Value.absent(),
    this.uploadCid = const Value.absent(),
    this.blobRefJson = const Value.absent(),
    required String status,
    required int sortOrder,
    required DateTime createdAt,
  }) : draftId = Value(draftId),
       localPath = Value(localPath),
       mimeType = Value(mimeType),
       status = Value(status),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<DraftMediaData> custom({
    Expression<int>? id,
    Expression<String>? draftId,
    Expression<String>? localPath,
    Expression<String>? mimeType,
    Expression<String>? altText,
    Expression<String>? uploadCid,
    Expression<String>? blobRefJson,
    Expression<String>? status,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (draftId != null) 'draft_id': draftId,
      if (localPath != null) 'local_path': localPath,
      if (mimeType != null) 'mime_type': mimeType,
      if (altText != null) 'alt_text': altText,
      if (uploadCid != null) 'upload_cid': uploadCid,
      if (blobRefJson != null) 'blob_ref_json': blobRefJson,
      if (status != null) 'status': status,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DraftMediaCompanion copyWith({
    Value<int>? id,
    Value<String>? draftId,
    Value<String>? localPath,
    Value<String>? mimeType,
    Value<String?>? altText,
    Value<String?>? uploadCid,
    Value<String?>? blobRefJson,
    Value<String>? status,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return DraftMediaCompanion(
      id: id ?? this.id,
      draftId: draftId ?? this.draftId,
      localPath: localPath ?? this.localPath,
      mimeType: mimeType ?? this.mimeType,
      altText: altText ?? this.altText,
      uploadCid: uploadCid ?? this.uploadCid,
      blobRefJson: blobRefJson ?? this.blobRefJson,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (draftId.present) {
      map['draft_id'] = Variable<String>(draftId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (altText.present) {
      map['alt_text'] = Variable<String>(altText.value);
    }
    if (uploadCid.present) {
      map['upload_cid'] = Variable<String>(uploadCid.value);
    }
    if (blobRefJson.present) {
      map['blob_ref_json'] = Variable<String>(blobRefJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftMediaCompanion(')
          ..write('id: $id, ')
          ..write('draftId: $draftId, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('altText: $altText, ')
          ..write('uploadCid: $uploadCid, ')
          ..write('blobRefJson: $blobRefJson, ')
          ..write('status: $status, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProfileRelationshipsTable extends ProfileRelationships
    with TableInfo<$ProfileRelationshipsTable, ProfileRelationship> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileRelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileDidMeta = const VerificationMeta('profileDid');
  @override
  late final GeneratedColumn<String> profileDid = GeneratedColumn<String>(
    'profile_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES profiles (did)'),
  );
  static const VerificationMeta _followingMeta = const VerificationMeta('following');
  @override
  late final GeneratedColumn<bool> following = GeneratedColumn<bool>(
    'following',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("following" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _followingUriMeta = const VerificationMeta('followingUri');
  @override
  late final GeneratedColumn<String> followingUri = GeneratedColumn<String>(
    'following_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _followedByMeta = const VerificationMeta('followedBy');
  @override
  late final GeneratedColumn<bool> followedBy = GeneratedColumn<bool>(
    'followed_by',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("followed_by" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<bool> muted = GeneratedColumn<bool>(
    'muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("muted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _blockedMeta = const VerificationMeta('blocked');
  @override
  late final GeneratedColumn<bool> blocked = GeneratedColumn<bool>(
    'blocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("blocked" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _blockedByMeta = const VerificationMeta('blockedBy');
  @override
  late final GeneratedColumn<bool> blockedBy = GeneratedColumn<bool>(
    'blocked_by',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("blocked_by" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _blockingUriMeta = const VerificationMeta('blockingUri');
  @override
  late final GeneratedColumn<String> blockingUri = GeneratedColumn<String>(
    'blocking_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mutedByListMeta = const VerificationMeta('mutedByList');
  @override
  late final GeneratedColumn<String> mutedByList = GeneratedColumn<String>(
    'muted_by_list',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockingByListMeta = const VerificationMeta('blockingByList');
  @override
  late final GeneratedColumn<String> blockingByList = GeneratedColumn<String>(
    'blocking_by_list',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerDid,
    profileDid,
    following,
    followingUri,
    followedBy,
    muted,
    blocked,
    blockedBy,
    blockingUri,
    mutedByList,
    blockingByList,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRelationship> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('profile_did')) {
      context.handle(
        _profileDidMeta,
        profileDid.isAcceptableOrUnknown(data['profile_did']!, _profileDidMeta),
      );
    } else if (isInserting) {
      context.missing(_profileDidMeta);
    }
    if (data.containsKey('following')) {
      context.handle(
        _followingMeta,
        following.isAcceptableOrUnknown(data['following']!, _followingMeta),
      );
    }
    if (data.containsKey('following_uri')) {
      context.handle(
        _followingUriMeta,
        followingUri.isAcceptableOrUnknown(data['following_uri']!, _followingUriMeta),
      );
    }
    if (data.containsKey('followed_by')) {
      context.handle(
        _followedByMeta,
        followedBy.isAcceptableOrUnknown(data['followed_by']!, _followedByMeta),
      );
    }
    if (data.containsKey('muted')) {
      context.handle(_mutedMeta, muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta));
    }
    if (data.containsKey('blocked')) {
      context.handle(_blockedMeta, blocked.isAcceptableOrUnknown(data['blocked']!, _blockedMeta));
    }
    if (data.containsKey('blocked_by')) {
      context.handle(
        _blockedByMeta,
        blockedBy.isAcceptableOrUnknown(data['blocked_by']!, _blockedByMeta),
      );
    }
    if (data.containsKey('blocking_uri')) {
      context.handle(
        _blockingUriMeta,
        blockingUri.isAcceptableOrUnknown(data['blocking_uri']!, _blockingUriMeta),
      );
    }
    if (data.containsKey('muted_by_list')) {
      context.handle(
        _mutedByListMeta,
        mutedByList.isAcceptableOrUnknown(data['muted_by_list']!, _mutedByListMeta),
      );
    }
    if (data.containsKey('blocking_by_list')) {
      context.handle(
        _blockingByListMeta,
        blockingByList.isAcceptableOrUnknown(data['blocking_by_list']!, _blockingByListMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerDid, profileDid};
  @override
  ProfileRelationship map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRelationship(
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      profileDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_did'],
      )!,
      following: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}following'],
      )!,
      followingUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}following_uri'],
      ),
      followedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}followed_by'],
      )!,
      muted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}muted'],
      )!,
      blocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}blocked'],
      )!,
      blockedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}blocked_by'],
      )!,
      blockingUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blocking_uri'],
      ),
      mutedByList: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muted_by_list'],
      ),
      blockingByList: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blocking_by_list'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfileRelationshipsTable createAlias(String alias) {
    return $ProfileRelationshipsTable(attachedDatabase, alias);
  }
}

class ProfileRelationship extends DataClass implements Insertable<ProfileRelationship> {
  /// The DID of the owner (the user who sees these relationships).
  final String ownerDid;

  /// The DID of the profile this relationship applies to (subject).
  final String profileDid;

  /// Whether the viewer is following this profile.
  final bool following;

  /// The URI of the follow record (if following).
  final String? followingUri;

  /// Whether this profile follows the viewer.
  final bool followedBy;

  /// Whether the viewer has muted this profile.
  final bool muted;

  /// Whether the viewer has blocked this profile.
  final bool blocked;

  /// Whether this profile has blocked the viewer.
  final bool blockedBy;

  /// The URI of the block record (if blocking).
  final String? blockingUri;

  /// Reference to the list that muted this profile (if applicable).
  final String? mutedByList;

  /// Reference to the list that blocked this profile (if applicable).
  final String? blockingByList;

  /// When this relationship was last updated.
  final DateTime updatedAt;
  const ProfileRelationship({
    required this.ownerDid,
    required this.profileDid,
    required this.following,
    this.followingUri,
    required this.followedBy,
    required this.muted,
    required this.blocked,
    required this.blockedBy,
    this.blockingUri,
    this.mutedByList,
    this.blockingByList,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_did'] = Variable<String>(ownerDid);
    map['profile_did'] = Variable<String>(profileDid);
    map['following'] = Variable<bool>(following);
    if (!nullToAbsent || followingUri != null) {
      map['following_uri'] = Variable<String>(followingUri);
    }
    map['followed_by'] = Variable<bool>(followedBy);
    map['muted'] = Variable<bool>(muted);
    map['blocked'] = Variable<bool>(blocked);
    map['blocked_by'] = Variable<bool>(blockedBy);
    if (!nullToAbsent || blockingUri != null) {
      map['blocking_uri'] = Variable<String>(blockingUri);
    }
    if (!nullToAbsent || mutedByList != null) {
      map['muted_by_list'] = Variable<String>(mutedByList);
    }
    if (!nullToAbsent || blockingByList != null) {
      map['blocking_by_list'] = Variable<String>(blockingByList);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfileRelationshipsCompanion toCompanion(bool nullToAbsent) {
    return ProfileRelationshipsCompanion(
      ownerDid: Value(ownerDid),
      profileDid: Value(profileDid),
      following: Value(following),
      followingUri: followingUri == null && nullToAbsent
          ? const Value.absent()
          : Value(followingUri),
      followedBy: Value(followedBy),
      muted: Value(muted),
      blocked: Value(blocked),
      blockedBy: Value(blockedBy),
      blockingUri: blockingUri == null && nullToAbsent ? const Value.absent() : Value(blockingUri),
      mutedByList: mutedByList == null && nullToAbsent ? const Value.absent() : Value(mutedByList),
      blockingByList: blockingByList == null && nullToAbsent
          ? const Value.absent()
          : Value(blockingByList),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfileRelationship.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRelationship(
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      profileDid: serializer.fromJson<String>(json['profileDid']),
      following: serializer.fromJson<bool>(json['following']),
      followingUri: serializer.fromJson<String?>(json['followingUri']),
      followedBy: serializer.fromJson<bool>(json['followedBy']),
      muted: serializer.fromJson<bool>(json['muted']),
      blocked: serializer.fromJson<bool>(json['blocked']),
      blockedBy: serializer.fromJson<bool>(json['blockedBy']),
      blockingUri: serializer.fromJson<String?>(json['blockingUri']),
      mutedByList: serializer.fromJson<String?>(json['mutedByList']),
      blockingByList: serializer.fromJson<String?>(json['blockingByList']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerDid': serializer.toJson<String>(ownerDid),
      'profileDid': serializer.toJson<String>(profileDid),
      'following': serializer.toJson<bool>(following),
      'followingUri': serializer.toJson<String?>(followingUri),
      'followedBy': serializer.toJson<bool>(followedBy),
      'muted': serializer.toJson<bool>(muted),
      'blocked': serializer.toJson<bool>(blocked),
      'blockedBy': serializer.toJson<bool>(blockedBy),
      'blockingUri': serializer.toJson<String?>(blockingUri),
      'mutedByList': serializer.toJson<String?>(mutedByList),
      'blockingByList': serializer.toJson<String?>(blockingByList),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfileRelationship copyWith({
    String? ownerDid,
    String? profileDid,
    bool? following,
    Value<String?> followingUri = const Value.absent(),
    bool? followedBy,
    bool? muted,
    bool? blocked,
    bool? blockedBy,
    Value<String?> blockingUri = const Value.absent(),
    Value<String?> mutedByList = const Value.absent(),
    Value<String?> blockingByList = const Value.absent(),
    DateTime? updatedAt,
  }) => ProfileRelationship(
    ownerDid: ownerDid ?? this.ownerDid,
    profileDid: profileDid ?? this.profileDid,
    following: following ?? this.following,
    followingUri: followingUri.present ? followingUri.value : this.followingUri,
    followedBy: followedBy ?? this.followedBy,
    muted: muted ?? this.muted,
    blocked: blocked ?? this.blocked,
    blockedBy: blockedBy ?? this.blockedBy,
    blockingUri: blockingUri.present ? blockingUri.value : this.blockingUri,
    mutedByList: mutedByList.present ? mutedByList.value : this.mutedByList,
    blockingByList: blockingByList.present ? blockingByList.value : this.blockingByList,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfileRelationship copyWithCompanion(ProfileRelationshipsCompanion data) {
    return ProfileRelationship(
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      profileDid: data.profileDid.present ? data.profileDid.value : this.profileDid,
      following: data.following.present ? data.following.value : this.following,
      followingUri: data.followingUri.present ? data.followingUri.value : this.followingUri,
      followedBy: data.followedBy.present ? data.followedBy.value : this.followedBy,
      muted: data.muted.present ? data.muted.value : this.muted,
      blocked: data.blocked.present ? data.blocked.value : this.blocked,
      blockedBy: data.blockedBy.present ? data.blockedBy.value : this.blockedBy,
      blockingUri: data.blockingUri.present ? data.blockingUri.value : this.blockingUri,
      mutedByList: data.mutedByList.present ? data.mutedByList.value : this.mutedByList,
      blockingByList: data.blockingByList.present
          ? data.blockingByList.value
          : this.blockingByList,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRelationship(')
          ..write('ownerDid: $ownerDid, ')
          ..write('profileDid: $profileDid, ')
          ..write('following: $following, ')
          ..write('followingUri: $followingUri, ')
          ..write('followedBy: $followedBy, ')
          ..write('muted: $muted, ')
          ..write('blocked: $blocked, ')
          ..write('blockedBy: $blockedBy, ')
          ..write('blockingUri: $blockingUri, ')
          ..write('mutedByList: $mutedByList, ')
          ..write('blockingByList: $blockingByList, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerDid,
    profileDid,
    following,
    followingUri,
    followedBy,
    muted,
    blocked,
    blockedBy,
    blockingUri,
    mutedByList,
    blockingByList,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRelationship &&
          other.ownerDid == this.ownerDid &&
          other.profileDid == this.profileDid &&
          other.following == this.following &&
          other.followingUri == this.followingUri &&
          other.followedBy == this.followedBy &&
          other.muted == this.muted &&
          other.blocked == this.blocked &&
          other.blockedBy == this.blockedBy &&
          other.blockingUri == this.blockingUri &&
          other.mutedByList == this.mutedByList &&
          other.blockingByList == this.blockingByList &&
          other.updatedAt == this.updatedAt);
}

class ProfileRelationshipsCompanion extends UpdateCompanion<ProfileRelationship> {
  final Value<String> ownerDid;
  final Value<String> profileDid;
  final Value<bool> following;
  final Value<String?> followingUri;
  final Value<bool> followedBy;
  final Value<bool> muted;
  final Value<bool> blocked;
  final Value<bool> blockedBy;
  final Value<String?> blockingUri;
  final Value<String?> mutedByList;
  final Value<String?> blockingByList;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfileRelationshipsCompanion({
    this.ownerDid = const Value.absent(),
    this.profileDid = const Value.absent(),
    this.following = const Value.absent(),
    this.followingUri = const Value.absent(),
    this.followedBy = const Value.absent(),
    this.muted = const Value.absent(),
    this.blocked = const Value.absent(),
    this.blockedBy = const Value.absent(),
    this.blockingUri = const Value.absent(),
    this.mutedByList = const Value.absent(),
    this.blockingByList = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileRelationshipsCompanion.insert({
    required String ownerDid,
    required String profileDid,
    this.following = const Value.absent(),
    this.followingUri = const Value.absent(),
    this.followedBy = const Value.absent(),
    this.muted = const Value.absent(),
    this.blocked = const Value.absent(),
    this.blockedBy = const Value.absent(),
    this.blockingUri = const Value.absent(),
    this.mutedByList = const Value.absent(),
    this.blockingByList = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : ownerDid = Value(ownerDid),
       profileDid = Value(profileDid),
       updatedAt = Value(updatedAt);
  static Insertable<ProfileRelationship> custom({
    Expression<String>? ownerDid,
    Expression<String>? profileDid,
    Expression<bool>? following,
    Expression<String>? followingUri,
    Expression<bool>? followedBy,
    Expression<bool>? muted,
    Expression<bool>? blocked,
    Expression<bool>? blockedBy,
    Expression<String>? blockingUri,
    Expression<String>? mutedByList,
    Expression<String>? blockingByList,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerDid != null) 'owner_did': ownerDid,
      if (profileDid != null) 'profile_did': profileDid,
      if (following != null) 'following': following,
      if (followingUri != null) 'following_uri': followingUri,
      if (followedBy != null) 'followed_by': followedBy,
      if (muted != null) 'muted': muted,
      if (blocked != null) 'blocked': blocked,
      if (blockedBy != null) 'blocked_by': blockedBy,
      if (blockingUri != null) 'blocking_uri': blockingUri,
      if (mutedByList != null) 'muted_by_list': mutedByList,
      if (blockingByList != null) 'blocking_by_list': blockingByList,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileRelationshipsCompanion copyWith({
    Value<String>? ownerDid,
    Value<String>? profileDid,
    Value<bool>? following,
    Value<String?>? followingUri,
    Value<bool>? followedBy,
    Value<bool>? muted,
    Value<bool>? blocked,
    Value<bool>? blockedBy,
    Value<String?>? blockingUri,
    Value<String?>? mutedByList,
    Value<String?>? blockingByList,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfileRelationshipsCompanion(
      ownerDid: ownerDid ?? this.ownerDid,
      profileDid: profileDid ?? this.profileDid,
      following: following ?? this.following,
      followingUri: followingUri ?? this.followingUri,
      followedBy: followedBy ?? this.followedBy,
      muted: muted ?? this.muted,
      blocked: blocked ?? this.blocked,
      blockedBy: blockedBy ?? this.blockedBy,
      blockingUri: blockingUri ?? this.blockingUri,
      mutedByList: mutedByList ?? this.mutedByList,
      blockingByList: blockingByList ?? this.blockingByList,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (profileDid.present) {
      map['profile_did'] = Variable<String>(profileDid.value);
    }
    if (following.present) {
      map['following'] = Variable<bool>(following.value);
    }
    if (followingUri.present) {
      map['following_uri'] = Variable<String>(followingUri.value);
    }
    if (followedBy.present) {
      map['followed_by'] = Variable<bool>(followedBy.value);
    }
    if (muted.present) {
      map['muted'] = Variable<bool>(muted.value);
    }
    if (blocked.present) {
      map['blocked'] = Variable<bool>(blocked.value);
    }
    if (blockedBy.present) {
      map['blocked_by'] = Variable<bool>(blockedBy.value);
    }
    if (blockingUri.present) {
      map['blocking_uri'] = Variable<String>(blockingUri.value);
    }
    if (mutedByList.present) {
      map['muted_by_list'] = Variable<String>(mutedByList.value);
    }
    if (blockingByList.present) {
      map['blocking_by_list'] = Variable<String>(blockingByList.value);
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
    return (StringBuffer('ProfileRelationshipsCompanion(')
          ..write('ownerDid: $ownerDid, ')
          ..write('profileDid: $profileDid, ')
          ..write('following: $following, ')
          ..write('followingUri: $followingUri, ')
          ..write('followedBy: $followedBy, ')
          ..write('muted: $muted, ')
          ..write('blocked: $blocked, ')
          ..write('blockedBy: $blockedBy, ')
          ..write('blockingUri: $blockingUri, ')
          ..write('mutedByList: $mutedByList, ')
          ..write('blockingByList: $blockingByList, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostInteractionsTable extends PostInteractions
    with TableInfo<$PostInteractionsTable, PostInteraction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostInteractionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _postUriMeta = const VerificationMeta('postUri');
  @override
  late final GeneratedColumn<String> postUri = GeneratedColumn<String>(
    'post_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES posts (uri)'),
  );
  static const VerificationMeta _likeUriMeta = const VerificationMeta('likeUri');
  @override
  late final GeneratedColumn<String> likeUri = GeneratedColumn<String>(
    'like_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repostUriMeta = const VerificationMeta('repostUri');
  @override
  late final GeneratedColumn<String> repostUri = GeneratedColumn<String>(
    'repost_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookmarkedMeta = const VerificationMeta('bookmarked');
  @override
  late final GeneratedColumn<bool> bookmarked = GeneratedColumn<bool>(
    'bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("bookmarked" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _threadMutedMeta = const VerificationMeta('threadMuted');
  @override
  late final GeneratedColumn<bool> threadMuted = GeneratedColumn<bool>(
    'thread_muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("thread_muted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    postUri,
    likeUri,
    repostUri,
    bookmarked,
    threadMuted,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'post_interactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostInteraction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('post_uri')) {
      context.handle(_postUriMeta, postUri.isAcceptableOrUnknown(data['post_uri']!, _postUriMeta));
    } else if (isInserting) {
      context.missing(_postUriMeta);
    }
    if (data.containsKey('like_uri')) {
      context.handle(_likeUriMeta, likeUri.isAcceptableOrUnknown(data['like_uri']!, _likeUriMeta));
    }
    if (data.containsKey('repost_uri')) {
      context.handle(
        _repostUriMeta,
        repostUri.isAcceptableOrUnknown(data['repost_uri']!, _repostUriMeta),
      );
    }
    if (data.containsKey('bookmarked')) {
      context.handle(
        _bookmarkedMeta,
        bookmarked.isAcceptableOrUnknown(data['bookmarked']!, _bookmarkedMeta),
      );
    }
    if (data.containsKey('thread_muted')) {
      context.handle(
        _threadMutedMeta,
        threadMuted.isAcceptableOrUnknown(data['thread_muted']!, _threadMutedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {postUri};
  @override
  PostInteraction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostInteraction(
      postUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_uri'],
      )!,
      likeUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}like_uri'],
      ),
      repostUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repost_uri'],
      ),
      bookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bookmarked'],
      )!,
      threadMuted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}thread_muted'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PostInteractionsTable createAlias(String alias) {
    return $PostInteractionsTable(attachedDatabase, alias);
  }
}

class PostInteraction extends DataClass implements Insertable<PostInteraction> {
  /// Reference to the post this interaction applies to.
  final String postUri;

  /// AT URI of the like record (if liked).
  final String? likeUri;

  /// AT URI of the repost record (if reposted).
  final String? repostUri;

  /// Whether the post is bookmarked.
  final bool bookmarked;

  /// Whether the thread is muted.
  final bool threadMuted;

  /// When this interaction was last updated.
  final DateTime updatedAt;
  const PostInteraction({
    required this.postUri,
    this.likeUri,
    this.repostUri,
    required this.bookmarked,
    required this.threadMuted,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['post_uri'] = Variable<String>(postUri);
    if (!nullToAbsent || likeUri != null) {
      map['like_uri'] = Variable<String>(likeUri);
    }
    if (!nullToAbsent || repostUri != null) {
      map['repost_uri'] = Variable<String>(repostUri);
    }
    map['bookmarked'] = Variable<bool>(bookmarked);
    map['thread_muted'] = Variable<bool>(threadMuted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PostInteractionsCompanion toCompanion(bool nullToAbsent) {
    return PostInteractionsCompanion(
      postUri: Value(postUri),
      likeUri: likeUri == null && nullToAbsent ? const Value.absent() : Value(likeUri),
      repostUri: repostUri == null && nullToAbsent ? const Value.absent() : Value(repostUri),
      bookmarked: Value(bookmarked),
      threadMuted: Value(threadMuted),
      updatedAt: Value(updatedAt),
    );
  }

  factory PostInteraction.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostInteraction(
      postUri: serializer.fromJson<String>(json['postUri']),
      likeUri: serializer.fromJson<String?>(json['likeUri']),
      repostUri: serializer.fromJson<String?>(json['repostUri']),
      bookmarked: serializer.fromJson<bool>(json['bookmarked']),
      threadMuted: serializer.fromJson<bool>(json['threadMuted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'postUri': serializer.toJson<String>(postUri),
      'likeUri': serializer.toJson<String?>(likeUri),
      'repostUri': serializer.toJson<String?>(repostUri),
      'bookmarked': serializer.toJson<bool>(bookmarked),
      'threadMuted': serializer.toJson<bool>(threadMuted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PostInteraction copyWith({
    String? postUri,
    Value<String?> likeUri = const Value.absent(),
    Value<String?> repostUri = const Value.absent(),
    bool? bookmarked,
    bool? threadMuted,
    DateTime? updatedAt,
  }) => PostInteraction(
    postUri: postUri ?? this.postUri,
    likeUri: likeUri.present ? likeUri.value : this.likeUri,
    repostUri: repostUri.present ? repostUri.value : this.repostUri,
    bookmarked: bookmarked ?? this.bookmarked,
    threadMuted: threadMuted ?? this.threadMuted,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PostInteraction copyWithCompanion(PostInteractionsCompanion data) {
    return PostInteraction(
      postUri: data.postUri.present ? data.postUri.value : this.postUri,
      likeUri: data.likeUri.present ? data.likeUri.value : this.likeUri,
      repostUri: data.repostUri.present ? data.repostUri.value : this.repostUri,
      bookmarked: data.bookmarked.present ? data.bookmarked.value : this.bookmarked,
      threadMuted: data.threadMuted.present ? data.threadMuted.value : this.threadMuted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostInteraction(')
          ..write('postUri: $postUri, ')
          ..write('likeUri: $likeUri, ')
          ..write('repostUri: $repostUri, ')
          ..write('bookmarked: $bookmarked, ')
          ..write('threadMuted: $threadMuted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(postUri, likeUri, repostUri, bookmarked, threadMuted, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostInteraction &&
          other.postUri == this.postUri &&
          other.likeUri == this.likeUri &&
          other.repostUri == this.repostUri &&
          other.bookmarked == this.bookmarked &&
          other.threadMuted == this.threadMuted &&
          other.updatedAt == this.updatedAt);
}

class PostInteractionsCompanion extends UpdateCompanion<PostInteraction> {
  final Value<String> postUri;
  final Value<String?> likeUri;
  final Value<String?> repostUri;
  final Value<bool> bookmarked;
  final Value<bool> threadMuted;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PostInteractionsCompanion({
    this.postUri = const Value.absent(),
    this.likeUri = const Value.absent(),
    this.repostUri = const Value.absent(),
    this.bookmarked = const Value.absent(),
    this.threadMuted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostInteractionsCompanion.insert({
    required String postUri,
    this.likeUri = const Value.absent(),
    this.repostUri = const Value.absent(),
    this.bookmarked = const Value.absent(),
    this.threadMuted = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : postUri = Value(postUri),
       updatedAt = Value(updatedAt);
  static Insertable<PostInteraction> custom({
    Expression<String>? postUri,
    Expression<String>? likeUri,
    Expression<String>? repostUri,
    Expression<bool>? bookmarked,
    Expression<bool>? threadMuted,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (postUri != null) 'post_uri': postUri,
      if (likeUri != null) 'like_uri': likeUri,
      if (repostUri != null) 'repost_uri': repostUri,
      if (bookmarked != null) 'bookmarked': bookmarked,
      if (threadMuted != null) 'thread_muted': threadMuted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostInteractionsCompanion copyWith({
    Value<String>? postUri,
    Value<String?>? likeUri,
    Value<String?>? repostUri,
    Value<bool>? bookmarked,
    Value<bool>? threadMuted,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PostInteractionsCompanion(
      postUri: postUri ?? this.postUri,
      likeUri: likeUri ?? this.likeUri,
      repostUri: repostUri ?? this.repostUri,
      bookmarked: bookmarked ?? this.bookmarked,
      threadMuted: threadMuted ?? this.threadMuted,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (postUri.present) {
      map['post_uri'] = Variable<String>(postUri.value);
    }
    if (likeUri.present) {
      map['like_uri'] = Variable<String>(likeUri.value);
    }
    if (repostUri.present) {
      map['repost_uri'] = Variable<String>(repostUri.value);
    }
    if (bookmarked.present) {
      map['bookmarked'] = Variable<bool>(bookmarked.value);
    }
    if (threadMuted.present) {
      map['thread_muted'] = Variable<bool>(threadMuted.value);
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
    return (StringBuffer('PostInteractionsCompanion(')
          ..write('postUri: $postUri, ')
          ..write('likeUri: $likeUri, ')
          ..write('repostUri: $repostUri, ')
          ..write('bookmarked: $bookmarked, ')
          ..write('threadMuted: $threadMuted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSettingsTable extends LocalSettings with TableInfo<$LocalSettingsTable, LocalSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSetting(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
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
  $LocalSettingsTable createAlias(String alias) {
    return $LocalSettingsTable(attachedDatabase, alias);
  }
}

class LocalSetting extends DataClass implements Insertable<LocalSetting> {
  /// Setting key (e.g., 'themeMode', 'themePackId').
  final String key;

  /// Setting value (serialized as string).
  final String value;

  /// When this setting was last updated.
  final DateTime updatedAt;
  const LocalSetting({required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalSetting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSetting(
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

  LocalSetting copyWith({String? key, String? value, DateTime? updatedAt}) => LocalSetting(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalSetting copyWithCompanion(LocalSettingsCompanion data) {
    return LocalSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSetting(')
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
      (other is LocalSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class LocalSettingsCompanion extends UpdateCompanion<LocalSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<LocalSetting> custom({
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

  LocalSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalSettingsCompanion(
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
    return (StringBuffer('LocalSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BlueskyPreferencesTable extends BlueskyPreferences
    with TableInfo<$BlueskyPreferencesTable, BlueskyPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlueskyPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta('lastSynced');
  @override
  late final GeneratedColumn<DateTime> lastSynced = GeneratedColumn<DateTime>(
    'last_synced',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [type, ownerDid, data, lastSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bluesky_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlueskyPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('data')) {
      context.handle(_dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('last_synced')) {
      context.handle(
        _lastSyncedMeta,
        lastSynced.isAcceptableOrUnknown(data['last_synced']!, _lastSyncedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type, ownerDid};
  @override
  BlueskyPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlueskyPreference(
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      lastSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced'],
      )!,
    );
  }

  @override
  $BlueskyPreferencesTable createAlias(String alias) {
    return $BlueskyPreferencesTable(attachedDatabase, alias);
  }
}

class BlueskyPreference extends DataClass implements Insertable<BlueskyPreference> {
  /// The preference type identifier (e.g., 'contentLabel', 'adultContent').
  final String type;

  /// The DID of the owner of these preferences.
  final String ownerDid;

  /// The preference data serialized as JSON.
  final String data;

  /// When this preference was last synced from the remote server.
  final DateTime lastSynced;
  const BlueskyPreference({
    required this.type,
    required this.ownerDid,
    required this.data,
    required this.lastSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['type'] = Variable<String>(type);
    map['owner_did'] = Variable<String>(ownerDid);
    map['data'] = Variable<String>(data);
    map['last_synced'] = Variable<DateTime>(lastSynced);
    return map;
  }

  BlueskyPreferencesCompanion toCompanion(bool nullToAbsent) {
    return BlueskyPreferencesCompanion(
      type: Value(type),
      ownerDid: Value(ownerDid),
      data: Value(data),
      lastSynced: Value(lastSynced),
    );
  }

  factory BlueskyPreference.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlueskyPreference(
      type: serializer.fromJson<String>(json['type']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      data: serializer.fromJson<String>(json['data']),
      lastSynced: serializer.fromJson<DateTime>(json['lastSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<String>(type),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'data': serializer.toJson<String>(data),
      'lastSynced': serializer.toJson<DateTime>(lastSynced),
    };
  }

  BlueskyPreference copyWith({
    String? type,
    String? ownerDid,
    String? data,
    DateTime? lastSynced,
  }) => BlueskyPreference(
    type: type ?? this.type,
    ownerDid: ownerDid ?? this.ownerDid,
    data: data ?? this.data,
    lastSynced: lastSynced ?? this.lastSynced,
  );
  BlueskyPreference copyWithCompanion(BlueskyPreferencesCompanion data) {
    return BlueskyPreference(
      type: data.type.present ? data.type.value : this.type,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      data: data.data.present ? data.data.value : this.data,
      lastSynced: data.lastSynced.present ? data.lastSynced.value : this.lastSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlueskyPreference(')
          ..write('type: $type, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('data: $data, ')
          ..write('lastSynced: $lastSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(type, ownerDid, data, lastSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlueskyPreference &&
          other.type == this.type &&
          other.ownerDid == this.ownerDid &&
          other.data == this.data &&
          other.lastSynced == this.lastSynced);
}

class BlueskyPreferencesCompanion extends UpdateCompanion<BlueskyPreference> {
  final Value<String> type;
  final Value<String> ownerDid;
  final Value<String> data;
  final Value<DateTime> lastSynced;
  final Value<int> rowid;
  const BlueskyPreferencesCompanion({
    this.type = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.data = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BlueskyPreferencesCompanion.insert({
    required String type,
    required String ownerDid,
    required String data,
    required DateTime lastSynced,
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       ownerDid = Value(ownerDid),
       data = Value(data),
       lastSynced = Value(lastSynced);
  static Insertable<BlueskyPreference> custom({
    Expression<String>? type,
    Expression<String>? ownerDid,
    Expression<String>? data,
    Expression<DateTime>? lastSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (data != null) 'data': data,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BlueskyPreferencesCompanion copyWith({
    Value<String>? type,
    Value<String>? ownerDid,
    Value<String>? data,
    Value<DateTime>? lastSynced,
    Value<int>? rowid,
  }) {
    return BlueskyPreferencesCompanion(
      type: type ?? this.type,
      ownerDid: ownerDid ?? this.ownerDid,
      data: data ?? this.data,
      lastSynced: lastSynced ?? this.lastSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<DateTime>(lastSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlueskyPreferencesCompanion(')
          ..write('type: $type, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('data: $data, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomThemesTable extends CustomThemes with TableInfo<$CustomThemesTable, CustomTheme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomThemesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _basePackIdMeta = const VerificationMeta('basePackId');
  @override
  late final GeneratedColumn<String> basePackId = GeneratedColumn<String>(
    'base_pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overridesJsonMeta = const VerificationMeta('overridesJson');
  @override
  late final GeneratedColumn<String> overridesJson = GeneratedColumn<String>(
    'overrides_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typographyScaleMeta = const VerificationMeta('typographyScale');
  @override
  late final GeneratedColumn<String> typographyScale = GeneratedColumn<String>(
    'typography_scale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    basePackId,
    overridesJson,
    typographyScale,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_themes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomTheme> instance, {
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
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('base_pack_id')) {
      context.handle(
        _basePackIdMeta,
        basePackId.isAcceptableOrUnknown(data['base_pack_id']!, _basePackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_basePackIdMeta);
    }
    if (data.containsKey('overrides_json')) {
      context.handle(
        _overridesJsonMeta,
        overridesJson.isAcceptableOrUnknown(data['overrides_json']!, _overridesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_overridesJsonMeta);
    }
    if (data.containsKey('typography_scale')) {
      context.handle(
        _typographyScaleMeta,
        typographyScale.isAcceptableOrUnknown(data['typography_scale']!, _typographyScaleMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomTheme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomTheme(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      basePackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_pack_id'],
      )!,
      overridesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overrides_json'],
      )!,
      typographyScale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}typography_scale'],
      )!,
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
  $CustomThemesTable createAlias(String alias) {
    return $CustomThemesTable(attachedDatabase, alias);
  }
}

class CustomTheme extends DataClass implements Insertable<CustomTheme> {
  /// Unique identifier for this custom theme.
  final String id;

  /// User-provided display name.
  final String name;

  /// ID of the base theme pack this customization extends.
  final String basePackId;

  /// Color role overrides serialized as JSON.
  final String overridesJson;

  /// Typography scale preference (small/normal/large).
  final String typographyScale;

  /// When this theme was first created.
  final DateTime createdAt;

  /// When this theme was last modified.
  final DateTime updatedAt;
  const CustomTheme({
    required this.id,
    required this.name,
    required this.basePackId,
    required this.overridesJson,
    required this.typographyScale,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['base_pack_id'] = Variable<String>(basePackId);
    map['overrides_json'] = Variable<String>(overridesJson);
    map['typography_scale'] = Variable<String>(typographyScale);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomThemesCompanion toCompanion(bool nullToAbsent) {
    return CustomThemesCompanion(
      id: Value(id),
      name: Value(name),
      basePackId: Value(basePackId),
      overridesJson: Value(overridesJson),
      typographyScale: Value(typographyScale),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomTheme.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomTheme(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      basePackId: serializer.fromJson<String>(json['basePackId']),
      overridesJson: serializer.fromJson<String>(json['overridesJson']),
      typographyScale: serializer.fromJson<String>(json['typographyScale']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'basePackId': serializer.toJson<String>(basePackId),
      'overridesJson': serializer.toJson<String>(overridesJson),
      'typographyScale': serializer.toJson<String>(typographyScale),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomTheme copyWith({
    String? id,
    String? name,
    String? basePackId,
    String? overridesJson,
    String? typographyScale,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CustomTheme(
    id: id ?? this.id,
    name: name ?? this.name,
    basePackId: basePackId ?? this.basePackId,
    overridesJson: overridesJson ?? this.overridesJson,
    typographyScale: typographyScale ?? this.typographyScale,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomTheme copyWithCompanion(CustomThemesCompanion data) {
    return CustomTheme(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      basePackId: data.basePackId.present ? data.basePackId.value : this.basePackId,
      overridesJson: data.overridesJson.present ? data.overridesJson.value : this.overridesJson,
      typographyScale: data.typographyScale.present
          ? data.typographyScale.value
          : this.typographyScale,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomTheme(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('basePackId: $basePackId, ')
          ..write('overridesJson: $overridesJson, ')
          ..write('typographyScale: $typographyScale, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, basePackId, overridesJson, typographyScale, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomTheme &&
          other.id == this.id &&
          other.name == this.name &&
          other.basePackId == this.basePackId &&
          other.overridesJson == this.overridesJson &&
          other.typographyScale == this.typographyScale &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomThemesCompanion extends UpdateCompanion<CustomTheme> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> basePackId;
  final Value<String> overridesJson;
  final Value<String> typographyScale;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomThemesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.basePackId = const Value.absent(),
    this.overridesJson = const Value.absent(),
    this.typographyScale = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomThemesCompanion.insert({
    required String id,
    required String name,
    required String basePackId,
    required String overridesJson,
    this.typographyScale = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       basePackId = Value(basePackId),
       overridesJson = Value(overridesJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomTheme> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? basePackId,
    Expression<String>? overridesJson,
    Expression<String>? typographyScale,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (basePackId != null) 'base_pack_id': basePackId,
      if (overridesJson != null) 'overrides_json': overridesJson,
      if (typographyScale != null) 'typography_scale': typographyScale,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomThemesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? basePackId,
    Value<String>? overridesJson,
    Value<String>? typographyScale,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CustomThemesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      basePackId: basePackId ?? this.basePackId,
      overridesJson: overridesJson ?? this.overridesJson,
      typographyScale: typographyScale ?? this.typographyScale,
      createdAt: createdAt ?? this.createdAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (basePackId.present) {
      map['base_pack_id'] = Variable<String>(basePackId.value);
    }
    if (overridesJson.present) {
      map['overrides_json'] = Variable<String>(overridesJson.value);
    }
    if (typographyScale.present) {
      map['typography_scale'] = Variable<String>(typographyScale.value);
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
    return (StringBuffer('CustomThemesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('basePackId: $basePackId, ')
          ..write('overridesJson: $overridesJson, ')
          ..write('typographyScale: $typographyScale, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimationPreferencesTableTable extends AnimationPreferencesTable
    with TableInfo<$AnimationPreferencesTableTable, AnimationPreferencesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimationPreferencesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animation_preferences_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnimationPreferencesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AnimationPreferencesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimationPreferencesTableData(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
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
  $AnimationPreferencesTableTable createAlias(String alias) {
    return $AnimationPreferencesTableTable(attachedDatabase, alias);
  }
}

class AnimationPreferencesTableData extends DataClass
    implements Insertable<AnimationPreferencesTableData> {
  /// Setting key (e.g., 'mode', 'speedMultiplier').
  final String key;

  /// Setting value (serialized as string).
  final String value;

  /// When this setting was last updated.
  final DateTime updatedAt;
  const AnimationPreferencesTableData({
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

  AnimationPreferencesTableCompanion toCompanion(bool nullToAbsent) {
    return AnimationPreferencesTableCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AnimationPreferencesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimationPreferencesTableData(
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

  AnimationPreferencesTableData copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AnimationPreferencesTableData(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AnimationPreferencesTableData copyWithCompanion(AnimationPreferencesTableCompanion data) {
    return AnimationPreferencesTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimationPreferencesTableData(')
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
      (other is AnimationPreferencesTableData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AnimationPreferencesTableCompanion extends UpdateCompanion<AnimationPreferencesTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AnimationPreferencesTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimationPreferencesTableCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AnimationPreferencesTableData> custom({
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

  AnimationPreferencesTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AnimationPreferencesTableCompanion(
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
    return (StringBuffer('AnimationPreferencesTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorDidMeta = const VerificationMeta('actorDid');
  @override
  late final GeneratedColumn<String> actorDid = GeneratedColumn<String>(
    'actor_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES profiles (did)'),
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
  static const VerificationMeta _reasonSubjectUriMeta = const VerificationMeta('reasonSubjectUri');
  @override
  late final GeneratedColumn<String> reasonSubjectUri = GeneratedColumn<String>(
    'reason_subject_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordJsonMeta = const VerificationMeta('recordJson');
  @override
  late final GeneratedColumn<String> recordJson = GeneratedColumn<String>(
    'record_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indexedAtMeta = const VerificationMeta('indexedAt');
  @override
  late final GeneratedColumn<DateTime> indexedAt = GeneratedColumn<DateTime>(
    'indexed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _seenAtMeta = const VerificationMeta('seenAt');
  @override
  late final GeneratedColumn<DateTime> seenAt = GeneratedColumn<DateTime>(
    'seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uri,
    ownerDid,
    actorDid,
    type,
    reasonSubjectUri,
    recordJson,
    indexedAt,
    isRead,
    seenAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uri')) {
      context.handle(_uriMeta, uri.isAcceptableOrUnknown(data['uri']!, _uriMeta));
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('actor_did')) {
      context.handle(
        _actorDidMeta,
        actorDid.isAcceptableOrUnknown(data['actor_did']!, _actorDidMeta),
      );
    } else if (isInserting) {
      context.missing(_actorDidMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('reason_subject_uri')) {
      context.handle(
        _reasonSubjectUriMeta,
        reasonSubjectUri.isAcceptableOrUnknown(data['reason_subject_uri']!, _reasonSubjectUriMeta),
      );
    }
    if (data.containsKey('record_json')) {
      context.handle(
        _recordJsonMeta,
        recordJson.isAcceptableOrUnknown(data['record_json']!, _recordJsonMeta),
      );
    }
    if (data.containsKey('indexed_at')) {
      context.handle(
        _indexedAtMeta,
        indexedAt.isAcceptableOrUnknown(data['indexed_at']!, _indexedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_indexedAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta, isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('seen_at')) {
      context.handle(_seenAtMeta, seenAt.isAcceptableOrUnknown(data['seen_at']!, _seenAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uri, ownerDid};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      uri: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uri'])!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      actorDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_did'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      reasonSubjectUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_subject_uri'],
      ),
      recordJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_json'],
      ),
      indexedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}indexed_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      seenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}seen_at'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  /// Notification AT URI (primary key).
  final String uri;

  /// The DID of the user receiving the notification.
  final String ownerDid;

  /// DID of the user who triggered the notification.
  final String actorDid;

  /// Notification type (like, repost, follow, mention, reply, quote, starterpack-joined).
  final String type;

  /// URI of the subject (post/profile) this notification is about.
  final String? reasonSubjectUri;

  /// Associated record JSON (for displaying notification context).
  final String? recordJson;

  /// When the notification was indexed on the server.
  final DateTime indexedAt;

  /// Whether the notification has been read.
  final bool isRead;

  /// When the notification was marked as seen (null if not seen yet).
  final DateTime? seenAt;

  /// When this notification was cached locally.
  final DateTime cachedAt;
  const Notification({
    required this.uri,
    required this.ownerDid,
    required this.actorDid,
    required this.type,
    this.reasonSubjectUri,
    this.recordJson,
    required this.indexedAt,
    required this.isRead,
    this.seenAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uri'] = Variable<String>(uri);
    map['owner_did'] = Variable<String>(ownerDid);
    map['actor_did'] = Variable<String>(actorDid);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || reasonSubjectUri != null) {
      map['reason_subject_uri'] = Variable<String>(reasonSubjectUri);
    }
    if (!nullToAbsent || recordJson != null) {
      map['record_json'] = Variable<String>(recordJson);
    }
    map['indexed_at'] = Variable<DateTime>(indexedAt);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || seenAt != null) {
      map['seen_at'] = Variable<DateTime>(seenAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      uri: Value(uri),
      ownerDid: Value(ownerDid),
      actorDid: Value(actorDid),
      type: Value(type),
      reasonSubjectUri: reasonSubjectUri == null && nullToAbsent
          ? const Value.absent()
          : Value(reasonSubjectUri),
      recordJson: recordJson == null && nullToAbsent ? const Value.absent() : Value(recordJson),
      indexedAt: Value(indexedAt),
      isRead: Value(isRead),
      seenAt: seenAt == null && nullToAbsent ? const Value.absent() : Value(seenAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      uri: serializer.fromJson<String>(json['uri']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      actorDid: serializer.fromJson<String>(json['actorDid']),
      type: serializer.fromJson<String>(json['type']),
      reasonSubjectUri: serializer.fromJson<String?>(json['reasonSubjectUri']),
      recordJson: serializer.fromJson<String?>(json['recordJson']),
      indexedAt: serializer.fromJson<DateTime>(json['indexedAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      seenAt: serializer.fromJson<DateTime?>(json['seenAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uri': serializer.toJson<String>(uri),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'actorDid': serializer.toJson<String>(actorDid),
      'type': serializer.toJson<String>(type),
      'reasonSubjectUri': serializer.toJson<String?>(reasonSubjectUri),
      'recordJson': serializer.toJson<String?>(recordJson),
      'indexedAt': serializer.toJson<DateTime>(indexedAt),
      'isRead': serializer.toJson<bool>(isRead),
      'seenAt': serializer.toJson<DateTime?>(seenAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  Notification copyWith({
    String? uri,
    String? ownerDid,
    String? actorDid,
    String? type,
    Value<String?> reasonSubjectUri = const Value.absent(),
    Value<String?> recordJson = const Value.absent(),
    DateTime? indexedAt,
    bool? isRead,
    Value<DateTime?> seenAt = const Value.absent(),
    DateTime? cachedAt,
  }) => Notification(
    uri: uri ?? this.uri,
    ownerDid: ownerDid ?? this.ownerDid,
    actorDid: actorDid ?? this.actorDid,
    type: type ?? this.type,
    reasonSubjectUri: reasonSubjectUri.present ? reasonSubjectUri.value : this.reasonSubjectUri,
    recordJson: recordJson.present ? recordJson.value : this.recordJson,
    indexedAt: indexedAt ?? this.indexedAt,
    isRead: isRead ?? this.isRead,
    seenAt: seenAt.present ? seenAt.value : this.seenAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      uri: data.uri.present ? data.uri.value : this.uri,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      actorDid: data.actorDid.present ? data.actorDid.value : this.actorDid,
      type: data.type.present ? data.type.value : this.type,
      reasonSubjectUri: data.reasonSubjectUri.present
          ? data.reasonSubjectUri.value
          : this.reasonSubjectUri,
      recordJson: data.recordJson.present ? data.recordJson.value : this.recordJson,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      seenAt: data.seenAt.present ? data.seenAt.value : this.seenAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('uri: $uri, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('actorDid: $actorDid, ')
          ..write('type: $type, ')
          ..write('reasonSubjectUri: $reasonSubjectUri, ')
          ..write('recordJson: $recordJson, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('isRead: $isRead, ')
          ..write('seenAt: $seenAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uri,
    ownerDid,
    actorDid,
    type,
    reasonSubjectUri,
    recordJson,
    indexedAt,
    isRead,
    seenAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.uri == this.uri &&
          other.ownerDid == this.ownerDid &&
          other.actorDid == this.actorDid &&
          other.type == this.type &&
          other.reasonSubjectUri == this.reasonSubjectUri &&
          other.recordJson == this.recordJson &&
          other.indexedAt == this.indexedAt &&
          other.isRead == this.isRead &&
          other.seenAt == this.seenAt &&
          other.cachedAt == this.cachedAt);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<String> uri;
  final Value<String> ownerDid;
  final Value<String> actorDid;
  final Value<String> type;
  final Value<String?> reasonSubjectUri;
  final Value<String?> recordJson;
  final Value<DateTime> indexedAt;
  final Value<bool> isRead;
  final Value<DateTime?> seenAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.uri = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.actorDid = const Value.absent(),
    this.type = const Value.absent(),
    this.reasonSubjectUri = const Value.absent(),
    this.recordJson = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.seenAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    required String uri,
    required String ownerDid,
    required String actorDid,
    required String type,
    this.reasonSubjectUri = const Value.absent(),
    this.recordJson = const Value.absent(),
    required DateTime indexedAt,
    this.isRead = const Value.absent(),
    this.seenAt = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : uri = Value(uri),
       ownerDid = Value(ownerDid),
       actorDid = Value(actorDid),
       type = Value(type),
       indexedAt = Value(indexedAt),
       cachedAt = Value(cachedAt);
  static Insertable<Notification> custom({
    Expression<String>? uri,
    Expression<String>? ownerDid,
    Expression<String>? actorDid,
    Expression<String>? type,
    Expression<String>? reasonSubjectUri,
    Expression<String>? recordJson,
    Expression<DateTime>? indexedAt,
    Expression<bool>? isRead,
    Expression<DateTime>? seenAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uri != null) 'uri': uri,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (actorDid != null) 'actor_did': actorDid,
      if (type != null) 'type': type,
      if (reasonSubjectUri != null) 'reason_subject_uri': reasonSubjectUri,
      if (recordJson != null) 'record_json': recordJson,
      if (indexedAt != null) 'indexed_at': indexedAt,
      if (isRead != null) 'is_read': isRead,
      if (seenAt != null) 'seen_at': seenAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith({
    Value<String>? uri,
    Value<String>? ownerDid,
    Value<String>? actorDid,
    Value<String>? type,
    Value<String?>? reasonSubjectUri,
    Value<String?>? recordJson,
    Value<DateTime>? indexedAt,
    Value<bool>? isRead,
    Value<DateTime?>? seenAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return NotificationsCompanion(
      uri: uri ?? this.uri,
      ownerDid: ownerDid ?? this.ownerDid,
      actorDid: actorDid ?? this.actorDid,
      type: type ?? this.type,
      reasonSubjectUri: reasonSubjectUri ?? this.reasonSubjectUri,
      recordJson: recordJson ?? this.recordJson,
      indexedAt: indexedAt ?? this.indexedAt,
      isRead: isRead ?? this.isRead,
      seenAt: seenAt ?? this.seenAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (actorDid.present) {
      map['actor_did'] = Variable<String>(actorDid.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (reasonSubjectUri.present) {
      map['reason_subject_uri'] = Variable<String>(reasonSubjectUri.value);
    }
    if (recordJson.present) {
      map['record_json'] = Variable<String>(recordJson.value);
    }
    if (indexedAt.present) {
      map['indexed_at'] = Variable<DateTime>(indexedAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (seenAt.present) {
      map['seen_at'] = Variable<DateTime>(seenAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('uri: $uri, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('actorDid: $actorDid, ')
          ..write('type: $type, ')
          ..write('reasonSubjectUri: $reasonSubjectUri, ')
          ..write('recordJson: $recordJson, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('isRead: $isRead, ')
          ..write('seenAt: $seenAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationCursorsTable extends NotificationCursors
    with TableInfo<$NotificationCursorsTable, NotificationCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedKeyMeta = const VerificationMeta('feedKey');
  @override
  late final GeneratedColumn<String> feedKey = GeneratedColumn<String>(
    'feed_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [feedKey, ownerDid, cursor, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_key')) {
      context.handle(_feedKeyMeta, feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta));
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta, cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(data['last_updated']!, _lastUpdatedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedKey, ownerDid};
  @override
  NotificationCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationCursor(
      feedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_key'],
      )!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      ),
    );
  }

  @override
  $NotificationCursorsTable createAlias(String alias) {
    return $NotificationCursorsTable(attachedDatabase, alias);
  }
}

class NotificationCursor extends DataClass implements Insertable<NotificationCursor> {
  /// Feed key identifier (e.g., 'notifications').
  final String feedKey;

  /// The DID of the user this cursor belongs to.
  final String ownerDid;

  /// Pagination cursor from API.
  final String cursor;

  /// When the cursor was last updated.
  final DateTime? lastUpdated;
  const NotificationCursor({
    required this.feedKey,
    required this.ownerDid,
    required this.cursor,
    this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_key'] = Variable<String>(feedKey);
    map['owner_did'] = Variable<String>(ownerDid);
    map['cursor'] = Variable<String>(cursor);
    if (!nullToAbsent || lastUpdated != null) {
      map['last_updated'] = Variable<DateTime>(lastUpdated);
    }
    return map;
  }

  NotificationCursorsCompanion toCompanion(bool nullToAbsent) {
    return NotificationCursorsCompanion(
      feedKey: Value(feedKey),
      ownerDid: Value(ownerDid),
      cursor: Value(cursor),
      lastUpdated: lastUpdated == null && nullToAbsent ? const Value.absent() : Value(lastUpdated),
    );
  }

  factory NotificationCursor.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationCursor(
      feedKey: serializer.fromJson<String>(json['feedKey']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      cursor: serializer.fromJson<String>(json['cursor']),
      lastUpdated: serializer.fromJson<DateTime?>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedKey': serializer.toJson<String>(feedKey),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'cursor': serializer.toJson<String>(cursor),
      'lastUpdated': serializer.toJson<DateTime?>(lastUpdated),
    };
  }

  NotificationCursor copyWith({
    String? feedKey,
    String? ownerDid,
    String? cursor,
    Value<DateTime?> lastUpdated = const Value.absent(),
  }) => NotificationCursor(
    feedKey: feedKey ?? this.feedKey,
    ownerDid: ownerDid ?? this.ownerDid,
    cursor: cursor ?? this.cursor,
    lastUpdated: lastUpdated.present ? lastUpdated.value : this.lastUpdated,
  );
  NotificationCursor copyWithCompanion(NotificationCursorsCompanion data) {
    return NotificationCursor(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastUpdated: data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationCursor(')
          ..write('feedKey: $feedKey, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('cursor: $cursor, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feedKey, ownerDid, cursor, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationCursor &&
          other.feedKey == this.feedKey &&
          other.ownerDid == this.ownerDid &&
          other.cursor == this.cursor &&
          other.lastUpdated == this.lastUpdated);
}

class NotificationCursorsCompanion extends UpdateCompanion<NotificationCursor> {
  final Value<String> feedKey;
  final Value<String> ownerDid;
  final Value<String> cursor;
  final Value<DateTime?> lastUpdated;
  final Value<int> rowid;
  const NotificationCursorsCompanion({
    this.feedKey = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationCursorsCompanion.insert({
    required String feedKey,
    required String ownerDid,
    required String cursor,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey),
       ownerDid = Value(ownerDid),
       cursor = Value(cursor);
  static Insertable<NotificationCursor> custom({
    Expression<String>? feedKey,
    Expression<String>? ownerDid,
    Expression<String>? cursor,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedKey != null) 'feed_key': feedKey,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (cursor != null) 'cursor': cursor,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationCursorsCompanion copyWith({
    Value<String>? feedKey,
    Value<String>? ownerDid,
    Value<String>? cursor,
    Value<DateTime?>? lastUpdated,
    Value<int>? rowid,
  }) {
    return NotificationCursorsCompanion(
      feedKey: feedKey ?? this.feedKey,
      ownerDid: ownerDid ?? this.ownerDid,
      cursor: cursor ?? this.cursor,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedKey.present) {
      map['feed_key'] = Variable<String>(feedKey.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationCursorsCompanion(')
          ..write('feedKey: $feedKey, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('cursor: $cursor, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsSyncQueueTable extends NotificationsSyncQueue
    with TableInfo<$NotificationsSyncQueueTable, NotificationsSyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsSyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
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
  static const VerificationMeta _seenAtMeta = const VerificationMeta('seenAt');
  @override
  late final GeneratedColumn<String> seenAt = GeneratedColumn<String>(
    'seen_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, ownerDid, type, seenAt, createdAt, retryCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications_sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationsSyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('seen_at')) {
      context.handle(_seenAtMeta, seenAt.isAcceptableOrUnknown(data['seen_at']!, _seenAtMeta));
    } else if (isInserting) {
      context.missing(_seenAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationsSyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationsSyncQueueData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      seenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seen_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $NotificationsSyncQueueTable createAlias(String alias) {
    return $NotificationsSyncQueueTable(attachedDatabase, alias);
  }
}

class NotificationsSyncQueueData extends DataClass
    implements Insertable<NotificationsSyncQueueData> {
  final int id;

  /// The DID of the user who owns this action.
  final String ownerDid;

  /// Type of operation: 'mark_seen'.
  final String type;

  /// The timestamp to mark as seen (ISO8601 string).
  final String seenAt;

  /// When the item was queued.
  final DateTime createdAt;

  /// Number of times we've tried to process this item.
  final int retryCount;
  const NotificationsSyncQueueData({
    required this.id,
    required this.ownerDid,
    required this.type,
    required this.seenAt,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['owner_did'] = Variable<String>(ownerDid);
    map['type'] = Variable<String>(type);
    map['seen_at'] = Variable<String>(seenAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  NotificationsSyncQueueCompanion toCompanion(bool nullToAbsent) {
    return NotificationsSyncQueueCompanion(
      id: Value(id),
      ownerDid: Value(ownerDid),
      type: Value(type),
      seenAt: Value(seenAt),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory NotificationsSyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationsSyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      type: serializer.fromJson<String>(json['type']),
      seenAt: serializer.fromJson<String>(json['seenAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'type': serializer.toJson<String>(type),
      'seenAt': serializer.toJson<String>(seenAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  NotificationsSyncQueueData copyWith({
    int? id,
    String? ownerDid,
    String? type,
    String? seenAt,
    DateTime? createdAt,
    int? retryCount,
  }) => NotificationsSyncQueueData(
    id: id ?? this.id,
    ownerDid: ownerDid ?? this.ownerDid,
    type: type ?? this.type,
    seenAt: seenAt ?? this.seenAt,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  NotificationsSyncQueueData copyWithCompanion(NotificationsSyncQueueCompanion data) {
    return NotificationsSyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      type: data.type.present ? data.type.value : this.type,
      seenAt: data.seenAt.present ? data.seenAt.value : this.seenAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsSyncQueueData(')
          ..write('id: $id, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('type: $type, ')
          ..write('seenAt: $seenAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerDid, type, seenAt, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationsSyncQueueData &&
          other.id == this.id &&
          other.ownerDid == this.ownerDid &&
          other.type == this.type &&
          other.seenAt == this.seenAt &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class NotificationsSyncQueueCompanion extends UpdateCompanion<NotificationsSyncQueueData> {
  final Value<int> id;
  final Value<String> ownerDid;
  final Value<String> type;
  final Value<String> seenAt;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const NotificationsSyncQueueCompanion({
    this.id = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.type = const Value.absent(),
    this.seenAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  NotificationsSyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String ownerDid,
    required String type,
    required String seenAt,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
  }) : ownerDid = Value(ownerDid),
       type = Value(type),
       seenAt = Value(seenAt),
       createdAt = Value(createdAt);
  static Insertable<NotificationsSyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? ownerDid,
    Expression<String>? type,
    Expression<String>? seenAt,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (type != null) 'type': type,
      if (seenAt != null) 'seen_at': seenAt,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  NotificationsSyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? ownerDid,
    Value<String>? type,
    Value<String>? seenAt,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
  }) {
    return NotificationsSyncQueueCompanion(
      id: id ?? this.id,
      ownerDid: ownerDid ?? this.ownerDid,
      type: type ?? this.type,
      seenAt: seenAt ?? this.seenAt,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (seenAt.present) {
      map['seen_at'] = Variable<String>(seenAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsSyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('type: $type, ')
          ..write('seenAt: $seenAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

class $DmConvosTable extends DmConvos with TableInfo<$DmConvosTable, DmConvo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DmConvosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _convoIdMeta = const VerificationMeta('convoId');
  @override
  late final GeneratedColumn<String> convoId = GeneratedColumn<String>(
    'convo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _membersJsonMeta = const VerificationMeta('membersJson');
  @override
  late final GeneratedColumn<String> membersJson = GeneratedColumn<String>(
    'members_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessageTextMeta = const VerificationMeta('lastMessageText');
  @override
  late final GeneratedColumn<String> lastMessageText = GeneratedColumn<String>(
    'last_message_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta('lastMessageAt');
  @override
  late final GeneratedColumn<DateTime> lastMessageAt = GeneratedColumn<DateTime>(
    'last_message_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReadMessageIdMeta = const VerificationMeta(
    'lastReadMessageId',
  );
  @override
  late final GeneratedColumn<String> lastReadMessageId = GeneratedColumn<String>(
    'last_read_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isMutedMeta = const VerificationMeta('isMuted');
  @override
  late final GeneratedColumn<bool> isMuted = GeneratedColumn<bool>(
    'is_muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_muted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAcceptedMeta = const VerificationMeta('isAccepted');
  @override
  late final GeneratedColumn<bool> isAccepted = GeneratedColumn<bool>(
    'is_accepted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_accepted" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    convoId,
    ownerDid,
    membersJson,
    lastMessageText,
    lastMessageAt,
    lastReadMessageId,
    unreadCount,
    isMuted,
    isAccepted,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dm_convos';
  @override
  VerificationContext validateIntegrity(Insertable<DmConvo> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('convo_id')) {
      context.handle(_convoIdMeta, convoId.isAcceptableOrUnknown(data['convo_id']!, _convoIdMeta));
    } else if (isInserting) {
      context.missing(_convoIdMeta);
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('members_json')) {
      context.handle(
        _membersJsonMeta,
        membersJson.isAcceptableOrUnknown(data['members_json']!, _membersJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_membersJsonMeta);
    }
    if (data.containsKey('last_message_text')) {
      context.handle(
        _lastMessageTextMeta,
        lastMessageText.isAcceptableOrUnknown(data['last_message_text']!, _lastMessageTextMeta),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(data['last_message_at']!, _lastMessageAtMeta),
      );
    }
    if (data.containsKey('last_read_message_id')) {
      context.handle(
        _lastReadMessageIdMeta,
        lastReadMessageId.isAcceptableOrUnknown(
          data['last_read_message_id']!,
          _lastReadMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(data['unread_count']!, _unreadCountMeta),
      );
    }
    if (data.containsKey('is_muted')) {
      context.handle(_isMutedMeta, isMuted.isAcceptableOrUnknown(data['is_muted']!, _isMutedMeta));
    }
    if (data.containsKey('is_accepted')) {
      context.handle(
        _isAcceptedMeta,
        isAccepted.isAcceptableOrUnknown(data['is_accepted']!, _isAcceptedMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {convoId, ownerDid};
  @override
  DmConvo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DmConvo(
      convoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}convo_id'],
      )!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      membersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}members_json'],
      )!,
      lastMessageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_text'],
      ),
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      ),
      lastReadMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_read_message_id'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      isMuted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_muted'],
      )!,
      isAccepted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_accepted'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $DmConvosTable createAlias(String alias) {
    return $DmConvosTable(attachedDatabase, alias);
  }
}

class DmConvo extends DataClass implements Insertable<DmConvo> {
  /// Conversation ID (unique identifier from API).
  final String convoId;

  /// The DID of the user who owns this conversation view.
  final String ownerDid;

  /// JSON array of participant DIDs.
  final String membersJson;

  /// Preview text from the last message.
  final String? lastMessageText;

  /// Timestamp of the last message.
  final DateTime? lastMessageAt;

  /// ID of the last message the user has read.
  final String? lastReadMessageId;

  /// Number of unread messages.
  final int unreadCount;

  /// Whether the conversation is muted.
  final bool isMuted;

  /// Whether the conversation request has been accepted.
  final bool isAccepted;

  /// When this conversation was cached locally.
  final DateTime cachedAt;
  const DmConvo({
    required this.convoId,
    required this.ownerDid,
    required this.membersJson,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastReadMessageId,
    required this.unreadCount,
    required this.isMuted,
    required this.isAccepted,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['convo_id'] = Variable<String>(convoId);
    map['owner_did'] = Variable<String>(ownerDid);
    map['members_json'] = Variable<String>(membersJson);
    if (!nullToAbsent || lastMessageText != null) {
      map['last_message_text'] = Variable<String>(lastMessageText);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    if (!nullToAbsent || lastReadMessageId != null) {
      map['last_read_message_id'] = Variable<String>(lastReadMessageId);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['is_muted'] = Variable<bool>(isMuted);
    map['is_accepted'] = Variable<bool>(isAccepted);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  DmConvosCompanion toCompanion(bool nullToAbsent) {
    return DmConvosCompanion(
      convoId: Value(convoId),
      ownerDid: Value(ownerDid),
      membersJson: Value(membersJson),
      lastMessageText: lastMessageText == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageText),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      lastReadMessageId: lastReadMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadMessageId),
      unreadCount: Value(unreadCount),
      isMuted: Value(isMuted),
      isAccepted: Value(isAccepted),
      cachedAt: Value(cachedAt),
    );
  }

  factory DmConvo.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DmConvo(
      convoId: serializer.fromJson<String>(json['convoId']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      membersJson: serializer.fromJson<String>(json['membersJson']),
      lastMessageText: serializer.fromJson<String?>(json['lastMessageText']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
      lastReadMessageId: serializer.fromJson<String?>(json['lastReadMessageId']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      isMuted: serializer.fromJson<bool>(json['isMuted']),
      isAccepted: serializer.fromJson<bool>(json['isAccepted']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'convoId': serializer.toJson<String>(convoId),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'membersJson': serializer.toJson<String>(membersJson),
      'lastMessageText': serializer.toJson<String?>(lastMessageText),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
      'lastReadMessageId': serializer.toJson<String?>(lastReadMessageId),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'isMuted': serializer.toJson<bool>(isMuted),
      'isAccepted': serializer.toJson<bool>(isAccepted),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  DmConvo copyWith({
    String? convoId,
    String? ownerDid,
    String? membersJson,
    Value<String?> lastMessageText = const Value.absent(),
    Value<DateTime?> lastMessageAt = const Value.absent(),
    Value<String?> lastReadMessageId = const Value.absent(),
    int? unreadCount,
    bool? isMuted,
    bool? isAccepted,
    DateTime? cachedAt,
  }) => DmConvo(
    convoId: convoId ?? this.convoId,
    ownerDid: ownerDid ?? this.ownerDid,
    membersJson: membersJson ?? this.membersJson,
    lastMessageText: lastMessageText.present ? lastMessageText.value : this.lastMessageText,
    lastMessageAt: lastMessageAt.present ? lastMessageAt.value : this.lastMessageAt,
    lastReadMessageId: lastReadMessageId.present
        ? lastReadMessageId.value
        : this.lastReadMessageId,
    unreadCount: unreadCount ?? this.unreadCount,
    isMuted: isMuted ?? this.isMuted,
    isAccepted: isAccepted ?? this.isAccepted,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  DmConvo copyWithCompanion(DmConvosCompanion data) {
    return DmConvo(
      convoId: data.convoId.present ? data.convoId.value : this.convoId,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      membersJson: data.membersJson.present ? data.membersJson.value : this.membersJson,
      lastMessageText: data.lastMessageText.present
          ? data.lastMessageText.value
          : this.lastMessageText,
      lastMessageAt: data.lastMessageAt.present ? data.lastMessageAt.value : this.lastMessageAt,
      lastReadMessageId: data.lastReadMessageId.present
          ? data.lastReadMessageId.value
          : this.lastReadMessageId,
      unreadCount: data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      isMuted: data.isMuted.present ? data.isMuted.value : this.isMuted,
      isAccepted: data.isAccepted.present ? data.isAccepted.value : this.isAccepted,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DmConvo(')
          ..write('convoId: $convoId, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('membersJson: $membersJson, ')
          ..write('lastMessageText: $lastMessageText, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('lastReadMessageId: $lastReadMessageId, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('isMuted: $isMuted, ')
          ..write('isAccepted: $isAccepted, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    convoId,
    ownerDid,
    membersJson,
    lastMessageText,
    lastMessageAt,
    lastReadMessageId,
    unreadCount,
    isMuted,
    isAccepted,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DmConvo &&
          other.convoId == this.convoId &&
          other.ownerDid == this.ownerDid &&
          other.membersJson == this.membersJson &&
          other.lastMessageText == this.lastMessageText &&
          other.lastMessageAt == this.lastMessageAt &&
          other.lastReadMessageId == this.lastReadMessageId &&
          other.unreadCount == this.unreadCount &&
          other.isMuted == this.isMuted &&
          other.isAccepted == this.isAccepted &&
          other.cachedAt == this.cachedAt);
}

class DmConvosCompanion extends UpdateCompanion<DmConvo> {
  final Value<String> convoId;
  final Value<String> ownerDid;
  final Value<String> membersJson;
  final Value<String?> lastMessageText;
  final Value<DateTime?> lastMessageAt;
  final Value<String?> lastReadMessageId;
  final Value<int> unreadCount;
  final Value<bool> isMuted;
  final Value<bool> isAccepted;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const DmConvosCompanion({
    this.convoId = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.membersJson = const Value.absent(),
    this.lastMessageText = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.lastReadMessageId = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.isAccepted = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DmConvosCompanion.insert({
    required String convoId,
    required String ownerDid,
    required String membersJson,
    this.lastMessageText = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.lastReadMessageId = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.isAccepted = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : convoId = Value(convoId),
       ownerDid = Value(ownerDid),
       membersJson = Value(membersJson),
       cachedAt = Value(cachedAt);
  static Insertable<DmConvo> custom({
    Expression<String>? convoId,
    Expression<String>? ownerDid,
    Expression<String>? membersJson,
    Expression<String>? lastMessageText,
    Expression<DateTime>? lastMessageAt,
    Expression<String>? lastReadMessageId,
    Expression<int>? unreadCount,
    Expression<bool>? isMuted,
    Expression<bool>? isAccepted,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (convoId != null) 'convo_id': convoId,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (membersJson != null) 'members_json': membersJson,
      if (lastMessageText != null) 'last_message_text': lastMessageText,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (lastReadMessageId != null) 'last_read_message_id': lastReadMessageId,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (isMuted != null) 'is_muted': isMuted,
      if (isAccepted != null) 'is_accepted': isAccepted,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DmConvosCompanion copyWith({
    Value<String>? convoId,
    Value<String>? ownerDid,
    Value<String>? membersJson,
    Value<String?>? lastMessageText,
    Value<DateTime?>? lastMessageAt,
    Value<String?>? lastReadMessageId,
    Value<int>? unreadCount,
    Value<bool>? isMuted,
    Value<bool>? isAccepted,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return DmConvosCompanion(
      convoId: convoId ?? this.convoId,
      ownerDid: ownerDid ?? this.ownerDid,
      membersJson: membersJson ?? this.membersJson,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isAccepted: isAccepted ?? this.isAccepted,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (convoId.present) {
      map['convo_id'] = Variable<String>(convoId.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (membersJson.present) {
      map['members_json'] = Variable<String>(membersJson.value);
    }
    if (lastMessageText.present) {
      map['last_message_text'] = Variable<String>(lastMessageText.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (lastReadMessageId.present) {
      map['last_read_message_id'] = Variable<String>(lastReadMessageId.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (isMuted.present) {
      map['is_muted'] = Variable<bool>(isMuted.value);
    }
    if (isAccepted.present) {
      map['is_accepted'] = Variable<bool>(isAccepted.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DmConvosCompanion(')
          ..write('convoId: $convoId, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('membersJson: $membersJson, ')
          ..write('lastMessageText: $lastMessageText, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('lastReadMessageId: $lastReadMessageId, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('isMuted: $isMuted, ')
          ..write('isAccepted: $isAccepted, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DmMessagesTable extends DmMessages with TableInfo<$DmMessagesTable, DmMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DmMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _convoIdMeta = const VerificationMeta('convoId');
  @override
  late final GeneratedColumn<String> convoId = GeneratedColumn<String>(
    'convo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderDidMeta = const VerificationMeta('senderDid');
  @override
  late final GeneratedColumn<String> senderDid = GeneratedColumn<String>(
    'sender_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES profiles (did)'),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    ownerDid,
    convoId,
    senderDid,
    content,
    sentAt,
    status,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dm_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<DmMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('convo_id')) {
      context.handle(_convoIdMeta, convoId.isAcceptableOrUnknown(data['convo_id']!, _convoIdMeta));
    } else if (isInserting) {
      context.missing(_convoIdMeta);
    }
    if (data.containsKey('sender_did')) {
      context.handle(
        _senderDidMeta,
        senderDid.isAcceptableOrUnknown(data['sender_did']!, _senderDidMeta),
      );
    } else if (isInserting) {
      context.missing(_senderDidMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta, content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta, sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId, ownerDid};
  @override
  DmMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DmMessage(
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      convoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}convo_id'],
      )!,
      senderDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_did'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $DmMessagesTable createAlias(String alias) {
    return $DmMessagesTable(attachedDatabase, alias);
  }
}

class DmMessage extends DataClass implements Insertable<DmMessage> {
  /// Message ID (unique identifier from API).
  final String messageId;

  /// The DID of the user who owns this message view.
  final String ownerDid;

  /// Conversation this message belongs to.
  final String convoId;

  /// DID of the message sender.
  final String senderDid;

  /// Message text content.
  final String content;

  /// When the message was sent.
  final DateTime sentAt;

  /// Message status: sent, read, deleted.
  final String status;

  /// When this message was cached locally.
  final DateTime cachedAt;
  const DmMessage({
    required this.messageId,
    required this.ownerDid,
    required this.convoId,
    required this.senderDid,
    required this.content,
    required this.sentAt,
    required this.status,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['owner_did'] = Variable<String>(ownerDid);
    map['convo_id'] = Variable<String>(convoId);
    map['sender_did'] = Variable<String>(senderDid);
    map['content'] = Variable<String>(content);
    map['sent_at'] = Variable<DateTime>(sentAt);
    map['status'] = Variable<String>(status);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  DmMessagesCompanion toCompanion(bool nullToAbsent) {
    return DmMessagesCompanion(
      messageId: Value(messageId),
      ownerDid: Value(ownerDid),
      convoId: Value(convoId),
      senderDid: Value(senderDid),
      content: Value(content),
      sentAt: Value(sentAt),
      status: Value(status),
      cachedAt: Value(cachedAt),
    );
  }

  factory DmMessage.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DmMessage(
      messageId: serializer.fromJson<String>(json['messageId']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      convoId: serializer.fromJson<String>(json['convoId']),
      senderDid: serializer.fromJson<String>(json['senderDid']),
      content: serializer.fromJson<String>(json['content']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
      status: serializer.fromJson<String>(json['status']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'convoId': serializer.toJson<String>(convoId),
      'senderDid': serializer.toJson<String>(senderDid),
      'content': serializer.toJson<String>(content),
      'sentAt': serializer.toJson<DateTime>(sentAt),
      'status': serializer.toJson<String>(status),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  DmMessage copyWith({
    String? messageId,
    String? ownerDid,
    String? convoId,
    String? senderDid,
    String? content,
    DateTime? sentAt,
    String? status,
    DateTime? cachedAt,
  }) => DmMessage(
    messageId: messageId ?? this.messageId,
    ownerDid: ownerDid ?? this.ownerDid,
    convoId: convoId ?? this.convoId,
    senderDid: senderDid ?? this.senderDid,
    content: content ?? this.content,
    sentAt: sentAt ?? this.sentAt,
    status: status ?? this.status,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  DmMessage copyWithCompanion(DmMessagesCompanion data) {
    return DmMessage(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      convoId: data.convoId.present ? data.convoId.value : this.convoId,
      senderDid: data.senderDid.present ? data.senderDid.value : this.senderDid,
      content: data.content.present ? data.content.value : this.content,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      status: data.status.present ? data.status.value : this.status,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DmMessage(')
          ..write('messageId: $messageId, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('convoId: $convoId, ')
          ..write('senderDid: $senderDid, ')
          ..write('content: $content, ')
          ..write('sentAt: $sentAt, ')
          ..write('status: $status, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(messageId, ownerDid, convoId, senderDid, content, sentAt, status, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DmMessage &&
          other.messageId == this.messageId &&
          other.ownerDid == this.ownerDid &&
          other.convoId == this.convoId &&
          other.senderDid == this.senderDid &&
          other.content == this.content &&
          other.sentAt == this.sentAt &&
          other.status == this.status &&
          other.cachedAt == this.cachedAt);
}

class DmMessagesCompanion extends UpdateCompanion<DmMessage> {
  final Value<String> messageId;
  final Value<String> ownerDid;
  final Value<String> convoId;
  final Value<String> senderDid;
  final Value<String> content;
  final Value<DateTime> sentAt;
  final Value<String> status;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const DmMessagesCompanion({
    this.messageId = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.convoId = const Value.absent(),
    this.senderDid = const Value.absent(),
    this.content = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.status = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DmMessagesCompanion.insert({
    required String messageId,
    required String ownerDid,
    required String convoId,
    required String senderDid,
    required String content,
    required DateTime sentAt,
    required String status,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       ownerDid = Value(ownerDid),
       convoId = Value(convoId),
       senderDid = Value(senderDid),
       content = Value(content),
       sentAt = Value(sentAt),
       status = Value(status),
       cachedAt = Value(cachedAt);
  static Insertable<DmMessage> custom({
    Expression<String>? messageId,
    Expression<String>? ownerDid,
    Expression<String>? convoId,
    Expression<String>? senderDid,
    Expression<String>? content,
    Expression<DateTime>? sentAt,
    Expression<String>? status,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (convoId != null) 'convo_id': convoId,
      if (senderDid != null) 'sender_did': senderDid,
      if (content != null) 'content': content,
      if (sentAt != null) 'sent_at': sentAt,
      if (status != null) 'status': status,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DmMessagesCompanion copyWith({
    Value<String>? messageId,
    Value<String>? ownerDid,
    Value<String>? convoId,
    Value<String>? senderDid,
    Value<String>? content,
    Value<DateTime>? sentAt,
    Value<String>? status,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return DmMessagesCompanion(
      messageId: messageId ?? this.messageId,
      ownerDid: ownerDid ?? this.ownerDid,
      convoId: convoId ?? this.convoId,
      senderDid: senderDid ?? this.senderDid,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (convoId.present) {
      map['convo_id'] = Variable<String>(convoId.value);
    }
    if (senderDid.present) {
      map['sender_did'] = Variable<String>(senderDid.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DmMessagesCompanion(')
          ..write('messageId: $messageId, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('convoId: $convoId, ')
          ..write('senderDid: $senderDid, ')
          ..write('content: $content, ')
          ..write('sentAt: $sentAt, ')
          ..write('status: $status, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DmOutboxTable extends DmOutbox with TableInfo<$DmOutboxTable, DmOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DmOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _outboxIdMeta = const VerificationMeta('outboxId');
  @override
  late final GeneratedColumn<String> outboxId = GeneratedColumn<String>(
    'outbox_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerDidMeta = const VerificationMeta('ownerDid');
  @override
  late final GeneratedColumn<String> ownerDid = GeneratedColumn<String>(
    'owner_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _convoIdMeta = const VerificationMeta('convoId');
  @override
  late final GeneratedColumn<String> convoId = GeneratedColumn<String>(
    'convo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageTextMeta = const VerificationMeta('messageText');
  @override
  late final GeneratedColumn<String> messageText = GeneratedColumn<String>(
    'message_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt = GeneratedColumn<DateTime>(
    'last_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    outboxId,
    ownerDid,
    convoId,
    messageText,
    status,
    retryCount,
    createdAt,
    lastAttemptAt,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dm_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<DmOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('outbox_id')) {
      context.handle(
        _outboxIdMeta,
        outboxId.isAcceptableOrUnknown(data['outbox_id']!, _outboxIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outboxIdMeta);
    }
    if (data.containsKey('owner_did')) {
      context.handle(
        _ownerDidMeta,
        ownerDid.isAcceptableOrUnknown(data['owner_did']!, _ownerDidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerDidMeta);
    }
    if (data.containsKey('convo_id')) {
      context.handle(_convoIdMeta, convoId.isAcceptableOrUnknown(data['convo_id']!, _convoIdMeta));
    } else if (isInserting) {
      context.missing(_convoIdMeta);
    }
    if (data.containsKey('message_text')) {
      context.handle(
        _messageTextMeta,
        messageText.isAcceptableOrUnknown(data['message_text']!, _messageTextMeta),
      );
    } else if (isInserting) {
      context.missing(_messageTextMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
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
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(data['last_attempt_at']!, _lastAttemptAtMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(data['error_message']!, _errorMessageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {outboxId};
  @override
  DmOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DmOutboxData(
      outboxId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outbox_id'],
      )!,
      ownerDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_did'],
      )!,
      convoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}convo_id'],
      )!,
      messageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_text'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $DmOutboxTable createAlias(String alias) {
    return $DmOutboxTable(attachedDatabase, alias);
  }
}

class DmOutboxData extends DataClass implements Insertable<DmOutboxData> {
  /// Local UUID for this outbox item.
  final String outboxId;

  /// The DID of the user who sent this message.
  final String ownerDid;

  /// Conversation to send the message to.
  final String convoId;

  /// Message text content.
  final String messageText;

  /// Status: pending, sending, failed.
  final String status;

  /// Number of send attempts.
  final int retryCount;

  /// When the message was queued.
  final DateTime createdAt;

  /// When the last send attempt was made.
  final DateTime? lastAttemptAt;

  /// Error message from the last failed attempt.
  final String? errorMessage;
  const DmOutboxData({
    required this.outboxId,
    required this.ownerDid,
    required this.convoId,
    required this.messageText,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    this.lastAttemptAt,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['outbox_id'] = Variable<String>(outboxId);
    map['owner_did'] = Variable<String>(ownerDid);
    map['convo_id'] = Variable<String>(convoId);
    map['message_text'] = Variable<String>(messageText);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  DmOutboxCompanion toCompanion(bool nullToAbsent) {
    return DmOutboxCompanion(
      outboxId: Value(outboxId),
      ownerDid: Value(ownerDid),
      convoId: Value(convoId),
      messageText: Value(messageText),
      status: Value(status),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory DmOutboxData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DmOutboxData(
      outboxId: serializer.fromJson<String>(json['outboxId']),
      ownerDid: serializer.fromJson<String>(json['ownerDid']),
      convoId: serializer.fromJson<String>(json['convoId']),
      messageText: serializer.fromJson<String>(json['messageText']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'outboxId': serializer.toJson<String>(outboxId),
      'ownerDid': serializer.toJson<String>(ownerDid),
      'convoId': serializer.toJson<String>(convoId),
      'messageText': serializer.toJson<String>(messageText),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  DmOutboxData copyWith({
    String? outboxId,
    String? ownerDid,
    String? convoId,
    String? messageText,
    String? status,
    int? retryCount,
    DateTime? createdAt,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
  }) => DmOutboxData(
    outboxId: outboxId ?? this.outboxId,
    ownerDid: ownerDid ?? this.ownerDid,
    convoId: convoId ?? this.convoId,
    messageText: messageText ?? this.messageText,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
    lastAttemptAt: lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  DmOutboxData copyWithCompanion(DmOutboxCompanion data) {
    return DmOutboxData(
      outboxId: data.outboxId.present ? data.outboxId.value : this.outboxId,
      ownerDid: data.ownerDid.present ? data.ownerDid.value : this.ownerDid,
      convoId: data.convoId.present ? data.convoId.value : this.convoId,
      messageText: data.messageText.present ? data.messageText.value : this.messageText,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present ? data.retryCount.value : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present ? data.lastAttemptAt.value : this.lastAttemptAt,
      errorMessage: data.errorMessage.present ? data.errorMessage.value : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DmOutboxData(')
          ..write('outboxId: $outboxId, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('convoId: $convoId, ')
          ..write('messageText: $messageText, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    outboxId,
    ownerDid,
    convoId,
    messageText,
    status,
    retryCount,
    createdAt,
    lastAttemptAt,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DmOutboxData &&
          other.outboxId == this.outboxId &&
          other.ownerDid == this.ownerDid &&
          other.convoId == this.convoId &&
          other.messageText == this.messageText &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.errorMessage == this.errorMessage);
}

class DmOutboxCompanion extends UpdateCompanion<DmOutboxData> {
  final Value<String> outboxId;
  final Value<String> ownerDid;
  final Value<String> convoId;
  final Value<String> messageText;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> errorMessage;
  final Value<int> rowid;
  const DmOutboxCompanion({
    this.outboxId = const Value.absent(),
    this.ownerDid = const Value.absent(),
    this.convoId = const Value.absent(),
    this.messageText = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DmOutboxCompanion.insert({
    required String outboxId,
    required String ownerDid,
    required String convoId,
    required String messageText,
    required String status,
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
    this.lastAttemptAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : outboxId = Value(outboxId),
       ownerDid = Value(ownerDid),
       convoId = Value(convoId),
       messageText = Value(messageText),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<DmOutboxData> custom({
    Expression<String>? outboxId,
    Expression<String>? ownerDid,
    Expression<String>? convoId,
    Expression<String>? messageText,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? errorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (outboxId != null) 'outbox_id': outboxId,
      if (ownerDid != null) 'owner_did': ownerDid,
      if (convoId != null) 'convo_id': convoId,
      if (messageText != null) 'message_text': messageText,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DmOutboxCompanion copyWith({
    Value<String>? outboxId,
    Value<String>? ownerDid,
    Value<String>? convoId,
    Value<String>? messageText,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? errorMessage,
    Value<int>? rowid,
  }) {
    return DmOutboxCompanion(
      outboxId: outboxId ?? this.outboxId,
      ownerDid: ownerDid ?? this.ownerDid,
      convoId: convoId ?? this.convoId,
      messageText: messageText ?? this.messageText,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (outboxId.present) {
      map['outbox_id'] = Variable<String>(outboxId.value);
    }
    if (ownerDid.present) {
      map['owner_did'] = Variable<String>(ownerDid.value);
    }
    if (convoId.present) {
      map['convo_id'] = Variable<String>(convoId.value);
    }
    if (messageText.present) {
      map['message_text'] = Variable<String>(messageText.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DmOutboxCompanion(')
          ..write('outboxId: $outboxId, ')
          ..write('ownerDid: $ownerDid, ')
          ..write('convoId: $convoId, ')
          ..write('messageText: $messageText, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $FeedContentItemsTable feedContentItems = $FeedContentItemsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $FeedCursorsTable feedCursors = $FeedCursorsTable(this);
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  late final $SearchCacheItemsTable searchCacheItems = $SearchCacheItemsTable(this);
  late final $SearchCacheCursorsTable searchCacheCursors = $SearchCacheCursorsTable(this);
  late final $FollowsTable follows = $FollowsTable(this);
  late final $SavedFeedsTable savedFeeds = $SavedFeedsTable(this);
  late final $PreferenceSyncQueueTable preferenceSyncQueue = $PreferenceSyncQueueTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final $DraftMediaTable draftMedia = $DraftMediaTable(this);
  late final $ProfileRelationshipsTable profileRelationships = $ProfileRelationshipsTable(this);
  late final $PostInteractionsTable postInteractions = $PostInteractionsTable(this);
  late final $LocalSettingsTable localSettings = $LocalSettingsTable(this);
  late final $BlueskyPreferencesTable blueskyPreferences = $BlueskyPreferencesTable(this);
  late final $CustomThemesTable customThemes = $CustomThemesTable(this);
  late final $AnimationPreferencesTableTable animationPreferencesTable =
      $AnimationPreferencesTableTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $NotificationCursorsTable notificationCursors = $NotificationCursorsTable(this);
  late final $NotificationsSyncQueueTable notificationsSyncQueue = $NotificationsSyncQueueTable(
    this,
  );
  late final $DmConvosTable dmConvos = $DmConvosTable(this);
  late final $DmMessagesTable dmMessages = $DmMessagesTable(this);
  late final $DmOutboxTable dmOutbox = $DmOutboxTable(this);
  late final Index feedContentSortIdx = Index(
    'feed_content_sort_idx',
    'CREATE INDEX feed_content_sort_idx ON feed_content_items (feed_key, sort_key)',
  );
  late final Index searchCacheSortIdx = Index(
    'search_cache_sort_idx',
    'CREATE INDEX search_cache_sort_idx ON search_cache_items (query_key, sort_key)',
  );
  late final Index notificationsIndexedAtIdx = Index(
    'notifications_indexed_at_idx',
    'CREATE INDEX notifications_indexed_at_idx ON notifications (indexed_at)',
  );
  late final Index dmMessagesConvoIdx = Index(
    'dm_messages_convo_idx',
    'CREATE INDEX dm_messages_convo_idx ON dm_messages (convo_id, sent_at)',
  );
  late final FeedContentDao feedContentDao = FeedContentDao(this as AppDatabase);
  late final ProfileDao profileDao = ProfileDao(this as AppDatabase);
  late final ProfileRelationshipDao profileRelationshipDao = ProfileRelationshipDao(
    this as AppDatabase,
  );
  late final SearchDao searchDao = SearchDao(this as AppDatabase);
  late final SearchCacheDao searchCacheDao = SearchCacheDao(this as AppDatabase);
  late final FollowsDao followsDao = FollowsDao(this as AppDatabase);
  late final SavedFeedsDao savedFeedsDao = SavedFeedsDao(this as AppDatabase);
  late final PreferenceSyncQueueDao preferenceSyncQueueDao = PreferenceSyncQueueDao(
    this as AppDatabase,
  );
  late final DraftsDao draftsDao = DraftsDao(this as AppDatabase);
  late final PostInteractionsDao postInteractionsDao = PostInteractionsDao(this as AppDatabase);
  late final LocalSettingsDao localSettingsDao = LocalSettingsDao(this as AppDatabase);
  late final BlueskyPreferencesDao blueskyPreferencesDao = BlueskyPreferencesDao(
    this as AppDatabase,
  );
  late final CustomThemeDao customThemeDao = CustomThemeDao(this as AppDatabase);
  late final AnimationPreferencesDao animationPreferencesDao = AnimationPreferencesDao(
    this as AppDatabase,
  );
  late final NotificationsDao notificationsDao = NotificationsDao(this as AppDatabase);
  late final NotificationsSyncQueueDao notificationsSyncQueueDao = NotificationsSyncQueueDao(
    this as AppDatabase,
  );
  late final DmConvosDao dmConvosDao = DmConvosDao(this as AppDatabase);
  late final DmMessagesDao dmMessagesDao = DmMessagesDao(this as AppDatabase);
  late final DmOutboxDao dmOutboxDao = DmOutboxDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    posts,
    feedContentItems,
    accounts,
    feedCursors,
    recentSearches,
    searchCacheItems,
    searchCacheCursors,
    follows,
    savedFeeds,
    preferenceSyncQueue,
    drafts,
    draftMedia,
    profileRelationships,
    postInteractions,
    localSettings,
    blueskyPreferences,
    customThemes,
    animationPreferencesTable,
    notifications,
    notificationCursors,
    notificationsSyncQueue,
    dmConvos,
    dmMessages,
    dmOutbox,
    feedContentSortIdx,
    searchCacheSortIdx,
    notificationsIndexedAtIdx,
    dmMessagesConvoIdx,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String did,
      required String handle,
      Value<String?> displayName,
      Value<String?> description,
      Value<String?> avatar,
      Value<String?> banner,
      Value<DateTime?> indexedAt,
      Value<String?> pronouns,
      Value<String?> website,
      Value<DateTime?> createdAt,
      Value<String?> verificationStatus,
      Value<String?> labels,
      Value<String?> pinnedPostUri,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> did,
      Value<String> handle,
      Value<String?> displayName,
      Value<String?> description,
      Value<String?> avatar,
      Value<String?> banner,
      Value<DateTime?> indexedAt,
      Value<String?> pronouns,
      Value<String?> website,
      Value<DateTime?> createdAt,
      Value<String?> verificationStatus,
      Value<String?> labels,
      Value<String?> pinnedPostUri,
      Value<int> rowid,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PostsTable, List<Post>> _postsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.posts,
        aliasName: $_aliasNameGenerator(db.profiles.did, db.posts.authorDid),
      );

  $$PostsTableProcessedTableManager get postsRefs {
    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.authorDid.did.sqlEquals($_itemColumn<String>('did')!));

    final cache = $_typedResult.readTableOrNull(_postsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SavedFeedsTable, List<SavedFeed>> _savedFeedsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.savedFeeds,
    aliasName: $_aliasNameGenerator(db.profiles.did, db.savedFeeds.creatorDid),
  );

  $$SavedFeedsTableProcessedTableManager get savedFeedsRefs {
    final manager = $$SavedFeedsTableTableManager(
      $_db,
      $_db.savedFeeds,
    ).filter((f) => f.creatorDid.did.sqlEquals($_itemColumn<String>('did')!));

    final cache = $_typedResult.readTableOrNull(_savedFeedsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProfileRelationshipsTable, List<ProfileRelationship>>
  _profileRelationshipsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.profileRelationships,
    aliasName: $_aliasNameGenerator(db.profiles.did, db.profileRelationships.profileDid),
  );

  $$ProfileRelationshipsTableProcessedTableManager get profileRelationshipsRefs {
    final manager = $$ProfileRelationshipsTableTableManager(
      $_db,
      $_db.profileRelationships,
    ).filter((f) => f.profileDid.did.sqlEquals($_itemColumn<String>('did')!));

    final cache = $_typedResult.readTableOrNull(_profileRelationshipsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NotificationsTable, List<Notification>> _notificationsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notifications,
    aliasName: $_aliasNameGenerator(db.profiles.did, db.notifications.actorDid),
  );

  $$NotificationsTableProcessedTableManager get notificationsRefs {
    final manager = $$NotificationsTableTableManager(
      $_db,
      $_db.notifications,
    ).filter((f) => f.actorDid.did.sqlEquals($_itemColumn<String>('did')!));

    final cache = $_typedResult.readTableOrNull(_notificationsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DmMessagesTable, List<DmMessage>> _dmMessagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.dmMessages,
    aliasName: $_aliasNameGenerator(db.profiles.did, db.dmMessages.senderDid),
  );

  $$DmMessagesTableProcessedTableManager get dmMessagesRefs {
    final manager = $$DmMessagesTableTableManager(
      $_db,
      $_db.dmMessages,
    ).filter((f) => f.senderDid.did.sqlEquals($_itemColumn<String>('did')!));

    final cache = $_typedResult.readTableOrNull(_dmMessagesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get did =>
      $composableBuilder(column: $table.did, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get banner =>
      $composableBuilder(column: $table.banner, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pronouns =>
      $composableBuilder(column: $table.pronouns, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verificationStatus => $composableBuilder(
    column: $table.verificationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinnedPostUri =>
      $composableBuilder(column: $table.pinnedPostUri, builder: (column) => ColumnFilters(column));

  Expression<bool> postsRefs(Expression<bool> Function($$PostsTableFilterComposer f) f) {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.authorDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableFilterComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<bool> savedFeedsRefs(Expression<bool> Function($$SavedFeedsTableFilterComposer f) f) {
    final $$SavedFeedsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.savedFeeds,
      getReferencedColumn: (t) => t.creatorDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$SavedFeedsTableFilterComposer(
                $db: $db,
                $table: $db.savedFeeds,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<bool> profileRelationshipsRefs(
    Expression<bool> Function($$ProfileRelationshipsTableFilterComposer f) f,
  ) {
    final $$ProfileRelationshipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.profileRelationships,
      getReferencedColumn: (t) => t.profileDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfileRelationshipsTableFilterComposer(
                $db: $db,
                $table: $db.profileRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<bool> notificationsRefs(
    Expression<bool> Function($$NotificationsTableFilterComposer f) f,
  ) {
    final $$NotificationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.notifications,
      getReferencedColumn: (t) => t.actorDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$NotificationsTableFilterComposer(
                $db: $db,
                $table: $db.notifications,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<bool> dmMessagesRefs(Expression<bool> Function($$DmMessagesTableFilterComposer f) f) {
    final $$DmMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.dmMessages,
      getReferencedColumn: (t) => t.senderDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$DmMessagesTableFilterComposer(
                $db: $db,
                $table: $db.dmMessages,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get did =>
      $composableBuilder(column: $table.did, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get banner =>
      $composableBuilder(column: $table.banner, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pronouns =>
      $composableBuilder(column: $table.pronouns, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verificationStatus => $composableBuilder(
    column: $table.verificationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinnedPostUri => $composableBuilder(
    column: $table.pinnedPostUri,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
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

  GeneratedColumn<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get banner =>
      $composableBuilder(column: $table.banner, builder: (column) => column);

  GeneratedColumn<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);

  GeneratedColumn<String> get pronouns =>
      $composableBuilder(column: $table.pronouns, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get verificationStatus =>
      $composableBuilder(column: $table.verificationStatus, builder: (column) => column);

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<String> get pinnedPostUri =>
      $composableBuilder(column: $table.pinnedPostUri, builder: (column) => column);

  Expression<T> postsRefs<T extends Object>(
    Expression<T> Function($$PostsTableAnnotationComposer a) f,
  ) {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.authorDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableAnnotationComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<T> savedFeedsRefs<T extends Object>(
    Expression<T> Function($$SavedFeedsTableAnnotationComposer a) f,
  ) {
    final $$SavedFeedsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.savedFeeds,
      getReferencedColumn: (t) => t.creatorDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$SavedFeedsTableAnnotationComposer(
                $db: $db,
                $table: $db.savedFeeds,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<T> profileRelationshipsRefs<T extends Object>(
    Expression<T> Function($$ProfileRelationshipsTableAnnotationComposer a) f,
  ) {
    final $$ProfileRelationshipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.profileRelationships,
      getReferencedColumn: (t) => t.profileDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfileRelationshipsTableAnnotationComposer(
                $db: $db,
                $table: $db.profileRelationships,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<T> notificationsRefs<T extends Object>(
    Expression<T> Function($$NotificationsTableAnnotationComposer a) f,
  ) {
    final $$NotificationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.notifications,
      getReferencedColumn: (t) => t.actorDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$NotificationsTableAnnotationComposer(
                $db: $db,
                $table: $db.notifications,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<T> dmMessagesRefs<T extends Object>(
    Expression<T> Function($$DmMessagesTableAnnotationComposer a) f,
  ) {
    final $$DmMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.did,
      referencedTable: $db.dmMessages,
      getReferencedColumn: (t) => t.senderDid,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$DmMessagesTableAnnotationComposer(
                $db: $db,
                $table: $db.dmMessages,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({
            bool postsRefs,
            bool savedFeedsRefs,
            bool profileRelationshipsRefs,
            bool notificationsRefs,
            bool dmMessagesRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> did = const Value.absent(),
                Value<String> handle = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> banner = const Value.absent(),
                Value<DateTime?> indexedAt = const Value.absent(),
                Value<String?> pronouns = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> verificationStatus = const Value.absent(),
                Value<String?> labels = const Value.absent(),
                Value<String?> pinnedPostUri = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                did: did,
                handle: handle,
                displayName: displayName,
                description: description,
                avatar: avatar,
                banner: banner,
                indexedAt: indexedAt,
                pronouns: pronouns,
                website: website,
                createdAt: createdAt,
                verificationStatus: verificationStatus,
                labels: labels,
                pinnedPostUri: pinnedPostUri,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String did,
                required String handle,
                Value<String?> displayName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> banner = const Value.absent(),
                Value<DateTime?> indexedAt = const Value.absent(),
                Value<String?> pronouns = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> verificationStatus = const Value.absent(),
                Value<String?> labels = const Value.absent(),
                Value<String?> pinnedPostUri = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                did: did,
                handle: handle,
                displayName: displayName,
                description: description,
                avatar: avatar,
                banner: banner,
                indexedAt: indexedAt,
                pronouns: pronouns,
                website: website,
                createdAt: createdAt,
                verificationStatus: verificationStatus,
                labels: labels,
                pinnedPostUri: pinnedPostUri,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$ProfilesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback:
              ({
                postsRefs = false,
                savedFeedsRefs = false,
                profileRelationshipsRefs = false,
                notificationsRefs = false,
                dmMessagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (postsRefs) db.posts,
                    if (savedFeedsRefs) db.savedFeeds,
                    if (profileRelationshipsRefs) db.profileRelationships,
                    if (notificationsRefs) db.notifications,
                    if (dmMessagesRefs) db.dmMessages,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (postsRefs)
                        await $_getPrefetchedData<Profile, $ProfilesTable, Post>(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._postsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).postsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.authorDid == item.did),
                          typedResults: items,
                        ),
                      if (savedFeedsRefs)
                        await $_getPrefetchedData<Profile, $ProfilesTable, SavedFeed>(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._savedFeedsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).savedFeedsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.creatorDid == item.did),
                          typedResults: items,
                        ),
                      if (profileRelationshipsRefs)
                        await $_getPrefetchedData<Profile, $ProfilesTable, ProfileRelationship>(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._profileRelationshipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).profileRelationshipsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.profileDid == item.did),
                          typedResults: items,
                        ),
                      if (notificationsRefs)
                        await $_getPrefetchedData<Profile, $ProfilesTable, Notification>(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._notificationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).notificationsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.actorDid == item.did),
                          typedResults: items,
                        ),
                      if (dmMessagesRefs)
                        await $_getPrefetchedData<Profile, $ProfilesTable, DmMessage>(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._dmMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(db, table, p0).dmMessagesRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.senderDid == item.did),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({
        bool postsRefs,
        bool savedFeedsRefs,
        bool profileRelationshipsRefs,
        bool notificationsRefs,
        bool dmMessagesRefs,
      })
    >;
typedef $$PostsTableCreateCompanionBuilder =
    PostsCompanion Function({
      required String uri,
      required String cid,
      required String authorDid,
      required String record,
      Value<String?> embed,
      Value<DateTime?> indexedAt,
      Value<int> replyCount,
      Value<int> repostCount,
      Value<int> likeCount,
      Value<int> quoteCount,
      Value<int> bookmarkCount,
      Value<String?> labels,
      Value<String?> viewerLikeUri,
      Value<String?> viewerRepostUri,
      Value<bool> viewerBookmarked,
      Value<bool> viewerThreadMuted,
      Value<bool> viewerReplyDisabled,
      Value<int> rowid,
    });
typedef $$PostsTableUpdateCompanionBuilder =
    PostsCompanion Function({
      Value<String> uri,
      Value<String> cid,
      Value<String> authorDid,
      Value<String> record,
      Value<String?> embed,
      Value<DateTime?> indexedAt,
      Value<int> replyCount,
      Value<int> repostCount,
      Value<int> likeCount,
      Value<int> quoteCount,
      Value<int> bookmarkCount,
      Value<String?> labels,
      Value<String?> viewerLikeUri,
      Value<String?> viewerRepostUri,
      Value<bool> viewerBookmarked,
      Value<bool> viewerThreadMuted,
      Value<bool> viewerReplyDisabled,
      Value<int> rowid,
    });

final class $$PostsTableReferences extends BaseReferences<_$AppDatabase, $PostsTable, Post> {
  $$PostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _authorDidTable(_$AppDatabase db) =>
      db.profiles.createAlias($_aliasNameGenerator(db.posts.authorDid, db.profiles.did));

  $$ProfilesTableProcessedTableManager get authorDid {
    final $_column = $_itemColumn<String>('author_did')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.did.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorDidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$FeedContentItemsTable, List<FeedContentItem>>
  _feedContentItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.feedContentItems,
    aliasName: $_aliasNameGenerator(db.posts.uri, db.feedContentItems.postUri),
  );

  $$FeedContentItemsTableProcessedTableManager get feedContentItemsRefs {
    final manager = $$FeedContentItemsTableTableManager(
      $_db,
      $_db.feedContentItems,
    ).filter((f) => f.postUri.uri.sqlEquals($_itemColumn<String>('uri')!));

    final cache = $_typedResult.readTableOrNull(_feedContentItemsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SearchCacheItemsTable, List<SearchCacheItem>>
  _searchCacheItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.searchCacheItems,
    aliasName: $_aliasNameGenerator(db.posts.uri, db.searchCacheItems.postUri),
  );

  $$SearchCacheItemsTableProcessedTableManager get searchCacheItemsRefs {
    final manager = $$SearchCacheItemsTableTableManager(
      $_db,
      $_db.searchCacheItems,
    ).filter((f) => f.postUri.uri.sqlEquals($_itemColumn<String>('uri')!));

    final cache = $_typedResult.readTableOrNull(_searchCacheItemsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PostInteractionsTable, List<PostInteraction>>
  _postInteractionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.postInteractions,
    aliasName: $_aliasNameGenerator(db.posts.uri, db.postInteractions.postUri),
  );

  $$PostInteractionsTableProcessedTableManager get postInteractionsRefs {
    final manager = $$PostInteractionsTableTableManager(
      $_db,
      $_db.postInteractions,
    ).filter((f) => f.postUri.uri.sqlEquals($_itemColumn<String>('uri')!));

    final cache = $_typedResult.readTableOrNull(_postInteractionsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PostsTableFilterComposer extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cid =>
      $composableBuilder(column: $table.cid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get record =>
      $composableBuilder(column: $table.record, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get embed =>
      $composableBuilder(column: $table.embed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get replyCount =>
      $composableBuilder(column: $table.replyCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repostCount =>
      $composableBuilder(column: $table.repostCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quoteCount =>
      $composableBuilder(column: $table.quoteCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookmarkCount =>
      $composableBuilder(column: $table.bookmarkCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get viewerLikeUri =>
      $composableBuilder(column: $table.viewerLikeUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get viewerRepostUri => $composableBuilder(
    column: $table.viewerRepostUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get viewerBookmarked => $composableBuilder(
    column: $table.viewerBookmarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get viewerThreadMuted => $composableBuilder(
    column: $table.viewerThreadMuted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get viewerReplyDisabled => $composableBuilder(
    column: $table.viewerReplyDisabled,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get authorDid {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableFilterComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }

  Expression<bool> feedContentItemsRefs(
    Expression<bool> Function($$FeedContentItemsTableFilterComposer f) f,
  ) {
    final $$FeedContentItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uri,
      referencedTable: $db.feedContentItems,
      getReferencedColumn: (t) => t.postUri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$FeedContentItemsTableFilterComposer(
                $db: $db,
                $table: $db.feedContentItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<bool> searchCacheItemsRefs(
    Expression<bool> Function($$SearchCacheItemsTableFilterComposer f) f,
  ) {
    final $$SearchCacheItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uri,
      referencedTable: $db.searchCacheItems,
      getReferencedColumn: (t) => t.postUri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$SearchCacheItemsTableFilterComposer(
                $db: $db,
                $table: $db.searchCacheItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<bool> postInteractionsRefs(
    Expression<bool> Function($$PostInteractionsTableFilterComposer f) f,
  ) {
    final $$PostInteractionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uri,
      referencedTable: $db.postInteractions,
      getReferencedColumn: (t) => t.postUri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostInteractionsTableFilterComposer(
                $db: $db,
                $table: $db.postInteractions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }
}

class $$PostsTableOrderingComposer extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cid =>
      $composableBuilder(column: $table.cid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get record =>
      $composableBuilder(column: $table.record, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get embed =>
      $composableBuilder(column: $table.embed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get replyCount =>
      $composableBuilder(column: $table.replyCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repostCount =>
      $composableBuilder(column: $table.repostCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quoteCount =>
      $composableBuilder(column: $table.quoteCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookmarkCount => $composableBuilder(
    column: $table.bookmarkCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get viewerLikeUri => $composableBuilder(
    column: $table.viewerLikeUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewerRepostUri => $composableBuilder(
    column: $table.viewerRepostUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get viewerBookmarked => $composableBuilder(
    column: $table.viewerBookmarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get viewerThreadMuted => $composableBuilder(
    column: $table.viewerThreadMuted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get viewerReplyDisabled => $composableBuilder(
    column: $table.viewerReplyDisabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get authorDid {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableOrderingComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$PostsTableAnnotationComposer extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get cid =>
      $composableBuilder(column: $table.cid, builder: (column) => column);

  GeneratedColumn<String> get record =>
      $composableBuilder(column: $table.record, builder: (column) => column);

  GeneratedColumn<String> get embed =>
      $composableBuilder(column: $table.embed, builder: (column) => column);

  GeneratedColumn<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);

  GeneratedColumn<int> get replyCount =>
      $composableBuilder(column: $table.replyCount, builder: (column) => column);

  GeneratedColumn<int> get repostCount =>
      $composableBuilder(column: $table.repostCount, builder: (column) => column);

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<int> get quoteCount =>
      $composableBuilder(column: $table.quoteCount, builder: (column) => column);

  GeneratedColumn<int> get bookmarkCount =>
      $composableBuilder(column: $table.bookmarkCount, builder: (column) => column);

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<String> get viewerLikeUri =>
      $composableBuilder(column: $table.viewerLikeUri, builder: (column) => column);

  GeneratedColumn<String> get viewerRepostUri =>
      $composableBuilder(column: $table.viewerRepostUri, builder: (column) => column);

  GeneratedColumn<bool> get viewerBookmarked =>
      $composableBuilder(column: $table.viewerBookmarked, builder: (column) => column);

  GeneratedColumn<bool> get viewerThreadMuted =>
      $composableBuilder(column: $table.viewerThreadMuted, builder: (column) => column);

  GeneratedColumn<bool> get viewerReplyDisabled =>
      $composableBuilder(column: $table.viewerReplyDisabled, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get authorDid {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }

  Expression<T> feedContentItemsRefs<T extends Object>(
    Expression<T> Function($$FeedContentItemsTableAnnotationComposer a) f,
  ) {
    final $$FeedContentItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uri,
      referencedTable: $db.feedContentItems,
      getReferencedColumn: (t) => t.postUri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$FeedContentItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.feedContentItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<T> searchCacheItemsRefs<T extends Object>(
    Expression<T> Function($$SearchCacheItemsTableAnnotationComposer a) f,
  ) {
    final $$SearchCacheItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uri,
      referencedTable: $db.searchCacheItems,
      getReferencedColumn: (t) => t.postUri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$SearchCacheItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.searchCacheItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }

  Expression<T> postInteractionsRefs<T extends Object>(
    Expression<T> Function($$PostInteractionsTableAnnotationComposer a) f,
  ) {
    final $$PostInteractionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uri,
      referencedTable: $db.postInteractions,
      getReferencedColumn: (t) => t.postUri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostInteractionsTableAnnotationComposer(
                $db: $db,
                $table: $db.postInteractions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }
}

class $$PostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostsTable,
          Post,
          $$PostsTableFilterComposer,
          $$PostsTableOrderingComposer,
          $$PostsTableAnnotationComposer,
          $$PostsTableCreateCompanionBuilder,
          $$PostsTableUpdateCompanionBuilder,
          (Post, $$PostsTableReferences),
          Post,
          PrefetchHooks Function({
            bool authorDid,
            bool feedContentItemsRefs,
            bool searchCacheItemsRefs,
            bool postInteractionsRefs,
          })
        > {
  $$PostsTableTableManager(_$AppDatabase db, $PostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uri = const Value.absent(),
                Value<String> cid = const Value.absent(),
                Value<String> authorDid = const Value.absent(),
                Value<String> record = const Value.absent(),
                Value<String?> embed = const Value.absent(),
                Value<DateTime?> indexedAt = const Value.absent(),
                Value<int> replyCount = const Value.absent(),
                Value<int> repostCount = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<int> quoteCount = const Value.absent(),
                Value<int> bookmarkCount = const Value.absent(),
                Value<String?> labels = const Value.absent(),
                Value<String?> viewerLikeUri = const Value.absent(),
                Value<String?> viewerRepostUri = const Value.absent(),
                Value<bool> viewerBookmarked = const Value.absent(),
                Value<bool> viewerThreadMuted = const Value.absent(),
                Value<bool> viewerReplyDisabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion(
                uri: uri,
                cid: cid,
                authorDid: authorDid,
                record: record,
                embed: embed,
                indexedAt: indexedAt,
                replyCount: replyCount,
                repostCount: repostCount,
                likeCount: likeCount,
                quoteCount: quoteCount,
                bookmarkCount: bookmarkCount,
                labels: labels,
                viewerLikeUri: viewerLikeUri,
                viewerRepostUri: viewerRepostUri,
                viewerBookmarked: viewerBookmarked,
                viewerThreadMuted: viewerThreadMuted,
                viewerReplyDisabled: viewerReplyDisabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uri,
                required String cid,
                required String authorDid,
                required String record,
                Value<String?> embed = const Value.absent(),
                Value<DateTime?> indexedAt = const Value.absent(),
                Value<int> replyCount = const Value.absent(),
                Value<int> repostCount = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<int> quoteCount = const Value.absent(),
                Value<int> bookmarkCount = const Value.absent(),
                Value<String?> labels = const Value.absent(),
                Value<String?> viewerLikeUri = const Value.absent(),
                Value<String?> viewerRepostUri = const Value.absent(),
                Value<bool> viewerBookmarked = const Value.absent(),
                Value<bool> viewerThreadMuted = const Value.absent(),
                Value<bool> viewerReplyDisabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion.insert(
                uri: uri,
                cid: cid,
                authorDid: authorDid,
                record: record,
                embed: embed,
                indexedAt: indexedAt,
                replyCount: replyCount,
                repostCount: repostCount,
                likeCount: likeCount,
                quoteCount: quoteCount,
                bookmarkCount: bookmarkCount,
                labels: labels,
                viewerLikeUri: viewerLikeUri,
                viewerRepostUri: viewerRepostUri,
                viewerBookmarked: viewerBookmarked,
                viewerThreadMuted: viewerThreadMuted,
                viewerReplyDisabled: viewerReplyDisabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$PostsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback:
              ({
                authorDid = false,
                feedContentItemsRefs = false,
                searchCacheItemsRefs = false,
                postInteractionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (feedContentItemsRefs) db.feedContentItems,
                    if (searchCacheItemsRefs) db.searchCacheItems,
                    if (postInteractionsRefs) db.postInteractions,
                  ],
                  addJoins:
                      <
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
                        if (authorDid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.authorDid,
                                    referencedTable: $$PostsTableReferences._authorDidTable(db),
                                    referencedColumn: $$PostsTableReferences
                                        ._authorDidTable(db)
                                        .did,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (feedContentItemsRefs)
                        await $_getPrefetchedData<Post, $PostsTable, FeedContentItem>(
                          currentTable: table,
                          referencedTable: $$PostsTableReferences._feedContentItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PostsTableReferences(db, table, p0).feedContentItemsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.postUri == item.uri),
                          typedResults: items,
                        ),
                      if (searchCacheItemsRefs)
                        await $_getPrefetchedData<Post, $PostsTable, SearchCacheItem>(
                          currentTable: table,
                          referencedTable: $$PostsTableReferences._searchCacheItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PostsTableReferences(db, table, p0).searchCacheItemsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.postUri == item.uri),
                          typedResults: items,
                        ),
                      if (postInteractionsRefs)
                        await $_getPrefetchedData<Post, $PostsTable, PostInteraction>(
                          currentTable: table,
                          referencedTable: $$PostsTableReferences._postInteractionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PostsTableReferences(db, table, p0).postInteractionsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.postUri == item.uri),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostsTable,
      Post,
      $$PostsTableFilterComposer,
      $$PostsTableOrderingComposer,
      $$PostsTableAnnotationComposer,
      $$PostsTableCreateCompanionBuilder,
      $$PostsTableUpdateCompanionBuilder,
      (Post, $$PostsTableReferences),
      Post,
      PrefetchHooks Function({
        bool authorDid,
        bool feedContentItemsRefs,
        bool searchCacheItemsRefs,
        bool postInteractionsRefs,
      })
    >;
typedef $$FeedContentItemsTableCreateCompanionBuilder =
    FeedContentItemsCompanion Function({
      required String feedKey,
      required String postUri,
      required String ownerDid,
      Value<String?> reason,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$FeedContentItemsTableUpdateCompanionBuilder =
    FeedContentItemsCompanion Function({
      Value<String> feedKey,
      Value<String> postUri,
      Value<String> ownerDid,
      Value<String?> reason,
      Value<String> sortKey,
      Value<int> rowid,
    });

final class $$FeedContentItemsTableReferences
    extends BaseReferences<_$AppDatabase, $FeedContentItemsTable, FeedContentItem> {
  $$FeedContentItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PostsTable _postUriTable(_$AppDatabase db) =>
      db.posts.createAlias($_aliasNameGenerator(db.feedContentItems.postUri, db.posts.uri));

  $$PostsTableProcessedTableManager get postUri {
    final $_column = $_itemColumn<String>('post_uri')!;

    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.uri.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postUriTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FeedContentItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedContentItemsTable> {
  $$FeedContentItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnFilters(column));

  $$PostsTableFilterComposer get postUri {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableFilterComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$FeedContentItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedContentItemsTable> {
  $$FeedContentItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnOrderings(column));

  $$PostsTableOrderingComposer get postUri {
    final $$PostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableOrderingComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$FeedContentItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedContentItemsTable> {
  $$FeedContentItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => column);

  $$PostsTableAnnotationComposer get postUri {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableAnnotationComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$FeedContentItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedContentItemsTable,
          FeedContentItem,
          $$FeedContentItemsTableFilterComposer,
          $$FeedContentItemsTableOrderingComposer,
          $$FeedContentItemsTableAnnotationComposer,
          $$FeedContentItemsTableCreateCompanionBuilder,
          $$FeedContentItemsTableUpdateCompanionBuilder,
          (FeedContentItem, $$FeedContentItemsTableReferences),
          FeedContentItem,
          PrefetchHooks Function({bool postUri})
        > {
  $$FeedContentItemsTableTableManager(_$AppDatabase db, $FeedContentItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedContentItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedContentItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedContentItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedKey = const Value.absent(),
                Value<String> postUri = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedContentItemsCompanion(
                feedKey: feedKey,
                postUri: postUri,
                ownerDid: ownerDid,
                reason: reason,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedKey,
                required String postUri,
                required String ownerDid,
                Value<String?> reason = const Value.absent(),
                required String sortKey,
                Value<int> rowid = const Value.absent(),
              }) => FeedContentItemsCompanion.insert(
                feedKey: feedKey,
                postUri: postUri,
                ownerDid: ownerDid,
                reason: reason,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$FeedContentItemsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({postUri = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (postUri) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.postUri,
                                referencedTable: $$FeedContentItemsTableReferences._postUriTable(
                                  db,
                                ),
                                referencedColumn: $$FeedContentItemsTableReferences
                                    ._postUriTable(db)
                                    .uri,
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

typedef $$FeedContentItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedContentItemsTable,
      FeedContentItem,
      $$FeedContentItemsTableFilterComposer,
      $$FeedContentItemsTableOrderingComposer,
      $$FeedContentItemsTableAnnotationComposer,
      $$FeedContentItemsTableCreateCompanionBuilder,
      $$FeedContentItemsTableUpdateCompanionBuilder,
      (FeedContentItem, $$FeedContentItemsTableReferences),
      FeedContentItem,
      PrefetchHooks Function({bool postUri})
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String did,
      required String handle,
      required String pdsUrl,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> did,
      Value<String> handle,
      Value<String> pdsUrl,
      Value<int> rowid,
    });

class $$AccountsTableFilterComposer extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get did =>
      $composableBuilder(column: $table.did, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pdsUrl =>
      $composableBuilder(column: $table.pdsUrl, builder: (column) => ColumnFilters(column));
}

class $$AccountsTableOrderingComposer extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get did =>
      $composableBuilder(column: $table.did, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pdsUrl =>
      $composableBuilder(column: $table.pdsUrl, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer extends Composer<_$AppDatabase, $AccountsTable> {
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

  GeneratedColumn<String> get pdsUrl =>
      $composableBuilder(column: $table.pdsUrl, builder: (column) => column);
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
          createFilteringComposer: () => $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> did = const Value.absent(),
                Value<String> handle = const Value.absent(),
                Value<String> pdsUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(did: did, handle: handle, pdsUrl: pdsUrl, rowid: rowid),
          createCompanionCallback:
              ({
                required String did,
                required String handle,
                required String pdsUrl,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AccountsCompanion.insert(did: did, handle: handle, pdsUrl: pdsUrl, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
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
typedef $$FeedCursorsTableCreateCompanionBuilder =
    FeedCursorsCompanion Function({
      required String feedKey,
      required String ownerDid,
      required String cursor,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });
typedef $$FeedCursorsTableUpdateCompanionBuilder =
    FeedCursorsCompanion Function({
      Value<String> feedKey,
      Value<String> ownerDid,
      Value<String> cursor,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });

class $$FeedCursorsTableFilterComposer extends Composer<_$AppDatabase, $FeedCursorsTable> {
  $$FeedCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated =>
      $composableBuilder(column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$FeedCursorsTableOrderingComposer extends Composer<_$AppDatabase, $FeedCursorsTable> {
  $$FeedCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated =>
      $composableBuilder(column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$FeedCursorsTableAnnotationComposer extends Composer<_$AppDatabase, $FeedCursorsTable> {
  $$FeedCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated =>
      $composableBuilder(column: $table.lastUpdated, builder: (column) => column);
}

class $$FeedCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedCursorsTable,
          FeedCursor,
          $$FeedCursorsTableFilterComposer,
          $$FeedCursorsTableOrderingComposer,
          $$FeedCursorsTableAnnotationComposer,
          $$FeedCursorsTableCreateCompanionBuilder,
          $$FeedCursorsTableUpdateCompanionBuilder,
          (FeedCursor, BaseReferences<_$AppDatabase, $FeedCursorsTable, FeedCursor>),
          FeedCursor,
          PrefetchHooks Function()
        > {
  $$FeedCursorsTableTableManager(_$AppDatabase db, $FeedCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FeedCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FeedCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedKey = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedCursorsCompanion(
                feedKey: feedKey,
                ownerDid: ownerDid,
                cursor: cursor,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedKey,
                required String ownerDid,
                required String cursor,
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedCursorsCompanion.insert(
                feedKey: feedKey,
                ownerDid: ownerDid,
                cursor: cursor,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedCursorsTable,
      FeedCursor,
      $$FeedCursorsTableFilterComposer,
      $$FeedCursorsTableOrderingComposer,
      $$FeedCursorsTableAnnotationComposer,
      $$FeedCursorsTableCreateCompanionBuilder,
      $$FeedCursorsTableUpdateCompanionBuilder,
      (FeedCursor, BaseReferences<_$AppDatabase, $FeedCursorsTable, FeedCursor>),
      FeedCursor,
      PrefetchHooks Function()
    >;
typedef $$RecentSearchesTableCreateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<int> id,
      required String query,
      required DateTime searchedAt,
    });
typedef $$RecentSearchesTableUpdateCompanionBuilder =
    RecentSearchesCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<DateTime> searchedAt,
    });

class $$RecentSearchesTableFilterComposer extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get searchedAt =>
      $composableBuilder(column: $table.searchedAt, builder: (column) => ColumnFilters(column));
}

class $$RecentSearchesTableOrderingComposer extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get searchedAt =>
      $composableBuilder(column: $table.searchedAt, builder: (column) => ColumnOrderings(column));
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get searchedAt =>
      $composableBuilder(column: $table.searchedAt, builder: (column) => column);
}

class $$RecentSearchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentSearchesTable,
          RecentSearche,
          $$RecentSearchesTableFilterComposer,
          $$RecentSearchesTableOrderingComposer,
          $$RecentSearchesTableAnnotationComposer,
          $$RecentSearchesTableCreateCompanionBuilder,
          $$RecentSearchesTableUpdateCompanionBuilder,
          (RecentSearche, BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>),
          RecentSearche,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(_$AppDatabase db, $RecentSearchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
              }) => RecentSearchesCompanion(id: id, query: query, searchedAt: searchedAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required DateTime searchedAt,
              }) => RecentSearchesCompanion.insert(id: id, query: query, searchedAt: searchedAt),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentSearchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentSearchesTable,
      RecentSearche,
      $$RecentSearchesTableFilterComposer,
      $$RecentSearchesTableOrderingComposer,
      $$RecentSearchesTableAnnotationComposer,
      $$RecentSearchesTableCreateCompanionBuilder,
      $$RecentSearchesTableUpdateCompanionBuilder,
      (RecentSearche, BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>),
      RecentSearche,
      PrefetchHooks Function()
    >;
typedef $$SearchCacheItemsTableCreateCompanionBuilder =
    SearchCacheItemsCompanion Function({
      required String queryKey,
      required String postUri,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$SearchCacheItemsTableUpdateCompanionBuilder =
    SearchCacheItemsCompanion Function({
      Value<String> queryKey,
      Value<String> postUri,
      Value<String> sortKey,
      Value<int> rowid,
    });

final class $$SearchCacheItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SearchCacheItemsTable, SearchCacheItem> {
  $$SearchCacheItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PostsTable _postUriTable(_$AppDatabase db) =>
      db.posts.createAlias($_aliasNameGenerator(db.searchCacheItems.postUri, db.posts.uri));

  $$PostsTableProcessedTableManager get postUri {
    final $_column = $_itemColumn<String>('post_uri')!;

    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.uri.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postUriTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SearchCacheItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SearchCacheItemsTable> {
  $$SearchCacheItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get queryKey =>
      $composableBuilder(column: $table.queryKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnFilters(column));

  $$PostsTableFilterComposer get postUri {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableFilterComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$SearchCacheItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchCacheItemsTable> {
  $$SearchCacheItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get queryKey =>
      $composableBuilder(column: $table.queryKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => ColumnOrderings(column));

  $$PostsTableOrderingComposer get postUri {
    final $$PostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableOrderingComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$SearchCacheItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchCacheItemsTable> {
  $$SearchCacheItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get queryKey =>
      $composableBuilder(column: $table.queryKey, builder: (column) => column);

  GeneratedColumn<String> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => column);

  $$PostsTableAnnotationComposer get postUri {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableAnnotationComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$SearchCacheItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchCacheItemsTable,
          SearchCacheItem,
          $$SearchCacheItemsTableFilterComposer,
          $$SearchCacheItemsTableOrderingComposer,
          $$SearchCacheItemsTableAnnotationComposer,
          $$SearchCacheItemsTableCreateCompanionBuilder,
          $$SearchCacheItemsTableUpdateCompanionBuilder,
          (SearchCacheItem, $$SearchCacheItemsTableReferences),
          SearchCacheItem,
          PrefetchHooks Function({bool postUri})
        > {
  $$SearchCacheItemsTableTableManager(_$AppDatabase db, $SearchCacheItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchCacheItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchCacheItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchCacheItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> queryKey = const Value.absent(),
                Value<String> postUri = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchCacheItemsCompanion(
                queryKey: queryKey,
                postUri: postUri,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String queryKey,
                required String postUri,
                required String sortKey,
                Value<int> rowid = const Value.absent(),
              }) => SearchCacheItemsCompanion.insert(
                queryKey: queryKey,
                postUri: postUri,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$SearchCacheItemsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({postUri = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (postUri) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.postUri,
                                referencedTable: $$SearchCacheItemsTableReferences._postUriTable(
                                  db,
                                ),
                                referencedColumn: $$SearchCacheItemsTableReferences
                                    ._postUriTable(db)
                                    .uri,
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

typedef $$SearchCacheItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchCacheItemsTable,
      SearchCacheItem,
      $$SearchCacheItemsTableFilterComposer,
      $$SearchCacheItemsTableOrderingComposer,
      $$SearchCacheItemsTableAnnotationComposer,
      $$SearchCacheItemsTableCreateCompanionBuilder,
      $$SearchCacheItemsTableUpdateCompanionBuilder,
      (SearchCacheItem, $$SearchCacheItemsTableReferences),
      SearchCacheItem,
      PrefetchHooks Function({bool postUri})
    >;
typedef $$SearchCacheCursorsTableCreateCompanionBuilder =
    SearchCacheCursorsCompanion Function({
      required String queryKey,
      required String cursor,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });
typedef $$SearchCacheCursorsTableUpdateCompanionBuilder =
    SearchCacheCursorsCompanion Function({
      Value<String> queryKey,
      Value<String> cursor,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });

class $$SearchCacheCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SearchCacheCursorsTable> {
  $$SearchCacheCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get queryKey =>
      $composableBuilder(column: $table.queryKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated =>
      $composableBuilder(column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$SearchCacheCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchCacheCursorsTable> {
  $$SearchCacheCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get queryKey =>
      $composableBuilder(column: $table.queryKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated =>
      $composableBuilder(column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$SearchCacheCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchCacheCursorsTable> {
  $$SearchCacheCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get queryKey =>
      $composableBuilder(column: $table.queryKey, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated =>
      $composableBuilder(column: $table.lastUpdated, builder: (column) => column);
}

class $$SearchCacheCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchCacheCursorsTable,
          SearchCacheCursor,
          $$SearchCacheCursorsTableFilterComposer,
          $$SearchCacheCursorsTableOrderingComposer,
          $$SearchCacheCursorsTableAnnotationComposer,
          $$SearchCacheCursorsTableCreateCompanionBuilder,
          $$SearchCacheCursorsTableUpdateCompanionBuilder,
          (
            SearchCacheCursor,
            BaseReferences<_$AppDatabase, $SearchCacheCursorsTable, SearchCacheCursor>,
          ),
          SearchCacheCursor,
          PrefetchHooks Function()
        > {
  $$SearchCacheCursorsTableTableManager(_$AppDatabase db, $SearchCacheCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchCacheCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchCacheCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchCacheCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> queryKey = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchCacheCursorsCompanion(
                queryKey: queryKey,
                cursor: cursor,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String queryKey,
                required String cursor,
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SearchCacheCursorsCompanion.insert(
                queryKey: queryKey,
                cursor: cursor,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchCacheCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchCacheCursorsTable,
      SearchCacheCursor,
      $$SearchCacheCursorsTableFilterComposer,
      $$SearchCacheCursorsTableOrderingComposer,
      $$SearchCacheCursorsTableAnnotationComposer,
      $$SearchCacheCursorsTableCreateCompanionBuilder,
      $$SearchCacheCursorsTableUpdateCompanionBuilder,
      (
        SearchCacheCursor,
        BaseReferences<_$AppDatabase, $SearchCacheCursorsTable, SearchCacheCursor>,
      ),
      SearchCacheCursor,
      PrefetchHooks Function()
    >;
typedef $$FollowsTableCreateCompanionBuilder =
    FollowsCompanion Function({
      required String actorDid,
      required String subjectDid,
      required String uri,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });
typedef $$FollowsTableUpdateCompanionBuilder =
    FollowsCompanion Function({
      Value<String> actorDid,
      Value<String> subjectDid,
      Value<String> uri,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });

class $$FollowsTableFilterComposer extends Composer<_$AppDatabase, $FollowsTable> {
  $$FollowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get actorDid =>
      $composableBuilder(column: $table.actorDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectDid =>
      $composableBuilder(column: $table.subjectDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FollowsTableOrderingComposer extends Composer<_$AppDatabase, $FollowsTable> {
  $$FollowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get actorDid =>
      $composableBuilder(column: $table.actorDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectDid =>
      $composableBuilder(column: $table.subjectDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FollowsTableAnnotationComposer extends Composer<_$AppDatabase, $FollowsTable> {
  $$FollowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get actorDid =>
      $composableBuilder(column: $table.actorDid, builder: (column) => column);

  GeneratedColumn<String> get subjectDid =>
      $composableBuilder(column: $table.subjectDid, builder: (column) => column);

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FollowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FollowsTable,
          Follow,
          $$FollowsTableFilterComposer,
          $$FollowsTableOrderingComposer,
          $$FollowsTableAnnotationComposer,
          $$FollowsTableCreateCompanionBuilder,
          $$FollowsTableUpdateCompanionBuilder,
          (Follow, BaseReferences<_$AppDatabase, $FollowsTable, Follow>),
          Follow,
          PrefetchHooks Function()
        > {
  $$FollowsTableTableManager(_$AppDatabase db, $FollowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FollowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FollowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FollowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> actorDid = const Value.absent(),
                Value<String> subjectDid = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FollowsCompanion(
                actorDid: actorDid,
                subjectDid: subjectDid,
                uri: uri,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String actorDid,
                required String subjectDid,
                required String uri,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FollowsCompanion.insert(
                actorDid: actorDid,
                subjectDid: subjectDid,
                uri: uri,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FollowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FollowsTable,
      Follow,
      $$FollowsTableFilterComposer,
      $$FollowsTableOrderingComposer,
      $$FollowsTableAnnotationComposer,
      $$FollowsTableCreateCompanionBuilder,
      $$FollowsTableUpdateCompanionBuilder,
      (Follow, BaseReferences<_$AppDatabase, $FollowsTable, Follow>),
      Follow,
      PrefetchHooks Function()
    >;
typedef $$SavedFeedsTableCreateCompanionBuilder =
    SavedFeedsCompanion Function({
      required String uri,
      required String ownerDid,
      required String displayName,
      Value<String?> description,
      Value<String?> avatar,
      required String creatorDid,
      Value<int> likeCount,
      required int sortOrder,
      Value<bool> isPinned,
      required DateTime lastSynced,
      Value<DateTime?> localUpdatedAt,
      Value<int> rowid,
    });
typedef $$SavedFeedsTableUpdateCompanionBuilder =
    SavedFeedsCompanion Function({
      Value<String> uri,
      Value<String> ownerDid,
      Value<String> displayName,
      Value<String?> description,
      Value<String?> avatar,
      Value<String> creatorDid,
      Value<int> likeCount,
      Value<int> sortOrder,
      Value<bool> isPinned,
      Value<DateTime> lastSynced,
      Value<DateTime?> localUpdatedAt,
      Value<int> rowid,
    });

final class $$SavedFeedsTableReferences
    extends BaseReferences<_$AppDatabase, $SavedFeedsTable, SavedFeed> {
  $$SavedFeedsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _creatorDidTable(_$AppDatabase db) =>
      db.profiles.createAlias($_aliasNameGenerator(db.savedFeeds.creatorDid, db.profiles.did));

  $$ProfilesTableProcessedTableManager get creatorDid {
    final $_column = $_itemColumn<String>('creator_did')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.did.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_creatorDidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SavedFeedsTableFilterComposer extends Composer<_$AppDatabase, $SavedFeedsTable> {
  $$SavedFeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSynced =>
      $composableBuilder(column: $table.lastSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get creatorDid {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creatorDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableFilterComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$SavedFeedsTableOrderingComposer extends Composer<_$AppDatabase, $SavedFeedsTable> {
  $$SavedFeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSynced =>
      $composableBuilder(column: $table.lastSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
    column: $table.localUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get creatorDid {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creatorDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableOrderingComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$SavedFeedsTableAnnotationComposer extends Composer<_$AppDatabase, $SavedFeedsTable> {
  $$SavedFeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSynced =>
      $composableBuilder(column: $table.lastSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt =>
      $composableBuilder(column: $table.localUpdatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get creatorDid {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creatorDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$SavedFeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedFeedsTable,
          SavedFeed,
          $$SavedFeedsTableFilterComposer,
          $$SavedFeedsTableOrderingComposer,
          $$SavedFeedsTableAnnotationComposer,
          $$SavedFeedsTableCreateCompanionBuilder,
          $$SavedFeedsTableUpdateCompanionBuilder,
          (SavedFeed, $$SavedFeedsTableReferences),
          SavedFeed,
          PrefetchHooks Function({bool creatorDid})
        > {
  $$SavedFeedsTableTableManager(_$AppDatabase db, $SavedFeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SavedFeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SavedFeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedFeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uri = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String> creatorDid = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<DateTime> lastSynced = const Value.absent(),
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedFeedsCompanion(
                uri: uri,
                ownerDid: ownerDid,
                displayName: displayName,
                description: description,
                avatar: avatar,
                creatorDid: creatorDid,
                likeCount: likeCount,
                sortOrder: sortOrder,
                isPinned: isPinned,
                lastSynced: lastSynced,
                localUpdatedAt: localUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uri,
                required String ownerDid,
                required String displayName,
                Value<String?> description = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                required String creatorDid,
                Value<int> likeCount = const Value.absent(),
                required int sortOrder,
                Value<bool> isPinned = const Value.absent(),
                required DateTime lastSynced,
                Value<DateTime?> localUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedFeedsCompanion.insert(
                uri: uri,
                ownerDid: ownerDid,
                displayName: displayName,
                description: description,
                avatar: avatar,
                creatorDid: creatorDid,
                likeCount: likeCount,
                sortOrder: sortOrder,
                isPinned: isPinned,
                lastSynced: lastSynced,
                localUpdatedAt: localUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$SavedFeedsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({creatorDid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (creatorDid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.creatorDid,
                                referencedTable: $$SavedFeedsTableReferences._creatorDidTable(db),
                                referencedColumn: $$SavedFeedsTableReferences
                                    ._creatorDidTable(db)
                                    .did,
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

typedef $$SavedFeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedFeedsTable,
      SavedFeed,
      $$SavedFeedsTableFilterComposer,
      $$SavedFeedsTableOrderingComposer,
      $$SavedFeedsTableAnnotationComposer,
      $$SavedFeedsTableCreateCompanionBuilder,
      $$SavedFeedsTableUpdateCompanionBuilder,
      (SavedFeed, $$SavedFeedsTableReferences),
      SavedFeed,
      PrefetchHooks Function({bool creatorDid})
    >;
typedef $$PreferenceSyncQueueTableCreateCompanionBuilder =
    PreferenceSyncQueueCompanion Function({
      Value<int> id,
      required String ownerDid,
      Value<String> category,
      required String type,
      required String payload,
      required DateTime createdAt,
      Value<int> retryCount,
    });
typedef $$PreferenceSyncQueueTableUpdateCompanionBuilder =
    PreferenceSyncQueueCompanion Function({
      Value<int> id,
      Value<String> ownerDid,
      Value<String> category,
      Value<String> type,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });

class $$PreferenceSyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $PreferenceSyncQueueTable> {
  $$PreferenceSyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => ColumnFilters(column));
}

class $$PreferenceSyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferenceSyncQueueTable> {
  $$PreferenceSyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => ColumnOrderings(column));
}

class $$PreferenceSyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferenceSyncQueueTable> {
  $$PreferenceSyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => column);
}

class $$PreferenceSyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferenceSyncQueueTable,
          PreferenceSyncQueueData,
          $$PreferenceSyncQueueTableFilterComposer,
          $$PreferenceSyncQueueTableOrderingComposer,
          $$PreferenceSyncQueueTableAnnotationComposer,
          $$PreferenceSyncQueueTableCreateCompanionBuilder,
          $$PreferenceSyncQueueTableUpdateCompanionBuilder,
          (
            PreferenceSyncQueueData,
            BaseReferences<_$AppDatabase, $PreferenceSyncQueueTable, PreferenceSyncQueueData>,
          ),
          PreferenceSyncQueueData,
          PrefetchHooks Function()
        > {
  $$PreferenceSyncQueueTableTableManager(_$AppDatabase db, $PreferenceSyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenceSyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenceSyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenceSyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => PreferenceSyncQueueCompanion(
                id: id,
                ownerDid: ownerDid,
                category: category,
                type: type,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ownerDid,
                Value<String> category = const Value.absent(),
                required String type,
                required String payload,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
              }) => PreferenceSyncQueueCompanion.insert(
                id: id,
                ownerDid: ownerDid,
                category: category,
                type: type,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferenceSyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferenceSyncQueueTable,
      PreferenceSyncQueueData,
      $$PreferenceSyncQueueTableFilterComposer,
      $$PreferenceSyncQueueTableOrderingComposer,
      $$PreferenceSyncQueueTableAnnotationComposer,
      $$PreferenceSyncQueueTableCreateCompanionBuilder,
      $$PreferenceSyncQueueTableUpdateCompanionBuilder,
      (
        PreferenceSyncQueueData,
        BaseReferences<_$AppDatabase, $PreferenceSyncQueueTable, PreferenceSyncQueueData>,
      ),
      PreferenceSyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$DraftsTableCreateCompanionBuilder =
    DraftsCompanion Function({
      required String id,
      Value<String> content,
      Value<String?> replyParentUri,
      Value<String?> replyParentCid,
      Value<String?> replyRootUri,
      Value<String?> replyRootCid,
      Value<String?> quoteUri,
      Value<String?> quoteCid,
      Value<String?> facetsJson,
      Value<String?> externalUri,
      Value<String?> externalTitle,
      Value<String?> externalDescription,
      Value<String?> externalThumbBlobJson,
      required String status,
      Value<String?> errorMessage,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DraftsTableUpdateCompanionBuilder =
    DraftsCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<String?> replyParentUri,
      Value<String?> replyParentCid,
      Value<String?> replyRootUri,
      Value<String?> replyRootCid,
      Value<String?> quoteUri,
      Value<String?> quoteCid,
      Value<String?> facetsJson,
      Value<String?> externalUri,
      Value<String?> externalTitle,
      Value<String?> externalDescription,
      Value<String?> externalThumbBlobJson,
      Value<String> status,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DraftsTableReferences extends BaseReferences<_$AppDatabase, $DraftsTable, Draft> {
  $$DraftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DraftMediaTable, List<DraftMediaData>> _draftMediaRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.draftMedia,
    aliasName: $_aliasNameGenerator(db.drafts.id, db.draftMedia.draftId),
  );

  $$DraftMediaTableProcessedTableManager get draftMediaRefs {
    final manager = $$DraftMediaTableTableManager(
      $_db,
      $_db.draftMedia,
    ).filter((f) => f.draftId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_draftMediaRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DraftsTableFilterComposer extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyParentUri => $composableBuilder(
    column: $table.replyParentUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyParentCid => $composableBuilder(
    column: $table.replyParentCid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyRootUri =>
      $composableBuilder(column: $table.replyRootUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyRootCid =>
      $composableBuilder(column: $table.replyRootCid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quoteUri =>
      $composableBuilder(column: $table.quoteUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quoteCid =>
      $composableBuilder(column: $table.quoteCid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get facetsJson =>
      $composableBuilder(column: $table.facetsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalUri =>
      $composableBuilder(column: $table.externalUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalTitle =>
      $composableBuilder(column: $table.externalTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalDescription => $composableBuilder(
    column: $table.externalDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalThumbBlobJson => $composableBuilder(
    column: $table.externalThumbBlobJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage =>
      $composableBuilder(column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> draftMediaRefs(Expression<bool> Function($$DraftMediaTableFilterComposer f) f) {
    final $$DraftMediaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draftMedia,
      getReferencedColumn: (t) => t.draftId,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$DraftMediaTableFilterComposer(
                $db: $db,
                $table: $db.draftMedia,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }
}

class $$DraftsTableOrderingComposer extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyParentUri => $composableBuilder(
    column: $table.replyParentUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyParentCid => $composableBuilder(
    column: $table.replyParentCid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyRootUri => $composableBuilder(
    column: $table.replyRootUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyRootCid => $composableBuilder(
    column: $table.replyRootCid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteUri =>
      $composableBuilder(column: $table.quoteUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quoteCid =>
      $composableBuilder(column: $table.quoteCid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get facetsJson =>
      $composableBuilder(column: $table.facetsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalUri =>
      $composableBuilder(column: $table.externalUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalTitle => $composableBuilder(
    column: $table.externalTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalDescription => $composableBuilder(
    column: $table.externalDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalThumbBlobJson => $composableBuilder(
    column: $table.externalThumbBlobJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DraftsTableAnnotationComposer extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get replyParentUri =>
      $composableBuilder(column: $table.replyParentUri, builder: (column) => column);

  GeneratedColumn<String> get replyParentCid =>
      $composableBuilder(column: $table.replyParentCid, builder: (column) => column);

  GeneratedColumn<String> get replyRootUri =>
      $composableBuilder(column: $table.replyRootUri, builder: (column) => column);

  GeneratedColumn<String> get replyRootCid =>
      $composableBuilder(column: $table.replyRootCid, builder: (column) => column);

  GeneratedColumn<String> get quoteUri =>
      $composableBuilder(column: $table.quoteUri, builder: (column) => column);

  GeneratedColumn<String> get quoteCid =>
      $composableBuilder(column: $table.quoteCid, builder: (column) => column);

  GeneratedColumn<String> get facetsJson =>
      $composableBuilder(column: $table.facetsJson, builder: (column) => column);

  GeneratedColumn<String> get externalUri =>
      $composableBuilder(column: $table.externalUri, builder: (column) => column);

  GeneratedColumn<String> get externalTitle =>
      $composableBuilder(column: $table.externalTitle, builder: (column) => column);

  GeneratedColumn<String> get externalDescription =>
      $composableBuilder(column: $table.externalDescription, builder: (column) => column);

  GeneratedColumn<String> get externalThumbBlobJson =>
      $composableBuilder(column: $table.externalThumbBlobJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage =>
      $composableBuilder(column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> draftMediaRefs<T extends Object>(
    Expression<T> Function($$DraftMediaTableAnnotationComposer a) f,
  ) {
    final $$DraftMediaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.draftMedia,
      getReferencedColumn: (t) => t.draftId,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$DraftMediaTableAnnotationComposer(
                $db: $db,
                $table: $db.draftMedia,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }
}

class $$DraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftsTable,
          Draft,
          $$DraftsTableFilterComposer,
          $$DraftsTableOrderingComposer,
          $$DraftsTableAnnotationComposer,
          $$DraftsTableCreateCompanionBuilder,
          $$DraftsTableUpdateCompanionBuilder,
          (Draft, $$DraftsTableReferences),
          Draft,
          PrefetchHooks Function({bool draftMediaRefs})
        > {
  $$DraftsTableTableManager(_$AppDatabase db, $DraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> replyParentUri = const Value.absent(),
                Value<String?> replyParentCid = const Value.absent(),
                Value<String?> replyRootUri = const Value.absent(),
                Value<String?> replyRootCid = const Value.absent(),
                Value<String?> quoteUri = const Value.absent(),
                Value<String?> quoteCid = const Value.absent(),
                Value<String?> facetsJson = const Value.absent(),
                Value<String?> externalUri = const Value.absent(),
                Value<String?> externalTitle = const Value.absent(),
                Value<String?> externalDescription = const Value.absent(),
                Value<String?> externalThumbBlobJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion(
                id: id,
                content: content,
                replyParentUri: replyParentUri,
                replyParentCid: replyParentCid,
                replyRootUri: replyRootUri,
                replyRootCid: replyRootCid,
                quoteUri: quoteUri,
                quoteCid: quoteCid,
                facetsJson: facetsJson,
                externalUri: externalUri,
                externalTitle: externalTitle,
                externalDescription: externalDescription,
                externalThumbBlobJson: externalThumbBlobJson,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> content = const Value.absent(),
                Value<String?> replyParentUri = const Value.absent(),
                Value<String?> replyParentCid = const Value.absent(),
                Value<String?> replyRootUri = const Value.absent(),
                Value<String?> replyRootCid = const Value.absent(),
                Value<String?> quoteUri = const Value.absent(),
                Value<String?> quoteCid = const Value.absent(),
                Value<String?> facetsJson = const Value.absent(),
                Value<String?> externalUri = const Value.absent(),
                Value<String?> externalTitle = const Value.absent(),
                Value<String?> externalDescription = const Value.absent(),
                Value<String?> externalThumbBlobJson = const Value.absent(),
                required String status,
                Value<String?> errorMessage = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion.insert(
                id: id,
                content: content,
                replyParentUri: replyParentUri,
                replyParentCid: replyParentCid,
                replyRootUri: replyRootUri,
                replyRootCid: replyRootCid,
                quoteUri: quoteUri,
                quoteCid: quoteCid,
                facetsJson: facetsJson,
                externalUri: externalUri,
                externalTitle: externalTitle,
                externalDescription: externalDescription,
                externalThumbBlobJson: externalThumbBlobJson,
                status: status,
                errorMessage: errorMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$DraftsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({draftMediaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (draftMediaRefs) db.draftMedia],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (draftMediaRefs)
                    await $_getPrefetchedData<Draft, $DraftsTable, DraftMediaData>(
                      currentTable: table,
                      referencedTable: $$DraftsTableReferences._draftMediaRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DraftsTableReferences(db, table, p0).draftMediaRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.draftId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftsTable,
      Draft,
      $$DraftsTableFilterComposer,
      $$DraftsTableOrderingComposer,
      $$DraftsTableAnnotationComposer,
      $$DraftsTableCreateCompanionBuilder,
      $$DraftsTableUpdateCompanionBuilder,
      (Draft, $$DraftsTableReferences),
      Draft,
      PrefetchHooks Function({bool draftMediaRefs})
    >;
typedef $$DraftMediaTableCreateCompanionBuilder =
    DraftMediaCompanion Function({
      Value<int> id,
      required String draftId,
      required String localPath,
      required String mimeType,
      Value<String?> altText,
      Value<String?> uploadCid,
      Value<String?> blobRefJson,
      required String status,
      required int sortOrder,
      required DateTime createdAt,
    });
typedef $$DraftMediaTableUpdateCompanionBuilder =
    DraftMediaCompanion Function({
      Value<int> id,
      Value<String> draftId,
      Value<String> localPath,
      Value<String> mimeType,
      Value<String?> altText,
      Value<String?> uploadCid,
      Value<String?> blobRefJson,
      Value<String> status,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });

final class $$DraftMediaTableReferences
    extends BaseReferences<_$AppDatabase, $DraftMediaTable, DraftMediaData> {
  $$DraftMediaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DraftsTable _draftIdTable(_$AppDatabase db) =>
      db.drafts.createAlias($_aliasNameGenerator(db.draftMedia.draftId, db.drafts.id));

  $$DraftsTableProcessedTableManager get draftId {
    final $_column = $_itemColumn<String>('draft_id')!;

    final manager = $$DraftsTableTableManager(
      $_db,
      $_db.drafts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_draftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DraftMediaTableFilterComposer extends Composer<_$AppDatabase, $DraftMediaTable> {
  $$DraftMediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get altText =>
      $composableBuilder(column: $table.altText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadCid =>
      $composableBuilder(column: $table.uploadCid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blobRefJson =>
      $composableBuilder(column: $table.blobRefJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$DraftsTableFilterComposer get draftId {
    final $$DraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.draftId,
      referencedTable: $db.drafts,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$DraftsTableFilterComposer(
                $db: $db,
                $table: $db.drafts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$DraftMediaTableOrderingComposer extends Composer<_$AppDatabase, $DraftMediaTable> {
  $$DraftMediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get altText =>
      $composableBuilder(column: $table.altText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadCid =>
      $composableBuilder(column: $table.uploadCid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blobRefJson =>
      $composableBuilder(column: $table.blobRefJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$DraftsTableOrderingComposer get draftId {
    final $$DraftsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.draftId,
      referencedTable: $db.drafts,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$DraftsTableOrderingComposer(
                $db: $db,
                $table: $db.drafts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$DraftMediaTableAnnotationComposer extends Composer<_$AppDatabase, $DraftMediaTable> {
  $$DraftMediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get altText =>
      $composableBuilder(column: $table.altText, builder: (column) => column);

  GeneratedColumn<String> get uploadCid =>
      $composableBuilder(column: $table.uploadCid, builder: (column) => column);

  GeneratedColumn<String> get blobRefJson =>
      $composableBuilder(column: $table.blobRefJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DraftsTableAnnotationComposer get draftId {
    final $$DraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.draftId,
      referencedTable: $db.drafts,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$DraftsTableAnnotationComposer(
                $db: $db,
                $table: $db.drafts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$DraftMediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftMediaTable,
          DraftMediaData,
          $$DraftMediaTableFilterComposer,
          $$DraftMediaTableOrderingComposer,
          $$DraftMediaTableAnnotationComposer,
          $$DraftMediaTableCreateCompanionBuilder,
          $$DraftMediaTableUpdateCompanionBuilder,
          (DraftMediaData, $$DraftMediaTableReferences),
          DraftMediaData,
          PrefetchHooks Function({bool draftId})
        > {
  $$DraftMediaTableTableManager(_$AppDatabase db, $DraftMediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DraftMediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DraftMediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftMediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> draftId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<String?> altText = const Value.absent(),
                Value<String?> uploadCid = const Value.absent(),
                Value<String?> blobRefJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DraftMediaCompanion(
                id: id,
                draftId: draftId,
                localPath: localPath,
                mimeType: mimeType,
                altText: altText,
                uploadCid: uploadCid,
                blobRefJson: blobRefJson,
                status: status,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String draftId,
                required String localPath,
                required String mimeType,
                Value<String?> altText = const Value.absent(),
                Value<String?> uploadCid = const Value.absent(),
                Value<String?> blobRefJson = const Value.absent(),
                required String status,
                required int sortOrder,
                required DateTime createdAt,
              }) => DraftMediaCompanion.insert(
                id: id,
                draftId: draftId,
                localPath: localPath,
                mimeType: mimeType,
                altText: altText,
                uploadCid: uploadCid,
                blobRefJson: blobRefJson,
                status: status,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$DraftMediaTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({draftId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (draftId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.draftId,
                                referencedTable: $$DraftMediaTableReferences._draftIdTable(db),
                                referencedColumn: $$DraftMediaTableReferences._draftIdTable(db).id,
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

typedef $$DraftMediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftMediaTable,
      DraftMediaData,
      $$DraftMediaTableFilterComposer,
      $$DraftMediaTableOrderingComposer,
      $$DraftMediaTableAnnotationComposer,
      $$DraftMediaTableCreateCompanionBuilder,
      $$DraftMediaTableUpdateCompanionBuilder,
      (DraftMediaData, $$DraftMediaTableReferences),
      DraftMediaData,
      PrefetchHooks Function({bool draftId})
    >;
typedef $$ProfileRelationshipsTableCreateCompanionBuilder =
    ProfileRelationshipsCompanion Function({
      required String ownerDid,
      required String profileDid,
      Value<bool> following,
      Value<String?> followingUri,
      Value<bool> followedBy,
      Value<bool> muted,
      Value<bool> blocked,
      Value<bool> blockedBy,
      Value<String?> blockingUri,
      Value<String?> mutedByList,
      Value<String?> blockingByList,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProfileRelationshipsTableUpdateCompanionBuilder =
    ProfileRelationshipsCompanion Function({
      Value<String> ownerDid,
      Value<String> profileDid,
      Value<bool> following,
      Value<String?> followingUri,
      Value<bool> followedBy,
      Value<bool> muted,
      Value<bool> blocked,
      Value<bool> blockedBy,
      Value<String?> blockingUri,
      Value<String?> mutedByList,
      Value<String?> blockingByList,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProfileRelationshipsTableReferences
    extends BaseReferences<_$AppDatabase, $ProfileRelationshipsTable, ProfileRelationship> {
  $$ProfileRelationshipsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileDidTable(_$AppDatabase db) => db.profiles.createAlias(
    $_aliasNameGenerator(db.profileRelationships.profileDid, db.profiles.did),
  );

  $$ProfilesTableProcessedTableManager get profileDid {
    final $_column = $_itemColumn<String>('profile_did')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.did.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileDidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProfileRelationshipsTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileRelationshipsTable> {
  $$ProfileRelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get following =>
      $composableBuilder(column: $table.following, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get followingUri =>
      $composableBuilder(column: $table.followingUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get followedBy =>
      $composableBuilder(column: $table.followedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get blocked =>
      $composableBuilder(column: $table.blocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get blockedBy =>
      $composableBuilder(column: $table.blockedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blockingUri =>
      $composableBuilder(column: $table.blockingUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mutedByList =>
      $composableBuilder(column: $table.mutedByList, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blockingByList => $composableBuilder(
    column: $table.blockingByList,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileDid {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableFilterComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$ProfileRelationshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileRelationshipsTable> {
  $$ProfileRelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get following =>
      $composableBuilder(column: $table.following, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get followingUri => $composableBuilder(
    column: $table.followingUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get followedBy =>
      $composableBuilder(column: $table.followedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get blocked =>
      $composableBuilder(column: $table.blocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get blockedBy =>
      $composableBuilder(column: $table.blockedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blockingUri =>
      $composableBuilder(column: $table.blockingUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mutedByList =>
      $composableBuilder(column: $table.mutedByList, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blockingByList => $composableBuilder(
    column: $table.blockingByList,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileDid {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableOrderingComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$ProfileRelationshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileRelationshipsTable> {
  $$ProfileRelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<bool> get following =>
      $composableBuilder(column: $table.following, builder: (column) => column);

  GeneratedColumn<String> get followingUri =>
      $composableBuilder(column: $table.followingUri, builder: (column) => column);

  GeneratedColumn<bool> get followedBy =>
      $composableBuilder(column: $table.followedBy, builder: (column) => column);

  GeneratedColumn<bool> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  GeneratedColumn<bool> get blocked =>
      $composableBuilder(column: $table.blocked, builder: (column) => column);

  GeneratedColumn<bool> get blockedBy =>
      $composableBuilder(column: $table.blockedBy, builder: (column) => column);

  GeneratedColumn<String> get blockingUri =>
      $composableBuilder(column: $table.blockingUri, builder: (column) => column);

  GeneratedColumn<String> get mutedByList =>
      $composableBuilder(column: $table.mutedByList, builder: (column) => column);

  GeneratedColumn<String> get blockingByList =>
      $composableBuilder(column: $table.blockingByList, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileDid {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$ProfileRelationshipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileRelationshipsTable,
          ProfileRelationship,
          $$ProfileRelationshipsTableFilterComposer,
          $$ProfileRelationshipsTableOrderingComposer,
          $$ProfileRelationshipsTableAnnotationComposer,
          $$ProfileRelationshipsTableCreateCompanionBuilder,
          $$ProfileRelationshipsTableUpdateCompanionBuilder,
          (ProfileRelationship, $$ProfileRelationshipsTableReferences),
          ProfileRelationship,
          PrefetchHooks Function({bool profileDid})
        > {
  $$ProfileRelationshipsTableTableManager(_$AppDatabase db, $ProfileRelationshipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileRelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileRelationshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileRelationshipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerDid = const Value.absent(),
                Value<String> profileDid = const Value.absent(),
                Value<bool> following = const Value.absent(),
                Value<String?> followingUri = const Value.absent(),
                Value<bool> followedBy = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<bool> blocked = const Value.absent(),
                Value<bool> blockedBy = const Value.absent(),
                Value<String?> blockingUri = const Value.absent(),
                Value<String?> mutedByList = const Value.absent(),
                Value<String?> blockingByList = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileRelationshipsCompanion(
                ownerDid: ownerDid,
                profileDid: profileDid,
                following: following,
                followingUri: followingUri,
                followedBy: followedBy,
                muted: muted,
                blocked: blocked,
                blockedBy: blockedBy,
                blockingUri: blockingUri,
                mutedByList: mutedByList,
                blockingByList: blockingByList,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerDid,
                required String profileDid,
                Value<bool> following = const Value.absent(),
                Value<String?> followingUri = const Value.absent(),
                Value<bool> followedBy = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<bool> blocked = const Value.absent(),
                Value<bool> blockedBy = const Value.absent(),
                Value<String?> blockingUri = const Value.absent(),
                Value<String?> mutedByList = const Value.absent(),
                Value<String?> blockingByList = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProfileRelationshipsCompanion.insert(
                ownerDid: ownerDid,
                profileDid: profileDid,
                following: following,
                followingUri: followingUri,
                followedBy: followedBy,
                muted: muted,
                blocked: blocked,
                blockedBy: blockedBy,
                blockingUri: blockingUri,
                mutedByList: mutedByList,
                blockingByList: blockingByList,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), $$ProfileRelationshipsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({profileDid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (profileDid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileDid,
                                referencedTable: $$ProfileRelationshipsTableReferences
                                    ._profileDidTable(db),
                                referencedColumn: $$ProfileRelationshipsTableReferences
                                    ._profileDidTable(db)
                                    .did,
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

typedef $$ProfileRelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileRelationshipsTable,
      ProfileRelationship,
      $$ProfileRelationshipsTableFilterComposer,
      $$ProfileRelationshipsTableOrderingComposer,
      $$ProfileRelationshipsTableAnnotationComposer,
      $$ProfileRelationshipsTableCreateCompanionBuilder,
      $$ProfileRelationshipsTableUpdateCompanionBuilder,
      (ProfileRelationship, $$ProfileRelationshipsTableReferences),
      ProfileRelationship,
      PrefetchHooks Function({bool profileDid})
    >;
typedef $$PostInteractionsTableCreateCompanionBuilder =
    PostInteractionsCompanion Function({
      required String postUri,
      Value<String?> likeUri,
      Value<String?> repostUri,
      Value<bool> bookmarked,
      Value<bool> threadMuted,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PostInteractionsTableUpdateCompanionBuilder =
    PostInteractionsCompanion Function({
      Value<String> postUri,
      Value<String?> likeUri,
      Value<String?> repostUri,
      Value<bool> bookmarked,
      Value<bool> threadMuted,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PostInteractionsTableReferences
    extends BaseReferences<_$AppDatabase, $PostInteractionsTable, PostInteraction> {
  $$PostInteractionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PostsTable _postUriTable(_$AppDatabase db) =>
      db.posts.createAlias($_aliasNameGenerator(db.postInteractions.postUri, db.posts.uri));

  $$PostsTableProcessedTableManager get postUri {
    final $_column = $_itemColumn<String>('post_uri')!;

    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.uri.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postUriTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PostInteractionsTableFilterComposer
    extends Composer<_$AppDatabase, $PostInteractionsTable> {
  $$PostInteractionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get likeUri =>
      $composableBuilder(column: $table.likeUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repostUri =>
      $composableBuilder(column: $table.repostUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get bookmarked =>
      $composableBuilder(column: $table.bookmarked, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get threadMuted =>
      $composableBuilder(column: $table.threadMuted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$PostsTableFilterComposer get postUri {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableFilterComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$PostInteractionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostInteractionsTable> {
  $$PostInteractionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get likeUri =>
      $composableBuilder(column: $table.likeUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repostUri =>
      $composableBuilder(column: $table.repostUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get bookmarked =>
      $composableBuilder(column: $table.bookmarked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get threadMuted =>
      $composableBuilder(column: $table.threadMuted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$PostsTableOrderingComposer get postUri {
    final $$PostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableOrderingComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$PostInteractionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostInteractionsTable> {
  $$PostInteractionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get likeUri =>
      $composableBuilder(column: $table.likeUri, builder: (column) => column);

  GeneratedColumn<String> get repostUri =>
      $composableBuilder(column: $table.repostUri, builder: (column) => column);

  GeneratedColumn<bool> get bookmarked =>
      $composableBuilder(column: $table.bookmarked, builder: (column) => column);

  GeneratedColumn<bool> get threadMuted =>
      $composableBuilder(column: $table.threadMuted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PostsTableAnnotationComposer get postUri {
    final $$PostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$PostsTableAnnotationComposer(
                $db: $db,
                $table: $db.posts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$PostInteractionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostInteractionsTable,
          PostInteraction,
          $$PostInteractionsTableFilterComposer,
          $$PostInteractionsTableOrderingComposer,
          $$PostInteractionsTableAnnotationComposer,
          $$PostInteractionsTableCreateCompanionBuilder,
          $$PostInteractionsTableUpdateCompanionBuilder,
          (PostInteraction, $$PostInteractionsTableReferences),
          PostInteraction,
          PrefetchHooks Function({bool postUri})
        > {
  $$PostInteractionsTableTableManager(_$AppDatabase db, $PostInteractionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostInteractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostInteractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostInteractionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> postUri = const Value.absent(),
                Value<String?> likeUri = const Value.absent(),
                Value<String?> repostUri = const Value.absent(),
                Value<bool> bookmarked = const Value.absent(),
                Value<bool> threadMuted = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostInteractionsCompanion(
                postUri: postUri,
                likeUri: likeUri,
                repostUri: repostUri,
                bookmarked: bookmarked,
                threadMuted: threadMuted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String postUri,
                Value<String?> likeUri = const Value.absent(),
                Value<String?> repostUri = const Value.absent(),
                Value<bool> bookmarked = const Value.absent(),
                Value<bool> threadMuted = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PostInteractionsCompanion.insert(
                postUri: postUri,
                likeUri: likeUri,
                repostUri: repostUri,
                bookmarked: bookmarked,
                threadMuted: threadMuted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$PostInteractionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({postUri = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (postUri) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.postUri,
                                referencedTable: $$PostInteractionsTableReferences._postUriTable(
                                  db,
                                ),
                                referencedColumn: $$PostInteractionsTableReferences
                                    ._postUriTable(db)
                                    .uri,
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

typedef $$PostInteractionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostInteractionsTable,
      PostInteraction,
      $$PostInteractionsTableFilterComposer,
      $$PostInteractionsTableOrderingComposer,
      $$PostInteractionsTableAnnotationComposer,
      $$PostInteractionsTableCreateCompanionBuilder,
      $$PostInteractionsTableUpdateCompanionBuilder,
      (PostInteraction, $$PostInteractionsTableReferences),
      PostInteraction,
      PrefetchHooks Function({bool postUri})
    >;
typedef $$LocalSettingsTableCreateCompanionBuilder =
    LocalSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalSettingsTableUpdateCompanionBuilder =
    LocalSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalSettingsTableFilterComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalSettingsTableOrderingComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalSettingsTableAnnotationComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableAnnotationComposer({
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

class $$LocalSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSettingsTable,
          LocalSetting,
          $$LocalSettingsTableFilterComposer,
          $$LocalSettingsTableOrderingComposer,
          $$LocalSettingsTableAnnotationComposer,
          $$LocalSettingsTableCreateCompanionBuilder,
          $$LocalSettingsTableUpdateCompanionBuilder,
          (LocalSetting, BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>),
          LocalSetting,
          PrefetchHooks Function()
        > {
  $$LocalSettingsTableTableManager(_$AppDatabase db, $LocalSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSettingsTable,
      LocalSetting,
      $$LocalSettingsTableFilterComposer,
      $$LocalSettingsTableOrderingComposer,
      $$LocalSettingsTableAnnotationComposer,
      $$LocalSettingsTableCreateCompanionBuilder,
      $$LocalSettingsTableUpdateCompanionBuilder,
      (LocalSetting, BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>),
      LocalSetting,
      PrefetchHooks Function()
    >;
typedef $$BlueskyPreferencesTableCreateCompanionBuilder =
    BlueskyPreferencesCompanion Function({
      required String type,
      required String ownerDid,
      required String data,
      required DateTime lastSynced,
      Value<int> rowid,
    });
typedef $$BlueskyPreferencesTableUpdateCompanionBuilder =
    BlueskyPreferencesCompanion Function({
      Value<String> type,
      Value<String> ownerDid,
      Value<String> data,
      Value<DateTime> lastSynced,
      Value<int> rowid,
    });

class $$BlueskyPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $BlueskyPreferencesTable> {
  $$BlueskyPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSynced =>
      $composableBuilder(column: $table.lastSynced, builder: (column) => ColumnFilters(column));
}

class $$BlueskyPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $BlueskyPreferencesTable> {
  $$BlueskyPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSynced =>
      $composableBuilder(column: $table.lastSynced, builder: (column) => ColumnOrderings(column));
}

class $$BlueskyPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BlueskyPreferencesTable> {
  $$BlueskyPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSynced =>
      $composableBuilder(column: $table.lastSynced, builder: (column) => column);
}

class $$BlueskyPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BlueskyPreferencesTable,
          BlueskyPreference,
          $$BlueskyPreferencesTableFilterComposer,
          $$BlueskyPreferencesTableOrderingComposer,
          $$BlueskyPreferencesTableAnnotationComposer,
          $$BlueskyPreferencesTableCreateCompanionBuilder,
          $$BlueskyPreferencesTableUpdateCompanionBuilder,
          (
            BlueskyPreference,
            BaseReferences<_$AppDatabase, $BlueskyPreferencesTable, BlueskyPreference>,
          ),
          BlueskyPreference,
          PrefetchHooks Function()
        > {
  $$BlueskyPreferencesTableTableManager(_$AppDatabase db, $BlueskyPreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlueskyPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlueskyPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlueskyPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> type = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> lastSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BlueskyPreferencesCompanion(
                type: type,
                ownerDid: ownerDid,
                data: data,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String type,
                required String ownerDid,
                required String data,
                required DateTime lastSynced,
                Value<int> rowid = const Value.absent(),
              }) => BlueskyPreferencesCompanion.insert(
                type: type,
                ownerDid: ownerDid,
                data: data,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BlueskyPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BlueskyPreferencesTable,
      BlueskyPreference,
      $$BlueskyPreferencesTableFilterComposer,
      $$BlueskyPreferencesTableOrderingComposer,
      $$BlueskyPreferencesTableAnnotationComposer,
      $$BlueskyPreferencesTableCreateCompanionBuilder,
      $$BlueskyPreferencesTableUpdateCompanionBuilder,
      (
        BlueskyPreference,
        BaseReferences<_$AppDatabase, $BlueskyPreferencesTable, BlueskyPreference>,
      ),
      BlueskyPreference,
      PrefetchHooks Function()
    >;
typedef $$CustomThemesTableCreateCompanionBuilder =
    CustomThemesCompanion Function({
      required String id,
      required String name,
      required String basePackId,
      required String overridesJson,
      Value<String> typographyScale,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CustomThemesTableUpdateCompanionBuilder =
    CustomThemesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> basePackId,
      Value<String> overridesJson,
      Value<String> typographyScale,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CustomThemesTableFilterComposer extends Composer<_$AppDatabase, $CustomThemesTable> {
  $$CustomThemesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get basePackId =>
      $composableBuilder(column: $table.basePackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get overridesJson =>
      $composableBuilder(column: $table.overridesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typographyScale => $composableBuilder(
    column: $table.typographyScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CustomThemesTableOrderingComposer extends Composer<_$AppDatabase, $CustomThemesTable> {
  $$CustomThemesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get basePackId =>
      $composableBuilder(column: $table.basePackId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get overridesJson => $composableBuilder(
    column: $table.overridesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typographyScale => $composableBuilder(
    column: $table.typographyScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomThemesTableAnnotationComposer extends Composer<_$AppDatabase, $CustomThemesTable> {
  $$CustomThemesTableAnnotationComposer({
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

  GeneratedColumn<String> get basePackId =>
      $composableBuilder(column: $table.basePackId, builder: (column) => column);

  GeneratedColumn<String> get overridesJson =>
      $composableBuilder(column: $table.overridesJson, builder: (column) => column);

  GeneratedColumn<String> get typographyScale =>
      $composableBuilder(column: $table.typographyScale, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomThemesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomThemesTable,
          CustomTheme,
          $$CustomThemesTableFilterComposer,
          $$CustomThemesTableOrderingComposer,
          $$CustomThemesTableAnnotationComposer,
          $$CustomThemesTableCreateCompanionBuilder,
          $$CustomThemesTableUpdateCompanionBuilder,
          (CustomTheme, BaseReferences<_$AppDatabase, $CustomThemesTable, CustomTheme>),
          CustomTheme,
          PrefetchHooks Function()
        > {
  $$CustomThemesTableTableManager(_$AppDatabase db, $CustomThemesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CustomThemesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomThemesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomThemesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> basePackId = const Value.absent(),
                Value<String> overridesJson = const Value.absent(),
                Value<String> typographyScale = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomThemesCompanion(
                id: id,
                name: name,
                basePackId: basePackId,
                overridesJson: overridesJson,
                typographyScale: typographyScale,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String basePackId,
                required String overridesJson,
                Value<String> typographyScale = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomThemesCompanion.insert(
                id: id,
                name: name,
                basePackId: basePackId,
                overridesJson: overridesJson,
                typographyScale: typographyScale,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomThemesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomThemesTable,
      CustomTheme,
      $$CustomThemesTableFilterComposer,
      $$CustomThemesTableOrderingComposer,
      $$CustomThemesTableAnnotationComposer,
      $$CustomThemesTableCreateCompanionBuilder,
      $$CustomThemesTableUpdateCompanionBuilder,
      (CustomTheme, BaseReferences<_$AppDatabase, $CustomThemesTable, CustomTheme>),
      CustomTheme,
      PrefetchHooks Function()
    >;
typedef $$AnimationPreferencesTableTableCreateCompanionBuilder =
    AnimationPreferencesTableCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AnimationPreferencesTableTableUpdateCompanionBuilder =
    AnimationPreferencesTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AnimationPreferencesTableTableFilterComposer
    extends Composer<_$AppDatabase, $AnimationPreferencesTableTable> {
  $$AnimationPreferencesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AnimationPreferencesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimationPreferencesTableTable> {
  $$AnimationPreferencesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AnimationPreferencesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimationPreferencesTableTable> {
  $$AnimationPreferencesTableTableAnnotationComposer({
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

class $$AnimationPreferencesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimationPreferencesTableTable,
          AnimationPreferencesTableData,
          $$AnimationPreferencesTableTableFilterComposer,
          $$AnimationPreferencesTableTableOrderingComposer,
          $$AnimationPreferencesTableTableAnnotationComposer,
          $$AnimationPreferencesTableTableCreateCompanionBuilder,
          $$AnimationPreferencesTableTableUpdateCompanionBuilder,
          (
            AnimationPreferencesTableData,
            BaseReferences<
              _$AppDatabase,
              $AnimationPreferencesTableTable,
              AnimationPreferencesTableData
            >,
          ),
          AnimationPreferencesTableData,
          PrefetchHooks Function()
        > {
  $$AnimationPreferencesTableTableTableManager(
    _$AppDatabase db,
    $AnimationPreferencesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimationPreferencesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimationPreferencesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimationPreferencesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimationPreferencesTableCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AnimationPreferencesTableCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnimationPreferencesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimationPreferencesTableTable,
      AnimationPreferencesTableData,
      $$AnimationPreferencesTableTableFilterComposer,
      $$AnimationPreferencesTableTableOrderingComposer,
      $$AnimationPreferencesTableTableAnnotationComposer,
      $$AnimationPreferencesTableTableCreateCompanionBuilder,
      $$AnimationPreferencesTableTableUpdateCompanionBuilder,
      (
        AnimationPreferencesTableData,
        BaseReferences<
          _$AppDatabase,
          $AnimationPreferencesTableTable,
          AnimationPreferencesTableData
        >,
      ),
      AnimationPreferencesTableData,
      PrefetchHooks Function()
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      required String uri,
      required String ownerDid,
      required String actorDid,
      required String type,
      Value<String?> reasonSubjectUri,
      Value<String?> recordJson,
      required DateTime indexedAt,
      Value<bool> isRead,
      Value<DateTime?> seenAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<String> uri,
      Value<String> ownerDid,
      Value<String> actorDid,
      Value<String> type,
      Value<String?> reasonSubjectUri,
      Value<String?> recordJson,
      Value<DateTime> indexedAt,
      Value<bool> isRead,
      Value<DateTime?> seenAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

final class $$NotificationsTableReferences
    extends BaseReferences<_$AppDatabase, $NotificationsTable, Notification> {
  $$NotificationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _actorDidTable(_$AppDatabase db) =>
      db.profiles.createAlias($_aliasNameGenerator(db.notifications.actorDid, db.profiles.did));

  $$ProfilesTableProcessedTableManager get actorDid {
    final $_column = $_itemColumn<String>('actor_did')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.did.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_actorDidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NotificationsTableFilterComposer extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reasonSubjectUri => $composableBuilder(
    column: $table.reasonSubjectUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordJson =>
      $composableBuilder(column: $table.recordJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get actorDid {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actorDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableFilterComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$NotificationsTableOrderingComposer extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reasonSubjectUri => $composableBuilder(
    column: $table.reasonSubjectUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordJson =>
      $composableBuilder(column: $table.recordJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get actorDid {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actorDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableOrderingComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$NotificationsTableAnnotationComposer extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get reasonSubjectUri =>
      $composableBuilder(column: $table.reasonSubjectUri, builder: (column) => column);

  GeneratedColumn<String> get recordJson =>
      $composableBuilder(column: $table.recordJson, builder: (column) => column);

  GeneratedColumn<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get actorDid {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actorDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTable,
          Notification,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (Notification, $$NotificationsTableReferences),
          Notification,
          PrefetchHooks Function({bool actorDid})
        > {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uri = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> actorDid = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> reasonSubjectUri = const Value.absent(),
                Value<String?> recordJson = const Value.absent(),
                Value<DateTime> indexedAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime?> seenAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion(
                uri: uri,
                ownerDid: ownerDid,
                actorDid: actorDid,
                type: type,
                reasonSubjectUri: reasonSubjectUri,
                recordJson: recordJson,
                indexedAt: indexedAt,
                isRead: isRead,
                seenAt: seenAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uri,
                required String ownerDid,
                required String actorDid,
                required String type,
                Value<String?> reasonSubjectUri = const Value.absent(),
                Value<String?> recordJson = const Value.absent(),
                required DateTime indexedAt,
                Value<bool> isRead = const Value.absent(),
                Value<DateTime?> seenAt = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => NotificationsCompanion.insert(
                uri: uri,
                ownerDid: ownerDid,
                actorDid: actorDid,
                type: type,
                reasonSubjectUri: reasonSubjectUri,
                recordJson: recordJson,
                indexedAt: indexedAt,
                isRead: isRead,
                seenAt: seenAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$NotificationsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({actorDid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (actorDid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.actorDid,
                                referencedTable: $$NotificationsTableReferences._actorDidTable(db),
                                referencedColumn: $$NotificationsTableReferences
                                    ._actorDidTable(db)
                                    .did,
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

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTable,
      Notification,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (Notification, $$NotificationsTableReferences),
      Notification,
      PrefetchHooks Function({bool actorDid})
    >;
typedef $$NotificationCursorsTableCreateCompanionBuilder =
    NotificationCursorsCompanion Function({
      required String feedKey,
      required String ownerDid,
      required String cursor,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });
typedef $$NotificationCursorsTableUpdateCompanionBuilder =
    NotificationCursorsCompanion Function({
      Value<String> feedKey,
      Value<String> ownerDid,
      Value<String> cursor,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });

class $$NotificationCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationCursorsTable> {
  $$NotificationCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated =>
      $composableBuilder(column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$NotificationCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationCursorsTable> {
  $$NotificationCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated =>
      $composableBuilder(column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$NotificationCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationCursorsTable> {
  $$NotificationCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated =>
      $composableBuilder(column: $table.lastUpdated, builder: (column) => column);
}

class $$NotificationCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationCursorsTable,
          NotificationCursor,
          $$NotificationCursorsTableFilterComposer,
          $$NotificationCursorsTableOrderingComposer,
          $$NotificationCursorsTableAnnotationComposer,
          $$NotificationCursorsTableCreateCompanionBuilder,
          $$NotificationCursorsTableUpdateCompanionBuilder,
          (
            NotificationCursor,
            BaseReferences<_$AppDatabase, $NotificationCursorsTable, NotificationCursor>,
          ),
          NotificationCursor,
          PrefetchHooks Function()
        > {
  $$NotificationCursorsTableTableManager(_$AppDatabase db, $NotificationCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedKey = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationCursorsCompanion(
                feedKey: feedKey,
                ownerDid: ownerDid,
                cursor: cursor,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedKey,
                required String ownerDid,
                required String cursor,
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationCursorsCompanion.insert(
                feedKey: feedKey,
                ownerDid: ownerDid,
                cursor: cursor,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationCursorsTable,
      NotificationCursor,
      $$NotificationCursorsTableFilterComposer,
      $$NotificationCursorsTableOrderingComposer,
      $$NotificationCursorsTableAnnotationComposer,
      $$NotificationCursorsTableCreateCompanionBuilder,
      $$NotificationCursorsTableUpdateCompanionBuilder,
      (
        NotificationCursor,
        BaseReferences<_$AppDatabase, $NotificationCursorsTable, NotificationCursor>,
      ),
      NotificationCursor,
      PrefetchHooks Function()
    >;
typedef $$NotificationsSyncQueueTableCreateCompanionBuilder =
    NotificationsSyncQueueCompanion Function({
      Value<int> id,
      required String ownerDid,
      required String type,
      required String seenAt,
      required DateTime createdAt,
      Value<int> retryCount,
    });
typedef $$NotificationsSyncQueueTableUpdateCompanionBuilder =
    NotificationsSyncQueueCompanion Function({
      Value<int> id,
      Value<String> ownerDid,
      Value<String> type,
      Value<String> seenAt,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });

class $$NotificationsSyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsSyncQueueTable> {
  $$NotificationsSyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => ColumnFilters(column));
}

class $$NotificationsSyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsSyncQueueTable> {
  $$NotificationsSyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => ColumnOrderings(column));
}

class $$NotificationsSyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsSyncQueueTable> {
  $$NotificationsSyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => column);
}

class $$NotificationsSyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsSyncQueueTable,
          NotificationsSyncQueueData,
          $$NotificationsSyncQueueTableFilterComposer,
          $$NotificationsSyncQueueTableOrderingComposer,
          $$NotificationsSyncQueueTableAnnotationComposer,
          $$NotificationsSyncQueueTableCreateCompanionBuilder,
          $$NotificationsSyncQueueTableUpdateCompanionBuilder,
          (
            NotificationsSyncQueueData,
            BaseReferences<
              _$AppDatabase,
              $NotificationsSyncQueueTable,
              NotificationsSyncQueueData
            >,
          ),
          NotificationsSyncQueueData,
          PrefetchHooks Function()
        > {
  $$NotificationsSyncQueueTableTableManager(_$AppDatabase db, $NotificationsSyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsSyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsSyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsSyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> seenAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => NotificationsSyncQueueCompanion(
                id: id,
                ownerDid: ownerDid,
                type: type,
                seenAt: seenAt,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ownerDid,
                required String type,
                required String seenAt,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
              }) => NotificationsSyncQueueCompanion.insert(
                id: id,
                ownerDid: ownerDid,
                type: type,
                seenAt: seenAt,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsSyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsSyncQueueTable,
      NotificationsSyncQueueData,
      $$NotificationsSyncQueueTableFilterComposer,
      $$NotificationsSyncQueueTableOrderingComposer,
      $$NotificationsSyncQueueTableAnnotationComposer,
      $$NotificationsSyncQueueTableCreateCompanionBuilder,
      $$NotificationsSyncQueueTableUpdateCompanionBuilder,
      (
        NotificationsSyncQueueData,
        BaseReferences<_$AppDatabase, $NotificationsSyncQueueTable, NotificationsSyncQueueData>,
      ),
      NotificationsSyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$DmConvosTableCreateCompanionBuilder =
    DmConvosCompanion Function({
      required String convoId,
      required String ownerDid,
      required String membersJson,
      Value<String?> lastMessageText,
      Value<DateTime?> lastMessageAt,
      Value<String?> lastReadMessageId,
      Value<int> unreadCount,
      Value<bool> isMuted,
      Value<bool> isAccepted,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$DmConvosTableUpdateCompanionBuilder =
    DmConvosCompanion Function({
      Value<String> convoId,
      Value<String> ownerDid,
      Value<String> membersJson,
      Value<String?> lastMessageText,
      Value<DateTime?> lastMessageAt,
      Value<String?> lastReadMessageId,
      Value<int> unreadCount,
      Value<bool> isMuted,
      Value<bool> isAccepted,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$DmConvosTableFilterComposer extends Composer<_$AppDatabase, $DmConvosTable> {
  $$DmConvosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get convoId =>
      $composableBuilder(column: $table.convoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get membersJson =>
      $composableBuilder(column: $table.membersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessageText => $composableBuilder(
    column: $table.lastMessageText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageAt =>
      $composableBuilder(column: $table.lastMessageAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount =>
      $composableBuilder(column: $table.unreadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMuted =>
      $composableBuilder(column: $table.isMuted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAccepted =>
      $composableBuilder(column: $table.isAccepted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$DmConvosTableOrderingComposer extends Composer<_$AppDatabase, $DmConvosTable> {
  $$DmConvosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get convoId =>
      $composableBuilder(column: $table.convoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get membersJson =>
      $composableBuilder(column: $table.membersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessageText => $composableBuilder(
    column: $table.lastMessageText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount =>
      $composableBuilder(column: $table.unreadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMuted =>
      $composableBuilder(column: $table.isMuted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAccepted =>
      $composableBuilder(column: $table.isAccepted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$DmConvosTableAnnotationComposer extends Composer<_$AppDatabase, $DmConvosTable> {
  $$DmConvosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get convoId =>
      $composableBuilder(column: $table.convoId, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get membersJson =>
      $composableBuilder(column: $table.membersJson, builder: (column) => column);

  GeneratedColumn<String> get lastMessageText =>
      $composableBuilder(column: $table.lastMessageText, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageAt =>
      $composableBuilder(column: $table.lastMessageAt, builder: (column) => column);

  GeneratedColumn<String> get lastReadMessageId =>
      $composableBuilder(column: $table.lastReadMessageId, builder: (column) => column);

  GeneratedColumn<int> get unreadCount =>
      $composableBuilder(column: $table.unreadCount, builder: (column) => column);

  GeneratedColumn<bool> get isMuted =>
      $composableBuilder(column: $table.isMuted, builder: (column) => column);

  GeneratedColumn<bool> get isAccepted =>
      $composableBuilder(column: $table.isAccepted, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$DmConvosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DmConvosTable,
          DmConvo,
          $$DmConvosTableFilterComposer,
          $$DmConvosTableOrderingComposer,
          $$DmConvosTableAnnotationComposer,
          $$DmConvosTableCreateCompanionBuilder,
          $$DmConvosTableUpdateCompanionBuilder,
          (DmConvo, BaseReferences<_$AppDatabase, $DmConvosTable, DmConvo>),
          DmConvo,
          PrefetchHooks Function()
        > {
  $$DmConvosTableTableManager(_$AppDatabase db, $DmConvosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DmConvosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DmConvosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DmConvosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> convoId = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> membersJson = const Value.absent(),
                Value<String?> lastMessageText = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<String?> lastReadMessageId = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<bool> isAccepted = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DmConvosCompanion(
                convoId: convoId,
                ownerDid: ownerDid,
                membersJson: membersJson,
                lastMessageText: lastMessageText,
                lastMessageAt: lastMessageAt,
                lastReadMessageId: lastReadMessageId,
                unreadCount: unreadCount,
                isMuted: isMuted,
                isAccepted: isAccepted,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String convoId,
                required String ownerDid,
                required String membersJson,
                Value<String?> lastMessageText = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<String?> lastReadMessageId = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<bool> isAccepted = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => DmConvosCompanion.insert(
                convoId: convoId,
                ownerDid: ownerDid,
                membersJson: membersJson,
                lastMessageText: lastMessageText,
                lastMessageAt: lastMessageAt,
                lastReadMessageId: lastReadMessageId,
                unreadCount: unreadCount,
                isMuted: isMuted,
                isAccepted: isAccepted,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DmConvosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DmConvosTable,
      DmConvo,
      $$DmConvosTableFilterComposer,
      $$DmConvosTableOrderingComposer,
      $$DmConvosTableAnnotationComposer,
      $$DmConvosTableCreateCompanionBuilder,
      $$DmConvosTableUpdateCompanionBuilder,
      (DmConvo, BaseReferences<_$AppDatabase, $DmConvosTable, DmConvo>),
      DmConvo,
      PrefetchHooks Function()
    >;
typedef $$DmMessagesTableCreateCompanionBuilder =
    DmMessagesCompanion Function({
      required String messageId,
      required String ownerDid,
      required String convoId,
      required String senderDid,
      required String content,
      required DateTime sentAt,
      required String status,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$DmMessagesTableUpdateCompanionBuilder =
    DmMessagesCompanion Function({
      Value<String> messageId,
      Value<String> ownerDid,
      Value<String> convoId,
      Value<String> senderDid,
      Value<String> content,
      Value<DateTime> sentAt,
      Value<String> status,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

final class $$DmMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $DmMessagesTable, DmMessage> {
  $$DmMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _senderDidTable(_$AppDatabase db) =>
      db.profiles.createAlias($_aliasNameGenerator(db.dmMessages.senderDid, db.profiles.did));

  $$ProfilesTableProcessedTableManager get senderDid {
    final $_column = $_itemColumn<String>('sender_did')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.did.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_senderDidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DmMessagesTableFilterComposer extends Composer<_$AppDatabase, $DmMessagesTable> {
  $$DmMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get convoId =>
      $composableBuilder(column: $table.convoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get senderDid {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableFilterComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$DmMessagesTableOrderingComposer extends Composer<_$AppDatabase, $DmMessagesTable> {
  $$DmMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get convoId =>
      $composableBuilder(column: $table.convoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get senderDid {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableOrderingComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$DmMessagesTableAnnotationComposer extends Composer<_$AppDatabase, $DmMessagesTable> {
  $$DmMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get convoId =>
      $composableBuilder(column: $table.convoId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get senderDid {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderDid,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.did,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$ProfilesTableAnnotationComposer(
                $db: $db,
                $table: $db.profiles,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$DmMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DmMessagesTable,
          DmMessage,
          $$DmMessagesTableFilterComposer,
          $$DmMessagesTableOrderingComposer,
          $$DmMessagesTableAnnotationComposer,
          $$DmMessagesTableCreateCompanionBuilder,
          $$DmMessagesTableUpdateCompanionBuilder,
          (DmMessage, $$DmMessagesTableReferences),
          DmMessage,
          PrefetchHooks Function({bool senderDid})
        > {
  $$DmMessagesTableTableManager(_$AppDatabase db, $DmMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DmMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DmMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DmMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageId = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> convoId = const Value.absent(),
                Value<String> senderDid = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DmMessagesCompanion(
                messageId: messageId,
                ownerDid: ownerDid,
                convoId: convoId,
                senderDid: senderDid,
                content: content,
                sentAt: sentAt,
                status: status,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageId,
                required String ownerDid,
                required String convoId,
                required String senderDid,
                required String content,
                required DateTime sentAt,
                required String status,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => DmMessagesCompanion.insert(
                messageId: messageId,
                ownerDid: ownerDid,
                convoId: convoId,
                senderDid: senderDid,
                content: content,
                sentAt: sentAt,
                status: status,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$DmMessagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({senderDid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (senderDid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.senderDid,
                                referencedTable: $$DmMessagesTableReferences._senderDidTable(db),
                                referencedColumn: $$DmMessagesTableReferences
                                    ._senderDidTable(db)
                                    .did,
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

typedef $$DmMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DmMessagesTable,
      DmMessage,
      $$DmMessagesTableFilterComposer,
      $$DmMessagesTableOrderingComposer,
      $$DmMessagesTableAnnotationComposer,
      $$DmMessagesTableCreateCompanionBuilder,
      $$DmMessagesTableUpdateCompanionBuilder,
      (DmMessage, $$DmMessagesTableReferences),
      DmMessage,
      PrefetchHooks Function({bool senderDid})
    >;
typedef $$DmOutboxTableCreateCompanionBuilder =
    DmOutboxCompanion Function({
      required String outboxId,
      required String ownerDid,
      required String convoId,
      required String messageText,
      required String status,
      Value<int> retryCount,
      required DateTime createdAt,
      Value<DateTime?> lastAttemptAt,
      Value<String?> errorMessage,
      Value<int> rowid,
    });
typedef $$DmOutboxTableUpdateCompanionBuilder =
    DmOutboxCompanion Function({
      Value<String> outboxId,
      Value<String> ownerDid,
      Value<String> convoId,
      Value<String> messageText,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttemptAt,
      Value<String?> errorMessage,
      Value<int> rowid,
    });

class $$DmOutboxTableFilterComposer extends Composer<_$AppDatabase, $DmOutboxTable> {
  $$DmOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get outboxId =>
      $composableBuilder(column: $table.outboxId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get convoId =>
      $composableBuilder(column: $table.convoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageText =>
      $composableBuilder(column: $table.messageText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt =>
      $composableBuilder(column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage =>
      $composableBuilder(column: $table.errorMessage, builder: (column) => ColumnFilters(column));
}

class $$DmOutboxTableOrderingComposer extends Composer<_$AppDatabase, $DmOutboxTable> {
  $$DmOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get outboxId =>
      $composableBuilder(column: $table.outboxId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get convoId =>
      $composableBuilder(column: $table.convoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageText =>
      $composableBuilder(column: $table.messageText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DmOutboxTableAnnotationComposer extends Composer<_$AppDatabase, $DmOutboxTable> {
  $$DmOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get outboxId =>
      $composableBuilder(column: $table.outboxId, builder: (column) => column);

  GeneratedColumn<String> get ownerDid =>
      $composableBuilder(column: $table.ownerDid, builder: (column) => column);

  GeneratedColumn<String> get convoId =>
      $composableBuilder(column: $table.convoId, builder: (column) => column);

  GeneratedColumn<String> get messageText =>
      $composableBuilder(column: $table.messageText, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt =>
      $composableBuilder(column: $table.lastAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get errorMessage =>
      $composableBuilder(column: $table.errorMessage, builder: (column) => column);
}

class $$DmOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DmOutboxTable,
          DmOutboxData,
          $$DmOutboxTableFilterComposer,
          $$DmOutboxTableOrderingComposer,
          $$DmOutboxTableAnnotationComposer,
          $$DmOutboxTableCreateCompanionBuilder,
          $$DmOutboxTableUpdateCompanionBuilder,
          (DmOutboxData, BaseReferences<_$AppDatabase, $DmOutboxTable, DmOutboxData>),
          DmOutboxData,
          PrefetchHooks Function()
        > {
  $$DmOutboxTableTableManager(_$AppDatabase db, $DmOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DmOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DmOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DmOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> outboxId = const Value.absent(),
                Value<String> ownerDid = const Value.absent(),
                Value<String> convoId = const Value.absent(),
                Value<String> messageText = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DmOutboxCompanion(
                outboxId: outboxId,
                ownerDid: ownerDid,
                convoId: convoId,
                messageText: messageText,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String outboxId,
                required String ownerDid,
                required String convoId,
                required String messageText,
                required String status,
                Value<int> retryCount = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DmOutboxCompanion.insert(
                outboxId: outboxId,
                ownerDid: ownerDid,
                convoId: convoId,
                messageText: messageText,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DmOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DmOutboxTable,
      DmOutboxData,
      $$DmOutboxTableFilterComposer,
      $$DmOutboxTableOrderingComposer,
      $$DmOutboxTableAnnotationComposer,
      $$DmOutboxTableCreateCompanionBuilder,
      $$DmOutboxTableUpdateCompanionBuilder,
      (DmOutboxData, BaseReferences<_$AppDatabase, $DmOutboxTable, DmOutboxData>),
      DmOutboxData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles => $$ProfilesTableTableManager(_db, _db.profiles);
  $$PostsTableTableManager get posts => $$PostsTableTableManager(_db, _db.posts);
  $$FeedContentItemsTableTableManager get feedContentItems =>
      $$FeedContentItemsTableTableManager(_db, _db.feedContentItems);
  $$AccountsTableTableManager get accounts => $$AccountsTableTableManager(_db, _db.accounts);
  $$FeedCursorsTableTableManager get feedCursors =>
      $$FeedCursorsTableTableManager(_db, _db.feedCursors);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
  $$SearchCacheItemsTableTableManager get searchCacheItems =>
      $$SearchCacheItemsTableTableManager(_db, _db.searchCacheItems);
  $$SearchCacheCursorsTableTableManager get searchCacheCursors =>
      $$SearchCacheCursorsTableTableManager(_db, _db.searchCacheCursors);
  $$FollowsTableTableManager get follows => $$FollowsTableTableManager(_db, _db.follows);
  $$SavedFeedsTableTableManager get savedFeeds =>
      $$SavedFeedsTableTableManager(_db, _db.savedFeeds);
  $$PreferenceSyncQueueTableTableManager get preferenceSyncQueue =>
      $$PreferenceSyncQueueTableTableManager(_db, _db.preferenceSyncQueue);
  $$DraftsTableTableManager get drafts => $$DraftsTableTableManager(_db, _db.drafts);
  $$DraftMediaTableTableManager get draftMedia =>
      $$DraftMediaTableTableManager(_db, _db.draftMedia);
  $$ProfileRelationshipsTableTableManager get profileRelationships =>
      $$ProfileRelationshipsTableTableManager(_db, _db.profileRelationships);
  $$PostInteractionsTableTableManager get postInteractions =>
      $$PostInteractionsTableTableManager(_db, _db.postInteractions);
  $$LocalSettingsTableTableManager get localSettings =>
      $$LocalSettingsTableTableManager(_db, _db.localSettings);
  $$BlueskyPreferencesTableTableManager get blueskyPreferences =>
      $$BlueskyPreferencesTableTableManager(_db, _db.blueskyPreferences);
  $$CustomThemesTableTableManager get customThemes =>
      $$CustomThemesTableTableManager(_db, _db.customThemes);
  $$AnimationPreferencesTableTableTableManager get animationPreferencesTable =>
      $$AnimationPreferencesTableTableTableManager(_db, _db.animationPreferencesTable);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$NotificationCursorsTableTableManager get notificationCursors =>
      $$NotificationCursorsTableTableManager(_db, _db.notificationCursors);
  $$NotificationsSyncQueueTableTableManager get notificationsSyncQueue =>
      $$NotificationsSyncQueueTableTableManager(_db, _db.notificationsSyncQueue);
  $$DmConvosTableTableManager get dmConvos => $$DmConvosTableTableManager(_db, _db.dmConvos);
  $$DmMessagesTableTableManager get dmMessages =>
      $$DmMessagesTableTableManager(_db, _db.dmMessages);
  $$DmOutboxTableTableManager get dmOutbox => $$DmOutboxTableTableManager(_db, _db.dmOutbox);
}
