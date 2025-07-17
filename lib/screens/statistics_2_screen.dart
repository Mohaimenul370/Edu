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

class _Statistics2ScreenState extends State<Statistics2Screen> {
  late bool isGameMode;
  int currentQuestionIndex = 0;
  bool showConfetti = false;
  bool isCompleted = false;
  bool showCorrectAnimation = false;
  bool showWrongAnimation = false;
  int score = 0;
  String? selectedAnswer;

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
  }

  void _showCompletionDialog() {
    // Calculate percentage score
    final percentage = (score / gameQuestions.length) * 100;
    final isPassed = percentage >= 50.0;

    // Save the game progress (SharedPreferenceService handles the 50% threshold automatically)
    SharedPreferenceService.saveGameProgress(
            'statistics_2', score, gameQuestions.length)
        .then((_) {
      _showDialog(percentage, isPassed);
    }).catchError((error) {
      print('Error saving game progress: $error');
      _showDialog(percentage, isPassed);
    });
  }

  void _showDialog(double percentage, bool isPassed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
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
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFF7B2FF2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Score',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7B2FF2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$score / ${gameQuestions.length}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B2FF2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  percentage >= 80
                      ? 'Great job! You\'ve mastered statistics!'
                      : percentage >= 60
                          ? 'Good work! Keep practicing!'
                          : 'Nice try! Practice makes perfect!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7B2FF2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 18),
                            SizedBox(width: 8),
                            Text('Back'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            currentQuestionIndex = 0;
                            isCompleted = false;
                            showConfetti = false;
                            showCorrectAnimation = false;
                            showWrongAnimation = false;
                            score = 0;
                            selectedAnswer = null;
                            gameQuestions.shuffle();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 18),
                            SizedBox(width: 8),
                            Text('Play Again'),
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
      ),
    );
  }

  void _checkAnswer(String answer) {
    bool isCorrect =
        answer == gameQuestions[currentQuestionIndex]['correctAnswer'];

    setState(() {
      selectedAnswer = answer;
      if (isCorrect) {
        showConfetti = true;
        showCorrectAnimation = true;
        showWrongAnimation = false;
        score++;
      } else {
        showWrongAnimation = true;
        showCorrectAnimation = false;
        showConfetti = false;
      }

      // Advance to next question after delay for both correct and wrong answers
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showCorrectAnimation = false;
            showWrongAnimation = false;
            showConfetti = false;
            selectedAnswer = null;

            if (currentQuestionIndex < gameQuestions.length - 1) {
              currentQuestionIndex++;
            } else {
              isCompleted = true;
              SharedPreferenceService.saveGameProgress(
                'statistics_2',
                score,
                gameQuestions.length,
              );
              developer.log(
                  'Game progress saved for statistics_2: Score $score out of ${gameQuestions.length}');
              setState(() {
                SharedPreferenceService.updateOverallProgress();
              });
              _showCompletionDialog();
            }
          });
        }
      });
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${gameQuestions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Score: $score',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                gameQuestions[currentQuestionIndex]['question'],
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (gameQuestions[currentQuestionIndex]['image'] != null) ...[
                SvgPicture.asset(
                  gameQuestions[currentQuestionIndex]['image'],
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
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

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.identity()
                          ..scale(
                              showWrongAnimation && isSelected ? 0.95 : 1.0),
                        child: ElevatedButton(
                          onPressed:
                              (showCorrectAnimation || showWrongAnimation)
                                  ? null
                                  : () => _checkAnswer(option),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: isSelected
                                ? (isCorrect
                                    ? Colors.green[50]
                                    : Colors.red[50])
                                : Colors.white,
                            foregroundColor: isSelected
                                ? (isCorrect
                                    ? Colors.green[700]
                                    : Colors.red[700])
                                : Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : Colors.purple,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
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
}
