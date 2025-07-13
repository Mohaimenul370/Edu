import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'dart:async';

class GameProgressService {
  static const String _scorePrefix = 'game_score_';
  static const String _completedPrefix = 'game_completed_';
  static final List<String> requiredGames = [
    'fractions',
    'numbers_to_10',
    'numbers_to_20',
    'shapes',
    'fractions_2',
    'measures',
    'geometry',
    'time',
    'statistics',
    'measures_2',
    'positions_2',
    'statistics_2',
    'positions',
    'time_2',
    'geometry_2',
  ];

  static SharedPreferences? _prefs;
  static bool _isInitialized = false;
  static final Completer<void> _initCompleter = Completer<void>();

  // Initialize SharedPreferences with better error handling
  static Future<void> initialize() async {
    if (_isInitialized) {
      // Already initialized, return immediately
      return;
    }
    
    // If initialization is in progress, wait for it to complete
    if (!_initCompleter.isCompleted) {
      try {
        developer.log('Initializing GameProgressService...');
        _prefs = await SharedPreferences.getInstance();
        _isInitialized = true;
        _initCompleter.complete();
        developer.log('GameProgressService initialized successfully');
        
        // Validate stored data
        await _validateStoredData();
      } catch (e) {
        developer.log('Error initializing GameProgressService: $e');
        // If initialization fails, mark the completer as complete but set _isInitialized to false
        if (!_initCompleter.isCompleted) {
          _initCompleter.completeError(e);
        }
        // Re-throw to allow callers to handle the error
        rethrow;
      }
    } else {
      // Wait for the initialization that's already in progress
      await _initCompleter.future;
    }
  }
  
  // Validate stored data to ensure consistency
  static Future<void> _validateStoredData() async {
    developer.log('Validating stored game data...');
    
    // Check for potential data inconsistencies
    for (String gameId in requiredGames) {
      final hasScore = _prefs!.containsKey('${_scorePrefix}$gameId');
      final hasCompletion = _prefs!.containsKey('${_completedPrefix}$gameId');
      
      // If there's a completion status but no score, or vice versa, fix it
      if (hasScore != hasCompletion) {
        developer.log('Data inconsistency detected for $gameId: score=$hasScore, completion=$hasCompletion');
        
        if (hasScore && !hasCompletion) {
          // Has score but no completion status - compute and save completion
          final score = _prefs!.getDouble('${_scorePrefix}$gameId') ?? 0.0;
          final isCompleted = score >= 50.0;
          await _prefs!.setBool('${_completedPrefix}$gameId', isCompleted);
          developer.log('Fixed: Set completion status for $gameId to $isCompleted');
        } else if (!hasScore && hasCompletion) {
          // Has completion but no score - set a default score
          final isCompleted = _prefs!.getBool('${_completedPrefix}$gameId') ?? false;
          await _prefs!.setDouble('${_scorePrefix}$gameId', isCompleted ? 50.0 : 0.0);
          developer.log('Fixed: Set score for $gameId to ${isCompleted ? 50.0 : 0.0}%');
        }
      }
    }
    
    developer.log('Data validation complete');
  }

  static Future<void> saveGameProgress(String gameId, int score, int totalQuestions) async {
    try {
      await initialize();
      final percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0.0;
      final isCompleted = percentage >= 50.0;
      
      developer.log('Saving game progress for $gameId:');
      developer.log('Score: $score out of $totalQuestions');
      developer.log('Percentage: $percentage%');
      developer.log('Is completed: $isCompleted');
      
      // Save both values
      await _prefs!.setDouble('${_scorePrefix}$gameId', percentage);
      await _prefs!.setBool('${_completedPrefix}$gameId', isCompleted);
      
      // Use apply to batch the operations
      final success = await _prefs!.commit();
      
      if (!success) {
        developer.log('Warning: Save operation did not return success. Verifying save...');
      }
      
      // Verify the save
      final savedScore = await getGameScore(gameId);
      final savedCompleted = await isGameCompleted(gameId);
      
      if (savedScore != percentage || savedCompleted != isCompleted) {
        developer.log('Warning: Verification failed - saved values do not match expected values');
        developer.log('Expected: score=$percentage%, completed=$isCompleted');
        developer.log('Actual: score=$savedScore%, completed=$savedCompleted');
        // Try to save again
        await _prefs!.setDouble('${_scorePrefix}$gameId', percentage);
        await _prefs!.setBool('${_completedPrefix}$gameId', isCompleted);
        await _prefs!.commit();
      } else {
        developer.log('Verification successful: Score and completion status saved correctly');
      }
    } catch (e) {
      developer.log('Error saving game progress: $e');
      rethrow;
    }
  }

  static Future<double> getGameScore(String gameId) async {
    try {
      await initialize();
      final score = _prefs!.getDouble('${_scorePrefix}$gameId') ?? 0.0;
      return score;
    } catch (e) {
      developer.log('Error retrieving score for $gameId: $e');
      return 0.0;
    }
  }

  static Future<bool> isGameCompleted(String gameId) async {
    try {
      await initialize();
      final isCompleted = _prefs!.getBool('${_completedPrefix}$gameId') ?? false;
      return isCompleted;
    } catch (e) {
      developer.log('Error retrieving completion status for $gameId: $e');
      return false;
    }
  }

  static Future<bool> canAccessMathPlay() async {
    try {
      await initialize();
      int completedGamesCount = 0;
      int requiredCompletionCount = requiredGames.length;
      
      developer.log('Checking Math Play access...');
      for (String gameId in requiredGames) {
        final isCompleted = await isGameCompleted(gameId);
        developer.log('$gameId completed: $isCompleted');
        if (isCompleted) {
          completedGamesCount++;
        }
      }
      
      final allPassed = completedGamesCount >= requiredCompletionCount;
      developer.log('Math Play access: ${allPassed ? 'granted' : 'denied'} ($completedGamesCount/$requiredCompletionCount games completed)');
      return allPassed;
    } catch (e) {
      developer.log('Error checking Math Play access: $e');
      return false;
    }
  }

  static Future<Map<String, double>> getAllScores() async {
    try {
      await initialize();
      Map<String, double> scores = {};
      
      for (String gameId in requiredGames) {
        final score = await getGameScore(gameId);
        scores[gameId] = score;
      }
      
      return scores;
    } catch (e) {
      developer.log('Error retrieving all scores: $e');
      return {};
    }
  }

  // Get a map of completed status for all games
  static Future<Map<String, bool>> getAllCompletionStatus() async {
    try {
      await initialize();
      Map<String, bool> completionStatus = {};
      
      for (String gameId in requiredGames) {
        final isCompleted = await isGameCompleted(gameId);
        completionStatus[gameId] = isCompleted;
      }
      
      return completionStatus;
    } catch (e) {
      developer.log('Error retrieving completion status: $e');
      return {};
    }
  }

  // Clear all game progress (for testing purposes)
  static Future<void> clearAllProgress() async {
    try {
      await initialize();
      developer.log('Clearing all progress...');
      
      for (String gameId in requiredGames) {
        await _prefs!.remove('${_scorePrefix}$gameId');
        await _prefs!.remove('${_completedPrefix}$gameId');
      }
      
      await _prefs!.commit();
      developer.log('All progress cleared');
    } catch (e) {
      developer.log('Error clearing progress: $e');
      rethrow;
    }
  }
  
  // For debugging: print all stored values
  static Future<void> debugPrintAllValues() async {
    try {
      await initialize();
      developer.log('--- DEBUG: All Stored Values ---');
      
      final keys = _prefs!.getKeys();
      for (String key in keys) {
        final value = _prefs!.get(key);
        developer.log('$key = $value');
      }
      
      developer.log('--- End of Debug Values ---');
    } catch (e) {
      developer.log('Error printing debug values: $e');
    }
  }
} 