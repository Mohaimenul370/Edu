import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kg_education_app/utils/utils_func.dart';
import 'dart:math';
import '../main.dart';
import '../services/shared_preference_service.dart';
import 'home_screen.dart';
import 'package:flutter/foundation.dart';

// Game types enum
enum GameType {
  multipleChoice,
  ordering,
  matching,
}

// Game concept class
class GameConcept {
  final String question;
  final Widget image;
  final List<String> options;
  final String correctAnswer;
  final GameType type;

  GameConcept({
    required this.question,
    required this.image,
    required this.options,
    required this.correctAnswer,
    required this.type,
  });
}

class TimeConcept {
  final String name;
  final Widget visual;
  final String description;
  final List<String> options;
  final String? exercise;

  TimeConcept({
    required this.name,
    required this.visual,
    required this.description,
    required this.options,
    this.exercise,
  });
}

class TimeScreen extends StatefulWidget {
  final bool isGameMode;

  const TimeScreen({
    super.key,
    required this.isGameMode,
  });

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  List<TimeConcept> shuffledConcepts = [];
  late final List<TimeConcept> concepts;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerScaleAnimation;
  late Animation<Color?> _answerColorAnimation;
  List<String> _currentOptions = [];
  List<String> _shuffledOptions = [];
  String selectedSection = 'Days and Time';
  List<Map<String, dynamic>> gameQuestions = [];
  bool _showingFeedback = false;
  bool _isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeAnimations();
    _initializeConcepts();
    _initializeGameQuestions();
    _startGame();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _answerScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _answerAnimationController,
      curve: Curves.easeInOut,
    ));

    _answerColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.green[100],
    ).animate(_answerAnimationController);
  }

  void _initializeConcepts() {
    concepts = [
      // Days and Time Section
      TimeConcept(
        name: 'Days of the Week',
        visual: _buildDaysVisual(),
        description:
            'There are 7 days in a week: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, and Sunday.',
        options: ['7 days', '6 days', '5 days', '8 days'],
        exercise: 'Can you say the days of the week in order?',
      ),
      TimeConcept(
        name: 'Weekdays and Weekends',
        visual: _buildWeekdayWeekendVisual(),
        description:
            'Weekdays are Monday to Friday, and weekends are Saturday and Sunday.',
        options: ['Weekdays', 'Weekends', 'Both', 'Neither'],
        exercise:
            'Can you identify which days are weekdays and which are weekend days?',
      ),
      TimeConcept(
        name: 'Yesterday, Today, and Tomorrow',
        visual: _buildCalendarVisual(),
        description:
            'Today is the current day, tomorrow is the next day, and yesterday was the day before.',
        options: ['Today', 'Tomorrow', 'Yesterday', 'Next week'],
        exercise: 'If today is Monday, what day is tomorrow?',
      ),

      // Time of Day Section
      TimeConcept(
        name: 'Morning Activities',
        visual: _buildTimeVisual('🌅', 'Morning'),
        description:
            'Morning is when we wake up and start our day, from sunrise until noon.',
        options: ['Morning', 'Afternoon', 'Evening', 'Night'],
        exercise: 'What activities do you do in the morning?',
      ),
      TimeConcept(
        name: 'Afternoon Activities',
        visual: _buildTimeVisual('☀️', 'Afternoon'),
        description:
            'Afternoon is from noon until evening, when the sun is high in the sky.',
        options: ['Afternoon', 'Morning', 'Evening', 'Night'],
        exercise: 'What time do you eat lunch?',
      ),
      TimeConcept(
        name: 'Evening Activities',
        visual: _buildTimeVisual('🌆', 'Evening'),
        description:
            'Evening is when the sun sets and we prepare to end our day.',
        options: ['Evening', 'Morning', 'Afternoon', 'Night'],
        exercise: 'What do you do in the evening?',
      ),
      TimeConcept(
        name: 'Daily Routines',
        visual: _buildDailyRoutineVisual(),
        description:
            'Our day has a routine of activities from morning to night.',
        options: [
          'Morning routine',
          'Evening routine',
          'Daily routine',
          'Weekend routine'
        ],
        exercise: 'Can you describe your daily routine?',
      ),
    ];
  }

  void _initializeGameQuestions() {
    gameQuestions = [
      {
        'question': 'If today is Wednesday, what day was yesterday?',
        'image': _buildCalendarVisual(),
        'options': ['Tuesday', 'Thursday', 'Monday', 'Friday'],
        'correctAnswer': 'Tuesday',
        'explanation':
            'Yesterday is the day before today. If today is Wednesday, then yesterday was Tuesday.',
      },
      {
        'question': 'Which activities belong to a morning routine?',
        'image': _buildDailyRoutineVisual(),
        'options': [
          'Wake up, brush teeth, breakfast',
          'Dinner, watch TV, sleep',
          'Lunch, play, study',
          'Shopping, cooking, cleaning'
        ],
        'correctAnswer': 'Wake up, brush teeth, breakfast',
        'explanation':
            'Morning routines typically include activities we do when we start our day.',
      },
      {
        'question':
            'Sarah has dance class every Monday and Thursday. How many days per week does she have dance class?',
        'image': _buildDaysVisual(),
        'options': ['2 days', '3 days', '4 days', '5 days'],
        'correctAnswer': '2 days',
        'explanation':
            'If Sarah has dance class on Monday and Thursday, that means she goes twice (2 days) per week.',
      },
      {
        'question': 'Which days make up a weekend?',
        'image': _buildWeekdayWeekendVisual(),
        'options': [
          'Saturday and Sunday',
          'Friday and Saturday',
          'Sunday and Monday',
          'Monday and Tuesday'
        ],
        'correctAnswer': 'Saturday and Sunday',
        'explanation':
            'Weekends are Saturday and Sunday, when most people don\'t go to school or work.',
      },
      {
        'question':
            'Match the activity with the correct time of day: "Having breakfast"',
        'image': _buildTimeVisual('🌅', 'Morning'),
        'options': ['Morning', 'Evening', 'Afternoon', 'Night'],
        'correctAnswer': 'Morning',
        'explanation':
            'Breakfast is our first meal of the day, which we typically have in the morning after waking up.',
      }
    ];
  }

  void _startGame() {
    if (!isGameMode) return;

    setState(() {
      currentQuestion = 0;
      score = 0;
      shuffledConcepts = List.from(concepts)..shuffle();
      _shuffleGameOptions();
    });
  }

  void _shuffleGameOptions() {
    setState(() {
      _shuffledOptions = List<String>.from(
          gameQuestions[currentQuestion]['options'] as List<String>);
      _shuffledOptions.shuffle();
    });
  }

  Future<void> _checkAnswer(String selectedOption) async {
    final isCorrect =
        selectedOption == gameQuestions[currentQuestion]['correctAnswer'];

    setState(() {
      selectedAnswer = selectedOption;
      _showingFeedback = true;
      _isCorrectAnswer = isCorrect;

      if (isCorrect) {
        score++;
      }

      _answerAnimationController.forward().then((_) {
        _answerAnimationController.reverse();
      });
    });
    if (isCorrect) {
      await speakText('Correct!');
    } else {
      await speakText('Try again!');
    }

    // Add animation and feedback delay before moving to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showingFeedback = false;
        });

        if (currentQuestion < gameQuestions.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            _shuffleGameOptions(); // Shuffle options for the new question
          });
        } else {
          // Save progress immediately when game is complete
          developer.log('Time screen completed. Saving progress...');
          developer.log('Score: $score out of ${gameQuestions.length}');

          SharedPreferenceService.saveGameProgress(
                  'time', score, gameQuestions.length)
              .then((_) {
            developer.log('Time screen progress saved successfully');
            // Show game complete dialog
            showGameCompletionDialog(
                context, score, gameQuestions, setState, _startGame, 'Time');
          });
        }
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
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: concepts.length,
          itemBuilder: (context, index) {
            final concept = concepts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
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
                    if (concept.exercise != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Exercise:',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        concept.exercise!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameModeScreen() {
    return WillPopScope(
      onWillPop: () async {
        return true; // Allow default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Question ${currentQuestion + 1}/5',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFF7B2FF2),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/time');
            },
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Score: $score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            gameQuestions[currentQuestion]['question']
                                as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200, // Increased height to prevent overflow
                            child: Center(
                              child: gameQuestions[currentQuestion]['image']
                                  as Widget,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._getShuffledOptions().map((option) {
                    return _buildAnswerOption(option);
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getShuffledOptions() {
    return _shuffledOptions;
  }

  Widget _buildAnswerOption(String option) {
    final isSelected = selectedAnswer == option;
    final isCorrectOption =
        option == gameQuestions[currentQuestion]['correctAnswer'];
    final isIncorrect = isSelected && !isCorrectOption;

    return AnimatedBuilder(
      animation: _answerAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale:
              isSelected && isCorrectOption ? _answerScaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _getOptionColor(isSelected, isCorrectOption, isIncorrect),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _getBorderColor(isSelected, isCorrectOption, isIncorrect),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    selectedAnswer == null ? () => _checkAnswer(option) : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: _getTextColor(
                                isSelected, isCorrectOption, isIncorrect),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (_showingFeedback && isSelected)
                        Icon(
                          isCorrectOption ? Icons.check_circle : Icons.cancel,
                          color: isCorrectOption ? Colors.green : Colors.red,
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

  Color _getOptionColor(
      bool isSelected, bool isCorrectOption, bool isIncorrect) {
    if (!_showingFeedback) return Colors.white;
    if (isSelected && isCorrectOption) return Colors.green.withOpacity(0.2);
    if (isIncorrect) return Colors.red.withOpacity(0.2);
    return Colors.white;
  }

  Color _getBorderColor(
      bool isSelected, bool isCorrectOption, bool isIncorrect) {
    if (!_showingFeedback)
      return isSelected ? Colors.purple : Colors.grey.shade300;
    if (isSelected && isCorrectOption) return Colors.green;
    if (isIncorrect) return Colors.red;
    return Colors.grey.shade300;
  }

  Color _getTextColor(bool isSelected, bool isCorrectOption, bool isIncorrect) {
    if (!_showingFeedback) return isSelected ? Colors.purple : Colors.black87;
    if (isSelected && isCorrectOption) return Colors.green;
    if (isIncorrect) return Colors.red;
    return Colors.black87;
  }

  Color _getShadowColor(bool isCorrectOption) {
    if (!_showingFeedback) return Colors.purple.withOpacity(0.3);
    return isCorrectOption
        ? Colors.green.withOpacity(0.3)
        : Colors.red.withOpacity(0.3);
  }

  static Widget _buildDaysVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Days of the Week',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((day) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple),
                          ),
                          child:
                              Text(day, style: const TextStyle(fontSize: 16)),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildClockHand(double angle, double length, double thickness) {
    return Transform.rotate(
      angle: angle,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: length,
          height: thickness,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(thickness / 2),
          ),
          transformAlignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  static Widget _buildSimpleClock(int hour, int minute) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]!, width: 2),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Minute markers
          ...List.generate(60, (index) {
            final isHour = index % 5 == 0;
            final angle = index * 6 * pi / 180;
            return Transform.rotate(
              angle: angle,
              child: Transform.translate(
                offset: const Offset(0, -90),
                child: Container(
                  width: isHour ? 2 : 1,
                  height: isHour ? 8 : 4,
                  color: Colors.grey[400],
                ),
              ),
            );
          }),
          // Clock numbers
          ...List.generate(12, (index) {
            final number = index == 0 ? 12 : index;
            final angle = (index - 3) * 30 * pi / 180;
            final radius = 80.0;
            return Positioned(
              left: 100 + radius * cos(angle) - 12,
              top: 100 + radius * sin(angle) - 12,
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            );
          }),
          // Hour hand
          Center(
            child: Transform.rotate(
              angle: ((hour % 12 + minute / 60) * 30 - 90) * pi / 180,
              child: Container(
                width: 60,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(1),
                ),
                transformAlignment: Alignment.centerLeft,
              ),
            ),
          ),
          // Minute hand
          Center(
            child: Transform.rotate(
              angle: (minute * 6 - 90) * pi / 180,
              child: Container(
                width: 80,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(1),
                ),
                transformAlignment: Alignment.centerLeft,
              ),
            ),
          ),
          // Center dot
          Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildOClockVisual(int hour) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildSimpleClock(hour, 0), // 0 minutes for o'clock
        ],
      ),
    );
  }

  static Widget _buildHalfPastVisual(int hour) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildSimpleClock(hour, 30), // 30 minutes for half past
        ],
      ),
    );
  }

  static Widget _buildCalendarVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
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
                  children: const [
                    Icon(Icons.calendar_today, size: 48),
                    SizedBox(height: 8),
                    Text('Yesterday', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: const [
                    Icon(Icons.calendar_today, color: Colors.purple, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Today',
                      style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: const [
                    Icon(Icons.calendar_today, size: 48),
                    SizedBox(height: 8),
                    Text('Tomorrow', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildTimeVisual(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Time of Day: $label',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget _buildWeekdayWeekendVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Weekdays vs Weekends',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Weekdays',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mon - Fri',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Weekends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sat - Sun',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildDailyRoutineVisual() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 100, // Adjust this value as needed for your design
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Daily Routine',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(child: _buildRoutineItem('🌅', 'Wake')),
                      const Icon(Icons.arrow_forward,
                          color: Colors.purple, size: 16),
                      Flexible(child: _buildRoutineItem('🍳', 'Eat')),
                      const Icon(Icons.arrow_forward,
                          color: Colors.purple, size: 16),
                      Flexible(child: _buildRoutineItem('🏫', 'School')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(child: _buildRoutineItem('🌆', 'Dinner')),
                      const Icon(Icons.arrow_forward,
                          color: Colors.purple, size: 16),
                      Flexible(child: _buildRoutineItem('🛁', 'Bath')),
                      const Icon(Icons.arrow_forward,
                          color: Colors.purple, size: 16),
                      Flexible(child: _buildRoutineItem('😴', 'Sleep')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildRoutineItem(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.purple),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 8),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
