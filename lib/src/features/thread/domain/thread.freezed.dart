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
/// @nodoc
mixin _$ThreadViewPost {

 ThreadPost get post; ThreadViewPost? get parent; List<ThreadViewPost> get replies; Threadgate? get threadgate; bool get isBlocked; bool get isNotFound;
/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadViewPostCopyWith<ThreadViewPost> get copyWith => _$ThreadViewPostCopyWithImpl<ThreadViewPost>(this as ThreadViewPost, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadViewPost&&(identical(other.post, post) || other.post == post)&&(identical(other.parent, parent) || other.parent == parent)&&const DeepCollectionEquality().equals(other.replies, replies)&&(identical(other.threadgate, threadgate) || other.threadgate == threadgate)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isNotFound, isNotFound) || other.isNotFound == isNotFound));
}


@override
int get hashCode => Object.hash(runtimeType,post,parent,const DeepCollectionEquality().hash(replies),threadgate,isBlocked,isNotFound);

@override
String toString() {
  return 'ThreadViewPost(post: $post, parent: $parent, replies: $replies, threadgate: $threadgate, isBlocked: $isBlocked, isNotFound: $isNotFound)';
}


}

/// @nodoc
abstract mixin class $ThreadViewPostCopyWith<$Res>  {
  factory $ThreadViewPostCopyWith(ThreadViewPost value, $Res Function(ThreadViewPost) _then) = _$ThreadViewPostCopyWithImpl;
@useResult
$Res call({
 ThreadPost post, ThreadViewPost? parent, List<ThreadViewPost> replies, Threadgate? threadgate, bool isBlocked, bool isNotFound
});


$ThreadPostCopyWith<$Res> get post;$ThreadViewPostCopyWith<$Res>? get parent;$ThreadgateCopyWith<$Res>? get threadgate;

}
/// @nodoc
class _$ThreadViewPostCopyWithImpl<$Res>
    implements $ThreadViewPostCopyWith<$Res> {
  _$ThreadViewPostCopyWithImpl(this._self, this._then);

  final ThreadViewPost _self;
  final $Res Function(ThreadViewPost) _then;

/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? post = null,Object? parent = freezed,Object? replies = null,Object? threadgate = freezed,Object? isBlocked = null,Object? isNotFound = null,}) {
  return _then(_self.copyWith(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as ThreadPost,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as ThreadViewPost?,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<ThreadViewPost>,threadgate: freezed == threadgate ? _self.threadgate : threadgate // ignore: cast_nullable_to_non_nullable
as Threadgate?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isNotFound: null == isNotFound ? _self.isNotFound : isNotFound // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThreadViewPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadViewPost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThreadViewPost value)  $default,){
final _that = this;
switch (_that) {
case _ThreadViewPost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThreadViewPost value)?  $default,){
final _that = this;
switch (_that) {
case _ThreadViewPost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThreadPost post,  ThreadViewPost? parent,  List<ThreadViewPost> replies,  Threadgate? threadgate,  bool isBlocked,  bool isNotFound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadViewPost() when $default != null:
return $default(_that.post,_that.parent,_that.replies,_that.threadgate,_that.isBlocked,_that.isNotFound);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThreadPost post,  ThreadViewPost? parent,  List<ThreadViewPost> replies,  Threadgate? threadgate,  bool isBlocked,  bool isNotFound)  $default,) {final _that = this;
switch (_that) {
case _ThreadViewPost():
return $default(_that.post,_that.parent,_that.replies,_that.threadgate,_that.isBlocked,_that.isNotFound);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThreadPost post,  ThreadViewPost? parent,  List<ThreadViewPost> replies,  Threadgate? threadgate,  bool isBlocked,  bool isNotFound)?  $default,) {final _that = this;
switch (_that) {
case _ThreadViewPost() when $default != null:
return $default(_that.post,_that.parent,_that.replies,_that.threadgate,_that.isBlocked,_that.isNotFound);case _:
  return null;

}
}

}

/// @nodoc


class _ThreadViewPost extends ThreadViewPost {
  const _ThreadViewPost({required this.post, this.parent, final  List<ThreadViewPost> replies = const [], this.threadgate, this.isBlocked = false, this.isNotFound = false}): _replies = replies,super._();
  

@override final  ThreadPost post;
@override final  ThreadViewPost? parent;
 final  List<ThreadViewPost> _replies;
@override@JsonKey() List<ThreadViewPost> get replies {
  if (_replies is EqualUnmodifiableListView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_replies);
}

@override final  Threadgate? threadgate;
@override@JsonKey() final  bool isBlocked;
@override@JsonKey() final  bool isNotFound;

/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadViewPostCopyWith<_ThreadViewPost> get copyWith => __$ThreadViewPostCopyWithImpl<_ThreadViewPost>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadViewPost&&(identical(other.post, post) || other.post == post)&&(identical(other.parent, parent) || other.parent == parent)&&const DeepCollectionEquality().equals(other._replies, _replies)&&(identical(other.threadgate, threadgate) || other.threadgate == threadgate)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isNotFound, isNotFound) || other.isNotFound == isNotFound));
}


@override
int get hashCode => Object.hash(runtimeType,post,parent,const DeepCollectionEquality().hash(_replies),threadgate,isBlocked,isNotFound);

@override
String toString() {
  return 'ThreadViewPost(post: $post, parent: $parent, replies: $replies, threadgate: $threadgate, isBlocked: $isBlocked, isNotFound: $isNotFound)';
}


}

/// @nodoc
abstract mixin class _$ThreadViewPostCopyWith<$Res> implements $ThreadViewPostCopyWith<$Res> {
  factory _$ThreadViewPostCopyWith(_ThreadViewPost value, $Res Function(_ThreadViewPost) _then) = __$ThreadViewPostCopyWithImpl;
@override @useResult
$Res call({
 ThreadPost post, ThreadViewPost? parent, List<ThreadViewPost> replies, Threadgate? threadgate, bool isBlocked, bool isNotFound
});


@override $ThreadPostCopyWith<$Res> get post;@override $ThreadViewPostCopyWith<$Res>? get parent;@override $ThreadgateCopyWith<$Res>? get threadgate;

}
/// @nodoc
class __$ThreadViewPostCopyWithImpl<$Res>
    implements _$ThreadViewPostCopyWith<$Res> {
  __$ThreadViewPostCopyWithImpl(this._self, this._then);

  final _ThreadViewPost _self;
  final $Res Function(_ThreadViewPost) _then;

/// Create a copy of ThreadViewPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? post = null,Object? parent = freezed,Object? replies = null,Object? threadgate = freezed,Object? isBlocked = null,Object? isNotFound = null,}) {
  return _then(_ThreadViewPost(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as ThreadPost,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as ThreadViewPost?,replies: null == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as List<ThreadViewPost>,threadgate: freezed == threadgate ? _self.threadgate : threadgate // ignore: cast_nullable_to_non_nullable
as Threadgate?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isNotFound: null == isNotFound ? _self.isNotFound : isNotFound // ignore: cast_nullable_to_non_nullable
as bool,
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
mixin _$ThreadPost {

 String get uri; String get cid; ThreadAuthor get author; Map<String, dynamic> get record; String? get embed; DateTime? get indexedAt; int get replyCount; int get repostCount; int get likeCount; int get quoteCount; int get bookmarkCount; String? get labels; String? get viewerLikeUri; String? get viewerRepostUri; bool get viewerBookmarked; bool get viewerThreadMuted; bool get viewerReplyDisabled; String? get placeholderReason; bool get isBlocked; bool get isNotFound;
/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadPostCopyWith<ThreadPost> get copyWith => _$ThreadPostCopyWithImpl<ThreadPost>(this as ThreadPost, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadPost&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other.record, record)&&(identical(other.embed, embed) || other.embed == embed)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.repostCount, repostCount) || other.repostCount == repostCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.quoteCount, quoteCount) || other.quoteCount == quoteCount)&&(identical(other.bookmarkCount, bookmarkCount) || other.bookmarkCount == bookmarkCount)&&(identical(other.labels, labels) || other.labels == labels)&&(identical(other.viewerLikeUri, viewerLikeUri) || other.viewerLikeUri == viewerLikeUri)&&(identical(other.viewerRepostUri, viewerRepostUri) || other.viewerRepostUri == viewerRepostUri)&&(identical(other.viewerBookmarked, viewerBookmarked) || other.viewerBookmarked == viewerBookmarked)&&(identical(other.viewerThreadMuted, viewerThreadMuted) || other.viewerThreadMuted == viewerThreadMuted)&&(identical(other.viewerReplyDisabled, viewerReplyDisabled) || other.viewerReplyDisabled == viewerReplyDisabled)&&(identical(other.placeholderReason, placeholderReason) || other.placeholderReason == placeholderReason)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isNotFound, isNotFound) || other.isNotFound == isNotFound));
}


@override
int get hashCode => Object.hashAll([runtimeType,uri,cid,author,const DeepCollectionEquality().hash(record),embed,indexedAt,replyCount,repostCount,likeCount,quoteCount,bookmarkCount,labels,viewerLikeUri,viewerRepostUri,viewerBookmarked,viewerThreadMuted,viewerReplyDisabled,placeholderReason,isBlocked,isNotFound]);

@override
String toString() {
  return 'ThreadPost(uri: $uri, cid: $cid, author: $author, record: $record, embed: $embed, indexedAt: $indexedAt, replyCount: $replyCount, repostCount: $repostCount, likeCount: $likeCount, quoteCount: $quoteCount, bookmarkCount: $bookmarkCount, labels: $labels, viewerLikeUri: $viewerLikeUri, viewerRepostUri: $viewerRepostUri, viewerBookmarked: $viewerBookmarked, viewerThreadMuted: $viewerThreadMuted, viewerReplyDisabled: $viewerReplyDisabled, placeholderReason: $placeholderReason, isBlocked: $isBlocked, isNotFound: $isNotFound)';
}


}

/// @nodoc
abstract mixin class $ThreadPostCopyWith<$Res>  {
  factory $ThreadPostCopyWith(ThreadPost value, $Res Function(ThreadPost) _then) = _$ThreadPostCopyWithImpl;
@useResult
$Res call({
 String uri, String cid, ThreadAuthor author, Map<String, dynamic> record, String? embed, DateTime? indexedAt, int replyCount, int repostCount, int likeCount, int quoteCount, int bookmarkCount, String? labels, String? viewerLikeUri, String? viewerRepostUri, bool viewerBookmarked, bool viewerThreadMuted, bool viewerReplyDisabled, String? placeholderReason, bool isBlocked, bool isNotFound
});


$ThreadAuthorCopyWith<$Res> get author;

}
/// @nodoc
class _$ThreadPostCopyWithImpl<$Res>
    implements $ThreadPostCopyWith<$Res> {
  _$ThreadPostCopyWithImpl(this._self, this._then);

  final ThreadPost _self;
  final $Res Function(ThreadPost) _then;

/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? cid = null,Object? author = null,Object? record = null,Object? embed = freezed,Object? indexedAt = freezed,Object? replyCount = null,Object? repostCount = null,Object? likeCount = null,Object? quoteCount = null,Object? bookmarkCount = null,Object? labels = freezed,Object? viewerLikeUri = freezed,Object? viewerRepostUri = freezed,Object? viewerBookmarked = null,Object? viewerThreadMuted = null,Object? viewerReplyDisabled = null,Object? placeholderReason = freezed,Object? isBlocked = null,Object? isNotFound = null,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ThreadAuthor,record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,embed: freezed == embed ? _self.embed : embed // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,repostCount: null == repostCount ? _self.repostCount : repostCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,quoteCount: null == quoteCount ? _self.quoteCount : quoteCount // ignore: cast_nullable_to_non_nullable
as int,bookmarkCount: null == bookmarkCount ? _self.bookmarkCount : bookmarkCount // ignore: cast_nullable_to_non_nullable
as int,labels: freezed == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as String?,viewerLikeUri: freezed == viewerLikeUri ? _self.viewerLikeUri : viewerLikeUri // ignore: cast_nullable_to_non_nullable
as String?,viewerRepostUri: freezed == viewerRepostUri ? _self.viewerRepostUri : viewerRepostUri // ignore: cast_nullable_to_non_nullable
as String?,viewerBookmarked: null == viewerBookmarked ? _self.viewerBookmarked : viewerBookmarked // ignore: cast_nullable_to_non_nullable
as bool,viewerThreadMuted: null == viewerThreadMuted ? _self.viewerThreadMuted : viewerThreadMuted // ignore: cast_nullable_to_non_nullable
as bool,viewerReplyDisabled: null == viewerReplyDisabled ? _self.viewerReplyDisabled : viewerReplyDisabled // ignore: cast_nullable_to_non_nullable
as bool,placeholderReason: freezed == placeholderReason ? _self.placeholderReason : placeholderReason // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String cid,  ThreadAuthor author,  Map<String, dynamic> record,  String? embed,  DateTime? indexedAt,  int replyCount,  int repostCount,  int likeCount,  int quoteCount,  int bookmarkCount,  String? labels,  String? viewerLikeUri,  String? viewerRepostUri,  bool viewerBookmarked,  bool viewerThreadMuted,  bool viewerReplyDisabled,  String? placeholderReason,  bool isBlocked,  bool isNotFound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadPost() when $default != null:
return $default(_that.uri,_that.cid,_that.author,_that.record,_that.embed,_that.indexedAt,_that.replyCount,_that.repostCount,_that.likeCount,_that.quoteCount,_that.bookmarkCount,_that.labels,_that.viewerLikeUri,_that.viewerRepostUri,_that.viewerBookmarked,_that.viewerThreadMuted,_that.viewerReplyDisabled,_that.placeholderReason,_that.isBlocked,_that.isNotFound);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String cid,  ThreadAuthor author,  Map<String, dynamic> record,  String? embed,  DateTime? indexedAt,  int replyCount,  int repostCount,  int likeCount,  int quoteCount,  int bookmarkCount,  String? labels,  String? viewerLikeUri,  String? viewerRepostUri,  bool viewerBookmarked,  bool viewerThreadMuted,  bool viewerReplyDisabled,  String? placeholderReason,  bool isBlocked,  bool isNotFound)  $default,) {final _that = this;
switch (_that) {
case _ThreadPost():
return $default(_that.uri,_that.cid,_that.author,_that.record,_that.embed,_that.indexedAt,_that.replyCount,_that.repostCount,_that.likeCount,_that.quoteCount,_that.bookmarkCount,_that.labels,_that.viewerLikeUri,_that.viewerRepostUri,_that.viewerBookmarked,_that.viewerThreadMuted,_that.viewerReplyDisabled,_that.placeholderReason,_that.isBlocked,_that.isNotFound);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String cid,  ThreadAuthor author,  Map<String, dynamic> record,  String? embed,  DateTime? indexedAt,  int replyCount,  int repostCount,  int likeCount,  int quoteCount,  int bookmarkCount,  String? labels,  String? viewerLikeUri,  String? viewerRepostUri,  bool viewerBookmarked,  bool viewerThreadMuted,  bool viewerReplyDisabled,  String? placeholderReason,  bool isBlocked,  bool isNotFound)?  $default,) {final _that = this;
switch (_that) {
case _ThreadPost() when $default != null:
return $default(_that.uri,_that.cid,_that.author,_that.record,_that.embed,_that.indexedAt,_that.replyCount,_that.repostCount,_that.likeCount,_that.quoteCount,_that.bookmarkCount,_that.labels,_that.viewerLikeUri,_that.viewerRepostUri,_that.viewerBookmarked,_that.viewerThreadMuted,_that.viewerReplyDisabled,_that.placeholderReason,_that.isBlocked,_that.isNotFound);case _:
  return null;

}
}

}

/// @nodoc


class _ThreadPost extends ThreadPost {
  const _ThreadPost({required this.uri, required this.cid, required this.author, required final  Map<String, dynamic> record, this.embed, this.indexedAt, this.replyCount = 0, this.repostCount = 0, this.likeCount = 0, this.quoteCount = 0, this.bookmarkCount = 0, this.labels, this.viewerLikeUri, this.viewerRepostUri, this.viewerBookmarked = false, this.viewerThreadMuted = false, this.viewerReplyDisabled = false, this.placeholderReason, this.isBlocked = false, this.isNotFound = false}): _record = record,super._();
  

@override final  String uri;
@override final  String cid;
@override final  ThreadAuthor author;
 final  Map<String, dynamic> _record;
@override Map<String, dynamic> get record {
  if (_record is EqualUnmodifiableMapView) return _record;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_record);
}

@override final  String? embed;
@override final  DateTime? indexedAt;
@override@JsonKey() final  int replyCount;
@override@JsonKey() final  int repostCount;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int quoteCount;
@override@JsonKey() final  int bookmarkCount;
@override final  String? labels;
@override final  String? viewerLikeUri;
@override final  String? viewerRepostUri;
@override@JsonKey() final  bool viewerBookmarked;
@override@JsonKey() final  bool viewerThreadMuted;
@override@JsonKey() final  bool viewerReplyDisabled;
@override final  String? placeholderReason;
@override@JsonKey() final  bool isBlocked;
@override@JsonKey() final  bool isNotFound;

/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadPostCopyWith<_ThreadPost> get copyWith => __$ThreadPostCopyWithImpl<_ThreadPost>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadPost&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other._record, _record)&&(identical(other.embed, embed) || other.embed == embed)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.repostCount, repostCount) || other.repostCount == repostCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.quoteCount, quoteCount) || other.quoteCount == quoteCount)&&(identical(other.bookmarkCount, bookmarkCount) || other.bookmarkCount == bookmarkCount)&&(identical(other.labels, labels) || other.labels == labels)&&(identical(other.viewerLikeUri, viewerLikeUri) || other.viewerLikeUri == viewerLikeUri)&&(identical(other.viewerRepostUri, viewerRepostUri) || other.viewerRepostUri == viewerRepostUri)&&(identical(other.viewerBookmarked, viewerBookmarked) || other.viewerBookmarked == viewerBookmarked)&&(identical(other.viewerThreadMuted, viewerThreadMuted) || other.viewerThreadMuted == viewerThreadMuted)&&(identical(other.viewerReplyDisabled, viewerReplyDisabled) || other.viewerReplyDisabled == viewerReplyDisabled)&&(identical(other.placeholderReason, placeholderReason) || other.placeholderReason == placeholderReason)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isNotFound, isNotFound) || other.isNotFound == isNotFound));
}


@override
int get hashCode => Object.hashAll([runtimeType,uri,cid,author,const DeepCollectionEquality().hash(_record),embed,indexedAt,replyCount,repostCount,likeCount,quoteCount,bookmarkCount,labels,viewerLikeUri,viewerRepostUri,viewerBookmarked,viewerThreadMuted,viewerReplyDisabled,placeholderReason,isBlocked,isNotFound]);

@override
String toString() {
  return 'ThreadPost(uri: $uri, cid: $cid, author: $author, record: $record, embed: $embed, indexedAt: $indexedAt, replyCount: $replyCount, repostCount: $repostCount, likeCount: $likeCount, quoteCount: $quoteCount, bookmarkCount: $bookmarkCount, labels: $labels, viewerLikeUri: $viewerLikeUri, viewerRepostUri: $viewerRepostUri, viewerBookmarked: $viewerBookmarked, viewerThreadMuted: $viewerThreadMuted, viewerReplyDisabled: $viewerReplyDisabled, placeholderReason: $placeholderReason, isBlocked: $isBlocked, isNotFound: $isNotFound)';
}


}

/// @nodoc
abstract mixin class _$ThreadPostCopyWith<$Res> implements $ThreadPostCopyWith<$Res> {
  factory _$ThreadPostCopyWith(_ThreadPost value, $Res Function(_ThreadPost) _then) = __$ThreadPostCopyWithImpl;
@override @useResult
$Res call({
 String uri, String cid, ThreadAuthor author, Map<String, dynamic> record, String? embed, DateTime? indexedAt, int replyCount, int repostCount, int likeCount, int quoteCount, int bookmarkCount, String? labels, String? viewerLikeUri, String? viewerRepostUri, bool viewerBookmarked, bool viewerThreadMuted, bool viewerReplyDisabled, String? placeholderReason, bool isBlocked, bool isNotFound
});


@override $ThreadAuthorCopyWith<$Res> get author;

}
/// @nodoc
class __$ThreadPostCopyWithImpl<$Res>
    implements _$ThreadPostCopyWith<$Res> {
  __$ThreadPostCopyWithImpl(this._self, this._then);

  final _ThreadPost _self;
  final $Res Function(_ThreadPost) _then;

/// Create a copy of ThreadPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? cid = null,Object? author = null,Object? record = null,Object? embed = freezed,Object? indexedAt = freezed,Object? replyCount = null,Object? repostCount = null,Object? likeCount = null,Object? quoteCount = null,Object? bookmarkCount = null,Object? labels = freezed,Object? viewerLikeUri = freezed,Object? viewerRepostUri = freezed,Object? viewerBookmarked = null,Object? viewerThreadMuted = null,Object? viewerReplyDisabled = null,Object? placeholderReason = freezed,Object? isBlocked = null,Object? isNotFound = null,}) {
  return _then(_ThreadPost(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ThreadAuthor,record: null == record ? _self._record : record // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,embed: freezed == embed ? _self.embed : embed // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,repostCount: null == repostCount ? _self.repostCount : repostCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,quoteCount: null == quoteCount ? _self.quoteCount : quoteCount // ignore: cast_nullable_to_non_nullable
as int,bookmarkCount: null == bookmarkCount ? _self.bookmarkCount : bookmarkCount // ignore: cast_nullable_to_non_nullable
as int,labels: freezed == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as String?,viewerLikeUri: freezed == viewerLikeUri ? _self.viewerLikeUri : viewerLikeUri // ignore: cast_nullable_to_non_nullable
as String?,viewerRepostUri: freezed == viewerRepostUri ? _self.viewerRepostUri : viewerRepostUri // ignore: cast_nullable_to_non_nullable
as String?,viewerBookmarked: null == viewerBookmarked ? _self.viewerBookmarked : viewerBookmarked // ignore: cast_nullable_to_non_nullable
as bool,viewerThreadMuted: null == viewerThreadMuted ? _self.viewerThreadMuted : viewerThreadMuted // ignore: cast_nullable_to_non_nullable
as bool,viewerReplyDisabled: null == viewerReplyDisabled ? _self.viewerReplyDisabled : viewerReplyDisabled // ignore: cast_nullable_to_non_nullable
as bool,placeholderReason: freezed == placeholderReason ? _self.placeholderReason : placeholderReason // ignore: cast_nullable_to_non_nullable
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
}
}


/// @nodoc
mixin _$ThreadAuthor {

 String get did; String get handle; String? get displayName; String? get description; String? get avatar; Map<String, dynamic>? get viewer;
/// Create a copy of ThreadAuthor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadAuthorCopyWith<ThreadAuthor> get copyWith => _$ThreadAuthorCopyWithImpl<ThreadAuthor>(this as ThreadAuthor, _$identity);

  /// Serializes this ThreadAuthor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadAuthor&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&const DeepCollectionEquality().equals(other.viewer, viewer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,description,avatar,const DeepCollectionEquality().hash(viewer));

@override
String toString() {
  return 'ThreadAuthor(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, viewer: $viewer)';
}


}

/// @nodoc
abstract mixin class $ThreadAuthorCopyWith<$Res>  {
  factory $ThreadAuthorCopyWith(ThreadAuthor value, $Res Function(ThreadAuthor) _then) = _$ThreadAuthorCopyWithImpl;
@useResult
$Res call({
 String did, String handle, String? displayName, String? description, String? avatar, Map<String, dynamic>? viewer
});




}
/// @nodoc
class _$ThreadAuthorCopyWithImpl<$Res>
    implements $ThreadAuthorCopyWith<$Res> {
  _$ThreadAuthorCopyWithImpl(this._self, this._then);

  final ThreadAuthor _self;
  final $Res Function(ThreadAuthor) _then;

/// Create a copy of ThreadAuthor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? description = freezed,Object? avatar = freezed,Object? viewer = freezed,}) {
  return _then(_self.copyWith(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,viewer: freezed == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  Map<String, dynamic>? viewer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadAuthor() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.viewer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  Map<String, dynamic>? viewer)  $default,) {final _that = this;
switch (_that) {
case _ThreadAuthor():
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.viewer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  Map<String, dynamic>? viewer)?  $default,) {final _that = this;
switch (_that) {
case _ThreadAuthor() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.viewer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadAuthor extends ThreadAuthor {
  const _ThreadAuthor({required this.did, required this.handle, this.displayName, this.description, this.avatar, final  Map<String, dynamic>? viewer}): _viewer = viewer,super._();
  factory _ThreadAuthor.fromJson(Map<String, dynamic> json) => _$ThreadAuthorFromJson(json);

@override final  String did;
@override final  String handle;
@override final  String? displayName;
@override final  String? description;
@override final  String? avatar;
 final  Map<String, dynamic>? _viewer;
@override Map<String, dynamic>? get viewer {
  final value = _viewer;
  if (value == null) return null;
  if (_viewer is EqualUnmodifiableMapView) return _viewer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadAuthor&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&const DeepCollectionEquality().equals(other._viewer, _viewer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,description,avatar,const DeepCollectionEquality().hash(_viewer));

@override
String toString() {
  return 'ThreadAuthor(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, viewer: $viewer)';
}


}

/// @nodoc
abstract mixin class _$ThreadAuthorCopyWith<$Res> implements $ThreadAuthorCopyWith<$Res> {
  factory _$ThreadAuthorCopyWith(_ThreadAuthor value, $Res Function(_ThreadAuthor) _then) = __$ThreadAuthorCopyWithImpl;
@override @useResult
$Res call({
 String did, String handle, String? displayName, String? description, String? avatar, Map<String, dynamic>? viewer
});




}
/// @nodoc
class __$ThreadAuthorCopyWithImpl<$Res>
    implements _$ThreadAuthorCopyWith<$Res> {
  __$ThreadAuthorCopyWithImpl(this._self, this._then);

  final _ThreadAuthor _self;
  final $Res Function(_ThreadAuthor) _then;

/// Create a copy of ThreadAuthor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? description = freezed,Object? avatar = freezed,Object? viewer = freezed,}) {
  return _then(_ThreadAuthor(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,viewer: freezed == viewer ? _self._viewer : viewer // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
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



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Threadgate&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.record, record) || other.record == record)&&const DeepCollectionEquality().equals(other.lists, lists));
}


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


class _Threadgate extends Threadgate {
  const _Threadgate({required this.uri, this.cid, this.record, final  List<Map<String, dynamic>> lists = const []}): _lists = lists,super._();
  

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
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Threadgate&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.record, record) || other.record == record)&&const DeepCollectionEquality().equals(other._lists, _lists));
}


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



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadgateRecord&&(identical(other.post, post) || other.post == post)&&const DeepCollectionEquality().equals(other.allow, allow)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


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


class _ThreadgateRecord extends ThreadgateRecord {
  const _ThreadgateRecord({required this.post, final  List<Map<String, dynamic>> allow = const [], this.createdAt}): _allow = allow,super._();
  

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
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadgateRecord&&(identical(other.post, post) || other.post == post)&&const DeepCollectionEquality().equals(other._allow, _allow)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


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
