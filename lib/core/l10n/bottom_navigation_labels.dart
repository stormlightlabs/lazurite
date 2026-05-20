import 'package:lazurite/core/l10n/app_localizations.dart';

extension BottomNavigationLabels on AppLocalizations {
  String get bottomNavHome => _titleCaseNavLabel(labelHome);

  String get bottomNavSearch => _titleCaseNavLabel(labelSearchNav);

  String get bottomNavAtExplorer => labelAtExplorer;

  String get bottomNavAlerts => _titleCaseNavLabel(labelAlerts);

  String get bottomNavProfile => _titleCaseNavLabel(labelProfile);

  String get bottomNavSettings => labelSettings;

  String get bottomNavSignIn => buttonSignIn;
}

String _titleCaseNavLabel(String label) {
  final normalized = label.trim();
  if (normalized.isEmpty) {
    return normalized;
  }

  return normalized
      .split(RegExp(r'\s+'))
      .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}
