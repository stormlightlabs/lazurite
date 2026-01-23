// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_actor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchActorItem {

 String get did; String get handle; String? get displayName; String? get description; String? get avatar; int get followersCount; int get followsCount; DateTime? get indexedAt; String? get allowIncoming;
/// Create a copy of SearchActorItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchActorItemCopyWith<SearchActorItem> get copyWith => _$SearchActorItemCopyWithImpl<SearchActorItem>(this as SearchActorItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchActorItem&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followsCount, followsCount) || other.followsCount == followsCount)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.allowIncoming, allowIncoming) || other.allowIncoming == allowIncoming));
}


@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,description,avatar,followersCount,followsCount,indexedAt,allowIncoming);

@override
String toString() {
  return 'SearchActorItem(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, followersCount: $followersCount, followsCount: $followsCount, indexedAt: $indexedAt, allowIncoming: $allowIncoming)';
}


}

/// @nodoc
abstract mixin class $SearchActorItemCopyWith<$Res>  {
  factory $SearchActorItemCopyWith(SearchActorItem value, $Res Function(SearchActorItem) _then) = _$SearchActorItemCopyWithImpl;
@useResult
$Res call({
 String did, String handle, String? displayName, String? description, String? avatar, int followersCount, int followsCount, DateTime? indexedAt, String? allowIncoming
});




}
/// @nodoc
class _$SearchActorItemCopyWithImpl<$Res>
    implements $SearchActorItemCopyWith<$Res> {
  _$SearchActorItemCopyWithImpl(this._self, this._then);

  final SearchActorItem _self;
  final $Res Function(SearchActorItem) _then;

/// Create a copy of SearchActorItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? description = freezed,Object? avatar = freezed,Object? followersCount = null,Object? followsCount = null,Object? indexedAt = freezed,Object? allowIncoming = freezed,}) {
  return _then(_self.copyWith(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followsCount: null == followsCount ? _self.followsCount : followsCount // ignore: cast_nullable_to_non_nullable
as int,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,allowIncoming: freezed == allowIncoming ? _self.allowIncoming : allowIncoming // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchActorItem].
extension SearchActorItemPatterns on SearchActorItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchActorItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchActorItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchActorItem value)  $default,){
final _that = this;
switch (_that) {
case _SearchActorItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchActorItem value)?  $default,){
final _that = this;
switch (_that) {
case _SearchActorItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  int followersCount,  int followsCount,  DateTime? indexedAt,  String? allowIncoming)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchActorItem() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.followersCount,_that.followsCount,_that.indexedAt,_that.allowIncoming);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  int followersCount,  int followsCount,  DateTime? indexedAt,  String? allowIncoming)  $default,) {final _that = this;
switch (_that) {
case _SearchActorItem():
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.followersCount,_that.followsCount,_that.indexedAt,_that.allowIncoming);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  int followersCount,  int followsCount,  DateTime? indexedAt,  String? allowIncoming)?  $default,) {final _that = this;
switch (_that) {
case _SearchActorItem() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.followersCount,_that.followsCount,_that.indexedAt,_that.allowIncoming);case _:
  return null;

}
}

}

/// @nodoc


class _SearchActorItem extends SearchActorItem {
  const _SearchActorItem({required this.did, required this.handle, this.displayName, this.description, this.avatar, this.followersCount = 0, this.followsCount = 0, this.indexedAt, this.allowIncoming}): super._();
  

@override final  String did;
@override final  String handle;
@override final  String? displayName;
@override final  String? description;
@override final  String? avatar;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followsCount;
@override final  DateTime? indexedAt;
@override final  String? allowIncoming;

/// Create a copy of SearchActorItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchActorItemCopyWith<_SearchActorItem> get copyWith => __$SearchActorItemCopyWithImpl<_SearchActorItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchActorItem&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followsCount, followsCount) || other.followsCount == followsCount)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.allowIncoming, allowIncoming) || other.allowIncoming == allowIncoming));
}


@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,description,avatar,followersCount,followsCount,indexedAt,allowIncoming);

@override
String toString() {
  return 'SearchActorItem(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, followersCount: $followersCount, followsCount: $followsCount, indexedAt: $indexedAt, allowIncoming: $allowIncoming)';
}


}

/// @nodoc
abstract mixin class _$SearchActorItemCopyWith<$Res> implements $SearchActorItemCopyWith<$Res> {
  factory _$SearchActorItemCopyWith(_SearchActorItem value, $Res Function(_SearchActorItem) _then) = __$SearchActorItemCopyWithImpl;
@override @useResult
$Res call({
 String did, String handle, String? displayName, String? description, String? avatar, int followersCount, int followsCount, DateTime? indexedAt, String? allowIncoming
});




}
/// @nodoc
class __$SearchActorItemCopyWithImpl<$Res>
    implements _$SearchActorItemCopyWith<$Res> {
  __$SearchActorItemCopyWithImpl(this._self, this._then);

  final _SearchActorItem _self;
  final $Res Function(_SearchActorItem) _then;

/// Create a copy of SearchActorItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? description = freezed,Object? avatar = freezed,Object? followersCount = null,Object? followsCount = null,Object? indexedAt = freezed,Object? allowIncoming = freezed,}) {
  return _then(_SearchActorItem(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followsCount: null == followsCount ? _self.followsCount : followsCount // ignore: cast_nullable_to_non_nullable
as int,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,allowIncoming: freezed == allowIncoming ? _self.allowIncoming : allowIncoming // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
