import 'package:flutter/widgets.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ?? lookupAppLocalizations(const Locale('en'));
}
