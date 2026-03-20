enum FeedArchitecture {
  grid,
  linear;

  static FeedArchitecture fromString(String? value) {
    switch (value) {
      case 'linear':
        return FeedArchitecture.linear;
      default:
        return FeedArchitecture.grid;
    }
  }
}
