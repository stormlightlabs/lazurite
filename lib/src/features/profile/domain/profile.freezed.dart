// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileData {

 String get did; String get handle; String? get displayName; String? get description; String? get avatar; String? get banner; int get followersCount; int get followsCount; int get postsCount; DateTime? get indexedAt; DateTime? get createdAt; String? get pronouns; String? get website;@JsonKey(name: 'verification', fromJson: _parseVerification) String? get verificationStatus;@JsonKey(name: 'pinnedPost', fromJson: _parsePinnedPost) String? get pinnedPostUri; ActorViewer? get viewer; List<ContentLabel>? get labels;
/// Create a copy of ProfileData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDataCopyWith<ProfileData> get copyWith => _$ProfileDataCopyWithImpl<ProfileData>(this as ProfileData, _$identity);

  /// Serializes this ProfileData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileData&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followsCount, followsCount) || other.followsCount == followsCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.website, website) || other.website == website)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.pinnedPostUri, pinnedPostUri) || other.pinnedPostUri == pinnedPostUri)&&(identical(other.viewer, viewer) || other.viewer == viewer)&&const DeepCollectionEquality().equals(other.labels, labels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,description,avatar,banner,followersCount,followsCount,postsCount,indexedAt,createdAt,pronouns,website,verificationStatus,pinnedPostUri,viewer,const DeepCollectionEquality().hash(labels));

@override
String toString() {
  return 'ProfileData(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, banner: $banner, followersCount: $followersCount, followsCount: $followsCount, postsCount: $postsCount, indexedAt: $indexedAt, createdAt: $createdAt, pronouns: $pronouns, website: $website, verificationStatus: $verificationStatus, pinnedPostUri: $pinnedPostUri, viewer: $viewer, labels: $labels)';
}


}

/// @nodoc
abstract mixin class $ProfileDataCopyWith<$Res>  {
  factory $ProfileDataCopyWith(ProfileData value, $Res Function(ProfileData) _then) = _$ProfileDataCopyWithImpl;
@useResult
$Res call({
 String did, String handle, String? displayName, String? description, String? avatar, String? banner, int followersCount, int followsCount, int postsCount, DateTime? indexedAt, DateTime? createdAt, String? pronouns, String? website,@JsonKey(name: 'verification', fromJson: _parseVerification) String? verificationStatus,@JsonKey(name: 'pinnedPost', fromJson: _parsePinnedPost) String? pinnedPostUri, ActorViewer? viewer, List<ContentLabel>? labels
});


$ActorViewerCopyWith<$Res>? get viewer;

}
/// @nodoc
class _$ProfileDataCopyWithImpl<$Res>
    implements $ProfileDataCopyWith<$Res> {
  _$ProfileDataCopyWithImpl(this._self, this._then);

  final ProfileData _self;
  final $Res Function(ProfileData) _then;

/// Create a copy of ProfileData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? description = freezed,Object? avatar = freezed,Object? banner = freezed,Object? followersCount = null,Object? followsCount = null,Object? postsCount = null,Object? indexedAt = freezed,Object? createdAt = freezed,Object? pronouns = freezed,Object? website = freezed,Object? verificationStatus = freezed,Object? pinnedPostUri = freezed,Object? viewer = freezed,Object? labels = freezed,}) {
  return _then(_self.copyWith(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followsCount: null == followsCount ? _self.followsCount : followsCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pronouns: freezed == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,pinnedPostUri: freezed == pinnedPostUri ? _self.pinnedPostUri : pinnedPostUri // ignore: cast_nullable_to_non_nullable
as String?,viewer: freezed == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as ActorViewer?,labels: freezed == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<ContentLabel>?,
  ));
}
/// Create a copy of ProfileData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActorViewerCopyWith<$Res>? get viewer {
    if (_self.viewer == null) {
    return null;
  }

  return $ActorViewerCopyWith<$Res>(_self.viewer!, (value) {
    return _then(_self.copyWith(viewer: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileData].
extension ProfileDataPatterns on ProfileData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileData value)  $default,){
final _that = this;
switch (_that) {
case _ProfileData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileData value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  String? banner,  int followersCount,  int followsCount,  int postsCount,  DateTime? indexedAt,  DateTime? createdAt,  String? pronouns,  String? website, @JsonKey(name: 'verification', fromJson: _parseVerification)  String? verificationStatus, @JsonKey(name: 'pinnedPost', fromJson: _parsePinnedPost)  String? pinnedPostUri,  ActorViewer? viewer,  List<ContentLabel>? labels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileData() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.banner,_that.followersCount,_that.followsCount,_that.postsCount,_that.indexedAt,_that.createdAt,_that.pronouns,_that.website,_that.verificationStatus,_that.pinnedPostUri,_that.viewer,_that.labels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  String? banner,  int followersCount,  int followsCount,  int postsCount,  DateTime? indexedAt,  DateTime? createdAt,  String? pronouns,  String? website, @JsonKey(name: 'verification', fromJson: _parseVerification)  String? verificationStatus, @JsonKey(name: 'pinnedPost', fromJson: _parsePinnedPost)  String? pinnedPostUri,  ActorViewer? viewer,  List<ContentLabel>? labels)  $default,) {final _that = this;
switch (_that) {
case _ProfileData():
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.banner,_that.followersCount,_that.followsCount,_that.postsCount,_that.indexedAt,_that.createdAt,_that.pronouns,_that.website,_that.verificationStatus,_that.pinnedPostUri,_that.viewer,_that.labels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String did,  String handle,  String? displayName,  String? description,  String? avatar,  String? banner,  int followersCount,  int followsCount,  int postsCount,  DateTime? indexedAt,  DateTime? createdAt,  String? pronouns,  String? website, @JsonKey(name: 'verification', fromJson: _parseVerification)  String? verificationStatus, @JsonKey(name: 'pinnedPost', fromJson: _parsePinnedPost)  String? pinnedPostUri,  ActorViewer? viewer,  List<ContentLabel>? labels)?  $default,) {final _that = this;
switch (_that) {
case _ProfileData() when $default != null:
return $default(_that.did,_that.handle,_that.displayName,_that.description,_that.avatar,_that.banner,_that.followersCount,_that.followsCount,_that.postsCount,_that.indexedAt,_that.createdAt,_that.pronouns,_that.website,_that.verificationStatus,_that.pinnedPostUri,_that.viewer,_that.labels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileData extends ProfileData {
  const _ProfileData({required this.did, required this.handle, this.displayName, this.description, this.avatar, this.banner, this.followersCount = 0, this.followsCount = 0, this.postsCount = 0, this.indexedAt, this.createdAt, this.pronouns, this.website, @JsonKey(name: 'verification', fromJson: _parseVerification) this.verificationStatus, @JsonKey(name: 'pinnedPost', fromJson: _parsePinnedPost) this.pinnedPostUri, this.viewer, final  List<ContentLabel>? labels}): _labels = labels,super._();
  factory _ProfileData.fromJson(Map<String, dynamic> json) => _$ProfileDataFromJson(json);

@override final  String did;
@override final  String handle;
@override final  String? displayName;
@override final  String? description;
@override final  String? avatar;
@override final  String? banner;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followsCount;
@override@JsonKey() final  int postsCount;
@override final  DateTime? indexedAt;
@override final  DateTime? createdAt;
@override final  String? pronouns;
@override final  String? website;
@override@JsonKey(name: 'verification', fromJson: _parseVerification) final  String? verificationStatus;
@override@JsonKey(name: 'pinnedPost', fromJson: _parsePinnedPost) final  String? pinnedPostUri;
@override final  ActorViewer? viewer;
 final  List<ContentLabel>? _labels;
@override List<ContentLabel>? get labels {
  final value = _labels;
  if (value == null) return null;
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ProfileData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileDataCopyWith<_ProfileData> get copyWith => __$ProfileDataCopyWithImpl<_ProfileData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileData&&(identical(other.did, did) || other.did == did)&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.banner, banner) || other.banner == banner)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followsCount, followsCount) || other.followsCount == followsCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount)&&(identical(other.indexedAt, indexedAt) || other.indexedAt == indexedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.website, website) || other.website == website)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.pinnedPostUri, pinnedPostUri) || other.pinnedPostUri == pinnedPostUri)&&(identical(other.viewer, viewer) || other.viewer == viewer)&&const DeepCollectionEquality().equals(other._labels, _labels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,did,handle,displayName,description,avatar,banner,followersCount,followsCount,postsCount,indexedAt,createdAt,pronouns,website,verificationStatus,pinnedPostUri,viewer,const DeepCollectionEquality().hash(_labels));

@override
String toString() {
  return 'ProfileData(did: $did, handle: $handle, displayName: $displayName, description: $description, avatar: $avatar, banner: $banner, followersCount: $followersCount, followsCount: $followsCount, postsCount: $postsCount, indexedAt: $indexedAt, createdAt: $createdAt, pronouns: $pronouns, website: $website, verificationStatus: $verificationStatus, pinnedPostUri: $pinnedPostUri, viewer: $viewer, labels: $labels)';
}


}

/// @nodoc
abstract mixin class _$ProfileDataCopyWith<$Res> implements $ProfileDataCopyWith<$Res> {
  factory _$ProfileDataCopyWith(_ProfileData value, $Res Function(_ProfileData) _then) = __$ProfileDataCopyWithImpl;
@override @useResult
$Res call({
 String did, String handle, String? displayName, String? description, String? avatar, String? banner, int followersCount, int followsCount, int postsCount, DateTime? indexedAt, DateTime? createdAt, String? pronouns, String? website,@JsonKey(name: 'verification', fromJson: _parseVerification) String? verificationStatus,@JsonKey(name: 'pinnedPost', fromJson: _parsePinnedPost) String? pinnedPostUri, ActorViewer? viewer, List<ContentLabel>? labels
});


@override $ActorViewerCopyWith<$Res>? get viewer;

}
/// @nodoc
class __$ProfileDataCopyWithImpl<$Res>
    implements _$ProfileDataCopyWith<$Res> {
  __$ProfileDataCopyWithImpl(this._self, this._then);

  final _ProfileData _self;
  final $Res Function(_ProfileData) _then;

/// Create a copy of ProfileData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? did = null,Object? handle = null,Object? displayName = freezed,Object? description = freezed,Object? avatar = freezed,Object? banner = freezed,Object? followersCount = null,Object? followsCount = null,Object? postsCount = null,Object? indexedAt = freezed,Object? createdAt = freezed,Object? pronouns = freezed,Object? website = freezed,Object? verificationStatus = freezed,Object? pinnedPostUri = freezed,Object? viewer = freezed,Object? labels = freezed,}) {
  return _then(_ProfileData(
did: null == did ? _self.did : did // ignore: cast_nullable_to_non_nullable
as String,handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,banner: freezed == banner ? _self.banner : banner // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followsCount: null == followsCount ? _self.followsCount : followsCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,indexedAt: freezed == indexedAt ? _self.indexedAt : indexedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pronouns: freezed == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,pinnedPostUri: freezed == pinnedPostUri ? _self.pinnedPostUri : pinnedPostUri // ignore: cast_nullable_to_non_nullable
as String?,viewer: freezed == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as ActorViewer?,labels: freezed == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<ContentLabel>?,
  ));
}

/// Create a copy of ProfileData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActorViewerCopyWith<$Res>? get viewer {
    if (_self.viewer == null) {
    return null;
  }

  return $ActorViewerCopyWith<$Res>(_self.viewer!, (value) {
    return _then(_self.copyWith(viewer: value));
  });
}
}


/// @nodoc
mixin _$AuthorFeedResult {

 List<Post> get items; String? get cursor;
/// Create a copy of AuthorFeedResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorFeedResultCopyWith<AuthorFeedResult> get copyWith => _$AuthorFeedResultCopyWithImpl<AuthorFeedResult>(this as AuthorFeedResult, _$identity);

  /// Serializes this AuthorFeedResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorFeedResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),cursor);

@override
String toString() {
  return 'AuthorFeedResult(items: $items, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $AuthorFeedResultCopyWith<$Res>  {
  factory $AuthorFeedResultCopyWith(AuthorFeedResult value, $Res Function(AuthorFeedResult) _then) = _$AuthorFeedResultCopyWithImpl;
@useResult
$Res call({
 List<Post> items, String? cursor
});




}
/// @nodoc
class _$AuthorFeedResultCopyWithImpl<$Res>
    implements $AuthorFeedResultCopyWith<$Res> {
  _$AuthorFeedResultCopyWithImpl(this._self, this._then);

  final AuthorFeedResult _self;
  final $Res Function(AuthorFeedResult) _then;

/// Create a copy of AuthorFeedResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Post>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthorFeedResult].
extension AuthorFeedResultPatterns on AuthorFeedResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthorFeedResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthorFeedResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthorFeedResult value)  $default,){
final _that = this;
switch (_that) {
case _AuthorFeedResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthorFeedResult value)?  $default,){
final _that = this;
switch (_that) {
case _AuthorFeedResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Post> items,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthorFeedResult() when $default != null:
return $default(_that.items,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Post> items,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _AuthorFeedResult():
return $default(_that.items,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Post> items,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _AuthorFeedResult() when $default != null:
return $default(_that.items,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthorFeedResult extends AuthorFeedResult {
  const _AuthorFeedResult({required final  List<Post> items, this.cursor}): _items = items,super._();
  factory _AuthorFeedResult.fromJson(Map<String, dynamic> json) => _$AuthorFeedResultFromJson(json);

 final  List<Post> _items;
@override List<Post> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? cursor;

/// Create a copy of AuthorFeedResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthorFeedResultCopyWith<_AuthorFeedResult> get copyWith => __$AuthorFeedResultCopyWithImpl<_AuthorFeedResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthorFeedResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthorFeedResult&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),cursor);

@override
String toString() {
  return 'AuthorFeedResult(items: $items, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$AuthorFeedResultCopyWith<$Res> implements $AuthorFeedResultCopyWith<$Res> {
  factory _$AuthorFeedResultCopyWith(_AuthorFeedResult value, $Res Function(_AuthorFeedResult) _then) = __$AuthorFeedResultCopyWithImpl;
@override @useResult
$Res call({
 List<Post> items, String? cursor
});




}
/// @nodoc
class __$AuthorFeedResultCopyWithImpl<$Res>
    implements _$AuthorFeedResultCopyWith<$Res> {
  __$AuthorFeedResultCopyWithImpl(this._self, this._then);

  final _AuthorFeedResult _self;
  final $Res Function(_AuthorFeedResult) _then;

/// Create a copy of AuthorFeedResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? cursor = freezed,}) {
  return _then(_AuthorFeedResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Post>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FollowersResult {

 List<Author> get followers; String? get cursor;
/// Create a copy of FollowersResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowersResultCopyWith<FollowersResult> get copyWith => _$FollowersResultCopyWithImpl<FollowersResult>(this as FollowersResult, _$identity);

  /// Serializes this FollowersResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowersResult&&const DeepCollectionEquality().equals(other.followers, followers)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(followers),cursor);

@override
String toString() {
  return 'FollowersResult(followers: $followers, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $FollowersResultCopyWith<$Res>  {
  factory $FollowersResultCopyWith(FollowersResult value, $Res Function(FollowersResult) _then) = _$FollowersResultCopyWithImpl;
@useResult
$Res call({
 List<Author> followers, String? cursor
});




}
/// @nodoc
class _$FollowersResultCopyWithImpl<$Res>
    implements $FollowersResultCopyWith<$Res> {
  _$FollowersResultCopyWithImpl(this._self, this._then);

  final FollowersResult _self;
  final $Res Function(FollowersResult) _then;

/// Create a copy of FollowersResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? followers = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
followers: null == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as List<Author>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowersResult].
extension FollowersResultPatterns on FollowersResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowersResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowersResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowersResult value)  $default,){
final _that = this;
switch (_that) {
case _FollowersResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowersResult value)?  $default,){
final _that = this;
switch (_that) {
case _FollowersResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Author> followers,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowersResult() when $default != null:
return $default(_that.followers,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Author> followers,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _FollowersResult():
return $default(_that.followers,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Author> followers,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _FollowersResult() when $default != null:
return $default(_that.followers,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowersResult extends FollowersResult {
  const _FollowersResult({required final  List<Author> followers, this.cursor}): _followers = followers,super._();
  factory _FollowersResult.fromJson(Map<String, dynamic> json) => _$FollowersResultFromJson(json);

 final  List<Author> _followers;
@override List<Author> get followers {
  if (_followers is EqualUnmodifiableListView) return _followers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_followers);
}

@override final  String? cursor;

/// Create a copy of FollowersResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowersResultCopyWith<_FollowersResult> get copyWith => __$FollowersResultCopyWithImpl<_FollowersResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowersResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowersResult&&const DeepCollectionEquality().equals(other._followers, _followers)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_followers),cursor);

@override
String toString() {
  return 'FollowersResult(followers: $followers, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$FollowersResultCopyWith<$Res> implements $FollowersResultCopyWith<$Res> {
  factory _$FollowersResultCopyWith(_FollowersResult value, $Res Function(_FollowersResult) _then) = __$FollowersResultCopyWithImpl;
@override @useResult
$Res call({
 List<Author> followers, String? cursor
});




}
/// @nodoc
class __$FollowersResultCopyWithImpl<$Res>
    implements _$FollowersResultCopyWith<$Res> {
  __$FollowersResultCopyWithImpl(this._self, this._then);

  final _FollowersResult _self;
  final $Res Function(_FollowersResult) _then;

/// Create a copy of FollowersResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? followers = null,Object? cursor = freezed,}) {
  return _then(_FollowersResult(
followers: null == followers ? _self._followers : followers // ignore: cast_nullable_to_non_nullable
as List<Author>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FollowsResult {

 List<Author> get follows; String? get cursor;
/// Create a copy of FollowsResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowsResultCopyWith<FollowsResult> get copyWith => _$FollowsResultCopyWithImpl<FollowsResult>(this as FollowsResult, _$identity);

  /// Serializes this FollowsResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowsResult&&const DeepCollectionEquality().equals(other.follows, follows)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(follows),cursor);

@override
String toString() {
  return 'FollowsResult(follows: $follows, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $FollowsResultCopyWith<$Res>  {
  factory $FollowsResultCopyWith(FollowsResult value, $Res Function(FollowsResult) _then) = _$FollowsResultCopyWithImpl;
@useResult
$Res call({
 List<Author> follows, String? cursor
});




}
/// @nodoc
class _$FollowsResultCopyWithImpl<$Res>
    implements $FollowsResultCopyWith<$Res> {
  _$FollowsResultCopyWithImpl(this._self, this._then);

  final FollowsResult _self;
  final $Res Function(FollowsResult) _then;

/// Create a copy of FollowsResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? follows = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
follows: null == follows ? _self.follows : follows // ignore: cast_nullable_to_non_nullable
as List<Author>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowsResult].
extension FollowsResultPatterns on FollowsResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowsResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowsResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowsResult value)  $default,){
final _that = this;
switch (_that) {
case _FollowsResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowsResult value)?  $default,){
final _that = this;
switch (_that) {
case _FollowsResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Author> follows,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowsResult() when $default != null:
return $default(_that.follows,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Author> follows,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _FollowsResult():
return $default(_that.follows,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Author> follows,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _FollowsResult() when $default != null:
return $default(_that.follows,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowsResult extends FollowsResult {
  const _FollowsResult({required final  List<Author> follows, this.cursor}): _follows = follows,super._();
  factory _FollowsResult.fromJson(Map<String, dynamic> json) => _$FollowsResultFromJson(json);

 final  List<Author> _follows;
@override List<Author> get follows {
  if (_follows is EqualUnmodifiableListView) return _follows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_follows);
}

@override final  String? cursor;

/// Create a copy of FollowsResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowsResultCopyWith<_FollowsResult> get copyWith => __$FollowsResultCopyWithImpl<_FollowsResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowsResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowsResult&&const DeepCollectionEquality().equals(other._follows, _follows)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_follows),cursor);

@override
String toString() {
  return 'FollowsResult(follows: $follows, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$FollowsResultCopyWith<$Res> implements $FollowsResultCopyWith<$Res> {
  factory _$FollowsResultCopyWith(_FollowsResult value, $Res Function(_FollowsResult) _then) = __$FollowsResultCopyWithImpl;
@override @useResult
$Res call({
 List<Author> follows, String? cursor
});




}
/// @nodoc
class __$FollowsResultCopyWithImpl<$Res>
    implements _$FollowsResultCopyWith<$Res> {
  __$FollowsResultCopyWithImpl(this._self, this._then);

  final _FollowsResult _self;
  final $Res Function(_FollowsResult) _then;

/// Create a copy of FollowsResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? follows = null,Object? cursor = freezed,}) {
  return _then(_FollowsResult(
follows: null == follows ? _self._follows : follows // ignore: cast_nullable_to_non_nullable
as List<Author>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
