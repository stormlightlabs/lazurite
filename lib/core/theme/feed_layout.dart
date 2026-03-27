enum FeedLayout {
  card,
  compact;

  static FeedLayout fromString(String? value) {
    switch (value) {
      case 'linear':
      case 'compact':
        return FeedLayout.compact;
      case 'grid':
      case 'card':
        return FeedLayout.card;
      default:
        return FeedLayout.card;
    }
  }
}
