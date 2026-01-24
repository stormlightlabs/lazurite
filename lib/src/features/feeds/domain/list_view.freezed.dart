// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListView {

 String get uri; String get cid; ActorBasic get creator; String get name; String get purpose; String? get description; String? get avatar; int? get listItemCount; DateTime? get indexedAt;
/// Create a copy of ListView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListViewCopyWith<ListView> get copyWith => _$ListViewCopyWithImpl<ListView>(this as ListView, _$identity);

  /// Serializes this ListView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListView&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.name, name) || other.name == name)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.listItemCount, listItemCount) || other.listItemCount == listItemCount)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,cid,creator,name,purpose,description,avatar,listItemCount,indexedAt);

@override
String toString() {
  return 'ListView(uri: $uri, cid: $cid, creator: $creator, name: $name, purpose: $purpose, description: $description, avatar: $avatar, listItemCount: $listItemCount, indexedAt: $indexedAt)';
}


}

/// @nodoc
abstract mixin class $ListViewCopyWith<$Res>  {
  factory $ListViewCopyWith(ListView value, $Res Function(ListView) _then) = _$ListViewCopyWithImpl;
@useResult
$Res call({
 String uri, String cid, ActorBasic creator, String name, String purpose, String? description, String? avatar, int? listItemCount, DateTime? indexedAt
});


$ActorBasicCopyWith<$Res> get creator;

}
/// @nodoc
class _$ListViewCopyWithImpl<$Res>
    implements $ListViewCopyWith<$Res> {
  _$ListViewCopyWithImpl(this._self, this._then);

  final ListView _self;
  final $Res Function(ListView) _then;

/// Create a copy of ListView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? cid = null,Object? creator = null,Object? name = null,Object? purpose = null,Object? description = freezed,Object? avatar = freezed,Object? listItemCount = freezed,Object? indexedAt = freezed,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as ActorBasic,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,listItemCount: freezed == listItemCount ? _self.listItemCount : listItemCount // ignore: cast_nullable_to_non_nullable
as int?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ListView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActorBasicCopyWith<$Res> get creator {
  
  return $ActorBasicCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListView].
extension ListViewPatterns on ListView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListView value)  $default,){
final _that = this;
switch (_that) {
case _ListView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListView value)?  $default,){
final _that = this;
switch (_that) {
case _ListView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String cid,  ActorBasic creator,  String name,  String purpose,  String? description,  String? avatar,  int? listItemCount,  DateTime? indexedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListView() when $default != null:
return $default(_that.uri,_that.cid,_that.creator,_that.name,_that.purpose,_that.description,_that.avatar,_that.listItemCount,_that.indexedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String cid,  ActorBasic creator,  String name,  String purpose,  String? description,  String? avatar,  int? listItemCount,  DateTime? indexedAt)  $default,) {final _that = this;
switch (_that) {
case _ListView():
return $default(_that.uri,_that.cid,_that.creator,_that.name,_that.purpose,_that.description,_that.avatar,_that.listItemCount,_that.indexedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String cid,  ActorBasic creator,  String name,  String purpose,  String? description,  String? avatar,  int? listItemCount,  DateTime? indexedAt)?  $default,) {final _that = this;
switch (_that) {
case _ListView() when $default != null:
return $default(_that.uri,_that.cid,_that.creator,_that.name,_that.purpose,_that.description,_that.avatar,_that.listItemCount,_that.indexedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListView implements ListView {
  const _ListView({required this.uri, required this.cid, required this.creator, required this.name, required this.purpose, this.description, this.avatar, this.listItemCount, this.indexedAt});
  factory _ListView.fromJson(Map<String, dynamic> json) => _$ListViewFromJson(json);

@override final  String uri;
@override final  String cid;
@override final  ActorBasic creator;
@override final  String name;
@override final  String purpose;
@override final  String? description;
@override final  String? avatar;
@override final  int? listItemCount;
@override final  DateTime? indexedAt;

/// Create a copy of ListView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListViewCopyWith<_ListView> get copyWith => __$ListViewCopyWithImpl<_ListView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListView&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.name, name) || other.name == name)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.listItemCount, listItemCount) || other.listItemCount == listItemCount)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,cid,creator,name,purpose,description,avatar,listItemCount,indexedAt);

@override
String toString() {
  return 'ListView(uri: $uri, cid: $cid, creator: $creator, name: $name, purpose: $purpose, description: $description, avatar: $avatar, listItemCount: $listItemCount, indexedAt: $indexedAt)';
}


}

/// @nodoc
abstract mixin class _$ListViewCopyWith<$Res> implements $ListViewCopyWith<$Res> {
  factory _$ListViewCopyWith(_ListView value, $Res Function(_ListView) _then) = __$ListViewCopyWithImpl;
@override @useResult
$Res call({
 String uri, String cid, ActorBasic creator, String name, String purpose, String? description, String? avatar, int? listItemCount, DateTime? indexedAt
});


@override $ActorBasicCopyWith<$Res> get creator;

}
/// @nodoc
class __$ListViewCopyWithImpl<$Res>
    implements _$ListViewCopyWith<$Res> {
  __$ListViewCopyWithImpl(this._self, this._then);

  final _ListView _self;
  final $Res Function(_ListView) _then;

/// Create a copy of ListView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? cid = null,Object? creator = null,Object? name = null,Object? purpose = null,Object? description = freezed,Object? avatar = freezed,Object? listItemCount = freezed,Object? indexedAt = freezed,}) {
  return _then(_ListView(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,cid: null == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as ActorBasic,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,listItemCount: freezed == listItemCount ? _self.listItemCount : listItemCount // ignore: cast_nullable_to_non_nullable
as int?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ListView
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
