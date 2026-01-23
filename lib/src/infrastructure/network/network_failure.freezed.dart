// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NetworkFailure {

 String? get message; Object? get cause;
/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkFailureCopyWith<NetworkFailure> get copyWith => _$NetworkFailureCopyWithImpl<NetworkFailure>(this as NetworkFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));



}

/// @nodoc
abstract mixin class $NetworkFailureCopyWith<$Res>  {
  factory $NetworkFailureCopyWith(NetworkFailure value, $Res Function(NetworkFailure) _then) = _$NetworkFailureCopyWithImpl;
@useResult
$Res call({
 String? message, Object? cause
});




}
/// @nodoc
class _$NetworkFailureCopyWithImpl<$Res>
    implements $NetworkFailureCopyWith<$Res> {
  _$NetworkFailureCopyWithImpl(this._self, this._then);

  final NetworkFailure _self;
  final $Res Function(NetworkFailure) _then;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? cause = freezed,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkFailure].
extension NetworkFailurePatterns on NetworkFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ConnectionFailure value)?  connection,TResult Function( AuthFailure value)?  auth,TResult Function( ServerFailure value)?  server,TResult Function( ClientFailure value)?  client,TResult Function( RateLimitFailure value)?  rateLimit,TResult Function( DecodeFailure value)?  decode,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ConnectionFailure() when connection != null:
return connection(_that);case AuthFailure() when auth != null:
return auth(_that);case ServerFailure() when server != null:
return server(_that);case ClientFailure() when client != null:
return client(_that);case RateLimitFailure() when rateLimit != null:
return rateLimit(_that);case DecodeFailure() when decode != null:
return decode(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ConnectionFailure value)  connection,required TResult Function( AuthFailure value)  auth,required TResult Function( ServerFailure value)  server,required TResult Function( ClientFailure value)  client,required TResult Function( RateLimitFailure value)  rateLimit,required TResult Function( DecodeFailure value)  decode,}){
final _that = this;
switch (_that) {
case ConnectionFailure():
return connection(_that);case AuthFailure():
return auth(_that);case ServerFailure():
return server(_that);case ClientFailure():
return client(_that);case RateLimitFailure():
return rateLimit(_that);case DecodeFailure():
return decode(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ConnectionFailure value)?  connection,TResult? Function( AuthFailure value)?  auth,TResult? Function( ServerFailure value)?  server,TResult? Function( ClientFailure value)?  client,TResult? Function( RateLimitFailure value)?  rateLimit,TResult? Function( DecodeFailure value)?  decode,}){
final _that = this;
switch (_that) {
case ConnectionFailure() when connection != null:
return connection(_that);case AuthFailure() when auth != null:
return auth(_that);case ServerFailure() when server != null:
return server(_that);case ClientFailure() when client != null:
return client(_that);case RateLimitFailure() when rateLimit != null:
return rateLimit(_that);case DecodeFailure() when decode != null:
return decode(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? message,  Object? cause)?  connection,TResult Function( String? message,  Object? cause,  bool requiresReauth)?  auth,TResult Function( String? message,  Object? cause,  int statusCode)?  server,TResult Function( String? message,  Object? cause,  int statusCode,  String? errorCode)?  client,TResult Function( String? message,  Object? cause,  Duration? retryAfter)?  rateLimit,TResult Function( String? message,  Object? cause)?  decode,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ConnectionFailure() when connection != null:
return connection(_that.message,_that.cause);case AuthFailure() when auth != null:
return auth(_that.message,_that.cause,_that.requiresReauth);case ServerFailure() when server != null:
return server(_that.message,_that.cause,_that.statusCode);case ClientFailure() when client != null:
return client(_that.message,_that.cause,_that.statusCode,_that.errorCode);case RateLimitFailure() when rateLimit != null:
return rateLimit(_that.message,_that.cause,_that.retryAfter);case DecodeFailure() when decode != null:
return decode(_that.message,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? message,  Object? cause)  connection,required TResult Function( String? message,  Object? cause,  bool requiresReauth)  auth,required TResult Function( String? message,  Object? cause,  int statusCode)  server,required TResult Function( String? message,  Object? cause,  int statusCode,  String? errorCode)  client,required TResult Function( String? message,  Object? cause,  Duration? retryAfter)  rateLimit,required TResult Function( String? message,  Object? cause)  decode,}) {final _that = this;
switch (_that) {
case ConnectionFailure():
return connection(_that.message,_that.cause);case AuthFailure():
return auth(_that.message,_that.cause,_that.requiresReauth);case ServerFailure():
return server(_that.message,_that.cause,_that.statusCode);case ClientFailure():
return client(_that.message,_that.cause,_that.statusCode,_that.errorCode);case RateLimitFailure():
return rateLimit(_that.message,_that.cause,_that.retryAfter);case DecodeFailure():
return decode(_that.message,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? message,  Object? cause)?  connection,TResult? Function( String? message,  Object? cause,  bool requiresReauth)?  auth,TResult? Function( String? message,  Object? cause,  int statusCode)?  server,TResult? Function( String? message,  Object? cause,  int statusCode,  String? errorCode)?  client,TResult? Function( String? message,  Object? cause,  Duration? retryAfter)?  rateLimit,TResult? Function( String? message,  Object? cause)?  decode,}) {final _that = this;
switch (_that) {
case ConnectionFailure() when connection != null:
return connection(_that.message,_that.cause);case AuthFailure() when auth != null:
return auth(_that.message,_that.cause,_that.requiresReauth);case ServerFailure() when server != null:
return server(_that.message,_that.cause,_that.statusCode);case ClientFailure() when client != null:
return client(_that.message,_that.cause,_that.statusCode,_that.errorCode);case RateLimitFailure() when rateLimit != null:
return rateLimit(_that.message,_that.cause,_that.retryAfter);case DecodeFailure() when decode != null:
return decode(_that.message,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class ConnectionFailure extends NetworkFailure {
  const ConnectionFailure({this.message, this.cause}): super._();
  

@override final  String? message;
@override final  Object? cause;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionFailureCopyWith<ConnectionFailure> get copyWith => _$ConnectionFailureCopyWithImpl<ConnectionFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));



}

/// @nodoc
abstract mixin class $ConnectionFailureCopyWith<$Res> implements $NetworkFailureCopyWith<$Res> {
  factory $ConnectionFailureCopyWith(ConnectionFailure value, $Res Function(ConnectionFailure) _then) = _$ConnectionFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause
});




}
/// @nodoc
class _$ConnectionFailureCopyWithImpl<$Res>
    implements $ConnectionFailureCopyWith<$Res> {
  _$ConnectionFailureCopyWithImpl(this._self, this._then);

  final ConnectionFailure _self;
  final $Res Function(ConnectionFailure) _then;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,}) {
  return _then(ConnectionFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

/// @nodoc


class AuthFailure extends NetworkFailure {
  const AuthFailure({this.message, this.cause, this.requiresReauth = false}): super._();
  

@override final  String? message;
@override final  Object? cause;
@JsonKey() final  bool requiresReauth;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<AuthFailure> get copyWith => _$AuthFailureCopyWithImpl<AuthFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause)&&(identical(other.requiresReauth, requiresReauth) || other.requiresReauth == requiresReauth));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause),requiresReauth);



}

/// @nodoc
abstract mixin class $AuthFailureCopyWith<$Res> implements $NetworkFailureCopyWith<$Res> {
  factory $AuthFailureCopyWith(AuthFailure value, $Res Function(AuthFailure) _then) = _$AuthFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause, bool requiresReauth
});




}
/// @nodoc
class _$AuthFailureCopyWithImpl<$Res>
    implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._self, this._then);

  final AuthFailure _self;
  final $Res Function(AuthFailure) _then;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,Object? requiresReauth = null,}) {
  return _then(AuthFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,requiresReauth: null == requiresReauth ? _self.requiresReauth : requiresReauth // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ServerFailure extends NetworkFailure {
  const ServerFailure({this.message, this.cause, required this.statusCode}): super._();
  

@override final  String? message;
@override final  Object? cause;
 final  int statusCode;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerFailureCopyWith<ServerFailure> get copyWith => _$ServerFailureCopyWithImpl<ServerFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause),statusCode);



}

/// @nodoc
abstract mixin class $ServerFailureCopyWith<$Res> implements $NetworkFailureCopyWith<$Res> {
  factory $ServerFailureCopyWith(ServerFailure value, $Res Function(ServerFailure) _then) = _$ServerFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause, int statusCode
});




}
/// @nodoc
class _$ServerFailureCopyWithImpl<$Res>
    implements $ServerFailureCopyWith<$Res> {
  _$ServerFailureCopyWithImpl(this._self, this._then);

  final ServerFailure _self;
  final $Res Function(ServerFailure) _then;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,Object? statusCode = null,}) {
  return _then(ServerFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ClientFailure extends NetworkFailure {
  const ClientFailure({this.message, this.cause, required this.statusCode, this.errorCode}): super._();
  

@override final  String? message;
@override final  Object? cause;
 final  int statusCode;
 final  String? errorCode;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientFailureCopyWith<ClientFailure> get copyWith => _$ClientFailureCopyWithImpl<ClientFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause),statusCode,errorCode);



}

/// @nodoc
abstract mixin class $ClientFailureCopyWith<$Res> implements $NetworkFailureCopyWith<$Res> {
  factory $ClientFailureCopyWith(ClientFailure value, $Res Function(ClientFailure) _then) = _$ClientFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause, int statusCode, String? errorCode
});




}
/// @nodoc
class _$ClientFailureCopyWithImpl<$Res>
    implements $ClientFailureCopyWith<$Res> {
  _$ClientFailureCopyWithImpl(this._self, this._then);

  final ClientFailure _self;
  final $Res Function(ClientFailure) _then;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,Object? statusCode = null,Object? errorCode = freezed,}) {
  return _then(ClientFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class RateLimitFailure extends NetworkFailure {
  const RateLimitFailure({this.message, this.cause, this.retryAfter}): super._();
  

@override final  String? message;
@override final  Object? cause;
 final  Duration? retryAfter;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateLimitFailureCopyWith<RateLimitFailure> get copyWith => _$RateLimitFailureCopyWithImpl<RateLimitFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateLimitFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause),retryAfter);



}

/// @nodoc
abstract mixin class $RateLimitFailureCopyWith<$Res> implements $NetworkFailureCopyWith<$Res> {
  factory $RateLimitFailureCopyWith(RateLimitFailure value, $Res Function(RateLimitFailure) _then) = _$RateLimitFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause, Duration? retryAfter
});




}
/// @nodoc
class _$RateLimitFailureCopyWithImpl<$Res>
    implements $RateLimitFailureCopyWith<$Res> {
  _$RateLimitFailureCopyWithImpl(this._self, this._then);

  final RateLimitFailure _self;
  final $Res Function(RateLimitFailure) _then;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,Object? retryAfter = freezed,}) {
  return _then(RateLimitFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

/// @nodoc


class DecodeFailure extends NetworkFailure {
  const DecodeFailure({this.message, this.cause}): super._();
  

@override final  String? message;
@override final  Object? cause;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecodeFailureCopyWith<DecodeFailure> get copyWith => _$DecodeFailureCopyWithImpl<DecodeFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DecodeFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));



}

/// @nodoc
abstract mixin class $DecodeFailureCopyWith<$Res> implements $NetworkFailureCopyWith<$Res> {
  factory $DecodeFailureCopyWith(DecodeFailure value, $Res Function(DecodeFailure) _then) = _$DecodeFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause
});




}
/// @nodoc
class _$DecodeFailureCopyWithImpl<$Res>
    implements $DecodeFailureCopyWith<$Res> {
  _$DecodeFailureCopyWithImpl(this._self, this._then);

  final DecodeFailure _self;
  final $Res Function(DecodeFailure) _then;

/// Create a copy of NetworkFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,}) {
  return _then(DecodeFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

// dart format on
