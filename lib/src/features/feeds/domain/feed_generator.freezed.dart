// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_generator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActorBasic {

 String get did; String get handle; String? get displayName; String? get avatar; String? get description; DateTime? get indexedAt; int? get followersCount; int? get followsCount; int? get postsCount;
/// Create a copy of ActorBasic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActorBasicCopyWith<ActorBasic> get copyWith => _$ActorBasicCopyWithImpl<ActorBasic>(this as ActorBasic, _$identity);

  /// Serializes this ActorBasic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActorBasic&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.description, description) || other.description == description)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followsCount, followsCount) || other.followsCount == followsCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,avatar,description,indexedAt,followersCount,followsCount,postsCount);

@override
String toString() {
  return 'ActorBasic(did: $did, handle: $handle, displayName: $displayName, avatar: $avatar, description: $description, indexedAt: $indexedAt, followersCount: $followersCount, followsCount: $followsCount, postsCount: $postsCount)';
}


}

/// @nodoc
abstract mixin class $ActorBasicCopyWith<$Res>  {
  factory $ActorBasicCopyWith(ActorBasic value, $Res Function(ActorBasic) _then) = _$ActorBasicCopyWithImpl;
@useResult
$Res call({
 String did, String handle, String? displayName, String? avatar, String? description, DateTime? indexedAt, int? followersCount, int? followsCount, int? postsCount
});




}
/// @nodoc
class _$ActorBasicCopyWithImpl<$Res>
    implements $ActorBasicCopyWith<$Res> {
  _$ActorBasicCopyWithImpl(this._self, this._then);

  final ActorBasic _self;
  final $Res Function(ActorBasic) _then;

/// Create a copy of ActorBasic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? avatar = freezed,Object? description = freezed,Object? indexedAt = freezed,Object? followersCount = freezed,Object? followsCount = freezed,Object? postsCount = freezed,}) {
  return _then(_self.copyWith(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,followersCount: freezed == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int?,followsCount: freezed == followsCount ? _self.followsCount : followsCount // ignore: cast_nullable_to_non_nullable
as int?,postsCount: freezed == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActorBasic].
extension ActorBasicPatterns on ActorBasic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActorBasic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActorBasic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActorBasic value)  $default,){
final _that = this;
switch (_that) {
case _ActorBasic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActorBasic value)?  $default,){
final _that = this;
switch (_that) {
case _ActorBasic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? avatar,  String? description,  DateTime? indexedAt,  int? followersCount,  int? followsCount,  int? postsCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActorBasic() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.avatar,_that.description,_that.indexedAt,_that.followersCount,_that.followsCount,_that.postsCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? avatar,  String? description,  DateTime? indexedAt,  int? followersCount,  int? followsCount,  int? postsCount)  $default,) {final _that = this;
switch (_that) {
case _ActorBasic():
return $default(_that.did,_that.handle,_that.displayName,_that.avatar,_that.description,_that.indexedAt,_that.followersCount,_that.followsCount,_that.postsCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String did,  String handle,  String? displayName,  String? avatar,  String? description,  DateTime? indexedAt,  int? followersCount,  int? followsCount,  int? postsCount)?  $default,) {final _that = this;
switch (_that) {
case _ActorBasic() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.avatar,_that.description,_that.indexedAt,_that.followersCount,_that.followsCount,_that.postsCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActorBasic implements ActorBasic {
  const _ActorBasic({required this.did, required this.handle, this.displayName, this.avatar, this.description, this.indexedAt, this.followersCount, this.followsCount, this.postsCount});
  factory _ActorBasic.fromJson(Map<String, dynamic> json) => _$ActorBasicFromJson(json);

@override final  String did;
@override final  String handle;
@override final  String? displayName;
@override final  String? avatar;
@override final  String? description;
@override final  DateTime? indexedAt;
@override final  int? followersCount;
@override final  int? followsCount;
@override final  int? postsCount;

/// Create a copy of ActorBasic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActorBasicCopyWith<_ActorBasic> get copyWith => __$ActorBasicCopyWithImpl<_ActorBasic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActorBasicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActorBasic&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.description, description) || other.description == description)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followsCount, followsCount) || other.followsCount == followsCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,avatar,description,indexedAt,followersCount,followsCount,postsCount);

@override
String toString() {
  return 'ActorBasic(did: $did, handle: $handle, displayName: $displayName, avatar: $avatar, description: $description, indexedAt: $indexedAt, followersCount: $followersCount, followsCount: $followsCount, postsCount: $postsCount)';
}


}

/// @nodoc
abstract mixin class _$ActorBasicCopyWith<$Res> implements $ActorBasicCopyWith<$Res> {
  factory _$ActorBasicCopyWith(_ActorBasic value, $Res Function(_ActorBasic) _then) = __$ActorBasicCopyWithImpl;
@override @useResult
$Res call({
 String did, String handle, String? displayName, String? avatar, String? description, DateTime? indexedAt, int? followersCount, int? followsCount, int? postsCount
});




}
/// @nodoc
class __$ActorBasicCopyWithImpl<$Res>
    implements _$ActorBasicCopyWith<$Res> {
  __$ActorBasicCopyWithImpl(this._self, this._then);

  final _ActorBasic _self;
  final $Res Function(_ActorBasic) _then;

/// Create a copy of ActorBasic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? avatar = freezed,Object? description = freezed,Object? indexedAt = freezed,Object? followersCount = freezed,Object? followsCount = freezed,Object? postsCount = freezed,}) {
  return _then(_ActorBasic(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,followersCount: freezed == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int?,followsCount: freezed == followsCount ? _self.followsCount : followsCount // ignore: cast_nullable_to_non_nullable
as int?,postsCount: freezed == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$FeedGenerator {

 String get uri; String get cid; String get did; ActorBasic get creator; String get displayName; String? get description; String? get avatar; int? get likeCount; DateTime? get indexedAt;
/// Create a copy of FeedGenerator
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedGeneratorCopyWith<FeedGenerator> get copyWith => _$FeedGeneratorCopyWithImpl<FeedGenerator>(this as FeedGenerator, _$identity);

  /// Serializes this FeedGenerator to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedGenerator&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.did, did) || other.did == did)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,cid,did,creator,displayName,description,avatar,likeCount,indexedAt);

@override
String toString() {
  return 'FeedGenerator(uri: $uri, cid: $cid, did: $did, creator: $creator, displayName: $displayName, description: $description, avatar: $avatar, likeCount: $likeCount, indexedAt: $indexedAt)';
}


}

/// @nodoc
abstract mixin class $FeedGeneratorCopyWith<$Res>  {
  factory $FeedGeneratorCopyWith(FeedGenerator value, $Res Function(FeedGenerator) _then) = _$FeedGeneratorCopyWithImpl;
@useResult
$Res call({
 String uri, String cid, String did, ActorBasic creator, String displayName, String? description, String? avatar, int? likeCount, DateTime? indexedAt
});


$ActorBasicCopyWith<$Res> get creator;

}
/// @nodoc
class _$FeedGeneratorCopyWithImpl<$Res>
    implements $FeedGeneratorCopyWith<$Res> {
  _$FeedGeneratorCopyWithImpl(this._self, this._then);

  final FeedGenerator _self;
  final $Res Function(FeedGenerator) _then;

/// Create a copy of FeedGenerator
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? cid = null,Object? did = null,Object? creator = null,Object? displayName = null,Object? description = freezed,Object? avatar = freezed,Object? likeCount = freezed,Object? indexedAt = freezed,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String,did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as ActorBasic,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,likeCount: freezed == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FeedGenerator
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActorBasicCopyWith<$Res> get creator {
  
  return $ActorBasicCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}
}


/// Adds pattern-matching-related methods to [FeedGenerator].
extension FeedGeneratorPatterns on FeedGenerator {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedGenerator value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedGenerator() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedGenerator value)  $default,){
final _that = this;
switch (_that) {
case _FeedGenerator():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedGenerator value)?  $default,){
final _that = this;
switch (_that) {
case _FeedGenerator() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String cid,  String did,  ActorBasic creator,  String displayName,  String? description,  String? avatar,  int? likeCount,  DateTime? indexedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedGenerator() when $default != null:
return $default(_that.uri,_that.cid,_that.did,_that.creator,_that.displayName,_that.description,_that.avatar,_that.likeCount,_that.indexedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String cid,  String did,  ActorBasic creator,  String displayName,  String? description,  String? avatar,  int? likeCount,  DateTime? indexedAt)  $default,) {final _that = this;
switch (_that) {
case _FeedGenerator():
return $default(_that.uri,_that.cid,_that.did,_that.creator,_that.displayName,_that.description,_that.avatar,_that.likeCount,_that.indexedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String cid,  String did,  ActorBasic creator,  String displayName,  String? description,  String? avatar,  int? likeCount,  DateTime? indexedAt)?  $default,) {final _that = this;
switch (_that) {
case _FeedGenerator() when $default != null:
return $default(_that.uri,_that.cid,_that.did,_that.creator,_that.displayName,_that.description,_that.avatar,_that.likeCount,_that.indexedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedGenerator implements FeedGenerator {
  const _FeedGenerator({required this.uri, required this.cid, required this.did, required this.creator, required this.displayName, this.description, this.avatar, this.likeCount, this.indexedAt});
  factory _FeedGenerator.fromJson(Map<String, dynamic> json) => _$FeedGeneratorFromJson(json);

@override final  String uri;
@override final  String cid;
@override final  String did;
@override final  ActorBasic creator;
@override final  String displayName;
@override final  String? description;
@override final  String? avatar;
@override final  int? likeCount;
@override final  DateTime? indexedAt;

/// Create a copy of FeedGenerator
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedGeneratorCopyWith<_FeedGenerator> get copyWith => __$FeedGeneratorCopyWithImpl<_FeedGenerator>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedGeneratorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedGenerator&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.did, did) || other.did == did)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,cid,did,creator,displayName,description,avatar,likeCount,indexedAt);

@override
String toString() {
  return 'FeedGenerator(uri: $uri, cid: $cid, did: $did, creator: $creator, displayName: $displayName, description: $description, avatar: $avatar, likeCount: $likeCount, indexedAt: $indexedAt)';
}


}

/// @nodoc
abstract mixin class _$FeedGeneratorCopyWith<$Res> implements $FeedGeneratorCopyWith<$Res> {
  factory _$FeedGeneratorCopyWith(_FeedGenerator value, $Res Function(_FeedGenerator) _then) = __$FeedGeneratorCopyWithImpl;
@override @useResult
$Res call({
 String uri, String cid, String did, ActorBasic creator, String displayName, String? description, String? avatar, int? likeCount, DateTime? indexedAt
});


@override $ActorBasicCopyWith<$Res> get creator;

}
/// @nodoc
class __$FeedGeneratorCopyWithImpl<$Res>
    implements _$FeedGeneratorCopyWith<$Res> {
  __$FeedGeneratorCopyWithImpl(this._self, this._then);

  final _FeedGenerator _self;
  final $Res Function(_FeedGenerator) _then;

/// Create a copy of FeedGenerator
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? cid = null,Object? did = null,Object? creator = null,Object? displayName = null,Object? description = freezed,Object? avatar = freezed,Object? likeCount = freezed,Object? indexedAt = freezed,}) {
  return _then(_FeedGenerator(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String,did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as ActorBasic,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,likeCount: freezed == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FeedGenerator
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActorBasicCopyWith<$Res> get creator {
  
  return $ActorBasicCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}
}

// dart format on
