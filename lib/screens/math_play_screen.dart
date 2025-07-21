import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kg_education_app/services/game_progress_service.dart';
import 'package:kg_education_app/services/shared_preference_service.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

class MathQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String chapter;
  final String? imageAsset;

  MathQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.chapter,
    this.imageAsset,
  });
}

class MathPlayScreen extends StatefulWidget {
  const MathPlayScreen({super.key});

  @override
  State<MathPlayScreen> createState() => _MathPlayScreenState();
}

class _MathPlayScreenState extends State<MathPlayScreen> {
  final Map<String, double> _gameScores = {};
  final Map<String, bool> _gameCompleted = {};
  double _mathPlayPercentage = 0.0;
  bool _canStartPractice = false;

  @override
  void initState() {
    super.initState();
    _loadGameScores();
  }

  Future<void> _loadGameScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gameScores.clear();
      _gameCompleted.clear();

      // Load scores for each chapter
      for (var chapter in chapters) {
        final route = chapter['route'].toString().substring(1);
        final score = prefs.getDouble('${route}_score') ?? 0.0;
        final completed = prefs.getBool('${route}_completed') ?? false;
        _gameScores[route] = score;
        _gameCompleted[route] = completed;
      }

      // Calculate Math Play percentage
      int completedChapters = 0;
      for (var entry in _gameScores.entries) {
        if (_gameCompleted[entry.key] == true || entry.value >= 50.0) {
          completedChapters++;
        }
      }
      _mathPlayPercentage = (completedChapters / 15) * 100;
      _canStartPractice = _mathPlayPercentage >= 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true; // Allow default back behavior
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF6A1B9A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Math Play',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Complete all 15 chapters to unlock Math Play!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _mathPlayPercentage / 100,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '${_mathPlayPercentage.toStringAsFixed(1)}% Complete',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _canStartPractice ? () {
                  Navigator.pushNamed(context, '/play');
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Start Practice',
                  style: TextStyle(
                    fontSize: 18,
                    color: _canStartPractice 
                        ? const Color(0xFF6A1B9A)
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: chapters.length - 1, // Excluding Math Play itself
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    if (chapter['title'] == 'Math Play') return const SizedBox.shrink();
                    
                    final route = chapter['route'].toString().substring(1);
                    final score = _gameScores[route] ?? 0.0;
                    final isComplete = _gameCompleted[route] ?? false;
                    final passed = isComplete || score >= 50.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            passed ? Icons.check_circle : Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              chapter['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '${score.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> chapters = [
  {'title': 'Numbers to 10', 'route': '/numbers_to_10'},
  {'title': 'Numbers to 20', 'route': '/numbers_to_20'},
  {'title': 'Shapes', 'route': '/shapes'},
  {'title': 'Fractions', 'route': '/fractions'},
  {'title': 'Fractions 2', 'route': '/fractions_2'},
  {'title': 'Geometry', 'route': '/geometry'},
  {'title': 'Geometry 2', 'route': '/geometry_2'},
  {'title': 'Measures', 'route': '/measures'},
  {'title': 'Measures 2', 'route': '/measures_2'},
  {'title': 'Positions', 'route': '/positions'},
  {'title': 'Statistics', 'route': '/statistics'},
  {'title': 'Time', 'route': '/time'},
  {'title': 'Statistics 2', 'route': '/statistics_2'},
  {'title': 'Time 2', 'route': '/time_2'},
  {'title': 'Position Patterns 2', 'route': '/position_patterns_2'},

]; 