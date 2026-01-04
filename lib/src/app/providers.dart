import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Provides the app's [GoRouter] instance.
///
/// This is the primary router provider.
/// Use it to access navigation from anywhere in the app via `ref.read(goRouterProvider)`.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return createRouter(ref);
}
