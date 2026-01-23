// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Draft {

 String get id; String get text; DraftStatus get status; DateTime get createdAt; DateTime get updatedAt; List<DraftMediaAttachment> get media; String? get replyParentUri; String? get replyParentCid; String? get replyRootUri; String? get replyRootCid; String? get quoteUri; String? get quoteCid; String? get facetsJson; String? get externalUri; String? get externalTitle; String? get externalDescription; String? get externalThumbBlobJson; String? get errorMessage; List<String> get langs; List<String> get labels; ThreadGateType? get threadGateType; bool get quoteDisabled;
/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftCopyWith<Draft> get copyWith => _$DraftCopyWithImpl<Draft>(this as Draft, _$identity);

  /// Serializes this Draft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Draft&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.media, media)&&(identical(other.replyParentUri, replyParentUri) || other.replyParentUri == replyParentUri)&&(identical(other.replyParentCid, replyParentCid) || other.replyParentCid == replyParentCid)&&(identical(other.replyRootUri, replyRootUri) || other.replyRootUri == replyRootUri)&&(identical(other.replyRootCid, replyRootCid) || other.replyRootCid == replyRootCid)&&(identical(other.quoteUri, quoteUri) || other.quoteUri == quoteUri)&&(identical(other.quoteCid, quoteCid) || other.quoteCid == quoteCid)&&(identical(other.facetsJson, facetsJson) || other.facetsJson == facetsJson)&&(identical(other.externalUri, externalUri) || other.externalUri == externalUri)&&(identical(other.externalTitle, externalTitle) || other.externalTitle == externalTitle)&&(identical(other.externalDescription, externalDescription) || other.externalDescription == externalDescription)&&(identical(other.externalThumbBlobJson, externalThumbBlobJson) || other.externalThumbBlobJson == externalThumbBlobJson)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.langs, langs)&&const DeepCollectionEquality().equals(other.labels, labels)&&(identical(other.threadGateType, threadGateType) || other.threadGateType == threadGateType)&&(identical(other.quoteDisabled, quoteDisabled) || other.quoteDisabled == quoteDisabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,text,status,createdAt,updatedAt,const DeepCollectionEquality().hash(media),replyParentUri,replyParentCid,replyRootUri,replyRootCid,quoteUri,quoteCid,facetsJson,externalUri,externalTitle,externalDescription,externalThumbBlobJson,errorMessage,const DeepCollectionEquality().hash(langs),const DeepCollectionEquality().hash(labels),threadGateType,quoteDisabled]);

@override
String toString() {
  return 'Draft(id: $id, text: $text, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, media: $media, replyParentUri: $replyParentUri, replyParentCid: $replyParentCid, replyRootUri: $replyRootUri, replyRootCid: $replyRootCid, quoteUri: $quoteUri, quoteCid: $quoteCid, facetsJson: $facetsJson, externalUri: $externalUri, externalTitle: $externalTitle, externalDescription: $externalDescription, externalThumbBlobJson: $externalThumbBlobJson, errorMessage: $errorMessage, langs: $langs, labels: $labels, threadGateType: $threadGateType, quoteDisabled: $quoteDisabled)';
}


}

/// @nodoc
abstract mixin class $DraftCopyWith<$Res>  {
  factory $DraftCopyWith(Draft value, $Res Function(Draft) _then) = _$DraftCopyWithImpl;
@useResult
$Res call({
 String id, String text, DraftStatus status, DateTime createdAt, DateTime updatedAt, List<DraftMediaAttachment> media, String? replyParentUri, String? replyParentCid, String? replyRootUri, String? replyRootCid, String? quoteUri, String? quoteCid, String? facetsJson, String? externalUri, String? externalTitle, String? externalDescription, String? externalThumbBlobJson, String? errorMessage, List<String> langs, List<String> labels, ThreadGateType? threadGateType, bool quoteDisabled
});




}
/// @nodoc
class _$DraftCopyWithImpl<$Res>
    implements $DraftCopyWith<$Res> {
  _$DraftCopyWithImpl(this._self, this._then);

  final Draft _self;
  final $Res Function(Draft) _then;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? media = null,Object? replyParentUri = freezed,Object? replyParentCid = freezed,Object? replyRootUri = freezed,Object? replyRootCid = freezed,Object? quoteUri = freezed,Object? quoteCid = freezed,Object? facetsJson = freezed,Object? externalUri = freezed,Object? externalTitle = freezed,Object? externalDescription = freezed,Object? externalThumbBlobJson = freezed,Object? errorMessage = freezed,Object? langs = null,Object? labels = null,Object? threadGateType = freezed,Object? quoteDisabled = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DraftStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<DraftMediaAttachment>,replyParentUri: freezed == replyParentUri ? _self.replyParentUri : replyParentUri // ignore: cast_nullable_to_non_nullable
as String?,replyParentCid: freezed == replyParentCid ? _self.replyParentCid : replyParentCid // ignore: cast_nullable_to_non_nullable
as String?,replyRootUri: freezed == replyRootUri ? _self.replyRootUri : replyRootUri // ignore: cast_nullable_to_non_nullable
as String?,replyRootCid: freezed == replyRootCid ? _self.replyRootCid : replyRootCid // ignore: cast_nullable_to_non_nullable
as String?,quoteUri: freezed == quoteUri ? _self.quoteUri : quoteUri // ignore: cast_nullable_to_non_nullable
as String?,quoteCid: freezed == quoteCid ? _self.quoteCid : quoteCid // ignore: cast_nullable_to_non_nullable
as String?,facetsJson: freezed == facetsJson ? _self.facetsJson : facetsJson // ignore: cast_nullable_to_non_nullable
as String?,externalUri: freezed == externalUri ? _self.externalUri : externalUri // ignore: cast_nullable_to_non_nullable
as String?,externalTitle: freezed == externalTitle ? _self.externalTitle : externalTitle // ignore: cast_nullable_to_non_nullable
as String?,externalDescription: freezed == externalDescription ? _self.externalDescription : externalDescription // ignore: cast_nullable_to_non_nullable
as String?,externalThumbBlobJson: freezed == externalThumbBlobJson ? _self.externalThumbBlobJson : externalThumbBlobJson // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,langs: null == langs ? _self.langs : langs // ignore: cast_nullable_to_non_nullable
as List<String>,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,threadGateType: freezed == threadGateType ? _self.threadGateType : threadGateType // ignore: cast_nullable_to_non_nullable
as ThreadGateType?,quoteDisabled: null == quoteDisabled ? _self.quoteDisabled : quoteDisabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Draft].
extension DraftPatterns on Draft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Draft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Draft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Draft value)  $default,){
final _that = this;
switch (_that) {
case _Draft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Draft value)?  $default,){
final _that = this;
switch (_that) {
case _Draft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  DraftStatus status,  DateTime createdAt,  DateTime updatedAt,  List<DraftMediaAttachment> media,  String? replyParentUri,  String? replyParentCid,  String? replyRootUri,  String? replyRootCid,  String? quoteUri,  String? quoteCid,  String? facetsJson,  String? externalUri,  String? externalTitle,  String? externalDescription,  String? externalThumbBlobJson,  String? errorMessage,  List<String> langs,  List<String> labels,  ThreadGateType? threadGateType,  bool quoteDisabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that.id,_that.text,_that.status,_that.createdAt,_that.updatedAt,_that.media,_that.replyParentUri,_that.replyParentCid,_that.replyRootUri,_that.replyRootCid,_that.quoteUri,_that.quoteCid,_that.facetsJson,_that.externalUri,_that.externalTitle,_that.externalDescription,_that.externalThumbBlobJson,_that.errorMessage,_that.langs,_that.labels,_that.threadGateType,_that.quoteDisabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  DraftStatus status,  DateTime createdAt,  DateTime updatedAt,  List<DraftMediaAttachment> media,  String? replyParentUri,  String? replyParentCid,  String? replyRootUri,  String? replyRootCid,  String? quoteUri,  String? quoteCid,  String? facetsJson,  String? externalUri,  String? externalTitle,  String? externalDescription,  String? externalThumbBlobJson,  String? errorMessage,  List<String> langs,  List<String> labels,  ThreadGateType? threadGateType,  bool quoteDisabled)  $default,) {final _that = this;
switch (_that) {
case _Draft():
return $default(_that.id,_that.text,_that.status,_that.createdAt,_that.updatedAt,_that.media,_that.replyParentUri,_that.replyParentCid,_that.replyRootUri,_that.replyRootCid,_that.quoteUri,_that.quoteCid,_that.facetsJson,_that.externalUri,_that.externalTitle,_that.externalDescription,_that.externalThumbBlobJson,_that.errorMessage,_that.langs,_that.labels,_that.threadGateType,_that.quoteDisabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  DraftStatus status,  DateTime createdAt,  DateTime updatedAt,  List<DraftMediaAttachment> media,  String? replyParentUri,  String? replyParentCid,  String? replyRootUri,  String? replyRootCid,  String? quoteUri,  String? quoteCid,  String? facetsJson,  String? externalUri,  String? externalTitle,  String? externalDescription,  String? externalThumbBlobJson,  String? errorMessage,  List<String> langs,  List<String> labels,  ThreadGateType? threadGateType,  bool quoteDisabled)?  $default,) {final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that.id,_that.text,_that.status,_that.createdAt,_that.updatedAt,_that.media,_that.replyParentUri,_that.replyParentCid,_that.replyRootUri,_that.replyRootCid,_that.quoteUri,_that.quoteCid,_that.facetsJson,_that.externalUri,_that.externalTitle,_that.externalDescription,_that.externalThumbBlobJson,_that.errorMessage,_that.langs,_that.labels,_that.threadGateType,_that.quoteDisabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Draft extends Draft {
  const _Draft({required this.id, required this.text, required this.status, required this.createdAt, required this.updatedAt, required final  List<DraftMediaAttachment> media, this.replyParentUri, this.replyParentCid, this.replyRootUri, this.replyRootCid, this.quoteUri, this.quoteCid, this.facetsJson, this.externalUri, this.externalTitle, this.externalDescription, this.externalThumbBlobJson, this.errorMessage, final  List<String> langs = const [], final  List<String> labels = const [], this.threadGateType, this.quoteDisabled = false}): _media = media,_langs = langs,_labels = labels,super._();
  factory _Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);

@override final  String id;
@override final  String text;
@override final  DraftStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<DraftMediaAttachment> _media;
@override List<DraftMediaAttachment> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}

@override final  String? replyParentUri;
@override final  String? replyParentCid;
@override final  String? replyRootUri;
@override final  String? replyRootCid;
@override final  String? quoteUri;
@override final  String? quoteCid;
@override final  String? facetsJson;
@override final  String? externalUri;
@override final  String? externalTitle;
@override final  String? externalDescription;
@override final  String? externalThumbBlobJson;
@override final  String? errorMessage;
 final  List<String> _langs;
@override@JsonKey() List<String> get langs {
  if (_langs is EqualUnmodifiableListView) return _langs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_langs);
}

 final  List<String> _labels;
@override@JsonKey() List<String> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

@override final  ThreadGateType? threadGateType;
@override@JsonKey() final  bool quoteDisabled;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftCopyWith<_Draft> get copyWith => __$DraftCopyWithImpl<_Draft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Draft&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._media, _media)&&(identical(other.replyParentUri, replyParentUri) || other.replyParentUri == replyParentUri)&&(identical(other.replyParentCid, replyParentCid) || other.replyParentCid == replyParentCid)&&(identical(other.replyRootUri, replyRootUri) || other.replyRootUri == replyRootUri)&&(identical(other.replyRootCid, replyRootCid) || other.replyRootCid == replyRootCid)&&(identical(other.quoteUri, quoteUri) || other.quoteUri == quoteUri)&&(identical(other.quoteCid, quoteCid) || other.quoteCid == quoteCid)&&(identical(other.facetsJson, facetsJson) || other.facetsJson == facetsJson)&&(identical(other.externalUri, externalUri) || other.externalUri == externalUri)&&(identical(other.externalTitle, externalTitle) || other.externalTitle == externalTitle)&&(identical(other.externalDescription, externalDescription) || other.externalDescription == externalDescription)&&(identical(other.externalThumbBlobJson, externalThumbBlobJson) || other.externalThumbBlobJson == externalThumbBlobJson)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._langs, _langs)&&const DeepCollectionEquality().equals(other._labels, _labels)&&(identical(other.threadGateType, threadGateType) || other.threadGateType == threadGateType)&&(identical(other.quoteDisabled, quoteDisabled) || other.quoteDisabled == quoteDisabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,text,status,createdAt,updatedAt,const DeepCollectionEquality().hash(_media),replyParentUri,replyParentCid,replyRootUri,replyRootCid,quoteUri,quoteCid,facetsJson,externalUri,externalTitle,externalDescription,externalThumbBlobJson,errorMessage,const DeepCollectionEquality().hash(_langs),const DeepCollectionEquality().hash(_labels),threadGateType,quoteDisabled]);

@override
String toString() {
  return 'Draft(id: $id, text: $text, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, media: $media, replyParentUri: $replyParentUri, replyParentCid: $replyParentCid, replyRootUri: $replyRootUri, replyRootCid: $replyRootCid, quoteUri: $quoteUri, quoteCid: $quoteCid, facetsJson: $facetsJson, externalUri: $externalUri, externalTitle: $externalTitle, externalDescription: $externalDescription, externalThumbBlobJson: $externalThumbBlobJson, errorMessage: $errorMessage, langs: $langs, labels: $labels, threadGateType: $threadGateType, quoteDisabled: $quoteDisabled)';
}


}

/// @nodoc
abstract mixin class _$DraftCopyWith<$Res> implements $DraftCopyWith<$Res> {
  factory _$DraftCopyWith(_Draft value, $Res Function(_Draft) _then) = __$DraftCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, DraftStatus status, DateTime createdAt, DateTime updatedAt, List<DraftMediaAttachment> media, String? replyParentUri, String? replyParentCid, String? replyRootUri, String? replyRootCid, String? quoteUri, String? quoteCid, String? facetsJson, String? externalUri, String? externalTitle, String? externalDescription, String? externalThumbBlobJson, String? errorMessage, List<String> langs, List<String> labels, ThreadGateType? threadGateType, bool quoteDisabled
});




}
/// @nodoc
class __$DraftCopyWithImpl<$Res>
    implements _$DraftCopyWith<$Res> {
  __$DraftCopyWithImpl(this._self, this._then);

  final _Draft _self;
  final $Res Function(_Draft) _then;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? media = null,Object? replyParentUri = freezed,Object? replyParentCid = freezed,Object? replyRootUri = freezed,Object? replyRootCid = freezed,Object? quoteUri = freezed,Object? quoteCid = freezed,Object? facetsJson = freezed,Object? externalUri = freezed,Object? externalTitle = freezed,Object? externalDescription = freezed,Object? externalThumbBlobJson = freezed,Object? errorMessage = freezed,Object? langs = null,Object? labels = null,Object? threadGateType = freezed,Object? quoteDisabled = null,}) {
  return _then(_Draft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DraftStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<DraftMediaAttachment>,replyParentUri: freezed == replyParentUri ? _self.replyParentUri : replyParentUri // ignore: cast_nullable_to_non_nullable
as String?,replyParentCid: freezed == replyParentCid ? _self.replyParentCid : replyParentCid // ignore: cast_nullable_to_non_nullable
as String?,replyRootUri: freezed == replyRootUri ? _self.replyRootUri : replyRootUri // ignore: cast_nullable_to_non_nullable
as String?,replyRootCid: freezed == replyRootCid ? _self.replyRootCid : replyRootCid // ignore: cast_nullable_to_non_nullable
as String?,quoteUri: freezed == quoteUri ? _self.quoteUri : quoteUri // ignore: cast_nullable_to_non_nullable
as String?,quoteCid: freezed == quoteCid ? _self.quoteCid : quoteCid // ignore: cast_nullable_to_non_nullable
as String?,facetsJson: freezed == facetsJson ? _self.facetsJson : facetsJson // ignore: cast_nullable_to_non_nullable
as String?,externalUri: freezed == externalUri ? _self.externalUri : externalUri // ignore: cast_nullable_to_non_nullable
as String?,externalTitle: freezed == externalTitle ? _self.externalTitle : externalTitle // ignore: cast_nullable_to_non_nullable
as String?,externalDescription: freezed == externalDescription ? _self.externalDescription : externalDescription // ignore: cast_nullable_to_non_nullable
as String?,externalThumbBlobJson: freezed == externalThumbBlobJson ? _self.externalThumbBlobJson : externalThumbBlobJson // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,langs: null == langs ? _self._langs : langs // ignore: cast_nullable_to_non_nullable
as List<String>,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<String>,threadGateType: freezed == threadGateType ? _self.threadGateType : threadGateType // ignore: cast_nullable_to_non_nullable
as ThreadGateType?,quoteDisabled: null == quoteDisabled ? _self.quoteDisabled : quoteDisabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DraftMediaAttachment {

 int get id; String get draftId; String get localPath; String get mimeType; DraftMediaStatus get status; int get sortOrder; String? get altText; String? get uploadCid; String? get blobRefJson; int? get durationSeconds; String? get aspectRatio;
/// Create a copy of DraftMediaAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftMediaAttachmentCopyWith<DraftMediaAttachment> get copyWith => _$DraftMediaAttachmentCopyWithImpl<DraftMediaAttachment>(this as DraftMediaAttachment, _$identity);

  /// Serializes this DraftMediaAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftMediaAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.draftId, draftId) || other.draftId == draftId)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.status, status) || other.status == status)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.uploadCid, uploadCid) || other.uploadCid == uploadCid)&&(identical(other.blobRefJson, blobRefJson) || other.blobRefJson == blobRefJson)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,draftId,localPath,mimeType,status,sortOrder,altText,uploadCid,blobRefJson,durationSeconds,aspectRatio);

@override
String toString() {
  return 'DraftMediaAttachment(id: $id, draftId: $draftId, localPath: $localPath, mimeType: $mimeType, status: $status, sortOrder: $sortOrder, altText: $altText, uploadCid: $uploadCid, blobRefJson: $blobRefJson, durationSeconds: $durationSeconds, aspectRatio: $aspectRatio)';
}


}

/// @nodoc
abstract mixin class $DraftMediaAttachmentCopyWith<$Res>  {
  factory $DraftMediaAttachmentCopyWith(DraftMediaAttachment value, $Res Function(DraftMediaAttachment) _then) = _$DraftMediaAttachmentCopyWithImpl;
@useResult
$Res call({
 int id, String draftId, String localPath, String mimeType, DraftMediaStatus status, int sortOrder, String? altText, String? uploadCid, String? blobRefJson, int? durationSeconds, String? aspectRatio
});




}
/// @nodoc
class _$DraftMediaAttachmentCopyWithImpl<$Res>
    implements $DraftMediaAttachmentCopyWith<$Res> {
  _$DraftMediaAttachmentCopyWithImpl(this._self, this._then);

  final DraftMediaAttachment _self;
  final $Res Function(DraftMediaAttachment) _then;

/// Create a copy of DraftMediaAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? draftId = null,Object? localPath = null,Object? mimeType = null,Object? status = null,Object? sortOrder = null,Object? altText = freezed,Object? uploadCid = freezed,Object? blobRefJson = freezed,Object? durationSeconds = freezed,Object? aspectRatio = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,draftId: null == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DraftMediaStatus,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,uploadCid: freezed == uploadCid ? _self.uploadCid : uploadCid // ignore: cast_nullable_to_non_nullable
as String?,blobRefJson: freezed == blobRefJson ? _self.blobRefJson : blobRefJson // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftMediaAttachment].
extension DraftMediaAttachmentPatterns on DraftMediaAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftMediaAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftMediaAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftMediaAttachment value)  $default,){
final _that = this;
switch (_that) {
case _DraftMediaAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftMediaAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _DraftMediaAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String draftId,  String localPath,  String mimeType,  DraftMediaStatus status,  int sortOrder,  String? altText,  String? uploadCid,  String? blobRefJson,  int? durationSeconds,  String? aspectRatio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftMediaAttachment() when $default != null:
return $default(_that.id,_that.draftId,_that.localPath,_that.mimeType,_that.status,_that.sortOrder,_that.altText,_that.uploadCid,_that.blobRefJson,_that.durationSeconds,_that.aspectRatio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String draftId,  String localPath,  String mimeType,  DraftMediaStatus status,  int sortOrder,  String? altText,  String? uploadCid,  String? blobRefJson,  int? durationSeconds,  String? aspectRatio)  $default,) {final _that = this;
switch (_that) {
case _DraftMediaAttachment():
return $default(_that.id,_that.draftId,_that.localPath,_that.mimeType,_that.status,_that.sortOrder,_that.altText,_that.uploadCid,_that.blobRefJson,_that.durationSeconds,_that.aspectRatio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String draftId,  String localPath,  String mimeType,  DraftMediaStatus status,  int sortOrder,  String? altText,  String? uploadCid,  String? blobRefJson,  int? durationSeconds,  String? aspectRatio)?  $default,) {final _that = this;
switch (_that) {
case _DraftMediaAttachment() when $default != null:
return $default(_that.id,_that.draftId,_that.localPath,_that.mimeType,_that.status,_that.sortOrder,_that.altText,_that.uploadCid,_that.blobRefJson,_that.durationSeconds,_that.aspectRatio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftMediaAttachment extends DraftMediaAttachment {
  const _DraftMediaAttachment({required this.id, required this.draftId, required this.localPath, required this.mimeType, required this.status, required this.sortOrder, this.altText, this.uploadCid, this.blobRefJson, this.durationSeconds, this.aspectRatio}): super._();
  factory _DraftMediaAttachment.fromJson(Map<String, dynamic> json) => _$DraftMediaAttachmentFromJson(json);

@override final  int id;
@override final  String draftId;
@override final  String localPath;
@override final  String mimeType;
@override final  DraftMediaStatus status;
@override final  int sortOrder;
@override final  String? altText;
@override final  String? uploadCid;
@override final  String? blobRefJson;
@override final  int? durationSeconds;
@override final  String? aspectRatio;

/// Create a copy of DraftMediaAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftMediaAttachmentCopyWith<_DraftMediaAttachment> get copyWith => __$DraftMediaAttachmentCopyWithImpl<_DraftMediaAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftMediaAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftMediaAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.draftId, draftId) || other.draftId == draftId)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.status, status) || other.status == status)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.uploadCid, uploadCid) || other.uploadCid == uploadCid)&&(identical(other.blobRefJson, blobRefJson) || other.blobRefJson == blobRefJson)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,draftId,localPath,mimeType,status,sortOrder,altText,uploadCid,blobRefJson,durationSeconds,aspectRatio);

@override
String toString() {
  return 'DraftMediaAttachment(id: $id, draftId: $draftId, localPath: $localPath, mimeType: $mimeType, status: $status, sortOrder: $sortOrder, altText: $altText, uploadCid: $uploadCid, blobRefJson: $blobRefJson, durationSeconds: $durationSeconds, aspectRatio: $aspectRatio)';
}


}

/// @nodoc
abstract mixin class _$DraftMediaAttachmentCopyWith<$Res> implements $DraftMediaAttachmentCopyWith<$Res> {
  factory _$DraftMediaAttachmentCopyWith(_DraftMediaAttachment value, $Res Function(_DraftMediaAttachment) _then) = __$DraftMediaAttachmentCopyWithImpl;
@override @useResult
$Res call({
 int id, String draftId, String localPath, String mimeType, DraftMediaStatus status, int sortOrder, String? altText, String? uploadCid, String? blobRefJson, int? durationSeconds, String? aspectRatio
});




}
/// @nodoc
class __$DraftMediaAttachmentCopyWithImpl<$Res>
    implements _$DraftMediaAttachmentCopyWith<$Res> {
  __$DraftMediaAttachmentCopyWithImpl(this._self, this._then);

  final _DraftMediaAttachment _self;
  final $Res Function(_DraftMediaAttachment) _then;

/// Create a copy of DraftMediaAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? draftId = null,Object? localPath = null,Object? mimeType = null,Object? status = null,Object? sortOrder = null,Object? altText = freezed,Object? uploadCid = freezed,Object? blobRefJson = freezed,Object? durationSeconds = freezed,Object? aspectRatio = freezed,}) {
  return _then(_DraftMediaAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,draftId: null == draftId ? _self.draftId : draftId // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DraftMediaStatus,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,uploadCid: freezed == uploadCid ? _self.uploadCid : uploadCid // ignore: cast_nullable_to_non_nullable
as String?,blobRefJson: freezed == blobRefJson ? _self.blobRefJson : blobRefJson // ignore: cast_nullable_to_non_nullable
as String?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DraftMediaInput {

 String get localPath; String get mimeType; String? get altText;
/// Create a copy of DraftMediaInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftMediaInputCopyWith<DraftMediaInput> get copyWith => _$DraftMediaInputCopyWithImpl<DraftMediaInput>(this as DraftMediaInput, _$identity);

  /// Serializes this DraftMediaInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftMediaInput&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.altText, altText) || other.altText == altText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localPath,mimeType,altText);

@override
String toString() {
  return 'DraftMediaInput(localPath: $localPath, mimeType: $mimeType, altText: $altText)';
}


}

/// @nodoc
abstract mixin class $DraftMediaInputCopyWith<$Res>  {
  factory $DraftMediaInputCopyWith(DraftMediaInput value, $Res Function(DraftMediaInput) _then) = _$DraftMediaInputCopyWithImpl;
@useResult
$Res call({
 String localPath, String mimeType, String? altText
});




}
/// @nodoc
class _$DraftMediaInputCopyWithImpl<$Res>
    implements $DraftMediaInputCopyWith<$Res> {
  _$DraftMediaInputCopyWithImpl(this._self, this._then);

  final DraftMediaInput _self;
  final $Res Function(DraftMediaInput) _then;

/// Create a copy of DraftMediaInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localPath = null,Object? mimeType = null,Object? altText = freezed,}) {
  return _then(_self.copyWith(
localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftMediaInput].
extension DraftMediaInputPatterns on DraftMediaInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftMediaInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftMediaInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftMediaInput value)  $default,){
final _that = this;
switch (_that) {
case _DraftMediaInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftMediaInput value)?  $default,){
final _that = this;
switch (_that) {
case _DraftMediaInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String localPath,  String mimeType,  String? altText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftMediaInput() when $default != null:
return $default(_that.localPath,_that.mimeType,_that.altText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String localPath,  String mimeType,  String? altText)  $default,) {final _that = this;
switch (_that) {
case _DraftMediaInput():
return $default(_that.localPath,_that.mimeType,_that.altText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String localPath,  String mimeType,  String? altText)?  $default,) {final _that = this;
switch (_that) {
case _DraftMediaInput() when $default != null:
return $default(_that.localPath,_that.mimeType,_that.altText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftMediaInput implements DraftMediaInput {
  const _DraftMediaInput({required this.localPath, required this.mimeType, this.altText});
  factory _DraftMediaInput.fromJson(Map<String, dynamic> json) => _$DraftMediaInputFromJson(json);

@override final  String localPath;
@override final  String mimeType;
@override final  String? altText;

/// Create a copy of DraftMediaInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftMediaInputCopyWith<_DraftMediaInput> get copyWith => __$DraftMediaInputCopyWithImpl<_DraftMediaInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftMediaInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftMediaInput&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.altText, altText) || other.altText == altText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localPath,mimeType,altText);

@override
String toString() {
  return 'DraftMediaInput(localPath: $localPath, mimeType: $mimeType, altText: $altText)';
}


}

/// @nodoc
abstract mixin class _$DraftMediaInputCopyWith<$Res> implements $DraftMediaInputCopyWith<$Res> {
  factory _$DraftMediaInputCopyWith(_DraftMediaInput value, $Res Function(_DraftMediaInput) _then) = __$DraftMediaInputCopyWithImpl;
@override @useResult
$Res call({
 String localPath, String mimeType, String? altText
});




}
/// @nodoc
class __$DraftMediaInputCopyWithImpl<$Res>
    implements _$DraftMediaInputCopyWith<$Res> {
  __$DraftMediaInputCopyWithImpl(this._self, this._then);

  final _DraftMediaInput _self;
  final $Res Function(_DraftMediaInput) _then;

/// Create a copy of DraftMediaInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localPath = null,Object? mimeType = null,Object? altText = freezed,}) {
  return _then(_DraftMediaInput(
localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
