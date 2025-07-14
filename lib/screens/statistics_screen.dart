import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class VennDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw first circle
    final Offset center1 = Offset(size.width * 0.4, size.height * 0.5);
    final double radius = size.width * 0.3;
    canvas.drawCircle(center1, radius, paint);
    canvas.drawCircle(center1, radius, borderPaint);

    // Draw second circle with overlap
    final Paint paint2 = Paint()
      ..color = Colors.purple.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Paint borderPaint2 = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Offset center2 = Offset(size.width * 0.6, size.height * 0.5);
    canvas.drawCircle(center2, radius, paint2);
    canvas.drawCircle(center2, radius, borderPaint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Statistic {
  final String name;
  final Widget visual;
  final String description;
  final List<String> options;

  Statistic({
    required this.name,
    required this.visual,
    required this.description,
    required this.options,
  });
}

class StatisticsScreen extends StatefulWidget {
  final bool isGameMode;

  const StatisticsScreen({super.key, this.isGameMode = false});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<Statistic> gameQuestions = [];
  late AnimationController _animationController;
  late AnimationController _answerAnimationController;
  late Animation<double> _animation;
  late Animation<double> _answerScaleAnimation;
  bool _isLoading = true;
  bool _isAnswering = false;

  List<Statistic> statistics = [
    Statistic(
      name: 'Count',
      visual: _buildStatisticVisual('🔢', 'Count'),
      description: 'Count is how many of something there are',
      options: ['Count', 'Sort', 'Compare', 'Group', 'Match'],
    ),
    Statistic(
      name: 'Sort',
      visual: _buildStatisticVisual('📊', 'Sort'),
      description: 'Sort is putting things in order',
      options: ['Sort', 'Count', 'Compare', 'Group', 'Match'],
    ),
    Statistic(
      name: 'Compare',
      visual: _buildStatisticVisual('⚖️', 'Compare'),
      description: 'Compare is looking at how things are different',
      options: ['Compare', 'Count', 'Sort', 'Group', 'Match'],
    ),
    Statistic(
      name: 'Group',
      visual: _buildStatisticVisual('👥', 'Group'),
      description: 'Group is putting similar things together',
      options: ['Group', 'Count', 'Sort', 'Compare', 'Match'],
    ),
    Statistic(
      name: 'Match',
      visual: _buildStatisticVisual('🔄', 'Match'),
      description: 'Match is finding things that go together',
      options: ['Match', 'Count', 'Sort', 'Compare', 'Group'],
    ),
  ];

  static Widget _buildStatisticVisual(String emoji, String statistic) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 48),
        ),
      ],
    );
  }

  static Widget _buildVennDiagramVisual() {
    return CustomPaint(
      size: const Size(100, 100),
      painter: VennDiagramPainter(),
    );
  }

  static Widget _buildGameVisual(String mainEmoji, List<String> content) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              mainEmoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(height: 16),
          ...content
              .map((text) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _answerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _answerScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _answerAnimationController,
      curve: Curves.easeInOut,
    ));

    isGameMode = widget.isGameMode;
    _initializeTts();

    if (isGameMode) {
      _startGame();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _shuffleOptions(String correctAnswer, List<String> allOptions) {
    final random = math.Random(DateTime.now().millisecondsSinceEpoch);
    final shuffled = List<String>.from(allOptions);

    // Shuffle multiple times for better randomization
    for (int i = 0; i < 5; i++) {
      shuffled.shuffle(random);
    }

    return shuffled;
  }

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      _isAnswering = false;

      // Create game-specific questions with shuffled options
      final questions = [
        Statistic(
          name: '5 fruits',
          visual:
              _buildGameVisual('🔢', ['🍎 🍎 🍎', '🍊 🍊', 'How many fruits?']),
          description: 'Count all the fruits shown above',
          options: _shuffleOptions(
              '5 fruits', ['5 fruits', '3 fruits', '4 fruits', '6 fruits']),
        ),
        Statistic(
          name: '1,2,3,4,5',
          visual: _buildGameVisual(
              '📊', ['3️⃣ 1️⃣ 4️⃣', '2️⃣ 5️⃣', 'Sort these numbers']),
          description: 'Which shows these numbers in order?',
          options: _shuffleOptions('1,2,3,4,5',
              ['1,2,3,4,5', '5,4,3,2,1', '1,3,2,5,4', '2,1,4,3,5']),
        ),
        Statistic(
          name: 'Elephant is bigger',
          visual: _buildGameVisual('⚖️', ['🐘 vs 🐁', 'Compare size']),
          description: 'Compare the size of these animals',
          options: _shuffleOptions('Elephant is bigger', [
            'Elephant is bigger',
            'Mouse is bigger',
            'Same size',
            'Cannot compare'
          ]),
        ),
        Statistic(
          name: 'Animals and Vehicles',
          visual: _buildGameVisual(
              '👥', ['🐶 🐱 🐰', '🚗 🚌 🚲', 'Group similar things']),
          description: 'Which shows a correct grouping?',
          options: _shuffleOptions('Animals and Vehicles', [
            'Animals and Vehicles',
            'Big and Small',
            'Fast and Slow',
            'Old and New'
          ]),
        ),
        Statistic(
          name: 'Shoes and Socks',
          visual: _buildGameVisual('🔄', ['👟 🧦', 'Find what goes together']),
          description: 'Which pair matches together?',
          options: _shuffleOptions('Shoes and Socks', [
            'Shoes and Socks',
            'Shoes and Hat',
            'Socks and Gloves',
            'None match'
          ]),
        ),
      ];

      // Shuffle the questions order
      final random = math.Random(DateTime.now().millisecondsSinceEpoch);
      questions.shuffle(random);

      // Set the shuffled questions as gameQuestions
      gameQuestions = questions;
      _isLoading = false;
    });

    _animationController.reset();
    _animationController.forward();
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
      await _loadGameState();
    } catch (e) {
      developer.log('Error initializing storage: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGameState() async {
    try {
      final savedScore =
          await PreferenceService.getInt('statistics_score') ?? 0;
      final savedQuestion =
          await PreferenceService.getInt('statistics_question') ?? 0;

      setState(() {
        score = savedScore;
        currentQuestion = savedQuestion;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading game state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGameState() async {
    try {
      await PreferenceService.setInt('statistics_score', score);
      await PreferenceService.setInt('statistics_question', currentQuestion);
      await PreferenceService.setBool('statistics_game_mode', isGameMode);
    } catch (e) {
      developer.log('Error saving game state: $e');
    }
  }

  void _checkAnswer(String answer) {
    if (showResult) return;

    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == gameQuestions[currentQuestion].name;
      if (isCorrect) {
        score++;
      }
    });

    _answerAnimationController.forward().then((_) {
      _answerAnimationController.reverse();
    });

    if (isCorrect) {
      _speakText('Correct! ${gameQuestions[currentQuestion].name} is right!');
    } else {
      _speakText('Try again!');
    }

    // Reduced delay from 800ms to 500ms
    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        if (currentQuestion < gameQuestions.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            showResult = false;
            isCorrect = false;
          });
        } else {
          // Game completed, update progress and show dialog
          if (mounted) {
            await SharedPreferenceService.saveGameProgress(
              'statistics_1',
              score,
              gameQuestions.length,
            );
            developer.log(
                'Game progress saved for statistics_1: Score $score out of ${gameQuestions.length}');
            setState(() {
              SharedPreferenceService.updateOverallProgress();
            });
            _showGameCompletionDialog();
          }
        }
      }
    });
  }

  void _showGameCompletionDialog() {
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
                    ? 'You\'ve completed the Statistics practice!'
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
                      _startGame();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isGameMode) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/statistics_1',
            (route) => route.isFirst || route.settings.name == '/main_menu',
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isGameMode ? 'Statistics Practice' : 'Statistics'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (isGameMode) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/statistics_1',
                  (route) =>
                      route.isFirst || route.settings.name == '/main_menu',
                );
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (!isGameMode) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Learn about Statistics',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLessonSection(),
                ] else ...[
                  if (_isLoading || gameQuestions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                      ),
                    )
                  else
                    _buildGameSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: statistics.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final statistic = statistics[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () =>
                _speakText('${statistic.name}. ${statistic.description}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statistic.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B2FF2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: statistic.visual),
                  const SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statistic.description,
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

  Widget _buildGameSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
        ),
      );
    }

    if (!isGameMode || currentQuestion >= gameQuestions.length) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Score Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                Text(
                  'Question ${currentQuestion + 1}/${gameQuestions.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Progress Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: (currentQuestion + 1) / gameQuestions.length,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          ),
          const SizedBox(height: 20),
          // Question Visual
          gameQuestions[currentQuestion].visual,
          const SizedBox(height: 20),
          // Question Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              gameQuestions[currentQuestion].description,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // Answer Options
          ...gameQuestions[currentQuestion]
              .options
              .map((option) => _buildAnswerOption(option))
              .toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String option) {
    final isSelected = selectedAnswer == option;
    final isCorrectOption = option == gameQuestions[currentQuestion].name;
    final isIncorrect = isSelected && !isCorrectOption;

    return AnimatedBuilder(
      animation: _answerAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale:
              isSelected && isCorrectOption ? _answerScaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _getOptionColor(isSelected, isCorrectOption, isIncorrect),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _getBorderColor(isSelected, isCorrectOption, isIncorrect),
                width: 2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: _getShadowColor(isCorrectOption),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    selectedAnswer == null ? () => _checkAnswer(option) : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: _getTextColor(
                                isSelected, isCorrectOption, isIncorrect),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (showResult && isSelected)
                        Icon(
                          isCorrectOption ? Icons.check_circle : Icons.cancel,
                          color: isCorrectOption ? Colors.green : Colors.red,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getOptionColor(
      bool isSelected, bool isCorrectOption, bool isIncorrect) {
    if (!showResult)
      return isSelected ? Colors.purple.withOpacity(0.1) : Colors.white;
    if (isSelected && isCorrectOption) return Colors.green.withOpacity(0.2);
    if (isIncorrect) return Colors.red.withOpacity(0.2);
    return Colors.white;
  }

  Color _getBorderColor(
      bool isSelected, bool isCorrectOption, bool isIncorrect) {
    if (!showResult) return isSelected ? Colors.purple : Colors.grey.shade300;
    if (isSelected && isCorrectOption) return Colors.green;
    if (isIncorrect) return Colors.red;
    return Colors.grey.shade300;
  }

  Color _getTextColor(bool isSelected, bool isCorrectOption, bool isIncorrect) {
    if (!showResult) return isSelected ? Colors.purple : Colors.black87;
    if (isSelected && isCorrectOption) return Colors.green;
    if (isIncorrect) return Colors.red;
    return Colors.black87;
  }

  Color _getShadowColor(bool isCorrectOption) {
    if (!showResult) return Colors.purple.withOpacity(0.3);
    return isCorrectOption
        ? Colors.green.withOpacity(0.3)
        : Colors.red.withOpacity(0.3);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    _answerAnimationController.dispose();
    super.dispose();
  }
}
