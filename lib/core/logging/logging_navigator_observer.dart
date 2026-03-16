import 'package:flutter/material.dart';
import 'package:lazurite/core/logging/app_logger.dart';

class LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    final routeName = route.settings.name ?? route.runtimeType.toString();
    final previousName = previousRoute?.settings.name ?? previousRoute?.runtimeType.toString() ?? 'root';
    log.i('NavObserver: Route pushed: $routeName (from $previousName)', time: DateTime.now());
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    final routeName = route.settings.name ?? route.runtimeType.toString();
    final previousName = previousRoute?.settings.name ?? previousRoute?.runtimeType.toString() ?? 'root';
    log.i('NavObserver: Route popped: $routeName (to $previousName)', time: DateTime.now());
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final newName = newRoute?.settings.name ?? newRoute?.runtimeType.toString() ?? 'unknown';
    final oldName = oldRoute?.settings.name ?? oldRoute?.runtimeType.toString() ?? 'unknown';
    log.i('NavObserver: Route replaced: $oldName → $newName', time: DateTime.now());
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    final routeName = route.settings.name ?? route.runtimeType.toString();
    log.i('NavObserver: Route removed: $routeName', time: DateTime.now());
  }
}
