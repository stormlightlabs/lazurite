// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animation_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnimationPreferences {

 AnimationMode get mode; double get speedMultiplier;
/// Create a copy of AnimationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimationPreferencesCopyWith<AnimationPreferences> get copyWith => _$AnimationPreferencesCopyWithImpl<AnimationPreferences>(this as AnimationPreferences, _$identity);

  /// Serializes this AnimationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimationPreferences&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.speedMultiplier, speedMultiplier) || other.speedMultiplier == speedMultiplier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,speedMultiplier);

@override
String toString() {
  return 'AnimationPreferences(mode: $mode, speedMultiplier: $speedMultiplier)';
}


}

/// @nodoc
abstract mixin class $AnimationPreferencesCopyWith<$Res>  {
  factory $AnimationPreferencesCopyWith(AnimationPreferences value, $Res Function(AnimationPreferences) _then) = _$AnimationPreferencesCopyWithImpl;
@useResult
$Res call({
 AnimationMode mode, double speedMultiplier
});




}
/// @nodoc
class _$AnimationPreferencesCopyWithImpl<$Res>
    implements $AnimationPreferencesCopyWith<$Res> {
  _$AnimationPreferencesCopyWithImpl(this._self, this._then);

  final AnimationPreferences _self;
  final $Res Function(AnimationPreferences) _then;

/// Create a copy of AnimationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? speedMultiplier = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AnimationMode,speedMultiplier: null == speedMultiplier ? _self.speedMultiplier : speedMultiplier // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimationPreferences].
extension AnimationPreferencesPatterns on AnimationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _AnimationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _AnimationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnimationMode mode,  double speedMultiplier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimationPreferences() when $default != null:
return $default(_that.mode,_that.speedMultiplier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnimationMode mode,  double speedMultiplier)  $default,) {final _that = this;
switch (_that) {
case _AnimationPreferences():
return $default(_that.mode,_that.speedMultiplier);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnimationMode mode,  double speedMultiplier)?  $default,) {final _that = this;
switch (_that) {
case _AnimationPreferences() when $default != null:
return $default(_that.mode,_that.speedMultiplier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnimationPreferences extends AnimationPreferences {
  const _AnimationPreferences({this.mode = AnimationMode.system, this.speedMultiplier = 1.0}): super._();
  factory _AnimationPreferences.fromJson(Map<String, dynamic> json) => _$AnimationPreferencesFromJson(json);

@override@JsonKey() final  AnimationMode mode;
@override@JsonKey() final  double speedMultiplier;

/// Create a copy of AnimationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimationPreferencesCopyWith<_AnimationPreferences> get copyWith => __$AnimationPreferencesCopyWithImpl<_AnimationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnimationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimationPreferences&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.speedMultiplier, speedMultiplier) || other.speedMultiplier == speedMultiplier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,speedMultiplier);

@override
String toString() {
  return 'AnimationPreferences(mode: $mode, speedMultiplier: $speedMultiplier)';
}


}

/// @nodoc
abstract mixin class _$AnimationPreferencesCopyWith<$Res> implements $AnimationPreferencesCopyWith<$Res> {
  factory _$AnimationPreferencesCopyWith(_AnimationPreferences value, $Res Function(_AnimationPreferences) _then) = __$AnimationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 AnimationMode mode, double speedMultiplier
});




}
/// @nodoc
class __$AnimationPreferencesCopyWithImpl<$Res>
    implements _$AnimationPreferencesCopyWith<$Res> {
  __$AnimationPreferencesCopyWithImpl(this._self, this._then);

  final _AnimationPreferences _self;
  final $Res Function(_AnimationPreferences) _then;

/// Create a copy of AnimationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? speedMultiplier = null,}) {
  return _then(_AnimationPreferences(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AnimationMode,speedMultiplier: null == speedMultiplier ? _self.speedMultiplier : speedMultiplier // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
