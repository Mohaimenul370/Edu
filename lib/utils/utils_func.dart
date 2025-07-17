import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kg_education_app/services/shared_preference_service.dart';

void showGameCompletionDialog(
    BuildContext context,
    int score,
    List<Object> gameQuestions,
    Function setState,
    Function startGame,
    String lessonName) {
  SharedPreferenceService.saveGameProgress(
    lessonName,
    score,
    gameQuestions.length,
  );
  SharedPreferenceService.updateOverallProgress();
  final percentage = (score / gameQuestions.length) * 100;
  final isPassed = percentage >= 50.0;
  setState(() {});
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPassed
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPassed ? Icons.emoji_events : Icons.school,
                size: 48,
                color: isPassed ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              isPassed ? 'Congratulations!' : 'Keep Practicing!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isPassed ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            // Score Display
            Text(
              'Score: $score/${gameQuestions.length} (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Message
            Text(
              isPassed
                  ? 'You\'ve completed the $lessonName practice!'
                  : 'You\'re making progress! Keep practicing to improve.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Buttons
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    startGame();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> speakText(String text) async {
  final tts = FlutterTts();
  await tts.setVoice({
    "name": "en-GB-language",
    "locale": "en-GB"
  }); // Google UK English Female
  await tts.setSpeechRate(.8); // Set a faster speech rate
  await tts.awaitSpeakCompletion(true);
  await tts.speak(text);
}
