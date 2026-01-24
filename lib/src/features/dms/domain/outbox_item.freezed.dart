// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outbox_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutboxItem {

/// Local UUID for this outbox item.
 String get outboxId;/// Conversation to send the message to.
 String get convoId;/// Message text content.
 String get messageText;/// Current status.
 OutboxStatus get status;/// Number of send attempts.
 int get retryCount;/// When the message was queued.
 DateTime get createdAt;/// When the last send attempt was made.
 DateTime? get lastAttemptAt;/// Error message from the last failed attempt.
 String? get errorMessage;
/// Create a copy of OutboxItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboxItemCopyWith<OutboxItem> get copyWith => _$OutboxItemCopyWithImpl<OutboxItem>(this as OutboxItem, _$identity);

  /// Serializes this OutboxItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxItem&&(identical(other.outboxId, outboxId) || other.outboxId == outboxId)&&(identical(other.convoId, convoId) || other.convoId == convoId)&&(identical(other.messageText, messageText) || other.messageText == messageText)&&(identical(other.status, status) || other.status == status)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastAttemptAt, lastAttemptAt) || other.lastAttemptAt == lastAttemptAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outboxId,convoId,messageText,status,retryCount,createdAt,lastAttemptAt,errorMessage);

@override
String toString() {
  return 'OutboxItem(outboxId: $outboxId, convoId: $convoId, messageText: $messageText, status: $status, retryCount: $retryCount, createdAt: $createdAt, lastAttemptAt: $lastAttemptAt, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $OutboxItemCopyWith<$Res>  {
  factory $OutboxItemCopyWith(OutboxItem value, $Res Function(OutboxItem) _then) = _$OutboxItemCopyWithImpl;
@useResult
$Res call({
 String outboxId, String convoId, String messageText, OutboxStatus status, int retryCount, DateTime createdAt, DateTime? lastAttemptAt, String? errorMessage
});




}
/// @nodoc
class _$OutboxItemCopyWithImpl<$Res>
    implements $OutboxItemCopyWith<$Res> {
  _$OutboxItemCopyWithImpl(this._self, this._then);

  final OutboxItem _self;
  final $Res Function(OutboxItem) _then;

/// Create a copy of OutboxItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outboxId = null,Object? convoId = null,Object? messageText = null,Object? status = null,Object? retryCount = null,Object? createdAt = null,Object? lastAttemptAt = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
outboxId: null == outboxId ? _self.outboxId : outboxId // ignore: cast_nullable_to_non_nullable
as String,convoId: null == convoId ? _self.convoId : convoId // ignore: cast_nullable_to_non_nullable
as String,messageText: null == messageText ? _self.messageText : messageText // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OutboxStatus,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastAttemptAt: freezed == lastAttemptAt ? _self.lastAttemptAt : lastAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutboxItem].
extension OutboxItemPatterns on OutboxItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboxItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboxItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboxItem value)  $default,){
final _that = this;
switch (_that) {
case _OutboxItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboxItem value)?  $default,){
final _that = this;
switch (_that) {
case _OutboxItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String outboxId,  String convoId,  String messageText,  OutboxStatus status,  int retryCount,  DateTime createdAt,  DateTime? lastAttemptAt,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboxItem() when $default != null:
return $default(_that.outboxId,_that.convoId,_that.messageText,_that.status,_that.retryCount,_that.createdAt,_that.lastAttemptAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String outboxId,  String convoId,  String messageText,  OutboxStatus status,  int retryCount,  DateTime createdAt,  DateTime? lastAttemptAt,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _OutboxItem():
return $default(_that.outboxId,_that.convoId,_that.messageText,_that.status,_that.retryCount,_that.createdAt,_that.lastAttemptAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String outboxId,  String convoId,  String messageText,  OutboxStatus status,  int retryCount,  DateTime createdAt,  DateTime? lastAttemptAt,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _OutboxItem() when $default != null:
return $default(_that.outboxId,_that.convoId,_that.messageText,_that.status,_that.retryCount,_that.createdAt,_that.lastAttemptAt,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutboxItem extends OutboxItem {
  const _OutboxItem({required this.outboxId, required this.convoId, required this.messageText, required this.status, required this.retryCount, required this.createdAt, this.lastAttemptAt, this.errorMessage}): super._();
  factory _OutboxItem.fromJson(Map<String, dynamic> json) => _$OutboxItemFromJson(json);

/// Local UUID for this outbox item.
@override final  String outboxId;
/// Conversation to send the message to.
@override final  String convoId;
/// Message text content.
@override final  String messageText;
/// Current status.
@override final  OutboxStatus status;
/// Number of send attempts.
@override final  int retryCount;
/// When the message was queued.
@override final  DateTime createdAt;
/// When the last send attempt was made.
@override final  DateTime? lastAttemptAt;
/// Error message from the last failed attempt.
@override final  String? errorMessage;

/// Create a copy of OutboxItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboxItemCopyWith<_OutboxItem> get copyWith => __$OutboxItemCopyWithImpl<_OutboxItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutboxItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboxItem&&(identical(other.outboxId, outboxId) || other.outboxId == outboxId)&&(identical(other.convoId, convoId) || other.convoId == convoId)&&(identical(other.messageText, messageText) || other.messageText == messageText)&&(identical(other.status, status) || other.status == status)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastAttemptAt, lastAttemptAt) || other.lastAttemptAt == lastAttemptAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,outboxId,convoId,messageText,status,retryCount,createdAt,lastAttemptAt,errorMessage);

@override
String toString() {
  return 'OutboxItem(outboxId: $outboxId, convoId: $convoId, messageText: $messageText, status: $status, retryCount: $retryCount, createdAt: $createdAt, lastAttemptAt: $lastAttemptAt, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$OutboxItemCopyWith<$Res> implements $OutboxItemCopyWith<$Res> {
  factory _$OutboxItemCopyWith(_OutboxItem value, $Res Function(_OutboxItem) _then) = __$OutboxItemCopyWithImpl;
@override @useResult
$Res call({
 String outboxId, String convoId, String messageText, OutboxStatus status, int retryCount, DateTime createdAt, DateTime? lastAttemptAt, String? errorMessage
});




}
/// @nodoc
class __$OutboxItemCopyWithImpl<$Res>
    implements _$OutboxItemCopyWith<$Res> {
  __$OutboxItemCopyWithImpl(this._self, this._then);

  final _OutboxItem _self;
  final $Res Function(_OutboxItem) _then;

/// Create a copy of OutboxItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outboxId = null,Object? convoId = null,Object? messageText = null,Object? status = null,Object? retryCount = null,Object? createdAt = null,Object? lastAttemptAt = freezed,Object? errorMessage = freezed,}) {
  return _then(_OutboxItem(
outboxId: null == outboxId ? _self.outboxId : outboxId // ignore: cast_nullable_to_non_nullable
as String,convoId: null == convoId ? _self.convoId : convoId // ignore: cast_nullable_to_non_nullable
as String,messageText: null == messageText ? _self.messageText : messageText // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OutboxStatus,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastAttemptAt: freezed == lastAttemptAt ? _self.lastAttemptAt : lastAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
