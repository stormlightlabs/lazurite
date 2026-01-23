// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dm_conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DmConversation {

/// Conversation ID (unique identifier from API).
 String get convoId;/// Participant profiles in this conversation.
 List<Author> get members;/// Preview text from the last message.
 String? get lastMessageText;/// Timestamp of the last message.
 DateTime? get lastMessageAt;/// ID of the last message the user has read.
 String? get lastReadMessageId;/// Number of unread messages.
 int get unreadCount;/// Whether the conversation is muted.
 bool get isMuted;/// Whether the conversation request has been accepted.
 bool get isAccepted;
/// Create a copy of DmConversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DmConversationCopyWith<DmConversation> get copyWith => _$DmConversationCopyWithImpl<DmConversation>(this as DmConversation, _$identity);

  /// Serializes this DmConversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DmConversation&&(identical(other.convoId, convoId) || other.convoId == convoId)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastReadMessageId, lastReadMessageId) || other.lastReadMessageId == lastReadMessageId)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isAccepted, isAccepted) || other.isAccepted == isAccepted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,convoId,const DeepCollectionEquality().hash(members),lastMessageText,lastMessageAt,lastReadMessageId,unreadCount,isMuted,isAccepted);

@override
String toString() {
  return 'DmConversation(convoId: $convoId, members: $members, lastMessageText: $lastMessageText, lastMessageAt: $lastMessageAt, lastReadMessageId: $lastReadMessageId, unreadCount: $unreadCount, isMuted: $isMuted, isAccepted: $isAccepted)';
}


}

/// @nodoc
abstract mixin class $DmConversationCopyWith<$Res>  {
  factory $DmConversationCopyWith(DmConversation value, $Res Function(DmConversation) _then) = _$DmConversationCopyWithImpl;
@useResult
$Res call({
 String convoId, List<Author> members, String? lastMessageText, DateTime? lastMessageAt, String? lastReadMessageId, int unreadCount, bool isMuted, bool isAccepted
});




}
/// @nodoc
class _$DmConversationCopyWithImpl<$Res>
    implements $DmConversationCopyWith<$Res> {
  _$DmConversationCopyWithImpl(this._self, this._then);

  final DmConversation _self;
  final $Res Function(DmConversation) _then;

/// Create a copy of DmConversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? convoId = null,Object? members = null,Object? lastMessageText = freezed,Object? lastMessageAt = freezed,Object? lastReadMessageId = freezed,Object? unreadCount = null,Object? isMuted = null,Object? isAccepted = null,}) {
  return _then(_self.copyWith(
convoId: null == convoId ? _self.convoId : convoId // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<Author>,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadMessageId: freezed == lastReadMessageId ? _self.lastReadMessageId : lastReadMessageId // ignore: cast_nullable_to_non_nullable
as String?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isAccepted: null == isAccepted ? _self.isAccepted : isAccepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DmConversation].
extension DmConversationPatterns on DmConversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DmConversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DmConversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DmConversation value)  $default,){
final _that = this;
switch (_that) {
case _DmConversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DmConversation value)?  $default,){
final _that = this;
switch (_that) {
case _DmConversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String convoId,  List<Author> members,  String? lastMessageText,  DateTime? lastMessageAt,  String? lastReadMessageId,  int unreadCount,  bool isMuted,  bool isAccepted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DmConversation() when $default != null:
return $default(_that.convoId,_that.members,_that.lastMessageText,_that.lastMessageAt,_that.lastReadMessageId,_that.unreadCount,_that.isMuted,_that.isAccepted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String convoId,  List<Author> members,  String? lastMessageText,  DateTime? lastMessageAt,  String? lastReadMessageId,  int unreadCount,  bool isMuted,  bool isAccepted)  $default,) {final _that = this;
switch (_that) {
case _DmConversation():
return $default(_that.convoId,_that.members,_that.lastMessageText,_that.lastMessageAt,_that.lastReadMessageId,_that.unreadCount,_that.isMuted,_that.isAccepted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String convoId,  List<Author> members,  String? lastMessageText,  DateTime? lastMessageAt,  String? lastReadMessageId,  int unreadCount,  bool isMuted,  bool isAccepted)?  $default,) {final _that = this;
switch (_that) {
case _DmConversation() when $default != null:
return $default(_that.convoId,_that.members,_that.lastMessageText,_that.lastMessageAt,_that.lastReadMessageId,_that.unreadCount,_that.isMuted,_that.isAccepted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DmConversation extends DmConversation {
  const _DmConversation({required this.convoId, required final  List<Author> members, this.lastMessageText, this.lastMessageAt, this.lastReadMessageId, required this.unreadCount, required this.isMuted, required this.isAccepted}): _members = members,super._();
  factory _DmConversation.fromJson(Map<String, dynamic> json) => _$DmConversationFromJson(json);

/// Conversation ID (unique identifier from API).
@override final  String convoId;
/// Participant profiles in this conversation.
 final  List<Author> _members;
/// Participant profiles in this conversation.
@override List<Author> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

/// Preview text from the last message.
@override final  String? lastMessageText;
/// Timestamp of the last message.
@override final  DateTime? lastMessageAt;
/// ID of the last message the user has read.
@override final  String? lastReadMessageId;
/// Number of unread messages.
@override final  int unreadCount;
/// Whether the conversation is muted.
@override final  bool isMuted;
/// Whether the conversation request has been accepted.
@override final  bool isAccepted;

/// Create a copy of DmConversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DmConversationCopyWith<_DmConversation> get copyWith => __$DmConversationCopyWithImpl<_DmConversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DmConversationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DmConversation&&(identical(other.convoId, convoId) || other.convoId == convoId)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastReadMessageId, lastReadMessageId) || other.lastReadMessageId == lastReadMessageId)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isAccepted, isAccepted) || other.isAccepted == isAccepted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,convoId,const DeepCollectionEquality().hash(_members),lastMessageText,lastMessageAt,lastReadMessageId,unreadCount,isMuted,isAccepted);

@override
String toString() {
  return 'DmConversation(convoId: $convoId, members: $members, lastMessageText: $lastMessageText, lastMessageAt: $lastMessageAt, lastReadMessageId: $lastReadMessageId, unreadCount: $unreadCount, isMuted: $isMuted, isAccepted: $isAccepted)';
}


}

/// @nodoc
abstract mixin class _$DmConversationCopyWith<$Res> implements $DmConversationCopyWith<$Res> {
  factory _$DmConversationCopyWith(_DmConversation value, $Res Function(_DmConversation) _then) = __$DmConversationCopyWithImpl;
@override @useResult
$Res call({
 String convoId, List<Author> members, String? lastMessageText, DateTime? lastMessageAt, String? lastReadMessageId, int unreadCount, bool isMuted, bool isAccepted
});




}
/// @nodoc
class __$DmConversationCopyWithImpl<$Res>
    implements _$DmConversationCopyWith<$Res> {
  __$DmConversationCopyWithImpl(this._self, this._then);

  final _DmConversation _self;
  final $Res Function(_DmConversation) _then;

/// Create a copy of DmConversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? convoId = null,Object? members = null,Object? lastMessageText = freezed,Object? lastMessageAt = freezed,Object? lastReadMessageId = freezed,Object? unreadCount = null,Object? isMuted = null,Object? isAccepted = null,}) {
  return _then(_DmConversation(
convoId: null == convoId ? _self.convoId : convoId // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<Author>,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadMessageId: freezed == lastReadMessageId ? _self.lastReadMessageId : lastReadMessageId // ignore: cast_nullable_to_non_nullable
as String?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isAccepted: null == isAccepted ? _self.isAccepted : isAccepted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
