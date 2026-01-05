import 'package:drift/drift.dart' show Index, SqlDialect;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';

void main() {
  test('TimelineItems defines composite index for feed and sort keys', () {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final index = database.allSchemaEntities.whereType<Index>().singleWhere(
      (idx) => idx.entityName == 'timeline_sort_idx',
    );

    final statement = index.createStatementsByDialect[SqlDialect.sqlite];
    expect(statement, isNotNull);
    expect(statement, contains('(feed_key, sort_key)'));
  });
}
