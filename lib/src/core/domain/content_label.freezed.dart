// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_label.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContentLabel {

/// DID of the labeler that created this label.
 String get src;/// AT URI of the subject (post or profile) this label applies to.
 String get uri;/// Short name or type of the label (e.g., "porn", "spam", "scam").
 String get val;/// Timestamp when the label was created.
 DateTime get cts;/// Optional CID targeting a specific version of the subject.
@JsonKey(includeIfNull: false) String? get cid;/// If true, this label negates a previous label with the same src, uri, and val.
@JsonKey(includeIfNull: false) bool? get neg;/// Label schema version (currently always 1).
@JsonKey(includeIfNull: false) int? get ver;
/// Create a copy of ContentLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentLabelCopyWith<ContentLabel> get copyWith => _$ContentLabelCopyWithImpl<ContentLabel>(this as ContentLabel, _$identity);

  /// Serializes this ContentLabel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentLabel&&(identical(other.src, src) || other.src == src)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.val, val) || other.val == val)&&(identical(other.cts, cts) || other.cts == cts)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.neg, neg) || other.neg == neg)&&(identical(other.ver, ver) || other.ver == ver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,src,uri,val,cts,cid,neg,ver);

@override
String toString() {
  return 'ContentLabel(src: $src, uri: $uri, val: $val, cts: $cts, cid: $cid, neg: $neg, ver: $ver)';
}


}

/// @nodoc
abstract mixin class $ContentLabelCopyWith<$Res>  {
  factory $ContentLabelCopyWith(ContentLabel value, $Res Function(ContentLabel) _then) = _$ContentLabelCopyWithImpl;
@useResult
$Res call({
 String src, String uri, String val, DateTime cts,@JsonKey(includeIfNull: false) String? cid,@JsonKey(includeIfNull: false) bool? neg,@JsonKey(includeIfNull: false) int? ver
});




}
/// @nodoc
class _$ContentLabelCopyWithImpl<$Res>
    implements $ContentLabelCopyWith<$Res> {
  _$ContentLabelCopyWithImpl(this._self, this._then);

  final ContentLabel _self;
  final $Res Function(ContentLabel) _then;

/// Create a copy of ContentLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? src = null,Object? uri = null,Object? val = null,Object? cts = null,Object? cid = freezed,Object? neg = freezed,Object? ver = freezed,}) {
  return _then(_self.copyWith(
src: null == src ? _self.src : src // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,val: null == val ? _self.val : val // ignore: cast_nullable_to_non_nullable
as String,cts: null == cts ? _self.cts : cts // ignore: cast_nullable_to_non_nullable
as DateTime,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String?,neg: freezed == neg ? _self.neg : neg // ignore: cast_nullable_to_non_nullable
as bool?,ver: freezed == ver ? _self.ver : ver // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentLabel].
extension ContentLabelPatterns on ContentLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentLabel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentLabel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentLabel value)  $default,){
final _that = this;
switch (_that) {
case _ContentLabel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentLabel value)?  $default,){
final _that = this;
switch (_that) {
case _ContentLabel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String src,  String uri,  String val,  DateTime cts, @JsonKey(includeIfNull: false)  String? cid, @JsonKey(includeIfNull: false)  bool? neg, @JsonKey(includeIfNull: false)  int? ver)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentLabel() when $default != null:
return $default(_that.src,_that.uri,_that.val,_that.cts,_that.cid,_that.neg,_that.ver);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String src,  String uri,  String val,  DateTime cts, @JsonKey(includeIfNull: false)  String? cid, @JsonKey(includeIfNull: false)  bool? neg, @JsonKey(includeIfNull: false)  int? ver)  $default,) {final _that = this;
switch (_that) {
case _ContentLabel():
return $default(_that.src,_that.uri,_that.val,_that.cts,_that.cid,_that.neg,_that.ver);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String src,  String uri,  String val,  DateTime cts, @JsonKey(includeIfNull: false)  String? cid, @JsonKey(includeIfNull: false)  bool? neg, @JsonKey(includeIfNull: false)  int? ver)?  $default,) {final _that = this;
switch (_that) {
case _ContentLabel() when $default != null:
return $default(_that.src,_that.uri,_that.val,_that.cts,_that.cid,_that.neg,_that.ver);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentLabel extends ContentLabel {
  const _ContentLabel({required this.src, required this.uri, required this.val, required this.cts, @JsonKey(includeIfNull: false) this.cid, @JsonKey(includeIfNull: false) this.neg, @JsonKey(includeIfNull: false) this.ver}): super._();
  factory _ContentLabel.fromJson(Map<String, dynamic> json) => _$ContentLabelFromJson(json);

/// DID of the labeler that created this label.
@override final  String src;
/// AT URI of the subject (post or profile) this label applies to.
@override final  String uri;
/// Short name or type of the label (e.g., "porn", "spam", "scam").
@override final  String val;
/// Timestamp when the label was created.
@override final  DateTime cts;
/// Optional CID targeting a specific version of the subject.
@override@JsonKey(includeIfNull: false) final  String? cid;
/// If true, this label negates a previous label with the same src, uri, and val.
@override@JsonKey(includeIfNull: false) final  bool? neg;
/// Label schema version (currently always 1).
@override@JsonKey(includeIfNull: false) final  int? ver;

/// Create a copy of ContentLabel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentLabelCopyWith<_ContentLabel> get copyWith => __$ContentLabelCopyWithImpl<_ContentLabel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentLabelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentLabel&&(identical(other.src, src) || other.src == src)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.val, val) || other.val == val)&&(identical(other.cts, cts) || other.cts == cts)&&(identical(other.cid, cid) || other.cid == cid)&&(identical(other.neg, neg) || other.neg == neg)&&(identical(other.ver, ver) || other.ver == ver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,src,uri,val,cts,cid,neg,ver);

@override
String toString() {
  return 'ContentLabel(src: $src, uri: $uri, val: $val, cts: $cts, cid: $cid, neg: $neg, ver: $ver)';
}


}

/// @nodoc
abstract mixin class _$ContentLabelCopyWith<$Res> implements $ContentLabelCopyWith<$Res> {
  factory _$ContentLabelCopyWith(_ContentLabel value, $Res Function(_ContentLabel) _then) = __$ContentLabelCopyWithImpl;
@override @useResult
$Res call({
 String src, String uri, String val, DateTime cts,@JsonKey(includeIfNull: false) String? cid,@JsonKey(includeIfNull: false) bool? neg,@JsonKey(includeIfNull: false) int? ver
});




}
/// @nodoc
class __$ContentLabelCopyWithImpl<$Res>
    implements _$ContentLabelCopyWith<$Res> {
  __$ContentLabelCopyWithImpl(this._self, this._then);

  final _ContentLabel _self;
  final $Res Function(_ContentLabel) _then;

/// Create a copy of ContentLabel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? src = null,Object? uri = null,Object? val = null,Object? cts = null,Object? cid = freezed,Object? neg = freezed,Object? ver = freezed,}) {
  return _then(_ContentLabel(
src: null == src ? _self.src : src // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,val: null == val ? _self.val : val // ignore: cast_nullable_to_non_nullable
as String,cts: null == cts ? _self.cts : cts // ignore: cast_nullable_to_non_nullable
as DateTime,cid: freezed == cid ? _self.cid : cid // ignore: cast_nullable_to_non_nullable
as String?,neg: freezed == neg ? _self.neg : neg // ignore: cast_nullable_to_non_nullable
as bool?,ver: freezed == ver ? _self.ver : ver // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
