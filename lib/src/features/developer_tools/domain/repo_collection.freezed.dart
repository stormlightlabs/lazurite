// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repo_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RepoCollection {

 String get nsid;
/// Create a copy of RepoCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepoCollectionCopyWith<RepoCollection> get copyWith => _$RepoCollectionCopyWithImpl<RepoCollection>(this as RepoCollection, _$identity);

  /// Serializes this RepoCollection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepoCollection&&(identical(other.nsid, nsid) || other.nsid == nsid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nsid);

@override
String toString() {
  return 'RepoCollection(nsid: $nsid)';
}


}

/// @nodoc
abstract mixin class $RepoCollectionCopyWith<$Res>  {
  factory $RepoCollectionCopyWith(RepoCollection value, $Res Function(RepoCollection) _then) = _$RepoCollectionCopyWithImpl;
@useResult
$Res call({
 String nsid
});




}
/// @nodoc
class _$RepoCollectionCopyWithImpl<$Res>
    implements $RepoCollectionCopyWith<$Res> {
  _$RepoCollectionCopyWithImpl(this._self, this._then);

  final RepoCollection _self;
  final $Res Function(RepoCollection) _then;

/// Create a copy of RepoCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nsid = null,}) {
  return _then(_self.copyWith(
nsid: null == nsid ? _self.nsid : nsid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RepoCollection].
extension RepoCollectionPatterns on RepoCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepoCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepoCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepoCollection value)  $default,){
final _that = this;
switch (_that) {
case _RepoCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepoCollection value)?  $default,){
final _that = this;
switch (_that) {
case _RepoCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nsid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepoCollection() when $default != null:
return $default(_that.nsid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nsid)  $default,) {final _that = this;
switch (_that) {
case _RepoCollection():
return $default(_that.nsid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nsid)?  $default,) {final _that = this;
switch (_that) {
case _RepoCollection() when $default != null:
return $default(_that.nsid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepoCollection implements RepoCollection {
  const _RepoCollection({required this.nsid});
  factory _RepoCollection.fromJson(Map<String, dynamic> json) => _$RepoCollectionFromJson(json);

@override final  String nsid;

/// Create a copy of RepoCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepoCollectionCopyWith<_RepoCollection> get copyWith => __$RepoCollectionCopyWithImpl<_RepoCollection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepoCollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepoCollection&&(identical(other.nsid, nsid) || other.nsid == nsid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nsid);

@override
String toString() {
  return 'RepoCollection(nsid: $nsid)';
}


}

/// @nodoc
abstract mixin class _$RepoCollectionCopyWith<$Res> implements $RepoCollectionCopyWith<$Res> {
  factory _$RepoCollectionCopyWith(_RepoCollection value, $Res Function(_RepoCollection) _then) = __$RepoCollectionCopyWithImpl;
@override @useResult
$Res call({
 String nsid
});




}
/// @nodoc
class __$RepoCollectionCopyWithImpl<$Res>
    implements _$RepoCollectionCopyWith<$Res> {
  __$RepoCollectionCopyWithImpl(this._self, this._then);

  final _RepoCollection _self;
  final $Res Function(_RepoCollection) _then;

/// Create a copy of RepoCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nsid = null,}) {
  return _then(_RepoCollection(
nsid: null == nsid ? _self.nsid : nsid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
