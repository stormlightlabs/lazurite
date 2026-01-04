import 'package:drift/native.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

/// Creates an in-memory test database.
///
/// Each call creates a fresh in-memory database for isolated test execution.
AppDatabase createTestDatabase() => AppDatabase(NativeDatabase.memory());
