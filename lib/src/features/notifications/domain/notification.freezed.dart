// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppNotification {

/// Notification AT URI (unique identifier).
 String get uri;/// The user who triggered the notification.
 Author get actor;/// The type of notification.
 NotificationType get type;/// URI of the subject (post/profile) this notification is about.
 String? get reasonSubjectUri;/// Associated record JSON (for displaying notification context).
 String? get recordJson;/// When the notification was indexed on the server.
 DateTime get indexedAt;/// Whether the notification has been read.
 bool get isRead;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.type, type) || other.type == type)&&(identical(other.reasonSubjectUri, reasonSubjectUri) || other.reasonSubjectUri == reasonSubjectUri)&&(identical(other.recordJson, recordJson) || other.recordJson == recordJson)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,actor,type,reasonSubjectUri,recordJson,indexedAt,isRead);

@override
String toString() {
  return 'AppNotification(uri: $uri, actor: $actor, type: $type, reasonSubjectUri: $reasonSubjectUri, recordJson: $recordJson, indexedAt: $indexedAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
 String uri, Author actor, NotificationType type, String? reasonSubjectUri, String? recordJson, DateTime indexedAt, bool isRead
});


$AuthorCopyWith<$Res> get actor;

}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? actor = null,Object? type = null,Object? reasonSubjectUri = freezed,Object? recordJson = freezed,Object? indexedAt = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,actor: null == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as Author,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,reasonSubjectUri: freezed == reasonSubjectUri ? _self.reasonSubjectUri : reasonSubjectUri // ignore: cast_nullable_to_non_nullable
as String?,recordJson: freezed == recordJson ? _self.recordJson : recordJson // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: null == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get actor {
  
  return $AuthorCopyWith<$Res>(_self.actor, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotification value)  $default,){
final _that = this;
switch (_that) {
case _AppNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  Author actor,  NotificationType type,  String? reasonSubjectUri,  String? recordJson,  DateTime indexedAt,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.uri,_that.actor,_that.type,_that.reasonSubjectUri,_that.recordJson,_that.indexedAt,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  Author actor,  NotificationType type,  String? reasonSubjectUri,  String? recordJson,  DateTime indexedAt,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that.uri,_that.actor,_that.type,_that.reasonSubjectUri,_that.recordJson,_that.indexedAt,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  Author actor,  NotificationType type,  String? reasonSubjectUri,  String? recordJson,  DateTime indexedAt,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.uri,_that.actor,_that.type,_that.reasonSubjectUri,_that.recordJson,_that.indexedAt,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppNotification implements AppNotification {
  const _AppNotification({required this.uri, required this.actor, required this.type, this.reasonSubjectUri, this.recordJson, required this.indexedAt, required this.isRead});
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

/// Notification AT URI (unique identifier).
@override final  String uri;
/// The user who triggered the notification.
@override final  Author actor;
/// The type of notification.
@override final  NotificationType type;
/// URI of the subject (post/profile) this notification is about.
@override final  String? reasonSubjectUri;
/// Associated record JSON (for displaying notification context).
@override final  String? recordJson;
/// When the notification was indexed on the server.
@override final  DateTime indexedAt;
/// Whether the notification has been read.
@override final  bool isRead;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.type, type) || other.type == type)&&(identical(other.reasonSubjectUri, reasonSubjectUri) || other.reasonSubjectUri == reasonSubjectUri)&&(identical(other.recordJson, recordJson) || other.recordJson == recordJson)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,actor,type,reasonSubjectUri,recordJson,indexedAt,isRead);

@override
String toString() {
  return 'AppNotification(uri: $uri, actor: $actor, type: $type, reasonSubjectUri: $reasonSubjectUri, recordJson: $recordJson, indexedAt: $indexedAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
 String uri, Author actor, NotificationType type, String? reasonSubjectUri, String? recordJson, DateTime indexedAt, bool isRead
});


@override $AuthorCopyWith<$Res> get actor;

}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? actor = null,Object? type = null,Object? reasonSubjectUri = freezed,Object? recordJson = freezed,Object? indexedAt = null,Object? isRead = null,}) {
  return _then(_AppNotification(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,actor: null == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as Author,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,reasonSubjectUri: freezed == reasonSubjectUri ? _self.reasonSubjectUri : reasonSubjectUri // ignore: cast_nullable_to_non_nullable
as String?,recordJson: freezed == recordJson ? _self.recordJson : recordJson // ignore: cast_nullable_to_non_nullable
as String?,indexedAt: null == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get actor {
  
  return $AuthorCopyWith<$Res>(_self.actor, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}

// dart format on
