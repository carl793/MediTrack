import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/firebase_service.dart';
import 'services/local_storage_service.dart';
import 'state/meditrack_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Point to the Realtime Database (Asia Southeast 1 region)
  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://meditrack-firebase-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => MediTrackState(
        firebaseService: FirebaseService(db),
        localStorageService: LocalStorageService(prefs),
      ),
      child: const MediTrackApp(),
    ),
  );
}

class MediTrackApp extends StatelessWidget {
  const MediTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTrack',
      debugShowCheckedModeBanner: false,
      theme: MediTrackTheme.theme.copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          MediTrackTheme.theme.textTheme,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
