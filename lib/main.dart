import 'package:biblioteca1/firebase_options.dart';
import 'package:biblioteca1/screens/my_book_detail_screen.dart';
import 'package:biblioteca1/screens/my_favorites_screen.dart';
import 'package:biblioteca1/screens/my_home_screen.dart';
import 'package:biblioteca1/screens/my_login_screen.dart';
import 'package:biblioteca1/screens/my_lido_list_screen.dart';
import 'package:biblioteca1/screens/my_register_screen.dart';
import 'package:biblioteca1/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:biblioteca1/screens/my_splash_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblioteca Digital',
      theme: ThemeData(
        primaryColor: Color(0xFF9D6550),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF9D6550),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.brown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
          ),
          elevation: 3,
        ),
      ),
      initialRoute: '/splash',
      navigatorObservers: [routeObserver],
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const AuthCheck(),
        '/login': (context) => TelaLogin(),
        '/registar': (context) => TelaRegisto(),
        '/home': (context) => const HomeScreen(),
        '/detalhes': (context) => const BookDetailScreen(),
        '/favoritos': (context) => const FavoritesScreen(),
        '/livros-lidos': (context) => const ReadListScreen(),
      },
    );
  }
}

// Widget para verificar autenticação
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return user != null ? const HomeScreen() : TelaLogin();
  }
}
