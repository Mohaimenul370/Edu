import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static const String gameProgressBox = 'gameProgressBox';
  static const String gameScoresBox = 'gameScoresBox';
  static const String gameCompletedBox = 'gameCompletedBox';

  static Future<void> initialize() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    
    // Open boxes
    await Hive.openBox(gameProgressBox);
    await Hive.openBox(gameScoresBox);
    await Hive.openBox(gameCompletedBox);
  }

  static Future<void> saveGameProgress(String gameId, int score, int totalQuestions) async {
    final progressBox = Hive.box(gameProgressBox);
    final scoresBox = Hive.box(gameScoresBox);
    final completedBox = Hive.box(gameCompletedBox);

    // Save progress
    await progressBox.put('${gameId}_score', score);
    await progressBox.put('${gameId}_total', totalQuestions);
    
    // Calculate and save percentage
    final percentage = (score / totalQuestions) * 100;
    await progressBox.put('${gameId}_percentage', percentage);
    
    // Save score
    await scoresBox.put('${gameId}_score', score.toDouble());
    
    // Mark as completed if score is good enough
    final isCompleted = score >= totalQuestions / 2;
    await completedBox.put('${gameId}_completed', isCompleted);
  }

  static int getGameScore(String gameId) {
    final progressBox = Hive.box(gameProgressBox);
    return progressBox.get('${gameId}_score', defaultValue: 0);
  }

  static double getGamePercentage(String gameId) {
    final progressBox = Hive.box(gameProgressBox);
    return progressBox.get('${gameId}_percentage', defaultValue: 0.0);
  }

  static bool isGameCompleted(String gameId) {
    final completedBox = Hive.box(gameCompletedBox);
    return completedBox.get('${gameId}_completed', defaultValue: false);
  }

  static Future<void> resetGameProgress(String gameId) async {
    final progressBox = Hive.box(gameProgressBox);
    final scoresBox = Hive.box(gameScoresBox);
    final completedBox = Hive.box(gameCompletedBox);

    await progressBox.delete('${gameId}_score');
    await progressBox.delete('${gameId}_total');
    await progressBox.delete('${gameId}_percentage');
    await scoresBox.delete('${gameId}_score');
    await completedBox.delete('${gameId}_completed');
  }

  static Map<String, dynamic> getAllGameProgress() {
    final progressBox = Hive.box(gameProgressBox);
    final scoresBox = Hive.box(gameScoresBox);
    final completedBox = Hive.box(gameCompletedBox);

    final Map<String, dynamic> progress = {};
    
    for (var key in progressBox.keys) {
      if (key.toString().endsWith('_score')) {
        final gameId = key.toString().replaceAll('_score', '');
        progress[gameId] = {
          'score': progressBox.get(key),
          'total': progressBox.get('${gameId}_total'),
          'percentage': progressBox.get('${gameId}_percentage'),
          'completed': completedBox.get('${gameId}_completed'),
        };
      }
    }

    return progress;
  }
} 