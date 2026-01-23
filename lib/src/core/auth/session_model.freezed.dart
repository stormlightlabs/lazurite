// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Session {

 String get did; String get handle; String get pdsUrl; String get accessJwt; String get refreshJwt; String get scope; DateTime get expiresAt; Map<String, dynamic> get dpopKey;
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCopyWith<Session> get copyWith => _$SessionCopyWithImpl<Session>(this as Session, _$identity);

  /// Serializes this Session to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Session&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.pdsUrl, pdsUrl) || other.pdsUrl == pdsUrl)&&(identical(other.accessJwt, accessJwt) || other.accessJwt == accessJwt)&&(identical(other.refreshJwt, refreshJwt) || other.refreshJwt == refreshJwt)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.dpopKey, dpopKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,pdsUrl,accessJwt,refreshJwt,scope,expiresAt,const DeepCollectionEquality().hash(dpopKey));

@override
String toString() {
  return 'Session(did: $did, handle: $handle, pdsUrl: $pdsUrl, accessJwt: $accessJwt, refreshJwt: $refreshJwt, scope: $scope, expiresAt: $expiresAt, dpopKey: $dpopKey)';
}


}

/// @nodoc
abstract mixin class $SessionCopyWith<$Res>  {
  factory $SessionCopyWith(Session value, $Res Function(Session) _then) = _$SessionCopyWithImpl;
@useResult
$Res call({
 String did, String handle, String pdsUrl, String accessJwt, String refreshJwt, String scope, DateTime expiresAt, Map<String, dynamic> dpopKey
});




}
/// @nodoc
class _$SessionCopyWithImpl<$Res>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._self, this._then);

  final Session _self;
  final $Res Function(Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? did = null,Object? handle = null,Object? pdsUrl = null,Object? accessJwt = null,Object? refreshJwt = null,Object? scope = null,Object? expiresAt = null,Object? dpopKey = null,}) {
  return _then(_self.copyWith(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,pdsUrl: null == pdsUrl ? _self.pdsUrl : pdsUrl // ignore: cast_nullable_to_non_nullable
as String,accessJwt: null == accessJwt ? _self.accessJwt : accessJwt // ignore: cast_nullable_to_non_nullable
as String,refreshJwt: null == refreshJwt ? _self.refreshJwt : refreshJwt // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,dpopKey: null == dpopKey ? _self.dpopKey : dpopKey // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [Session].
extension SessionPatterns on Session {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Session value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Session value)  $default,){
final _that = this;
switch (_that) {
case _Session():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Session value)?  $default,){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String did,  String handle,  String pdsUrl,  String accessJwt,  String refreshJwt,  String scope,  DateTime expiresAt,  Map<String, dynamic> dpopKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.did,_that.handle,_that.pdsUrl,_that.accessJwt,_that.refreshJwt,_that.scope,_that.expiresAt,_that.dpopKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String did,  String handle,  String pdsUrl,  String accessJwt,  String refreshJwt,  String scope,  DateTime expiresAt,  Map<String, dynamic> dpopKey)  $default,) {final _that = this;
switch (_that) {
case _Session():
return $default(_that.did,_that.handle,_that.pdsUrl,_that.accessJwt,_that.refreshJwt,_that.scope,_that.expiresAt,_that.dpopKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String did,  String handle,  String pdsUrl,  String accessJwt,  String refreshJwt,  String scope,  DateTime expiresAt,  Map<String, dynamic> dpopKey)?  $default,) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.did,_that.handle,_that.pdsUrl,_that.accessJwt,_that.refreshJwt,_that.scope,_that.expiresAt,_that.dpopKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Session extends Session {
  const _Session({required this.did, required this.handle, required this.pdsUrl, required this.accessJwt, required this.refreshJwt, required this.scope, required this.expiresAt, required final  Map<String, dynamic> dpopKey}): _dpopKey = dpopKey,super._();
  factory _Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

@override final  String did;
@override final  String handle;
@override final  String pdsUrl;
@override final  String accessJwt;
@override final  String refreshJwt;
@override final  String scope;
@override final  DateTime expiresAt;
 final  Map<String, dynamic> _dpopKey;
@override Map<String, dynamic> get dpopKey {
  if (_dpopKey is EqualUnmodifiableMapView) return _dpopKey;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dpopKey);
}


/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCopyWith<_Session> get copyWith => __$SessionCopyWithImpl<_Session>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Session&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.pdsUrl, pdsUrl) || other.pdsUrl == pdsUrl)&&(identical(other.accessJwt, accessJwt) || other.accessJwt == accessJwt)&&(identical(other.refreshJwt, refreshJwt) || other.refreshJwt == refreshJwt)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other._dpopKey, _dpopKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,pdsUrl,accessJwt,refreshJwt,scope,expiresAt,const DeepCollectionEquality().hash(_dpopKey));

@override
String toString() {
  return 'Session(did: $did, handle: $handle, pdsUrl: $pdsUrl, accessJwt: $accessJwt, refreshJwt: $refreshJwt, scope: $scope, expiresAt: $expiresAt, dpopKey: $dpopKey)';
}


}

/// @nodoc
abstract mixin class _$SessionCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$SessionCopyWith(_Session value, $Res Function(_Session) _then) = __$SessionCopyWithImpl;
@override @useResult
$Res call({
 String did, String handle, String pdsUrl, String accessJwt, String refreshJwt, String scope, DateTime expiresAt, Map<String, dynamic> dpopKey
});




}
/// @nodoc
class __$SessionCopyWithImpl<$Res>
    implements _$SessionCopyWith<$Res> {
  __$SessionCopyWithImpl(this._self, this._then);

  final _Session _self;
  final $Res Function(_Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? did = null,Object? handle = null,Object? pdsUrl = null,Object? accessJwt = null,Object? refreshJwt = null,Object? scope = null,Object? expiresAt = null,Object? dpopKey = null,}) {
  return _then(_Session(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,pdsUrl: null == pdsUrl ? _self.pdsUrl : pdsUrl // ignore: cast_nullable_to_non_nullable
as String,accessJwt: null == accessJwt ? _self.accessJwt : accessJwt // ignore: cast_nullable_to_non_nullable
as String,refreshJwt: null == refreshJwt ? _self.refreshJwt : refreshJwt // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,dpopKey: null == dpopKey ? _self._dpopKey : dpopKey // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
