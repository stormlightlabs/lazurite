// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Post {

 String get uri; String get cid; Author get author; String get text; DateTime? get indexedAt; int get replyCount; int get repostCount; int get likeCount; Map<String, dynamic>? get embed; Map<String, dynamic>? get record; List<dynamic>? get facets;// Viewer states (from FeedItem)
 String? get viewerLikeUri; String? get viewerRepostUri; bool get viewerBookmarked;// Helper flags (from FeedItem)
 bool get isReply; bool get isRepost; bool get isQuote; bool get hasImages; bool get hasVideo; String? get embedType;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.repostCount, repostCount) || other.repostCount == repostCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&const DeepCollectionEquality().equals(other.embed, embed)&&const DeepCollectionEquality().equals(other.record, record)&&const DeepCollectionEquality().equals(other.facets, facets)&&(identical(other.viewerLikeUri, viewerLikeUri) || other.viewerLikeUri == viewerLikeUri)&&(identical(other.viewerRepostUri, viewerRepostUri) || other.viewerRepostUri == viewerRepostUri)&&(identical(other.viewerBookmarked, viewerBookmarked) || other.viewerBookmarked == viewerBookmarked)&&(identical(other.isReply, isReply) || other.isReply == isReply)&&(identical(other.isRepost, isRepost) || other.isRepost == isRepost)&&(identical(other.isQuote, isQuote) || other.isQuote == isQuote)&&(identical(other.hasImages, hasImages) || other.hasImages == hasImages)&&(identical(other.hasVideo, hasVideo) || other.hasVideo == hasVideo)&&(identical(other.embedType, embedType) || other.embedType == embedType));
}


@override
int get hashCode => Object.hashAll([runtimeType,uri,cid,author,text,indexedAt,replyCount,repostCount,likeCount,const DeepCollectionEquality().hash(embed),const DeepCollectionEquality().hash(record),const DeepCollectionEquality().hash(facets),viewerLikeUri,viewerRepostUri,viewerBookmarked,isReply,isRepost,isQuote,hasImages,hasVideo,embedType]);

@override
String toString() {
  return 'Post(uri: $uri, cid: $cid, author: $author, text: $text, indexedAt: $indexedAt, replyCount: $replyCount, repostCount: $repostCount, likeCount: $likeCount, embed: $embed, record: $record, facets: $facets, viewerLikeUri: $viewerLikeUri, viewerRepostUri: $viewerRepostUri, viewerBookmarked: $viewerBookmarked, isReply: $isReply, isRepost: $isRepost, isQuote: $isQuote, hasImages: $hasImages, hasVideo: $hasVideo, embedType: $embedType)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String uri, String cid, Author author, String text, DateTime? indexedAt, int replyCount, int repostCount, int likeCount, Map<String, dynamic>? embed, Map<String, dynamic>? record, List<dynamic>? facets, String? viewerLikeUri, String? viewerRepostUri, bool viewerBookmarked, bool isReply, bool isRepost, bool isQuote, bool hasImages, bool hasVideo, String? embedType
});


$AuthorCopyWith<$Res> get author;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? cid = null,Object? author = null,Object? text = null,Object? indexedAt = freezed,Object? replyCount = null,Object? repostCount = null,Object? likeCount = null,Object? embed = freezed,Object? record = freezed,Object? facets = freezed,Object? viewerLikeUri = freezed,Object? viewerRepostUri = freezed,Object? viewerBookmarked = null,Object? isReply = null,Object? isRepost = null,Object? isQuote = null,Object? hasImages = null,Object? hasVideo = null,Object? embedType = freezed,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,repostCount: null == repostCount ? _self.repostCount : repostCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,embed: freezed == embed ? _self.embed : embed // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,record: freezed == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,facets: freezed == facets ? _self.facets : facets // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,viewerLikeUri: freezed == viewerLikeUri ? _self.viewerLikeUri : viewerLikeUri // ignore: cast_nullable_to_non_nullable
as String?,viewerRepostUri: freezed == viewerRepostUri ? _self.viewerRepostUri : viewerRepostUri // ignore: cast_nullable_to_non_nullable
as String?,viewerBookmarked: null == viewerBookmarked ? _self.viewerBookmarked : viewerBookmarked // ignore: cast_nullable_to_non_nullable
as bool,isReply: null == isReply ? _self.isReply : isReply // ignore: cast_nullable_to_non_nullable
as bool,isRepost: null == isRepost ? _self.isRepost : isRepost // ignore: cast_nullable_to_non_nullable
as bool,isQuote: null == isQuote ? _self.isQuote : isQuote // ignore: cast_nullable_to_non_nullable
as bool,hasImages: null == hasImages ? _self.hasImages : hasImages // ignore: cast_nullable_to_non_nullable
as bool,hasVideo: null == hasVideo ? _self.hasVideo : hasVideo // ignore: cast_nullable_to_non_nullable
as bool,embedType: freezed == embedType ? _self.embedType : embedType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String cid,  Author author,  String text,  DateTime? indexedAt,  int replyCount,  int repostCount,  int likeCount,  Map<String, dynamic>? embed,  Map<String, dynamic>? record,  List<dynamic>? facets,  String? viewerLikeUri,  String? viewerRepostUri,  bool viewerBookmarked,  bool isReply,  bool isRepost,  bool isQuote,  bool hasImages,  bool hasVideo,  String? embedType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.uri,_that.cid,_that.author,_that.text,_that.indexedAt,_that.replyCount,_that.repostCount,_that.likeCount,_that.embed,_that.record,_that.facets,_that.viewerLikeUri,_that.viewerRepostUri,_that.viewerBookmarked,_that.isReply,_that.isRepost,_that.isQuote,_that.hasImages,_that.hasVideo,_that.embedType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String cid,  Author author,  String text,  DateTime? indexedAt,  int replyCount,  int repostCount,  int likeCount,  Map<String, dynamic>? embed,  Map<String, dynamic>? record,  List<dynamic>? facets,  String? viewerLikeUri,  String? viewerRepostUri,  bool viewerBookmarked,  bool isReply,  bool isRepost,  bool isQuote,  bool hasImages,  bool hasVideo,  String? embedType)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.uri,_that.cid,_that.author,_that.text,_that.indexedAt,_that.replyCount,_that.repostCount,_that.likeCount,_that.embed,_that.record,_that.facets,_that.viewerLikeUri,_that.viewerRepostUri,_that.viewerBookmarked,_that.isReply,_that.isRepost,_that.isQuote,_that.hasImages,_that.hasVideo,_that.embedType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String cid,  Author author,  String text,  DateTime? indexedAt,  int replyCount,  int repostCount,  int likeCount,  Map<String, dynamic>? embed,  Map<String, dynamic>? record,  List<dynamic>? facets,  String? viewerLikeUri,  String? viewerRepostUri,  bool viewerBookmarked,  bool isReply,  bool isRepost,  bool isQuote,  bool hasImages,  bool hasVideo,  String? embedType)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.uri,_that.cid,_that.author,_that.text,_that.indexedAt,_that.replyCount,_that.repostCount,_that.likeCount,_that.embed,_that.record,_that.facets,_that.viewerLikeUri,_that.viewerRepostUri,_that.viewerBookmarked,_that.isReply,_that.isRepost,_that.isQuote,_that.hasImages,_that.hasVideo,_that.embedType);case _:
  return null;

}
}

}

/// @nodoc


class _Post extends Post {
  const _Post({required this.uri, required this.cid, required this.author, required this.text, this.indexedAt, this.replyCount = 0, this.repostCount = 0, this.likeCount = 0, final  Map<String, dynamic>? embed, final  Map<String, dynamic>? record, final  List<dynamic>? facets, this.viewerLikeUri, this.viewerRepostUri, this.viewerBookmarked = false, this.isReply = false, this.isRepost = false, this.isQuote = false, this.hasImages = false, this.hasVideo = false, this.embedType}): _embed = embed,_record = record,_facets = facets,super._();
  

@override final  String uri;
@override final  String cid;
@override final  Author author;
@override final  String text;
@override final  DateTime? indexedAt;
@override@JsonKey() final  int replyCount;
@override@JsonKey() final  int repostCount;
@override@JsonKey() final  int likeCount;
 final  Map<String, dynamic>? _embed;
@override Map<String, dynamic>? get embed {
  final value = _embed;
  if (value == null) return null;
  if (_embed is EqualUnmodifiableMapView) return _embed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _record;
@override Map<String, dynamic>? get record {
  final value = _record;
  if (value == null) return null;
  if (_record is EqualUnmodifiableMapView) return _record;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<dynamic>? _facets;
@override List<dynamic>? get facets {
  final value = _facets;
  if (value == null) return null;
  if (_facets is EqualUnmodifiableListView) return _facets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Viewer states (from FeedItem)
@override final  String? viewerLikeUri;
@override final  String? viewerRepostUri;
@override@JsonKey() final  bool viewerBookmarked;
// Helper flags (from FeedItem)
@override@JsonKey() final  bool isReply;
@override@JsonKey() final  bool isRepost;
@override@JsonKey() final  bool isQuote;
@override@JsonKey() final  bool hasImages;
@override@JsonKey() final  bool hasVideo;
@override final  String? embedType;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.repostCount, repostCount) || other.repostCount == repostCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&const DeepCollectionEquality().equals(other._embed, _embed)&&const DeepCollectionEquality().equals(other._record, _record)&&const DeepCollectionEquality().equals(other._facets, _facets)&&(identical(other.viewerLikeUri, viewerLikeUri) || other.viewerLikeUri == viewerLikeUri)&&(identical(other.viewerRepostUri, viewerRepostUri) || other.viewerRepostUri == viewerRepostUri)&&(identical(other.viewerBookmarked, viewerBookmarked) || other.viewerBookmarked == viewerBookmarked)&&(identical(other.isReply, isReply) || other.isReply == isReply)&&(identical(other.isRepost, isRepost) || other.isRepost == isRepost)&&(identical(other.isQuote, isQuote) || other.isQuote == isQuote)&&(identical(other.hasImages, hasImages) || other.hasImages == hasImages)&&(identical(other.hasVideo, hasVideo) || other.hasVideo == hasVideo)&&(identical(other.embedType, embedType) || other.embedType == embedType));
}


@override
int get hashCode => Object.hashAll([runtimeType,uri,cid,author,text,indexedAt,replyCount,repostCount,likeCount,const DeepCollectionEquality().hash(_embed),const DeepCollectionEquality().hash(_record),const DeepCollectionEquality().hash(_facets),viewerLikeUri,viewerRepostUri,viewerBookmarked,isReply,isRepost,isQuote,hasImages,hasVideo,embedType]);

@override
String toString() {
  return 'Post(uri: $uri, cid: $cid, author: $author, text: $text, indexedAt: $indexedAt, replyCount: $replyCount, repostCount: $repostCount, likeCount: $likeCount, embed: $embed, record: $record, facets: $facets, viewerLikeUri: $viewerLikeUri, viewerRepostUri: $viewerRepostUri, viewerBookmarked: $viewerBookmarked, isReply: $isReply, isRepost: $isRepost, isQuote: $isQuote, hasImages: $hasImages, hasVideo: $hasVideo, embedType: $embedType)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String uri, String cid, Author author, String text, DateTime? indexedAt, int replyCount, int repostCount, int likeCount, Map<String, dynamic>? embed, Map<String, dynamic>? record, List<dynamic>? facets, String? viewerLikeUri, String? viewerRepostUri, bool viewerBookmarked, bool isReply, bool isRepost, bool isQuote, bool hasImages, bool hasVideo, String? embedType
});


@override $AuthorCopyWith<$Res> get author;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? cid = null,Object? author = null,Object? text = null,Object? indexedAt = freezed,Object? replyCount = null,Object? repostCount = null,Object? likeCount = null,Object? embed = freezed,Object? record = freezed,Object? facets = freezed,Object? viewerLikeUri = freezed,Object? viewerRepostUri = freezed,Object? viewerBookmarked = null,Object? isReply = null,Object? isRepost = null,Object? isQuote = null,Object? hasImages = null,Object? hasVideo = null,Object? embedType = freezed,}) {
  return _then(_Post(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,repostCount: null == repostCount ? _self.repostCount : repostCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,embed: freezed == embed ? _self._embed : embed // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,record: freezed == record ? _self._record : record // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,facets: freezed == facets ? _self._facets : facets // ignore: cast_nullable_to_non_nullable
as List<dynamic>?,viewerLikeUri: freezed == viewerLikeUri ? _self.viewerLikeUri : viewerLikeUri // ignore: cast_nullable_to_non_nullable
as String?,viewerRepostUri: freezed == viewerRepostUri ? _self.viewerRepostUri : viewerRepostUri // ignore: cast_nullable_to_non_nullable
as String?,viewerBookmarked: null == viewerBookmarked ? _self.viewerBookmarked : viewerBookmarked // ignore: cast_nullable_to_non_nullable
as bool,isReply: null == isReply ? _self.isReply : isReply // ignore: cast_nullable_to_non_nullable
as bool,isRepost: null == isRepost ? _self.isRepost : isRepost // ignore: cast_nullable_to_non_nullable
as bool,isQuote: null == isQuote ? _self.isQuote : isQuote // ignore: cast_nullable_to_non_nullable
as bool,hasImages: null == hasImages ? _self.hasImages : hasImages // ignore: cast_nullable_to_non_nullable
as bool,hasVideo: null == hasVideo ? _self.hasVideo : hasVideo // ignore: cast_nullable_to_non_nullable
as bool,embedType: freezed == embedType ? _self.embedType : embedType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}

// dart format on
