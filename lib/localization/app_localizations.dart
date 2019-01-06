import 'dart:core';
import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Class containing localizations for the app (translations).
class AppLocalizations {
  /// Create app localizations.
  AppLocalizations(this.locale);

  /// Current locale.
  final Locale locale;

  /// Convenience method to easily get the localizations.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Map containing all localizations (translations).
  static const Map<String, Map<String, String>> _localizations = {
    "de": _deLocalizations,
    "en": _enLocalizations,
  };

  /// German localized values.
  static const Map<String, String> _deLocalizations = {
    "title": "Guide7",
    "splash_subtitle": "Eine App der Fachschaft 07",
    "login": "Anmeldung",
    "login_info": "Gib deine ZPA Anmeldedaten an um dich anzumelden.",
    "username": "Benutzername",
    "username_error": "Bitte geben Sie einen Benutzernamen an",
    "password": "Passwort",
    "password_error": "Bitte geben Sie ein Password an",
    "do_login": "Anmelden",
    "check_login": "Überprüfe Anmeldedaten...",
    "login_failed": "Anmeldung fehlgeschlagen",
    "notice_board": "Schwarzes Brett",
    "weekplan": "Wochenplan",
    "appointments": "Termine",
    "logout": "Abmelden",
    "search": "Suche",
    "end_search": "Suche beenden",
    "do_search": "Suchen...",
    "notice_board_entry_load_error": "Beim Laden der Einträge ist ein Fehler aufgetreten.",
    "navigation_view_item_title": "Mehr...",
    "navigation_view_title": "Navigation",
    "settings": "Einstellungen",
    "privacy_policy_statement": "Datenschutzerklärung",
    "or": "Oder",
    "skip_login": "Anmeldung überspringen",
  };

  /// English localized values.
  static const Map<String, String> _enLocalizations = {
    "title": "Guide7",
    "splash_subtitle": "App of the students council of department 07",
    "login": "Login",
    "login_info": "Enter your ZPA credentials to login.",
    "username": "Username",
    "username_error": "Please enter a username",
    "password": "Password",
    "password_error": "Please enter a password",
    "do_login": "Login",
    "check_login": "Checking credentials...",
    "login_failed": "Login failed",
    "notice_board": "Notice board",
    "weekplan": "Week plan",
    "appointments": "Appointments",
    "logout": "Log out",
    "search": "Search",
    "end_search": "Exit search",
    "do_search": "Search...",
    "notice_board_entry_load_error": "An error occurred when trying to load notice board entries.",
    "navigation_view_item_title": "More...",
    "navigation_view_title": "Navigation",
    "settings": "Settings",
    "privacy_policy_statement": "Privacy policy statement",
    "or": "Or",
    "skip_login": "Skip the login",
  };

  /// Get localized value by [key].
  String _get(String key) => _localizations[locale.languageCode][key];

  String get title => _get("title");

  String get splashSubtitle => _get("splash_subtitle");

  String get login => _get("login");

  String get loginInfo => _get("login_info");

  String get username => _get("username");

  String get usernameError => _get("username_error");

  String get password => _get("password");

  String get passwordError => _get("password_error");

  String get doLogin => _get("do_login");

  String get checkLogin => _get("check_login");

  String get loginFailed => _get("login_failed");

  String get noticeBoard => _get("notice_board");

  String get weekPlan => _get("weekplan");

  String get appointments => _get("appointments");

  String get logOut => _get("logout");

  String get search => _get("search");

  String get endSearch => _get("end_search");

  String get doSearch => _get("do_search");

  String get noticeBoardEntryLoadError => _get("notice_board_entry_load_error");

  String get navigationViewItemTitle => _get("navigation_view_item_title");

  String get navigationViewTitle => _get("navigation_view_title");

  String get settings => _get("settings");

  String get privacyPolicyStatement => _get("privacy_policy_statement");

  String get or => _get("or");

  String get skipLogin => _get("skip_login");
}
