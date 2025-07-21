import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/game_progress_service.dart';
import '../services/shared_preference_service.dart';
import 'time_2_chapter_screen.dart';
import '../main.dart';
import 'home_screen.dart';

class TimeConcept {
  final String name;
  final String description;
  final Widget visual;
  final String example;
  final List<String> options;

  TimeConcept({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
    required this.options,
  });
}

class Time2Screen extends StatefulWidget {
  final bool isGameMode;

  const Time2Screen({
    super.key,
    required this.isGameMode,
  });

  @override
  State<Time2Screen> createState() => _Time2ScreenState();
}

class _Time2ScreenState extends State<Time2Screen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode; // Initialize as false to show lesson mode first
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<TimeConcept> shuffledConcepts = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  List<String> _currentOptions = [];

  static Widget _buildTimeDisplay(String time) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  final List<TimeConcept> concepts = [
    TimeConcept(
      name: 'O\'clock Times',
      description: 'Learning to read o\'clock times',
      visual: Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '12:00',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
      example:
          'When the hour hand points to a number and the minute hand points to 12, it\'s o\'clock',
      options: [
        '3 o\'clock',
        '6 o\'clock',
        '9 o\'clock',
        '12 o\'clock',
        'Half past 3'
      ],
    ),
    TimeConcept(
      name: 'Half Past Times',
      description: 'Learning to read half past times',
      visual: Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          '3:30',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
      example: 'When the minute hand points to 6, it\'s half past the hour',
      options: [
        'Half past 3',
        'Half past 6',
        'Half past 9',
        'Half past 12',
        '3 o\'clock'
      ],
    ),
    // Section 2: Days of the Week
    TimeConcept(
      name: 'Days Order',
      description: 'Learning the order of days in a week',
      visual: _buildDaysVisual(),
      example: 'The days of the week always come in the same order',
      options: [
        'Monday comes after Sunday',
        'Saturday comes after Friday',
        'Wednesday comes after Tuesday',
        'Sunday comes after Saturday',
        'Friday comes after Monday',
      ],
    ),
    TimeConcept(
      name: 'Yesterday and Tomorrow',
      description: 'Understanding the sequence of days',
      visual: _buildDaySequenceVisual(),
      example:
          'If today is Monday, tomorrow will be Tuesday, and yesterday was Sunday',
      options: [
        'If today is Wednesday, tomorrow is Thursday',
        'If today is Friday, yesterday was Thursday',
        'If today is Sunday, tomorrow is Saturday',
        'If today is Tuesday, yesterday was Monday',
        'If today is Saturday, tomorrow is Friday',
      ],
    ),
    // Section 3: Months of the Year
    TimeConcept(
      name: 'Months Order',
      description: 'Learning the order of months in a year',
      visual: _buildMonthsVisual(),
      example: 'The months of the year always come in the same order',
      options: [
        'January is the first month',
        'December is the last month',
        'July is in the middle of the year',
        'April comes after March',
        'October comes before September',
      ],
    ),
    TimeConcept(
      name: 'Next and Last Month',
      description: 'Understanding the sequence of months',
      visual: _buildMonthSequenceVisual(),
      example: 'After December comes January, as months repeat in a cycle',
      options: [
        'After March comes April',
        'Before August comes July',
        'After December comes November',
        'Before January comes February',
        'After June comes May',
      ],
    ),
    // Section 4: Practical Applications
    TimeConcept(
      name: 'Daily Schedule',
      description: 'Using time for daily activities',
      visual: _buildScheduleVisual(),
      example: 'Different activities happen at specific times of the day',
      options: [
        'School starts at 8 o\'clock',
        'Lunch time is at 12 o\'clock',
        'Bedtime is at 6 o\'clock',
        'Breakfast is at 10 o\'clock',
        'Dinner is at 4 o\'clock',
      ],
    ),
    TimeConcept(
      name: 'Calendar Reading',
      description: 'Understanding dates and appointments',
      visual: _buildCalendarVisual(),
      example: 'We use calendars to keep track of important dates',
      options: [
        'Doctor appointment on Tuesday at 3 o\'clock',
        'School holiday on Monday',
        'Birthday party on Saturday at 2 o\'clock',
        'Dentist on Sunday',
        'Library closes at 1 o\'clock',
      ],
    ),
  ];

  // Separate game questions list with 5 logical and easier questions
  final List<Map<String, dynamic>> gameQuestions = [
    {
      'question':
          'What time is it when the hour hand points to 3 and the minute hand points to 12?',
      'image': _buildTimeDisplay('3:00'),
      'options': ['3 o\'clock', '12 o\'clock', '6 o\'clock', '9 o\'clock'],
      'correctAnswer': '3 o\'clock',
      'explanation': 'When the minute hand points to 12, it\'s o\'clock time!',
    },
    {
      'question': 'If today is Monday, what day will tomorrow be?',
      'image': _buildDaySequenceVisual(),
      'options': ['Tuesday', 'Sunday', 'Wednesday', 'Friday'],
      'correctAnswer': 'Tuesday',
      'explanation':
          'The days go: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday',
    },
    {
      'question': 'Which month comes after March?',
      'image': _buildMonthsVisual(),
      'options': ['April', 'February', 'May', 'June'],
      'correctAnswer': 'April',
      'explanation':
          'The months go: January, February, March, April, May, June...',
    },
    {
      'question': 'What time do we usually eat breakfast?',
      'image': _buildScheduleVisual(),
      'options': ['8 o\'clock', '12 o\'clock', '6 o\'clock', '10 o\'clock'],
      'correctAnswer': '8 o\'clock',
      'explanation':
          'Breakfast is our first meal of the day, usually in the morning!',
    },
    {
      'question': 'How many days are there in a week?',
      'image': _buildDaysVisual(),
      'options': ['7 days', '5 days', '6 days', '8 days'],
      'correctAnswer': '7 days',
      'explanation':
          'There are 7 days in a week: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday',
    },
  ];

  static Widget _buildDaysVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('Days of the Week',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700])),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              'Sunday',
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
            ]
                .map((day) => Chip(
                      label: Text(day),
                      backgroundColor: Colors.purple[100],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  static Widget _buildDaySequenceVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text('Yesterday',
                  style: TextStyle(fontSize: 16, color: Colors.purple[700])),
              const Icon(Icons.arrow_back, color: Colors.purple),
            ],
          ),
          Column(
            children: [
              Text('Today',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[900])),
              const Icon(Icons.circle, color: Colors.purple),
            ],
          ),
          Column(
            children: [
              Text('Tomorrow',
                  style: TextStyle(fontSize: 16, color: Colors.purple[700])),
              const Icon(Icons.arrow_forward, color: Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildMonthsVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('Months of the Year',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700])),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December'
            ]
                .map((month) => Chip(
                      label: Text(month),
                      backgroundColor: Colors.purple[100],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  static Widget _buildMonthSequenceVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Last Month',
                      style: TextStyle(fontSize: 14, color: Colors.purple[700]),
                      textAlign: TextAlign.center,
                    ),
                    const Icon(Icons.arrow_back, color: Colors.purple),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'This Month',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900]),
                      textAlign: TextAlign.center,
                    ),
                    const Icon(Icons.calendar_today, color: Colors.purple),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Next Month',
                      style: TextStyle(fontSize: 14, color: Colors.purple[700]),
                      textAlign: TextAlign.center,
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildScheduleVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                Text('Morning', style: TextStyle(fontSize: 14)),
                Icon(Icons.wb_sunny)
              ]),
              Column(children: [
                Text('Afternoon', style: TextStyle(fontSize: 14)),
                Icon(Icons.wb_cloudy)
              ]),
              Column(children: [
                Text('Evening', style: TextStyle(fontSize: 14)),
                Icon(Icons.nights_stay)
              ]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('8:00',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward),
              Text('12:00',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward),
              Text('6:00',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildCalendarVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                Icon(Icons.medical_services, color: Colors.red),
                Text('Doctor', style: TextStyle(fontSize: 12))
              ]),
              Column(children: [
                Icon(Icons.school, color: Colors.blue),
                Text('School', style: TextStyle(fontSize: 12))
              ]),
              Column(children: [
                Icon(Icons.cake, color: Colors.green),
                Text('Party', style: TextStyle(fontSize: 12))
              ]),
            ],
          ),
          const SizedBox(height: 8),
          Text('Important Dates',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;

    _initializeAnimations();
    if (isGameMode) {
      _startGame();
    }
  }

  void _startGame() {
    setState(() {
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      _currentOptions = _getShuffledGameOptions();
      _animationController.reset();
      _animationController.forward();
    });
  }

  List<String> _getShuffledGameOptions() {
    // Create a list of options from the current game question
    final List<String> options =
        List.from(gameQuestions[currentQuestion]['options'] as List<String>);

    // Shuffle the options to randomize their order
    options.shuffle();

    return options;
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

    // Scale animation for answer selection
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

  Future<void> _checkAnswer(String answer) async {
    if (showResult) return;

    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == gameQuestions[currentQuestion]['correctAnswer'];
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
      await speakText(
          'Try again! The correct answer is ${gameQuestions[currentQuestion]['correctAnswer']}');
    }

    // Shorter delay for better responsiveness
    Future.delayed(const Duration(seconds: 0), () {
      if (mounted) {
        if (currentQuestion < gameQuestions.length - 1) {
          setState(() {
            currentQuestion++;
            _currentOptions = _getShuffledGameOptions();
            selectedAnswer = null;
            showResult = false;
            isCorrect = false;
          });
        } else {
          // Game completed, update progress and show dialog
          if (mounted) {
            SharedPreferenceService.saveGameProgress(
              'time_2',
              score,
              gameQuestions.length,
            ).then((_) {
              developer.log(
                  'Game progress saved for time_2: Score $score out of ${gameQuestions.length}');
              setState(() {
                SharedPreferenceService.updateOverallProgress();
              });
              showGameCompletionDialog(
                context,
                score,
                gameQuestions,
                setState,
                _startGame,
                'time_2',
              );
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isGameMode) {
      return _buildGameModeScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learn Time',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF7B2FF2),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
              onTap: () => speakText('${concept.name}. ${concept.description}'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concept.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B2FF2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(child: concept.visual),
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
          'Time Game',
          style: TextStyle(
            color: Color(0xFF7B2FF2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF7B2FF2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B2FF2), Color(0xFFf357a8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
        child: _buildGameMode(),
      ),
    );
  }

  Widget _buildGameMode() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Question ${currentQuestion + 1} of ${gameQuestions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B2FF2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B2FF2),
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
                              child: gameQuestions[currentQuestion]['image'],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          gameQuestions[currentQuestion]['question'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B2FF2),
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
                  final isSelected = selectedAnswer == option;
                  final isCorrectOption = showResult && option == gameQuestions[currentQuestion]['correctAnswer'];
                  final isIncorrect = showResult && isSelected && !isCorrect;
                  Color backgroundColor;
                  if (isCorrectOption) {
                    backgroundColor = Colors.green.shade100;
                  } else if (isIncorrect) {
                    backgroundColor = Colors.red.shade100;
                  } else if (isSelected) {
                    backgroundColor = const Color(0xFF7B2FF2).withOpacity(0.2);
                  } else {
                    backgroundColor = Colors.white;
                  }
                  Color borderColor;
                  if (isCorrectOption) {
                    borderColor = Colors.green;
                  } else if (isIncorrect) {
                    borderColor = Colors.red;
                  } else if (isSelected) {
                    borderColor = const Color(0xFF7B2FF2);
                  } else {
                    borderColor = Colors.grey.shade300;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: isSelected || isCorrectOption ? FontWeight.bold : FontWeight.normal,
                                          color: isCorrectOption
                                              ? Colors.green
                                              : isIncorrect
                                                  ? Colors.red
                                                  : isSelected
                                                      ? const Color(0xFF7B2FF2)
                                                      : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (isCorrectOption)
                                      const Icon(Icons.check_circle, color: Colors.green, size: 24)
                                    else if (isIncorrect)
                                      const Icon(Icons.cancel, color: Colors.red, size: 24),
                                  ],
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
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
}
