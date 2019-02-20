import 'dart:core';
import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Class containing localizations for the app (translations).
class AppLocalizations {
  /// Version of the application.
  static const String _appVersion = "0.1.1";

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
    "app_title": "Guide7",
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
    "room_search": "Raumsuche",
    "day": "Tag",
    "from": "Von",
    "to": "Bis",
    "room_search_error": "Freie Räume konnten nicht geladen werden.",
    "seat_count": "Sitzanzahl",
    "appointment_load_error": "Die Termine konnten nicht geladen werden.",
    "weekplan_load_error": "Die Wochenplan Einträge konnten nicht geladen werden.",
    "refresh": "Aktualisieren",
    "version": "Version",
    "no_entries": "Keine Einträge",
    "moved": "Verschoben",
    "cancelled": "Abgesagt",
    "room_changed": "Raum geändert",
    "change_to": "auf",
    "change_at": "in",
    "title": "Titel",
    "description": "Beschreibung",
    "location": "Ort",
    "create_event_title_empty_error": "Ein Titel wird benötigt",
    "create_custom_event": "Neues Ereignis",
    "edit_custom_event": "Ereignis bearbeiten",
    "details": "Details",
    "recurring": "Wiederkehrend",
    "create": "Erstellen",
    "edit": "Bearbeiten",
    "daily": "Täglich",
    "weekly": "Wöchentlich",
    "every_two_weeks": "Jede zweite Woche",
    "custom": "Benutzerdefiniert",
    "only_once": "Nur einmal",
    "create_event_custom_recurring_cycle_invalid": "Die eingegebene Zahl ist ungültig",
    "count_of_days": "Tage",
    "count_of_months": "Monate",
    "count_of_years": "Jahre",
    "generic_load_error": "Während des Ladens ist ein Fehler aufgetreten",
    "save": "Speichern",
    "delete_event": "Ereignis löschen",
    "delete_event_security_question": "Nochmal Berühren zum Löschen",
    "actions": "Aktionen",
    "first_start.first_line": "Ich bereite nur schnell was für dich vor!",
    "first_start.line1": "Ist gleich fertig. Versprochen!",
    "first_start.line2": "Ich kann nicht wenn jemand kuckt! :(",
    "first_start.line3": "Hmm... braucht wohl doch länger ¯\\_(ツ)_/¯",
    "first_start.line4": "Gähn...",
    "first_start.line5": "Mach dir doch noch schnell einen Kaffee!",
    "first_start.line6": "Nur die Ruhe... Ich mach ja schon!",
    "first_start.line7": "Mist... ich glaub ich muss nochmal von vorne anfangen >.<",
    "first_start.line8": "Hier könnte Ihre Werbung stehen!",
    "first_start.line9": "Einen kleinen Moment noch, ich habs gleich!",
    "first_start.line10": "Lorem ipsum...",
    "first_start.last_line": "Gleich gehts los!",
  };

  /// English localized values.
  static const Map<String, String> _enLocalizations = {
    "app_title": "Guide7",
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
    "room_search": "Room search",
    "day": "Day",
    "from": "From",
    "to": "To",
    "room_search_error": "Free rooms could not be fetched.",
    "seat_count": "Seat count",
    "appointment_load_error": "Appointments could not be loaded.",
    "weekplan_load_error": "Week plan entries could not be loaded.",
    "refresh": "Refresh",
    "version": "Version",
    "no_entries": "No entries",
    "moved": "Moved",
    "cancelled": "Cancelled",
    "room_changed": "Room changed",
    "change_to": "to",
    "change_at": "at",
    "title": "Title",
    "description": "Description",
    "location": "Location",
    "create_event_title_empty_error": "The event needs a title",
    "create_custom_event": "New event",
    "edit_custom_event": "Edit event",
    "details": "Details",
    "recurring": "Recurring",
    "create": "Create",
    "edit": "Edit",
    "daily": "Daily",
    "weekly": "Weekly",
    "every_two_weeks": "Every second week",
    "custom": "Custom",
    "only_once": "Only once",
    "create_event_custom_recurring_cycle_invalid": "The provided cycle is invalid",
    "count_of_days": "Days",
    "count_of_months": "Months",
    "count_of_years": "Years",
    "generic_load_error": "An error occurred while loading",
    "save": "Save",
    "delete_event": "Delete event",
    "delete_event_security_question": "Tap again to delete",
    "actions": "Actions",
    "first_start.first_line": "I'm preparing stuff for you!",
    "first_start.line1": "Nearly ready. I Promise!",
    "first_start.line2": "Stop staring. I just cannot work when you do this!",
    "first_start.line3": "Weeeell... Seems like it takes a little longer ¯\\_(ツ)_/¯",
    "first_start.line4": "So boring...",
    "first_start.line5": "Just another coffee and we're ready to go!",
    "first_start.line6": "Keep calm! I'm at it!",
    "first_start.line7": "#!&? Oh no! I have to restart all over! >.<",
    "first_start.line8": "Here could be your ad!",
    "first_start.line9": "Just a little longer, nearly finished!",
    "first_start.line10": "Lorem ipsum...",
    "first_start.last_line": "Let's go!",
  };

  /// Get localized value by [key].
  String _get(String key) => _localizations[locale.languageCode][key];

  String get appVersion => _appVersion;

  String get appTitle => _get("app_title");

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

  String get roomSearch => _get("room_search");

  String get day => _get("day");

  String get from => _get("from");

  String get to => _get("to");

  String get roomSearchError => _get("room_search_error");

  String get seatCount => _get("seat_count");

  String get appointmentLoadError => _get("appointment_load_error");

  String get weekPlanLoadError => _get("weekplan_load_error");

  String get refresh => _get("refresh");

  String get version => _get("version");

  String get noEntries => _get("no_entries");

  String get moved => _get("moved");

  String get cancelled => _get("cancelled");

  String get roomChanged => _get("room_changed");

  String get changeTo => _get("change_to");

  String get changeAt => _get("change_at");

  String get title => _get("title");

  String get description => _get("description");

  String get location => _get("location");

  String get createEventTitleEmptyError => _get("create_event_title_empty_error");

  String get createCustomEvent => _get("create_custom_event");

  String get editCustomEvent => _get("edit_custom_event");

  String get details => _get("details");

  String get recurring => _get("recurring");

  String get create => _get("create");

  String get edit => _get("edit");

  String get daily => _get("daily");

  String get weekly => _get("weekly");

  String get everyTwoWeeks => _get("every_two_weeks");

  String get custom => _get("custom");

  String get onlyOnce => _get("only_once");

  String get createEventCustomRecurringCycleInvalid => _get("create_event_custom_recurring_cycle_invalid");

  String get countOfDays => _get("count_of_days");

  String get countOfMonths => _get("count_of_months");

  String get countOfYears => _get("count_of_years");

  String get genericLoadError => _get("generic_load_error");

  String get save => _get("save");

  String get deleteEvent => _get("delete_event");

  String get deleteEventSecurityQuestion => _get("delete_event_security_question");

  String get actions => _get("actions");

  String get firstStartFirstLine => _get("first_start.first_line");

  String get firstStartLastLine => _get("first_start.last_line");

  List<String> get firstStartLines => [
        _get("first_start.line1"),
        _get("first_start.line2"),
        _get("first_start.line3"),
        _get("first_start.line4"),
        _get("first_start.line5"),
        _get("first_start.line6"),
        _get("first_start.line7"),
        _get("first_start.line8"),
        _get("first_start.line9"),
        _get("first_start.line10"),
      ];
}
