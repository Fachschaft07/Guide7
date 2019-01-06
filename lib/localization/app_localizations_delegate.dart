import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

/// Delegate needed to use applications localized values within the flutter app.
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  /// List of supported locales.
  static const List<Locale> supportedLocales = [
    Locale("de"),
    Locale("en"),
  ];

  /// Constant constructor.
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => supportedLocales.where((l) => l.languageCode == locale.languageCode).isNotEmpty;

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of AppLocalizations.
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
