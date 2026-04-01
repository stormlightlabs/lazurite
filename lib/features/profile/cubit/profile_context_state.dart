part of 'profile_context_cubit.dart';

enum ProfileContextTabStatus { initial, loading, loaded, error }

const _profileContextNoValue = Object();

class ProfileContextState extends Equatable {
  const ProfileContextState._({
    required this.did,
    required this.isOwnProfile,
    this.blockedByCount = 0,
    this.blockingCount = 0,
    this.listsOnCount = 0,
    this.blockedByStatus = ProfileContextTabStatus.initial,
    this.blockedByEntries = const [],
    this.blockedByCursor,
    this.blockedByHasMore = false,
    this.blockedByError,
    this.blockingStatus = ProfileContextTabStatus.initial,
    this.blockingProfiles = const [],
    this.blockingUnavailable = const [],
    this.blockingCursor,
    this.blockingHasMore = false,
    this.blockingError,
    this.listsOnStatus = ProfileContextTabStatus.initial,
    this.listsOn = const [],
    this.listsOnCursor,
    this.listsOnHasMore = false,
    this.listsOnError,
  });

  const ProfileContextState.initial({required String did, required bool isOwnProfile})
    : this._(did: did, isOwnProfile: isOwnProfile);

  final String did;
  final bool isOwnProfile;

  final int blockedByCount;
  final int blockingCount;
  final int listsOnCount;

  final ProfileContextTabStatus blockedByStatus;
  final List<BlockedByEntry> blockedByEntries;
  final String? blockedByCursor;
  final bool blockedByHasMore;
  final String? blockedByError;

  final ProfileContextTabStatus blockingStatus;
  final List<ProfileView> blockingProfiles;
  final List<UnavailableProfileRef> blockingUnavailable;
  final String? blockingCursor;
  final bool blockingHasMore;
  final String? blockingError;

  final ProfileContextTabStatus listsOnStatus;
  final List<ListView> listsOn;
  final String? listsOnCursor;
  final bool listsOnHasMore;
  final String? listsOnError;

  ProfileContextState copyWith({
    int? blockedByCount,
    int? blockingCount,
    int? listsOnCount,
    ProfileContextTabStatus? blockedByStatus,
    List<BlockedByEntry>? blockedByEntries,
    Object? blockedByCursor = _profileContextNoValue,
    bool? blockedByHasMore,
    Object? blockedByError = _profileContextNoValue,
    ProfileContextTabStatus? blockingStatus,
    List<ProfileView>? blockingProfiles,
    List<UnavailableProfileRef>? blockingUnavailable,
    Object? blockingCursor = _profileContextNoValue,
    bool? blockingHasMore,
    Object? blockingError = _profileContextNoValue,
    ProfileContextTabStatus? listsOnStatus,
    List<ListView>? listsOn,
    Object? listsOnCursor = _profileContextNoValue,
    bool? listsOnHasMore,
    Object? listsOnError = _profileContextNoValue,
  }) {
    return ProfileContextState._(
      did: did,
      isOwnProfile: isOwnProfile,
      blockedByCount: blockedByCount ?? this.blockedByCount,
      blockingCount: blockingCount ?? this.blockingCount,
      listsOnCount: listsOnCount ?? this.listsOnCount,
      blockedByStatus: blockedByStatus ?? this.blockedByStatus,
      blockedByEntries: blockedByEntries ?? this.blockedByEntries,
      blockedByCursor: identical(blockedByCursor, _profileContextNoValue)
          ? this.blockedByCursor
          : blockedByCursor as String?,
      blockedByHasMore: blockedByHasMore ?? this.blockedByHasMore,
      blockedByError: identical(blockedByError, _profileContextNoValue)
          ? this.blockedByError
          : blockedByError as String?,
      blockingStatus: blockingStatus ?? this.blockingStatus,
      blockingProfiles: blockingProfiles ?? this.blockingProfiles,
      blockingUnavailable: blockingUnavailable ?? this.blockingUnavailable,
      blockingCursor: identical(blockingCursor, _profileContextNoValue)
          ? this.blockingCursor
          : blockingCursor as String?,
      blockingHasMore: blockingHasMore ?? this.blockingHasMore,
      blockingError: identical(blockingError, _profileContextNoValue) ? this.blockingError : blockingError as String?,
      listsOnStatus: listsOnStatus ?? this.listsOnStatus,
      listsOn: listsOn ?? this.listsOn,
      listsOnCursor: identical(listsOnCursor, _profileContextNoValue) ? this.listsOnCursor : listsOnCursor as String?,
      listsOnHasMore: listsOnHasMore ?? this.listsOnHasMore,
      listsOnError: identical(listsOnError, _profileContextNoValue) ? this.listsOnError : listsOnError as String?,
    );
  }

  @override
  List<Object?> get props => [
    did,
    isOwnProfile,
    blockedByCount,
    blockingCount,
    listsOnCount,
    blockedByStatus,
    blockedByEntries,
    blockedByCursor,
    blockedByHasMore,
    blockedByError,
    blockingStatus,
    blockingProfiles,
    blockingUnavailable,
    blockingCursor,
    blockingHasMore,
    blockingError,
    listsOnStatus,
    listsOn,
    listsOnCursor,
    listsOnHasMore,
    listsOnError,
  ];
}
