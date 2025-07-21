import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import 'package:flutter/services.dart';
import '../services/game_progress_service.dart';
import '../main.dart';
import 'home_screen.dart';

class MeasuresScreen extends StatefulWidget {
  final bool isGameMode;

  const MeasuresScreen({
    super.key,
    required this.isGameMode,
  });

  @override
  State<MeasuresScreen> createState() => _MeasuresScreenState();
}

class _MeasuresScreenState extends State<MeasuresScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerScaleAnimation;
  final FlutterTts flutterTts = FlutterTts();
  int score = 0;
  int currentQuestion = 0;
  bool showResult = false;
  bool isCorrect = false;
  String? selectedAnswer;
  bool _isLoading = true;
  List<Map<String, dynamic>> shuffledGames = [];

  // Add scale animation controller following fractions_screen.dart pattern
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> games = [
    {
      'question': 'Which pencil is longer?',
      'visual': Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF7B2FF2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 4),
                Text('Pencil A', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFFf357a8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 4),
                Text('Pencil B', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      'options': ['Pencil A', 'Pencil B'],
      'correctAnswer': 'Pencil A',
      'explanation': 'Pencil A is longer than Pencil B.',
    },
    {
      'question': 'Which tree is taller?',
      'visual': Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                Icon(Icons.forest, size: 80, color: Color(0xFF7B2FF2)),
                Text('Tree A', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.forest, size: 120, color: Color(0xFFf357a8)),
                Text('Tree B', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      'options': ['Tree A', 'Tree B'],
      'correctAnswer': 'Tree B',
      'explanation': 'Tree B is taller than Tree A.',
    },
    {
      'question': 'Which door is wider?',
      'visual': Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFF7B2FF2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child:
                        Text('Door A', style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
          SizedBox(height: 20),
          Column(
            children: [
              Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFf357a8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child:
                        Text('Door B', style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ],
      ),
      'options': ['Door A', 'Door B'],
      'correctAnswer': 'Door A',
      'explanation': 'Door A is wider than Door B.',
    },
    {
      'question': 'Order these animals from shortest to tallest:',
      'visual': Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              children: [
                Icon(Icons.pets, size: 40, color: Colors.brown),
                Text('Dog', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.emoji_nature, size: 100, color: Colors.orange),
                Text('Giraffe', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.emoji_nature, size: 70, color: Colors.grey),
                Text('Elephant', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      'options': [
        'Dog, Elephant, Giraffe',
        'Giraffe, Dog, Elephant',
        'Dog, Giraffe, Elephant',
        'Elephant, Giraffe, Dog'
      ],
      'correctAnswer': 'Dog, Elephant, Giraffe',
      'explanation':
          'The dog is the shortest, then the elephant, and the giraffe is the tallest.',
    },
    {
      'question': 'Which vehicle is longer?',
      'visual': Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.directions_bus,
                        size: 80, color: Color(0xFF7B2FF2)),
                    Text('Bus', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.directions_car,
                        size: 60, color: Color(0xFFf357a8)),
                    Text('Car', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      'options': ['Bus', 'Car'],
      'correctAnswer': 'Bus',
      'explanation': 'The bus is longer than the car.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeAnswerAnimation();
    _shuffleGames();
    if (widget.isGameMode) {
      _startGame();
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // Add scale animation controller following fractions_screen.dart pattern
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _initializeAnswerAnimation() {
    _answerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _answerScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _answerAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _shuffleGames() {
    final random = math.Random();

    // Create shuffled copies of games with shuffled options
    shuffledGames = games.map((game) {
      final shuffledOptions = List<String>.from(game['options']);
      shuffledOptions.shuffle(random);

      return {
        'question': game['question'],
        'visual': game['visual'],
        'options': shuffledOptions,
        'correctAnswer': game['correctAnswer'],
        'explanation': game['explanation'],
      };
    }).toList();

    // Shuffle the order of games as well
    shuffledGames.shuffle(random);
  }

  void _startGame() {
    setState(() {
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      _shuffleGames(); // Re-shuffle for a new game
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGameMode) {
      return _buildGameMode();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measures - Length'),
        backgroundColor: const Color(0xFF7B2FF2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Understanding Length',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B2FF2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Length is all about measuring how long, tall, or wide things are. Let\'s explore different ways to compare lengths!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ...games
                    .map((game) => Card(
                          margin: const EdgeInsets.only(bottom: 24),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game['question'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7B2FF2),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: game['visual'],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFf357a8)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.lightbulb_outline,
                                        color: Color(0xFFf357a8),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          game['explanation'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFf357a8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    final game = shuffledGames[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measures Game'),
        backgroundColor: const Color(0xFF7B2FF2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (currentQuestion + 1) / shuffledGames.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B2FF2)),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestion + 1} of ${shuffledGames.length}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7B2FF2), Color(0xFFf357a8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF7B2FF2).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Score: $score',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  game['question'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B2FF2),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: game['visual'],
                ),
                SizedBox(height: 32),
                ...game['options'].map<Widget>((option) {
                  final bool isSelected = selectedAnswer == option;
                  final bool isCorrect = showResult && option == game['correctAnswer'];
                  final bool isIncorrect = showResult && isSelected && option != game['correctAnswer'];
                  
                  Color backgroundColor;
                  if (isCorrect) {
                    backgroundColor = Colors.green.shade100;
                  } else if (isIncorrect) {
                    backgroundColor = Colors.red.shade100;
                  } else if (isSelected) {
                    backgroundColor = const Color(0xFF7B2FF2).withOpacity(0.2);
                  } else {
                    backgroundColor = Colors.white;
                  }

                  Color borderColor;
                  if (isCorrect) {
                    borderColor = Colors.green;
                  } else if (isIncorrect) {
                    borderColor = Colors.red;
                  } else if (isSelected) {
                    borderColor = const Color(0xFF7B2FF2);
                  } else {
                    borderColor = Colors.grey.shade300;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AnimatedBuilder(
                      animation: _scaleAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isSelected ? _scaleAnimation.value : 1.0,
                          child: Material(
                            borderRadius: BorderRadius.circular(12),
                            elevation: isSelected ? 4 : 1,
                            child: InkWell(
                              onTap: showResult ? null : () => _checkAnswer(option),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (isCorrect)
                                      const Icon(Icons.check_circle, color: Colors.green, size: 24)
                                    else if (isIncorrect)
                                      const Icon(Icons.cancel, color: Colors.red, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkAnswer(String answer) async {
    if (showResult) return; // Prevent multiple answers while showing result

    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledGames[currentQuestion]['correctAnswer'];
      if (isCorrect) {
        score++;
      }
    });

    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });

    if (isCorrect) {
      await speakText('Correct! Well done!');
    } else {
      await speakText('Try again! The correct answer is ${shuffledGames[currentQuestion]['correctAnswer']}');
    }

    Future.delayed(const Duration(seconds: 0), () async {
      if (mounted) {
        if (currentQuestion < shuffledGames.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            showResult = false;
            isCorrect = false;
          });
        } else {
          // Show completion dialog after the last question
          if (mounted) {
            await SharedPreferenceService.saveGameProgress(
              'measures',
              score,
              shuffledGames.length,
            );
            developer.log('Game progress saved for measures: Score $score out of ${shuffledGames.length}');
            setState(() {
              SharedPreferenceService.updateOverallProgress();
            });
            showGameCompletionDialog(context, score, shuffledGames, setState, _startGame, 'measures');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
}
