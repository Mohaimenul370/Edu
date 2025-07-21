import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import '../services/shared_preference_service.dart';
import 'package:flutter/services.dart';
import 'package:kg_education_app/screens/measures_2_screen.dart';
import 'package:kg_education_app/screens/statistics_screen.dart';
import 'package:kg_education_app/screens/positions_screen.dart';

class GeometryConcept {
  final String name;
  final String description;
  final Widget visual;
  final String example;
  final String section;

  GeometryConcept({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
    required this.section,
  });
}

class GeometryGameQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;
  final Widget visual;
  final String explanation;

  GeometryGameQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.visual,
    required this.explanation,
  });
}

class Geometry2Screen extends StatefulWidget {
  final bool isGameMode;
  const Geometry2Screen({super.key, required this.isGameMode});

  @override
  State<Geometry2Screen> createState() => _Geometry2ScreenState();
}

class _Geometry2ScreenState extends State<Geometry2Screen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  List<GeometryGameQuestion> _shuffledQuestions = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerScaleAnimation;
  late Animation<Color?> _answerColorAnimation;
  List<String> _currentOptions = [];
  String selectedSection = '3D Shapes';

  final List<GeometryConcept> concepts = [
    GeometryConcept(
      name: 'Cube Properties',
      description:
          'A cube has 6 flat faces, all faces are square shaped, and all edges are equal.',
      visual: _build3DShapeVisual('cube'),
      example: 'Count the faces and edges: 6 faces, 12 edges',
      section: '3D Shapes',
    ),
    GeometryConcept(
      name: 'Cuboid Properties',
      description:
          'A cuboid has 6 flat faces, faces can be rectangles, and edges may not be equal.',
      visual: _build3DShapeVisual('cuboid'),
      example:
          'Compare with cube: Different face shapes, different edge lengths',
      section: '3D Shapes',
    ),
    GeometryConcept(
      name: 'Pyramid Types',
      description:
          'Pyramids can have different base shapes with triangular faces meeting at a point.',
      visual: _build3DShapeVisual('pyramid'),
      example: 'Square base pyramid: 1 square face, 4 triangle faces',
      section: '3D Shapes',
    ),
    GeometryConcept(
      name: 'Sphere vs Cylinder',
      description:
          'Compare curved surfaces: Sphere rolls in any direction, cylinder rolls one way.',
      visual: _build3DShapeVisual('sphere_cylinder'),
      example: 'Cylinder: 2 flat circular faces, 1 curved surface',
      section: '3D Shapes',
    ),
    GeometryConcept(
      name: 'Building with Shapes',
      description:
          'Combine 3D shapes to create towers and structures that stand.',
      visual: _build3DShapeVisual('tower'),
      example: 'Stack cubes to count faces: More cubes = fewer visible faces',
      section: '3D Shapes',
    ),
    GeometryConcept(
      name: 'Shape Rotation',
      description:
          'Some 2D shapes look different when turned around but are still the same shape.',
      visual: _build2DShapeVisual('rotation'),
      example: 'Rectangle looks different when rotated, still a rectangle',
      section: '2D Shapes',
    ),
    GeometryConcept(
      name: 'Shape Patterns',
      description:
          'Create patterns by arranging 2D shapes with no gaps between them.',
      visual: _build2DShapeVisual('pattern'),
      example: 'Squares fit together perfectly with no spaces',
      section: '2D Shapes',
    ),
    GeometryConcept(
      name: 'Triangle Patterns',
      description:
          'Make larger triangles using smaller triangles in different arrangements.',
      visual: _build2DShapeVisual('triangles'),
      example: 'Use two colors to create triangle patterns',
      section: '2D Shapes',
    ),
    GeometryConcept(
      name: 'Square Construction',
      description: 'Build squares using equal sides and right angles.',
      visual: _build2DShapeVisual('square'),
      example: 'Four equal sticks make a square',
      section: '2D Shapes',
    ),
    GeometryConcept(
      name: '2D from 3D',
      description: 'Identify and draw the flat shapes you see on 3D objects.',
      visual: _build2DShapeVisual('faces'),
      example: 'Draw the circle face of a cylinder',
      section: '2D Shapes',
    ),
  ];

  final List<GeometryGameQuestion> geometryGameQuestions = [
    // Question 1: 3D Shape Faces
    GeometryGameQuestion(
      question:
          'Look at this cube. The colored sides are its faces.\nHow many faces can you count in total?',
      correctAnswer: '6 faces',
      options: ['4 faces', '5 faces', '6 faces', '8 faces'],
      visual: Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          'assets/images/geometry/cube_faces.svg',
          fit: BoxFit.contain,
        ),
      ),
      explanation:
          'A cube has 6 faces - front, back, top, bottom, left, and right. Each face is a square. You can see 3 faces, and there are 3 more on the other side!',
    ),

    // Question 2: 2D Shape Pattern
    GeometryGameQuestion(
      question: 'Which shape pattern has NO gaps between the shapes?',
      correctAnswer: 'Squares',
      options: ['Circles', 'Squares', 'Pentagons', 'Hexagons'],
      visual: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: GridView.count(
          crossAxisCount: 3,
          padding: const EdgeInsets.all(20),
          children: List.generate(9, (index) {
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.purple[200],
                border: Border.all(color: Colors.purple),
              ),
            );
          }),
        ),
      ),
      explanation: 'Squares fit together perfectly with no gaps between them.',
    ),

    // Question 3: 3D Shape Rolling
    GeometryGameQuestion(
      question:
          'Look at this round shape. Which 3D shape is it that can roll in ALL directions?',
      correctAnswer: 'Sphere',
      options: ['Cube', 'Cylinder', 'Sphere', 'Pyramid'],
      visual: Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          'assets/images/geometry/sphere.svg',
          fit: BoxFit.contain,
        ),
      ),
      explanation:
          'A sphere (like a ball) can roll in any direction because it is round all over. The arrows show it can roll in every direction!',
    ),

    // Question 4: Triangle Patterns
    GeometryGameQuestion(
      question: 'How many small triangles make up this large triangle?',
      correctAnswer: '4 triangles',
      options: ['2 triangles', '3 triangles', '4 triangles', '6 triangles'],
      visual: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: CustomPaint(
          painter: TrianglePatternPainter(),
          size: const Size(160, 160),
        ),
      ),
      explanation:
          'The large triangle is made up of 4 smaller triangles arranged in a pattern.',
    ),

    // Question 5: 3D Shape Base
    GeometryGameQuestion(
      question:
          'Look at the bottom of this pyramid.\nWhat shape is its base (the bottom part it stands on)?',
      correctAnswer: 'Square',
      options: ['Triangle', 'Square', 'Rectangle', 'Circle'],
      visual: Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          'assets/images/geometry/pyramid_base.svg',
          fit: BoxFit.contain,
        ),
      ),
      explanation:
          'This pyramid has a square base (bottom). The base is the flat part that the pyramid stands on, and it\'s clearly a square shape!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.isGameMode) {
      _startGame();
    }
  }

  void _initializeAnimations() {
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

  List<String> _getShuffledOptions(GeometryGameQuestion question) {
    final List<String> options = List.from(question.options);
    final random = math.Random();
    options.shuffle(random);
    return options;
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showResult = false;
      final random = math.Random();
      _shuffledQuestions = List.from(geometryGameQuestions)..shuffle(random);
      _currentOptions = _getShuffledOptions(_shuffledQuestions[0]);
      _animationController.reset();
      _animationController.forward();
    });
  }

  Future<void> _checkAnswer(String answer) async {
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _isCorrect =
          answer == _shuffledQuestions[_currentQuestionIndex].correctAnswer;
    });

    _answerAnimationController.forward().then((_) {
      _answerAnimationController.reverse();
    });

    if (_isCorrect) {
      _score++;
      await speakText('Correct! Well done!');
    } else {
      await speakText(
          'Try again! The correct answer is ${_shuffledQuestions[_currentQuestionIndex].correctAnswer}');
    }

    if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
      _nextQuestion();
    } else {
      SharedPreferenceService.saveGameProgress(
        'geometry_2',
        _score,
        _shuffledQuestions.length,
      );
      SharedPreferenceService.updateOverallProgress();
      showGameCompletionDialog(context, _score, _shuffledQuestions, setState,
          _startGame, 'Geometry_2');
    }
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
        speakText('Next question!');
      } else {
        SharedPreferenceService.saveGameProgress(
          'geometry_2',
          _score,
          _shuffledQuestions.length,
        );
        SharedPreferenceService.updateOverallProgress();
        showGameCompletionDialog(context, _score, _shuffledQuestions, setState,
            _startGame, 'Geometry_2');
      }
    });
  }

  static Widget _buildSymmetryVisual() {
    return Container(
      width: 200,
      height: 200,
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
        painter: SymmetryPainter(),
      ),
    );
  }

  static Widget _buildAnglesVisual() {
    return Container(
      width: 200,
      height: 200,
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
        painter: AnglesPainter(),
      ),
    );
  }

  static Widget _buildPerimeterVisual() {
    return Container(
      width: 200,
      height: 200,
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
        painter: PerimeterPainter(),
      ),
    );
  }

  static Widget _buildAreaVisual() {
    return Container(
      width: 200,
      height: 200,
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
        painter: AreaPainter(),
      ),
    );
  }

  static Widget _build3DShapesVisual() {
    return Container(
      width: 200,
      height: 200,
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
        painter: ThreeDShapesPainter(),
      ),
    );
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
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Geometry 2',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF6A1B9A),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFF6A1B9A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: concepts.length,
              itemBuilder: (context, index) {
                final concept = concepts[index];
                if (concept.section == selectedSection) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
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
                          const SizedBox(height: 8),
                          Text(
                            concept.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Center(child: concept.visual),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb,
                                    color: Colors.purple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Example: ${concept.example}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Geometry 2',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF6A1B9A),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
          Expanded(
            flex: 1,
            child: ScaleTransition(
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
                      Expanded(
                        child: Center(
                          child:
                              _shuffledQuestions[_currentQuestionIndex].visual,
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
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                                padding: const EdgeInsets.all(12.0),
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

  static Widget _build3DShapeVisual(String type) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'cube'
                  ? Icons.crop_square_sharp
                  : type == 'cuboid'
                      ? Icons.rectangle
                      : type == 'pyramid'
                          ? Icons.change_history
                          : type == 'sphere_cylinder'
                              ? Icons.circle
                              : Icons.architecture,
              size: 80,
              color: Colors.purple,
            ),
            const SizedBox(height: 10),
            Text(
              type.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _build2DShapeVisual(String type) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'rotation'
                  ? Icons.rotate_right
                  : type == 'pattern'
                      ? Icons.grid_on
                      : type == 'triangles'
                          ? Icons.change_history
                          : type == 'square'
                              ? Icons.crop_square
                              : Icons.face,
              size: 80,
              color: Colors.purple,
            ),
            const SizedBox(height: 10),
            Text(
              type.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SymmetryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    final path = Path()
      ..moveTo(center.dx, center.dy - 50)
      ..quadraticBezierTo(
          center.dx + 30, center.dy - 30, center.dx + 20, center.dy)
      ..quadraticBezierTo(
          center.dx + 40, center.dy + 20, center.dx, center.dy + 40)
      ..quadraticBezierTo(
          center.dx - 40, center.dy + 20, center.dx - 20, center.dy)
      ..quadraticBezierTo(
          center.dx - 30, center.dy - 30, center.dx, center.dy - 50);

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(center.dx, center.dy - 60),
      Offset(center.dx, center.dy + 60),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnglesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawLine(
      Offset(center.dx - 30, center.dy),
      center,
      paint,
    );
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - 30),
      paint,
    );

    canvas.drawArc(
      Rect.fromCenter(center: center, width: 40, height: 40),
      -90 * 3.14159 / 180,
      90 * 3.14159 / 180,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PerimeterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawRect(
      Rect.fromCenter(center: center, width: 80, height: 60),
      paint,
    );

    final arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx - 40, center.dy - 30),
      Offset(center.dx + 40, center.dy - 30),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 40, center.dy - 30),
      Offset(center.dx + 40, center.dy + 30),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 40, center.dy + 30),
      Offset(center.dx - 40, center.dy + 30),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 40, center.dy + 30),
      Offset(center.dx - 40, center.dy - 30),
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AreaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawRect(
      Rect.fromCenter(center: center, width: 80, height: 60),
      paint,
    );

    final gridPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i < 8; i++) {
      canvas.drawLine(
        Offset(center.dx - 40 + i * 10, center.dy - 30),
        Offset(center.dx - 40 + i * 10, center.dy + 30),
        gridPaint,
      );
    }
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(center.dx - 40, center.dy - 30 + i * 10),
        Offset(center.dx + 40, center.dy - 30 + i * 10),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ThreeDShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    final path = Path()
      ..moveTo(center.dx - 30, center.dy - 30)
      ..lineTo(center.dx + 30, center.dy - 30)
      ..lineTo(center.dx + 30, center.dy + 30)
      ..lineTo(center.dx - 30, center.dy + 30)
      ..close()
      ..moveTo(center.dx - 20, center.dy - 20)
      ..lineTo(center.dx + 40, center.dy - 20)
      ..lineTo(center.dx + 40, center.dy + 40)
      ..lineTo(center.dx - 20, center.dy + 40)
      ..close()
      ..moveTo(center.dx + 30, center.dy - 30)
      ..lineTo(center.dx + 40, center.dy - 20)
      ..moveTo(center.dx + 30, center.dy + 30)
      ..lineTo(center.dx + 40, center.dy + 40)
      ..moveTo(center.dx - 30, center.dy + 30)
      ..lineTo(center.dx - 20, center.dy + 40);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Triangle Pattern
class TrianglePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    // Large triangle
    path.moveTo(size.width / 2, 20);
    path.lineTo(20, size.height - 20);
    path.lineTo(size.width - 20, size.height - 20);
    path.close();

    // Internal lines
    path.moveTo(size.width / 2, 20);
    path.lineTo(size.width / 2, size.height - 20);
    path.moveTo((size.width / 2 + 20) / 2, (size.height + 20) / 2);
    path.lineTo((size.width / 2 + size.width - 20) / 2, (size.height + 20) / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Pyramid
class PyramidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    // Base (square)
    path.moveTo(40, size.height - 40);
    path.lineTo(size.width - 40, size.height - 40);
    path.lineTo(size.width - 40, size.height - 40);
    path.lineTo(40, size.height - 40);
    path.close();

    // Lines to apex
    path.moveTo(size.width / 2, 40);
    path.lineTo(40, size.height - 40);
    path.moveTo(size.width / 2, 40);
    path.lineTo(size.width - 40, size.height - 40);

    // Dotted lines for hidden edges
    final dashPaint = Paint()
      ..color = Colors.purple.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
