import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/constants.dart';
import 'screens/webview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style to blend seamlessly with the dark sci-fi theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppConfig.primaryBg,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const SignalApp());
}

class SignalApp extends StatelessWidget {
  const SignalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConfig.primaryBg,
        canvasColor: AppConfig.primaryBg,
        colorScheme: const ColorScheme.dark(
          primary: AppConfig.cyan,
          secondary: AppConfig.magenta,
          surface: AppConfig.cardBg,
          onPrimary: AppConfig.primaryBg,
          onSecondary: Colors.white,
          onSurface: AppConfig.lightText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConfig.primaryBg,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppConfig.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          iconTheme: IconThemeData(color: AppConfig.cyan),
        ),
        fontFamily: 'Roboto',
      ),
      home: const WebViewScreen(),
    );
  }
}
