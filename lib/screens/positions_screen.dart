import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import 'dart:developer' as developer;
import '../services/shared_preference_service.dart';

class PositionConcept {
  final String name;
  final String description;
  final IconData icon;

  PositionConcept(
      {required this.name, required this.description, required this.icon});
}

class PositionGameQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;
  final Widget visual;

  PositionGameQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.visual,
  });
}

final List<PositionConcept> concepts = [
  PositionConcept(
    name: 'Above and Below',
    description: 'Learn about positions above and below objects',
    icon: Icons.arrow_upward,
  ),
  PositionConcept(
    name: 'Left and Right',
    description: 'Learn about positions to the left and right of objects',
    icon: Icons.arrow_forward,
  ),
  PositionConcept(
    name: 'In Front and Behind',
    description: 'Learn about positions in front of and behind objects',
    icon: Icons.compare_arrows,
  ),
  PositionConcept(
    name: 'Inside and Outside',
    description: 'Learn about positions inside and outside of objects',
    icon: Icons.crop_square,
  ),
];

final List<PositionGameQuestion> positionGameQuestions = [
  PositionGameQuestion(
    question: 'Where is the ball positioned?',
    correctAnswer: 'Above',
    options: ['Above', 'Below', 'Left', 'Right'],
    visual: _buildPositionVisual('above', '⚽'),
  ),
  PositionGameQuestion(
    question: 'Where is the star positioned?',
    correctAnswer: 'Below',
    options: ['Above', 'Below', 'Left', 'Right'],
    visual: _buildPositionVisual('below', '⭐'),
  ),
  PositionGameQuestion(
    question: 'Where is the heart positioned?',
    correctAnswer: 'Left',
    options: ['Left', 'Right', 'Above', 'Below'],
    visual: _buildPositionVisual('left', '❤️'),
  ),
  PositionGameQuestion(
    question: 'Where is the flower positioned?',
    correctAnswer: 'Right',
    options: ['Left', 'Right', 'Above', 'Below'],
    visual: _buildPositionVisual('right', '🌸'),
  ),
  PositionGameQuestion(
    question: 'Where is the sun positioned?',
    correctAnswer: 'Inside',
    options: ['Inside', 'Outside', 'Above', 'Below'],
    visual: _buildPositionVisual('inside', '☀️'),
  ),
  PositionGameQuestion(
    question: 'Where is the moon positioned?',
    correctAnswer: 'Outside',
    options: ['Inside', 'Outside', 'Above', 'Below'],
    visual: _buildPositionVisual('outside', '🌙'),
  ),
];

Widget _buildPositionVisual(String position, String emoji) {
  return Container(
    width: 150,
    height: 150,
    child: CustomPaint(
      painter: PositionPainter(position, emoji),
      size: const Size(150, 150),
    ),
  );
}

class PositionsScreen extends StatefulWidget {
  final bool isGameMode;
  const PositionsScreen({super.key, this.isGameMode = false});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  List<PositionGameQuestion> _shuffledQuestions = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerScaleAnimation;
  late Animation<Color?> _answerColorAnimation;
  List<String> _currentOptions = [];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeAnimations();
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

  void _initializeAnimations() {
    // Question transition animation
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

    // Answer feedback animation
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
    _answerColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.green,
    ).animate(
      CurvedAnimation(
        parent: _answerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  List<String> _getShuffledOptions(PositionGameQuestion question) {
    // Create a list of options including the correct answer
    final List<String> options = List.from(question.options);

    // Shuffle the options to randomize their order
    options.shuffle();

    return options;
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showResult = false;
      _shuffledQuestions = List.from(positionGameQuestions)..shuffle();
      _currentOptions = _getShuffledOptions(_shuffledQuestions[0]);
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) async {
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _isCorrect =
          answer == _shuffledQuestions[_currentQuestionIndex].correctAnswer;
      if (_isCorrect) {
        _score++;
      }
    });

    _answerAnimationController.forward().then((_) {
      _answerAnimationController.reverse();
    });

    if (_isCorrect) {
      await speakText('Correct! Well done!');
    } else {
      await speakText(
          'Try again! The correct answer is ${_shuffledQuestions[_currentQuestionIndex].correctAnswer}');
    }

    Future.delayed(const Duration(seconds: 0), () {
      if (mounted) {
        if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _selectedAnswer = null;
            _showResult = false;
            _isCorrect = false;
          });
        } else {
          // Game completed, update progress and show dialog
          if (mounted) {
            SharedPreferenceService.saveGameProgress(
              'positions',
              _score,
              _shuffledQuestions.length,
            ).then((_) {
              developer.log(
                  'Game progress saved for positions: Score $_score out of ${_shuffledQuestions.length}');
              setState(() {
                SharedPreferenceService.updateOverallProgress();
              });
              showGameCompletionDialog(
                context,
                _score,
                _shuffledQuestions,
                setState,
                _startGame,
                'positions',
              );
            });
          }
        }
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showResult = false;
        _currentOptions =
            _getShuffledOptions(_shuffledQuestions[_currentQuestionIndex]);
        _animationController.reset();
        _animationController.forward();
        _speakText('Next question!');
      } else {
        showGameCompletionDialog(context, _score, _shuffledQuestions, setState,
            _startGame, 'Positions');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _answerAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF6A1B9A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF6A1B9A),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    if (widget.isGameMode) {
      return _buildGameModeScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Positions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
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
              onTap: () =>
                  _speakText('${concept.name}. ${concept.description}'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          concept.icon,
                          color: const Color(0xFF6A1B9A),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            concept.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(child: _buildConceptVisual(concept.name)),
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
                      concept.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameModeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Position Practice',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF6A1B9A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF6A1B9A),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF6A1B9A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3EFFF), Color(0xFFE3F0FF)],
          ),
        ),
        child: SafeArea(
          child: _buildGameMode(),
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_shuffledQuestions.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $_score',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
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
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _shuffledQuestions[_currentQuestionIndex]
                                .visual,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _shuffledQuestions[_currentQuestionIndex].question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6A1B9A),
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
              children: _currentOptions.map((option) {
                final isSelected = _selectedAnswer == option;
                final isCorrectOption = _showResult &&
                    option ==
                        _shuffledQuestions[_currentQuestionIndex].correctAnswer;
                final isIncorrect = _showResult && isSelected && !_isCorrect;
                Color backgroundColor;
                if (isCorrectOption) {
                  backgroundColor = Colors.green;
                } else if (isIncorrect) {
                  backgroundColor = Colors.red;
                } else if (isSelected) {
                  backgroundColor = const Color(0xFF6A1B9A);
                } else {
                  backgroundColor = const Color(0xFF6A1B9A).withOpacity(0.1);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AnimatedBuilder(
                    animation: _answerAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? _answerScaleAnimation.value : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF6A1B9A),
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _showResult
                                  ? null
                                  : () => _checkAnswer(option),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ||
                                            isCorrectOption ||
                                            isIncorrect
                                        ? Colors.white
                                        : const Color(0xFF6A1B9A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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

  Widget _buildConceptVisual(String name) {
    switch (name.toLowerCase()) {
      case 'above and below':
        return Column(
          children: [
            _buildPositionVisual('above', '⚽'),
            const SizedBox(height: 10),
            _buildPositionVisual('below', '⭐'),
          ],
        );
      case 'left and right':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPositionVisual('left', '❤️'),
            const SizedBox(width: 10),
            _buildPositionVisual('right', '🌸'),
          ],
        );
      case 'in front and behind':
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Behind',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6A1B9A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Front',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      case 'inside and outside':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPositionVisual('inside', '☀️'),
            const SizedBox(width: 10),
            _buildPositionVisual('outside', '🌙'),
          ],
        );
      default:
        return _buildPositionVisual('above', '⚽');
    }
  }
}

class PositionPainter extends CustomPainter {
  final String position;
  final String emoji;

  PositionPainter(this.position, this.emoji);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final referenceRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 60,
      height: 60,
    );

    // Draw reference square
    canvas.drawRect(referenceRect, paint);

    // Draw emoji based on position
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final emojiWidth = textPainter.width;
    final emojiHeight = textPainter.height;

    switch (position) {
      case 'above':
        textPainter.paint(
          canvas,
          Offset(
            (size.width - emojiWidth) / 2,
            referenceRect.top - emojiHeight - 10,
          ),
        );
        break;
      case 'below':
        textPainter.paint(
          canvas,
          Offset(
            (size.width - emojiWidth) / 2,
            referenceRect.bottom + 10,
          ),
        );
        break;
      case 'left':
        textPainter.paint(
          canvas,
          Offset(
            referenceRect.left - emojiWidth - 10,
            (size.height - emojiHeight) / 2,
          ),
        );
        break;
      case 'right':
        textPainter.paint(
          canvas,
          Offset(
            referenceRect.right + 10,
            (size.height - emojiHeight) / 2,
          ),
        );
        break;
      case 'inside':
        textPainter.paint(
          canvas,
          Offset(
            (size.width - emojiWidth) / 2,
            (size.height - emojiHeight) / 2,
          ),
        );
        break;
      case 'outside':
        // Draw emoji in all four corners
        final cornerOffset = 10.0;
        textPainter.paint(
          canvas,
          Offset(cornerOffset, cornerOffset),
        );
        textPainter.paint(
          canvas,
          Offset(size.width - emojiWidth - cornerOffset, cornerOffset),
        );
        textPainter.paint(
          canvas,
          Offset(cornerOffset, size.height - emojiHeight - cornerOffset),
        );
        textPainter.paint(
          canvas,
          Offset(
            size.width - emojiWidth - cornerOffset,
            size.height - emojiHeight - cornerOffset,
          ),
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
