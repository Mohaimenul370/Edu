import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'services/game_progress_service.dart';
import 'services/shared_preference_service.dart';
import 'screens/alphabet_screen.dart';
import 'screens/numbers_screen.dart';
import 'screens/games_screen.dart';
import 'screens/shapes_screen.dart';
import 'screens/fractions_screen.dart';
import 'screens/fractions_2_screen.dart';
import 'screens/measures_screen.dart';
import 'screens/numbers_to_10_screen.dart';
import 'screens/numbers_to_10_chapter_screen.dart';
import 'screens/numbers_to_20_screen.dart';
import 'screens/numbers_to_20_chapter_screen.dart';
import 'screens/positions_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/statistics_2_screen.dart';
import 'screens/time_screen.dart';
import 'screens/geometry_2_screen.dart';
import 'screens/measures_2_screen.dart';
import 'screens/statistics_2_chapter_screen.dart';
import 'screens/time_2_screen.dart';
import 'screens/position_patterns_2_screen.dart';
import 'screens/play_screen.dart';
import 'screens/geometry_screen.dart';
import 'screens/math_play_screen.dart';
import 'package:flutter/services.dart';
import 'package:kg_education_app/services/hive_service.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shapes_chapter_screen.dart';
import 'screens/fractions_chapter_screen.dart';
import 'screens/fractions_2_chapter_screen.dart';
import 'screens/measures_chapter_screen.dart';
import 'screens/time_chapter_screen.dart';
import 'screens/statistics_chapter_screen.dart';
import 'screens/positions_chapter_screen.dart';
import 'screens/geometry_chapter_screen.dart';
import 'screens/geometry_2_chapter_screen.dart';
import 'screens/time_2_chapter_screen.dart';
import 'screens/measures_2_chapter_screen.dart';
import 'screens/position_patterns_2_chapter_screen.dart';

void main() async {
  try {
    // Initialize Flutter binding first
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Hive
    await HiveService.initialize();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style globally
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF6A1B9A),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF6A1B9A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    
    // Log start of initialization
    print('Starting application initialization...');
    
    // Initialize SharedPreferenceService
    print('Initializing SharedPreferenceService...');
    await SharedPreferenceService.initialize();
    print('SharedPreferenceService initialized successfully');
    
    // For backward compatibility, also initialize GameProgressService
    print('Initializing GameProgressService for backward compatibility...');
    await GameProgressService.initialize();
    print('GameProgressService initialized successfully');
    
    // Debug: Print all stored values to verify initialization
    SharedPreferenceService.debugPrintAllValues();
    
    // Start the app
    print('Starting application...');
    runApp(const MyApp());
  } catch (e) {
    // Critical error handling
    print('CRITICAL ERROR during app initialization: $e');
    // Still try to run the app even if initialization failed
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KG Education App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          primary: const Color(0xFF6A1B9A),
          secondary: Colors.orange,
          background: const Color(0xFFF3E6FA),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        fontFamily: 'Comic Sans MS',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/math_play': (context) => const PlayScreen(),
        '/numbers_to_10': (context) => const NumbersTo10ChapterScreen(),
        '/numbers_to_10_learn': (context) => const NumbersTo10Screen(isGameMode: false),
        '/numbers_to_10_game': (context) => const NumbersTo10Screen(isGameMode: true),
        '/numbers_to_20': (context) => const NumbersTo20ChapterScreen(),
        '/numbers_to_20_learn': (context) => const NumbersTo20Screen(isGameMode: false),
        '/numbers_to_20_game': (context) => const NumbersTo20Screen(isGameMode: true),
        '/shapes': (context) => const ShapesChapterScreen(),
        '/vocab': (context) => const AlphabetScreen(),
        '/analysis': (context) => const StatisticsChapterScreen(),
        '/statistics_learn': (context) => const StatisticsScreen(isGameMode: false),
        '/statistics_game': (context) => const StatisticsScreen(isGameMode: true),
        '/settings': (context) => const SettingsScreen(),
        '/fractions': (context) => const FractionsChapterScreen(),
        '/fractions_2': (context) => const Fractions2ChapterScreen(),
        '/fractions_2_learn': (context) => const Fractions2Screen(isGameMode: false),
        '/fractions_2_game': (context) => const Fractions2Screen(isGameMode: true),
        '/measures': (context) => const MeasuresChapterScreen(),
        '/measures_learn': (context) => const MeasuresScreen(isGameMode: false),
        '/measures_game': (context) => const MeasuresScreen(isGameMode: true),
        '/time': (context) => const TimeChapterScreen(),
        '/time_learn': (context) => const TimeScreen(isGameMode: false),
        '/time_game': (context) => const TimeScreen(isGameMode: true),
        '/position_patterns_2': (context) => const PositionPatterns2ChapterScreen(),
        '/position_patterns_2/learn': (context) => const PositionPatterns2Screen(isGameMode: false),
        '/position_patterns_2/game': (context) => const PositionPatterns2Screen(isGameMode: true),
        '/geometry': (context) => const GeometryChapterScreen(),
        '/geometry/learn': (context) => const GeometryScreen(isGameMode: false),
        '/geometry/game': (context) => const GeometryScreen(isGameMode: true),
        '/time_2': (context) => const Time2ChapterScreen(),
        '/time_2/learn': (context) => const Time2Screen(isGameMode: false),
        '/time_2/game': (context) => const Time2Screen(isGameMode: true),
        '/statistics_2': (context) => const Statistics2ChapterScreen(),
        '/statistics_2/learn': (context) => const Statistics2Screen(isGameMode: false),
        '/statistics_2/game': (context) => const Statistics2Screen(isGameMode: true),
        '/positions': (context) => const PositionsChapterScreen(),
        '/positions/learn': (context) => const PositionsScreen(isGameMode: false),
        '/positions/game': (context) => const PositionsScreen(isGameMode: true),
        '/measures_2': (context) => const Measures2ChapterScreen(),
        '/measures_2/learn': (context) => const Measures2Screen(isGameMode: false),
        '/measures_2/game': (context) => const Measures2Screen(isGameMode: true),
        '/play': (context) => const PlayScreen(),
        '/geometry_2': (context) => const Geometry2ChapterScreen(),
        '/geometry_2/learn': (context) => const Geometry2Screen(isGameMode: false),
        '/geometry_2/game': (context) => const Geometry2Screen(isGameMode: true),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/statistics') {
          final args = settings.arguments as Map<String, dynamic>?;
          final isGameMode = args != null && args['isGameMode'] == true;
          return MaterialPageRoute(
            builder: (context) => StatisticsScreen(isGameMode: isGameMode),
          );
        }
        // fallback to default
        return null;
      },
    );
  }
}
