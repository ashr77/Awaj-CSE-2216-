import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/main_app_screen.dart';
import 'screens/splash_screen.dart';
import 'theme_locale_provider.dart';
import 'l10n/l10n.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Supabase.initialize(
    url: 'https://vtgdgmpvgsdpmzczoakc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0Z2RnbXB2Z3NkcG16Y3pvYWtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5Mzk1MzksImV4cCI6MjA2NjUxNTUzOX0.lyEROVVDt9TPbAB_ZuhKJ2SCqMN-5dsLUf7Fk-r4Ufk',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeLocaleProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeLocaleProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Auth System',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: provider.themeMode,
          locale: provider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: SplashScreen(),
          routes: {
            '/home': (context) => HomeScreen(),
            '/signup': (context) => SignUpScreen(),
            '/signin': (context) => SignInScreen(),
            '/main': (context) => MainAppScreen(),
          },
        );
      },
    );
  }
}
