// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TARL Learning';

  @override
  String get homeGreeting => 'Welcome';

  @override
  String dailyHighlight(String kidName, String subject) {
    return '$kidName just passed a $subject test! Check the result.';
  }
}
