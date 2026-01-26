import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/app/app.dart';
import 'package:lazurite/src/core/infrastructure/notifications/notification_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationInitializer.instance.initialize();
  runApp(const ProviderScope(child: App()));
}
