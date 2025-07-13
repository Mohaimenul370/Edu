import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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

class _MeasuresScreenState extends State<MeasuresScreen> with TickerProviderStateMixin {
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
                child: Center(child: Text('Door A', style: TextStyle(color: Colors.white))),
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
                child: Center(child: Text('Door B', style: TextStyle(color: Colors.white))),
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
      'explanation': 'The dog is the shortest, then the elephant, and the giraffe is the tallest.',
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
                    Icon(Icons.directions_bus, size: 80, color: Color(0xFF7B2FF2)),
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
                    Icon(Icons.directions_car, size: 60, color: Color(0xFFf357a8)),
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
    _initializeTts();
    _initializeAnimation();
    _initializeAnswerAnimation();
    _shuffleGames();
    if (widget.isGameMode) {
      _startGame();
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
                ...games.map((game) => Card(
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
                            color: const Color(0xFFf357a8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                )).toList(),
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
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  final bool showResult = this.showResult;
                  final bool isCorrect = option == game['correctAnswer'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: showResult ? null : () => _checkAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: showResult
                              ? (isCorrect
                                  ? Colors.green
                                  : (isSelected ? Colors.red : Colors.grey[300]))
                              : (isSelected ? Color(0xFF7B2FF2) : Colors.white),
                          foregroundColor: showResult
                              ? Colors.white
                              : (isSelected ? Colors.white : Color(0xFF7B2FF2)),
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: showResult
                                ? (isCorrect
                                    ? Colors.green
                                    : (isSelected ? Colors.red : Colors.grey))
                                : (isSelected ? Color(0xFF7B2FF2) : Colors.grey),
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
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

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledGames[currentQuestion]['correctAnswer'];
      if (isCorrect) {
        score++;
        _speakText('Correct!');
      } else {
        _speakText('Try again!');
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        if (currentQuestion < shuffledGames.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            showResult = false;
          });
        } else {
          // Show completion dialog after the last question
          _showCompletionDialog();
        }
      }
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / shuffledGames.length) * 100;
    
    // Save progress immediately when game is complete
    SharedPreferenceService.saveGameProgress('measures', score, shuffledGames.length);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFF7B2FF2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Score',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7B2FF2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$score / ${shuffledGames.length}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B2FF2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  percentage >= 80 
                      ? 'Great job! You\'ve mastered these measurements!'
                      : percentage >= 60
                          ? 'Good work! Keep practicing!'
                          : 'Nice try! Practice makes perfect!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Go back to measures_chapter_screen.dart
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7B2FF2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 18),
                            SizedBox(width: 8),
                            Text('Back'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startGame(); // This will re-shuffle and restart
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 18),
                            SizedBox(width: 8),
                            Text('Play Again'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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