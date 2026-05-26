/// Returns the normalized DID for the active session, preferring the
/// app-password session DID and falling back to the OAuth subject.
String? resolveCurrentSessionDid({required String? sessionDid, required String? oauthSubject}) {
  final normalizedSessionDid = sessionDid?.trim().toLowerCase();
  if (normalizedSessionDid != null && normalizedSessionDid.isNotEmpty) {
    return normalizedSessionDid;
  }

  final normalizedOauthSubject = oauthSubject?.trim().toLowerCase();
  if (normalizedOauthSubject != null && normalizedOauthSubject.isNotEmpty) {
    return normalizedOauthSubject;
  }

  return null;
}
