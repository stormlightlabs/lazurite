// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grouped_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroupedNotification {

/// The notification type shared by all in this group.
 NotificationType get type;/// Actors who triggered notifications in this group.
 List<Author> get actors;/// URI of the subject (post/profile) this group is about.
 String? get subjectUri;/// Timestamp of the most recent notification in the group.
 DateTime get mostRecentTimestamp;/// Whether any notification in this group is unread.
 bool get hasUnread;/// Total number of notifications in this group.
 int get totalCount;/// All underlying notifications in this group.
 List<AppNotification> get notifications;
/// Create a copy of GroupedNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupedNotificationCopyWith<GroupedNotification> get copyWith => _$GroupedNotificationCopyWithImpl<GroupedNotification>(this as GroupedNotification, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupedNotification&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.actors, actors)&&(identical(other.subjectUri, subjectUri) || other.subjectUri == subjectUri)&&(identical(other.mostRecentTimestamp, mostRecentTimestamp) || other.mostRecentTimestamp == mostRecentTimestamp)&&(identical(other.hasUnread, hasUnread) || other.hasUnread == hasUnread)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other.notifications, notifications));
}


@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(actors),subjectUri,mostRecentTimestamp,hasUnread,totalCount,const DeepCollectionEquality().hash(notifications));

@override
String toString() {
  return 'GroupedNotification(type: $type, actors: $actors, subjectUri: $subjectUri, mostRecentTimestamp: $mostRecentTimestamp, hasUnread: $hasUnread, totalCount: $totalCount, notifications: $notifications)';
}


}

/// @nodoc
abstract mixin class $GroupedNotificationCopyWith<$Res>  {
  factory $GroupedNotificationCopyWith(GroupedNotification value, $Res Function(GroupedNotification) _then) = _$GroupedNotificationCopyWithImpl;
@useResult
$Res call({
 NotificationType type, List<Author> actors, String? subjectUri, DateTime mostRecentTimestamp, bool hasUnread, int totalCount, List<AppNotification> notifications
});




}
/// @nodoc
class _$GroupedNotificationCopyWithImpl<$Res>
    implements $GroupedNotificationCopyWith<$Res> {
  _$GroupedNotificationCopyWithImpl(this._self, this._then);

  final GroupedNotification _self;
  final $Res Function(GroupedNotification) _then;

/// Create a copy of GroupedNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? actors = null,Object? subjectUri = freezed,Object? mostRecentTimestamp = null,Object? hasUnread = null,Object? totalCount = null,Object? notifications = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,actors: null == actors ? _self.actors : actors // ignore: cast_nullable_to_non_nullable
as List<Author>,subjectUri: freezed == subjectUri ? _self.subjectUri : subjectUri // ignore: cast_nullable_to_non_nullable
as String?,mostRecentTimestamp: null == mostRecentTimestamp ? _self.mostRecentTimestamp : mostRecentTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime,hasUnread: null == hasUnread ? _self.hasUnread : hasUnread // ignore: cast_nullable_to_non_nullable
as bool,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupedNotification].
extension GroupedNotificationPatterns on GroupedNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupedNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupedNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupedNotification value)  $default,){
final _that = this;
switch (_that) {
case _GroupedNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupedNotification value)?  $default,){
final _that = this;
switch (_that) {
case _GroupedNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NotificationType type,  List<Author> actors,  String? subjectUri,  DateTime mostRecentTimestamp,  bool hasUnread,  int totalCount,  List<AppNotification> notifications)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupedNotification() when $default != null:
return $default(_that.type,_that.actors,_that.subjectUri,_that.mostRecentTimestamp,_that.hasUnread,_that.totalCount,_that.notifications);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NotificationType type,  List<Author> actors,  String? subjectUri,  DateTime mostRecentTimestamp,  bool hasUnread,  int totalCount,  List<AppNotification> notifications)  $default,) {final _that = this;
switch (_that) {
case _GroupedNotification():
return $default(_that.type,_that.actors,_that.subjectUri,_that.mostRecentTimestamp,_that.hasUnread,_that.totalCount,_that.notifications);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NotificationType type,  List<Author> actors,  String? subjectUri,  DateTime mostRecentTimestamp,  bool hasUnread,  int totalCount,  List<AppNotification> notifications)?  $default,) {final _that = this;
switch (_that) {
case _GroupedNotification() when $default != null:
return $default(_that.type,_that.actors,_that.subjectUri,_that.mostRecentTimestamp,_that.hasUnread,_that.totalCount,_that.notifications);case _:
  return null;

}
}

}

/// @nodoc


class _GroupedNotification extends GroupedNotification {
  const _GroupedNotification({required this.type, required final  List<Author> actors, this.subjectUri, required this.mostRecentTimestamp, required this.hasUnread, required this.totalCount, required final  List<AppNotification> notifications}): _actors = actors,_notifications = notifications,super._();
  

/// The notification type shared by all in this group.
@override final  NotificationType type;
/// Actors who triggered notifications in this group.
 final  List<Author> _actors;
/// Actors who triggered notifications in this group.
@override List<Author> get actors {
  if (_actors is EqualUnmodifiableListView) return _actors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actors);
}

/// URI of the subject (post/profile) this group is about.
@override final  String? subjectUri;
/// Timestamp of the most recent notification in the group.
@override final  DateTime mostRecentTimestamp;
/// Whether any notification in this group is unread.
@override final  bool hasUnread;
/// Total number of notifications in this group.
@override final  int totalCount;
/// All underlying notifications in this group.
 final  List<AppNotification> _notifications;
/// All underlying notifications in this group.
@override List<AppNotification> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}


/// Create a copy of GroupedNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupedNotificationCopyWith<_GroupedNotification> get copyWith => __$GroupedNotificationCopyWithImpl<_GroupedNotification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupedNotification&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._actors, _actors)&&(identical(other.subjectUri, subjectUri) || other.subjectUri == subjectUri)&&(identical(other.mostRecentTimestamp, mostRecentTimestamp) || other.mostRecentTimestamp == mostRecentTimestamp)&&(identical(other.hasUnread, hasUnread) || other.hasUnread == hasUnread)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other._notifications, _notifications));
}


@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_actors),subjectUri,mostRecentTimestamp,hasUnread,totalCount,const DeepCollectionEquality().hash(_notifications));

@override
String toString() {
  return 'GroupedNotification(type: $type, actors: $actors, subjectUri: $subjectUri, mostRecentTimestamp: $mostRecentTimestamp, hasUnread: $hasUnread, totalCount: $totalCount, notifications: $notifications)';
}


}

/// @nodoc
abstract mixin class _$GroupedNotificationCopyWith<$Res> implements $GroupedNotificationCopyWith<$Res> {
  factory _$GroupedNotificationCopyWith(_GroupedNotification value, $Res Function(_GroupedNotification) _then) = __$GroupedNotificationCopyWithImpl;
@override @useResult
$Res call({
 NotificationType type, List<Author> actors, String? subjectUri, DateTime mostRecentTimestamp, bool hasUnread, int totalCount, List<AppNotification> notifications
});




}
/// @nodoc
class __$GroupedNotificationCopyWithImpl<$Res>
    implements _$GroupedNotificationCopyWith<$Res> {
  __$GroupedNotificationCopyWithImpl(this._self, this._then);

  final _GroupedNotification _self;
  final $Res Function(_GroupedNotification) _then;

/// Create a copy of GroupedNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? actors = null,Object? subjectUri = freezed,Object? mostRecentTimestamp = null,Object? hasUnread = null,Object? totalCount = null,Object? notifications = null,}) {
  return _then(_GroupedNotification(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,actors: null == actors ? _self._actors : actors // ignore: cast_nullable_to_non_nullable
as List<Author>,subjectUri: freezed == subjectUri ? _self.subjectUri : subjectUri // ignore: cast_nullable_to_non_nullable
as String?,mostRecentTimestamp: null == mostRecentTimestamp ? _self.mostRecentTimestamp : mostRecentTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime,hasUnread: null == hasUnread ? _self.hasUnread : hasUnread // ignore: cast_nullable_to_non_nullable
as bool,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,
  ));
}


}

// dart format on
