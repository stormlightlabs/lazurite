enum UiDensity {
  compact,
  standard,
  relaxed;

  double get scaleFactor {
    switch (this) {
      case UiDensity.compact:
        return 0.75;
      case UiDensity.standard:
        return 1.0;
      case UiDensity.relaxed:
        return 1.25;
    }
  }

  static UiDensity fromString(String? value) {
    switch (value) {
      case 'compact':
        return UiDensity.compact;
      case 'relaxed':
        return UiDensity.relaxed;
      default:
        return UiDensity.standard;
    }
  }
}
