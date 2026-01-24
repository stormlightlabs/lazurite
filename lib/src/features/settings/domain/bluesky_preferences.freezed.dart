// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bluesky_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdultContentPref {

 bool get enabled;
/// Create a copy of AdultContentPref
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdultContentPrefCopyWith<AdultContentPref> get copyWith => _$AdultContentPrefCopyWithImpl<AdultContentPref>(this as AdultContentPref, _$identity);

  /// Serializes this AdultContentPref to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdultContentPref&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'AdultContentPref(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $AdultContentPrefCopyWith<$Res>  {
  factory $AdultContentPrefCopyWith(AdultContentPref value, $Res Function(AdultContentPref) _then) = _$AdultContentPrefCopyWithImpl;
@useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class _$AdultContentPrefCopyWithImpl<$Res>
    implements $AdultContentPrefCopyWith<$Res> {
  _$AdultContentPrefCopyWithImpl(this._self, this._then);

  final AdultContentPref _self;
  final $Res Function(AdultContentPref) _then;

/// Create a copy of AdultContentPref
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AdultContentPref].
extension AdultContentPrefPatterns on AdultContentPref {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdultContentPref value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdultContentPref() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdultContentPref value)  $default,){
final _that = this;
switch (_that) {
case _AdultContentPref():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdultContentPref value)?  $default,){
final _that = this;
switch (_that) {
case _AdultContentPref() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdultContentPref() when $default != null:
return $default(_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled)  $default,) {final _that = this;
switch (_that) {
case _AdultContentPref():
return $default(_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _AdultContentPref() when $default != null:
return $default(_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdultContentPref extends AdultContentPref {
  const _AdultContentPref({this.enabled = false}): super._();
  factory _AdultContentPref.fromJson(Map<String, dynamic> json) => _$AdultContentPrefFromJson(json);

@override@JsonKey() final  bool enabled;

/// Create a copy of AdultContentPref
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdultContentPrefCopyWith<_AdultContentPref> get copyWith => __$AdultContentPrefCopyWithImpl<_AdultContentPref>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdultContentPrefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdultContentPref&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'AdultContentPref(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$AdultContentPrefCopyWith<$Res> implements $AdultContentPrefCopyWith<$Res> {
  factory _$AdultContentPrefCopyWith(_AdultContentPref value, $Res Function(_AdultContentPref) _then) = __$AdultContentPrefCopyWithImpl;
@override @useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class __$AdultContentPrefCopyWithImpl<$Res>
    implements _$AdultContentPrefCopyWith<$Res> {
  __$AdultContentPrefCopyWithImpl(this._self, this._then);

  final _AdultContentPref _self;
  final $Res Function(_AdultContentPref) _then;

/// Create a copy of AdultContentPref
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,}) {
  return _then(_AdultContentPref(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ContentLabelPref {

 String get label; LabelVisibility get visibility;@JsonKey(includeIfNull: false) String? get labelerDid;
/// Create a copy of ContentLabelPref
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentLabelPrefCopyWith<ContentLabelPref> get copyWith => _$ContentLabelPrefCopyWithImpl<ContentLabelPref>(this as ContentLabelPref, _$identity);

  /// Serializes this ContentLabelPref to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentLabelPref&&(identical(other.label, label) || other.label == label)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.labelerDid, labelerDid) || other.labelerDid == labelerDid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,visibility,labelerDid);

@override
String toString() {
  return 'ContentLabelPref(label: $label, visibility: $visibility, labelerDid: $labelerDid)';
}


}

/// @nodoc
abstract mixin class $ContentLabelPrefCopyWith<$Res>  {
  factory $ContentLabelPrefCopyWith(ContentLabelPref value, $Res Function(ContentLabelPref) _then) = _$ContentLabelPrefCopyWithImpl;
@useResult
$Res call({
 String label, LabelVisibility visibility,@JsonKey(includeIfNull: false) String? labelerDid
});




}
/// @nodoc
class _$ContentLabelPrefCopyWithImpl<$Res>
    implements $ContentLabelPrefCopyWith<$Res> {
  _$ContentLabelPrefCopyWithImpl(this._self, this._then);

  final ContentLabelPref _self;
  final $Res Function(ContentLabelPref) _then;

/// Create a copy of ContentLabelPref
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? visibility = null,Object? labelerDid = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as LabelVisibility,labelerDid: freezed == labelerDid ? _self.labelerDid : labelerDid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentLabelPref].
extension ContentLabelPrefPatterns on ContentLabelPref {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentLabelPref value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentLabelPref() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentLabelPref value)  $default,){
final _that = this;
switch (_that) {
case _ContentLabelPref():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentLabelPref value)?  $default,){
final _that = this;
switch (_that) {
case _ContentLabelPref() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  LabelVisibility visibility, @JsonKey(includeIfNull: false)  String? labelerDid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentLabelPref() when $default != null:
return $default(_that.label,_that.visibility,_that.labelerDid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  LabelVisibility visibility, @JsonKey(includeIfNull: false)  String? labelerDid)  $default,) {final _that = this;
switch (_that) {
case _ContentLabelPref():
return $default(_that.label,_that.visibility,_that.labelerDid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  LabelVisibility visibility, @JsonKey(includeIfNull: false)  String? labelerDid)?  $default,) {final _that = this;
switch (_that) {
case _ContentLabelPref() when $default != null:
return $default(_that.label,_that.visibility,_that.labelerDid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentLabelPref extends ContentLabelPref {
  const _ContentLabelPref({required this.label, this.visibility = LabelVisibility.warn, @JsonKey(includeIfNull: false) this.labelerDid}): super._();
  factory _ContentLabelPref.fromJson(Map<String, dynamic> json) => _$ContentLabelPrefFromJson(json);

@override final  String label;
@override@JsonKey() final  LabelVisibility visibility;
@override@JsonKey(includeIfNull: false) final  String? labelerDid;

/// Create a copy of ContentLabelPref
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentLabelPrefCopyWith<_ContentLabelPref> get copyWith => __$ContentLabelPrefCopyWithImpl<_ContentLabelPref>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentLabelPrefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentLabelPref&&(identical(other.label, label) || other.label == label)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.labelerDid, labelerDid) || other.labelerDid == labelerDid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,visibility,labelerDid);

@override
String toString() {
  return 'ContentLabelPref(label: $label, visibility: $visibility, labelerDid: $labelerDid)';
}


}

/// @nodoc
abstract mixin class _$ContentLabelPrefCopyWith<$Res> implements $ContentLabelPrefCopyWith<$Res> {
  factory _$ContentLabelPrefCopyWith(_ContentLabelPref value, $Res Function(_ContentLabelPref) _then) = __$ContentLabelPrefCopyWithImpl;
@override @useResult
$Res call({
 String label, LabelVisibility visibility,@JsonKey(includeIfNull: false) String? labelerDid
});




}
/// @nodoc
class __$ContentLabelPrefCopyWithImpl<$Res>
    implements _$ContentLabelPrefCopyWith<$Res> {
  __$ContentLabelPrefCopyWithImpl(this._self, this._then);

  final _ContentLabelPref _self;
  final $Res Function(_ContentLabelPref) _then;

/// Create a copy of ContentLabelPref
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? visibility = null,Object? labelerDid = freezed,}) {
  return _then(_ContentLabelPref(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as LabelVisibility,labelerDid: freezed == labelerDid ? _self.labelerDid : labelerDid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ContentLabelPrefs {

 List<ContentLabelPref> get items;
/// Create a copy of ContentLabelPrefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentLabelPrefsCopyWith<ContentLabelPrefs> get copyWith => _$ContentLabelPrefsCopyWithImpl<ContentLabelPrefs>(this as ContentLabelPrefs, _$identity);

  /// Serializes this ContentLabelPrefs to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentLabelPrefs&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ContentLabelPrefs(items: $items)';
}


}

/// @nodoc
abstract mixin class $ContentLabelPrefsCopyWith<$Res>  {
  factory $ContentLabelPrefsCopyWith(ContentLabelPrefs value, $Res Function(ContentLabelPrefs) _then) = _$ContentLabelPrefsCopyWithImpl;
@useResult
$Res call({
 List<ContentLabelPref> items
});




}
/// @nodoc
class _$ContentLabelPrefsCopyWithImpl<$Res>
    implements $ContentLabelPrefsCopyWith<$Res> {
  _$ContentLabelPrefsCopyWithImpl(this._self, this._then);

  final ContentLabelPrefs _self;
  final $Res Function(ContentLabelPrefs) _then;

/// Create a copy of ContentLabelPrefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ContentLabelPref>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentLabelPrefs].
extension ContentLabelPrefsPatterns on ContentLabelPrefs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentLabelPrefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentLabelPrefs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentLabelPrefs value)  $default,){
final _that = this;
switch (_that) {
case _ContentLabelPrefs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentLabelPrefs value)?  $default,){
final _that = this;
switch (_that) {
case _ContentLabelPrefs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ContentLabelPref> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentLabelPrefs() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ContentLabelPref> items)  $default,) {final _that = this;
switch (_that) {
case _ContentLabelPrefs():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ContentLabelPref> items)?  $default,) {final _that = this;
switch (_that) {
case _ContentLabelPrefs() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentLabelPrefs extends ContentLabelPrefs {
  const _ContentLabelPrefs({final  List<ContentLabelPref> items = const []}): _items = items,super._();
  factory _ContentLabelPrefs.fromJson(Map<String, dynamic> json) => _$ContentLabelPrefsFromJson(json);

 final  List<ContentLabelPref> _items;
@override@JsonKey() List<ContentLabelPref> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ContentLabelPrefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentLabelPrefsCopyWith<_ContentLabelPrefs> get copyWith => __$ContentLabelPrefsCopyWithImpl<_ContentLabelPrefs>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentLabelPrefsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentLabelPrefs&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ContentLabelPrefs(items: $items)';
}


}

/// @nodoc
abstract mixin class _$ContentLabelPrefsCopyWith<$Res> implements $ContentLabelPrefsCopyWith<$Res> {
  factory _$ContentLabelPrefsCopyWith(_ContentLabelPrefs value, $Res Function(_ContentLabelPrefs) _then) = __$ContentLabelPrefsCopyWithImpl;
@override @useResult
$Res call({
 List<ContentLabelPref> items
});




}
/// @nodoc
class __$ContentLabelPrefsCopyWithImpl<$Res>
    implements _$ContentLabelPrefsCopyWith<$Res> {
  __$ContentLabelPrefsCopyWithImpl(this._self, this._then);

  final _ContentLabelPrefs _self;
  final $Res Function(_ContentLabelPrefs) _then;

/// Create a copy of ContentLabelPrefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_ContentLabelPrefs(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ContentLabelPref>,
  ));
}


}


/// @nodoc
mixin _$LabelerRef {

 String get did;
/// Create a copy of LabelerRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabelerRefCopyWith<LabelerRef> get copyWith => _$LabelerRefCopyWithImpl<LabelerRef>(this as LabelerRef, _$identity);

  /// Serializes this LabelerRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabelerRef&&(identical(other.did, did) || other.did == did));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did);

@override
String toString() {
  return 'LabelerRef(did: $did)';
}


}

/// @nodoc
abstract mixin class $LabelerRefCopyWith<$Res>  {
  factory $LabelerRefCopyWith(LabelerRef value, $Res Function(LabelerRef) _then) = _$LabelerRefCopyWithImpl;
@useResult
$Res call({
 String did
});




}
/// @nodoc
class _$LabelerRefCopyWithImpl<$Res>
    implements $LabelerRefCopyWith<$Res> {
  _$LabelerRefCopyWithImpl(this._self, this._then);

  final LabelerRef _self;
  final $Res Function(LabelerRef) _then;

/// Create a copy of LabelerRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? did = null,}) {
  return _then(_self.copyWith(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LabelerRef].
extension LabelerRefPatterns on LabelerRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabelerRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabelerRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabelerRef value)  $default,){
final _that = this;
switch (_that) {
case _LabelerRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabelerRef value)?  $default,){
final _that = this;
switch (_that) {
case _LabelerRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String did)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabelerRef() when $default != null:
return $default(_that.did);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String did)  $default,) {final _that = this;
switch (_that) {
case _LabelerRef():
return $default(_that.did);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String did)?  $default,) {final _that = this;
switch (_that) {
case _LabelerRef() when $default != null:
return $default(_that.did);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabelerRef extends LabelerRef {
  const _LabelerRef({required this.did}): super._();
  factory _LabelerRef.fromJson(Map<String, dynamic> json) => _$LabelerRefFromJson(json);

@override final  String did;

/// Create a copy of LabelerRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabelerRefCopyWith<_LabelerRef> get copyWith => __$LabelerRefCopyWithImpl<_LabelerRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabelerRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabelerRef&&(identical(other.did, did) || other.did == did));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did);

@override
String toString() {
  return 'LabelerRef(did: $did)';
}


}

/// @nodoc
abstract mixin class _$LabelerRefCopyWith<$Res> implements $LabelerRefCopyWith<$Res> {
  factory _$LabelerRefCopyWith(_LabelerRef value, $Res Function(_LabelerRef) _then) = __$LabelerRefCopyWithImpl;
@override @useResult
$Res call({
 String did
});




}
/// @nodoc
class __$LabelerRefCopyWithImpl<$Res>
    implements _$LabelerRefCopyWith<$Res> {
  __$LabelerRefCopyWithImpl(this._self, this._then);

  final _LabelerRef _self;
  final $Res Function(_LabelerRef) _then;

/// Create a copy of LabelerRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? did = null,}) {
  return _then(_LabelerRef(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LabelersPref {

 List<LabelerRef> get labelers;
/// Create a copy of LabelersPref
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabelersPrefCopyWith<LabelersPref> get copyWith => _$LabelersPrefCopyWithImpl<LabelersPref>(this as LabelersPref, _$identity);

  /// Serializes this LabelersPref to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabelersPref&&const DeepCollectionEquality().equals(other.labelers, labelers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(labelers));

@override
String toString() {
  return 'LabelersPref(labelers: $labelers)';
}


}

/// @nodoc
abstract mixin class $LabelersPrefCopyWith<$Res>  {
  factory $LabelersPrefCopyWith(LabelersPref value, $Res Function(LabelersPref) _then) = _$LabelersPrefCopyWithImpl;
@useResult
$Res call({
 List<LabelerRef> labelers
});




}
/// @nodoc
class _$LabelersPrefCopyWithImpl<$Res>
    implements $LabelersPrefCopyWith<$Res> {
  _$LabelersPrefCopyWithImpl(this._self, this._then);

  final LabelersPref _self;
  final $Res Function(LabelersPref) _then;

/// Create a copy of LabelersPref
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labelers = null,}) {
  return _then(_self.copyWith(
labelers: null == labelers ? _self.labelers : labelers // ignore: cast_nullable_to_non_nullable
as List<LabelerRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [LabelersPref].
extension LabelersPrefPatterns on LabelersPref {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabelersPref value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabelersPref() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabelersPref value)  $default,){
final _that = this;
switch (_that) {
case _LabelersPref():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabelersPref value)?  $default,){
final _that = this;
switch (_that) {
case _LabelersPref() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LabelerRef> labelers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabelersPref() when $default != null:
return $default(_that.labelers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LabelerRef> labelers)  $default,) {final _that = this;
switch (_that) {
case _LabelersPref():
return $default(_that.labelers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LabelerRef> labelers)?  $default,) {final _that = this;
switch (_that) {
case _LabelersPref() when $default != null:
return $default(_that.labelers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabelersPref extends LabelersPref {
  const _LabelersPref({final  List<LabelerRef> labelers = const []}): _labelers = labelers,super._();
  factory _LabelersPref.fromJson(Map<String, dynamic> json) => _$LabelersPrefFromJson(json);

 final  List<LabelerRef> _labelers;
@override@JsonKey() List<LabelerRef> get labelers {
  if (_labelers is EqualUnmodifiableListView) return _labelers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labelers);
}


/// Create a copy of LabelersPref
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabelersPrefCopyWith<_LabelersPref> get copyWith => __$LabelersPrefCopyWithImpl<_LabelersPref>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabelersPrefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabelersPref&&const DeepCollectionEquality().equals(other._labelers, _labelers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_labelers));

@override
String toString() {
  return 'LabelersPref(labelers: $labelers)';
}


}

/// @nodoc
abstract mixin class _$LabelersPrefCopyWith<$Res> implements $LabelersPrefCopyWith<$Res> {
  factory _$LabelersPrefCopyWith(_LabelersPref value, $Res Function(_LabelersPref) _then) = __$LabelersPrefCopyWithImpl;
@override @useResult
$Res call({
 List<LabelerRef> labelers
});




}
/// @nodoc
class __$LabelersPrefCopyWithImpl<$Res>
    implements _$LabelersPrefCopyWith<$Res> {
  __$LabelersPrefCopyWithImpl(this._self, this._then);

  final _LabelersPref _self;
  final $Res Function(_LabelersPref) _then;

/// Create a copy of LabelersPref
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labelers = null,}) {
  return _then(_LabelersPref(
labelers: null == labelers ? _self._labelers : labelers // ignore: cast_nullable_to_non_nullable
as List<LabelerRef>,
  ));
}


}


/// @nodoc
mixin _$FeedViewPref {

 bool get hideReplies; bool get hideRepliesByUnfollowed;@JsonKey(includeIfNull: false) int? get hideRepliesByLikeCount; bool get hideReposts; bool get hideQuotePosts;@JsonKey(includeIfNull: false) String? get feed;
/// Create a copy of FeedViewPref
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedViewPrefCopyWith<FeedViewPref> get copyWith => _$FeedViewPrefCopyWithImpl<FeedViewPref>(this as FeedViewPref, _$identity);

  /// Serializes this FeedViewPref to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedViewPref&&(identical(other.hideReplies, hideReplies) || other.hideReplies == hideReplies)&&(identical(other.hideRepliesByUnfollowed, hideRepliesByUnfollowed) || other.hideRepliesByUnfollowed == hideRepliesByUnfollowed)&&(identical(other.hideRepliesByLikeCount, hideRepliesByLikeCount) || other.hideRepliesByLikeCount == hideRepliesByLikeCount)&&(identical(other.hideReposts, hideReposts) || other.hideReposts == hideReposts)&&(identical(other.hideQuotePosts, hideQuotePosts) || other.hideQuotePosts == hideQuotePosts)&&(identical(other.feed, feed) || other.feed == feed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hideReplies,hideRepliesByUnfollowed,hideRepliesByLikeCount,hideReposts,hideQuotePosts,feed);

@override
String toString() {
  return 'FeedViewPref(hideReplies: $hideReplies, hideRepliesByUnfollowed: $hideRepliesByUnfollowed, hideRepliesByLikeCount: $hideRepliesByLikeCount, hideReposts: $hideReposts, hideQuotePosts: $hideQuotePosts, feed: $feed)';
}


}

/// @nodoc
abstract mixin class $FeedViewPrefCopyWith<$Res>  {
  factory $FeedViewPrefCopyWith(FeedViewPref value, $Res Function(FeedViewPref) _then) = _$FeedViewPrefCopyWithImpl;
@useResult
$Res call({
 bool hideReplies, bool hideRepliesByUnfollowed,@JsonKey(includeIfNull: false) int? hideRepliesByLikeCount, bool hideReposts, bool hideQuotePosts,@JsonKey(includeIfNull: false) String? feed
});




}
/// @nodoc
class _$FeedViewPrefCopyWithImpl<$Res>
    implements $FeedViewPrefCopyWith<$Res> {
  _$FeedViewPrefCopyWithImpl(this._self, this._then);

  final FeedViewPref _self;
  final $Res Function(FeedViewPref) _then;

/// Create a copy of FeedViewPref
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hideReplies = null,Object? hideRepliesByUnfollowed = null,Object? hideRepliesByLikeCount = freezed,Object? hideReposts = null,Object? hideQuotePosts = null,Object? feed = freezed,}) {
  return _then(_self.copyWith(
hideReplies: null == hideReplies ? _self.hideReplies : hideReplies // ignore: cast_nullable_to_non_nullable
as bool,hideRepliesByUnfollowed: null == hideRepliesByUnfollowed ? _self.hideRepliesByUnfollowed : hideRepliesByUnfollowed // ignore: cast_nullable_to_non_nullable
as bool,hideRepliesByLikeCount: freezed == hideRepliesByLikeCount ? _self.hideRepliesByLikeCount : hideRepliesByLikeCount // ignore: cast_nullable_to_non_nullable
as int?,hideReposts: null == hideReposts ? _self.hideReposts : hideReposts // ignore: cast_nullable_to_non_nullable
as bool,hideQuotePosts: null == hideQuotePosts ? _self.hideQuotePosts : hideQuotePosts // ignore: cast_nullable_to_non_nullable
as bool,feed: freezed == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedViewPref].
extension FeedViewPrefPatterns on FeedViewPref {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedViewPref value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedViewPref() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedViewPref value)  $default,){
final _that = this;
switch (_that) {
case _FeedViewPref():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedViewPref value)?  $default,){
final _that = this;
switch (_that) {
case _FeedViewPref() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hideReplies,  bool hideRepliesByUnfollowed, @JsonKey(includeIfNull: false)  int? hideRepliesByLikeCount,  bool hideReposts,  bool hideQuotePosts, @JsonKey(includeIfNull: false)  String? feed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedViewPref() when $default != null:
return $default(_that.hideReplies,_that.hideRepliesByUnfollowed,_that.hideRepliesByLikeCount,_that.hideReposts,_that.hideQuotePosts,_that.feed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hideReplies,  bool hideRepliesByUnfollowed, @JsonKey(includeIfNull: false)  int? hideRepliesByLikeCount,  bool hideReposts,  bool hideQuotePosts, @JsonKey(includeIfNull: false)  String? feed)  $default,) {final _that = this;
switch (_that) {
case _FeedViewPref():
return $default(_that.hideReplies,_that.hideRepliesByUnfollowed,_that.hideRepliesByLikeCount,_that.hideReposts,_that.hideQuotePosts,_that.feed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hideReplies,  bool hideRepliesByUnfollowed, @JsonKey(includeIfNull: false)  int? hideRepliesByLikeCount,  bool hideReposts,  bool hideQuotePosts, @JsonKey(includeIfNull: false)  String? feed)?  $default,) {final _that = this;
switch (_that) {
case _FeedViewPref() when $default != null:
return $default(_that.hideReplies,_that.hideRepliesByUnfollowed,_that.hideRepliesByLikeCount,_that.hideReposts,_that.hideQuotePosts,_that.feed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedViewPref extends FeedViewPref {
  const _FeedViewPref({this.hideReplies = false, this.hideRepliesByUnfollowed = true, @JsonKey(includeIfNull: false) this.hideRepliesByLikeCount, this.hideReposts = false, this.hideQuotePosts = false, @JsonKey(includeIfNull: false) this.feed}): super._();
  factory _FeedViewPref.fromJson(Map<String, dynamic> json) => _$FeedViewPrefFromJson(json);

@override@JsonKey() final  bool hideReplies;
@override@JsonKey() final  bool hideRepliesByUnfollowed;
@override@JsonKey(includeIfNull: false) final  int? hideRepliesByLikeCount;
@override@JsonKey() final  bool hideReposts;
@override@JsonKey() final  bool hideQuotePosts;
@override@JsonKey(includeIfNull: false) final  String? feed;

/// Create a copy of FeedViewPref
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedViewPrefCopyWith<_FeedViewPref> get copyWith => __$FeedViewPrefCopyWithImpl<_FeedViewPref>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedViewPrefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedViewPref&&(identical(other.hideReplies, hideReplies) || other.hideReplies == hideReplies)&&(identical(other.hideRepliesByUnfollowed, hideRepliesByUnfollowed) || other.hideRepliesByUnfollowed == hideRepliesByUnfollowed)&&(identical(other.hideRepliesByLikeCount, hideRepliesByLikeCount) || other.hideRepliesByLikeCount == hideRepliesByLikeCount)&&(identical(other.hideReposts, hideReposts) || other.hideReposts == hideReposts)&&(identical(other.hideQuotePosts, hideQuotePosts) || other.hideQuotePosts == hideQuotePosts)&&(identical(other.feed, feed) || other.feed == feed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hideReplies,hideRepliesByUnfollowed,hideRepliesByLikeCount,hideReposts,hideQuotePosts,feed);

@override
String toString() {
  return 'FeedViewPref(hideReplies: $hideReplies, hideRepliesByUnfollowed: $hideRepliesByUnfollowed, hideRepliesByLikeCount: $hideRepliesByLikeCount, hideReposts: $hideReposts, hideQuotePosts: $hideQuotePosts, feed: $feed)';
}


}

/// @nodoc
abstract mixin class _$FeedViewPrefCopyWith<$Res> implements $FeedViewPrefCopyWith<$Res> {
  factory _$FeedViewPrefCopyWith(_FeedViewPref value, $Res Function(_FeedViewPref) _then) = __$FeedViewPrefCopyWithImpl;
@override @useResult
$Res call({
 bool hideReplies, bool hideRepliesByUnfollowed,@JsonKey(includeIfNull: false) int? hideRepliesByLikeCount, bool hideReposts, bool hideQuotePosts,@JsonKey(includeIfNull: false) String? feed
});




}
/// @nodoc
class __$FeedViewPrefCopyWithImpl<$Res>
    implements _$FeedViewPrefCopyWith<$Res> {
  __$FeedViewPrefCopyWithImpl(this._self, this._then);

  final _FeedViewPref _self;
  final $Res Function(_FeedViewPref) _then;

/// Create a copy of FeedViewPref
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hideReplies = null,Object? hideRepliesByUnfollowed = null,Object? hideRepliesByLikeCount = freezed,Object? hideReposts = null,Object? hideQuotePosts = null,Object? feed = freezed,}) {
  return _then(_FeedViewPref(
hideReplies: null == hideReplies ? _self.hideReplies : hideReplies // ignore: cast_nullable_to_non_nullable
as bool,hideRepliesByUnfollowed: null == hideRepliesByUnfollowed ? _self.hideRepliesByUnfollowed : hideRepliesByUnfollowed // ignore: cast_nullable_to_non_nullable
as bool,hideRepliesByLikeCount: freezed == hideRepliesByLikeCount ? _self.hideRepliesByLikeCount : hideRepliesByLikeCount // ignore: cast_nullable_to_non_nullable
as int?,hideReposts: null == hideReposts ? _self.hideReposts : hideReposts // ignore: cast_nullable_to_non_nullable
as bool,hideQuotePosts: null == hideQuotePosts ? _self.hideQuotePosts : hideQuotePosts // ignore: cast_nullable_to_non_nullable
as bool,feed: freezed == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ThreadViewPref {

 ThreadSortOrder get sort; bool get prioritizeFollowedUsers;
/// Create a copy of ThreadViewPref
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadViewPrefCopyWith<ThreadViewPref> get copyWith => _$ThreadViewPrefCopyWithImpl<ThreadViewPref>(this as ThreadViewPref, _$identity);

  /// Serializes this ThreadViewPref to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadViewPref&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.prioritizeFollowedUsers, prioritizeFollowedUsers) || other.prioritizeFollowedUsers == prioritizeFollowedUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sort,prioritizeFollowedUsers);

@override
String toString() {
  return 'ThreadViewPref(sort: $sort, prioritizeFollowedUsers: $prioritizeFollowedUsers)';
}


}

/// @nodoc
abstract mixin class $ThreadViewPrefCopyWith<$Res>  {
  factory $ThreadViewPrefCopyWith(ThreadViewPref value, $Res Function(ThreadViewPref) _then) = _$ThreadViewPrefCopyWithImpl;
@useResult
$Res call({
 ThreadSortOrder sort, bool prioritizeFollowedUsers
});




}
/// @nodoc
class _$ThreadViewPrefCopyWithImpl<$Res>
    implements $ThreadViewPrefCopyWith<$Res> {
  _$ThreadViewPrefCopyWithImpl(this._self, this._then);

  final ThreadViewPref _self;
  final $Res Function(ThreadViewPref) _then;

/// Create a copy of ThreadViewPref
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sort = null,Object? prioritizeFollowedUsers = null,}) {
  return _then(_self.copyWith(
sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ThreadSortOrder,prioritizeFollowedUsers: null == prioritizeFollowedUsers ? _self.prioritizeFollowedUsers : prioritizeFollowedUsers // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ThreadViewPref].
extension ThreadViewPrefPatterns on ThreadViewPref {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThreadViewPref value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadViewPref() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThreadViewPref value)  $default,){
final _that = this;
switch (_that) {
case _ThreadViewPref():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThreadViewPref value)?  $default,){
final _that = this;
switch (_that) {
case _ThreadViewPref() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThreadSortOrder sort,  bool prioritizeFollowedUsers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadViewPref() when $default != null:
return $default(_that.sort,_that.prioritizeFollowedUsers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThreadSortOrder sort,  bool prioritizeFollowedUsers)  $default,) {final _that = this;
switch (_that) {
case _ThreadViewPref():
return $default(_that.sort,_that.prioritizeFollowedUsers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThreadSortOrder sort,  bool prioritizeFollowedUsers)?  $default,) {final _that = this;
switch (_that) {
case _ThreadViewPref() when $default != null:
return $default(_that.sort,_that.prioritizeFollowedUsers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadViewPref extends ThreadViewPref {
  const _ThreadViewPref({this.sort = ThreadSortOrder.oldest, this.prioritizeFollowedUsers = true}): super._();
  factory _ThreadViewPref.fromJson(Map<String, dynamic> json) => _$ThreadViewPrefFromJson(json);

@override@JsonKey() final  ThreadSortOrder sort;
@override@JsonKey() final  bool prioritizeFollowedUsers;

/// Create a copy of ThreadViewPref
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadViewPrefCopyWith<_ThreadViewPref> get copyWith => __$ThreadViewPrefCopyWithImpl<_ThreadViewPref>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadViewPrefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadViewPref&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.prioritizeFollowedUsers, prioritizeFollowedUsers) || other.prioritizeFollowedUsers == prioritizeFollowedUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sort,prioritizeFollowedUsers);

@override
String toString() {
  return 'ThreadViewPref(sort: $sort, prioritizeFollowedUsers: $prioritizeFollowedUsers)';
}


}

/// @nodoc
abstract mixin class _$ThreadViewPrefCopyWith<$Res> implements $ThreadViewPrefCopyWith<$Res> {
  factory _$ThreadViewPrefCopyWith(_ThreadViewPref value, $Res Function(_ThreadViewPref) _then) = __$ThreadViewPrefCopyWithImpl;
@override @useResult
$Res call({
 ThreadSortOrder sort, bool prioritizeFollowedUsers
});




}
/// @nodoc
class __$ThreadViewPrefCopyWithImpl<$Res>
    implements _$ThreadViewPrefCopyWith<$Res> {
  __$ThreadViewPrefCopyWithImpl(this._self, this._then);

  final _ThreadViewPref _self;
  final $Res Function(_ThreadViewPref) _then;

/// Create a copy of ThreadViewPref
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sort = null,Object? prioritizeFollowedUsers = null,}) {
  return _then(_ThreadViewPref(
sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as ThreadSortOrder,prioritizeFollowedUsers: null == prioritizeFollowedUsers ? _self.prioritizeFollowedUsers : prioritizeFollowedUsers // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MutedWord {

 String get id; String get value; List<MutedWordTarget> get targets; MutedWordActorTarget get actorTarget;@JsonKey(includeIfNull: false) DateTime? get expiresAt;
/// Create a copy of MutedWord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MutedWordCopyWith<MutedWord> get copyWith => _$MutedWordCopyWithImpl<MutedWord>(this as MutedWord, _$identity);

  /// Serializes this MutedWord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MutedWord&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value)&&const DeepCollectionEquality().equals(other.targets, targets)&&(identical(other.actorTarget, actorTarget) || other.actorTarget == actorTarget)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value,const DeepCollectionEquality().hash(targets),actorTarget,expiresAt);

@override
String toString() {
  return 'MutedWord(id: $id, value: $value, targets: $targets, actorTarget: $actorTarget, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $MutedWordCopyWith<$Res>  {
  factory $MutedWordCopyWith(MutedWord value, $Res Function(MutedWord) _then) = _$MutedWordCopyWithImpl;
@useResult
$Res call({
 String id, String value, List<MutedWordTarget> targets, MutedWordActorTarget actorTarget,@JsonKey(includeIfNull: false) DateTime? expiresAt
});




}
/// @nodoc
class _$MutedWordCopyWithImpl<$Res>
    implements $MutedWordCopyWith<$Res> {
  _$MutedWordCopyWithImpl(this._self, this._then);

  final MutedWord _self;
  final $Res Function(MutedWord) _then;

/// Create a copy of MutedWord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? value = null,Object? targets = null,Object? actorTarget = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,targets: null == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as List<MutedWordTarget>,actorTarget: null == actorTarget ? _self.actorTarget : actorTarget // ignore: cast_nullable_to_non_nullable
as MutedWordActorTarget,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MutedWord].
extension MutedWordPatterns on MutedWord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MutedWord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MutedWord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MutedWord value)  $default,){
final _that = this;
switch (_that) {
case _MutedWord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MutedWord value)?  $default,){
final _that = this;
switch (_that) {
case _MutedWord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String value,  List<MutedWordTarget> targets,  MutedWordActorTarget actorTarget, @JsonKey(includeIfNull: false)  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MutedWord() when $default != null:
return $default(_that.id,_that.value,_that.targets,_that.actorTarget,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String value,  List<MutedWordTarget> targets,  MutedWordActorTarget actorTarget, @JsonKey(includeIfNull: false)  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _MutedWord():
return $default(_that.id,_that.value,_that.targets,_that.actorTarget,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String value,  List<MutedWordTarget> targets,  MutedWordActorTarget actorTarget, @JsonKey(includeIfNull: false)  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _MutedWord() when $default != null:
return $default(_that.id,_that.value,_that.targets,_that.actorTarget,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MutedWord extends MutedWord {
  const _MutedWord({required this.id, required this.value, required final  List<MutedWordTarget> targets, this.actorTarget = MutedWordActorTarget.all, @JsonKey(includeIfNull: false) this.expiresAt}): _targets = targets,super._();
  factory _MutedWord.fromJson(Map<String, dynamic> json) => _$MutedWordFromJson(json);

@override final  String id;
@override final  String value;
 final  List<MutedWordTarget> _targets;
@override List<MutedWordTarget> get targets {
  if (_targets is EqualUnmodifiableListView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targets);
}

@override@JsonKey() final  MutedWordActorTarget actorTarget;
@override@JsonKey(includeIfNull: false) final  DateTime? expiresAt;

/// Create a copy of MutedWord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MutedWordCopyWith<_MutedWord> get copyWith => __$MutedWordCopyWithImpl<_MutedWord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MutedWordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MutedWord&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value)&&const DeepCollectionEquality().equals(other._targets, _targets)&&(identical(other.actorTarget, actorTarget) || other.actorTarget == actorTarget)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value,const DeepCollectionEquality().hash(_targets),actorTarget,expiresAt);

@override
String toString() {
  return 'MutedWord(id: $id, value: $value, targets: $targets, actorTarget: $actorTarget, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$MutedWordCopyWith<$Res> implements $MutedWordCopyWith<$Res> {
  factory _$MutedWordCopyWith(_MutedWord value, $Res Function(_MutedWord) _then) = __$MutedWordCopyWithImpl;
@override @useResult
$Res call({
 String id, String value, List<MutedWordTarget> targets, MutedWordActorTarget actorTarget,@JsonKey(includeIfNull: false) DateTime? expiresAt
});




}
/// @nodoc
class __$MutedWordCopyWithImpl<$Res>
    implements _$MutedWordCopyWith<$Res> {
  __$MutedWordCopyWithImpl(this._self, this._then);

  final _MutedWord _self;
  final $Res Function(_MutedWord) _then;

/// Create a copy of MutedWord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? value = null,Object? targets = null,Object? actorTarget = null,Object? expiresAt = freezed,}) {
  return _then(_MutedWord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as List<MutedWordTarget>,actorTarget: null == actorTarget ? _self.actorTarget : actorTarget // ignore: cast_nullable_to_non_nullable
as MutedWordActorTarget,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MutedWordsPref {

 List<MutedWord> get items;
/// Create a copy of MutedWordsPref
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MutedWordsPrefCopyWith<MutedWordsPref> get copyWith => _$MutedWordsPrefCopyWithImpl<MutedWordsPref>(this as MutedWordsPref, _$identity);

  /// Serializes this MutedWordsPref to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MutedWordsPref&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MutedWordsPref(items: $items)';
}


}

/// @nodoc
abstract mixin class $MutedWordsPrefCopyWith<$Res>  {
  factory $MutedWordsPrefCopyWith(MutedWordsPref value, $Res Function(MutedWordsPref) _then) = _$MutedWordsPrefCopyWithImpl;
@useResult
$Res call({
 List<MutedWord> items
});




}
/// @nodoc
class _$MutedWordsPrefCopyWithImpl<$Res>
    implements $MutedWordsPrefCopyWith<$Res> {
  _$MutedWordsPrefCopyWithImpl(this._self, this._then);

  final MutedWordsPref _self;
  final $Res Function(MutedWordsPref) _then;

/// Create a copy of MutedWordsPref
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MutedWord>,
  ));
}

}


/// Adds pattern-matching-related methods to [MutedWordsPref].
extension MutedWordsPrefPatterns on MutedWordsPref {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MutedWordsPref value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MutedWordsPref() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MutedWordsPref value)  $default,){
final _that = this;
switch (_that) {
case _MutedWordsPref():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MutedWordsPref value)?  $default,){
final _that = this;
switch (_that) {
case _MutedWordsPref() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MutedWord> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MutedWordsPref() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MutedWord> items)  $default,) {final _that = this;
switch (_that) {
case _MutedWordsPref():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MutedWord> items)?  $default,) {final _that = this;
switch (_that) {
case _MutedWordsPref() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MutedWordsPref extends MutedWordsPref {
  const _MutedWordsPref({final  List<MutedWord> items = const []}): _items = items,super._();
  factory _MutedWordsPref.fromJson(Map<String, dynamic> json) => _$MutedWordsPrefFromJson(json);

 final  List<MutedWord> _items;
@override@JsonKey() List<MutedWord> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MutedWordsPref
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MutedWordsPrefCopyWith<_MutedWordsPref> get copyWith => __$MutedWordsPrefCopyWithImpl<_MutedWordsPref>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MutedWordsPrefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MutedWordsPref&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MutedWordsPref(items: $items)';
}


}

/// @nodoc
abstract mixin class _$MutedWordsPrefCopyWith<$Res> implements $MutedWordsPrefCopyWith<$Res> {
  factory _$MutedWordsPrefCopyWith(_MutedWordsPref value, $Res Function(_MutedWordsPref) _then) = __$MutedWordsPrefCopyWithImpl;
@override @useResult
$Res call({
 List<MutedWord> items
});




}
/// @nodoc
class __$MutedWordsPrefCopyWithImpl<$Res>
    implements _$MutedWordsPrefCopyWith<$Res> {
  __$MutedWordsPrefCopyWithImpl(this._self, this._then);

  final _MutedWordsPref _self;
  final $Res Function(_MutedWordsPref) _then;

/// Create a copy of MutedWordsPref
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_MutedWordsPref(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MutedWord>,
  ));
}


}

// dart format on
