import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class SharedPreferenceService {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;
  static const String _mathPlayKey = 'math_play_percentage';

  static const List<String> allChapters = [
    'numbers_to_10',
    'numbers_to_20',
    'shapes',
    'fractions',
    'fractions_2',
    'geometry',
    'geometry_2',
    'measures',
    'measures_2',
    'positions',
    'statistics',
    'time',
    'statistics_2',
    'time_2',
    'position_patterns_2'
  ];

  // Initialize SharedPreferences
  static Future<void> initialize() async {
    if (!_isInitialized) {
      developer.log('Initializing SharedPreferenceService...');
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      developer.log('SharedPreferenceService initialized successfully');
    }
  }

  // GAME PROGRESS METHODS
  
  // Save game progress
  static Future<bool> saveGameProgress(String gameId, int score, int totalQuestions) async {
    if (!_isInitialized) await initialize();
    
    developer.log('Saving game progress for $gameId:');
    developer.log('Score: $score out of $totalQuestions');
    
    final percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0.0;
    final isCompleted = percentage >= 50.0;
    
    developer.log('Percentage: $percentage%');
    developer.log('Is completed: $isCompleted');
    
    // Save all relevant data
    await Future.wait([
      setGamePercentage(gameId, percentage),
      setGameCompleted(gameId, isCompleted),
    ]);
    
    // Force immediate progress update
    await _updateOverallProgress();
    
    return true;
  }

  // Get game score
  static int getGameScore(String gameId) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get game score before initialization');
      return 0;
    }
    final score = _prefs!.getInt('${gameId}_score') ?? 0;
    developer.log('Getting game score for $gameId: $score');
    return score;
  }

  // Get total questions
  static int getTotalQuestions(String gameId) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get total questions before initialization');
      return 0;
    }
    final total = _prefs!.getInt('${gameId}_totalQuestions') ?? 0;
    developer.log('Getting total questions for $gameId: $total');
    return total;
  }

  // Get game completion percentage
  static double getGamePercentage(String gameId) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get game percentage before initialization');
      return 0.0;
    }
    
    // Special handling for Numbers to 10 chapter
    if (gameId == 'numbers_to_10') {
      final percentage = _prefs!.getDouble('${gameId}_score') ?? 
                        _prefs!.getDouble('${gameId}_percentage') ?? 0.0;
      developer.log('Getting game percentage for $gameId: $percentage%');
      return percentage;
    }
    
    final percentage = _prefs!.getDouble('${gameId}_score') ?? 0.0;
    developer.log('Getting game percentage for $gameId: $percentage%');
    return percentage;
  }

  // Set game percentage for a specific chapter/game
  static Future<void> setGamePercentage(String gameId, double percentage) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting game percentage for $gameId: $percentage%');
    
    // Special handling for Numbers to 10 chapter
    if (gameId == 'numbers_to_10') {
      await _prefs!.setDouble('${gameId}_percentage', percentage);
    }
    
    await _prefs!.setDouble('${gameId}_score', percentage);
    await _updateOverallProgress();
  }

  // Check if game is completed
  static bool isGameCompleted(String gameId) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to check game completion before initialization');
      return false;
    }
    final isCompleted = _prefs!.getBool('${gameId}_completed') ?? false;
    developer.log('Checking if game $gameId is completed: $isCompleted');
    return isCompleted;
  }

  // Set completion status for a specific chapter/game
  static Future<void> setGameCompleted(String gameId, bool completed) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting game completion for $gameId: $completed');
    await _prefs!.setBool('${gameId}_completed', completed);
    await _updateOverallProgress();
  }
  
  // Get all game IDs with saved progress
  static List<String> getAllGameIds() {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get all game IDs before initialization');
      return [];
    }
    
    final Set<String> gameIds = {};
    final keyPattern = RegExp(r'(.+)_score');
    
    for (final key in _prefs!.getKeys()) {
      final match = keyPattern.firstMatch(key);
      if (match != null && match.groupCount >= 1) {
        gameIds.add(match.group(1)!);
      }
    }
    
    developer.log('Found ${gameIds.length} games with saved progress: $gameIds');
    return gameIds.toList();
  }

  // GENERAL PREFERENCE METHODS

  // Save an integer value
  static Future<bool> setInt(String key, int value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting int: $key = $value');
    return await _prefs!.setInt(key, value);
  }

  // Get an integer value
  static int? getInt(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get int value before initialization');
      return null;
    }
    final value = _prefs!.getInt(key);
    developer.log('Getting int: $key = $value');
    return value;
  }

  // Save a boolean value
  static Future<bool> setBool(String key, bool value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting bool: $key = $value');
    return await _prefs!.setBool(key, value);
  }

  // Get a boolean value
  static bool? getBool(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get bool value before initialization');
      return null;
    }
    final value = _prefs!.getBool(key);
    developer.log('Getting bool: $key = $value');
    return value;
  }

  // Save a double value
  static Future<bool> setDouble(String key, double value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting double: $key = $value');
    return await _prefs!.setDouble(key, value);
  }

  // Get a double value
  static double? getDouble(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get double value before initialization');
      return null;
    }
    final value = _prefs!.getDouble(key);
    developer.log('Getting double: $key = $value');
    return value;
  }

  // Save a string value
  static Future<bool> setString(String key, String value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting string: $key = $value');
    return await _prefs!.setString(key, value);
  }

  // Get a string value
  static String? getString(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get string value before initialization');
      return null;
    }
    final value = _prefs!.getString(key);
    developer.log('Getting string: $key = $value');
    return value;
  }

  // Save a string list
  static Future<bool> setStringList(String key, List<String> value) async {
    if (!_isInitialized) await initialize();
    developer.log('Setting string list: $key = $value');
    return await _prefs!.setStringList(key, value);
  }

  // Get a string list
  static List<String>? getStringList(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get string list before initialization');
      return null;
    }
    final value = _prefs!.getStringList(key);
    developer.log('Getting string list: $key = $value');
    return value;
  }

  // Remove a specific key
  static Future<bool> remove(String key) async {
    if (!_isInitialized) await initialize();
    developer.log('Removing key: $key');
    return await _prefs!.remove(key);
  }

  // Clear all preferences
  static Future<bool> clear() async {
    if (!_isInitialized) await initialize();
    developer.log('Clearing all preferences');
    return await _prefs!.clear();
  }



  // Check if key exists
  static bool containsKey(String key) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to check key before initialization');
      return false;
    }
    final contains = _prefs!.containsKey(key);
    developer.log('Checking if contains key: $key = $contains');
    return contains;
  }
  
  // Get all keys
  static Set<String> getKeys() {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get keys before initialization');
      return {};
    }
    final keys = _prefs!.getKeys();
    developer.log('Getting all keys: $keys');
    return keys;
  }

  // MATH SECTION SPECIFIC METHODS

  // Update Numbers to 10 progress
  static Future<bool> updateNumbersTo10Progress(int percentage) async {
    if (!_isInitialized) await initialize();
    
    developer.log('Updating Numbers to 10 progress: $percentage%');
    
    // Save progress percentage
    await _prefs!.setInt('numbers_to_10_progress', percentage);
    
    // Save completion status if percentage is high enough
    if (percentage >= 70) {
      await _prefs!.setBool('numbers_to_10_completed', true);
    }
    
    // Save timestamp of last update
    await _prefs!.setInt('numbers_to_10_last_update', DateTime.now().millisecondsSinceEpoch);
    
    return await commit();
  }

  // Get Numbers to 10 progress
  static int getNumbersTo10Progress() {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get Numbers to 10 progress before initialization');
      return 0;
    }
    final progress = _prefs!.getInt('numbers_to_10_progress') ?? 0;
    developer.log('Getting Numbers to 10 progress: $progress%');
    return progress;
  }

  // Unlock next math section
  static Future<bool> unlockNextMathSection(String currentSection) async {
    if (!_isInitialized) await initialize();
    
    developer.log('Unlocking next section after: $currentSection');
    
    // Map of section progression
    final sectionProgression = {
      'numbers_to_10': 'numbers_to_20',
      'numbers_to_20': 'addition',
      'addition': 'subtraction',
      'subtraction': 'multiplication',
      'multiplication': 'division',
      // Add more sections as needed
    };
    
    // Get next section
    final nextSection = sectionProgression[currentSection];
    if (nextSection != null) {
      // Unlock next section
      await _prefs!.setBool('${nextSection}_unlocked', true);
      developer.log('Unlocked section: $nextSection');
      
      // Save unlock timestamp
      await _prefs!.setInt('${nextSection}_unlock_time', DateTime.now().millisecondsSinceEpoch);
      
      return await commit();
    }
    
    developer.log('No next section found for: $currentSection');
    return false;
  }

  // Check if a math section is unlocked
  static bool isMathSectionUnlocked(String section) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to check section unlock status before initialization');
      return false;
    }
    
    // First section is always unlocked
    if (section == 'numbers_to_10') return true;
    
    final isUnlocked = _prefs!.getBool('${section}_unlocked') ?? false;
    developer.log('Checking if section $section is unlocked: $isUnlocked');
    return isUnlocked;
  }

  // Get last update timestamp for a section
  static DateTime? getSectionLastUpdate(String section) {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get section last update before initialization');
      return null;
    }
    
    final timestamp = _prefs!.getInt('${section}_last_update');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  // Commit changes to disk (important for some platforms)
  static Future<bool> commit() async {
    if (!_isInitialized) {
      developer.log('Warning: Trying to commit before initialization');
      return false;
    }
    developer.log('Committing changes to disk');
    return await _prefs!.commit();
  }
  
  // Debug: Print all stored values
  static void debugPrintAllValues() {
    if (!_isInitialized) {
      developer.log('Warning: Trying to print values before initialization');
      return;
    }
    
    developer.log('=== Debug Values ===');
    for (String key in _prefs!.getKeys()) {
      developer.log('$key: ${_prefs!.get(key)}');
    }
    developer.log('=== End of Debug Values ===');
  }

  static Future<void> resetAllProgress() async {
    try {
      if (!_isInitialized) await initialize();
      developer.log('Resetting all game progress');

      // Reset progress for all chapters
      for (String chapter in allChapters) {
        await setGamePercentage(chapter, 0.0);
        await setGameCompleted(chapter, false);
      }

      // Reset math play percentage and access
      await _prefs!.setDouble(_mathPlayKey, 0.0);
      await _prefs!.setBool('can_access_math_play', false);

      // Clear all game-related data
      final keys = _prefs!.getKeys();
      for (String key in keys) {
        if (key.startsWith('game_') || 
            key.contains('_score') || 
            key.contains('_completed') || 
            key.contains('_total') ||
            key.contains('_percentage') ||
            key.contains('_unlocked') ||
            key.contains('_progress')) {
          await _prefs!.remove(key);
        }
      }
      
      developer.log('All progress has been reset successfully');
    } catch (e) {
      developer.log('Error resetting progress: $e');
      rethrow;
    }
  }



  // Update overall progress based on chapter completion
  static Future<void> _updateOverallProgress() async {
    if (!_isInitialized) await initialize();
    
    int completedChapters = 0;
    for (var chapter in allChapters) {
      if (isGameCompleted(chapter)) {
        completedChapters++;
      }
    }
    
    final overallProgress = (completedChapters / allChapters.length) * 100;
    await _prefs!.setDouble(_mathPlayKey, overallProgress);
    developer.log('Overall progress updated: $overallProgress%');
  }

  // Get overall progress
  static double getOverallProgress() {
    final progress = _prefs?.getDouble(_mathPlayKey) ?? 0.0;
    final roundedProgress = double.parse(progress.toStringAsFixed(2)); // Round to 2 decimal places
    return roundedProgress; // No need to clamp here as it's already handled in _updateOverallProgress
  }
} 