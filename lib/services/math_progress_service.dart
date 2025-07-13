import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class MathProgressService {
  static late SharedPreferences _prefs;
  static bool _isInitialized = false;

  // Initialize SharedPreferences
  static Future<void> initialize() async {
    if (!_isInitialized) {
      developer.log('Initializing MathProgressService...');
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      developer.log('MathProgressService initialized successfully');
    }
  }

  // Update Numbers to 10 progress
  static Future<bool> updateNumbersTo10Progress(int percentage) async {
    if (!_isInitialized) await initialize();
    
    developer.log('Updating Numbers to 10 progress: $percentage%');
    
    // Save progress percentage
    await _prefs.setInt('numbers_to_10_progress', percentage);
    
    // Save completion status if percentage is high enough
    if (percentage >= 70) {
      await _prefs.setBool('numbers_to_10_completed', true);
    }
    
    // Save timestamp of last update
    await _prefs.setInt('numbers_to_10_last_update', DateTime.now().millisecondsSinceEpoch);
    
    return await _prefs.commit();
  }

  // Get Numbers to 10 progress
  static int getNumbersTo10Progress() {
    if (!_isInitialized) {
      developer.log('Warning: Trying to get Numbers to 10 progress before initialization');
      return 0;
    }
    final progress = _prefs.getInt('numbers_to_10_progress') ?? 0;
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
    };
    
    // Get next section
    final nextSection = sectionProgression[currentSection];
    if (nextSection != null) {
      // Unlock next section
      await _prefs.setBool('${nextSection}_unlocked', true);
      developer.log('Unlocked section: $nextSection');
      
      // Save unlock timestamp
      await _prefs.setInt('${nextSection}_unlock_time', DateTime.now().millisecondsSinceEpoch);
      
      return await _prefs.commit();
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
    
    final isUnlocked = _prefs.getBool('${section}_unlocked') ?? false;
    developer.log('Checking if section $section is unlocked: $isUnlocked');
    return isUnlocked;
  }
} 