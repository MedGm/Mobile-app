// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تعلم TARL';

  @override
  String get homeGreeting => 'أهلًا بك';

  @override
  String dailyHighlight(String kidName, String subject) {
    return '$kidName نجح للتو في اختبار $subject، اطّلع على النتيجة';
  }
}
