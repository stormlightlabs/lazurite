// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState()';
}


}

/// @nodoc
class $AuthStateCopyWith<$Res>  {
$AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthStateUnknown value)?  unknown,TResult Function( AuthStateUnauthenticated value)?  unauthenticated,TResult Function( AuthStateAuthenticated value)?  authenticated,TResult Function( AuthStateLoading value)?  loading,TResult Function( AuthStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthStateUnknown() when unknown != null:
return unknown(_that);case AuthStateUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case AuthStateAuthenticated() when authenticated != null:
return authenticated(_that);case AuthStateLoading() when loading != null:
return loading(_that);case AuthStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthStateUnknown value)  unknown,required TResult Function( AuthStateUnauthenticated value)  unauthenticated,required TResult Function( AuthStateAuthenticated value)  authenticated,required TResult Function( AuthStateLoading value)  loading,required TResult Function( AuthStateError value)  error,}){
final _that = this;
switch (_that) {
case AuthStateUnknown():
return unknown(_that);case AuthStateUnauthenticated():
return unauthenticated(_that);case AuthStateAuthenticated():
return authenticated(_that);case AuthStateLoading():
return loading(_that);case AuthStateError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthStateUnknown value)?  unknown,TResult? Function( AuthStateUnauthenticated value)?  unauthenticated,TResult? Function( AuthStateAuthenticated value)?  authenticated,TResult? Function( AuthStateLoading value)?  loading,TResult? Function( AuthStateError value)?  error,}){
final _that = this;
switch (_that) {
case AuthStateUnknown() when unknown != null:
return unknown(_that);case AuthStateUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case AuthStateAuthenticated() when authenticated != null:
return authenticated(_that);case AuthStateLoading() when loading != null:
return loading(_that);case AuthStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  unknown,TResult Function()?  unauthenticated,TResult Function( Session session)?  authenticated,TResult Function()?  loading,TResult Function( Object error,  StackTrace? stackTrace)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthStateUnknown() when unknown != null:
return unknown();case AuthStateUnauthenticated() when unauthenticated != null:
return unauthenticated();case AuthStateAuthenticated() when authenticated != null:
return authenticated(_that.session);case AuthStateLoading() when loading != null:
return loading();case AuthStateError() when error != null:
return error(_that.error,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  unknown,required TResult Function()  unauthenticated,required TResult Function( Session session)  authenticated,required TResult Function()  loading,required TResult Function( Object error,  StackTrace? stackTrace)  error,}) {final _that = this;
switch (_that) {
case AuthStateUnknown():
return unknown();case AuthStateUnauthenticated():
return unauthenticated();case AuthStateAuthenticated():
return authenticated(_that.session);case AuthStateLoading():
return loading();case AuthStateError():
return error(_that.error,_that.stackTrace);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  unknown,TResult? Function()?  unauthenticated,TResult? Function( Session session)?  authenticated,TResult? Function()?  loading,TResult? Function( Object error,  StackTrace? stackTrace)?  error,}) {final _that = this;
switch (_that) {
case AuthStateUnknown() when unknown != null:
return unknown();case AuthStateUnauthenticated() when unauthenticated != null:
return unauthenticated();case AuthStateAuthenticated() when authenticated != null:
return authenticated(_that.session);case AuthStateLoading() when loading != null:
return loading();case AuthStateError() when error != null:
return error(_that.error,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class AuthStateUnknown extends AuthState {
  const AuthStateUnknown(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStateUnknown);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.unknown()';
}


}




/// @nodoc


class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStateUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.unauthenticated()';
}


}




/// @nodoc


class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.session): super._();
  

 final  Session session;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateAuthenticatedCopyWith<AuthStateAuthenticated> get copyWith => _$AuthStateAuthenticatedCopyWithImpl<AuthStateAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStateAuthenticated&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode => Object.hash(runtimeType,session);

@override
String toString() {
  return 'AuthState.authenticated(session: $session)';
}


}

/// @nodoc
abstract mixin class $AuthStateAuthenticatedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthStateAuthenticatedCopyWith(AuthStateAuthenticated value, $Res Function(AuthStateAuthenticated) _then) = _$AuthStateAuthenticatedCopyWithImpl;
@useResult
$Res call({
 Session session
});


$SessionCopyWith<$Res> get session;

}
/// @nodoc
class _$AuthStateAuthenticatedCopyWithImpl<$Res>
    implements $AuthStateAuthenticatedCopyWith<$Res> {
  _$AuthStateAuthenticatedCopyWithImpl(this._self, this._then);

  final AuthStateAuthenticated _self;
  final $Res Function(AuthStateAuthenticated) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? session = null,}) {
  return _then(AuthStateAuthenticated(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as Session,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionCopyWith<$Res> get session {
  
  return $SessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc


class AuthStateLoading extends AuthState {
  const AuthStateLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.loading()';
}


}




/// @nodoc


class AuthStateError extends AuthState {
  const AuthStateError(this.error, this.stackTrace): super._();
  

 final  Object error;
 final  StackTrace? stackTrace;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthStateErrorCopyWith<AuthStateError> get copyWith => _$AuthStateErrorCopyWithImpl<AuthStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthStateError&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(error),stackTrace);

@override
String toString() {
  return 'AuthState.error(error: $error, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $AuthStateErrorCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthStateErrorCopyWith(AuthStateError value, $Res Function(AuthStateError) _then) = _$AuthStateErrorCopyWithImpl;
@useResult
$Res call({
 Object error, StackTrace? stackTrace
});




}
/// @nodoc
class _$AuthStateErrorCopyWithImpl<$Res>
    implements $AuthStateErrorCopyWith<$Res> {
  _$AuthStateErrorCopyWithImpl(this._self, this._then);

  final AuthStateError _self;
  final $Res Function(AuthStateError) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,Object? stackTrace = freezed,}) {
  return _then(AuthStateError(
null == error ? _self.error : error ,freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
