// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Schedule {

/// ID of the draft to be published.
 String get draftId;/// The DID of the user who owns this scheduled post.
 String get ownerDid;/// When the post should be published (UTC).
 DateTime get scheduledAtUtc;/// Current state of the scheduled post.
 ScheduleStatus get status;/// When this schedule record was created.
 DateTime get createdAt;/// When this schedule was last modified.
 DateTime get updatedAt;/// Number of publish attempts made.
 int get attempts;/// Error message from the last failed attempt (if any).
 String? get lastError;/// AT URI of the successfully posted post (null until published).
 String? get postedUri;/// CID of the successfully posted post (null until published).
 String? get postedCid;
/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleCopyWith<Schedule> get copyWith => _$ScheduleCopyWithImpl<Schedule>(this as Schedule, _$identity);

  /// Serializes this Schedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Schedule&&(identical(other.draftId, draftId) || other.draftId == draftId)&&(identical(other.ownerDid, ownerDid) || other.ownerDid == ownerDid)&&(identical(other.scheduledAtUtc, scheduledAtUtc) || other.scheduledAtUtc == scheduledAtUtc)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.postedUri, postedUri) || other.postedUri == postedUri)&&(identical(other.postedCid, postedCid) || other.postedCid == postedCid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,draftId,ownerDid,scheduledAtUtc,status,createdAt,updatedAt,attempts,lastError,postedUri,postedCid);

@override
String toString() {
  return 'Schedule(draftId: $draftId, ownerDid: $ownerDid, scheduledAtUtc: $scheduledAtUtc, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, attempts: $attempts, lastError: $lastError, postedUri: $postedUri, postedCid: $postedCid)';
}


}

/// @nodoc
abstract mixin class $ScheduleCopyWith<$Res>  {
  factory $ScheduleCopyWith(Schedule value, $Res Function(Schedule) _then) = _$ScheduleCopyWithImpl;
@useResult
$Res call({
 String draftId, String ownerDid, DateTime scheduledAtUtc, ScheduleStatus status, DateTime createdAt, DateTime updatedAt, int attempts, String? lastError, String? postedUri, String? postedCid
});




}
/// @nodoc
class _$ScheduleCopyWithImpl<$Res>
    implements $ScheduleCopyWith<$Res> {
  _$ScheduleCopyWithImpl(this._self, this._then);

  final Schedule _self;
  final $Res Function(Schedule) _then;

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? draftId = null,Object? ownerDid = null,Object? scheduledAtUtc = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? attempts = null,Object? lastError = freezed,Object? postedUri = freezed,Object? postedCid = freezed,}) {
  return _then(_self.copyWith(
draftId: null == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as String,ownerDid: null == ownerDid ? _self.ownerDid : ownerDid // ignore: cast_nullable_to_non_nullable
as String,scheduledAtUtc: null == scheduledAtUtc ? _self.scheduledAtUtc : scheduledAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScheduleStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,postedUri: freezed == postedUri ? _self.postedUri : postedUri // ignore: cast_nullable_to_non_nullable
as String?,postedCid: freezed == postedCid ? _self.postedCid : postedCid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Schedule].
extension SchedulePatterns on Schedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Schedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Schedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Schedule value)  $default,){
final _that = this;
switch (_that) {
case _Schedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Schedule value)?  $default,){
final _that = this;
switch (_that) {
case _Schedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String draftId,  String ownerDid,  DateTime scheduledAtUtc,  ScheduleStatus status,  DateTime createdAt,  DateTime updatedAt,  int attempts,  String? lastError,  String? postedUri,  String? postedCid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Schedule() when $default != null:
return $default(_that.draftId,_that.ownerDid,_that.scheduledAtUtc,_that.status,_that.createdAt,_that.updatedAt,_that.attempts,_that.lastError,_that.postedUri,_that.postedCid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String draftId,  String ownerDid,  DateTime scheduledAtUtc,  ScheduleStatus status,  DateTime createdAt,  DateTime updatedAt,  int attempts,  String? lastError,  String? postedUri,  String? postedCid)  $default,) {final _that = this;
switch (_that) {
case _Schedule():
return $default(_that.draftId,_that.ownerDid,_that.scheduledAtUtc,_that.status,_that.createdAt,_that.updatedAt,_that.attempts,_that.lastError,_that.postedUri,_that.postedCid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String draftId,  String ownerDid,  DateTime scheduledAtUtc,  ScheduleStatus status,  DateTime createdAt,  DateTime updatedAt,  int attempts,  String? lastError,  String? postedUri,  String? postedCid)?  $default,) {final _that = this;
switch (_that) {
case _Schedule() when $default != null:
return $default(_that.draftId,_that.ownerDid,_that.scheduledAtUtc,_that.status,_that.createdAt,_that.updatedAt,_that.attempts,_that.lastError,_that.postedUri,_that.postedCid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Schedule extends Schedule {
  const _Schedule({required this.draftId, required this.ownerDid, required this.scheduledAtUtc, required this.status, required this.createdAt, required this.updatedAt, this.attempts = 0, this.lastError, this.postedUri, this.postedCid}): super._();
  factory _Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

/// ID of the draft to be published.
@override final  String draftId;
/// The DID of the user who owns this scheduled post.
@override final  String ownerDid;
/// When the post should be published (UTC).
@override final  DateTime scheduledAtUtc;
/// Current state of the scheduled post.
@override final  ScheduleStatus status;
/// When this schedule record was created.
@override final  DateTime createdAt;
/// When this schedule was last modified.
@override final  DateTime updatedAt;
/// Number of publish attempts made.
@override@JsonKey() final  int attempts;
/// Error message from the last failed attempt (if any).
@override final  String? lastError;
/// AT URI of the successfully posted post (null until published).
@override final  String? postedUri;
/// CID of the successfully posted post (null until published).
@override final  String? postedCid;

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleCopyWith<_Schedule> get copyWith => __$ScheduleCopyWithImpl<_Schedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Schedule&&(identical(other.draftId, draftId) || other.draftId == draftId)&&(identical(other.ownerDid, ownerDid) || other.ownerDid == ownerDid)&&(identical(other.scheduledAtUtc, scheduledAtUtc) || other.scheduledAtUtc == scheduledAtUtc)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.postedUri, postedUri) || other.postedUri == postedUri)&&(identical(other.postedCid, postedCid) || other.postedCid == postedCid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,draftId,ownerDid,scheduledAtUtc,status,createdAt,updatedAt,attempts,lastError,postedUri,postedCid);

@override
String toString() {
  return 'Schedule(draftId: $draftId, ownerDid: $ownerDid, scheduledAtUtc: $scheduledAtUtc, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, attempts: $attempts, lastError: $lastError, postedUri: $postedUri, postedCid: $postedCid)';
}


}

/// @nodoc
abstract mixin class _$ScheduleCopyWith<$Res> implements $ScheduleCopyWith<$Res> {
  factory _$ScheduleCopyWith(_Schedule value, $Res Function(_Schedule) _then) = __$ScheduleCopyWithImpl;
@override @useResult
$Res call({
 String draftId, String ownerDid, DateTime scheduledAtUtc, ScheduleStatus status, DateTime createdAt, DateTime updatedAt, int attempts, String? lastError, String? postedUri, String? postedCid
});




}
/// @nodoc
class __$ScheduleCopyWithImpl<$Res>
    implements _$ScheduleCopyWith<$Res> {
  __$ScheduleCopyWithImpl(this._self, this._then);

  final _Schedule _self;
  final $Res Function(_Schedule) _then;

/// Create a copy of Schedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? draftId = null,Object? ownerDid = null,Object? scheduledAtUtc = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? attempts = null,Object? lastError = freezed,Object? postedUri = freezed,Object? postedCid = freezed,}) {
  return _then(_Schedule(
draftId: null == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as String,ownerDid: null == ownerDid ? _self.ownerDid : ownerDid // ignore: cast_nullable_to_non_nullable
as String,scheduledAtUtc: null == scheduledAtUtc ? _self.scheduledAtUtc : scheduledAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScheduleStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,postedUri: freezed == postedUri ? _self.postedUri : postedUri // ignore: cast_nullable_to_non_nullable
as String?,postedCid: freezed == postedCid ? _self.postedCid : postedCid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
