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
  static const VerificationMeta _embedMeta = const VerificationMeta('embed');
  @override
  late final GeneratedColumn<String> embed = GeneratedColumn<String>(
    'embed',
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
  static const VerificationMeta _replyCountMeta = const VerificationMeta(
    'replyCount',
  );
  @override
  late final GeneratedColumn<int> replyCount = GeneratedColumn<int>(
    'reply_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repostCountMeta = const VerificationMeta(
    'repostCount',
  );
  @override
  late final GeneratedColumn<int> repostCount = GeneratedColumn<int>(
    'repost_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    if (data.containsKey('embed')) {
      context.handle(
        _embedMeta,
        embed.isAcceptableOrUnknown(data['embed']!, _embedMeta),
      );
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
        repostCount.isAcceptableOrUnknown(
          data['repost_count']!,
          _repostCountMeta,
        ),
      );
    }
    if (data.containsKey('like_count')) {
      context.handle(
        _likeCountMeta,
        likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta),
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
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      uri: Value(uri),
      cid: Value(cid),
      authorDid: Value(authorDid),
      record: Value(record),
      embed: embed == null && nullToAbsent
          ? const Value.absent()
          : Value(embed),
      indexedAt: indexedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(indexedAt),
      replyCount: Value(replyCount),
      repostCount: Value(repostCount),
      likeCount: Value(likeCount),
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
      embed: serializer.fromJson<String?>(json['embed']),
      indexedAt: serializer.fromJson<DateTime?>(json['indexedAt']),
      replyCount: serializer.fromJson<int>(json['replyCount']),
      repostCount: serializer.fromJson<int>(json['repostCount']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
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
  );
  Post copyWithCompanion(PostsCompanion data) {
    return Post(
      uri: data.uri.present ? data.uri.value : this.uri,
      cid: data.cid.present ? data.cid.value : this.cid,
      authorDid: data.authorDid.present ? data.authorDid.value : this.authorDid,
      record: data.record.present ? data.record.value : this.record,
      embed: data.embed.present ? data.embed.value : this.embed,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
      replyCount: data.replyCount.present
          ? data.replyCount.value
          : this.replyCount,
      repostCount: data.repostCount.present
          ? data.repostCount.value
          : this.repostCount,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
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
          ..write('likeCount: $likeCount')
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
          other.likeCount == this.likeCount);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
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
  const RecentSearche({
    required this.id,
    required this.query,
    required this.searchedAt,
  });
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

  factory RecentSearche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  RecentSearche copyWith({int? id, String? query, DateTime? searchedAt}) =>
      RecentSearche(
        id: id ?? this.id,
        query: query ?? this.query,
        searchedAt: searchedAt ?? this.searchedAt,
      );
  RecentSearche copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearche(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
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

class $FollowsTable extends Follows with TableInfo<$FollowsTable, Follow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FollowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _actorDidMeta = const VerificationMeta(
    'actorDid',
  );
  @override
  late final GeneratedColumn<String> actorDid = GeneratedColumn<String>(
    'actor_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectDidMeta = const VerificationMeta(
    'subjectDid',
  );
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
  @override
  List<GeneratedColumn> get $columns => [actorDid, subjectDid, uri, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'follows';
  @override
  VerificationContext validateIntegrity(
    Insertable<Follow> instance, {
    bool isInserting = false,
  }) {
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
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
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
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
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
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Follow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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
      subjectDid: data.subjectDid.present
          ? data.subjectDid.value
          : this.subjectDid,
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

class $SavedFeedsTable extends SavedFeeds
    with TableInfo<$SavedFeedsTable, SavedFeed> {
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
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
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creatorDidMeta = const VerificationMeta(
    'creatorDid',
  );
  @override
  late final GeneratedColumn<String> creatorDid = GeneratedColumn<String>(
    'creator_did',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _likeCountMeta = const VerificationMeta(
    'likeCount',
  );
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
    'like_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta(
    'lastSynced',
  );
  @override
  late final GeneratedColumn<DateTime> lastSynced = GeneratedColumn<DateTime>(
    'last_synced',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uri,
    displayName,
    description,
    avatar,
    creatorDid,
    likeCount,
    sortOrder,
    isPinned,
    lastSynced,
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
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    } else if (isInserting) {
      context.missing(_uriMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uri};
  @override
  SavedFeed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedFeed(
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
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
  const SavedFeed({
    required this.uri,
    required this.displayName,
    this.description,
    this.avatar,
    required this.creatorDid,
    required this.likeCount,
    required this.sortOrder,
    required this.isPinned,
    required this.lastSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uri'] = Variable<String>(uri);
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
    return map;
  }

  SavedFeedsCompanion toCompanion(bool nullToAbsent) {
    return SavedFeedsCompanion(
      uri: Value(uri),
      displayName: Value(displayName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      creatorDid: Value(creatorDid),
      likeCount: Value(likeCount),
      sortOrder: Value(sortOrder),
      isPinned: Value(isPinned),
      lastSynced: Value(lastSynced),
    );
  }

  factory SavedFeed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedFeed(
      uri: serializer.fromJson<String>(json['uri']),
      displayName: serializer.fromJson<String>(json['displayName']),
      description: serializer.fromJson<String?>(json['description']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      creatorDid: serializer.fromJson<String>(json['creatorDid']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      lastSynced: serializer.fromJson<DateTime>(json['lastSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uri': serializer.toJson<String>(uri),
      'displayName': serializer.toJson<String>(displayName),
      'description': serializer.toJson<String?>(description),
      'avatar': serializer.toJson<String?>(avatar),
      'creatorDid': serializer.toJson<String>(creatorDid),
      'likeCount': serializer.toJson<int>(likeCount),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isPinned': serializer.toJson<bool>(isPinned),
      'lastSynced': serializer.toJson<DateTime>(lastSynced),
    };
  }

  SavedFeed copyWith({
    String? uri,
    String? displayName,
    Value<String?> description = const Value.absent(),
    Value<String?> avatar = const Value.absent(),
    String? creatorDid,
    int? likeCount,
    int? sortOrder,
    bool? isPinned,
    DateTime? lastSynced,
  }) => SavedFeed(
    uri: uri ?? this.uri,
    displayName: displayName ?? this.displayName,
    description: description.present ? description.value : this.description,
    avatar: avatar.present ? avatar.value : this.avatar,
    creatorDid: creatorDid ?? this.creatorDid,
    likeCount: likeCount ?? this.likeCount,
    sortOrder: sortOrder ?? this.sortOrder,
    isPinned: isPinned ?? this.isPinned,
    lastSynced: lastSynced ?? this.lastSynced,
  );
  SavedFeed copyWithCompanion(SavedFeedsCompanion data) {
    return SavedFeed(
      uri: data.uri.present ? data.uri.value : this.uri,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      description: data.description.present
          ? data.description.value
          : this.description,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      creatorDid: data.creatorDid.present
          ? data.creatorDid.value
          : this.creatorDid,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      lastSynced: data.lastSynced.present
          ? data.lastSynced.value
          : this.lastSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedFeed(')
          ..write('uri: $uri, ')
          ..write('displayName: $displayName, ')
          ..write('description: $description, ')
          ..write('avatar: $avatar, ')
          ..write('creatorDid: $creatorDid, ')
          ..write('likeCount: $likeCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPinned: $isPinned, ')
          ..write('lastSynced: $lastSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uri,
    displayName,
    description,
    avatar,
    creatorDid,
    likeCount,
    sortOrder,
    isPinned,
    lastSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedFeed &&
          other.uri == this.uri &&
          other.displayName == this.displayName &&
          other.description == this.description &&
          other.avatar == this.avatar &&
          other.creatorDid == this.creatorDid &&
          other.likeCount == this.likeCount &&
          other.sortOrder == this.sortOrder &&
          other.isPinned == this.isPinned &&
          other.lastSynced == this.lastSynced);
}

class SavedFeedsCompanion extends UpdateCompanion<SavedFeed> {
  final Value<String> uri;
  final Value<String> displayName;
  final Value<String?> description;
  final Value<String?> avatar;
  final Value<String> creatorDid;
  final Value<int> likeCount;
  final Value<int> sortOrder;
  final Value<bool> isPinned;
  final Value<DateTime> lastSynced;
  final Value<int> rowid;
  const SavedFeedsCompanion({
    this.uri = const Value.absent(),
    this.displayName = const Value.absent(),
    this.description = const Value.absent(),
    this.avatar = const Value.absent(),
    this.creatorDid = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedFeedsCompanion.insert({
    required String uri,
    required String displayName,
    this.description = const Value.absent(),
    this.avatar = const Value.absent(),
    required String creatorDid,
    this.likeCount = const Value.absent(),
    required int sortOrder,
    this.isPinned = const Value.absent(),
    required DateTime lastSynced,
    this.rowid = const Value.absent(),
  }) : uri = Value(uri),
       displayName = Value(displayName),
       creatorDid = Value(creatorDid),
       sortOrder = Value(sortOrder),
       lastSynced = Value(lastSynced);
  static Insertable<SavedFeed> custom({
    Expression<String>? uri,
    Expression<String>? displayName,
    Expression<String>? description,
    Expression<String>? avatar,
    Expression<String>? creatorDid,
    Expression<int>? likeCount,
    Expression<int>? sortOrder,
    Expression<bool>? isPinned,
    Expression<DateTime>? lastSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uri != null) 'uri': uri,
      if (displayName != null) 'display_name': displayName,
      if (description != null) 'description': description,
      if (avatar != null) 'avatar': avatar,
      if (creatorDid != null) 'creator_did': creatorDid,
      if (likeCount != null) 'like_count': likeCount,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isPinned != null) 'is_pinned': isPinned,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedFeedsCompanion copyWith({
    Value<String>? uri,
    Value<String>? displayName,
    Value<String?>? description,
    Value<String?>? avatar,
    Value<String>? creatorDid,
    Value<int>? likeCount,
    Value<int>? sortOrder,
    Value<bool>? isPinned,
    Value<DateTime>? lastSynced,
    Value<int>? rowid,
  }) {
    return SavedFeedsCompanion(
      uri: uri ?? this.uri,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      creatorDid: creatorDid ?? this.creatorDid,
      likeCount: likeCount ?? this.likeCount,
      sortOrder: sortOrder ?? this.sortOrder,
      isPinned: isPinned ?? this.isPinned,
      lastSynced: lastSynced ?? this.lastSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedFeedsCompanion(')
          ..write('uri: $uri, ')
          ..write('displayName: $displayName, ')
          ..write('description: $description, ')
          ..write('avatar: $avatar, ')
          ..write('creatorDid: $creatorDid, ')
          ..write('likeCount: $likeCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPinned: $isPinned, ')
          ..write('lastSynced: $lastSynced, ')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _feedUriMeta = const VerificationMeta(
    'feedUri',
  );
  @override
  late final GeneratedColumn<String> feedUri = GeneratedColumn<String>(
    'feed_uri',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    feedUri,
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('feed_uri')) {
      context.handle(
        _feedUriMeta,
        feedUri.isAcceptableOrUnknown(data['feed_uri']!, _feedUriMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUriMeta);
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
  PreferenceSyncQueueData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceSyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      feedUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_uri'],
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

class PreferenceSyncQueueData extends DataClass
    implements Insertable<PreferenceSyncQueueData> {
  final int id;

  /// Type of operation: 'save' or 'remove'.
  final String type;

  /// The feed URI to sync.
  final String feedUri;

  /// When the item was queued.
  final DateTime createdAt;

  /// Number of times we've tried to process this item.
  final int retryCount;
  const PreferenceSyncQueueData({
    required this.id,
    required this.type,
    required this.feedUri,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['feed_uri'] = Variable<String>(feedUri);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  PreferenceSyncQueueCompanion toCompanion(bool nullToAbsent) {
    return PreferenceSyncQueueCompanion(
      id: Value(id),
      type: Value(type),
      feedUri: Value(feedUri),
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
      type: serializer.fromJson<String>(json['type']),
      feedUri: serializer.fromJson<String>(json['feedUri']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'feedUri': serializer.toJson<String>(feedUri),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  PreferenceSyncQueueData copyWith({
    int? id,
    String? type,
    String? feedUri,
    DateTime? createdAt,
    int? retryCount,
  }) => PreferenceSyncQueueData(
    id: id ?? this.id,
    type: type ?? this.type,
    feedUri: feedUri ?? this.feedUri,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  PreferenceSyncQueueData copyWithCompanion(PreferenceSyncQueueCompanion data) {
    return PreferenceSyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      feedUri: data.feedUri.present ? data.feedUri.value : this.feedUri,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceSyncQueueData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('feedUri: $feedUri, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, feedUri, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceSyncQueueData &&
          other.id == this.id &&
          other.type == this.type &&
          other.feedUri == this.feedUri &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class PreferenceSyncQueueCompanion
    extends UpdateCompanion<PreferenceSyncQueueData> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> feedUri;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const PreferenceSyncQueueCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.feedUri = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  PreferenceSyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String feedUri,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
  }) : type = Value(type),
       feedUri = Value(feedUri),
       createdAt = Value(createdAt);
  static Insertable<PreferenceSyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? feedUri,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (feedUri != null) 'feed_uri': feedUri,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  PreferenceSyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? feedUri,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
  }) {
    return PreferenceSyncQueueCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      feedUri: feedUri ?? this.feedUri,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (feedUri.present) {
      map['feed_uri'] = Variable<String>(feedUri.value);
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
          ..write('type: $type, ')
          ..write('feedUri: $feedUri, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
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
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  late final $FollowsTable follows = $FollowsTable(this);
  late final $SavedFeedsTable savedFeeds = $SavedFeedsTable(this);
  late final $PreferenceSyncQueueTable preferenceSyncQueue =
      $PreferenceSyncQueueTable(this);
  late final Index timelineSortIdx = Index(
    'timeline_sort_idx',
    'CREATE INDEX timeline_sort_idx ON timeline_items (feed_key, sort_key)',
  );
  late final TimelineDao timelineDao = TimelineDao(this as AppDatabase);
  late final ProfileDao profileDao = ProfileDao(this as AppDatabase);
  late final SearchDao searchDao = SearchDao(this as AppDatabase);
  late final FollowsDao followsDao = FollowsDao(this as AppDatabase);
  late final SavedFeedsDao savedFeedsDao = SavedFeedsDao(this as AppDatabase);
  late final PreferenceSyncQueueDao preferenceSyncQueueDao =
      PreferenceSyncQueueDao(this as AppDatabase);
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
    recentSearches,
    follows,
    savedFeeds,
    preferenceSyncQueue,
    timelineSortIdx,
  ];
}

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

  ColumnFilters<String> get embed => $composableBuilder(
    column: $table.embed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repostCount => $composableBuilder(
    column: $table.repostCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
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

  ColumnOrderings<String> get embed => $composableBuilder(
    column: $table.embed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repostCount => $composableBuilder(
    column: $table.repostCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
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

  GeneratedColumn<String> get embed =>
      $composableBuilder(column: $table.embed, builder: (column) => column);

  GeneratedColumn<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);

  GeneratedColumn<int> get replyCount => $composableBuilder(
    column: $table.replyCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repostCount => $composableBuilder(
    column: $table.repostCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

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
                Value<String?> embed = const Value.absent(),
                Value<DateTime?> indexedAt = const Value.absent(),
                Value<int> replyCount = const Value.absent(),
                Value<int> repostCount = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
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

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
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

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
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
          (
            RecentSearche,
            BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>,
          ),
          RecentSearche,
          PrefetchHooks Function()
        > {
  $$RecentSearchesTableTableManager(
    _$AppDatabase db,
    $RecentSearchesTable table,
  ) : super(
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
              }) => RecentSearchesCompanion(
                id: id,
                query: query,
                searchedAt: searchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required DateTime searchedAt,
              }) => RecentSearchesCompanion.insert(
                id: id,
                query: query,
                searchedAt: searchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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
      (
        RecentSearche,
        BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearche>,
      ),
      RecentSearche,
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

class $$FollowsTableFilterComposer
    extends Composer<_$AppDatabase, $FollowsTable> {
  $$FollowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get actorDid => $composableBuilder(
    column: $table.actorDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectDid => $composableBuilder(
    column: $table.subjectDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FollowsTableOrderingComposer
    extends Composer<_$AppDatabase, $FollowsTable> {
  $$FollowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get actorDid => $composableBuilder(
    column: $table.actorDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectDid => $composableBuilder(
    column: $table.subjectDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FollowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FollowsTable> {
  $$FollowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get actorDid =>
      $composableBuilder(column: $table.actorDid, builder: (column) => column);

  GeneratedColumn<String> get subjectDid => $composableBuilder(
    column: $table.subjectDid,
    builder: (column) => column,
  );

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
          createFilteringComposer: () =>
              $$FollowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FollowsTableOrderingComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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
      required String displayName,
      Value<String?> description,
      Value<String?> avatar,
      required String creatorDid,
      Value<int> likeCount,
      required int sortOrder,
      Value<bool> isPinned,
      required DateTime lastSynced,
      Value<int> rowid,
    });
typedef $$SavedFeedsTableUpdateCompanionBuilder =
    SavedFeedsCompanion Function({
      Value<String> uri,
      Value<String> displayName,
      Value<String?> description,
      Value<String?> avatar,
      Value<String> creatorDid,
      Value<int> likeCount,
      Value<int> sortOrder,
      Value<bool> isPinned,
      Value<DateTime> lastSynced,
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
  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
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

  ColumnFilters<String> get creatorDid => $composableBuilder(
    column: $table.creatorDid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
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
  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
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

  ColumnOrderings<String> get creatorDid => $composableBuilder(
    column: $table.creatorDid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likeCount => $composableBuilder(
    column: $table.likeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
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
  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

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

  GeneratedColumn<String> get creatorDid => $composableBuilder(
    column: $table.creatorDid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => column,
  );
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
          (
            SavedFeed,
            BaseReferences<_$AppDatabase, $SavedFeedsTable, SavedFeed>,
          ),
          SavedFeed,
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
                Value<String> uri = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String> creatorDid = const Value.absent(),
                Value<int> likeCount = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<DateTime> lastSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedFeedsCompanion(
                uri: uri,
                displayName: displayName,
                description: description,
                avatar: avatar,
                creatorDid: creatorDid,
                likeCount: likeCount,
                sortOrder: sortOrder,
                isPinned: isPinned,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uri,
                required String displayName,
                Value<String?> description = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                required String creatorDid,
                Value<int> likeCount = const Value.absent(),
                required int sortOrder,
                Value<bool> isPinned = const Value.absent(),
                required DateTime lastSynced,
                Value<int> rowid = const Value.absent(),
              }) => SavedFeedsCompanion.insert(
                uri: uri,
                displayName: displayName,
                description: description,
                avatar: avatar,
                creatorDid: creatorDid,
                likeCount: likeCount,
                sortOrder: sortOrder,
                isPinned: isPinned,
                lastSynced: lastSynced,
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
      SavedFeed,
      $$SavedFeedsTableFilterComposer,
      $$SavedFeedsTableOrderingComposer,
      $$SavedFeedsTableAnnotationComposer,
      $$SavedFeedsTableCreateCompanionBuilder,
      $$SavedFeedsTableUpdateCompanionBuilder,
      (SavedFeed, BaseReferences<_$AppDatabase, $SavedFeedsTable, SavedFeed>),
      SavedFeed,
      PrefetchHooks Function()
    >;
typedef $$PreferenceSyncQueueTableCreateCompanionBuilder =
    PreferenceSyncQueueCompanion Function({
      Value<int> id,
      required String type,
      required String feedUri,
      required DateTime createdAt,
      Value<int> retryCount,
    });
typedef $$PreferenceSyncQueueTableUpdateCompanionBuilder =
    PreferenceSyncQueueCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> feedUri,
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUri => $composableBuilder(
    column: $table.feedUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUri => $composableBuilder(
    column: $table.feedUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get feedUri =>
      $composableBuilder(column: $table.feedUri, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
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
            BaseReferences<
              _$AppDatabase,
              $PreferenceSyncQueueTable,
              PreferenceSyncQueueData
            >,
          ),
          PreferenceSyncQueueData,
          PrefetchHooks Function()
        > {
  $$PreferenceSyncQueueTableTableManager(
    _$AppDatabase db,
    $PreferenceSyncQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenceSyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenceSyncQueueTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PreferenceSyncQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> feedUri = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => PreferenceSyncQueueCompanion(
                id: id,
                type: type,
                feedUri: feedUri,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String feedUri,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
              }) => PreferenceSyncQueueCompanion.insert(
                id: id,
                type: type,
                feedUri: feedUri,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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
        BaseReferences<
          _$AppDatabase,
          $PreferenceSyncQueueTable,
          PreferenceSyncQueueData
        >,
      ),
      PreferenceSyncQueueData,
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
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
  $$FollowsTableTableManager get follows =>
      $$FollowsTableTableManager(_db, _db.follows);
  $$SavedFeedsTableTableManager get savedFeeds =>
      $$SavedFeedsTableTableManager(_db, _db.savedFeeds);
  $$PreferenceSyncQueueTableTableManager get preferenceSyncQueue =>
      $$PreferenceSyncQueueTableTableManager(_db, _db.preferenceSyncQueue);
}
