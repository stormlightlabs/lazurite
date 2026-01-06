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
  static const VerificationMeta _authorDidMeta = const VerificationMeta('authorDid');
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
      embed: embed == null && nullToAbsent ? const Value.absent() : Value(embed),
      indexedAt: indexedAt == null && nullToAbsent ? const Value.absent() : Value(indexedAt),
      replyCount: Value(replyCount),
      repostCount: Value(repostCount),
      likeCount: Value(likeCount),
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
      replyCount: data.replyCount.present ? data.replyCount.value : this.replyCount,
      repostCount: data.repostCount.present ? data.repostCount.value : this.repostCount,
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
      displayName: displayName == null && nullToAbsent ? const Value.absent() : Value(displayName),
      description: description == null && nullToAbsent ? const Value.absent() : Value(description),
      avatar: avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      banner: banner == null && nullToAbsent ? const Value.absent() : Value(banner),
      indexedAt: indexedAt == null && nullToAbsent ? const Value.absent() : Value(indexedAt),
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
      displayName: data.displayName.present ? data.displayName.value : this.displayName,
      description: data.description.present ? data.description.value : this.description,
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
  int get hashCode =>
      Object.hash(did, handle, displayName, description, avatar, banner, indexedAt);
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
  List<GeneratedColumn> get $columns => [feedKey, postUri, reason, sortKey];
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
  Set<GeneratedColumn> get $primaryKey => {feedKey, postUri};
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
  final String? reason;
  final String sortKey;
  const FeedContentItem({
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

  FeedContentItemsCompanion toCompanion(bool nullToAbsent) {
    return FeedContentItemsCompanion(
      feedKey: Value(feedKey),
      postUri: Value(postUri),
      reason: reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      sortKey: Value(sortKey),
    );
  }

  factory FeedContentItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedContentItem(
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

  FeedContentItem copyWith({
    String? feedKey,
    String? postUri,
    Value<String?> reason = const Value.absent(),
    String? sortKey,
  }) => FeedContentItem(
    feedKey: feedKey ?? this.feedKey,
    postUri: postUri ?? this.postUri,
    reason: reason.present ? reason.value : this.reason,
    sortKey: sortKey ?? this.sortKey,
  );
  FeedContentItem copyWithCompanion(FeedContentItemsCompanion data) {
    return FeedContentItem(
      feedKey: data.feedKey.present ? data.feedKey.value : this.feedKey,
      postUri: data.postUri.present ? data.postUri.value : this.postUri,
      reason: data.reason.present ? data.reason.value : this.reason,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedContentItem(')
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
      (other is FeedContentItem &&
          other.feedKey == this.feedKey &&
          other.postUri == this.postUri &&
          other.reason == this.reason &&
          other.sortKey == this.sortKey);
}

class FeedContentItemsCompanion extends UpdateCompanion<FeedContentItem> {
  final Value<String> feedKey;
  final Value<String> postUri;
  final Value<String?> reason;
  final Value<String> sortKey;
  final Value<int> rowid;
  const FeedContentItemsCompanion({
    this.feedKey = const Value.absent(),
    this.postUri = const Value.absent(),
    this.reason = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedContentItemsCompanion.insert({
    required String feedKey,
    required String postUri,
    this.reason = const Value.absent(),
    required String sortKey,
    this.rowid = const Value.absent(),
  }) : feedKey = Value(feedKey),
       postUri = Value(postUri),
       sortKey = Value(sortKey);
  static Insertable<FeedContentItem> custom({
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

  FeedContentItemsCompanion copyWith({
    Value<String>? feedKey,
    Value<String>? postUri,
    Value<String?>? reason,
    Value<String>? sortKey,
    Value<int>? rowid,
  }) {
    return FeedContentItemsCompanion(
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
    return (StringBuffer('FeedContentItemsCompanion(')
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
      context.handle(_feedKeyMeta, feedKey.isAcceptableOrUnknown(data['feed_key']!, _feedKeyMeta));
    } else if (isInserting) {
      context.missing(_feedKeyMeta);
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
  const FeedCursor({required this.feedKey, required this.cursor, this.lastUpdated});
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
      lastUpdated: lastUpdated == null && nullToAbsent ? const Value.absent() : Value(lastUpdated),
    );
  }

  factory FeedCursor.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
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
      lastUpdated: data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
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
  Set<GeneratedColumn> get $primaryKey => {uri};
  @override
  SavedFeed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedFeed(
      uri: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uri'])!,
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
    Expression<DateTime>? localUpdatedAt,
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
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
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
    Value<DateTime?>? localUpdatedAt,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedUriMeta = const VerificationMeta('feedUri');
  @override
  late final GeneratedColumn<String> feedUri = GeneratedColumn<String>(
    'feed_uri',
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
  List<GeneratedColumn> get $columns => [id, type, feedUri, createdAt, retryCount];
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
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('feed_uri')) {
      context.handle(_feedUriMeta, feedUri.isAcceptableOrUnknown(data['feed_uri']!, _feedUriMeta));
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
  PreferenceSyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceSyncQueueData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
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

class PreferenceSyncQueueData extends DataClass implements Insertable<PreferenceSyncQueueData> {
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
      retryCount: data.retryCount.present ? data.retryCount.value : this.retryCount,
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

class PreferenceSyncQueueCompanion extends UpdateCompanion<PreferenceSyncQueueData> {
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
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
  late final Index feedContentSortIdx = Index(
    'feed_content_sort_idx',
    'CREATE INDEX feed_content_sort_idx ON feed_content_items (feed_key, sort_key)',
  );
  late final Index searchCacheSortIdx = Index(
    'search_cache_sort_idx',
    'CREATE INDEX search_cache_sort_idx ON search_cache_items (query_key, sort_key)',
  );
  late final FeedContentDao feedContentDao = FeedContentDao(this as AppDatabase);
  late final ProfileDao profileDao = ProfileDao(this as AppDatabase);
  late final SearchDao searchDao = SearchDao(this as AppDatabase);
  late final SearchCacheDao searchCacheDao = SearchCacheDao(this as AppDatabase);
  late final FollowsDao followsDao = FollowsDao(this as AppDatabase);
  late final SavedFeedsDao savedFeedsDao = SavedFeedsDao(this as AppDatabase);
  late final PreferenceSyncQueueDao preferenceSyncQueueDao = PreferenceSyncQueueDao(
    this as AppDatabase,
  );
  late final DraftsDao draftsDao = DraftsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    posts,
    profiles,
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
    feedContentSortIdx,
    searchCacheSortIdx,
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

final class $$PostsTableReferences extends BaseReferences<_$AppDatabase, $PostsTable, Post> {
  $$PostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

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

  ColumnFilters<String> get authorDid =>
      $composableBuilder(column: $table.authorDid, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get authorDid =>
      $composableBuilder(column: $table.authorDid, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get authorDid =>
      $composableBuilder(column: $table.authorDid, builder: (column) => column);

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
          PrefetchHooks Function({bool feedContentItemsRefs, bool searchCacheItemsRefs})
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$PostsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({feedContentItemsRefs = false, searchCacheItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (feedContentItemsRefs) db.feedContentItems,
                if (searchCacheItemsRefs) db.searchCacheItems,
              ],
              addJoins: null,
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
      PrefetchHooks Function({bool feedContentItemsRefs, bool searchCacheItemsRefs})
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
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
typedef $$FeedContentItemsTableCreateCompanionBuilder =
    FeedContentItemsCompanion Function({
      required String feedKey,
      required String postUri,
      Value<String?> reason,
      required String sortKey,
      Value<int> rowid,
    });
typedef $$FeedContentItemsTableUpdateCompanionBuilder =
    FeedContentItemsCompanion Function({
      Value<String> feedKey,
      Value<String> postUri,
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
                Value<String?> reason = const Value.absent(),
                Value<String> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedContentItemsCompanion(
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
              }) => FeedContentItemsCompanion.insert(
                feedKey: feedKey,
                postUri: postUri,
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

  ColumnFilters<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get creatorDid =>
      $composableBuilder(column: $table.creatorDid, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get creatorDid =>
      $composableBuilder(column: $table.creatorDid, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get displayName =>
      $composableBuilder(column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get creatorDid =>
      $composableBuilder(column: $table.creatorDid, builder: (column) => column);

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
          (SavedFeed, BaseReferences<_$AppDatabase, $SavedFeedsTable, SavedFeed>),
          SavedFeed,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
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
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedUri =>
      $composableBuilder(column: $table.feedUri, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedUri =>
      $composableBuilder(column: $table.feedUri, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get feedUri =>
      $composableBuilder(column: $table.feedUri, builder: (column) => column);

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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PostsTableTableManager get posts => $$PostsTableTableManager(_db, _db.posts);
  $$ProfilesTableTableManager get profiles => $$ProfilesTableTableManager(_db, _db.profiles);
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
}
