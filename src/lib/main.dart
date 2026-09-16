import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/decks_list_screen.dart';
import 'presentation/screens/deck_detail_screen.dart';
import 'presentation/screens/study_screen.dart';
import 'data/local/adapters/card_adapter.dart';
import 'data/local/adapters/deck_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Hive
  await Hive.initFlutter();
  
  // Регистрация адаптеров
  Hive.registerAdapter(CardAdapter());
  Hive.registerAdapter(DeckAdapter());
  
  // Открытие боксов
  await Hive.openBox('decks');
  await Hive.openBox('settings');
  
  runApp(const FlashcardsApp());
}

class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flashcards RU-EN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/decks',
      builder: (context, state) => const DecksListScreen(),
    ),
    GoRoute(
      path: '/deck/:id',
      builder: (context, state) {
        final deckId = state.pathParameters['id']!;
        return DeckDetailScreen(deckId: deckId);
      },
    ),
    GoRoute(
      path: '/study/:id',
      builder: (context, state) {
        final deckId = state.pathParameters['id']!;
        return StudyScreen(deckId: deckId);
      },
    ),
  ],
);
