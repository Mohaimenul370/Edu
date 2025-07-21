import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class FractionActivity {
  final String title;
  final String description;
  final Widget visual;
  final String instruction;
  final List<String> options;
  final String name;
  final String funFact;

  FractionActivity({
    required this.title,
    required this.description,
    required this.visual,
    required this.instruction,
    required this.options,
    required this.name,
    required this.funFact,
  });
}

class FractionsScreen extends StatefulWidget {
  final bool isGameMode;
  
  const FractionsScreen({
    super.key,
    this.isGameMode = false,
  });

  @override
  State<FractionsScreen> createState() => _FractionsScreenState();
}

class _FractionsScreenState extends State<FractionsScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<FractionActivity> shuffledActivities = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;
  int? expandedIndex;

  List<FractionActivity> get activities => [
    FractionActivity(
      title: 'What is a Half?',
      description: 'A fraction is a part of a whole. When you cut something into two equal parts, each part is called a half.',
      visual: _buildVisual('sandwich', [Colors.brown.shade200, Colors.brown.shade100]),
      instruction: 'Look at how objects can be divided into two equal parts',
      options: ['Half', 'Whole', 'Part', 'Equal'],
      name: 'Half',
      funFact: 'When you share something equally with one friend, you each get half!',
    ),
    FractionActivity(
      title: 'Half in Real Life',
      description: 'We use halves in many everyday situations:\n- Half of a sandwich\n- Half a jug of water\n- Half past on a clock\n- Half of a number',
      visual: _buildVisual('clock', [Colors.purple.shade700, Colors.purple.shade200]),
      instruction: 'Halves are all around us in daily life',
      options: ['Half', 'Third', 'Quarter', 'Fifth'],
      name: 'Half',
      funFact: 'Half past 4 means it\'s 4:30!',
    ),
    FractionActivity(
      title: 'Coloring Halves',
      description: 'We can show half by coloring one part of two equal parts. Both parts must be exactly the same size.',
      visual: _buildVisual('shapes', [Colors.orange.shade800, Colors.orange.shade200]),
      instruction: 'Look at how shapes can be divided into halves',
      options: ['Equal parts', 'Different parts', 'Whole shape', 'Quarter parts'],
      name: 'Equal parts',
      funFact: 'Both halves of a shape must be exactly the same size!',
    ),
    FractionActivity(
      title: 'Half of Numbers',
      description: 'We can also find half of a number. Half of 10 is 5 because 5 + 5 = 10.',
      visual: _buildVisual('numbers', [Colors.green.shade700, Colors.green.shade200]),
      instruction: 'Half of a number means dividing it into two equal parts',
      options: ['5', '2', '4', '6'],
      name: '5',
      funFact: 'To find half of an even number, divide it by 2!',
    ),
    FractionActivity(
      title: 'Making a Whole',
      description: 'Two halves put together make a whole. For example, if you pour two half-full glasses of juice into a jug, you get a full jug!',
      visual: _buildVisual('jug', [Colors.blue.shade600, Colors.blue.shade200]),
      instruction: 'See how two halves combine to make one whole',
      options: ['Whole', 'Half', 'Part', 'Quarter'],
      name: 'Whole',
      funFact: 'Two halves always make a whole!',
    ),
  ];

  static Widget _buildVisual(String type, List<Color> gradient) {
    return Container(
      width: 200,
      height: 120,
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
      child: CustomPaint(
        painter: ContentPainter(type: type, gradient: gradient),
      ),
    );
  }

  void _initializeAnimation() {
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

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeTts();
    _initializeAnimation();
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
    if (isGameMode) {
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

  void _handleActivityTap(FractionActivity activity, int index) {
    _speakText('${activity.title}. ${activity.instruction}');
    setState(() {
      expandedIndex = expandedIndex == index ? null : index;
    });
  }

  void _checkAnswer(String answer)async {
    if (showResult) return;
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledActivities[currentQuestion].name;
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
      await speakText('Try again! The correct answer is ${shuffledActivities[currentQuestion].name}');
    }

    Future.delayed(const Duration(seconds: 0), () async {
      if (mounted) {
        if (currentQuestion < shuffledActivities.length - 1) {
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
              'fractions',
              score,
              shuffledActivities.length,
            );
            developer.log(
                'Game progress saved for statistics_1: Score $score out of ${shuffledActivities.length}');
            setState(() {
              SharedPreferenceService.updateOverallProgress();
            });
            showGameCompletionDialog(context, score, shuffledActivities, setState, _startGame, 'Fractions');
          }
        }
      }
    });
  }

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledActivities = List.from(activities)..shuffle();
      for (var activity in shuffledActivities) {
        activity.options.shuffle();
      }
      _animationController.reset();
      _scaleAnimationController.reset();
      _animationController.forward();
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
          widget.isGameMode ? 'Fractions Practice' : 'Learn Fractions',
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

  Widget _buildGameMode() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Question ${currentQuestion + 1}/${shuffledActivities.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(
                        value: (currentQuestion + 1) / shuffledActivities.length,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Score: $score',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Add question number
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Question ${currentQuestion + 1} of ${shuffledActivities.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Rest of game content
              shuffledActivities[currentQuestion].visual,
              const SizedBox(height: 20),
              Text(
                shuffledActivities[currentQuestion].instruction,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Options grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: shuffledActivities[currentQuestion]
                    .options
                    .map((option) => _buildAnswerOption(option))
                    .toList(),
              ),
            ],
          ),
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
        
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lesson ${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content section
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
                    const SizedBox(height: 16),
                    Center(child: activity.visual),
                    const SizedBox(height: 16),
                    Text(
                      activity.instruction,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activity.funFact,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildAnswerOption(String option) {
    final isSelected = selectedAnswer == option;
    final isCorrect = showResult && option == shuffledActivities[currentQuestion].name;
    final isIncorrect = showResult && isSelected && option != shuffledActivities[currentQuestion].name;
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
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
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }
}

class ContentPainter extends CustomPainter {
  final String type;
  final List<Color> gradient;

  ContentPainter({required this.type, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 'sandwich':
        _drawSandwich(canvas, size);
        break;
      case 'clock':
        _drawClock(canvas, size);
        break;
      case 'shapes':
        _drawShapes(canvas, size);
        break;
      case 'numbers':
        _drawNumbers(canvas, size);
        break;
      case 'jug':
        _drawJug(canvas, size);
        break;
    }
  }

  void _drawSandwich(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gradient[0]
      ..style = PaintingStyle.fill;

    // Draw bread slices
    final breadRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 30, size.width - 40, 60),
      const Radius.circular(10),
    );
    canvas.drawRRect(breadRect, paint);

    // Draw filling
    final fillingPaint = Paint()
      ..color = gradient[1]
      ..style = PaintingStyle.fill;
    final fillingRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(25, 45, size.width - 50, 30),
      const Radius.circular(5),
    );
    canvas.drawRRect(fillingRect, fillingPaint);

    // Draw cutting line
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width / 2, 20),
      Offset(size.width / 2, 100),
      linePaint,
    );
  }

  void _drawClock(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    // Reduce clock radius to 25% of the smaller dimension
    final radius = math.min(size.width, size.height) * 0.25;

    // Draw clock face
    canvas.drawCircle(center, radius, paint);

    // Draw numbers with smaller font
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 12);
      final offset = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );

      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(
          fontSize: 10,
          color: Colors.purple.shade700,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx - textPainter.width / 2,
          offset.dy - textPainter.height / 2,
        ),
      );
    }

    // Draw hands with adjusted thickness
    final handPaint = Paint()
      ..color = Colors.purple.shade700
      ..strokeWidth = 2;

    // Hour hand
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.4 * math.cos(-math.pi / 3),
        center.dy + radius * 0.4 * math.sin(-math.pi / 3),
      ),
      handPaint,
    );

    // Minute hand
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius * 0.6),
      handPaint,
    );

    // Center dot
    canvas.drawCircle(center, 3, Paint()..color = Colors.purple.shade700);
  }

  void _drawShapes(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw circle
    final circleCenter = Offset(size.width * 0.3, size.height / 2);
    paint.color = gradient[1];
    canvas.drawCircle(circleCenter, 30, paint);
    paint.color = gradient[0];
    final circlePath = Path()
      ..moveTo(circleCenter.dx, circleCenter.dy - 30)
      ..arcTo(
        Rect.fromCircle(center: circleCenter, radius: 30),
        -math.pi / 2,
        math.pi,
        false,
      );
    canvas.drawPath(circlePath, paint);

    // Draw square
    final squareCenter = Offset(size.width * 0.7, size.height / 2);
    paint.color = gradient[1];
    canvas.drawRect(
      Rect.fromCenter(center: squareCenter, width: 60, height: 60),
      paint,
    );
    paint.color = gradient[0];
    canvas.drawRect(
      Rect.fromLTWH(squareCenter.dx - 30, squareCenter.dy - 30, 30, 60),
      paint,
    );
  }

  void _drawNumbers(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw equation with better spacing and smaller font
    final equation = TextSpan(
      children: [
        TextSpan(
          text: '10',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const TextSpan(
          text: ' ÷ 2 = ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        TextSpan(
          text: '5',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    
    textPainter.text = equation;
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.2,
      ),
    );

    // Draw dots in a more compact and clearer arrangement
    final dotRadius = 4.0;
    final rowSpacing = 20.0;
    final dotSpacing = 15.0;

    // Calculate starting position to center the dots
    final totalWidth = dotSpacing * 4; // 5 dots, 4 spaces
    final startX = (size.width - totalWidth) / 2;
    final startY = size.height * 0.5;

    // Draw dividing line
    final linePaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(startX - 5, startY),
      Offset(startX + totalWidth + 5, startY),
      linePaint,
    );

    // Draw first row of dots (darker green)
    final topDotPaint = Paint()..color = Colors.green.shade700;
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(startX + (i * dotSpacing), startY - rowSpacing/2),
        dotRadius,
        topDotPaint,
      );
    }

    // Draw second row of dots (lighter green)
    final bottomDotPaint = Paint()..color = Colors.green.shade400;
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(startX + (i * dotSpacing), startY + rowSpacing/2),
        dotRadius,
        bottomDotPaint,
      );
    }
  }

  void _drawJug(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;

    // Draw first half-full glass
    _drawGlass(canvas, Offset(size.width * 0.25, size.height * 0.5), size.width * 0.15, size.height * 0.4, gradient[1], true);

    // Draw plus sign
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '+',
        style: TextStyle(
          fontSize: 24,
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // Draw second half-full glass
    _drawGlass(canvas, Offset(size.width * 0.75, size.height * 0.5), size.width * 0.15, size.height * 0.4, gradient[1], true);
  }

  void _drawGlass(Canvas canvas, Offset center, double width, double height, Color fillColor, bool halfFull) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = gradient[0];

    // Draw glass outline
    final glassPath = Path()
      ..moveTo(center.dx - width / 2, center.dy - height / 2)
      ..lineTo(center.dx - width / 3, center.dy + height / 2)
      ..lineTo(center.dx + width / 3, center.dy + height / 2)
      ..lineTo(center.dx + width / 2, center.dy - height / 2)
      ..close();
    canvas.drawPath(glassPath, paint);

    // Fill the glass halfway
    if (halfFull) {
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = fillColor;
      final fillPath = Path()
        ..moveTo(center.dx - width / 3, center.dy + height / 2)
        ..lineTo(center.dx + width / 3, center.dy + height / 2)
        ..lineTo(center.dx + width / 3, center.dy)
        ..lineTo(center.dx - width / 3, center.dy)
        ..close();
      canvas.drawPath(fillPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 