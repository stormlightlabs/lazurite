// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_embed_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DraftEmbedPayload {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftEmbedPayload);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DraftEmbedPayload()';
}


}

/// @nodoc
class $DraftEmbedPayloadCopyWith<$Res>  {
$DraftEmbedPayloadCopyWith(DraftEmbedPayload _, $Res Function(DraftEmbedPayload) __);
}


/// Adds pattern-matching-related methods to [DraftEmbedPayload].
extension DraftEmbedPayloadPatterns on DraftEmbedPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DraftImagesEmbedPayload value)?  images,TResult Function( DraftVideoEmbedPayload value)?  video,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DraftImagesEmbedPayload() when images != null:
return images(_that);case DraftVideoEmbedPayload() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DraftImagesEmbedPayload value)  images,required TResult Function( DraftVideoEmbedPayload value)  video,}){
final _that = this;
switch (_that) {
case DraftImagesEmbedPayload():
return images(_that);case DraftVideoEmbedPayload():
return video(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DraftImagesEmbedPayload value)?  images,TResult? Function( DraftVideoEmbedPayload value)?  video,}){
final _that = this;
switch (_that) {
case DraftImagesEmbedPayload() when images != null:
return images(_that);case DraftVideoEmbedPayload() when video != null:
return video(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<String> paths,  List<String> altTexts)?  images,TResult Function( String path,  String alt)?  video,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DraftImagesEmbedPayload() when images != null:
return images(_that.paths,_that.altTexts);case DraftVideoEmbedPayload() when video != null:
return video(_that.path,_that.alt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<String> paths,  List<String> altTexts)  images,required TResult Function( String path,  String alt)  video,}) {final _that = this;
switch (_that) {
case DraftImagesEmbedPayload():
return images(_that.paths,_that.altTexts);case DraftVideoEmbedPayload():
return video(_that.path,_that.alt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<String> paths,  List<String> altTexts)?  images,TResult? Function( String path,  String alt)?  video,}) {final _that = this;
switch (_that) {
case DraftImagesEmbedPayload() when images != null:
return images(_that.paths,_that.altTexts);case DraftVideoEmbedPayload() when video != null:
return video(_that.path,_that.alt);case _:
  return null;

}
}

}

/// @nodoc


class DraftImagesEmbedPayload extends DraftEmbedPayload {
  const DraftImagesEmbedPayload({final  List<String> paths = const <String>[], final  List<String> altTexts = const <String>[]}): _paths = paths,_altTexts = altTexts,super._();
  

 final  List<String> _paths;
@JsonKey() List<String> get paths {
  if (_paths is EqualUnmodifiableListView) return _paths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paths);
}

 final  List<String> _altTexts;
@JsonKey() List<String> get altTexts {
  if (_altTexts is EqualUnmodifiableListView) return _altTexts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_altTexts);
}


/// Create a copy of DraftEmbedPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftImagesEmbedPayloadCopyWith<DraftImagesEmbedPayload> get copyWith => _$DraftImagesEmbedPayloadCopyWithImpl<DraftImagesEmbedPayload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftImagesEmbedPayload&&const DeepCollectionEquality().equals(other._paths, _paths)&&const DeepCollectionEquality().equals(other._altTexts, _altTexts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_paths),const DeepCollectionEquality().hash(_altTexts));

@override
String toString() {
  return 'DraftEmbedPayload.images(paths: $paths, altTexts: $altTexts)';
}


}

/// @nodoc
abstract mixin class $DraftImagesEmbedPayloadCopyWith<$Res> implements $DraftEmbedPayloadCopyWith<$Res> {
  factory $DraftImagesEmbedPayloadCopyWith(DraftImagesEmbedPayload value, $Res Function(DraftImagesEmbedPayload) _then) = _$DraftImagesEmbedPayloadCopyWithImpl;
@useResult
$Res call({
 List<String> paths, List<String> altTexts
});




}
/// @nodoc
class _$DraftImagesEmbedPayloadCopyWithImpl<$Res>
    implements $DraftImagesEmbedPayloadCopyWith<$Res> {
  _$DraftImagesEmbedPayloadCopyWithImpl(this._self, this._then);

  final DraftImagesEmbedPayload _self;
  final $Res Function(DraftImagesEmbedPayload) _then;

/// Create a copy of DraftEmbedPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? paths = null,Object? altTexts = null,}) {
  return _then(DraftImagesEmbedPayload(
paths: null == paths ? _self._paths : paths // ignore: cast_nullable_to_non_nullable
as List<String>,altTexts: null == altTexts ? _self._altTexts : altTexts // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class DraftVideoEmbedPayload extends DraftEmbedPayload {
  const DraftVideoEmbedPayload({required this.path, this.alt = ''}): super._();
  

 final  String path;
@JsonKey() final  String alt;

/// Create a copy of DraftEmbedPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftVideoEmbedPayloadCopyWith<DraftVideoEmbedPayload> get copyWith => _$DraftVideoEmbedPayloadCopyWithImpl<DraftVideoEmbedPayload>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftVideoEmbedPayload&&(identical(other.path, path) || other.path == path)&&(identical(other.alt, alt) || other.alt == alt));
}


@override
int get hashCode => Object.hash(runtimeType,path,alt);

@override
String toString() {
  return 'DraftEmbedPayload.video(path: $path, alt: $alt)';
}


}

/// @nodoc
abstract mixin class $DraftVideoEmbedPayloadCopyWith<$Res> implements $DraftEmbedPayloadCopyWith<$Res> {
  factory $DraftVideoEmbedPayloadCopyWith(DraftVideoEmbedPayload value, $Res Function(DraftVideoEmbedPayload) _then) = _$DraftVideoEmbedPayloadCopyWithImpl;
@useResult
$Res call({
 String path, String alt
});




}
/// @nodoc
class _$DraftVideoEmbedPayloadCopyWithImpl<$Res>
    implements $DraftVideoEmbedPayloadCopyWith<$Res> {
  _$DraftVideoEmbedPayloadCopyWithImpl(this._self, this._then);

  final DraftVideoEmbedPayload _self;
  final $Res Function(DraftVideoEmbedPayload) _then;

/// Create a copy of DraftEmbedPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,Object? alt = null,}) {
  return _then(DraftVideoEmbedPayload(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,alt: null == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
