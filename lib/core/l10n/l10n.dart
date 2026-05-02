import 'package:flutter/widgets.dart';
import '../../generated/l10n/app_localizations.dart';

export '../../generated/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
