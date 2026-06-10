import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hệ thống Quản lý Yêu cầu Sinh viên',
      themeMode: themeProvider.themeMode,
      
      // Theme Sáng
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Màu AppBar sáng
          foregroundColor: Colors.black,  // Màu chữ/icon trên AppBar
          elevation: 0,
        ),
      ),
      
      // Theme Tối
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Nền tối hơn
        cardColor: const Color(0xFF1E1E1E),              // Màu thẻ tối
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212), // Màu AppBar tối
          foregroundColor: Colors.white,      // Màu chữ/icon trên AppBar
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF42A5F5), // Màu nhấn
          surface: Color(0xFF121212),
        ),
      ),
      
      home: const LoginScreen(),
    );
  }
}