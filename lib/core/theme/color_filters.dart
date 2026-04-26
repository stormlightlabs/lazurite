import 'package:flutter/widgets.dart';

abstract final class AppColorFilters {
  static const List<double> greyscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  static const ColorFilter greyscale = ColorFilter.matrix(greyscaleMatrix);
}
