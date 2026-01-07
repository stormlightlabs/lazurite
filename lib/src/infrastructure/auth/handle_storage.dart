import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'handle_storage.g.dart';

/// Provider for SharedPreferences instance.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

/// Storage for user handles to improve login UX by remembering the last used handle.
///
/// This stores handles in plain text using SharedPreferences since handles are
/// public identifiers (like email addresses or usernames) and not sensitive data.
/// The actual authentication tokens are stored securely via SessionStorage.
class HandleStorage {
  /// Creates a handle storage instance.
  HandleStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _keyLastHandle = 'lazurite_last_handle';

  /// Retrieves the last used handle from storage.
  ///
  /// Returns null if no handle has been saved.
  String? getLastHandle() {
    return _prefs.getString(_keyLastHandle);
  }

  /// Saves a handle to storage for future retrieval.
  ///
  /// This should be called when a user successfully starts the login flow,
  /// not when they successfully authenticate (to remember even failed attempts).
  Future<void> saveHandle(String handle) async {
    await _prefs.setString(_keyLastHandle, handle.trim());
  }

  /// Clears the saved handle from storage.
  ///
  /// This is typically called when a user explicitly chooses to switch accounts
  /// or wants to clear their login history.
  Future<void> clearHandle() async {
    await _prefs.remove(_keyLastHandle);
  }
}

/// Provider for HandleStorage.
@Riverpod(keepAlive: true)
Future<HandleStorage> handleStorage(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return HandleStorage(prefs);
}
