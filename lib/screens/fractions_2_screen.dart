import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import '../services/shared_preference_service.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// --- LESSON DATA ---
class Fractions2Lesson {
  final String title;
  final String description;
  final Widget visual;
  Fractions2Lesson(
      {required this.title, required this.description, required this.visual});
}

// --- GAME DATA ---
class Fractions2GameQuestion {
  final String question;
  final Widget visual;
  final List<String> options;
  final String answer;
  Fractions2GameQuestion(
      {required this.question,
      required this.visual,
      required this.options,
      required this.answer});
}

class Fractions2Screen extends StatefulWidget {
  final bool isGameMode;
  const Fractions2Screen({super.key, required this.isGameMode});
  @override
  State<Fractions2Screen> createState() => _Fractions2ScreenState();
}

class _Fractions2ScreenState extends State<Fractions2Screen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  late List<Fractions2GameQuestion> shuffledQuestions;

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeTts();
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

  void _startGame() {
    setState(() {
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledQuestions = List.from(fractions2GameQuestions)..shuffle();
      for (var q in shuffledQuestions) {
        q.options.shuffle();
      }
      _scaleAnimationController.reset();
    });
  }

  void _checkAnswer(String answer) {
    if (showResult) return; // Prevent multiple answers while showing result

    setState(() {
      selectedAnswer = answer;
      showResult = true;    
      isCorrect = answer == shuffledQuestions[currentQuestion].answer;
      if (isCorrect) {
        score++;
      }
    });

    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });

    if (isCorrect) {
      _speakText('Correct!');
    } else {
      _speakText('Try again!');
    }

    // Shorter delay for better responsiveness
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (currentQuestion < shuffledQuestions.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            showResult = false;
            isCorrect = false;
          });
        } else {
          // Game completed, update progress and show dialog
          if (mounted) {
            SharedPreferenceService.saveGameProgress(
              'fractions_2',
              score,
              shuffledQuestions.length,
            ).then((_) {
              developer.log('Game progress saved for fractions_2: Score $score out of ${shuffledQuestions.length}');
              setState(() {
                SharedPreferenceService.updateOverallProgress();
              });
              // _showCompletionDialog();
              showGameCompletionDialog(context, score, shuffledQuestions, setState, _startGame, 'Fractions 2');
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF7B2FF2),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF7B2FF2),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    if (isGameMode) {
      return _buildGameModeScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fractions 2 Lessons',
          style: TextStyle(
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fractions2Lessons.length,
        itemBuilder: (context, index) {
          final lesson = fractions2Lessons[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _speakText('${lesson.title}. ${lesson.description}'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B2FF2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lesson.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(child: lesson.visual),
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
          'Fractions 2 Practice',
          style: TextStyle(
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
          child: _buildGameMode(),
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildGameContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildGameContent() {
    final q = shuffledQuestions[currentQuestion];
    return Column(
      children: [
        // Score and Progress Display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7B2FF2).withOpacity(0.1),
                Color(0xFFF3EFFF).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7B2FF2).withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${currentQuestion + 1} of ${shuffledQuestions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B2FF2),
                    ),
                  ),
                ],
              ),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF7B2FF2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Color(0xFF7B2FF2),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Score: $score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B2FF2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        q.visual,
        const SizedBox(height: 16),
        Text(
          q.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...q.options.map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ElevatedButton(
                onPressed: showResult ? null : () => _checkAnswer(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: option == selectedAnswer
                      ? (isCorrect ? Colors.green : Colors.red)
                      : Color(0xFF7B2FF2).withOpacity(0.1),
                  foregroundColor: Color(0xFF7B2FF2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )),
        const SizedBox(height: 24),
        if (showResult)
          Text(
            isCorrect ? 'Correct!' : 'Try again!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
      ],
    );
  }

  // --- LESSON CONTENT ---
  List<Fractions2Lesson> get fractions2Lessons => [
        Fractions2Lesson(
          title: 'What is a Half?',
          description:
              'A fraction is a part of a whole. When something is divided into two equal parts, each part is called a half (½).',
          visual: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Color(0xFF7B2FF2), width: 2),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 2,
                          height: 100,
                          color: Color(0xFF7B2FF2),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '½',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFF7B2FF2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Fractions2Lesson(
          title: 'Sharing Food',
          description:
              'We use halves when sharing food like sweets, pizza, or cookies. Each person gets the same amount when we share between two.',
          visual: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 2,
                          height: 120,
                          color: Colors.orange,
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 30,
                        child: Text(
                          '½',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        right: 30,
                        child: Text(
                          '½',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Fractions2Lesson(
          title: 'Halving Liquids',
          description:
              'When we pour a full jug of juice into two equal glasses, each glass has half of the juice. When we pour them back, they make a whole jug again.',
          visual: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue[400],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Icon(Icons.arrow_forward, color: Color(0xFF7B2FF2), size: 24),
                SizedBox(width: 20),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue[400],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue[400],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Fractions2Lesson(
          title: 'Half Past Time',
          description:
              'We use halves when telling time. When the minute hand points to 6, it means 30 minutes have passed - we call this "half past".',
          visual: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF7B2FF2), width: 2),
              ),
              child: CustomPaint(
                painter: ClockPainter(
                  hourAngle: 2 * 30 * 3.14159 / 180 - 3.14159 / 2, // 2 o'clock
                  minuteAngle:
                      6 * 30 * 3.14159 / 180 - 3.14159 / 2, // 30 minutes
                  color: Color(0xFF7B2FF2),
                ),
              ),
            ),
          ),
        ),
        Fractions2Lesson(
          title: 'Half of Numbers',
          description:
              'We can find half of a number by dividing it into two equal groups. For example, half of 10 is 5 because 5 + 5 = 10.',
          visual: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                        5,
                        (index) => Padding(
                              padding: EdgeInsets.all(4),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Color(0xFF7B2FF2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )),
                    SizedBox(width: 20),
                    ...List.generate(
                        5,
                        (index) => Padding(
                              padding: EdgeInsets.all(4),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Color(0xFF7B2FF2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '5 + 5 = 10',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF7B2FF2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];

  // --- GAME CONTENT ---
  List<Fractions2GameQuestion> get fractions2GameQuestions => [
        Fractions2GameQuestion(
          question: 'Look at the pizza. Which side shows half of it?',
          visual: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 2,
                          height: 120,
                          color: Colors.orange,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 59,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.orange[300],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60),
                              bottomLeft: Radius.circular(60),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          options: ['Left side', 'Right side', 'Both sides', 'Neither side'],
          answer: 'Left side',
        ),
        Fractions2GameQuestion(
          question:
              'A jug of juice is poured into two glasses. How much juice is in each glass?',
          visual: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRect(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[400],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(Icons.arrow_forward, color: Color(0xFF7B2FF2), size: 24),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRect(
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRect(
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(),
                              ),
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
          options: ['One quarter', 'One half', 'Three quarters', 'All of it'],
          answer: 'One half',
        ),
        Fractions2GameQuestion(
          question: 'What time does this clock show?',
          visual: Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF7B2FF2), width: 2),
              ),
              child: CustomPaint(
                painter: ClockPainter(
                  hourAngle: 2 * 30 * 3.14159 / 180 - 3.14159 / 2, // 2 o'clock
                  minuteAngle:
                      6 * 30 * 3.14159 / 180 - 3.14159 / 2, // 30 minutes
                  color: Color(0xFF7B2FF2),
                  isLarge: true,
                ),
              ),
            ),
          ),
          options: ['Half past 1', 'Half past 2', 'Half past 3', 'Half past 4'],
          answer: 'Half past 2',
        ),
        Fractions2GameQuestion(
          question:
              'Half of these cookies are chocolate. How many chocolate cookies are there?',
          visual: Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ...List.generate(
                    4,
                    (index) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.brown[300],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.brown, width: 2),
                          ),
                        )),
                ...List.generate(
                    4,
                    (index) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange, width: 2),
                          ),
                        )),
              ],
            ),
          ),
          options: ['2 cookies', '4 cookies', '6 cookies', '8 cookies'],
          answer: '4 cookies',
        ),
        Fractions2GameQuestion(
          question: 'What is half of 18 apples?',
          visual: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                      18,
                      (index) => Icon(
                            Icons.apple,
                            color: Color(0xFF7B2FF2),
                            size: 24,
                          )),
                ),
                SizedBox(height: 16),
                Text(
                  '÷ 2 = ?',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF7B2FF2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          options: ['7 apples', '8 apples', '9 apples', '10 apples'],
          answer: '9 apples',
        ),
      ];
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
      final angle = i * 30 * 3.14159 / 180;
      final markerRadius = isLarge ? radius * 0.85 : radius * 0.8;
      final x = center.dx + markerRadius * sin(angle);
      final y = center.dy - markerRadius * cos(angle);
      canvas.drawCircle(Offset(x, y), isLarge ? 2 : 1.5, markerPaint);
    }

    // Draw hour hand
    final hourHandPaint = Paint()
      ..color = color
      ..strokeWidth = isLarge ? 4 : 3
      ..strokeCap = StrokeCap.round;

    final hourHandLength = isLarge ? radius * 0.5 : radius * 0.45;
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
      ..strokeWidth = isLarge ? 2 : 1.5
      ..strokeCap = StrokeCap.round;

    final minuteHandLength = isLarge ? radius * 0.7 : radius * 0.65;
    canvas.drawLine(
      center,
      Offset(
        center.dx + minuteHandLength * cos(minuteAngle),
        center.dy + minuteHandLength * sin(minuteAngle),
      ),
      minuteHandPaint,
    );

    // Draw center dot
    canvas.drawCircle(center, isLarge ? 4 : 3, markerPaint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) =>
      oldDelegate.hourAngle != hourAngle ||
      oldDelegate.minuteAngle != minuteAngle ||
      oldDelegate.color != color;
}
