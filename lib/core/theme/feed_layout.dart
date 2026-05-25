enum FeedLayout {
  comfortable,
  compact;

  static FeedLayout fromString(String? value) {
    switch (value) {
      case 'linear':
      case 'compact':
        return FeedLayout.compact;
      case 'grid':
      case 'card':
      case 'comfortable':
        return FeedLayout.comfortable;
      default:
        return FeedLayout.comfortable;
    }
  }
}
