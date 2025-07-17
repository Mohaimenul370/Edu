import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class Measure {
  final String name;
  final String description;
  final Widget visual;
  final String example;
  final String unit;
  final List<String> options;
  final String section;

  Measure({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
    required this.unit,
    required this.options,
    required this.section,
  });
}

class Measures2Screen extends StatefulWidget {
  final bool isGameMode;
  const Measures2Screen({super.key, required this.isGameMode});

  @override
  State<Measures2Screen> createState() => _Measures2ScreenState();
}

class _Measures2ScreenState extends State<Measures2Screen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  bool _isLoading = false;
  bool _isAnswering = false;
  int currentQuestion = 0;
  int score = 0;
  String selectedAnswer = '';
  bool showResult = false;
  bool isCorrect = false;
  List<Map<String, dynamic>> practiceQuestions = [];
  late AnimationController _controller;
  late AnimationController _answerAnimationController;
  late Animation<double> _animation;
  late Animation<double> _answerScaleAnimation;

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeTts();
    _initializeQuestions();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _answerScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _answerAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeQuestions() {
    setState(() {
      _isLoading = true;
    });

    final questions = [
      {
        'question': 'Which one is heavier?',
        'image1': 'assets/images/measures/dumbbell_feather.svg',
        'image2': 'assets/images/measures/dumbbell_feather.svg',
        'baseOptions': ['DUMBBELL', 'FEATHER'],
        'correctAnswer': 'DUMBBELL',
        'leftLabel': 'DUMBBELL',
        'rightLabel': 'FEATHER'
      },
      {
        'question': 'Which container can hold more liquid?',
        'image1': 'assets/images/measures/jug_cup.svg',
        'image2': 'assets/images/measures/jug_cup.svg',
        'baseOptions': ['JUG', 'CUP'],
        'correctAnswer': 'JUG',
        'leftLabel': 'JUG',
        'rightLabel': 'CUP'
      },
      {
        'question': 'Which fruit is heavier?',
        'image1': 'assets/images/measures/watermelon_apple.svg',
        'image2': 'assets/images/measures/watermelon_apple.svg',
        'baseOptions': ['WATERMELON', 'APPLE'],
        'correctAnswer': 'WATERMELON',
        'leftLabel': 'WATERMELON',
        'rightLabel': 'APPLE'
      },
      {
        'question': 'Which bottle has more capacity?',
        'image1': 'assets/images/measures/bottle_comparison.svg',
        'image2': 'assets/images/measures/bottle_comparison.svg',
        'baseOptions': ['1L BOTTLE', '500ML BOTTLE'],
        'correctAnswer': '1L BOTTLE',
        'leftLabel': '1L BOTTLE',
        'rightLabel': '500ML BOTTLE'
      },
      {
        'question': 'Which object is heavier?',
        'image1': 'assets/images/measures/books_pencil.svg',
        'image2': 'assets/images/measures/books_pencil.svg',
        'baseOptions': ['BOOKS', 'PENCIL'],
        'correctAnswer': 'BOOKS',
        'leftLabel': 'BOOKS',
        'rightLabel': 'PENCIL'
      },
    ];

    // Shuffle the questions order with time-based seed
    final random = math.Random(DateTime.now().millisecondsSinceEpoch);
    questions.shuffle(random);

    // Add shuffled options to each question
    practiceQuestions = questions.map((q) {
      return {
        'question': q['question'],
        'image1': q['image1'],
        'image2': q['image2'],
        'options': _shuffleOptions(q['baseOptions'] as List<String>, q['correctAnswer'] as String),
        'correctAnswer': q['correctAnswer'],
        'leftLabel': q['leftLabel'],
        'rightLabel': q['rightLabel'],
        'baseOptions': q['baseOptions'],
      };
    }).toList();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  List<String> _shuffleOptions(List<String> options, String correctAnswer) {
    final random = math.Random(DateTime.now().millisecondsSinceEpoch);
    final shuffled = List<String>.from(options);
    
    // For 2-option questions, use explicit random positioning
    if (shuffled.length == 2) {
      // Randomly decide if correct answer should be first (0) or second (1)
      final correctAnswerPosition = random.nextInt(2);
      
      if (correctAnswerPosition == 0) {
        // Correct answer first
        if (shuffled[0] != correctAnswer) {
          final temp = shuffled[0];
          shuffled[0] = shuffled[1];
          shuffled[1] = temp;
        }
      } else {
        // Correct answer second  
        if (shuffled[1] != correctAnswer) {
          final temp = shuffled[0];
          shuffled[0] = shuffled[1];
          shuffled[1] = temp;
        }
      }
    } else {
      // For more than 2 options, use multiple shuffles
      for (int i = 0; i < 5; i++) {
        shuffled.shuffle(random);
      }
    }
    
    return shuffled;
  }

  Widget _buildAnswerOption(String option, bool isCorrect) {
    final bool isSelected = selectedAnswer == option;
    final bool isCorrectOption = option == practiceQuestions[currentQuestion]['correctAnswer'];
    final bool isIncorrect = isSelected && !isCorrectOption;

    return AnimatedBuilder(
      animation: _answerAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected && isCorrectOption ? _answerScaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isAnswering ? null : () => _handleAnswer(option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _getOptionColor(isSelected, isCorrectOption, isIncorrect),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getBorderColor(isSelected, isCorrectOption, isIncorrect),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: _getTextColor(isSelected, isCorrectOption, isIncorrect),
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

  Color _getOptionColor(bool isSelected, bool isCorrectOption, bool isIncorrect) {
    if (!showResult) return isSelected ? Colors.purple.withOpacity(0.1) : Colors.white;
    if (isSelected && isCorrectOption) return Colors.green.withOpacity(0.2);
    if (isIncorrect) return Colors.red.withOpacity(0.2);
    return Colors.white;
  }

  Color _getBorderColor(bool isSelected, bool isCorrectOption, bool isIncorrect) {
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
    return isCorrectOption ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3);
  }

  void _handleAnswer(String answer) async {
    if (_isAnswering) return;
    _isAnswering = true;

    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == practiceQuestions[currentQuestion]['correctAnswer'];
      if (isCorrect) {
        score++;
        _answerAnimationController.forward().then((_) {
          _answerAnimationController.reverse();
        });
      }
    });

    if (isCorrect) {
      _speakText('Correct!');
    } else {
      _speakText('Try again!');
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (currentQuestion < practiceQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = '';
        showResult = false;
        _isAnswering = false;
        
        // Re-shuffle options for the next question with new randomization
        final nextQuestion = practiceQuestions[currentQuestion];
        nextQuestion['options'] = _shuffleOptions(
          nextQuestion['baseOptions'] as List<String>, 
          nextQuestion['correctAnswer'] as String
        );
      });
    } else {
      SharedPreferenceService.saveGameProgress(
          'measures_2',
          score,
          practiceQuestions.length,
        );
        SharedPreferenceService.updateOverallProgress();
      showGameCompletionDialog(context, score, practiceQuestions, setState, () {}, 'Measures_2');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _answerAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF7B2FF2),
        elevation: 0,
        title: Text(
          isGameMode ? 'Practice - Mass and Capacity' : 'Mass and Capacity',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color(0xFF7B2FF2),
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: isGameMode ? _buildGameSection() : _buildLessonSection(),
      ),
    );
  }

  Widget _buildLessonSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learn about Mass and Capacity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7B2FF2),
            ),
          ),
          SizedBox(height: 24),
          _buildLessonCard(
            'Mass',
            'Mass is how heavy something is.',
            'assets/images/measures/dumbbell_feather.svg',
            'Example: A dumbbell is heavier than a feather.',
            'Measured in: kilograms (kg) and grams (g)',
          ),
          SizedBox(height: 16),
          _buildLessonCard(
            'Capacity',
            'Capacity is how much something can hold.',
            'assets/images/measures/jug_cup.svg',
            'Example: A jug can hold more water than a cup.',
            'Measured in: liters (L) and milliliters (mL)',
          ),
          SizedBox(height: 16),
          _buildLessonCard(
            'Comparing Mass',
            'We can compare objects to see which is heavier.',
            'assets/images/measures/watermelon_apple.svg',
            'Example: A watermelon is heavier than an apple.',
            'Compare using: heavier than, lighter than, same as',
          ),
          SizedBox(height: 16),
          _buildLessonCard(
            'Comparing Capacity',
            'We can compare containers to see which holds more.',
            'assets/images/measures/bottle_comparison.svg',
            'Example: A 1L bottle holds more than a 500ml bottle.',
            'Compare using: more than, less than, equal to',
          ),
          SizedBox(height: 16),
          _buildLessonCard(
            'Everyday Objects',
            'We use mass and capacity measurements daily.',
            'assets/images/measures/books_pencil.svg',
            'Example: Books are heavier than pencils.',
            'Used in: cooking, shopping, and more',
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonImage(String imagePath, String label, bool isLeft, {double size = 60}) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: size,
            child: ClipRect(
              child: Align(
                alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                widthFactor: 0.5,
                child: SvgPicture.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  height: size,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String imagePath, List<String> labels, {double size = 60}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildComparisonImage(imagePath, labels[0], true, size: size),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'VS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B2FF2),
              ),
            ),
          ),
          _buildComparisonImage(imagePath, labels[1], false, size: size),
        ],
      ),
    );
  }

  Widget _buildLessonCard(String title, String description, String imagePath, String example, String units) {
    final images = {
      'assets/images/measures/dumbbell_feather.svg': ['DUMBBELL', 'FEATHER'],
      'assets/images/measures/jug_cup.svg': ['JUG', 'CUP'],
      'assets/images/measures/watermelon_apple.svg': ['WATERMELON', 'APPLE'],
      'assets/images/measures/bottle_comparison.svg': ['1L BOTTLE', '500ML BOTTLE'],
      'assets/images/measures/books_pencil.svg': ['BOOKS', 'PENCIL'],
    };

    final labels = images[imagePath] ?? ['ITEM 1', 'ITEM 2'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B2FF2),
              ),
            ),
            SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: _buildComparisonRow(imagePath, labels, size: 100),
            ),
            SizedBox(height: 24),
            Text(
              example,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              units.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
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

    if (!isGameMode || currentQuestion >= practiceQuestions.length) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
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
                  'Question ${currentQuestion + 1}/${practiceQuestions.length}',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              practiceQuestions[currentQuestion]['question'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _buildComparisonRow(
            practiceQuestions[currentQuestion]['image1'],
            [
              practiceQuestions[currentQuestion]['leftLabel'],
              practiceQuestions[currentQuestion]['rightLabel']
            ],
            size: 120,
          ),
          const SizedBox(height: 32),
          ...practiceQuestions[currentQuestion]['options'].map((option) => 
            _buildAnswerOption(option, option == practiceQuestions[currentQuestion]['correctAnswer'])
          ).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class WatermelonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = Color(0xFF4CAF50)  // Green color for watermelon
      ..style = PaintingStyle.fill;
    
    final Paint stripePaint = Paint()
      ..color = Color(0xFF388E3C)  // Darker green for stripes
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final Paint fleshPaint = Paint()
      ..color = Color(0xFFFF5252)  // Red color for flesh
      ..style = PaintingStyle.fill;
    
    // Draw main watermelon shape
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.9,
        height: size.height * 0.8,
      ),
      fillPaint,
    );

    // Draw stripes
    for (int i = 0; i < 5; i++) {
      double y = size.height * (0.3 + i * 0.1);
      canvas.drawLine(
        Offset(size.width * 0.2, y),
        Offset(size.width * 0.8, y),
        stripePaint,
      );
    }

    // Draw a small section showing the red flesh
    final Path fleshPath = Path()
      ..moveTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..close();
    canvas.drawPath(fleshPath, fleshPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ApplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint bodyPaint = Paint()
      ..color = Color(0xFFF44336)  // Red color for apple
      ..style = PaintingStyle.fill;
    
    final Paint stemPaint = Paint()
      ..color = Color(0xFF795548)  // Brown color for stem
      ..style = PaintingStyle.fill;
    
    final Paint leafPaint = Paint()
      ..color = Color(0xFF4CAF50)  // Green color for leaf
      ..style = PaintingStyle.fill;
    
    // Draw main apple body
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.4,
      bodyPaint,
    );
    
    // Draw stem
    final Path stemPath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.2)
      ..lineTo(size.width * 0.55, size.height * 0.2)
      ..lineTo(size.width * 0.5, size.height * 0.1)
      ..close();
    canvas.drawPath(stemPath, stemPaint);
    
    // Draw leaf
    final Path leafPath = Path()
      ..moveTo(size.width * 0.6, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.1,
        size.width * 0.8,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.25,
        size.width * 0.6,
        size.height * 0.2,
      );
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 