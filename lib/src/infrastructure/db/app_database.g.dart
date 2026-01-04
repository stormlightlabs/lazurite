// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
  static const VerificationMeta _recordMeta = const VerificationMeta('record');
  @override
  late final GeneratedColumn<String> record = GeneratedColumn<String>(
    'record',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _indexedAtMeta = const VerificationMeta(
    'indexedAt',
  );
  @override
  late final GeneratedColumn<DateTime> indexedAt = GeneratedColumn<DateTime>(
    'indexed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uri,
    cid,
    authorDid,
    record,
    indexedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'posts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Post> instance, {
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
    if (data.containsKey('cid')) {
      context.handle(
        _cidMeta,
        cid.isAcceptableOrUnknown(data['cid']!, _cidMeta),
      );
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
      context.handle(
        _recordMeta,
        record.isAcceptableOrUnknown(data['record']!, _recordMeta),
      );
    } else if (isInserting) {
      context.missing(_recordMeta);
    }
    if (data.containsKey('indexed_at')) {
      context.handle(
        _indexedAtMeta,
        indexedAt.isAcceptableOrUnknown(data['indexed_at']!, _indexedAtMeta),
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
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      cid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cid'],
      )!,
      authorDid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_did'],
      )!,
      record: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record'],
      )!,
      indexedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}indexed_at'],
      ),
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
  final DateTime? indexedAt;
  const Post({
    required this.uri,
    required this.cid,
    required this.authorDid,
    required this.record,
    this.indexedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uri'] = Variable<String>(uri);
    map['cid'] = Variable<String>(cid);
    map['author_did'] = Variable<String>(authorDid);
    map['record'] = Variable<String>(record);
    if (!nullToAbsent || indexedAt != null) {
      map['indexed_at'] = Variable<DateTime>(indexedAt);
    }
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      uri: Value(uri),
      cid: Value(cid),
      authorDid: Value(authorDid),
      record: Value(record),
      indexedAt: indexedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(indexedAt),
    );
  }

  factory Post.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Post(
      uri: serializer.fromJson<String>(json['uri']),
      cid: serializer.fromJson<String>(json['cid']),
      authorDid: serializer.fromJson<String>(json['authorDid']),
      record: serializer.fromJson<String>(json['record']),
      indexedAt: serializer.fromJson<DateTime?>(json['indexedAt']),
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
      'indexedAt': serializer.toJson<DateTime?>(indexedAt),
    };
  }

  Post copyWith({
    String? uri,
    String? cid,
    String? authorDid,
    String? record,
    Value<DateTime?> indexedAt = const Value.absent(),
  }) => Post(
    uri: uri ?? this.uri,
    cid: cid ?? this.cid,
    authorDid: authorDid ?? this.authorDid,
    record: record ?? this.record,
    indexedAt: indexedAt.present ? indexedAt.value : this.indexedAt,
  );
  Post copyWithCompanion(PostsCompanion data) {
    return Post(
      uri: data.uri.present ? data.uri.value : this.uri,
      cid: data.cid.present ? data.cid.value : this.cid,
      authorDid: data.authorDid.present ? data.authorDid.value : this.authorDid,
      record: data.record.present ? data.record.value : this.record,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Post(')
          ..write('uri: $uri, ')
          ..write('cid: $cid, ')
          ..write('authorDid: $authorDid, ')
          ..write('record: $record, ')
          ..write('indexedAt: $indexedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uri, cid, authorDid, record, indexedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Post &&
          other.uri == this.uri &&
          other.cid == this.cid &&
          other.authorDid == this.authorDid &&
          other.record == this.record &&
          other.indexedAt == this.indexedAt);
}

class PostsCompanion extends UpdateCompanion<Post> {
  final Value<String> uri;
  final Value<String> cid;
  final Value<String> authorDid;
  final Value<String> record;
  final Value<DateTime?> indexedAt;
  final Value<int> rowid;
  const PostsCompanion({
    this.uri = const Value.absent(),
    this.cid = const Value.absent(),
    this.authorDid = const Value.absent(),
    this.record = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostsCompanion.insert({
    required String uri,
    required String cid,
    required String authorDid,
    required String record,
    this.indexedAt = const Value.absent(),
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
    Expression<DateTime>? indexedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uri != null) 'uri': uri,
      if (cid != null) 'cid': cid,
      if (authorDid != null) 'author_did': authorDid,
      if (record != null) 'record': record,
      if (indexedAt != null) 'indexed_at': indexedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostsCompanion copyWith({
    Value<String>? uri,
    Value<String>? cid,
    Value<String>? authorDid,
    Value<String>? record,
    Value<DateTime?>? indexedAt,
    Value<int>? rowid,
  }) {
    return PostsCompanion(
      uri: uri ?? this.uri,
      cid: cid ?? this.cid,
      authorDid: authorDid ?? this.authorDid,
      record: record ?? this.record,
      indexedAt: indexedAt ?? this.indexedAt,
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
    if (indexedAt.present) {
      map['indexed_at'] = Variable<DateTime>(indexedAt.value);
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
          ..write('indexedAt: $indexedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _indexedAtMeta = const VerificationMeta(
    'indexedAt',
  );
  @override
  late final GeneratedColumn<DateTime> indexedAt = GeneratedColumn<DateTime>(
    'indexed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('banner')) {
      context.handle(
        _bannerMeta,
        banner.isAcceptableOrUnknown(data['banner']!, _bannerMeta),
      );
    }
    if (data.containsKey('indexed_at')) {
      context.handle(
        _indexedAtMeta,
        indexedAt.isAcceptableOrUnknown(data['indexed_at']!, _indexedAtMeta),
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
  const Profile({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
    this.banner,
    this.indexedAt,
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
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      did: Value(did),
      handle: Value(handle),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      banner: banner == null && nullToAbsent
          ? const Value.absent()
          : Value(banner),
      indexedAt: indexedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(indexedAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      did: serializer.fromJson<String>(json['did']),
      handle: serializer.fromJson<String>(json['handle']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      description: serializer.fromJson<String?>(json['description']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      banner: serializer.fromJson<String?>(json['banner']),
      indexedAt: serializer.fromJson<DateTime?>(json['indexedAt']),
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
  }) => Profile(
    did: did ?? this.did,
    handle: handle ?? this.handle,
    displayName: displayName.present ? displayName.value : this.displayName,
    description: description.present ? description.value : this.description,
    avatar: avatar.present ? avatar.value : this.avatar,
    banner: banner.present ? banner.value : this.banner,
    indexedAt: indexedAt.present ? indexedAt.value : this.indexedAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      did: data.did.present ? data.did.value : this.did,
      handle: data.handle.present ? data.handle.value : this.handle,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      description: data.description.present
          ? data.description.value
          : this.description,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      banner: data.banner.present ? data.banner.value : this.banner,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
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
          ..write('indexedAt: $indexedAt')
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
          other.indexedAt == this.indexedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> did;
  final Value<String> handle;
  final Value<String?> displayName;
  final Value<String?> description;
  final Value<String?> avatar;
  final Value<String?> banner;
  final Value<DateTime?> indexedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.did = const Value.absent(),
    this.handle = const Value.absent(),
    this.displayName = const Value.absent(),
    this.description = const Value.absent(),
    this.avatar = const Value.absent(),
    this.banner = const Value.absent(),
    this.indexedAt = const Value.absent(),
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineItemsTable extends TimelineItems
    with TableInfo<$TimelineItemsTable, TimelineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedKeyMeta = const VerificationMeta(
    'feedKey',
  );
  @override
  late final GeneratedColumn<String> feedKey = GeneratedColumn<String>(
    'feed_key',
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES posts (uri)',
    ),
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
  static const VerificationMeta _sortKeyMeta = const VerificationMeta(
    'sortKey',
  );
  @override
  late final GeneratedColumn<String> sortKey = GeneratedColumn<String>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [feedKey, postUri, reason, sortKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_key')) {
      context.handle(
        _feedKeyMeta,
        feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
    }
    if (data.containsKey('post_uri')) {
      context.handle(
        _postUriMeta,
        postUri.isAcceptableOrUnknown(data['post_uri']!, _postUriMeta),
      );
    } else if (isInserting) {
      context.missing(_postUriMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('sort_key')) {
      context.handle(
        _sortKeyMeta,
        sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedKey, postUri};
  @override
  TimelineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineItem(
      feedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_key'],
      )!,
      postUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_uri'],
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
  $TimelineItemsTable createAlias(String alias) {
    return $TimelineItemsTable(attachedDatabase, alias);
  }
}

class TimelineItem extends DataClass implements Insertable<TimelineItem> {
  final String feedKey;
  final String postUri;
  final String? reason;
  final String sortKey;
  const TimelineItem({
    required this.feedKey,
    required this.postUri,
    this.reason,
    required this.sortKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_key'] = Variable<String>(feedKey);
    map['post_uri'] = Variable<String>(postUri);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['sort_key'] = Variable<String>(sortKey);
    return map;
  }

  TimelineItemsCompanion toCompanion(bool nullToAbsent) {
    return TimelineItemsCompanion(
      feedKey: Value(feedKey),
      postUri: Value(postUri),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      sortKey: Value(sortKey),
    );
  }

  factory TimelineItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineItem(
      feedKey: serializer.fromJson<String>(json['feedKey']),
      postUri: serializer.fromJson<String>(json['postUri']),
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
      'reason': serializer.toJson<String?>(reason),
      'sortKey': serializer.toJson<String>(sortKey),
    };
  }

  TimelineItem copyWith({
    String? feedKey,
    String? postUri,
    Value<String?> reason = const Value.absent(),
    String? sortKey,
  }) => TimelineItem(
    feedKey: feedKey ?? this.feedKey,
    postUri: postUri ?? this.postUri,
    reason: reason.present ? reason.value : this.reason,
    sortKey: sortKey ?? this.sortKey,
  );
  TimelineItem copyWithCompanion(TimelineItemsCompanion data) {
    return TimelineItem(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      postUri: data.postUri.present ? data.postUri.value : this.postUri,
      reason: data.reason.present ? data.reason.value : this.reason,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineItem(')
          ..write('feedKey: $feedKey, ')
          ..write('postUri: $postUri, ')
          ..write('reason: $reason, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feedKey, postUri, reason, sortKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineItem &&
          other.feedKey == this.feedKey &&
          other.postUri == this.postUri &&
          other.reason == this.reason &&
          other.sortKey == this.sortKey);
}

class TimelineItemsCompanion extends UpdateCompanion<TimelineItem> {
  final Value<String> feedKey;
  final Value<String> postUri;
  final Value<String?> reason;
  final Value<String> sortKey;
  final Value<int> rowid;
  const TimelineItemsCompanion({
    this.feedKey = const Value.absent(),
    this.postUri = const Value.absent(),
    this.reason = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimelineItemsCompanion.insert({
    required String feedKey,
    required String postUri,
    this.reason = const Value.absent(),
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey),
       postUri = Value(postUri),
       sortKey = Value(sortKey);
  static Insertable<TimelineItem> custom({
    Expression<String>? feedKey,
    Expression<String>? postUri,
    Expression<String>? reason,
    Expression<String>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedKey != null) 'feed_key': feedKey,
      if (postUri != null) 'post_uri': postUri,
      if (reason != null) 'reason': reason,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimelineItemsCompanion copyWith({
    Value<String>? feedKey,
    Value<String>? postUri,
    Value<String?>? reason,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return TimelineItemsCompanion(
      feedKey: feedKey ?? this.feedKey,
      postUri: postUri ?? this.postUri,
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
    return (StringBuffer('TimelineItemsCompanion(')
          ..write('feedKey: $feedKey, ')
          ..write('postUri: $postUri, ')
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
    if (data.containsKey('pds_url')) {
      context.handle(
        _pdsUrlMeta,
        pdsUrl.isAcceptableOrUnknown(data['pds_url']!, _pdsUrlMeta),
      );
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
      did: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}did'],
      )!,
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
  const Account({
    required this.did,
    required this.handle,
    required this.pdsUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['did'] = Variable<String>(did);
    map['handle'] = Variable<String>(handle);
    map['pds_url'] = Variable<String>(pdsUrl);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      did: Value(did),
      handle: Value(handle),
      pdsUrl: Value(pdsUrl),
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

  Account copyWith({String? did, String? handle, String? pdsUrl}) => Account(
    did: did ?? this.did,
    handle: handle ?? this.handle,
    pdsUrl: pdsUrl ?? this.pdsUrl,
  );
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

class $FeedCursorsTable extends FeedCursors
    with TableInfo<$FeedCursorsTable, FeedCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedKeyMeta = const VerificationMeta(
    'feedKey',
  );
  @override
  late final GeneratedColumn<String> feedKey = GeneratedColumn<String>(
    'feed_key',
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
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [feedKey, cursor, lastUpdated];
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
      context.handle(
        _feedKeyMeta,
        feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedKey};
  @override
  FeedCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedCursor(
      feedKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_key'],
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
  final String cursor;
  final DateTime? lastUpdated;
  const FeedCursor({
    required this.feedKey,
    required this.cursor,
    this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_key'] = Variable<String>(feedKey);
    map['cursor'] = Variable<String>(cursor);
    if (!nullToAbsent || lastUpdated != null) {
      map['last_updated'] = Variable<DateTime>(lastUpdated);
    }
    return map;
  }

  FeedCursorsCompanion toCompanion(bool nullToAbsent) {
    return FeedCursorsCompanion(
      feedKey: Value(feedKey),
      cursor: Value(cursor),
      lastUpdated: lastUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdated),
    );
  }

  factory FeedCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedCursor(
      feedKey: serializer.fromJson<String>(json['feedKey']),
      cursor: serializer.fromJson<String>(json['cursor']),
      lastUpdated: serializer.fromJson<DateTime?>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedKey': serializer.toJson<String>(feedKey),
      'cursor': serializer.toJson<String>(cursor),
      'lastUpdated': serializer.toJson<DateTime?>(lastUpdated),
    };
  }

  FeedCursor copyWith({
    String? feedKey,
    String? cursor,
    Value<DateTime?> lastUpdated = const Value.absent(),
  }) => FeedCursor(
    feedKey: feedKey ?? this.feedKey,
    cursor: cursor ?? this.cursor,
    lastUpdated: lastUpdated.present ? lastUpdated.value : this.lastUpdated,
  );
  FeedCursor copyWithCompanion(FeedCursorsCompanion data) {
    return FeedCursor(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedCursor(')
          ..write('feedKey: $feedKey, ')
          ..write('cursor: $cursor, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feedKey, cursor, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedCursor &&
          other.feedKey == this.feedKey &&
          other.cursor == this.cursor &&
          other.lastUpdated == this.lastUpdated);
}

class FeedCursorsCompanion extends UpdateCompanion<FeedCursor> {
  final Value<String> feedKey;
  final Value<String> cursor;
  final Value<DateTime?> lastUpdated;
  final Value<int> rowid;
  const FeedCursorsCompanion({
    this.feedKey = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedCursorsCompanion.insert({
    required String feedKey,
    required String cursor,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey),
       cursor = Value(cursor);
  static Insertable<FeedCursor> custom({
    Expression<String>? feedKey,
    Expression<String>? cursor,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedKey != null) 'feed_key': feedKey,
      if (cursor != null) 'cursor': cursor,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedCursorsCompanion copyWith({
    Value<String>? feedKey,
    Value<String>? cursor,
    Value<DateTime?>? lastUpdated,
    Value<int>? rowid,
  }) {
    return FeedCursorsCompanion(
      feedKey: feedKey ?? this.feedKey,
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
          ..write('cursor: $cursor, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $TimelineItemsTable timelineItems = $TimelineItemsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $FeedCursorsTable feedCursors = $FeedCursorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    posts,
    profiles,
    timelineItems,
    accounts,
    feedCursors,
  ];
}

typedef $$PostsTableCreateCompanionBuilder =
    PostsCompanion Function({
      required String uri,
      required String cid,
      required String authorDid,
      required String record,
      Value<DateTime?> indexedAt,
      Value<int> rowid,
    });
typedef $$PostsTableUpdateCompanionBuilder =
    PostsCompanion Function({
      Value<String> uri,
      Value<String> cid,
      Value<String> authorDid,
      Value<String> record,
      Value<DateTime?> indexedAt,
      Value<int> rowid,
    });

final class $$PostsTableReferences
    extends BaseReferences<_$AppDatabase, $PostsTable, Post> {
  $$PostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimelineItemsTable, List<TimelineItem>>
  _timelineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timelineItems,
    aliasName: $_aliasNameGenerator(db.posts.uri, db.timelineItems.postUri),
  );

  $$TimelineItemsTableProcessedTableManager get timelineItemsRefs {
    final manager = $$TimelineItemsTableTableManager(
      $_db,
      $_db.timelineItems,
    ).filter((f) => f.postUri.uri.sqlEquals($_itemColumn<String>('uri')!));

    final cache = $_typedResult.readTableOrNull(_timelineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
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
  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cid => $composableBuilder(
    column: $table.cid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorDid => $composableBuilder(
    column: $table.authorDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get record => $composableBuilder(
    column: $table.record,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> timelineItemsRefs(
    Expression<bool> Function($$TimelineItemsTableFilterComposer f) f,
  ) {
    final $$TimelineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uri,
      referencedTable: $db.timelineItems,
      getReferencedColumn: (t) => t.postUri,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineItemsTableFilterComposer(
            $db: $db,
            $table: $db.timelineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PostsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostsTable> {
  $$PostsTableOrderingComposer({
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

  ColumnOrderings<String> get cid => $composableBuilder(
    column: $table.cid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorDid => $composableBuilder(
    column: $table.authorDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get record => $composableBuilder(
    column: $table.record,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostsTable> {
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

  GeneratedColumn<String> get authorDid =>
      $composableBuilder(column: $table.authorDid, builder: (column) => column);

  GeneratedColumn<String> get record =>
      $composableBuilder(column: $table.record, builder: (column) => column);

  GeneratedColumn<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);

  Expression<T> timelineItemsRefs<T extends Object>(
    Expression<T> Function($$TimelineItemsTableAnnotationComposer a) f,
  ) {
    final $$TimelineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uri,
      referencedTable: $db.timelineItems,
      getReferencedColumn: (t) => t.postUri,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.timelineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
          PrefetchHooks Function({bool timelineItemsRefs})
        > {
  $$PostsTableTableManager(_$AppDatabase db, $PostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uri = const Value.absent(),
                Value<String> cid = const Value.absent(),
                Value<String> authorDid = const Value.absent(),
                Value<String> record = const Value.absent(),
                Value<DateTime?> indexedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion(
                uri: uri,
                cid: cid,
                authorDid: authorDid,
                record: record,
                indexedAt: indexedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uri,
                required String cid,
                required String authorDid,
                required String record,
                Value<DateTime?> indexedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostsCompanion.insert(
                uri: uri,
                cid: cid,
                authorDid: authorDid,
                record: record,
                indexedAt: indexedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PostsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({timelineItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (timelineItemsRefs) db.timelineItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timelineItemsRefs)
                    await $_getPrefetchedData<Post, $PostsTable, TimelineItem>(
                      currentTable: table,
                      referencedTable: $$PostsTableReferences
                          ._timelineItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PostsTableReferences(
                        db,
                        table,
                        p0,
                      ).timelineItemsRefs,
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
      PrefetchHooks Function({bool timelineItemsRefs})
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String did,
      required String handle,
      Value<String?> displayName,
      Value<String?> description,
      Value<String?> avatar,
      Value<String?> banner,
      Value<DateTime?> indexedAt,
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
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get banner => $composableBuilder(
    column: $table.banner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get banner => $composableBuilder(
    column: $table.banner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
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

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get banner =>
      $composableBuilder(column: $table.banner, builder: (column) => column);

  GeneratedColumn<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);
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
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
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
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                did: did,
                handle: handle,
                displayName: displayName,
                description: description,
                avatar: avatar,
                banner: banner,
                indexedAt: indexedAt,
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
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                did: did,
                handle: handle,
                displayName: displayName,
                description: description,
                avatar: avatar,
                banner: banner,
                indexedAt: indexedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$TimelineItemsTableCreateCompanionBuilder =
    TimelineItemsCompanion Function({
      required String feedKey,
      required String postUri,
      Value<String?> reason,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$TimelineItemsTableUpdateCompanionBuilder =
    TimelineItemsCompanion Function({
      Value<String> feedKey,
      Value<String> postUri,
      Value<String?> reason,
      Value<String> sortKey,
      Value<int> rowid,
    });

final class $$TimelineItemsTableReferences
    extends BaseReferences<_$AppDatabase, $TimelineItemsTable, TimelineItem> {
  $$TimelineItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PostsTable _postUriTable(_$AppDatabase db) => db.posts.createAlias(
    $_aliasNameGenerator(db.timelineItems.postUri, db.posts.uri),
  );

  $$PostsTableProcessedTableManager get postUri {
    final $_column = $_itemColumn<String>('post_uri')!;

    final manager = $$PostsTableTableManager(
      $_db,
      $_db.posts,
    ).filter((f) => f.uri.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postUriTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimelineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineItemsTable> {
  $$TimelineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnFilters(column),
  );

  $$PostsTableFilterComposer get postUri {
    final $$PostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableFilterComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineItemsTable> {
  $$TimelineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$PostsTableOrderingComposer get postUri {
    final $$PostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postUri,
      referencedTable: $db.posts,
      getReferencedColumn: (t) => t.uri,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableOrderingComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineItemsTable> {
  $$TimelineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => column);

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
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostsTableAnnotationComposer(
            $db: $db,
            $table: $db.posts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimelineItemsTable,
          TimelineItem,
          $$TimelineItemsTableFilterComposer,
          $$TimelineItemsTableOrderingComposer,
          $$TimelineItemsTableAnnotationComposer,
          $$TimelineItemsTableCreateCompanionBuilder,
          $$TimelineItemsTableUpdateCompanionBuilder,
          (TimelineItem, $$TimelineItemsTableReferences),
          TimelineItem,
          PrefetchHooks Function({bool postUri})
        > {
  $$TimelineItemsTableTableManager(_$AppDatabase db, $TimelineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedKey = const Value.absent(),
                Value<String> postUri = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineItemsCompanion(
                feedKey: feedKey,
                postUri: postUri,
                reason: reason,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedKey,
                required String postUri,
                Value<String?> reason = const Value.absent(),
                required String sortKey,
                Value<int> rowid = const Value.absent(),
              }) => TimelineItemsCompanion.insert(
                feedKey: feedKey,
                postUri: postUri,
                reason: reason,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimelineItemsTableReferences(db, table, e),
                ),
              )
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
                                referencedTable: $$TimelineItemsTableReferences
                                    ._postUriTable(db),
                                referencedColumn: $$TimelineItemsTableReferences
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

typedef $$TimelineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimelineItemsTable,
      TimelineItem,
      $$TimelineItemsTableFilterComposer,
      $$TimelineItemsTableOrderingComposer,
      $$TimelineItemsTableAnnotationComposer,
      $$TimelineItemsTableCreateCompanionBuilder,
      $$TimelineItemsTableUpdateCompanionBuilder,
      (TimelineItem, $$TimelineItemsTableReferences),
      TimelineItem,
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

  ColumnFilters<String> get pdsUrl => $composableBuilder(
    column: $table.pdsUrl,
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

  ColumnOrderings<String> get pdsUrl => $composableBuilder(
    column: $table.pdsUrl,
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
                Value<String> pdsUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                did: did,
                handle: handle,
                pdsUrl: pdsUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String did,
                required String handle,
                required String pdsUrl,
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                did: did,
                handle: handle,
                pdsUrl: pdsUrl,
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
typedef $$FeedCursorsTableCreateCompanionBuilder =
    FeedCursorsCompanion Function({
      required String feedKey,
      required String cursor,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });
typedef $$FeedCursorsTableUpdateCompanionBuilder =
    FeedCursorsCompanion Function({
      Value<String> feedKey,
      Value<String> cursor,
      Value<DateTime?> lastUpdated,
      Value<int> rowid,
    });

class $$FeedCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedCursorsTable> {
  $$FeedCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedCursorsTable> {
  $$FeedCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedKey => $composableBuilder(
    column: $table.feedKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedCursorsTable> {
  $$FeedCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedKey =>
      $composableBuilder(column: $table.feedKey, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
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
          (
            FeedCursor,
            BaseReferences<_$AppDatabase, $FeedCursorsTable, FeedCursor>,
          ),
          FeedCursor,
          PrefetchHooks Function()
        > {
  $$FeedCursorsTableTableManager(_$AppDatabase db, $FeedCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> feedKey = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedCursorsCompanion(
                feedKey: feedKey,
                cursor: cursor,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedKey,
                required String cursor,
                Value<DateTime?> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedCursorsCompanion.insert(
                feedKey: feedKey,
                cursor: cursor,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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
      (
        FeedCursor,
        BaseReferences<_$AppDatabase, $FeedCursorsTable, FeedCursor>,
      ),
      FeedCursor,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PostsTableTableManager get posts =>
      $$PostsTableTableManager(_db, _db.posts);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$TimelineItemsTableTableManager get timelineItems =>
      $$TimelineItemsTableTableManager(_db, _db.timelineItems);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$FeedCursorsTableTableManager get feedCursors =>
      $$FeedCursorsTableTableManager(_db, _db.feedCursors);
}
