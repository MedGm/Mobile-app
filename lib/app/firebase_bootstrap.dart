import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarl_mobile_app/firebase_options.dart';

/// Initializes Firebase if possible.
/// Returns true if Firebase is available, false otherwise.
Future<bool> ensureFirebaseInitialized() async {
  try {
    if (Firebase.apps.isEmpty) {
      // Prefer generated options when available
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        // Linux or unsupported: skip initializing with options
        // Attempt a plain initialize; may still be unsupported.
        await Firebase.initializeApp();
      }
    }
    return true;
  } catch (_) {
    // Likely missing firebase_options.dart or platform config; continue without Firebase.
    return false;
  }
}

/// Exposes Firebase readiness to the app.
final firebaseReadyProvider = FutureProvider<bool>((ref) async {
  return ensureFirebaseInitialized();
});
