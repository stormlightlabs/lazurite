// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dm_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppDmMessage {

/// Message ID (unique identifier from API or local UUID for pending).
 String get messageId;/// Conversation this message belongs to.
 String get convoId;/// The message sender's profile.
 Author get sender;/// Message text content.
 String get content;/// When the message was sent.
 DateTime get sentAt;/// Current delivery status.
 MessageStatus get status;
/// Create a copy of AppDmMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppDmMessageCopyWith<AppDmMessage> get copyWith => _$AppDmMessageCopyWithImpl<AppDmMessage>(this as AppDmMessage, _$identity);

  /// Serializes this AppDmMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppDmMessage&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.convoId, convoId) || other.convoId == convoId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,convoId,sender,content,sentAt,status);

@override
String toString() {
  return 'AppDmMessage(messageId: $messageId, convoId: $convoId, sender: $sender, content: $content, sentAt: $sentAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $AppDmMessageCopyWith<$Res>  {
  factory $AppDmMessageCopyWith(AppDmMessage value, $Res Function(AppDmMessage) _then) = _$AppDmMessageCopyWithImpl;
@useResult
$Res call({
 String messageId, String convoId, Author sender, String content, DateTime sentAt, MessageStatus status
});


$AuthorCopyWith<$Res> get sender;

}
/// @nodoc
class _$AppDmMessageCopyWithImpl<$Res>
    implements $AppDmMessageCopyWith<$Res> {
  _$AppDmMessageCopyWithImpl(this._self, this._then);

  final AppDmMessage _self;
  final $Res Function(AppDmMessage) _then;

/// Create a copy of AppDmMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageId = null,Object? convoId = null,Object? sender = null,Object? content = null,Object? sentAt = null,Object? status = null,}) {
  return _then(_self.copyWith(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,convoId: null == convoId ? _self.convoId : convoId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,
  ));
}
/// Create a copy of AppDmMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get sender {
  
  return $AuthorCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppDmMessage].
extension AppDmMessagePatterns on AppDmMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppDmMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppDmMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppDmMessage value)  $default,){
final _that = this;
switch (_that) {
case _AppDmMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppDmMessage value)?  $default,){
final _that = this;
switch (_that) {
case _AppDmMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String messageId,  String convoId,  Author sender,  String content,  DateTime sentAt,  MessageStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppDmMessage() when $default != null:
return $default(_that.messageId,_that.convoId,_that.sender,_that.content,_that.sentAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String messageId,  String convoId,  Author sender,  String content,  DateTime sentAt,  MessageStatus status)  $default,) {final _that = this;
switch (_that) {
case _AppDmMessage():
return $default(_that.messageId,_that.convoId,_that.sender,_that.content,_that.sentAt,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String messageId,  String convoId,  Author sender,  String content,  DateTime sentAt,  MessageStatus status)?  $default,) {final _that = this;
switch (_that) {
case _AppDmMessage() when $default != null:
return $default(_that.messageId,_that.convoId,_that.sender,_that.content,_that.sentAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppDmMessage extends AppDmMessage {
  const _AppDmMessage({required this.messageId, required this.convoId, required this.sender, required this.content, required this.sentAt, required this.status}): super._();
  factory _AppDmMessage.fromJson(Map<String, dynamic> json) => _$AppDmMessageFromJson(json);

/// Message ID (unique identifier from API or local UUID for pending).
@override final  String messageId;
/// Conversation this message belongs to.
@override final  String convoId;
/// The message sender's profile.
@override final  Author sender;
/// Message text content.
@override final  String content;
/// When the message was sent.
@override final  DateTime sentAt;
/// Current delivery status.
@override final  MessageStatus status;

/// Create a copy of AppDmMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppDmMessageCopyWith<_AppDmMessage> get copyWith => __$AppDmMessageCopyWithImpl<_AppDmMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppDmMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppDmMessage&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.convoId, convoId) || other.convoId == convoId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageId,convoId,sender,content,sentAt,status);

@override
String toString() {
  return 'AppDmMessage(messageId: $messageId, convoId: $convoId, sender: $sender, content: $content, sentAt: $sentAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AppDmMessageCopyWith<$Res> implements $AppDmMessageCopyWith<$Res> {
  factory _$AppDmMessageCopyWith(_AppDmMessage value, $Res Function(_AppDmMessage) _then) = __$AppDmMessageCopyWithImpl;
@override @useResult
$Res call({
 String messageId, String convoId, Author sender, String content, DateTime sentAt, MessageStatus status
});


@override $AuthorCopyWith<$Res> get sender;

}
/// @nodoc
class __$AppDmMessageCopyWithImpl<$Res>
    implements _$AppDmMessageCopyWith<$Res> {
  __$AppDmMessageCopyWithImpl(this._self, this._then);

  final _AppDmMessage _self;
  final $Res Function(_AppDmMessage) _then;

/// Create a copy of AppDmMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? convoId = null,Object? sender = null,Object? content = null,Object? sentAt = null,Object? status = null,}) {
  return _then(_AppDmMessage(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,convoId: null == convoId ? _self.convoId : convoId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,
  ));
}

/// Create a copy of AppDmMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get sender {
  
  return $AuthorCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}

// dart format on
