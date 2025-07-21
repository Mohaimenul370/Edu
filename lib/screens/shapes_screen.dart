import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import '../utils/utils_func.dart';
import '../widgets/menu_card.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class Question {
  final String shape;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.shape,
    required this.options,
    required this.correctAnswer,
  });
}

class ShapeActivity {
  final String title;
  final String description;
  final Widget visual;
  final String instruction;
  final List<String> options;

  ShapeActivity({
    required this.title,
    required this.description,
    required this.visual,
    required this.instruction,
    required this.options,
  });
}

class ShapesScreen extends StatefulWidget {
  final bool isGameMode;
  
  const ShapesScreen({
    super.key,
    this.isGameMode = false,
  });

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<Question> questions = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<ShapeActivity> get activities => [
    ShapeActivity(
      title: 'Basic Shapes',
      description: 'Learn about basic shapes like circle, square, and triangle',
      visual: _buildBasicShapesVisual(),
      instruction: 'Identify and learn the names of basic shapes',
      options: ['Circle', 'Square', 'Triangle', 'Rectangle'],
    ),
    ShapeActivity(
      title: 'Advanced Shapes',
      description: 'Explore more complex shapes like pentagon and hexagon',
      visual: _buildAdvancedShapesVisual(),
      instruction: 'Learn about shapes with more sides',
      options: ['Pentagon', 'Hexagon', 'Octagon', 'Star'],
    ),
    ShapeActivity(
      title: 'Shape Properties',
      description: 'Learn about sides, corners, and other properties of shapes',
      visual: _buildShapePropertiesVisual(),
      instruction: 'Count the sides and corners of each shape',
      options: ['3 sides', '4 sides', '5 sides', '6 sides'],
    ),
    ShapeActivity(
      title: 'Shape Patterns',
      description: 'Learn to identify and create patterns with shapes',
      visual: _buildShapePatternsVisual(),
      instruction: 'Continue the pattern with the correct shape',
      options: ['Circle', 'Square', 'Triangle', 'Star'],
    ),
    ShapeActivity(
      title: 'Real World Shapes',
      description: 'Find shapes in everyday objects around you',
      visual: _buildRealWorldShapesVisual(),
      instruction: 'Match the shape to real world objects',
      options: ['Clock', 'Window', 'Road Sign', 'Ball'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeTts();
    _initializeAnimation();
    if (isGameMode) {
      _startGame();
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      
      // Create a list of shape questions with consistent casing
      questions = [
        Question(
          shape: 'circle',
          options: ['Circle', 'Square', 'Triangle', 'Rectangle'],
          correctAnswer: 'Circle',
        ),
        Question(
          shape: 'square',
          options: ['Circle', 'Square', 'Triangle', 'Rectangle'],
          correctAnswer: 'Square',
        ),
        Question(
          shape: 'triangle',
          options: ['Circle', 'Square', 'Triangle', 'Rectangle'],
          correctAnswer: 'Triangle',
        ),
        Question(
          shape: 'pentagon',
          options: ['Pentagon', 'Hexagon', 'Octagon', 'Star'],
          correctAnswer: 'Pentagon',
        ),
        Question(
          shape: 'hexagon',
          options: ['Pentagon', 'Hexagon', 'Octagon', 'Star'],
          correctAnswer: 'Hexagon',
        ),
      ];
    });
  }

  void _checkAnswer(String answer) async {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == questions[currentQuestion].correctAnswer;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (isCorrect) {
      score++;
      await speakText('Correct! This is a ${questions[currentQuestion].correctAnswer}');
    } else {
      await speakText('Try again! The correct answer is ${questions[currentQuestion].correctAnswer}');
    }

    Future.delayed(const Duration(milliseconds: 0), () async {
      if (mounted) {
        if (currentQuestion < questions.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            showResult = false;
          });
        } else {
          if (mounted) {
            await SharedPreferenceService.saveGameProgress(
              'shapes',
              score,
              questions.length,
            );
            developer.log('Game progress saved for Shapes: Score $score out of ${questions.length}');
            setState(() {
              SharedPreferenceService.updateOverallProgress();
            });
            showGameCompletionDialog(context, score, questions, setState, _startGame, 'Shapes');
          }
        }
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF6A1B9A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF6A1B9A),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(
          widget.isGameMode ? 'Shapes Practice' : 'Learn Shapes',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF7B2FF2),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
          child: widget.isGameMode ? _buildGameMode() : _buildLearningMode(),
        ),
      ),
    );
  }

  Widget _buildLearningMode() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 200,
                child: RawScrollbar(
                  thumbColor: Theme.of(context).primaryColor.withOpacity(0.6),
                  radius: const Radius.circular(20),
                  thickness: 5,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: activity.visual,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.instruction,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameMode() {
    return Column(
      children: [
        // Score and Question number indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score display
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              // Question counter
              Text(
                'Question ${currentQuestion + 1}/${questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              minHeight: 8,
            ),
          ),
        ),
        // Game content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Question visual
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: _buildShapeVisual(questions[currentQuestion]),
                ),
              ),
              const SizedBox(height: 24),
              // Question text
              Text(
                'What shape is this?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Options grid
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: questions[currentQuestion]
                    .options
                    .map((option) => _buildAnswerOption(option))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerOption(String option) {
    final isSelected = selectedAnswer == option;
    final isCorrect = showResult && option == questions[currentQuestion].correctAnswer;
    final isIncorrect = showResult && isSelected && option != questions[currentQuestion].correctAnswer;

    Color backgroundColor;
    if (isCorrect) {
      backgroundColor = Colors.green.shade100;
    } else if (isIncorrect) {
      backgroundColor = Colors.red.shade100;
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);
    } else {
      backgroundColor = Colors.white;
    }

    Color borderColor;
    if (isCorrect) {
      borderColor = Colors.green;
    } else if (isIncorrect) {
      borderColor = Colors.red;
    } else if (isSelected) {
      borderColor = Theme.of(context).colorScheme.primary;
    } else {
      borderColor = Colors.grey.shade300;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: showResult ? null : () => _checkAnswer(option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (isCorrect)
                      const Icon(Icons.check_circle, color: Colors.green, size: 20)
                    else if (isIncorrect)
                      const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShapeVisual(Question question) {
    switch (question.shape.toLowerCase()) {
      case 'circle':
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      case 'square':
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case 'rectangle':
        return Container(
          width: 160,
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case 'triangle':
        return CustomPaint(
          size: const Size(120, 120),
          painter: TrianglePainter(color: Theme.of(context).colorScheme.primary),
        );
      case 'pentagon':
        return CustomPaint(
          size: const Size(120, 120),
          painter: PentagonPainter(color: Theme.of(context).colorScheme.primary),
        );
      case 'hexagon':
        return CustomPaint(
          size: const Size(120, 120),
          painter: HexagonPainter(color: Theme.of(context).colorScheme.primary),
        );
      default:
        return Text(
          question.shape,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Widget _buildBasicShapesVisual() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShapeCard('Circle', _buildShapeVisual(Question(shape: 'Circle', options: [], correctAnswer: ''))),
          const SizedBox(width: 16),
          _buildShapeCard('Square', _buildShapeVisual(Question(shape: 'Square', options: [], correctAnswer: ''))),
          const SizedBox(width: 16),
          _buildShapeCard('Triangle', _buildShapeVisual(Question(shape: 'Triangle', options: [], correctAnswer: ''))),
          const SizedBox(width: 16),
          _buildShapeCard('Rectangle', _buildShapeVisual(Question(shape: 'Rectangle', options: [], correctAnswer: ''))),
        ],
      ),
    );
  }

  Widget _buildAdvancedShapesVisual() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShapeCard('Pentagon', _buildShapeVisual(Question(shape: 'Pentagon', options: [], correctAnswer: ''))),
          const SizedBox(width: 16),
          _buildShapeCard('Hexagon', _buildShapeVisual(Question(shape: 'Hexagon', options: [], correctAnswer: ''))),
          const SizedBox(width: 16),
          const Icon(Icons.star, size: 100, color: Colors.amber),
        ],
      ),
    );
  }

  Widget _buildShapePropertiesVisual() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildShapeCard('Triangle', _buildShapeVisual(Question(shape: 'Triangle', options: [], correctAnswer: ''))),
        _buildShapeCard('Square', _buildShapeVisual(Question(shape: 'Square', options: [], correctAnswer: ''))),
        _buildShapeCard('Pentagon', _buildShapeVisual(Question(shape: 'Pentagon', options: [], correctAnswer: ''))),
        _buildShapeCard('Hexagon', _buildShapeVisual(Question(shape: 'Hexagon', options: [], correctAnswer: ''))),
      ],
    );
  }

  Widget _buildShapePatternsVisual() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShapeCard('Circle', _buildShapeVisual(Question(shape: 'Circle', options: [], correctAnswer: ''))),
          const Icon(Icons.arrow_forward, size: 40, color: Colors.grey),
          _buildShapeCard('Square', _buildShapeVisual(Question(shape: 'Square', options: [], correctAnswer: ''))),
          const Icon(Icons.arrow_forward, size: 40, color: Colors.grey),
          _buildShapeCard('Triangle', _buildShapeVisual(Question(shape: 'Triangle', options: [], correctAnswer: ''))),
          const Icon(Icons.arrow_forward, size: 40, color: Colors.grey),
          _buildShapeCard('Circle', _buildShapeVisual(Question(shape: 'Circle', options: [], correctAnswer: ''))),
        ],
      ),
    );
  }

  Widget _buildRealWorldShapesVisual() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildRealWorldObject('Clock', Icons.access_time),
        _buildRealWorldObject('Window', Icons.window),
        _buildRealWorldObject('Road Sign', Icons.traffic),
        _buildRealWorldObject('Ball', Icons.sports_soccer),
      ],
    );
  }

  Widget _buildRealWorldObject(String name, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 60, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShapeCard(String shapeName, Widget shapeVisual) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: shapeVisual,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              shapeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Widget _buildLessonMode() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildLessonSection(
          'Basic Shapes',
          [
            _buildShapeCard('Circle', _buildShapeVisual(Question(shape: 'circle', options: [], correctAnswer: ''))),
            _buildShapeCard('Square', _buildShapeVisual(Question(shape: 'square', options: [], correctAnswer: ''))),
            _buildShapeCard('Triangle', _buildShapeVisual(Question(shape: 'triangle', options: [], correctAnswer: ''))),
            _buildShapeCard('Rectangle', _buildShapeVisual(Question(shape: 'rectangle', options: [], correctAnswer: ''))),
          ],
        ),
        const SizedBox(height: 24),
        _buildLessonSection(
          'Advanced Shapes',
          [
            _buildShapeCard('Pentagon', _buildShapeVisual(Question(shape: 'pentagon', options: [], correctAnswer: ''))),
            _buildShapeCard('Hexagon', _buildShapeVisual(Question(shape: 'hexagon', options: [], correctAnswer: ''))),
          ],
        ),
        const SizedBox(height: 24),
        _buildShapeProperties(),
        const SizedBox(height: 24),
        _buildShapePatterns(),
      ],
    );
  }

  Widget _buildLessonSection(String title, List<Widget> shapes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: shapes.map((shape) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: shape,
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildShapeProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shape Properties',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildPropertyCard('Triangle', '3 sides', Question(shape: 'triangle', options: [], correctAnswer: '')),
            _buildPropertyCard('Square', '4 equal sides', Question(shape: 'square', options: [], correctAnswer: '')),
            _buildPropertyCard('Pentagon', '5 sides', Question(shape: 'pentagon', options: [], correctAnswer: '')),
            _buildPropertyCard('Hexagon', '6 sides', Question(shape: 'hexagon', options: [], correctAnswer: '')),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyCard(String shapeName, String property, Question question) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: _buildShapeVisual(question),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            shapeName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            property,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShapePatterns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shape Patterns',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShapeVisual(Question(shape: 'circle', options: [], correctAnswer: '')),
              const Icon(Icons.arrow_forward, size: 40, color: Colors.grey),
              _buildShapeVisual(Question(shape: 'square', options: [], correctAnswer: '')),
              const Icon(Icons.arrow_forward, size: 40, color: Colors.grey),
              _buildShapeVisual(Question(shape: 'triangle', options: [], correctAnswer: '')),
              const Icon(Icons.arrow_forward, size: 40, color: Colors.grey),
              _buildShapeVisual(Question(shape: 'circle', options: [], correctAnswer: '')),
            ],
          ),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => color != oldDelegate.color;
}

class PentagonPainter extends CustomPainter {
  final Color color;

  PentagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Start at the top point
    path.moveTo(centerX, 0);

    // Calculate the points of the pentagon
    for (int i = 1; i <= 5; i++) {
      final angle = (i * 2 * pi / 5) - (pi / 2); // Start from the top
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      path.lineTo(x, y);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PentagonPainter oldDelegate) => color != oldDelegate.color;
}

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Start at the rightmost point
    path.moveTo(centerX + radius, centerY);

    // Calculate the points of the hexagon
    for (int i = 1; i <= 6; i++) {
      final angle = (i * 2 * pi / 6);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      path.lineTo(x, y);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HexagonPainter oldDelegate) => color != oldDelegate.color;
} 