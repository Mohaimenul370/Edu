import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kg_education_app/services/hive_service.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import 'package:kg_education_app/widgets/confetti_widget.dart';
import 'package:kg_education_app/widgets/position_visual.dart';
import 'package:kg_education_app/widgets/pattern_visual.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/game_progress_service.dart';
import '../services/shared_preference_service.dart';

class PositionPatternConcept {
  final String name;
  final String description;
  final Widget visual;
  final String example;
  final List<String> options;

  PositionPatternConcept({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
    required this.options,
  });
}

class PositionPatterns2Screen extends StatefulWidget {
  final bool isGameMode;
  const PositionPatterns2Screen({super.key, this.isGameMode = false});

  @override
  State<PositionPatterns2Screen> createState() => _PositionPatterns2ScreenState();
}

class _PositionPatterns2ScreenState extends State<PositionPatterns2Screen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<PositionPatternConcept> shuffledConcepts = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerScaleAnimation;
  bool _isLoading = true;
  
  // Maps to track game progress across different games
  Map<String, double> _gameScores = {};
  Map<String, bool> _gameCompleted = {};

  final List<PositionPatternConcept> concepts = [
    PositionPatternConcept(
      name: 'Color Patterns',
      description: 'Understanding color patterns',
      visual: _buildPatternVisual(['🔴', '🟡', '🔴', '🟡']),
      example: '🔴',
      options: [
        '🔴',
        '🟡',
        '🟢',
        '🔵',
        '🟣',
      ],
    ),
    PositionPatternConcept(
      name: 'Shape Patterns',
      description: 'Understanding shape patterns',
      visual: _buildPatternVisual(['⭐', '🔺', '⭐', '🔺']),
      example: '⭐',
      options: [
        '⭐',
        '🔺',
        '🔵',
        '🟢',
        '🔴',
      ],
    ),
    PositionPatternConcept(
      name: 'Size Patterns',
      description: 'Understanding size patterns',
      visual: _buildSizePatternVisual(['big', 'small', 'big', 'small']),
      example: 'big',
      options: [
        'big',
        'small',
        'medium',
        'tiny',
        'large',
      ],
    ),
    PositionPatternConcept(
      name: 'Number Patterns',
      description: 'Understanding number patterns',
      visual: _buildNumberPatternVisual([1, 2, 3, 4]),
      example: '5',
      options: [
        '5',
        '6',
        '8',
        '4',
        '7',
      ],
    ),
    PositionPatternConcept(
      name: 'Between',
      description: 'Understanding the concept of between',
      visual: _buildPatternVisual(['🍎', '🍌', '🍊']),
      example: '🍌',
      options: [
        '🍎',
        '🍌',
        '🍊',
        '🍇',
        '🍉',
      ],
    ),
    PositionPatternConcept(
      name: 'Inside and Outside',
      description: 'Understanding inside and outside positions',
      visual: _buildPatternVisual(['⬛️', '⚽️']), // e.g., ball outside a box
      example: 'outside',
      options: [
        'inside',
        'outside',
        'above',
        'below',
        'next to',
      ],
    ),
  ];

  static Widget _buildPositionVisual(String emoji, String position) {
    return PositionVisual(emoji: emoji, position: position);
  }

  static Widget _buildPatternVisual(List<String> pattern) {
    return PatternVisual(pattern: pattern);
  }

  static Widget _buildSizePatternVisual(List<String> pattern) {
    return PatternVisual(pattern: pattern, type: 'size');
  }

  static Widget _buildNumberPatternVisual(List<dynamic> pattern) {
    return PatternVisual(
      pattern: pattern.map((n) => n.toString()).toList(),
      type: 'number',
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeTts();
    isGameMode = widget.isGameMode;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _answerScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _answerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _initializeStorage();

    // FIX: If starting in game mode, initialize shuffledConcepts
    if (isGameMode) {
      shuffledConcepts = List.from(concepts)..shuffle();
      for (var concept in shuffledConcepts) {
        concept.options.shuffle();
      }
    }
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _initializeStorage() async {
    try {
      await PreferenceService.initialize();
      await SharedPreferenceService.initialize();
      await _loadGameState();
      await _loadScores();
      
      // Debug: Print all values to verify initialization
      developer.log('=== Debug: All SharedPreference values after initialization ===');
      SharedPreferenceService.debugPrintAllValues();
    } catch (e) {
      developer.log('Error initializing storage: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadScores() async {
    try {
      developer.log('Loading game scores from SharedPreferenceService...');
      
      // Load numbers_to_10 progress
      final numbersScore = SharedPreferenceService.getGameScore('numbers_to_10');
      final numbersIsCompleted = SharedPreferenceService.isGameCompleted('numbers_to_10');
      final numbersPercentage = SharedPreferenceService.getGamePercentage('numbers_to_10');

      // Load position_patterns_2 progress
      final patternsScore = SharedPreferenceService.getGameScore('position_patterns_2');
      final patternsIsCompleted = SharedPreferenceService.isGameCompleted('position_patterns_2');
      final patternsPercentage = SharedPreferenceService.getGamePercentage('position_patterns_2');
      
      // Log the loaded scores
      developer.log('Loaded scores:');
      developer.log('numbers_to_10: Score=$numbersScore, Completed=$numbersIsCompleted, Percentage=$numbersPercentage%');
      developer.log('position_patterns_2: Score=$patternsScore, Completed=$patternsIsCompleted, Percentage=$patternsPercentage%');

      setState(() {
        // Update the game scores map
        _gameScores['numbers_to_10'] = numbersScore.toDouble();
        _gameCompleted['numbers_to_10'] = numbersIsCompleted;
        
        _gameScores['position_patterns_2'] = patternsScore.toDouble();
        _gameCompleted['position_patterns_2'] = patternsIsCompleted;
        
        // You might want to store these percentages as well
        // _gamePercentages['numbers_to_10'] = numbersPercentage;
        // _gamePercentages['position_patterns_2'] = patternsPercentage;
      });
    } catch (e) {
      developer.log('Error loading scores: $e');
    }
  }

  Future<void> _loadGameState() async {
    try {
      final savedScore = HiveService.getGameScore('position_patterns_2');
      final savedPercentage = HiveService.getGamePercentage('position_patterns_2');
      final isCompleted = HiveService.isGameCompleted('position_patterns_2');

      developer.log('Loaded game state:');
      developer.log('- Score: $savedScore');
      developer.log('- Percentage: $savedPercentage');
      developer.log('- Is completed: $isCompleted');

      if (savedScore > 0) {
        setState(() {
          score = savedScore;
          currentQuestion = savedScore;
        });
      }
    } catch (error) {
      developer.log('Error loading game state: $error');
    }
  }

  Future<void> _saveGameState() async {
    try {
      await HiveService.saveGameProgress('position_patterns_2', score, shuffledConcepts.length);
      developer.log('Game state saved successfully');
    } catch (error) {
      developer.log('Error saving game state: $error');
    }
  }

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledConcepts = List.from(concepts)..shuffle();
      
      // Prepare options based on concept type
      for (var concept in shuffledConcepts) {
        if (concept.name == 'Number Patterns') {
          // Ensure we have the correct answer in the options
          if (!concept.options.contains(concept.example)) {
            var optionsList = List<String>.from(concept.options);
            // Replace a random option with the correct answer if it's not there
            optionsList.removeLast();
            optionsList.add(concept.example);
            concept.options.clear();
            concept.options.addAll(optionsList);
          }
        }
        concept.options.shuffle();
      }
      
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      final currentConcept = shuffledConcepts[currentQuestion];
      isCorrect = answer == currentConcept.example;
      _answerAnimationController.forward().then((_) {
        _answerAnimationController.reverse();
      });
      if (isCorrect) {
        score++;
        _animationController.reset();
        _animationController.forward();
        _speakText('Yay! You got it right! ${currentConcept.description}');
      } else {
        _speakText('Oops! Try again! Think about the ${currentConcept.name.toLowerCase()}');
      }
      // Save score if this is the last question
      if (currentQuestion == shuffledConcepts.length - 1) {
        SharedPreferenceService.saveGameProgress('position_patterns_2', score, shuffledConcepts.length);
      }
      // Add delay for animation/highlight
      if (currentQuestion < shuffledConcepts.length - 1) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _nextQuestion();
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          showGameCompletionDialog(context, score, shuffledConcepts, setState, _startGame, 'Position_Patterns_2');
        });
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestion < shuffledConcepts.length - 1) {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
      } else {
        SharedPreferenceService.saveGameProgress('position_patterns_2', score, shuffledConcepts.length);
        showGameCompletionDialog(context, score, shuffledConcepts, setState, _startGame, 'Position_Patterns_2');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (widget.isGameMode) {
      return _buildGameModeScreen();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B2FF2),
        title: Text(
          isGameMode ? 'Position Patterns 2' : 'Lesson Mode',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isGameMode ? _buildGameMode() : _buildLessonMode(),
    );
  }

  Widget _buildLessonMode() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: concepts.length,
      itemBuilder: (context, index) {
        final concept = concepts[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _speakText('${concept.name}. ${concept.description}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concept.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B2FF2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: concept.visual),
                  const SizedBox(height: 16),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    concept.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameModeScreen() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Position Patterns 2',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF7B2FF2),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFF7B2FF2),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B2FF2), Color(0xFFf357a8)],
          ),
        ),
        child: SafeArea(
          child: _buildGameMode(),
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    final concept = shuffledConcepts[currentQuestion];
    final options = List<String>.from(concept.options);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3EFFF), Color(0xFFE3F0FF)],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Question ${currentQuestion + 1} of ${shuffledConcepts.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B2FF2),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: LinearProgressIndicator(
                    value: (currentQuestion + 1) / shuffledConcepts.length,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7B2FF2)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'What is this position pattern?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                // Visual
                Container(
                  height: 100,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Center(
                    child: concept.visual,
                  ),
                ),
                const SizedBox(height: 24),
                // Answer options
                ...options.map((option) {
                  final isSelected = selectedAnswer == option;
                  final isCorrectOption = showResult && option == concept.example;
                  final isIncorrect = showResult && isSelected && !isCorrect;
                  
                  Color backgroundColor;
                  if (isCorrectOption) {
                    backgroundColor = Colors.green.withOpacity(0.9);
                  } else if (isIncorrect) {
                    backgroundColor = Colors.red.withOpacity(0.9);
                  } else if (isSelected) {
                    backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.9);
                  } else {
                    backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.7);
                  }

                  return ScaleTransition(
                    scale: (isSelected && showResult) ? _answerScaleAnimation : const AlwaysStoppedAnimation(1.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(12),
                        elevation: isSelected ? 4 : 1,
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: showResult ? null : () => _checkAnswer(option),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (isCorrectOption)
                                  const Icon(Icons.check_circle, color: Colors.white, size: 24)
                                else if (isIncorrect)
                                  const Icon(Icons.cancel, color: Colors.white, size: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _answerAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
} 