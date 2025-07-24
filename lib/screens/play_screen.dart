import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import '../services/game_progress_service.dart';
import '../services/shared_preference_service.dart';
import '../widgets/global_app_bar.dart';
import 'dart:math';

class MathProblem {
  final String question;
  final Widget visual;
  final List<String> options;
  final String correctAnswer;
  final String category;

  MathProblem({
    required this.question,
    required this.visual,
    required this.options,
    required this.correctAnswer,
    required this.category,
  });
}

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  bool showFinalResults = false;
  List<MathProblem> shuffledProblems = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _resultAnimationController;
  late Animation<double> _resultAnimation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerAnimation;
  Color _answerColor = Colors.transparent;
  final Map<String, double> _gameScores = {};
  final Map<String, bool> _gameCompleted = {};
  double _mathPlayPercentage = 0.0;
  bool _canStartPractice = false;
  bool _hasShownDialog = false;
  bool _isLoading = true;

  final List<MathProblem> problems = [
    MathProblem(
      question: 'How many sides does a triangle have?',
      visual: _buildShapeVisual('🔺'),
      options: ['2', '3', '4', '5', '6'],
      correctAnswer: '3',
      category: 'Shapes',
    ),
    MathProblem(
      question: 'What time is shown on the clock?',
      visual: _buildClockVisual(6, 0), // Changed to 6 o'clock
      options: ['2:00', '3:00', '4:00', '5:00', '6:00'],
      correctAnswer: '6:00', // Changed to 6:00
      category: 'Time',
    ),
    MathProblem(
      question: 'Which object is longer?',
      visual: _buildLengthComparisonVisual(),
      options: ['Blue', 'Red', 'Green', 'Yellow', 'Purple'],
      correctAnswer: 'Blue',
      category: 'Measures',
    ),
    MathProblem(
      question: 'What comes next in the pattern?',
      visual: _buildPatternVisual(['🔴', '🟡', '🔴', '?']),
      options: ['🔴', '🟡', '🟢', '🔵', '🟣'],
      correctAnswer: '🟡',
      category: 'Patterns',
    ),
    MathProblem(
      question: 'How many apples are there?',
      visual: _buildNumberVisual(5),
      options: ['3', '4', '5', '6', '7'],
      correctAnswer: '5',
      category: 'Numbers',
    ),
    MathProblem(
      question: 'Which shape has 4 equal sides?',
      visual: _buildShapeVisual('⬜'),
      options: ['Triangle', 'Square', 'Circle', 'Rectangle', 'Star'],
      correctAnswer: 'Square',
      category: 'Shapes',
    ),
    MathProblem(
      question: 'What is 2 + 3?',
      visual: _buildAdditionVisual(2, 3),
      options: ['4', '5', '6', '7', '8'],
      correctAnswer: '5',
      category: 'Numbers',
    ),
    MathProblem(
      question: 'Which container has more water?',
      visual: _buildVolumeComparisonVisual(),
      options: ['Tall', 'Short', 'Wide', 'Narrow', 'Both'],
      correctAnswer: 'Tall',
      category: 'Measures',
    ),
    MathProblem(
      question: 'What time of day is it?',
      visual: _buildTimeOfDayVisual('🌅'),
      options: ['Morning', 'Afternoon', 'Evening', 'Night', 'Midnight'],
      correctAnswer: 'Morning',
      category: 'Time',
    ),
    MathProblem(
      question: 'What comes next in the pattern?',
      visual: _buildPatternVisual(['⭐', '🔺', '⭐', '?']),
      options: ['⭐', '🔺', '🔵', '🟢', '🔶'],
      correctAnswer: '🔺',
      category: 'Patterns',
    ),
  ];

  static Widget _buildShapeVisual(String shape) {
    return Text(
      shape,
      style: const TextStyle(fontSize: 48),
    );
  }

  static Widget _buildClockVisual(int hour, int minutes) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: CustomPaint(
        painter: ClockPainter(
          hourAngle: (hour % 12) * (2 * pi / 12) - pi / 2,
          minuteAngle: minutes * (2 * pi / 60) - pi / 2,
          color: Colors.black,
        ),
      ),
    );
  }

  static Widget _buildLengthComparisonVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 20,
          color: Colors.blue,
        ),
        const SizedBox(width: 20),
        Container(
          width: 60,
          height: 20,
          color: Colors.red,
        ),
      ],
    );
  }

  static Widget _buildPatternVisual(List<String> pattern) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pattern.map((emoji) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
        );
      }).toList(),
    );
  }

  static Widget _buildNumberVisual(int number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(number, (index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '🍎',
            style: TextStyle(fontSize: 32),
          ),
        );
      }),
    );
  }

  static Widget _buildAdditionVisual(int a, int b) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$a + $b = ?',
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }

  static Widget _buildVolumeComparisonVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            border: Border.all(color: Colors.blue),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            border: Border.all(color: Colors.red),
          ),
        ),
      ],
    );
  }

  static Widget _buildTimeOfDayVisual(String emoji) {
    return Text(
      emoji,
      style: const TextStyle(fontSize: 48),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGameScores();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _resultAnimation = CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeInOut,
    );

    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _answerAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _answerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resultAnimationController.dispose();
    _answerAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _loadGameScores() async {
    setState(() {
      _isLoading = true;
    });

    await SharedPreferenceService.initialize();
    setState(() {
      _gameScores.clear();
      _gameCompleted.clear();

      // Load scores for each chapter
      for (var chapter in SharedPreferenceService.allChapters) {
        final score = SharedPreferenceService.getGamePercentage(chapter);
        final completed = SharedPreferenceService.isGameCompleted(chapter);
        _gameScores[chapter] = score;
        _gameCompleted[chapter] = completed;
      }

      // Get overall progress directly from SharedPreferenceService
      _mathPlayPercentage = SharedPreferenceService.getOverallProgress();
      _canStartPractice = _mathPlayPercentage >= 100;
      _isLoading = false;
    });

    if (_canStartPractice) {
      // If progress is 100%, start the game directly
      _startGame();
    } else if (!_hasShownDialog && mounted) {
      // Only show dialog if progress is less than 100%
      _hasShownDialog = true;
      await _showProgressDialog();

      // After dialog is closed, navigate back if not enough progress
      if (mounted && !_canStartPractice) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showProgressDialog() async {
    if (!mounted) return;

    // Show the dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Create a list of chapters with their scores
        final List<Widget> chapterScores = [];
        for (var chapter in SharedPreferenceService.allChapters) {
          final score = _gameScores[chapter] ?? 0.0;
          final chapterName = chapter.toUpperCase().replaceAll('_', ' ');
          chapterScores.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chapterName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${score.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Color(0xFFFCE4EC), // Light pink background
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Math Play Locked',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Score at least 50% in all the chapters to unlock the exclusive Math Play chapter.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Current progress: ${_mathPlayPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your current progress:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(3),
                      child: SingleChildScrollView(
                        child: Column(
                          children: chapterScores,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startGame() {
    setState(() {
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledProblems = List.from(problems)..shuffle();
      for (var problem in shuffledProblems) {
        problem.options.shuffle();
      }
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) async {
    if (!mounted) return;

    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledProblems[currentQuestion].correctAnswer;
    });

    _answerAnimationController.forward().then((_) {
      _answerAnimationController.reverse();
    });

    if (isCorrect) {
      score++;
      await speakText('Correct! Well done!');
    } else {
      await speakText(
          'Try again! The correct answer is ${shuffledProblems[currentQuestion].correctAnswer}');
    }

    Future.delayed(const Duration(milliseconds: 0), () async {
      if (!mounted) return;

      if (currentQuestion < shuffledProblems.length - 1) {
        setState(() {
          currentQuestion++;
          selectedAnswer = null;
          showResult = false;
        });
      } else {
        // Save score if this is the last question
        GameProgressService.saveGameProgress(
            'play', score, shuffledProblems.length);
        // Show final results after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          _showFinalResults();
        });
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestion < shuffledProblems.length - 1) {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        _animationController.reset();
        _animationController.forward();
        speakText('Next question!');
      } else {
        showFinalResults = true;
        speakText('You completed the game!');
        _showFinalResults();
      }
    });
  }

  void _restartGame() {
    setState(() {
      showFinalResults = false;
      _startGame();
    });
  }

  void _showFinalResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
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
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score: $score/${shuffledProblems.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getResultMessage(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _restartGame();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Main Menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
        );
      },
    );
  }

  String _getResultMessage() {
    final percentage = (score / shuffledProblems.length) * 100;
    if (percentage >= 90) {
      return 'Excellent! You\'re a math superstar! 🌟';
    } else if (percentage >= 70) {
      return 'Great job! You\'re doing amazing! 👍';
    } else if (percentage >= 50) {
      return 'Good work! Keep practicing! 💪';
    } else {
      return 'Keep trying! You\'ll get better! 🎯';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(title: 'Math Play'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : shuffledProblems.isEmpty
              ? _buildWelcomeContent()
              : _buildGameContent(),
    );
  }

  Widget _buildWelcomeContent() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3EFFF), Color(0xFFE3F0FF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 80,
                  color: Color(0xFF7B2FF2),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to Math Play!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B2FF2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Complete all chapters to unlock\nthis exclusive game mode',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF7B2FF2),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Progress: ${_mathPlayPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B2FF2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _mathPlayPercentage / 100,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF7B2FF2)),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Question ${currentQuestion + 1} of ${shuffledProblems.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ScaleTransition(
              scale: _animation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: shuffledProblems[currentQuestion].visual,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        shuffledProblems[currentQuestion].question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: shuffledProblems[currentQuestion].options.map((option) {
                final isSelected = option == selectedAnswer;
                final isCorrect = showResult &&
                    option == shuffledProblems[currentQuestion].correctAnswer;
                final isIncorrect = showResult &&
                    isSelected &&
                    option != shuffledProblems[currentQuestion].correctAnswer;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: AnimatedBuilder(
                    animation: _answerAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? _answerAnimation.value : 1.0,
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          elevation: isSelected ? 4 : 1,
                          child: InkWell(
                            onTap: showResult
                                ? null
                                : () {
                                    if (mounted) {
                                      _checkAnswer(option);
                                    }
                                  },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isCorrect
                                    ? Colors.green.withOpacity(0.2)
                                    : isIncorrect
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.white,
                                border: Border.all(
                                  color: isCorrect
                                      ? Colors.green
                                      : isIncorrect
                                          ? Colors.red
                                          : isSelected
                                              ? const Color(0xFF7B2FF2)
                                              : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isCorrect
                                      ? Colors.green
                                      : isIncorrect
                                          ? Colors.red
                                          : isSelected
                                              ? const Color(0xFF7B2FF2)
                                              : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;
  final Color color;
  final bool isLarge;

  ClockPainter({
    required this.hourAngle,
    required this.minuteAngle,
    required this.color,
    this.isLarge = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw hour markers
    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = i * (2 * pi / 12);
      final markerRadius = radius * 0.85;
      final x = center.dx + markerRadius * sin(angle);
      final y = center.dy - markerRadius * cos(angle);
      canvas.drawCircle(Offset(x, y), 2, markerPaint);
    }

    // Draw hour hand
    final hourHandPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final hourHandLength = radius * 0.5;
    canvas.drawLine(
      center,
      Offset(
        center.dx + hourHandLength * cos(hourAngle),
        center.dy + hourHandLength * sin(hourAngle),
      ),
      hourHandPaint,
    );

    // Draw minute hand
    final minuteHandPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final minuteHandLength = radius * 0.7;
    canvas.drawLine(
      center,
      Offset(
        center.dx + minuteHandLength * cos(minuteAngle),
        center.dy + minuteHandLength * sin(minuteAngle),
      ),
      minuteHandPaint,
    );

    // Draw center dot
    canvas.drawCircle(center, 4, markerPaint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) =>
      oldDelegate.hourAngle != hourAngle ||
      oldDelegate.minuteAngle != minuteAngle ||
      oldDelegate.color != color;
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
