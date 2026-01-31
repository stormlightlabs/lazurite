import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/app/app.dart';
import 'package:lazurite/src/core/infrastructure/notifications/notification_initializer.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/workmanager_callback_dispatcher.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationInitializer.instance.initialize();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);

  runApp(const ProviderScope(child: App()));
}
