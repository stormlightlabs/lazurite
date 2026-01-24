// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
ThreadViewPost _$ThreadViewPostFromJson(
  Map<String, dynamic> json
) {
        switch (json['\$type']) {
                  case 'app.bsky.feed.defs#threadViewPost':
          return _ThreadViewPostView.fromJson(
            json
          );
                case 'app.bsky.feed.defs#blockedPost':
          return _ThreadViewPostBlocked.fromJson(
            json
          );
                case 'app.bsky.feed.defs#notFoundPost':
          return _ThreadViewPostNotFound.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  '\$type',
  'ThreadViewPost',
  'Invalid union type "${json['\$type']}"!'
);
        }
      
}

/// @nodoc
mixin _$ThreadViewPost {



  /// Serializes this ThreadViewPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadViewPost);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ThreadViewPost()';
}


}

/// @nodoc
class $ThreadViewPostCopyWith<$Res>  {
$ThreadViewPostCopyWith(ThreadViewPost _, $Res Function(ThreadViewPost) __);
}


/// Adds pattern-matching-related methods to [ThreadViewPost].
extension ThreadViewPostPatterns on ThreadViewPost {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ThreadViewPostView value)?  item,TResult Function( _ThreadViewPostBlocked value)?  blocked,TResult Function( _ThreadViewPostNotFound value)?  notFound,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadViewPostView() when item != null:
return item(_that);case _ThreadViewPostBlocked() when blocked != null:
return blocked(_that);case _ThreadViewPostNotFound() when notFound != null:
return notFound(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ThreadViewPostView value)  item,required TResult Function( _ThreadViewPostBlocked value)  blocked,required TResult Function( _ThreadViewPostNotFound value)  notFound,}){
final _that = this;
switch (_that) {
case _ThreadViewPostView():
return item(_that);case _ThreadViewPostBlocked():
return blocked(_that);case _ThreadViewPostNotFound():
return notFound(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ThreadViewPostView value)?  item,TResult? Function( _ThreadViewPostBlocked value)?  blocked,TResult? Function( _ThreadViewPostNotFound value)?  notFound,}){
final _that = this;
switch (_that) {
case _ThreadViewPostView() when item != null:
return item(_that);case _ThreadViewPostBlocked() when blocked != null:
return blocked(_that);case _ThreadViewPostNotFound() when notFound != null:
return notFound(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ThreadPost post,  ThreadViewPost? parent,  List<ThreadViewPost> replies,  Threadgate? threadgate)?  item,TResult Function( String uri,  bool blocked,  ThreadAuthor? author)?  blocked,TResult Function( String uri,  bool notFound)?  notFound,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadViewPostView() when item != null:
return item(_that.post,_that.parent,_that.replies,_that.threadgate);case _ThreadViewPostBlocked() when blocked != null:
return blocked(_that.uri,_that.blocked,_that.author);case _ThreadViewPostNotFound() when notFound != null:
return notFound(_that.uri,_that.notFound);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ThreadPost post,  ThreadViewPost? parent,  List<ThreadViewPost> replies,  Threadgate? threadgate)  item,required TResult Function( String uri,  bool blocked,  ThreadAuthor? author)  blocked,required TResult Function( String uri,  bool notFound)  notFound,}) {final _that = this;
switch (_that) {
case _ThreadViewPostView():
return item(_that.post,_that.parent,_that.replies,_that.threadgate);case _ThreadViewPostBlocked():
return blocked(_that.uri,_that.blocked,_that.author);case _ThreadViewPostNotFound():
return notFound(_that.uri,_that.notFound);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ThreadPost post,  ThreadViewPost? parent,  List<ThreadViewPost> replies,  Threadgate? threadgate)?  item,TResult? Function( String uri,  bool blocked,  ThreadAuthor? author)?  blocked,TResult? Function( String uri,  bool notFound)?  notFound,}) {final _that = this;
switch (_that) {
case _ThreadViewPostView() when item != null:
return item(_that.post,_that.parent,_that.replies,_that.threadgate);case _ThreadViewPostBlocked() when blocked != null:
return blocked(_that.uri,_that.blocked,_that.author);case _ThreadViewPostNotFound() when notFound != null:
return notFound(_that.uri,_that.notFound);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadViewPostView extends ThreadViewPost {
  const _ThreadViewPostView({required this.post, this.parent, final  List<ThreadViewPost> replies = const [], this.threadgate, final  String? $type}): _replies = replies,$type = $type ?? 'app.bsky.feed.defs#threadViewPost',super._();
  factory _ThreadViewPostView.fromJson(Map<String, dynamic> json) => _$ThreadViewPostViewFromJson(json);

 final  ThreadPost post;
 final  ThreadViewPost? parent;
 final  List<ThreadViewPost> _replies;
@JsonKey() List<ThreadViewPost> get replies {
  if (_replies is EqualUnmodifiableListView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_replies);
}

 final  Threadgate? threadgate;

@JsonKey(name: '\$type')
final String $type;


/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadViewPostViewCopyWith<_ThreadViewPostView> get copyWith => __$ThreadViewPostViewCopyWithImpl<_ThreadViewPostView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadViewPostViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadViewPostView&&(identical(other.post, post) || other.post == post)&&(identical(other.parent, parent) || other.parent == parent)&&const DeepCollectionEquality().equals(other._replies, _replies)&&(identical(other.threadgate, threadgate) || other.threadgate == threadgate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,post,parent,const DeepCollectionEquality().hash(_replies),threadgate);

@override
String toString() {
  return 'ThreadViewPost.item(post: $post, parent: $parent, replies: $replies, threadgate: $threadgate)';
}


}

/// @nodoc
abstract mixin class _$ThreadViewPostViewCopyWith<$Res> implements $ThreadViewPostCopyWith<$Res> {
  factory _$ThreadViewPostViewCopyWith(_ThreadViewPostView value, $Res Function(_ThreadViewPostView) _then) = __$ThreadViewPostViewCopyWithImpl;
@useResult
$Res call({
 ThreadPost post, ThreadViewPost? parent, List<ThreadViewPost> replies, Threadgate? threadgate
});


$ThreadPostCopyWith<$Res> get post;$ThreadViewPostCopyWith<$Res>? get parent;$ThreadgateCopyWith<$Res>? get threadgate;

}
/// @nodoc
class __$ThreadViewPostViewCopyWithImpl<$Res>
    implements _$ThreadViewPostViewCopyWith<$Res> {
  __$ThreadViewPostViewCopyWithImpl(this._self, this._then);

  final _ThreadViewPostView _self;
  final $Res Function(_ThreadViewPostView) _then;

/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? post = null,Object? parent = freezed,Object? replies = null,Object? threadgate = freezed,}) {
  return _then(_ThreadViewPostView(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as ThreadPost,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as ThreadViewPost?,replies: null == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as List<ThreadViewPost>,threadgate: freezed == threadgate ? _self.threadgate : threadgate // ignore: cast_nullable_to_non_nullable
as Threadgate?,
  ));
}

/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadPostCopyWith<$Res> get post {
  
  return $ThreadPostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadViewPostCopyWith<$Res>? get parent {
    if (_self.parent == null) {
    return null;
  }

  return $ThreadViewPostCopyWith<$Res>(_self.parent!, (value) {
    return _then(_self.copyWith(parent: value));
  });
}/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadgateCopyWith<$Res>? get threadgate {
    if (_self.threadgate == null) {
    return null;
  }

  return $ThreadgateCopyWith<$Res>(_self.threadgate!, (value) {
    return _then(_self.copyWith(threadgate: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class _ThreadViewPostBlocked extends ThreadViewPost {
  const _ThreadViewPostBlocked({required this.uri, this.blocked = true, this.author, final  String? $type}): $type = $type ?? 'app.bsky.feed.defs#blockedPost',super._();
  factory _ThreadViewPostBlocked.fromJson(Map<String, dynamic> json) => _$ThreadViewPostBlockedFromJson(json);

 final  String uri;
@JsonKey() final  bool blocked;
 final  ThreadAuthor? author;

@JsonKey(name: '\$type')
final String $type;


/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadViewPostBlockedCopyWith<_ThreadViewPostBlocked> get copyWith => __$ThreadViewPostBlockedCopyWithImpl<_ThreadViewPostBlocked>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadViewPostBlockedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadViewPostBlocked&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.blocked, blocked) || other.blocked == blocked)&&(identical(other.author, author) || other.author == author));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,blocked,author);

@override
String toString() {
  return 'ThreadViewPost.blocked(uri: $uri, blocked: $blocked, author: $author)';
}


}

/// @nodoc
abstract mixin class _$ThreadViewPostBlockedCopyWith<$Res> implements $ThreadViewPostCopyWith<$Res> {
  factory _$ThreadViewPostBlockedCopyWith(_ThreadViewPostBlocked value, $Res Function(_ThreadViewPostBlocked) _then) = __$ThreadViewPostBlockedCopyWithImpl;
@useResult
$Res call({
 String uri, bool blocked, ThreadAuthor? author
});


$ThreadAuthorCopyWith<$Res>? get author;

}
/// @nodoc
class __$ThreadViewPostBlockedCopyWithImpl<$Res>
    implements _$ThreadViewPostBlockedCopyWith<$Res> {
  __$ThreadViewPostBlockedCopyWithImpl(this._self, this._then);

  final _ThreadViewPostBlocked _self;
  final $Res Function(_ThreadViewPostBlocked) _then;

/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? blocked = null,Object? author = freezed,}) {
  return _then(_ThreadViewPostBlocked(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as bool,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ThreadAuthor?,
  ));
}

/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadAuthorCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $ThreadAuthorCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class _ThreadViewPostNotFound extends ThreadViewPost {
  const _ThreadViewPostNotFound({required this.uri, this.notFound = true, final  String? $type}): $type = $type ?? 'app.bsky.feed.defs#notFoundPost',super._();
  factory _ThreadViewPostNotFound.fromJson(Map<String, dynamic> json) => _$ThreadViewPostNotFoundFromJson(json);

 final  String uri;
@JsonKey() final  bool notFound;

@JsonKey(name: '\$type')
final String $type;


/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadViewPostNotFoundCopyWith<_ThreadViewPostNotFound> get copyWith => __$ThreadViewPostNotFoundCopyWithImpl<_ThreadViewPostNotFound>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadViewPostNotFoundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadViewPostNotFound&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.notFound, notFound) || other.notFound == notFound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,notFound);

@override
String toString() {
  return 'ThreadViewPost.notFound(uri: $uri, notFound: $notFound)';
}


}

/// @nodoc
abstract mixin class _$ThreadViewPostNotFoundCopyWith<$Res> implements $ThreadViewPostCopyWith<$Res> {
  factory _$ThreadViewPostNotFoundCopyWith(_ThreadViewPostNotFound value, $Res Function(_ThreadViewPostNotFound) _then) = __$ThreadViewPostNotFoundCopyWithImpl;
@useResult
$Res call({
 String uri, bool notFound
});




}
/// @nodoc
class __$ThreadViewPostNotFoundCopyWithImpl<$Res>
    implements _$ThreadViewPostNotFoundCopyWith<$Res> {
  __$ThreadViewPostNotFoundCopyWithImpl(this._self, this._then);

  final _ThreadViewPostNotFound _self;
  final $Res Function(_ThreadViewPostNotFound) _then;

/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? notFound = null,}) {
  return _then(_ThreadViewPostNotFound(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ThreadPost {

 String get uri; String? get cid; ThreadAuthor get author; Map<String, dynamic> get record;@JsonKey(fromJson: _transformEmbed) String? get embed; DateTime? get indexedAt; int get replyCount; int get repostCount; int get likeCount; int get quoteCount; int get bookmarkCount; List<ContentLabel>? get labels; PostViewer? get viewer; String? get placeholderReason; bool get isBlocked; bool get isNotFound;
/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadPostCopyWith<ThreadPost> get copyWith => _$ThreadPostCopyWithImpl<ThreadPost>(this as ThreadPost, _$identity);

  /// Serializes this ThreadPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadPost&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other.record, record)&&(identical(other.embed, embed) || other.embed == embed)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.repostCount, repostCount) || other.repostCount == repostCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.quoteCount, quoteCount) || other.quoteCount == quoteCount)&&(identical(other.bookmarkCount, bookmarkCount) || other.bookmarkCount == bookmarkCount)&&const DeepCollectionEquality().equals(other.labels, labels)&&(identical(other.viewer, viewer) || other.viewer == viewer)&&(identical(other.placeholderReason, placeholderReason) || other.placeholderReason == placeholderReason)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isNotFound, isNotFound) || other.isNotFound == isNotFound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,cid,author,const DeepCollectionEquality().hash(record),embed,indexedAt,replyCount,repostCount,likeCount,quoteCount,bookmarkCount,const DeepCollectionEquality().hash(labels),viewer,placeholderReason,isBlocked,isNotFound);

@override
String toString() {
  return 'ThreadPost(uri: $uri, cid: $cid, author: $author, record: $record, embed: $embed, indexedAt: $indexedAt, replyCount: $replyCount, repostCount: $repostCount, likeCount: $likeCount, quoteCount: $quoteCount, bookmarkCount: $bookmarkCount, labels: $labels, viewer: $viewer, placeholderReason: $placeholderReason, isBlocked: $isBlocked, isNotFound: $isNotFound)';
}


}

/// @nodoc
abstract mixin class $ThreadPostCopyWith<$Res>  {
  factory $ThreadPostCopyWith(ThreadPost value, $Res Function(ThreadPost) _then) = _$ThreadPostCopyWithImpl;
@useResult
$Res call({
 String uri, String? cid, ThreadAuthor author, Map<String, dynamic> record,@JsonKey(fromJson: _transformEmbed) String? embed, DateTime? indexedAt, int replyCount, int repostCount, int likeCount, int quoteCount, int bookmarkCount, List<ContentLabel>? labels, PostViewer? viewer, String? placeholderReason, bool isBlocked, bool isNotFound
});


$ThreadAuthorCopyWith<$Res> get author;$PostViewerCopyWith<$Res>? get viewer;

}
/// @nodoc
class _$ThreadPostCopyWithImpl<$Res>
    implements $ThreadPostCopyWith<$Res> {
  _$ThreadPostCopyWithImpl(this._self, this._then);

  final ThreadPost _self;
  final $Res Function(ThreadPost) _then;

/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? cid = freezed,Object? author = null,Object? record = null,Object? embed = freezed,Object? indexedAt = freezed,Object? replyCount = null,Object? repostCount = null,Object? likeCount = null,Object? quoteCount = null,Object? bookmarkCount = null,Object? labels = freezed,Object? viewer = freezed,Object? placeholderReason = freezed,Object? isBlocked = null,Object? isNotFound = null,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String?,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ThreadAuthor,record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,embed: freezed == embed ? _self.embed : embed // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,repostCount: null == repostCount ? _self.repostCount : repostCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,quoteCount: null == quoteCount ? _self.quoteCount : quoteCount // ignore: cast_nullable_to_non_nullable
as int,bookmarkCount: null == bookmarkCount ? _self.bookmarkCount : bookmarkCount // ignore: cast_nullable_to_non_nullable
as int,labels: freezed == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<ContentLabel>?,viewer: freezed == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as PostViewer?,placeholderReason: freezed == placeholderReason ? _self.placeholderReason : placeholderReason // ignore: cast_nullable_to_non_nullable
as String?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isNotFound: null == isNotFound ? _self.isNotFound : isNotFound // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadAuthorCopyWith<$Res> get author {
  
  return $ThreadAuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostViewerCopyWith<$Res>? get viewer {
    if (_self.viewer == null) {
    return null;
  }

  return $PostViewerCopyWith<$Res>(_self.viewer!, (value) {
    return _then(_self.copyWith(viewer: value));
  });
}
}


/// Adds pattern-matching-related methods to [ThreadPost].
extension ThreadPostPatterns on ThreadPost {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThreadPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadPost() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThreadPost value)  $default,){
final _that = this;
switch (_that) {
case _ThreadPost():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThreadPost value)?  $default,){
final _that = this;
switch (_that) {
case _ThreadPost() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String? cid,  ThreadAuthor author,  Map<String, dynamic> record, @JsonKey(fromJson: _transformEmbed)  String? embed,  DateTime? indexedAt,  int replyCount,  int repostCount,  int likeCount,  int quoteCount,  int bookmarkCount,  List<ContentLabel>? labels,  PostViewer? viewer,  String? placeholderReason,  bool isBlocked,  bool isNotFound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadPost() when $default != null:
return $default(_that.uri,_that.cid,_that.author,_that.record,_that.embed,_that.indexedAt,_that.replyCount,_that.repostCount,_that.likeCount,_that.quoteCount,_that.bookmarkCount,_that.labels,_that.viewer,_that.placeholderReason,_that.isBlocked,_that.isNotFound);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String? cid,  ThreadAuthor author,  Map<String, dynamic> record, @JsonKey(fromJson: _transformEmbed)  String? embed,  DateTime? indexedAt,  int replyCount,  int repostCount,  int likeCount,  int quoteCount,  int bookmarkCount,  List<ContentLabel>? labels,  PostViewer? viewer,  String? placeholderReason,  bool isBlocked,  bool isNotFound)  $default,) {final _that = this;
switch (_that) {
case _ThreadPost():
return $default(_that.uri,_that.cid,_that.author,_that.record,_that.embed,_that.indexedAt,_that.replyCount,_that.repostCount,_that.likeCount,_that.quoteCount,_that.bookmarkCount,_that.labels,_that.viewer,_that.placeholderReason,_that.isBlocked,_that.isNotFound);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String? cid,  ThreadAuthor author,  Map<String, dynamic> record, @JsonKey(fromJson: _transformEmbed)  String? embed,  DateTime? indexedAt,  int replyCount,  int repostCount,  int likeCount,  int quoteCount,  int bookmarkCount,  List<ContentLabel>? labels,  PostViewer? viewer,  String? placeholderReason,  bool isBlocked,  bool isNotFound)?  $default,) {final _that = this;
switch (_that) {
case _ThreadPost() when $default != null:
return $default(_that.uri,_that.cid,_that.author,_that.record,_that.embed,_that.indexedAt,_that.replyCount,_that.repostCount,_that.likeCount,_that.quoteCount,_that.bookmarkCount,_that.labels,_that.viewer,_that.placeholderReason,_that.isBlocked,_that.isNotFound);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadPost extends ThreadPost {
  const _ThreadPost({required this.uri, this.cid, required this.author, required final  Map<String, dynamic> record, @JsonKey(fromJson: _transformEmbed) this.embed, this.indexedAt, this.replyCount = 0, this.repostCount = 0, this.likeCount = 0, this.quoteCount = 0, this.bookmarkCount = 0, final  List<ContentLabel>? labels, this.viewer, this.placeholderReason, this.isBlocked = false, this.isNotFound = false}): _record = record,_labels = labels,super._();
  factory _ThreadPost.fromJson(Map<String, dynamic> json) => _$ThreadPostFromJson(json);

@override final  String uri;
@override final  String? cid;
@override final  ThreadAuthor author;
 final  Map<String, dynamic> _record;
@override Map<String, dynamic> get record {
  if (_record is EqualUnmodifiableMapView) return _record;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_record);
}

@override@JsonKey(fromJson: _transformEmbed) final  String? embed;
@override final  DateTime? indexedAt;
@override@JsonKey() final  int replyCount;
@override@JsonKey() final  int repostCount;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int quoteCount;
@override@JsonKey() final  int bookmarkCount;
 final  List<ContentLabel>? _labels;
@override List<ContentLabel>? get labels {
  final value = _labels;
  if (value == null) return null;
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  PostViewer? viewer;
@override final  String? placeholderReason;
@override@JsonKey() final  bool isBlocked;
@override@JsonKey() final  bool isNotFound;

/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadPostCopyWith<_ThreadPost> get copyWith => __$ThreadPostCopyWithImpl<_ThreadPost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadPostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadPost&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other._record, _record)&&(identical(other.embed, embed) || other.embed == embed)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.repostCount, repostCount) || other.repostCount == repostCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.quoteCount, quoteCount) || other.quoteCount == quoteCount)&&(identical(other.bookmarkCount, bookmarkCount) || other.bookmarkCount == bookmarkCount)&&const DeepCollectionEquality().equals(other._labels, _labels)&&(identical(other.viewer, viewer) || other.viewer == viewer)&&(identical(other.placeholderReason, placeholderReason) || other.placeholderReason == placeholderReason)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isNotFound, isNotFound) || other.isNotFound == isNotFound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,cid,author,const DeepCollectionEquality().hash(_record),embed,indexedAt,replyCount,repostCount,likeCount,quoteCount,bookmarkCount,const DeepCollectionEquality().hash(_labels),viewer,placeholderReason,isBlocked,isNotFound);

@override
String toString() {
  return 'ThreadPost(uri: $uri, cid: $cid, author: $author, record: $record, embed: $embed, indexedAt: $indexedAt, replyCount: $replyCount, repostCount: $repostCount, likeCount: $likeCount, quoteCount: $quoteCount, bookmarkCount: $bookmarkCount, labels: $labels, viewer: $viewer, placeholderReason: $placeholderReason, isBlocked: $isBlocked, isNotFound: $isNotFound)';
}


}

/// @nodoc
abstract mixin class _$ThreadPostCopyWith<$Res> implements $ThreadPostCopyWith<$Res> {
  factory _$ThreadPostCopyWith(_ThreadPost value, $Res Function(_ThreadPost) _then) = __$ThreadPostCopyWithImpl;
@override @useResult
$Res call({
 String uri, String? cid, ThreadAuthor author, Map<String, dynamic> record,@JsonKey(fromJson: _transformEmbed) String? embed, DateTime? indexedAt, int replyCount, int repostCount, int likeCount, int quoteCount, int bookmarkCount, List<ContentLabel>? labels, PostViewer? viewer, String? placeholderReason, bool isBlocked, bool isNotFound
});


@override $ThreadAuthorCopyWith<$Res> get author;@override $PostViewerCopyWith<$Res>? get viewer;

}
/// @nodoc
class __$ThreadPostCopyWithImpl<$Res>
    implements _$ThreadPostCopyWith<$Res> {
  __$ThreadPostCopyWithImpl(this._self, this._then);

  final _ThreadPost _self;
  final $Res Function(_ThreadPost) _then;

/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? cid = freezed,Object? author = null,Object? record = null,Object? embed = freezed,Object? indexedAt = freezed,Object? replyCount = null,Object? repostCount = null,Object? likeCount = null,Object? quoteCount = null,Object? bookmarkCount = null,Object? labels = freezed,Object? viewer = freezed,Object? placeholderReason = freezed,Object? isBlocked = null,Object? isNotFound = null,}) {
  return _then(_ThreadPost(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String?,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ThreadAuthor,record: null == record ? _self._record : record // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,embed: freezed == embed ? _self.embed : embed // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,repostCount: null == repostCount ? _self.repostCount : repostCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,quoteCount: null == quoteCount ? _self.quoteCount : quoteCount // ignore: cast_nullable_to_non_nullable
as int,bookmarkCount: null == bookmarkCount ? _self.bookmarkCount : bookmarkCount // ignore: cast_nullable_to_non_nullable
as int,labels: freezed == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<ContentLabel>?,viewer: freezed == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as PostViewer?,placeholderReason: freezed == placeholderReason ? _self.placeholderReason : placeholderReason // ignore: cast_nullable_to_non_nullable
as String?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isNotFound: null == isNotFound ? _self.isNotFound : isNotFound // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadAuthorCopyWith<$Res> get author {
  
  return $ThreadAuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostViewerCopyWith<$Res>? get viewer {
    if (_self.viewer == null) {
    return null;
  }

  return $PostViewerCopyWith<$Res>(_self.viewer!, (value) {
    return _then(_self.copyWith(viewer: value));
  });
}
}


/// @nodoc
mixin _$PostViewer {

 String? get like; String? get repost; bool get bookmarked; bool get threadMuted; bool get replyDisabled; String? get embedding;
/// Create a copy of PostViewer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostViewerCopyWith<PostViewer> get copyWith => _$PostViewerCopyWithImpl<PostViewer>(this as PostViewer, _$identity);

  /// Serializes this PostViewer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostViewer&&(identical(other.like, like) || other.like == like)&&(identical(other.repost, repost) || other.repost == repost)&&(identical(other.bookmarked, bookmarked) || other.bookmarked == bookmarked)&&(identical(other.threadMuted, threadMuted) || other.threadMuted == threadMuted)&&(identical(other.replyDisabled, replyDisabled) || other.replyDisabled == replyDisabled)&&(identical(other.embedding, embedding) || other.embedding == embedding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,like,repost,bookmarked,threadMuted,replyDisabled,embedding);

@override
String toString() {
  return 'PostViewer(like: $like, repost: $repost, bookmarked: $bookmarked, threadMuted: $threadMuted, replyDisabled: $replyDisabled, embedding: $embedding)';
}


}

/// @nodoc
abstract mixin class $PostViewerCopyWith<$Res>  {
  factory $PostViewerCopyWith(PostViewer value, $Res Function(PostViewer) _then) = _$PostViewerCopyWithImpl;
@useResult
$Res call({
 String? like, String? repost, bool bookmarked, bool threadMuted, bool replyDisabled, String? embedding
});




}
/// @nodoc
class _$PostViewerCopyWithImpl<$Res>
    implements $PostViewerCopyWith<$Res> {
  _$PostViewerCopyWithImpl(this._self, this._then);

  final PostViewer _self;
  final $Res Function(PostViewer) _then;

/// Create a copy of PostViewer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? like = freezed,Object? repost = freezed,Object? bookmarked = null,Object? threadMuted = null,Object? replyDisabled = null,Object? embedding = freezed,}) {
  return _then(_self.copyWith(
like: freezed == like ? _self.like : like // ignore: cast_nullable_to_non_nullable
as String?,repost: freezed == repost ? _self.repost : repost // ignore: cast_nullable_to_non_nullable
as String?,bookmarked: null == bookmarked ? _self.bookmarked : bookmarked // ignore: cast_nullable_to_non_nullable
as bool,threadMuted: null == threadMuted ? _self.threadMuted : threadMuted // ignore: cast_nullable_to_non_nullable
as bool,replyDisabled: null == replyDisabled ? _self.replyDisabled : replyDisabled // ignore: cast_nullable_to_non_nullable
as bool,embedding: freezed == embedding ? _self.embedding : embedding // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostViewer].
extension PostViewerPatterns on PostViewer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostViewer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostViewer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostViewer value)  $default,){
final _that = this;
switch (_that) {
case _PostViewer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostViewer value)?  $default,){
final _that = this;
switch (_that) {
case _PostViewer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? like,  String? repost,  bool bookmarked,  bool threadMuted,  bool replyDisabled,  String? embedding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostViewer() when $default != null:
return $default(_that.like,_that.repost,_that.bookmarked,_that.threadMuted,_that.replyDisabled,_that.embedding);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? like,  String? repost,  bool bookmarked,  bool threadMuted,  bool replyDisabled,  String? embedding)  $default,) {final _that = this;
switch (_that) {
case _PostViewer():
return $default(_that.like,_that.repost,_that.bookmarked,_that.threadMuted,_that.replyDisabled,_that.embedding);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? like,  String? repost,  bool bookmarked,  bool threadMuted,  bool replyDisabled,  String? embedding)?  $default,) {final _that = this;
switch (_that) {
case _PostViewer() when $default != null:
return $default(_that.like,_that.repost,_that.bookmarked,_that.threadMuted,_that.replyDisabled,_that.embedding);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostViewer implements PostViewer {
  const _PostViewer({this.like, this.repost, this.bookmarked = false, this.threadMuted = false, this.replyDisabled = false, this.embedding});
  factory _PostViewer.fromJson(Map<String, dynamic> json) => _$PostViewerFromJson(json);

@override final  String? like;
@override final  String? repost;
@override@JsonKey() final  bool bookmarked;
@override@JsonKey() final  bool threadMuted;
@override@JsonKey() final  bool replyDisabled;
@override final  String? embedding;

/// Create a copy of PostViewer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostViewerCopyWith<_PostViewer> get copyWith => __$PostViewerCopyWithImpl<_PostViewer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostViewerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostViewer&&(identical(other.like, like) || other.like == like)&&(identical(other.repost, repost) || other.repost == repost)&&(identical(other.bookmarked, bookmarked) || other.bookmarked == bookmarked)&&(identical(other.threadMuted, threadMuted) || other.threadMuted == threadMuted)&&(identical(other.replyDisabled, replyDisabled) || other.replyDisabled == replyDisabled)&&(identical(other.embedding, embedding) || other.embedding == embedding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,like,repost,bookmarked,threadMuted,replyDisabled,embedding);

@override
String toString() {
  return 'PostViewer(like: $like, repost: $repost, bookmarked: $bookmarked, threadMuted: $threadMuted, replyDisabled: $replyDisabled, embedding: $embedding)';
}


}

/// @nodoc
abstract mixin class _$PostViewerCopyWith<$Res> implements $PostViewerCopyWith<$Res> {
  factory _$PostViewerCopyWith(_PostViewer value, $Res Function(_PostViewer) _then) = __$PostViewerCopyWithImpl;
@override @useResult
$Res call({
 String? like, String? repost, bool bookmarked, bool threadMuted, bool replyDisabled, String? embedding
});




}
/// @nodoc
class __$PostViewerCopyWithImpl<$Res>
    implements _$PostViewerCopyWith<$Res> {
  __$PostViewerCopyWithImpl(this._self, this._then);

  final _PostViewer _self;
  final $Res Function(_PostViewer) _then;

/// Create a copy of PostViewer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? like = freezed,Object? repost = freezed,Object? bookmarked = null,Object? threadMuted = null,Object? replyDisabled = null,Object? embedding = freezed,}) {
  return _then(_PostViewer(
like: freezed == like ? _self.like : like // ignore: cast_nullable_to_non_nullable
as String?,repost: freezed == repost ? _self.repost : repost // ignore: cast_nullable_to_non_nullable
as String?,bookmarked: null == bookmarked ? _self.bookmarked : bookmarked // ignore: cast_nullable_to_non_nullable
as bool,threadMuted: null == threadMuted ? _self.threadMuted : threadMuted // ignore: cast_nullable_to_non_nullable
as bool,replyDisabled: null == replyDisabled ? _self.replyDisabled : replyDisabled // ignore: cast_nullable_to_non_nullable
as bool,embedding: freezed == embedding ? _self.embedding : embedding // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ThreadAuthor {

 String get did; String get handle; String? get displayName; String? get description; String? get avatar; ActorViewer? get viewer; List<ContentLabel>? get labels;
/// Create a copy of ThreadAuthor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadAuthorCopyWith<ThreadAuthor> get copyWith => _$ThreadAuthorCopyWithImpl<ThreadAuthor>(this as ThreadAuthor, _$identity);

  /// Serializes this ThreadAuthor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadAuthor&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.viewer, viewer) || other.viewer == viewer)&&const DeepCollectionEquality().equals(other.labels, labels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,description,avatar,viewer,const DeepCollectionEquality().hash(labels));

@override
String toString() {
  return 'ThreadAuthor(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, viewer: $viewer, labels: $labels)';
}


}

/// @nodoc
abstract mixin class $ThreadAuthorCopyWith<$Res>  {
  factory $ThreadAuthorCopyWith(ThreadAuthor value, $Res Function(ThreadAuthor) _then) = _$ThreadAuthorCopyWithImpl;
@useResult
$Res call({
 String did, String handle, String? displayName, String? description, String? avatar, ActorViewer? viewer, List<ContentLabel>? labels
});


$ActorViewerCopyWith<$Res>? get viewer;

}
/// @nodoc
class _$ThreadAuthorCopyWithImpl<$Res>
    implements $ThreadAuthorCopyWith<$Res> {
  _$ThreadAuthorCopyWithImpl(this._self, this._then);

  final ThreadAuthor _self;
  final $Res Function(ThreadAuthor) _then;

/// Create a copy of ThreadAuthor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? description = freezed,Object? avatar = freezed,Object? viewer = freezed,Object? labels = freezed,}) {
  return _then(_self.copyWith(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,viewer: freezed == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as ActorViewer?,labels: freezed == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<ContentLabel>?,
  ));
}
/// Create a copy of ThreadAuthor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActorViewerCopyWith<$Res>? get viewer {
    if (_self.viewer == null) {
    return null;
  }

  return $ActorViewerCopyWith<$Res>(_self.viewer!, (value) {
    return _then(_self.copyWith(viewer: value));
  });
}
}


/// Adds pattern-matching-related methods to [ThreadAuthor].
extension ThreadAuthorPatterns on ThreadAuthor {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThreadAuthor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadAuthor() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThreadAuthor value)  $default,){
final _that = this;
switch (_that) {
case _ThreadAuthor():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThreadAuthor value)?  $default,){
final _that = this;
switch (_that) {
case _ThreadAuthor() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  ActorViewer? viewer,  List<ContentLabel>? labels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadAuthor() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.viewer,_that.labels);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  ActorViewer? viewer,  List<ContentLabel>? labels)  $default,) {final _that = this;
switch (_that) {
case _ThreadAuthor():
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.viewer,_that.labels);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  ActorViewer? viewer,  List<ContentLabel>? labels)?  $default,) {final _that = this;
switch (_that) {
case _ThreadAuthor() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.viewer,_that.labels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadAuthor extends ThreadAuthor {
  const _ThreadAuthor({required this.did, required this.handle, this.displayName, this.description, this.avatar, this.viewer, final  List<ContentLabel>? labels}): _labels = labels,super._();
  factory _ThreadAuthor.fromJson(Map<String, dynamic> json) => _$ThreadAuthorFromJson(json);

@override final  String did;
@override final  String handle;
@override final  String? displayName;
@override final  String? description;
@override final  String? avatar;
@override final  ActorViewer? viewer;
 final  List<ContentLabel>? _labels;
@override List<ContentLabel>? get labels {
  final value = _labels;
  if (value == null) return null;
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ThreadAuthor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadAuthorCopyWith<_ThreadAuthor> get copyWith => __$ThreadAuthorCopyWithImpl<_ThreadAuthor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadAuthorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadAuthor&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.viewer, viewer) || other.viewer == viewer)&&const DeepCollectionEquality().equals(other._labels, _labels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,description,avatar,viewer,const DeepCollectionEquality().hash(_labels));

@override
String toString() {
  return 'ThreadAuthor(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, viewer: $viewer, labels: $labels)';
}


}

/// @nodoc
abstract mixin class _$ThreadAuthorCopyWith<$Res> implements $ThreadAuthorCopyWith<$Res> {
  factory _$ThreadAuthorCopyWith(_ThreadAuthor value, $Res Function(_ThreadAuthor) _then) = __$ThreadAuthorCopyWithImpl;
@override @useResult
$Res call({
 String did, String handle, String? displayName, String? description, String? avatar, ActorViewer? viewer, List<ContentLabel>? labels
});


@override $ActorViewerCopyWith<$Res>? get viewer;

}
/// @nodoc
class __$ThreadAuthorCopyWithImpl<$Res>
    implements _$ThreadAuthorCopyWith<$Res> {
  __$ThreadAuthorCopyWithImpl(this._self, this._then);

  final _ThreadAuthor _self;
  final $Res Function(_ThreadAuthor) _then;

/// Create a copy of ThreadAuthor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? description = freezed,Object? avatar = freezed,Object? viewer = freezed,Object? labels = freezed,}) {
  return _then(_ThreadAuthor(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,viewer: freezed == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as ActorViewer?,labels: freezed == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<ContentLabel>?,
  ));
}

/// Create a copy of ThreadAuthor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActorViewerCopyWith<$Res>? get viewer {
    if (_self.viewer == null) {
    return null;
  }

  return $ActorViewerCopyWith<$Res>(_self.viewer!, (value) {
    return _then(_self.copyWith(viewer: value));
  });
}
}


/// @nodoc
mixin _$ActorViewer {

 String? get following; String? get followedBy; bool get muted; String? get blocking; bool get blockedBy; String? get mutedByList; String? get blockingByList; bool get knownFollowers;
/// Create a copy of ActorViewer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActorViewerCopyWith<ActorViewer> get copyWith => _$ActorViewerCopyWithImpl<ActorViewer>(this as ActorViewer, _$identity);

  /// Serializes this ActorViewer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActorViewer&&(identical(other.following, following) || other.following == following)&&(identical(other.followedBy, followedBy) || other.followedBy == followedBy)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.blocking, blocking) || other.blocking == blocking)&&(identical(other.blockedBy, blockedBy) || other.blockedBy == blockedBy)&&(identical(other.mutedByList, mutedByList) || other.mutedByList == mutedByList)&&(identical(other.blockingByList, blockingByList) || other.blockingByList == blockingByList)&&(identical(other.knownFollowers, knownFollowers) || other.knownFollowers == knownFollowers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,following,followedBy,muted,blocking,blockedBy,mutedByList,blockingByList,knownFollowers);

@override
String toString() {
  return 'ActorViewer(following: $following, followedBy: $followedBy, muted: $muted, blocking: $blocking, blockedBy: $blockedBy, mutedByList: $mutedByList, blockingByList: $blockingByList, knownFollowers: $knownFollowers)';
}


}

/// @nodoc
abstract mixin class $ActorViewerCopyWith<$Res>  {
  factory $ActorViewerCopyWith(ActorViewer value, $Res Function(ActorViewer) _then) = _$ActorViewerCopyWithImpl;
@useResult
$Res call({
 String? following, String? followedBy, bool muted, String? blocking, bool blockedBy, String? mutedByList, String? blockingByList, bool knownFollowers
});




}
/// @nodoc
class _$ActorViewerCopyWithImpl<$Res>
    implements $ActorViewerCopyWith<$Res> {
  _$ActorViewerCopyWithImpl(this._self, this._then);

  final ActorViewer _self;
  final $Res Function(ActorViewer) _then;

/// Create a copy of ActorViewer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? following = freezed,Object? followedBy = freezed,Object? muted = null,Object? blocking = freezed,Object? blockedBy = null,Object? mutedByList = freezed,Object? blockingByList = freezed,Object? knownFollowers = null,}) {
  return _then(_self.copyWith(
following: freezed == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as String?,followedBy: freezed == followedBy ? _self.followedBy : followedBy // ignore: cast_nullable_to_non_nullable
as String?,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,blocking: freezed == blocking ? _self.blocking : blocking // ignore: cast_nullable_to_non_nullable
as String?,blockedBy: null == blockedBy ? _self.blockedBy : blockedBy // ignore: cast_nullable_to_non_nullable
as bool,mutedByList: freezed == mutedByList ? _self.mutedByList : mutedByList // ignore: cast_nullable_to_non_nullable
as String?,blockingByList: freezed == blockingByList ? _self.blockingByList : blockingByList // ignore: cast_nullable_to_non_nullable
as String?,knownFollowers: null == knownFollowers ? _self.knownFollowers : knownFollowers // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ActorViewer].
extension ActorViewerPatterns on ActorViewer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActorViewer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActorViewer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActorViewer value)  $default,){
final _that = this;
switch (_that) {
case _ActorViewer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActorViewer value)?  $default,){
final _that = this;
switch (_that) {
case _ActorViewer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? following,  String? followedBy,  bool muted,  String? blocking,  bool blockedBy,  String? mutedByList,  String? blockingByList,  bool knownFollowers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActorViewer() when $default != null:
return $default(_that.following,_that.followedBy,_that.muted,_that.blocking,_that.blockedBy,_that.mutedByList,_that.blockingByList,_that.knownFollowers);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? following,  String? followedBy,  bool muted,  String? blocking,  bool blockedBy,  String? mutedByList,  String? blockingByList,  bool knownFollowers)  $default,) {final _that = this;
switch (_that) {
case _ActorViewer():
return $default(_that.following,_that.followedBy,_that.muted,_that.blocking,_that.blockedBy,_that.mutedByList,_that.blockingByList,_that.knownFollowers);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? following,  String? followedBy,  bool muted,  String? blocking,  bool blockedBy,  String? mutedByList,  String? blockingByList,  bool knownFollowers)?  $default,) {final _that = this;
switch (_that) {
case _ActorViewer() when $default != null:
return $default(_that.following,_that.followedBy,_that.muted,_that.blocking,_that.blockedBy,_that.mutedByList,_that.blockingByList,_that.knownFollowers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActorViewer implements ActorViewer {
  const _ActorViewer({this.following, this.followedBy, this.muted = false, this.blocking, this.blockedBy = false, this.mutedByList, this.blockingByList, this.knownFollowers = false});
  factory _ActorViewer.fromJson(Map<String, dynamic> json) => _$ActorViewerFromJson(json);

@override final  String? following;
@override final  String? followedBy;
@override@JsonKey() final  bool muted;
@override final  String? blocking;
@override@JsonKey() final  bool blockedBy;
@override final  String? mutedByList;
@override final  String? blockingByList;
@override@JsonKey() final  bool knownFollowers;

/// Create a copy of ActorViewer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActorViewerCopyWith<_ActorViewer> get copyWith => __$ActorViewerCopyWithImpl<_ActorViewer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActorViewerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActorViewer&&(identical(other.following, following) || other.following == following)&&(identical(other.followedBy, followedBy) || other.followedBy == followedBy)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.blocking, blocking) || other.blocking == blocking)&&(identical(other.blockedBy, blockedBy) || other.blockedBy == blockedBy)&&(identical(other.mutedByList, mutedByList) || other.mutedByList == mutedByList)&&(identical(other.blockingByList, blockingByList) || other.blockingByList == blockingByList)&&(identical(other.knownFollowers, knownFollowers) || other.knownFollowers == knownFollowers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,following,followedBy,muted,blocking,blockedBy,mutedByList,blockingByList,knownFollowers);

@override
String toString() {
  return 'ActorViewer(following: $following, followedBy: $followedBy, muted: $muted, blocking: $blocking, blockedBy: $blockedBy, mutedByList: $mutedByList, blockingByList: $blockingByList, knownFollowers: $knownFollowers)';
}


}

/// @nodoc
abstract mixin class _$ActorViewerCopyWith<$Res> implements $ActorViewerCopyWith<$Res> {
  factory _$ActorViewerCopyWith(_ActorViewer value, $Res Function(_ActorViewer) _then) = __$ActorViewerCopyWithImpl;
@override @useResult
$Res call({
 String? following, String? followedBy, bool muted, String? blocking, bool blockedBy, String? mutedByList, String? blockingByList, bool knownFollowers
});




}
/// @nodoc
class __$ActorViewerCopyWithImpl<$Res>
    implements _$ActorViewerCopyWith<$Res> {
  __$ActorViewerCopyWithImpl(this._self, this._then);

  final _ActorViewer _self;
  final $Res Function(_ActorViewer) _then;

/// Create a copy of ActorViewer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? following = freezed,Object? followedBy = freezed,Object? muted = null,Object? blocking = freezed,Object? blockedBy = null,Object? mutedByList = freezed,Object? blockingByList = freezed,Object? knownFollowers = null,}) {
  return _then(_ActorViewer(
following: freezed == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as String?,followedBy: freezed == followedBy ? _self.followedBy : followedBy // ignore: cast_nullable_to_non_nullable
as String?,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,blocking: freezed == blocking ? _self.blocking : blocking // ignore: cast_nullable_to_non_nullable
as String?,blockedBy: null == blockedBy ? _self.blockedBy : blockedBy // ignore: cast_nullable_to_non_nullable
as bool,mutedByList: freezed == mutedByList ? _self.mutedByList : mutedByList // ignore: cast_nullable_to_non_nullable
as String?,blockingByList: freezed == blockingByList ? _self.blockingByList : blockingByList // ignore: cast_nullable_to_non_nullable
as String?,knownFollowers: null == knownFollowers ? _self.knownFollowers : knownFollowers // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Threadgate {

 String get uri; String? get cid; ThreadgateRecord? get record; List<Map<String, dynamic>> get lists;
/// Create a copy of Threadgate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadgateCopyWith<Threadgate> get copyWith => _$ThreadgateCopyWithImpl<Threadgate>(this as Threadgate, _$identity);

  /// Serializes this Threadgate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Threadgate&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.record, record) || other.record == record)&&const DeepCollectionEquality().equals(other.lists, lists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,cid,record,const DeepCollectionEquality().hash(lists));

@override
String toString() {
  return 'Threadgate(uri: $uri, cid: $cid, record: $record, lists: $lists)';
}


}

/// @nodoc
abstract mixin class $ThreadgateCopyWith<$Res>  {
  factory $ThreadgateCopyWith(Threadgate value, $Res Function(Threadgate) _then) = _$ThreadgateCopyWithImpl;
@useResult
$Res call({
 String uri, String? cid, ThreadgateRecord? record, List<Map<String, dynamic>> lists
});


$ThreadgateRecordCopyWith<$Res>? get record;

}
/// @nodoc
class _$ThreadgateCopyWithImpl<$Res>
    implements $ThreadgateCopyWith<$Res> {
  _$ThreadgateCopyWithImpl(this._self, this._then);

  final Threadgate _self;
  final $Res Function(Threadgate) _then;

/// Create a copy of Threadgate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? cid = freezed,Object? record = freezed,Object? lists = null,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String?,record: freezed == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as ThreadgateRecord?,lists: null == lists ? _self.lists : lists // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}
/// Create a copy of Threadgate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadgateRecordCopyWith<$Res>? get record {
    if (_self.record == null) {
    return null;
  }

  return $ThreadgateRecordCopyWith<$Res>(_self.record!, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}


/// Adds pattern-matching-related methods to [Threadgate].
extension ThreadgatePatterns on Threadgate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Threadgate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Threadgate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Threadgate value)  $default,){
final _that = this;
switch (_that) {
case _Threadgate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Threadgate value)?  $default,){
final _that = this;
switch (_that) {
case _Threadgate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String? cid,  ThreadgateRecord? record,  List<Map<String, dynamic>> lists)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Threadgate() when $default != null:
return $default(_that.uri,_that.cid,_that.record,_that.lists);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String? cid,  ThreadgateRecord? record,  List<Map<String, dynamic>> lists)  $default,) {final _that = this;
switch (_that) {
case _Threadgate():
return $default(_that.uri,_that.cid,_that.record,_that.lists);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String? cid,  ThreadgateRecord? record,  List<Map<String, dynamic>> lists)?  $default,) {final _that = this;
switch (_that) {
case _Threadgate() when $default != null:
return $default(_that.uri,_that.cid,_that.record,_that.lists);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Threadgate extends Threadgate {
  const _Threadgate({required this.uri, this.cid, this.record, final  List<Map<String, dynamic>> lists = const []}): _lists = lists,super._();
  factory _Threadgate.fromJson(Map<String, dynamic> json) => _$ThreadgateFromJson(json);

@override final  String uri;
@override final  String? cid;
@override final  ThreadgateRecord? record;
 final  List<Map<String, dynamic>> _lists;
@override@JsonKey() List<Map<String, dynamic>> get lists {
  if (_lists is EqualUnmodifiableListView) return _lists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lists);
}


/// Create a copy of Threadgate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadgateCopyWith<_Threadgate> get copyWith => __$ThreadgateCopyWithImpl<_Threadgate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadgateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Threadgate&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.record, record) || other.record == record)&&const DeepCollectionEquality().equals(other._lists, _lists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,cid,record,const DeepCollectionEquality().hash(_lists));

@override
String toString() {
  return 'Threadgate(uri: $uri, cid: $cid, record: $record, lists: $lists)';
}


}

/// @nodoc
abstract mixin class _$ThreadgateCopyWith<$Res> implements $ThreadgateCopyWith<$Res> {
  factory _$ThreadgateCopyWith(_Threadgate value, $Res Function(_Threadgate) _then) = __$ThreadgateCopyWithImpl;
@override @useResult
$Res call({
 String uri, String? cid, ThreadgateRecord? record, List<Map<String, dynamic>> lists
});


@override $ThreadgateRecordCopyWith<$Res>? get record;

}
/// @nodoc
class __$ThreadgateCopyWithImpl<$Res>
    implements _$ThreadgateCopyWith<$Res> {
  __$ThreadgateCopyWithImpl(this._self, this._then);

  final _Threadgate _self;
  final $Res Function(_Threadgate) _then;

/// Create a copy of Threadgate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? cid = freezed,Object? record = freezed,Object? lists = null,}) {
  return _then(_Threadgate(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String?,record: freezed == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as ThreadgateRecord?,lists: null == lists ? _self._lists : lists // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

/// Create a copy of Threadgate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadgateRecordCopyWith<$Res>? get record {
    if (_self.record == null) {
    return null;
  }

  return $ThreadgateRecordCopyWith<$Res>(_self.record!, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}


/// @nodoc
mixin _$ThreadgateRecord {

 String get post; List<Map<String, dynamic>> get allow; DateTime? get createdAt;
/// Create a copy of ThreadgateRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadgateRecordCopyWith<ThreadgateRecord> get copyWith => _$ThreadgateRecordCopyWithImpl<ThreadgateRecord>(this as ThreadgateRecord, _$identity);

  /// Serializes this ThreadgateRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadgateRecord&&(identical(other.post, post) || other.post == post)&&const DeepCollectionEquality().equals(other.allow, allow)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,post,const DeepCollectionEquality().hash(allow),createdAt);

@override
String toString() {
  return 'ThreadgateRecord(post: $post, allow: $allow, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ThreadgateRecordCopyWith<$Res>  {
  factory $ThreadgateRecordCopyWith(ThreadgateRecord value, $Res Function(ThreadgateRecord) _then) = _$ThreadgateRecordCopyWithImpl;
@useResult
$Res call({
 String post, List<Map<String, dynamic>> allow, DateTime? createdAt
});




}
/// @nodoc
class _$ThreadgateRecordCopyWithImpl<$Res>
    implements $ThreadgateRecordCopyWith<$Res> {
  _$ThreadgateRecordCopyWithImpl(this._self, this._then);

  final ThreadgateRecord _self;
  final $Res Function(ThreadgateRecord) _then;

/// Create a copy of ThreadgateRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? post = null,Object? allow = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as String,allow: null == allow ? _self.allow : allow // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ThreadgateRecord].
extension ThreadgateRecordPatterns on ThreadgateRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThreadgateRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadgateRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThreadgateRecord value)  $default,){
final _that = this;
switch (_that) {
case _ThreadgateRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThreadgateRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ThreadgateRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String post,  List<Map<String, dynamic>> allow,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadgateRecord() when $default != null:
return $default(_that.post,_that.allow,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String post,  List<Map<String, dynamic>> allow,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ThreadgateRecord():
return $default(_that.post,_that.allow,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String post,  List<Map<String, dynamic>> allow,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ThreadgateRecord() when $default != null:
return $default(_that.post,_that.allow,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadgateRecord extends ThreadgateRecord {
  const _ThreadgateRecord({required this.post, final  List<Map<String, dynamic>> allow = const [], this.createdAt}): _allow = allow,super._();
  factory _ThreadgateRecord.fromJson(Map<String, dynamic> json) => _$ThreadgateRecordFromJson(json);

@override final  String post;
 final  List<Map<String, dynamic>> _allow;
@override@JsonKey() List<Map<String, dynamic>> get allow {
  if (_allow is EqualUnmodifiableListView) return _allow;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allow);
}

@override final  DateTime? createdAt;

/// Create a copy of ThreadgateRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadgateRecordCopyWith<_ThreadgateRecord> get copyWith => __$ThreadgateRecordCopyWithImpl<_ThreadgateRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadgateRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadgateRecord&&(identical(other.post, post) || other.post == post)&&const DeepCollectionEquality().equals(other._allow, _allow)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,post,const DeepCollectionEquality().hash(_allow),createdAt);

@override
String toString() {
  return 'ThreadgateRecord(post: $post, allow: $allow, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ThreadgateRecordCopyWith<$Res> implements $ThreadgateRecordCopyWith<$Res> {
  factory _$ThreadgateRecordCopyWith(_ThreadgateRecord value, $Res Function(_ThreadgateRecord) _then) = __$ThreadgateRecordCopyWithImpl;
@override @useResult
$Res call({
 String post, List<Map<String, dynamic>> allow, DateTime? createdAt
});




}
/// @nodoc
class __$ThreadgateRecordCopyWithImpl<$Res>
    implements _$ThreadgateRecordCopyWith<$Res> {
  __$ThreadgateRecordCopyWithImpl(this._self, this._then);

  final _ThreadgateRecord _self;
  final $Res Function(_ThreadgateRecord) _then;

/// Create a copy of ThreadgateRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? post = null,Object? allow = null,Object? createdAt = freezed,}) {
  return _then(_ThreadgateRecord(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as String,allow: null == allow ? _self._allow : allow // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
