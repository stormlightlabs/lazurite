// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'klipy_gif.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KlipyMediaFormat {

 String get url; int get width; int get height; int? get size;
/// Create a copy of KlipyMediaFormat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<KlipyMediaFormat> get copyWith => _$KlipyMediaFormatCopyWithImpl<KlipyMediaFormat>(this as KlipyMediaFormat, _$identity);

  /// Serializes this KlipyMediaFormat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KlipyMediaFormat&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height,size);

@override
String toString() {
  return 'KlipyMediaFormat(url: $url, width: $width, height: $height, size: $size)';
}


}

/// @nodoc
abstract mixin class $KlipyMediaFormatCopyWith<$Res>  {
  factory $KlipyMediaFormatCopyWith(KlipyMediaFormat value, $Res Function(KlipyMediaFormat) _then) = _$KlipyMediaFormatCopyWithImpl;
@useResult
$Res call({
 String url, int width, int height, int? size
});




}
/// @nodoc
class _$KlipyMediaFormatCopyWithImpl<$Res>
    implements $KlipyMediaFormatCopyWith<$Res> {
  _$KlipyMediaFormatCopyWithImpl(this._self, this._then);

  final KlipyMediaFormat _self;
  final $Res Function(KlipyMediaFormat) _then;

/// Create a copy of KlipyMediaFormat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? width = null,Object? height = null,Object? size = freezed,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [KlipyMediaFormat].
extension KlipyMediaFormatPatterns on KlipyMediaFormat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KlipyMediaFormat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KlipyMediaFormat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KlipyMediaFormat value)  $default,){
final _that = this;
switch (_that) {
case _KlipyMediaFormat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KlipyMediaFormat value)?  $default,){
final _that = this;
switch (_that) {
case _KlipyMediaFormat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  int width,  int height,  int? size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KlipyMediaFormat() when $default != null:
return $default(_that.url,_that.width,_that.height,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  int width,  int height,  int? size)  $default,) {final _that = this;
switch (_that) {
case _KlipyMediaFormat():
return $default(_that.url,_that.width,_that.height,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  int width,  int height,  int? size)?  $default,) {final _that = this;
switch (_that) {
case _KlipyMediaFormat() when $default != null:
return $default(_that.url,_that.width,_that.height,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KlipyMediaFormat implements KlipyMediaFormat {
  const _KlipyMediaFormat({this.url = '', this.width = 0, this.height = 0, this.size});
  factory _KlipyMediaFormat.fromJson(Map<String, dynamic> json) => _$KlipyMediaFormatFromJson(json);

@override@JsonKey() final  String url;
@override@JsonKey() final  int width;
@override@JsonKey() final  int height;
@override final  int? size;

/// Create a copy of KlipyMediaFormat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KlipyMediaFormatCopyWith<_KlipyMediaFormat> get copyWith => __$KlipyMediaFormatCopyWithImpl<_KlipyMediaFormat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KlipyMediaFormatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KlipyMediaFormat&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,width,height,size);

@override
String toString() {
  return 'KlipyMediaFormat(url: $url, width: $width, height: $height, size: $size)';
}


}

/// @nodoc
abstract mixin class _$KlipyMediaFormatCopyWith<$Res> implements $KlipyMediaFormatCopyWith<$Res> {
  factory _$KlipyMediaFormatCopyWith(_KlipyMediaFormat value, $Res Function(_KlipyMediaFormat) _then) = __$KlipyMediaFormatCopyWithImpl;
@override @useResult
$Res call({
 String url, int width, int height, int? size
});




}
/// @nodoc
class __$KlipyMediaFormatCopyWithImpl<$Res>
    implements _$KlipyMediaFormatCopyWith<$Res> {
  __$KlipyMediaFormatCopyWithImpl(this._self, this._then);

  final _KlipyMediaFormat _self;
  final $Res Function(_KlipyMediaFormat) _then;

/// Create a copy of KlipyMediaFormat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? width = null,Object? height = null,Object? size = freezed,}) {
  return _then(_KlipyMediaFormat(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$KlipyFormatVariants {

 KlipyMediaFormat? get gif; KlipyMediaFormat? get webp; KlipyMediaFormat? get jpg; KlipyMediaFormat? get mp4; KlipyMediaFormat? get webm;
/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KlipyFormatVariantsCopyWith<KlipyFormatVariants> get copyWith => _$KlipyFormatVariantsCopyWithImpl<KlipyFormatVariants>(this as KlipyFormatVariants, _$identity);

  /// Serializes this KlipyFormatVariants to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KlipyFormatVariants&&(identical(other.gif, gif) || other.gif == gif)&&(identical(other.webp, webp) || other.webp == webp)&&(identical(other.jpg, jpg) || other.jpg == jpg)&&(identical(other.mp4, mp4) || other.mp4 == mp4)&&(identical(other.webm, webm) || other.webm == webm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gif,webp,jpg,mp4,webm);

@override
String toString() {
  return 'KlipyFormatVariants(gif: $gif, webp: $webp, jpg: $jpg, mp4: $mp4, webm: $webm)';
}


}

/// @nodoc
abstract mixin class $KlipyFormatVariantsCopyWith<$Res>  {
  factory $KlipyFormatVariantsCopyWith(KlipyFormatVariants value, $Res Function(KlipyFormatVariants) _then) = _$KlipyFormatVariantsCopyWithImpl;
@useResult
$Res call({
 KlipyMediaFormat? gif, KlipyMediaFormat? webp, KlipyMediaFormat? jpg, KlipyMediaFormat? mp4, KlipyMediaFormat? webm
});


$KlipyMediaFormatCopyWith<$Res>? get gif;$KlipyMediaFormatCopyWith<$Res>? get webp;$KlipyMediaFormatCopyWith<$Res>? get jpg;$KlipyMediaFormatCopyWith<$Res>? get mp4;$KlipyMediaFormatCopyWith<$Res>? get webm;

}
/// @nodoc
class _$KlipyFormatVariantsCopyWithImpl<$Res>
    implements $KlipyFormatVariantsCopyWith<$Res> {
  _$KlipyFormatVariantsCopyWithImpl(this._self, this._then);

  final KlipyFormatVariants _self;
  final $Res Function(KlipyFormatVariants) _then;

/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gif = freezed,Object? webp = freezed,Object? jpg = freezed,Object? mp4 = freezed,Object? webm = freezed,}) {
  return _then(_self.copyWith(
gif: freezed == gif ? _self.gif : gif // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,webp: freezed == webp ? _self.webp : webp // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,jpg: freezed == jpg ? _self.jpg : jpg // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,mp4: freezed == mp4 ? _self.mp4 : mp4 // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,webm: freezed == webm ? _self.webm : webm // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,
  ));
}
/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get gif {
    if (_self.gif == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.gif!, (value) {
    return _then(_self.copyWith(gif: value));
  });
}/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get webp {
    if (_self.webp == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.webp!, (value) {
    return _then(_self.copyWith(webp: value));
  });
}/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get jpg {
    if (_self.jpg == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.jpg!, (value) {
    return _then(_self.copyWith(jpg: value));
  });
}/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get mp4 {
    if (_self.mp4 == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.mp4!, (value) {
    return _then(_self.copyWith(mp4: value));
  });
}/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get webm {
    if (_self.webm == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.webm!, (value) {
    return _then(_self.copyWith(webm: value));
  });
}
}


/// Adds pattern-matching-related methods to [KlipyFormatVariants].
extension KlipyFormatVariantsPatterns on KlipyFormatVariants {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KlipyFormatVariants value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KlipyFormatVariants() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KlipyFormatVariants value)  $default,){
final _that = this;
switch (_that) {
case _KlipyFormatVariants():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KlipyFormatVariants value)?  $default,){
final _that = this;
switch (_that) {
case _KlipyFormatVariants() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( KlipyMediaFormat? gif,  KlipyMediaFormat? webp,  KlipyMediaFormat? jpg,  KlipyMediaFormat? mp4,  KlipyMediaFormat? webm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KlipyFormatVariants() when $default != null:
return $default(_that.gif,_that.webp,_that.jpg,_that.mp4,_that.webm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( KlipyMediaFormat? gif,  KlipyMediaFormat? webp,  KlipyMediaFormat? jpg,  KlipyMediaFormat? mp4,  KlipyMediaFormat? webm)  $default,) {final _that = this;
switch (_that) {
case _KlipyFormatVariants():
return $default(_that.gif,_that.webp,_that.jpg,_that.mp4,_that.webm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( KlipyMediaFormat? gif,  KlipyMediaFormat? webp,  KlipyMediaFormat? jpg,  KlipyMediaFormat? mp4,  KlipyMediaFormat? webm)?  $default,) {final _that = this;
switch (_that) {
case _KlipyFormatVariants() when $default != null:
return $default(_that.gif,_that.webp,_that.jpg,_that.mp4,_that.webm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KlipyFormatVariants implements KlipyFormatVariants {
  const _KlipyFormatVariants({this.gif, this.webp, this.jpg, this.mp4, this.webm});
  factory _KlipyFormatVariants.fromJson(Map<String, dynamic> json) => _$KlipyFormatVariantsFromJson(json);

@override final  KlipyMediaFormat? gif;
@override final  KlipyMediaFormat? webp;
@override final  KlipyMediaFormat? jpg;
@override final  KlipyMediaFormat? mp4;
@override final  KlipyMediaFormat? webm;

/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KlipyFormatVariantsCopyWith<_KlipyFormatVariants> get copyWith => __$KlipyFormatVariantsCopyWithImpl<_KlipyFormatVariants>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KlipyFormatVariantsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KlipyFormatVariants&&(identical(other.gif, gif) || other.gif == gif)&&(identical(other.webp, webp) || other.webp == webp)&&(identical(other.jpg, jpg) || other.jpg == jpg)&&(identical(other.mp4, mp4) || other.mp4 == mp4)&&(identical(other.webm, webm) || other.webm == webm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gif,webp,jpg,mp4,webm);

@override
String toString() {
  return 'KlipyFormatVariants(gif: $gif, webp: $webp, jpg: $jpg, mp4: $mp4, webm: $webm)';
}


}

/// @nodoc
abstract mixin class _$KlipyFormatVariantsCopyWith<$Res> implements $KlipyFormatVariantsCopyWith<$Res> {
  factory _$KlipyFormatVariantsCopyWith(_KlipyFormatVariants value, $Res Function(_KlipyFormatVariants) _then) = __$KlipyFormatVariantsCopyWithImpl;
@override @useResult
$Res call({
 KlipyMediaFormat? gif, KlipyMediaFormat? webp, KlipyMediaFormat? jpg, KlipyMediaFormat? mp4, KlipyMediaFormat? webm
});


@override $KlipyMediaFormatCopyWith<$Res>? get gif;@override $KlipyMediaFormatCopyWith<$Res>? get webp;@override $KlipyMediaFormatCopyWith<$Res>? get jpg;@override $KlipyMediaFormatCopyWith<$Res>? get mp4;@override $KlipyMediaFormatCopyWith<$Res>? get webm;

}
/// @nodoc
class __$KlipyFormatVariantsCopyWithImpl<$Res>
    implements _$KlipyFormatVariantsCopyWith<$Res> {
  __$KlipyFormatVariantsCopyWithImpl(this._self, this._then);

  final _KlipyFormatVariants _self;
  final $Res Function(_KlipyFormatVariants) _then;

/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gif = freezed,Object? webp = freezed,Object? jpg = freezed,Object? mp4 = freezed,Object? webm = freezed,}) {
  return _then(_KlipyFormatVariants(
gif: freezed == gif ? _self.gif : gif // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,webp: freezed == webp ? _self.webp : webp // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,jpg: freezed == jpg ? _self.jpg : jpg // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,mp4: freezed == mp4 ? _self.mp4 : mp4 // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,webm: freezed == webm ? _self.webm : webm // ignore: cast_nullable_to_non_nullable
as KlipyMediaFormat?,
  ));
}

/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get gif {
    if (_self.gif == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.gif!, (value) {
    return _then(_self.copyWith(gif: value));
  });
}/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get webp {
    if (_self.webp == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.webp!, (value) {
    return _then(_self.copyWith(webp: value));
  });
}/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get jpg {
    if (_self.jpg == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.jpg!, (value) {
    return _then(_self.copyWith(jpg: value));
  });
}/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get mp4 {
    if (_self.mp4 == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.mp4!, (value) {
    return _then(_self.copyWith(mp4: value));
  });
}/// Create a copy of KlipyFormatVariants
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyMediaFormatCopyWith<$Res>? get webm {
    if (_self.webm == null) {
    return null;
  }

  return $KlipyMediaFormatCopyWith<$Res>(_self.webm!, (value) {
    return _then(_self.copyWith(webm: value));
  });
}
}


/// @nodoc
mixin _$KlipyFile {

 KlipyFormatVariants? get hd; KlipyFormatVariants? get md; KlipyFormatVariants? get sm; KlipyFormatVariants? get xs;
/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KlipyFileCopyWith<KlipyFile> get copyWith => _$KlipyFileCopyWithImpl<KlipyFile>(this as KlipyFile, _$identity);

  /// Serializes this KlipyFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KlipyFile&&(identical(other.hd, hd) || other.hd == hd)&&(identical(other.md, md) || other.md == md)&&(identical(other.sm, sm) || other.sm == sm)&&(identical(other.xs, xs) || other.xs == xs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hd,md,sm,xs);

@override
String toString() {
  return 'KlipyFile(hd: $hd, md: $md, sm: $sm, xs: $xs)';
}


}

/// @nodoc
abstract mixin class $KlipyFileCopyWith<$Res>  {
  factory $KlipyFileCopyWith(KlipyFile value, $Res Function(KlipyFile) _then) = _$KlipyFileCopyWithImpl;
@useResult
$Res call({
 KlipyFormatVariants? hd, KlipyFormatVariants? md, KlipyFormatVariants? sm, KlipyFormatVariants? xs
});


$KlipyFormatVariantsCopyWith<$Res>? get hd;$KlipyFormatVariantsCopyWith<$Res>? get md;$KlipyFormatVariantsCopyWith<$Res>? get sm;$KlipyFormatVariantsCopyWith<$Res>? get xs;

}
/// @nodoc
class _$KlipyFileCopyWithImpl<$Res>
    implements $KlipyFileCopyWith<$Res> {
  _$KlipyFileCopyWithImpl(this._self, this._then);

  final KlipyFile _self;
  final $Res Function(KlipyFile) _then;

/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hd = freezed,Object? md = freezed,Object? sm = freezed,Object? xs = freezed,}) {
  return _then(_self.copyWith(
hd: freezed == hd ? _self.hd : hd // ignore: cast_nullable_to_non_nullable
as KlipyFormatVariants?,md: freezed == md ? _self.md : md // ignore: cast_nullable_to_non_nullable
as KlipyFormatVariants?,sm: freezed == sm ? _self.sm : sm // ignore: cast_nullable_to_non_nullable
as KlipyFormatVariants?,xs: freezed == xs ? _self.xs : xs // ignore: cast_nullable_to_non_nullable
as KlipyFormatVariants?,
  ));
}
/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFormatVariantsCopyWith<$Res>? get hd {
    if (_self.hd == null) {
    return null;
  }

  return $KlipyFormatVariantsCopyWith<$Res>(_self.hd!, (value) {
    return _then(_self.copyWith(hd: value));
  });
}/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFormatVariantsCopyWith<$Res>? get md {
    if (_self.md == null) {
    return null;
  }

  return $KlipyFormatVariantsCopyWith<$Res>(_self.md!, (value) {
    return _then(_self.copyWith(md: value));
  });
}/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFormatVariantsCopyWith<$Res>? get sm {
    if (_self.sm == null) {
    return null;
  }

  return $KlipyFormatVariantsCopyWith<$Res>(_self.sm!, (value) {
    return _then(_self.copyWith(sm: value));
  });
}/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFormatVariantsCopyWith<$Res>? get xs {
    if (_self.xs == null) {
    return null;
  }

  return $KlipyFormatVariantsCopyWith<$Res>(_self.xs!, (value) {
    return _then(_self.copyWith(xs: value));
  });
}
}


/// Adds pattern-matching-related methods to [KlipyFile].
extension KlipyFilePatterns on KlipyFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KlipyFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KlipyFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KlipyFile value)  $default,){
final _that = this;
switch (_that) {
case _KlipyFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KlipyFile value)?  $default,){
final _that = this;
switch (_that) {
case _KlipyFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( KlipyFormatVariants? hd,  KlipyFormatVariants? md,  KlipyFormatVariants? sm,  KlipyFormatVariants? xs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KlipyFile() when $default != null:
return $default(_that.hd,_that.md,_that.sm,_that.xs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( KlipyFormatVariants? hd,  KlipyFormatVariants? md,  KlipyFormatVariants? sm,  KlipyFormatVariants? xs)  $default,) {final _that = this;
switch (_that) {
case _KlipyFile():
return $default(_that.hd,_that.md,_that.sm,_that.xs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( KlipyFormatVariants? hd,  KlipyFormatVariants? md,  KlipyFormatVariants? sm,  KlipyFormatVariants? xs)?  $default,) {final _that = this;
switch (_that) {
case _KlipyFile() when $default != null:
return $default(_that.hd,_that.md,_that.sm,_that.xs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KlipyFile implements KlipyFile {
  const _KlipyFile({this.hd, this.md, this.sm, this.xs});
  factory _KlipyFile.fromJson(Map<String, dynamic> json) => _$KlipyFileFromJson(json);

@override final  KlipyFormatVariants? hd;
@override final  KlipyFormatVariants? md;
@override final  KlipyFormatVariants? sm;
@override final  KlipyFormatVariants? xs;

/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KlipyFileCopyWith<_KlipyFile> get copyWith => __$KlipyFileCopyWithImpl<_KlipyFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KlipyFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KlipyFile&&(identical(other.hd, hd) || other.hd == hd)&&(identical(other.md, md) || other.md == md)&&(identical(other.sm, sm) || other.sm == sm)&&(identical(other.xs, xs) || other.xs == xs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hd,md,sm,xs);

@override
String toString() {
  return 'KlipyFile(hd: $hd, md: $md, sm: $sm, xs: $xs)';
}


}

/// @nodoc
abstract mixin class _$KlipyFileCopyWith<$Res> implements $KlipyFileCopyWith<$Res> {
  factory _$KlipyFileCopyWith(_KlipyFile value, $Res Function(_KlipyFile) _then) = __$KlipyFileCopyWithImpl;
@override @useResult
$Res call({
 KlipyFormatVariants? hd, KlipyFormatVariants? md, KlipyFormatVariants? sm, KlipyFormatVariants? xs
});


@override $KlipyFormatVariantsCopyWith<$Res>? get hd;@override $KlipyFormatVariantsCopyWith<$Res>? get md;@override $KlipyFormatVariantsCopyWith<$Res>? get sm;@override $KlipyFormatVariantsCopyWith<$Res>? get xs;

}
/// @nodoc
class __$KlipyFileCopyWithImpl<$Res>
    implements _$KlipyFileCopyWith<$Res> {
  __$KlipyFileCopyWithImpl(this._self, this._then);

  final _KlipyFile _self;
  final $Res Function(_KlipyFile) _then;

/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hd = freezed,Object? md = freezed,Object? sm = freezed,Object? xs = freezed,}) {
  return _then(_KlipyFile(
hd: freezed == hd ? _self.hd : hd // ignore: cast_nullable_to_non_nullable
as KlipyFormatVariants?,md: freezed == md ? _self.md : md // ignore: cast_nullable_to_non_nullable
as KlipyFormatVariants?,sm: freezed == sm ? _self.sm : sm // ignore: cast_nullable_to_non_nullable
as KlipyFormatVariants?,xs: freezed == xs ? _self.xs : xs // ignore: cast_nullable_to_non_nullable
as KlipyFormatVariants?,
  ));
}

/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFormatVariantsCopyWith<$Res>? get hd {
    if (_self.hd == null) {
    return null;
  }

  return $KlipyFormatVariantsCopyWith<$Res>(_self.hd!, (value) {
    return _then(_self.copyWith(hd: value));
  });
}/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFormatVariantsCopyWith<$Res>? get md {
    if (_self.md == null) {
    return null;
  }

  return $KlipyFormatVariantsCopyWith<$Res>(_self.md!, (value) {
    return _then(_self.copyWith(md: value));
  });
}/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFormatVariantsCopyWith<$Res>? get sm {
    if (_self.sm == null) {
    return null;
  }

  return $KlipyFormatVariantsCopyWith<$Res>(_self.sm!, (value) {
    return _then(_self.copyWith(sm: value));
  });
}/// Create a copy of KlipyFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFormatVariantsCopyWith<$Res>? get xs {
    if (_self.xs == null) {
    return null;
  }

  return $KlipyFormatVariantsCopyWith<$Res>(_self.xs!, (value) {
    return _then(_self.copyWith(xs: value));
  });
}
}


/// @nodoc
mixin _$KlipyGif {

 int get id; String get slug; String get title; KlipyFile get file; List<String>? get tags; String? get type;@JsonKey(name: 'blur_preview') String? get blurPreview;
/// Create a copy of KlipyGif
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KlipyGifCopyWith<KlipyGif> get copyWith => _$KlipyGifCopyWithImpl<KlipyGif>(this as KlipyGif, _$identity);

  /// Serializes this KlipyGif to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KlipyGif&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.file, file) || other.file == file)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.type, type) || other.type == type)&&(identical(other.blurPreview, blurPreview) || other.blurPreview == blurPreview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,file,const DeepCollectionEquality().hash(tags),type,blurPreview);

@override
String toString() {
  return 'KlipyGif(id: $id, slug: $slug, title: $title, file: $file, tags: $tags, type: $type, blurPreview: $blurPreview)';
}


}

/// @nodoc
abstract mixin class $KlipyGifCopyWith<$Res>  {
  factory $KlipyGifCopyWith(KlipyGif value, $Res Function(KlipyGif) _then) = _$KlipyGifCopyWithImpl;
@useResult
$Res call({
 int id, String slug, String title, KlipyFile file, List<String>? tags, String? type,@JsonKey(name: 'blur_preview') String? blurPreview
});


$KlipyFileCopyWith<$Res> get file;

}
/// @nodoc
class _$KlipyGifCopyWithImpl<$Res>
    implements $KlipyGifCopyWith<$Res> {
  _$KlipyGifCopyWithImpl(this._self, this._then);

  final KlipyGif _self;
  final $Res Function(KlipyGif) _then;

/// Create a copy of KlipyGif
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? file = null,Object? tags = freezed,Object? type = freezed,Object? blurPreview = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as KlipyFile,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,blurPreview: freezed == blurPreview ? _self.blurPreview : blurPreview // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of KlipyGif
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFileCopyWith<$Res> get file {
  
  return $KlipyFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}


/// Adds pattern-matching-related methods to [KlipyGif].
extension KlipyGifPatterns on KlipyGif {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KlipyGif value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KlipyGif() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KlipyGif value)  $default,){
final _that = this;
switch (_that) {
case _KlipyGif():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KlipyGif value)?  $default,){
final _that = this;
switch (_that) {
case _KlipyGif() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String slug,  String title,  KlipyFile file,  List<String>? tags,  String? type, @JsonKey(name: 'blur_preview')  String? blurPreview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KlipyGif() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.file,_that.tags,_that.type,_that.blurPreview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String slug,  String title,  KlipyFile file,  List<String>? tags,  String? type, @JsonKey(name: 'blur_preview')  String? blurPreview)  $default,) {final _that = this;
switch (_that) {
case _KlipyGif():
return $default(_that.id,_that.slug,_that.title,_that.file,_that.tags,_that.type,_that.blurPreview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String slug,  String title,  KlipyFile file,  List<String>? tags,  String? type, @JsonKey(name: 'blur_preview')  String? blurPreview)?  $default,) {final _that = this;
switch (_that) {
case _KlipyGif() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.file,_that.tags,_that.type,_that.blurPreview);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KlipyGif extends KlipyGif {
  const _KlipyGif({this.id = 0, this.slug = '', this.title = '', this.file = const KlipyFile(), final  List<String>? tags, this.type, @JsonKey(name: 'blur_preview') this.blurPreview}): _tags = tags,super._();
  factory _KlipyGif.fromJson(Map<String, dynamic> json) => _$KlipyGifFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String slug;
@override@JsonKey() final  String title;
@override@JsonKey() final  KlipyFile file;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? type;
@override@JsonKey(name: 'blur_preview') final  String? blurPreview;

/// Create a copy of KlipyGif
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KlipyGifCopyWith<_KlipyGif> get copyWith => __$KlipyGifCopyWithImpl<_KlipyGif>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KlipyGifToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KlipyGif&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.file, file) || other.file == file)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.type, type) || other.type == type)&&(identical(other.blurPreview, blurPreview) || other.blurPreview == blurPreview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,title,file,const DeepCollectionEquality().hash(_tags),type,blurPreview);

@override
String toString() {
  return 'KlipyGif(id: $id, slug: $slug, title: $title, file: $file, tags: $tags, type: $type, blurPreview: $blurPreview)';
}


}

/// @nodoc
abstract mixin class _$KlipyGifCopyWith<$Res> implements $KlipyGifCopyWith<$Res> {
  factory _$KlipyGifCopyWith(_KlipyGif value, $Res Function(_KlipyGif) _then) = __$KlipyGifCopyWithImpl;
@override @useResult
$Res call({
 int id, String slug, String title, KlipyFile file, List<String>? tags, String? type,@JsonKey(name: 'blur_preview') String? blurPreview
});


@override $KlipyFileCopyWith<$Res> get file;

}
/// @nodoc
class __$KlipyGifCopyWithImpl<$Res>
    implements _$KlipyGifCopyWith<$Res> {
  __$KlipyGifCopyWithImpl(this._self, this._then);

  final _KlipyGif _self;
  final $Res Function(_KlipyGif) _then;

/// Create a copy of KlipyGif
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? file = null,Object? tags = freezed,Object? type = freezed,Object? blurPreview = freezed,}) {
  return _then(_KlipyGif(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as KlipyFile,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,blurPreview: freezed == blurPreview ? _self.blurPreview : blurPreview // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of KlipyGif
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KlipyFileCopyWith<$Res> get file {
  
  return $KlipyFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}


/// @nodoc
mixin _$KlipySearchResponse {

 List<KlipyGif> get results;@JsonKey(name: 'current_page') int get currentPage;@JsonKey(name: 'per_page') int get perPage;@JsonKey(name: 'has_next') bool get hasNext;
/// Create a copy of KlipySearchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KlipySearchResponseCopyWith<KlipySearchResponse> get copyWith => _$KlipySearchResponseCopyWithImpl<KlipySearchResponse>(this as KlipySearchResponse, _$identity);

  /// Serializes this KlipySearchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KlipySearchResponse&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),currentPage,perPage,hasNext);

@override
String toString() {
  return 'KlipySearchResponse(results: $results, currentPage: $currentPage, perPage: $perPage, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class $KlipySearchResponseCopyWith<$Res>  {
  factory $KlipySearchResponseCopyWith(KlipySearchResponse value, $Res Function(KlipySearchResponse) _then) = _$KlipySearchResponseCopyWithImpl;
@useResult
$Res call({
 List<KlipyGif> results,@JsonKey(name: 'current_page') int currentPage,@JsonKey(name: 'per_page') int perPage,@JsonKey(name: 'has_next') bool hasNext
});




}
/// @nodoc
class _$KlipySearchResponseCopyWithImpl<$Res>
    implements $KlipySearchResponseCopyWith<$Res> {
  _$KlipySearchResponseCopyWithImpl(this._self, this._then);

  final KlipySearchResponse _self;
  final $Res Function(KlipySearchResponse) _then;

/// Create a copy of KlipySearchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? currentPage = null,Object? perPage = null,Object? hasNext = null,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<KlipyGif>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [KlipySearchResponse].
extension KlipySearchResponsePatterns on KlipySearchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KlipySearchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KlipySearchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KlipySearchResponse value)  $default,){
final _that = this;
switch (_that) {
case _KlipySearchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KlipySearchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _KlipySearchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<KlipyGif> results, @JsonKey(name: 'current_page')  int currentPage, @JsonKey(name: 'per_page')  int perPage, @JsonKey(name: 'has_next')  bool hasNext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KlipySearchResponse() when $default != null:
return $default(_that.results,_that.currentPage,_that.perPage,_that.hasNext);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<KlipyGif> results, @JsonKey(name: 'current_page')  int currentPage, @JsonKey(name: 'per_page')  int perPage, @JsonKey(name: 'has_next')  bool hasNext)  $default,) {final _that = this;
switch (_that) {
case _KlipySearchResponse():
return $default(_that.results,_that.currentPage,_that.perPage,_that.hasNext);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<KlipyGif> results, @JsonKey(name: 'current_page')  int currentPage, @JsonKey(name: 'per_page')  int perPage, @JsonKey(name: 'has_next')  bool hasNext)?  $default,) {final _that = this;
switch (_that) {
case _KlipySearchResponse() when $default != null:
return $default(_that.results,_that.currentPage,_that.perPage,_that.hasNext);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KlipySearchResponse extends KlipySearchResponse {
  const _KlipySearchResponse({final  List<KlipyGif> results = const [], @JsonKey(name: 'current_page') this.currentPage = 1, @JsonKey(name: 'per_page') this.perPage = 24, @JsonKey(name: 'has_next') this.hasNext = false}): _results = results,super._();
  factory _KlipySearchResponse.fromJson(Map<String, dynamic> json) => _$KlipySearchResponseFromJson(json);

 final  List<KlipyGif> _results;
@override@JsonKey() List<KlipyGif> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey(name: 'current_page') final  int currentPage;
@override@JsonKey(name: 'per_page') final  int perPage;
@override@JsonKey(name: 'has_next') final  bool hasNext;

/// Create a copy of KlipySearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KlipySearchResponseCopyWith<_KlipySearchResponse> get copyWith => __$KlipySearchResponseCopyWithImpl<_KlipySearchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KlipySearchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KlipySearchResponse&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.perPage, perPage) || other.perPage == perPage)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),currentPage,perPage,hasNext);

@override
String toString() {
  return 'KlipySearchResponse(results: $results, currentPage: $currentPage, perPage: $perPage, hasNext: $hasNext)';
}


}

/// @nodoc
abstract mixin class _$KlipySearchResponseCopyWith<$Res> implements $KlipySearchResponseCopyWith<$Res> {
  factory _$KlipySearchResponseCopyWith(_KlipySearchResponse value, $Res Function(_KlipySearchResponse) _then) = __$KlipySearchResponseCopyWithImpl;
@override @useResult
$Res call({
 List<KlipyGif> results,@JsonKey(name: 'current_page') int currentPage,@JsonKey(name: 'per_page') int perPage,@JsonKey(name: 'has_next') bool hasNext
});




}
/// @nodoc
class __$KlipySearchResponseCopyWithImpl<$Res>
    implements _$KlipySearchResponseCopyWith<$Res> {
  __$KlipySearchResponseCopyWithImpl(this._self, this._then);

  final _KlipySearchResponse _self;
  final $Res Function(_KlipySearchResponse) _then;

/// Create a copy of KlipySearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? currentPage = null,Object? perPage = null,Object? hasNext = null,}) {
  return _then(_KlipySearchResponse(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<KlipyGif>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,perPage: null == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
