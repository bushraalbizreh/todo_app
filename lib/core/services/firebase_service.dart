import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Optional Firebase wiring. The application remains local-first when Firebase
/// is unavailable (for example in widget tests or an offline first launch).
class FirebaseService {
  const FirebaseService({this.firestore, this.auth});

  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  bool get isAvailable => firestore != null && auth != null;

  static Future<FirebaseService> initialize() async {
    try {
      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Diagnostic B: Firebase initialization succeeded — report the actual
      // runtime project so a wrong-project misconfiguration is visible.
      final projectId = app.options.projectId;
      if (kDebugMode) {
        debugPrint(
          '[FIREBASE] B) initialization succeeded: project=$projectId '
          'apps=${Firebase.apps.length}',
        );
        if (projectId != 'to-do-app-55081') {
          debugPrint(
            '[FIREBASE] WARNING: runtime project "$projectId" does not match '
            'expected "to-do-app-55081"',
          );
        }
      }
      final firestore = FirebaseFirestore.instanceFor(app: app);
      if (kDebugMode) {
        // The instance is bound to the exact app above: any other project or
        // an emulator connection would show up here.
        debugPrint(
          '[FIREBASE] Firestore instance bound to project '
          '${firestore.app.options.projectId} (database "(default)", no '
          'emulator)',
        );
      }
      return FirebaseService(
        firestore: firestore,
        auth: FirebaseAuth.instanceFor(app: app),
      );
    } catch (error, stackTrace) {
      // Diagnostic B: initialization failed — never swallow the reason; the
      // app falls back to local-only and the exact error stays visible.
      if (kDebugMode) {
        debugPrint('[FIREBASE] B) initialization FAILED: $error');
        debugPrint('$stackTrace');
      }
      return const FirebaseService();
    }
  }
}
