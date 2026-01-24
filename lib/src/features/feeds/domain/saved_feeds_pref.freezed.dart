// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_feeds_pref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedFeedItem {

 String get value; bool get pinned; String get id;
/// Create a copy of SavedFeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedFeedItemCopyWith<SavedFeedItem> get copyWith => _$SavedFeedItemCopyWithImpl<SavedFeedItem>(this as SavedFeedItem, _$identity);

  /// Serializes this SavedFeedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedFeedItem&&(identical(other.value, value) || other.value == value)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,pinned,id);

@override
String toString() {
  return 'SavedFeedItem(value: $value, pinned: $pinned, id: $id)';
}


}

/// @nodoc
abstract mixin class $SavedFeedItemCopyWith<$Res>  {
  factory $SavedFeedItemCopyWith(SavedFeedItem value, $Res Function(SavedFeedItem) _then) = _$SavedFeedItemCopyWithImpl;
@useResult
$Res call({
 String value, bool pinned, String id
});




}
/// @nodoc
class _$SavedFeedItemCopyWithImpl<$Res>
    implements $SavedFeedItemCopyWith<$Res> {
  _$SavedFeedItemCopyWithImpl(this._self, this._then);

  final SavedFeedItem _self;
  final $Res Function(SavedFeedItem) _then;

/// Create a copy of SavedFeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? pinned = null,Object? id = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedFeedItem].
extension SavedFeedItemPatterns on SavedFeedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedFeedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedFeedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedFeedItem value)  $default,){
final _that = this;
switch (_that) {
case _SavedFeedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedFeedItem value)?  $default,){
final _that = this;
switch (_that) {
case _SavedFeedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  bool pinned,  String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedFeedItem() when $default != null:
return $default(_that.value,_that.pinned,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  bool pinned,  String id)  $default,) {final _that = this;
switch (_that) {
case _SavedFeedItem():
return $default(_that.value,_that.pinned,_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  bool pinned,  String id)?  $default,) {final _that = this;
switch (_that) {
case _SavedFeedItem() when $default != null:
return $default(_that.value,_that.pinned,_that.id);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SavedFeedItem implements SavedFeedItem {
  const _SavedFeedItem({required this.value, this.pinned = false, required this.id});
  factory _SavedFeedItem.fromJson(Map<String, dynamic> json) => _$SavedFeedItemFromJson(json);

@override final  String value;
@override@JsonKey() final  bool pinned;
@override final  String id;

/// Create a copy of SavedFeedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedFeedItemCopyWith<_SavedFeedItem> get copyWith => __$SavedFeedItemCopyWithImpl<_SavedFeedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedFeedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedFeedItem&&(identical(other.value, value) || other.value == value)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,pinned,id);

@override
String toString() {
  return 'SavedFeedItem(value: $value, pinned: $pinned, id: $id)';
}


}

/// @nodoc
abstract mixin class _$SavedFeedItemCopyWith<$Res> implements $SavedFeedItemCopyWith<$Res> {
  factory _$SavedFeedItemCopyWith(_SavedFeedItem value, $Res Function(_SavedFeedItem) _then) = __$SavedFeedItemCopyWithImpl;
@override @useResult
$Res call({
 String value, bool pinned, String id
});




}
/// @nodoc
class __$SavedFeedItemCopyWithImpl<$Res>
    implements _$SavedFeedItemCopyWith<$Res> {
  __$SavedFeedItemCopyWithImpl(this._self, this._then);

  final _SavedFeedItem _self;
  final $Res Function(_SavedFeedItem) _then;

/// Create a copy of SavedFeedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? pinned = null,Object? id = null,}) {
  return _then(_SavedFeedItem(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SavedFeedsPrefV2 {

@JsonKey(name: r'$type') String get type; List<SavedFeedItem> get items;
/// Create a copy of SavedFeedsPrefV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedFeedsPrefV2CopyWith<SavedFeedsPrefV2> get copyWith => _$SavedFeedsPrefV2CopyWithImpl<SavedFeedsPrefV2>(this as SavedFeedsPrefV2, _$identity);

  /// Serializes this SavedFeedsPrefV2 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedFeedsPrefV2&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'SavedFeedsPrefV2(type: $type, items: $items)';
}


}

/// @nodoc
abstract mixin class $SavedFeedsPrefV2CopyWith<$Res>  {
  factory $SavedFeedsPrefV2CopyWith(SavedFeedsPrefV2 value, $Res Function(SavedFeedsPrefV2) _then) = _$SavedFeedsPrefV2CopyWithImpl;
@useResult
$Res call({
@JsonKey(name: r'$type') String type, List<SavedFeedItem> items
});




}
/// @nodoc
class _$SavedFeedsPrefV2CopyWithImpl<$Res>
    implements $SavedFeedsPrefV2CopyWith<$Res> {
  _$SavedFeedsPrefV2CopyWithImpl(this._self, this._then);

  final SavedFeedsPrefV2 _self;
  final $Res Function(SavedFeedsPrefV2) _then;

/// Create a copy of SavedFeedsPrefV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? items = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SavedFeedItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedFeedsPrefV2].
extension SavedFeedsPrefV2Patterns on SavedFeedsPrefV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedFeedsPrefV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedFeedsPrefV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedFeedsPrefV2 value)  $default,){
final _that = this;
switch (_that) {
case _SavedFeedsPrefV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedFeedsPrefV2 value)?  $default,){
final _that = this;
switch (_that) {
case _SavedFeedsPrefV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: r'$type')  String type,  List<SavedFeedItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedFeedsPrefV2() when $default != null:
return $default(_that.type,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: r'$type')  String type,  List<SavedFeedItem> items)  $default,) {final _that = this;
switch (_that) {
case _SavedFeedsPrefV2():
return $default(_that.type,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: r'$type')  String type,  List<SavedFeedItem> items)?  $default,) {final _that = this;
switch (_that) {
case _SavedFeedsPrefV2() when $default != null:
return $default(_that.type,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SavedFeedsPrefV2 extends SavedFeedsPrefV2 {
  const _SavedFeedsPrefV2({@JsonKey(name: r'$type') this.type = 'app.bsky.actor.defs#savedFeedsPrefV2', required final  List<SavedFeedItem> items}): _items = items,super._();
  factory _SavedFeedsPrefV2.fromJson(Map<String, dynamic> json) => _$SavedFeedsPrefV2FromJson(json);

@override@JsonKey(name: r'$type') final  String type;
 final  List<SavedFeedItem> _items;
@override List<SavedFeedItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of SavedFeedsPrefV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedFeedsPrefV2CopyWith<_SavedFeedsPrefV2> get copyWith => __$SavedFeedsPrefV2CopyWithImpl<_SavedFeedsPrefV2>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedFeedsPrefV2ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedFeedsPrefV2&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'SavedFeedsPrefV2(type: $type, items: $items)';
}


}

/// @nodoc
abstract mixin class _$SavedFeedsPrefV2CopyWith<$Res> implements $SavedFeedsPrefV2CopyWith<$Res> {
  factory _$SavedFeedsPrefV2CopyWith(_SavedFeedsPrefV2 value, $Res Function(_SavedFeedsPrefV2) _then) = __$SavedFeedsPrefV2CopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: r'$type') String type, List<SavedFeedItem> items
});




}
/// @nodoc
class __$SavedFeedsPrefV2CopyWithImpl<$Res>
    implements _$SavedFeedsPrefV2CopyWith<$Res> {
  __$SavedFeedsPrefV2CopyWithImpl(this._self, this._then);

  final _SavedFeedsPrefV2 _self;
  final $Res Function(_SavedFeedsPrefV2) _then;

/// Create a copy of SavedFeedsPrefV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? items = null,}) {
  return _then(_SavedFeedsPrefV2(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SavedFeedItem>,
  ));
}


}


/// @nodoc
mixin _$SavedFeedsPref {

@JsonKey(name: r'$type') String get type; List<String> get saved; List<String> get pinned;
/// Create a copy of SavedFeedsPref
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedFeedsPrefCopyWith<SavedFeedsPref> get copyWith => _$SavedFeedsPrefCopyWithImpl<SavedFeedsPref>(this as SavedFeedsPref, _$identity);

  /// Serializes this SavedFeedsPref to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedFeedsPref&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.saved, saved)&&const DeepCollectionEquality().equals(other.pinned, pinned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(saved),const DeepCollectionEquality().hash(pinned));

@override
String toString() {
  return 'SavedFeedsPref(type: $type, saved: $saved, pinned: $pinned)';
}


}

/// @nodoc
abstract mixin class $SavedFeedsPrefCopyWith<$Res>  {
  factory $SavedFeedsPrefCopyWith(SavedFeedsPref value, $Res Function(SavedFeedsPref) _then) = _$SavedFeedsPrefCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: r'$type') String type, List<String> saved, List<String> pinned
});




}
/// @nodoc
class _$SavedFeedsPrefCopyWithImpl<$Res>
    implements $SavedFeedsPrefCopyWith<$Res> {
  _$SavedFeedsPrefCopyWithImpl(this._self, this._then);

  final SavedFeedsPref _self;
  final $Res Function(SavedFeedsPref) _then;

/// Create a copy of SavedFeedsPref
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? saved = null,Object? pinned = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as List<String>,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedFeedsPref].
extension SavedFeedsPrefPatterns on SavedFeedsPref {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedFeedsPref value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedFeedsPref() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedFeedsPref value)  $default,){
final _that = this;
switch (_that) {
case _SavedFeedsPref():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedFeedsPref value)?  $default,){
final _that = this;
switch (_that) {
case _SavedFeedsPref() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: r'$type')  String type,  List<String> saved,  List<String> pinned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedFeedsPref() when $default != null:
return $default(_that.type,_that.saved,_that.pinned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: r'$type')  String type,  List<String> saved,  List<String> pinned)  $default,) {final _that = this;
switch (_that) {
case _SavedFeedsPref():
return $default(_that.type,_that.saved,_that.pinned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: r'$type')  String type,  List<String> saved,  List<String> pinned)?  $default,) {final _that = this;
switch (_that) {
case _SavedFeedsPref() when $default != null:
return $default(_that.type,_that.saved,_that.pinned);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SavedFeedsPref extends SavedFeedsPref {
  const _SavedFeedsPref({@JsonKey(name: r'$type') this.type = 'app.bsky.actor.defs#savedFeedsPref', final  List<String> saved = const [], final  List<String> pinned = const []}): _saved = saved,_pinned = pinned,super._();
  factory _SavedFeedsPref.fromJson(Map<String, dynamic> json) => _$SavedFeedsPrefFromJson(json);

@override@JsonKey(name: r'$type') final  String type;
 final  List<String> _saved;
@override@JsonKey() List<String> get saved {
  if (_saved is EqualUnmodifiableListView) return _saved;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_saved);
}

 final  List<String> _pinned;
@override@JsonKey() List<String> get pinned {
  if (_pinned is EqualUnmodifiableListView) return _pinned;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pinned);
}


/// Create a copy of SavedFeedsPref
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedFeedsPrefCopyWith<_SavedFeedsPref> get copyWith => __$SavedFeedsPrefCopyWithImpl<_SavedFeedsPref>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedFeedsPrefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedFeedsPref&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._saved, _saved)&&const DeepCollectionEquality().equals(other._pinned, _pinned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_saved),const DeepCollectionEquality().hash(_pinned));

@override
String toString() {
  return 'SavedFeedsPref(type: $type, saved: $saved, pinned: $pinned)';
}


}

/// @nodoc
abstract mixin class _$SavedFeedsPrefCopyWith<$Res> implements $SavedFeedsPrefCopyWith<$Res> {
  factory _$SavedFeedsPrefCopyWith(_SavedFeedsPref value, $Res Function(_SavedFeedsPref) _then) = __$SavedFeedsPrefCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: r'$type') String type, List<String> saved, List<String> pinned
});




}
/// @nodoc
class __$SavedFeedsPrefCopyWithImpl<$Res>
    implements _$SavedFeedsPrefCopyWith<$Res> {
  __$SavedFeedsPrefCopyWithImpl(this._self, this._then);

  final _SavedFeedsPref _self;
  final $Res Function(_SavedFeedsPref) _then;

/// Create a copy of SavedFeedsPref
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? saved = null,Object? pinned = null,}) {
  return _then(_SavedFeedsPref(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,saved: null == saved ? _self._saved : saved // ignore: cast_nullable_to_non_nullable
as List<String>,pinned: null == pinned ? _self._pinned : pinned // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
