// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecentRecord {

 String get uri; String get did; String get collection; String get rkey; String? get cid; DateTime? get indexedAt; DateTime get viewedAt;
/// Create a copy of RecentRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentRecordCopyWith<RecentRecord> get copyWith => _$RecentRecordCopyWithImpl<RecentRecord>(this as RecentRecord, _$identity);

  /// Serializes this RecentRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentRecord&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.did, did) || other.did == did)&&(identical(other.collection, collection) || other.collection == collection)&&(identical(other.rkey, rkey) || other.rkey == rkey)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,did,collection,rkey,cid,indexedAt,viewedAt);

@override
String toString() {
  return 'RecentRecord(uri: $uri, did: $did, collection: $collection, rkey: $rkey, cid: $cid, indexedAt: $indexedAt, viewedAt: $viewedAt)';
}


}

/// @nodoc
abstract mixin class $RecentRecordCopyWith<$Res>  {
  factory $RecentRecordCopyWith(RecentRecord value, $Res Function(RecentRecord) _then) = _$RecentRecordCopyWithImpl;
@useResult
$Res call({
 String uri, String did, String collection, String rkey, String? cid, DateTime? indexedAt, DateTime viewedAt
});




}
/// @nodoc
class _$RecentRecordCopyWithImpl<$Res>
    implements $RecentRecordCopyWith<$Res> {
  _$RecentRecordCopyWithImpl(this._self, this._then);

  final RecentRecord _self;
  final $Res Function(RecentRecord) _then;

/// Create a copy of RecentRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? did = null,Object? collection = null,Object? rkey = null,Object? cid = freezed,Object? indexedAt = freezed,Object? viewedAt = null,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as String,rkey: null == rkey ? _self.rkey : rkey // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedAt: null == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentRecord].
extension RecentRecordPatterns on RecentRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentRecord value)  $default,){
final _that = this;
switch (_that) {
case _RecentRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentRecord value)?  $default,){
final _that = this;
switch (_that) {
case _RecentRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String did,  String collection,  String rkey,  String? cid,  DateTime? indexedAt,  DateTime viewedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentRecord() when $default != null:
return $default(_that.uri,_that.did,_that.collection,_that.rkey,_that.cid,_that.indexedAt,_that.viewedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String did,  String collection,  String rkey,  String? cid,  DateTime? indexedAt,  DateTime viewedAt)  $default,) {final _that = this;
switch (_that) {
case _RecentRecord():
return $default(_that.uri,_that.did,_that.collection,_that.rkey,_that.cid,_that.indexedAt,_that.viewedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String did,  String collection,  String rkey,  String? cid,  DateTime? indexedAt,  DateTime viewedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecentRecord() when $default != null:
return $default(_that.uri,_that.did,_that.collection,_that.rkey,_that.cid,_that.indexedAt,_that.viewedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentRecord implements RecentRecord {
  const _RecentRecord({required this.uri, required this.did, required this.collection, required this.rkey, this.cid, this.indexedAt, required this.viewedAt});
  factory _RecentRecord.fromJson(Map<String, dynamic> json) => _$RecentRecordFromJson(json);

@override final  String uri;
@override final  String did;
@override final  String collection;
@override final  String rkey;
@override final  String? cid;
@override final  DateTime? indexedAt;
@override final  DateTime viewedAt;

/// Create a copy of RecentRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentRecordCopyWith<_RecentRecord> get copyWith => __$RecentRecordCopyWithImpl<_RecentRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentRecord&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.did, did) || other.did == did)&&(identical(other.collection, collection) || other.collection == collection)&&(identical(other.rkey, rkey) || other.rkey == rkey)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,did,collection,rkey,cid,indexedAt,viewedAt);

@override
String toString() {
  return 'RecentRecord(uri: $uri, did: $did, collection: $collection, rkey: $rkey, cid: $cid, indexedAt: $indexedAt, viewedAt: $viewedAt)';
}


}

/// @nodoc
abstract mixin class _$RecentRecordCopyWith<$Res> implements $RecentRecordCopyWith<$Res> {
  factory _$RecentRecordCopyWith(_RecentRecord value, $Res Function(_RecentRecord) _then) = __$RecentRecordCopyWithImpl;
@override @useResult
$Res call({
 String uri, String did, String collection, String rkey, String? cid, DateTime? indexedAt, DateTime viewedAt
});




}
/// @nodoc
class __$RecentRecordCopyWithImpl<$Res>
    implements _$RecentRecordCopyWith<$Res> {
  __$RecentRecordCopyWithImpl(this._self, this._then);

  final _RecentRecord _self;
  final $Res Function(_RecentRecord) _then;

/// Create a copy of RecentRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? did = null,Object? collection = null,Object? rkey = null,Object? cid = freezed,Object? indexedAt = freezed,Object? viewedAt = null,}) {
  return _then(_RecentRecord(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as String,rkey: null == rkey ? _self.rkey : rkey // ignore: cast_nullable_to_non_nullable
as String,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedAt: null == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
