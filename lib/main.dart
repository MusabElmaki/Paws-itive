import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/utm_pawsitive_app.dart';
import 'firebase_options.dart';

export 'app/utm_pawsitive_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const UtmPawsitiveApp());
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unable to connect. Check your connection and retry.',
                ),
                FilledButton(onPressed: main, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
