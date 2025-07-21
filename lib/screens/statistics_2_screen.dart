import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import 'dart:math';
import '../widgets/confetti_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/shared_preference_service.dart';

class Statistics2Screen extends StatefulWidget {
  final bool isGameMode;
  const Statistics2Screen({super.key, required this.isGameMode});

  @override
  State<Statistics2Screen> createState() => _Statistics2ScreenState();
}

class _Statistics2ScreenState extends State<Statistics2Screen>
    with TickerProviderStateMixin {
  late bool isGameMode;
  int currentQuestionIndex = 0;
  bool showConfetti = false;
  bool isCompleted = false;
  bool showCorrectAnimation = false;
  bool showWrongAnimation = false;
  int score = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;

  // Animation controllers
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _resultAnimationController;
  late Animation<double> _resultAnimation;
  late AnimationController _correctAnimationController;
  late Animation<double> _correctAnimation;
  late AnimationController _incorrectAnimationController;
  late Animation<double> _incorrectAnimation;

  // Section 1: Venn diagrams, Carroll diagrams, and pictograms
  final List<Map<String, dynamic>> section1Lessons = [
    {
      'title': 'Venn Diagrams',
      'content': '''A Venn diagram uses circles to sort and show data.
      
Things that belong to a group go inside the circle.
Things that don't belong go outside the circle.

For example:
- A circle for "red things" would have red apples inside
- Green apples would stay outside
''',
      'example': 'assets/images/statistics/venn_diagram_example.svg',
    },
    {
      'title': 'Carroll Diagrams',
      'content': '''A Carroll diagram organizes data using a set of rules.

It uses boxes to sort items into groups.
Each box shows if items have or don't have certain features.

For example:
- Sorting shapes by "has curved sides" and "has straight sides"
- Sorting numbers into "odd" and "not odd"
''',
      'example': 'assets/images/statistics/carroll_diagram_example.svg',
    },
    {
      'title': 'Pictograms',
      'content': '''A pictogram uses pictures to show data.

Important rules:
- Uses columns or rows of pictures
- Must have a title
- Each picture represents one item
- Pictures must be the same size

For example:
- Using 🌞 to show hours of sunshine
- Using 🎈 to show number of balloons
''',
      'example': 'assets/images/statistics/pictogram_example.svg',
    },
  ];

  // Section 2: Lists, tables, and block graphs
  final List<Map<String, dynamic>> section2Lessons = [
    {
      'title': 'Lists',
      'content': '''A list helps organize information in a simple way.

Important features:
- Has a heading to show what the list is about
- Items are written one below another
- Used to collect and show data simply

For example:
Shopping List:
- milk
- bread
- eggs
''',
      'example': 'assets/images/statistics/list_example.svg',
    },
    {
      'title': 'Tables',
      'content': '''A table shows data using rows and columns.

Important features:
- Rows go across ➡️
- Columns go down ⬇️
- Makes it easy to compare information

For example:
Ice Cream Sales:
Monday: 5 chocolate, 3 vanilla
Tuesday: 4 chocolate, 6 vanilla
''',
      'example': 'assets/images/statistics/table_example.svg',
    },
    {
      'title': 'Block Graphs',
      'content': '''A block graph uses blocks to show and compare data.

Important features:
- One block = one item
- Must have a title
- Shows most, least, more, fewer
- Easy to compare amounts

For example:
Favorite Colors:
Red ■■■
Blue ■■■■
Green ■■
''',
      'example': 'assets/images/statistics/block_graph_example.svg',
    },
  ];

  // Game mode questions based on the lessons
  final List<Map<String, dynamic>> gameQuestions = [
    {
      'question': 'Which type of diagram is shown below?',
      'image': 'assets/images/statistics/venn_diagram_example.svg',
      'options': [
        'Venn diagram',
        'Carroll diagram',
        'Block graph',
        'Pictogram'
      ],
      'correctAnswer': 'Venn diagram',
      'explanation':
          'This is a Venn diagram. It uses circles to sort and show data. Things that belong to a group go inside the circle.',
    },
    {
      'question':
          'In this Carroll diagram, where would you put a triangle with straight sides?',
      'image': 'assets/images/statistics/carroll_diagram_example.svg',
      'options': ['Left side', 'Right side', 'Outside', 'Both sides'],
      'correctAnswer': 'Right side',
      'explanation':
          'A triangle has straight sides, so it belongs in the right side of the Carroll diagram which shows shapes with straight sides.',
    },
    {
      'question':
          'Looking at this block graph, which color is the most popular?',
      'image': 'assets/images/statistics/block_graph_example.svg',
      'options': ['Red', 'Blue', 'Green', 'Yellow'],
      'correctAnswer': 'Blue',
      'explanation':
          'Blue has 4 blocks, which is more than Red (3 blocks) and Green (2 blocks).',
    },
    {
      'question':
          'In this table, how many vanilla ice creams were sold on Tuesday?',
      'image': 'assets/images/statistics/table_example.svg',
      'options': ['3', '4', '6', '5'],
      'correctAnswer': '6',
      'explanation':
          'Looking at the table, on Tuesday there were 6 vanilla ice creams sold.',
    },
    {
      'question': 'In this pictogram, which pet has the most symbols?',
      'image': 'assets/images/statistics/pictogram_example.svg',
      'options': ['Dogs', 'Cats', 'Fish', 'Birds'],
      'correctAnswer': 'Dogs',
      'explanation':
          'Dogs has 4 symbols, which is more than Cats (3 symbols) and Fish (2 symbols).',
    },
  ];

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    if (isGameMode) {
      gameQuestions.shuffle();
      score = 0;
    }
    // Debug print for lesson examples
    section1Lessons.forEach((lesson) {
      print('Loading example: ${lesson['example']}');
    });
    section2Lessons.forEach((lesson) {
      print('Loading example: ${lesson['example']}');
    });

    // Initialize animation controllers
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resultAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _correctAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _incorrectAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _resultAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _correctAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _correctAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _incorrectAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _incorrectAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startGame() {
    setState(() {
      score = 0;
      currentQuestionIndex = 0;
      selectedAnswer = null;
      showResult = false;
      gameQuestions.shuffle();
    });
  }

  void _checkAnswer(String answer) async {
    if (showResult) return; // Prevent multiple answers while showing result

    final correctAnswer = gameQuestions[currentQuestionIndex]['correctAnswer'];
    final isAnswerCorrect = answer == correctAnswer;

    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = isAnswerCorrect;
      if (isCorrect) {
        score++;
      }
    });

    // Trigger scale animation for button press
    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });

    if (isCorrect) {
      await speakText('Correct!');
      _correctAnimationController.forward().then((_) {
        _correctAnimationController.reverse();
      });
    } else {
      await speakText('Try again! The correct answer is $correctAnswer');
      _incorrectAnimationController.forward().then((_) {
        _incorrectAnimationController.reverse();
      });
    }

    // Shorter delay for better responsiveness
    Future.delayed(const Duration(seconds: 0), () {
      if (mounted) {
        if (currentQuestionIndex < gameQuestions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = null;
            showResult = false;
            isCorrect = false;
          });
        } else {
          // Game completed, update progress and show dialog
          if (mounted) {
            SharedPreferenceService.saveGameProgress(
              'statistics_2',
              score,
              gameQuestions.length,
            ).then((_) {
              developer.log(
                  'Game progress saved for statistics_2: Score $score out of ${gameQuestions.length}');
              setState(() {
                SharedPreferenceService.updateOverallProgress();
              });
              showGameCompletionDialog(
                context,
                score,
                gameQuestions,
                setState,
                _startGame,
                'statistics_2',
              );
            });
          }
        }
      }
    });
  }

  Widget _buildLessonMode() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Section 1: Venn diagrams, Carroll diagrams, and pictograms',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 16),
        ...section1Lessons.map((lesson) => _buildLessonCard(lesson)).toList(),
        const SizedBox(height: 32),
        const Text(
          'Section 2: Lists, tables, and block graphs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 16),
        ...section2Lessons.map((lesson) => _buildLessonCard(lesson)).toList(),
      ],
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    print(
        'Building lesson card for: ${lesson['title']} with example: ${lesson['example']}');
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson['title'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lesson['content'],
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            if (lesson['example'] != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Builder(
                        builder: (context) {
                          try {
                            print(
                                'Attempting to load SVG: ${lesson['example']}');
                            return SvgPicture.asset(
                              lesson['example'],
                              height: 200,
                              width: 200,
                              fit: BoxFit.contain,
                              placeholderBuilder: (BuildContext context) =>
                                  Container(
                                height: 200,
                                width: 200,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          } catch (e, stackTrace) {
                            print('Error loading SVG: ${lesson['example']}');
                            print('Error details: $e');
                            print('Stack trace: $stackTrace');
                            return Container(
                              height: 200,
                              width: 200,
                              color: Colors.red[100],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error loading image',
                                    style: TextStyle(color: Colors.red[900]),
                                  ),
                                  if (e
                                      .toString()
                                      .contains('Unable to load asset')) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Asset not found',
                                      style: TextStyle(
                                          color: Colors.red[900], fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Example ${lesson['title']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    return Stack(
      children: [
        // ConfettiWidget removed as part of unused code cleanup
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Progress and Score Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF7B2FF2).withOpacity(0.7),
                        const Color(0xFF7B2FF2).withOpacity(0.9),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      
                          const Text(
                            'Question:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${currentQuestionIndex + 1} of ${gameQuestions.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Score: $score',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              // Progress Bar
              // LinearProgressIndicator(
              //   value: (currentQuestionIndex + 1) / gameQuestions.length,
              //   backgroundColor: Colors.grey[200],
              //   valueColor:
              //       const AlwaysStoppedAnimation<Color>(Color(0xFF7B2FF2)),
              //   minHeight: 8,
              // ),
              const SizedBox(height: 24),
              Text(
                gameQuestions[currentQuestionIndex]['question'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (gameQuestions[currentQuestionIndex]['image'] != null) ...[
                Container(
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
                  padding: const EdgeInsets.all(16),
                  child: SvgPicture.asset(
                    gameQuestions[currentQuestionIndex]['image'],
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: (gameQuestions[currentQuestionIndex]['options']
                          as List<String>)
                      .length,
                  itemBuilder: (context, index) {
                    final option =
                        gameQuestions[currentQuestionIndex]['options'][index];
                    final isSelected = option == selectedAnswer;
                    final isCorrect = option ==
                        gameQuestions[currentQuestionIndex]['correctAnswer'];
                    final showCorrectAnswer = showResult && isCorrect;
                    final showIncorrectSelection =
                        showResult && isSelected && !isCorrect;

                    Color backgroundColor;
                    if (showCorrectAnswer) {
                      backgroundColor = Colors.green.shade100;
                    } else if (showIncorrectSelection) {
                      backgroundColor = Colors.red.shade100;
                    } else if (isSelected) {
                      backgroundColor =
                          const Color(0xFF7B2FF2).withOpacity(0.2);
                    } else {
                      backgroundColor = Colors.white;
                    }

                    Color borderColor;
                    if (showCorrectAnswer) {
                      borderColor = Colors.green;
                    } else if (showIncorrectSelection) {
                      borderColor = Colors.red;
                    } else if (isSelected) {
                      borderColor = const Color(0xFF7B2FF2);
                    } else {
                      borderColor = Colors.grey.shade300;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8,left: 16,right: 16),
                      child: AnimatedBuilder(
                        animation: _scaleAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isSelected ? _scaleAnimation.value : 1.0,
                            child: Material(
                              borderRadius: BorderRadius.circular(12),
                              elevation: isSelected ? 4 : 1,
                              child: InkWell(
                                onTap: showResult
                                    ? null
                                    : () => _checkAnswer(option),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                isSelected || showCorrectAnswer
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            color: showCorrectAnswer
                                                ? Colors.green
                                                : showIncorrectSelection
                                                    ? Colors.red
                                                    : isSelected
                                                        ? const Color(
                                                            0xFF7B2FF2)
                                                        : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (showCorrectAnswer)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 24,
                                        ),
                                      if (showIncorrectSelection)
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3EFFF), Color(0xFFE3F0FF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(isGameMode ? 'Statistics 2 Game' : 'Statistics 2 Lesson'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B2FF2), Color(0xFFf357a8)],
              ),
            ),
          ),
        ),
        body: isGameMode ? _buildGameMode() : _buildLessonMode(),
      ),
    );
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _resultAnimationController.dispose();
    _correctAnimationController.dispose();
    _incorrectAnimationController.dispose();
    super.dispose();
  }
}
