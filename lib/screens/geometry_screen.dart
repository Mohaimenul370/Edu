import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import '../services/shared_preference_service.dart';
import 'package:flutter/services.dart';
import '../utils/utils_func.dart';

class GeometryConcept {
  final String name;
  final Widget visual;
  final String description;
  final List<String> options;
  final String section;
  final String? exercise;

  GeometryConcept({
    required this.name,
    required this.visual,
    required this.description,
    required this.options,
    required this.section,
    this.exercise,
  });
}

class GeometryScreen extends StatefulWidget {
  final bool isGameMode;

  const GeometryScreen({
    super.key,
    required this.isGameMode,
  });

  @override
  State<GeometryScreen> createState() => _GeometryScreenState();
}

class _GeometryScreenState extends State<GeometryScreen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<GeometryConcept> shuffledConcepts = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _optionAnimationController;
  late Animation<double> _optionScaleAnimation;
  bool _isLoading = false;
  String selectedSection = '3D Shapes';

  final List<GeometryConcept> concepts = [
    // 3D Shapes Section
    GeometryConcept(
      name: 'Introduction to 3D Shapes',
      visual: _build3DShapeVisual('intro'),
      description:
          'We live inside 3D shapes and have them all around us. You can hold a 3D shape in your hand.',
      options: ['True', 'False'],
      section: '3D Shapes',
      exercise: 'Look around your room. Can you spot any 3D shapes?',
    ),
    GeometryConcept(
      name: 'Parts of 3D Shapes',
      visual: _build3DShapeVisual('parts'),
      description:
          '3D shapes have faces and edges. Some have flat faces, others have curved surfaces.',
      options: ['Face', 'Edge', 'Surface', 'All of these'],
      section: '3D Shapes',
      exercise: 'Touch a face and an edge on a 3D shape.',
    ),
    GeometryConcept(
      name: 'Cube Properties',
      visual: _build3DShapeVisual('cube'),
      description: 'A cube has 6 faces and 12 edges. All faces are squares.',
      options: ['6 faces', '8 faces', '12 faces', '4 faces'],
      section: '3D Shapes',
      exercise: 'Count the faces and edges of a cube.',
    ),
    GeometryConcept(
      name: 'Cylinder Properties',
      visual: _build3DShapeVisual('cylinder'),
      description: 'A cylinder has 2 flat circular faces and 1 curved surface.',
      options: ['Can roll', 'Cannot roll', 'Has corners', 'Is flat'],
      section: '3D Shapes',
      exercise: 'Will a cylinder roll? Try it!',
    ),
    GeometryConcept(
      name: 'Sphere Properties',
      visual: _build3DShapeVisual('sphere'),
      description: 'A sphere has no faces or edges, only one curved surface.',
      options: ['Has faces', 'Has edges', 'Can roll', 'Is flat'],
      section: '3D Shapes',
      exercise: 'Compare how a sphere and cylinder roll.',
    ),

    // 2D Shapes Section
    GeometryConcept(
      name: 'Introduction to 2D Shapes',
      visual: _build2DShapeVisual('intro'),
      description:
          '2D shapes are flat. This makes them different from 3D shapes.',
      options: ['True', 'False'],
      section: '2D Shapes',
      exercise: 'Can you hold a 2D shape in your hand?',
    ),
    GeometryConcept(
      name: 'Circle',
      visual: _build2DShapeVisual('circle'),
      description: 'A circle has one curved side and no corners.',
      options: ['Curved sides', 'Straight sides', 'No sides', 'Four sides'],
      section: '2D Shapes',
      exercise: 'Draw a circle in the air with your finger.',
    ),
    GeometryConcept(
      name: 'Square',
      visual: _build2DShapeVisual('square'),
      description: 'A square has 4 equal straight sides and 4 corners.',
      options: ['4 sides', '3 sides', '5 sides', '6 sides'],
      section: '2D Shapes',
      exercise: 'Find something square in your room.',
    ),
    GeometryConcept(
      name: 'Triangle',
      visual: _build2DShapeVisual('triangle'),
      description: 'A triangle has 3 straight sides and 3 corners.',
      options: ['3 sides', '4 sides', '5 sides', '6 sides'],
      section: '2D Shapes',
      exercise: 'Draw a triangle using 3 straight lines.',
    ),
    GeometryConcept(
      name: 'Rectangle',
      visual: _build2DShapeVisual('rectangle'),
      description:
          'A rectangle has 4 straight sides, with opposite sides equal.',
      options: ['4 sides', '3 sides', '5 sides', '6 sides'],
      section: '2D Shapes',
      exercise: 'How is a rectangle different from a square?',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();

    // Initialize the main animation controller
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

    // Initialize the option animation controller
    _optionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _optionScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _optionAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isGameMode) {
      _startGame();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _optionAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }


  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;

      // Simplified questions for better understanding
      final gameQuestions = [
        GeometryConcept(
          name:
              '6 faces', // Changed from 'Cube Properties' to match the correct answer
          visual: _build3DShapeVisual('cube'),
          description:
              'How many faces does a cube have?', // Simplified question
          options: ['6 faces', '4 faces', '8 faces', '12 faces'],
          section: '3D Shapes',
          exercise: null,
        ),
        GeometryConcept(
          name: 'Can roll', // Changed to match the correct answer
          visual: _build3DShapeVisual('sphere'),
          description: 'What can a sphere do?', // Simplified question
          options: ['Can roll', 'Has edges', 'Has corners', 'Is flat'],
          section: '3D Shapes',
          exercise: null,
        ),
        GeometryConcept(
          name: 'Curved sides', // Changed to match the correct answer
          visual: _build2DShapeVisual('circle'),
          description:
              'What type of sides does a circle have?', // Simplified question
          options: ['Curved sides', 'Straight sides', 'No sides', 'Four sides'],
          section: '2D Shapes',
          exercise: null,
        ),
        GeometryConcept(
          name: '4 sides', // Changed to match the correct answer
          visual: _build2DShapeVisual('square'),
          description:
              'How many sides does a square have?', // Simplified question
          options: ['4 sides', '3 sides', '5 sides', '6 sides'],
          section: '2D Shapes',
          exercise: null,
        ),
        GeometryConcept(
          name: '3 sides', // Changed to match the correct answer
          visual: _build2DShapeVisual('triangle'),
          description:
              'How many sides does a triangle have?', // Simplified question
          options: ['3 sides', '4 sides', '5 sides', '6 sides'],
          section: '2D Shapes',
          exercise: null,
        ),
      ];

      final random = math.Random();
      shuffledConcepts = List.from(gameQuestions)..shuffle(random);
      for (var concept in shuffledConcepts) {
        // Create a new list to ensure proper shuffling
        final originalOptions = List<String>.from(concept.options);
        originalOptions.shuffle(random);
        concept.options.clear();
        concept.options.addAll(originalOptions);
      }
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) async {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledConcepts[currentQuestion].name;
      if (isCorrect) {
        score++;
      }
    });

    if (isCorrect) {
      await speakText('Correct! Well done!');
    } else {
      await speakText('Try again! The correct answer is ${shuffledConcepts[currentQuestion].name}');
    }

    // Trigger animation for the selected option
    _optionAnimationController.forward().then((_) {
      _optionAnimationController.reverse();
    });

    // Wait for 1.5 seconds before moving to next question
    Future.delayed(const Duration(milliseconds: 0), () async {
      if (currentQuestion < 4) {
        setState(() {
          currentQuestion++;
          selectedAnswer = null;
          showResult = false;
        });
      } else {
        if (mounted) {
          await SharedPreferenceService.saveGameProgress(
            'geometry',
            score,
            shuffledConcepts.length,
          );
          developer.log(
              'Game progress saved for geometry: Score $score out of ${shuffledConcepts.length}');
          setState(() {
            SharedPreferenceService.updateOverallProgress();
          });
          showGameCompletionDialog(context, score, shuffledConcepts, setState,
              _startGame, 'geometry');
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final filteredConcepts =
        concepts.where((c) => c.section == selectedSection).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGameMode ? 'Geometry Game' : 'Learning Geometry'),
        centerTitle: true,
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Section Toggle - Only show in lesson mode
          if (!widget.isGameMode) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedSection == '3D Shapes'
                          ? Colors.purple
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () =>
                        setState(() => selectedSection = '3D Shapes'),
                    child: const Text('3D Shapes'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedSection == '2D Shapes'
                          ? Colors.purple
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () =>
                        setState(() => selectedSection = '2D Shapes'),
                    child: const Text('2D Shapes'),
                  ),
                ],
              ),
            ),

            // Section Introduction
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                selectedSection == '3D Shapes'
                    ? 'We live inside 3D shapes and have them all around us. Let\'s explore them!'
                    : '2D shapes are flat and make patterns in our world. Let\'s discover them!',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.purple,
                ),
              ),
            ),
          ],

          // Content Area
          Expanded(
            child: widget.isGameMode
                ? _buildGameMode()
                : _buildLessonMode(filteredConcepts),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonMode(List<GeometryConcept> filteredConcepts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredConcepts.length,
      itemBuilder: (context, index) {
        final concept = filteredConcepts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concept.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
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
                    child: concept.visual,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  concept.description,
                  style: const TextStyle(fontSize: 16),
                ),
                if (concept.exercise != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              const Icon(Icons.extension, color: Colors.purple),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Try This!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                concept.exercise!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameMode() {
    if (currentQuestion >= 5) {
      return _buildGameComplete();
    }

    final concept = shuffledConcepts[currentQuestion];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score and Progress Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestion + 1} of 5',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Question Visual
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: concept.visual,
            ),
          ),
          const SizedBox(height: 16),
          // Question Text
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                concept.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Answer Options
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: concept.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = selectedAnswer == option;
                final isCorrect = showResult &&
                    option == shuffledConcepts[currentQuestion].name;
                final isIncorrect = showResult &&
                    isSelected &&
                    option != shuffledConcepts[currentQuestion].name;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: AnimatedBuilder(
                    animation: _optionAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? _optionScaleAnimation.value : 1.0,
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          elevation: isSelected ? 4 : 1,
                          child: InkWell(
                            onTap:
                                showResult ? null : () => _checkAnswer(option),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
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
                                              ? Colors.purple
                                              : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
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
                                            ? Colors.white
                                            : isSelected
                                                ? Colors.purple
                                                : Colors.black87,
                                  ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildGameComplete() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showGameCompletionDialog(
          context, score, shuffledConcepts, setState, _startGame, 'geometry');
    });

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Color _getOptionColor(String option) {
    if (!showResult) {
      return Colors.purple;
    }

    // If this is the selected answer
    if (option == selectedAnswer) {
      // Show green for correct, red for incorrect
      return isCorrect ? Colors.green : Colors.red;
    }

    // If user selected wrong answer, highlight the correct one
    if (!isCorrect && option == shuffledConcepts[currentQuestion].name) {
      return Colors.green;
    }

    // Other options should be dimmed
    return Colors.grey.withOpacity(0.5);
  }

  static Widget _build3DShapeVisual(String type) {
    return Container(
      width: 200,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: ThreeDShapePainter(type),
      ),
    );
  }

  static Widget _build2DShapeVisual(String type) {
    return Container(
      width: 200,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: TwoDShapePainter(type),
      ),
    );
  }
}

class ThreeDShapePainter extends CustomPainter {
  final String type;

  ThreeDShapePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (type) {
      case 'cube':
        _drawCube(canvas, size, paint);
        break;
      case 'cylinder':
        _drawCylinder(canvas, size, paint);
        break;
      case 'sphere':
        _drawSphere(canvas, size, paint);
        break;
      case 'intro':
        _drawIntro3D(canvas, size, paint);
        break;
      case 'parts':
        _drawParts3D(canvas, size, paint);
        break;
    }
  }

  void _drawCube(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final side = size.width * 0.4;

    // Front face
    final frontPath = Path()
      ..moveTo(center.dx - side / 2, center.dy - side / 2)
      ..lineTo(center.dx + side / 2, center.dy - side / 2)
      ..lineTo(center.dx + side / 2, center.dy + side / 2)
      ..lineTo(center.dx - side / 2, center.dy + side / 2)
      ..close();

    // Back face
    final backPath = Path()
      ..moveTo(center.dx - side / 4, center.dy - side / 1.5)
      ..lineTo(center.dx + side / 1.5, center.dy - side / 1.5)
      ..lineTo(center.dx + side / 1.5, center.dy + side / 4)
      ..lineTo(center.dx - side / 4, center.dy + side / 4)
      ..close();

    // Connecting lines
    final connectPath = Path()
      ..moveTo(center.dx - side / 2, center.dy - side / 2)
      ..lineTo(center.dx - side / 4, center.dy - side / 1.5)
      ..moveTo(center.dx + side / 2, center.dy - side / 2)
      ..lineTo(center.dx + side / 1.5, center.dy - side / 1.5)
      ..moveTo(center.dx + side / 2, center.dy + side / 2)
      ..lineTo(center.dx + side / 1.5, center.dy + side / 4)
      ..moveTo(center.dx - side / 2, center.dy + side / 2)
      ..lineTo(center.dx - side / 4, center.dy + side / 4);

    canvas.drawPath(frontPath, paint);
    canvas.drawPath(backPath, paint);
    canvas.drawPath(connectPath, paint);
  }

  void _drawCylinder(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.2;
    final height = size.height * 0.4;

    // Top ellipse
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, -height / 2),
        width: radius * 2,
        height: radius,
      ),
      paint,
    );

    // Bottom ellipse
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, height / 2),
        width: radius * 2,
        height: radius,
      ),
      paint,
    );

    // Side lines
    canvas.drawLine(
      center.translate(-radius, -height / 2),
      center.translate(-radius, height / 2),
      paint,
    );
    canvas.drawLine(
      center.translate(radius, -height / 2),
      center.translate(radius, height / 2),
      paint,
    );
  }

  void _drawSphere(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Main circle
    canvas.drawCircle(center, radius, paint);

    // Ellipses for 3D effect
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius,
        height: radius * 2,
      ),
      paint,
    );
  }

  void _drawIntro3D(Canvas canvas, Size size, Paint paint) {
    // Draw a simple house-like shape to demonstrate 3D
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.4;
    final height = size.height * 0.4;

    // Front face
    final frontPath = Path()
      ..moveTo(center.dx - width / 2, center.dy + height / 2)
      ..lineTo(center.dx - width / 2, center.dy - height / 2)
      ..lineTo(center.dx, center.dy - height)
      ..lineTo(center.dx + width / 2, center.dy - height / 2)
      ..lineTo(center.dx + width / 2, center.dy + height / 2)
      ..close();

    canvas.drawPath(frontPath, paint);

    // Side face
    final sidePath = Path()
      ..moveTo(center.dx + width / 2, center.dy - height / 2)
      ..lineTo(center.dx + width, center.dy - height / 3)
      ..lineTo(center.dx + width, center.dy + height / 1.5)
      ..lineTo(center.dx + width / 2, center.dy + height / 2);

    canvas.drawPath(sidePath, paint);

    // Roof side
    canvas.drawLine(
      center.translate(0, -height),
      center.translate(width / 2, -height / 3),
      paint,
    );
  }

  void _drawParts3D(Canvas canvas, Size size, Paint paint) {
    // Draw a cube with labeled parts
    _drawCube(canvas, size, paint);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: 'Face',
        style: TextStyle(
          color: Colors.purple,
          fontSize: 12,
        ),
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.7, size.height * 0.3));

    textPainter.text = const TextSpan(
      text: 'Edge',
      style: TextStyle(
        color: Colors.purple,
        fontSize: 12,
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.3, size.height * 0.7));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TwoDShapePainter extends CustomPainter {
  final String type;

  TwoDShapePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    switch (type) {
      case 'circle':
        _drawCircle(canvas, size, paint);
        break;
      case 'square':
        _drawSquare(canvas, size, paint);
        break;
      case 'triangle':
        _drawTriangle(canvas, size, paint);
        break;
      case 'rectangle':
        _drawRectangle(canvas, size, paint);
        break;
      case 'intro':
        _drawIntro2D(canvas, size, paint);
        break;
    }
  }

  void _drawCircle(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.3, paint);
  }

  void _drawSquare(Canvas canvas, Size size, Paint paint) {
    final side = size.width * 0.6;
    final left = (size.width - side) / 2;
    final top = (size.height - side) / 2;

    canvas.drawRect(
      Rect.fromLTWH(left, top, side, side),
      paint,
    );
  }

  void _drawTriangle(Canvas canvas, Size size, Paint paint) {
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.2)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawRectangle(Canvas canvas, Size size, Paint paint) {
    final width = size.width * 0.7;
    final height = size.height * 0.4;
    final left = (size.width - width) / 2;
    final top = (size.height - height) / 2;

    canvas.drawRect(
      Rect.fromLTWH(left, top, width, height),
      paint,
    );
  }

  void _drawIntro2D(Canvas canvas, Size size, Paint paint) {
    // Draw multiple 2D shapes to demonstrate flatness
    _drawCircle(canvas, Size(size.width * 0.4, size.height * 0.4), paint);
    _drawSquare(canvas, Size(size.width * 0.4, size.height * 0.4), paint);
    _drawTriangle(canvas, Size(size.width * 0.4, size.height * 0.4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
