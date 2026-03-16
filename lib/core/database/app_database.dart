import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Accounts, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'lazurite_db',
      native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
    );
  }

  Future<Account?> getAccount(String did) => (select(accounts)..where((a) => a.did.equals(did))).getSingleOrNull();

  Future<Account?> getActiveAccount() async {
    final all = await select(accounts).get();
    return all.isNotEmpty ? all.first : null;
  }

  Future<List<Account>> getAllAccounts() => select(accounts).get();

  Future<int> insertAccount(AccountsCompanion account) => into(accounts).insert(account, mode: InsertMode.replace);

  Future<int> deleteAccount(String did) => (delete(accounts)..where((a) => a.did.equals(did))).go();

  Future<int> deleteAllAccounts() => delete(accounts).go();

  Future<bool> updateAccountTokens(
    String did, {
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    final query = update(accounts)..where((a) => a.did.equals(did));
    final rowsAffected = await query.write(
      AccountsCompanion(
        accessToken: Value(accessToken),
        refreshToken: refreshToken != null ? Value(refreshToken) : const Value.absent(),
        expiresAt: expiresAt != null ? Value(expiresAt) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return rowsAffected > 0;
  }

  Future<String?> getSetting(String key) async {
    final setting = await (select(settings)..where((s) => s.key.equals(key))).getSingleOrNull();
    return setting?.value;
  }

  Future<int> setSetting(String key, String value) => into(settings).insert(
    SettingsCompanion(key: Value(key), value: Value(value), updatedAt: Value(DateTime.now())),
    mode: InsertMode.replace,
  );

  Future<int> deleteSetting(String key) => (delete(settings)..where((s) => s.key.equals(key))).go();
}
