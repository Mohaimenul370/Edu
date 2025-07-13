import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/shared_preference_service.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class Question {
  final int num1;
  final int num2;
  final String operation;
  final List<int> options;
  final int correctAnswer;

  Question({
    required this.num1,
    required this.num2,
    required this.operation,
    required this.options,
    required this.correctAnswer,
  });
}

class NumberActivity {
  final String title;
  final String description;
  final Widget visual;
  final String instruction;
  final List<String> options;
  final String name;
  final String funFact;

  NumberActivity({
    required this.title,
    required this.description,
    required this.visual,
    required this.instruction,
    required this.options,
    required this.name,
    required this.funFact,
  });
}

class NumbersTo20Screen extends StatefulWidget {
  final bool isGameMode;
  
  const NumbersTo20Screen({
    super.key,
    this.isGameMode = false,
  });

  @override
  State<NumbersTo20Screen> createState() => _NumbersTo20ScreenState();
}

class _NumbersTo20ScreenState extends State<NumbersTo20Screen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  int? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<Question> questions = [];
  List<NumberActivity> shuffledActivities = [];
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  int? expandedIndex;

  List<NumberActivity> get activities => [
    NumberActivity(
      title: 'Number 11 - Eleven',
      description: 'Learn about the number eleven and how to recognize it',
      visual: _buildNumberVisual(11, Colors.blue),
      instruction: 'Eleven comes after ten and represents eleven items',
      options: ['11', 'Eleven', 'Eleventh'],
      name: 'Eleven',
      funFact: 'Eleven is the first number that needs two digits to write!',
    ),
    NumberActivity(
      title: 'Number 12 - Twelve',
      description: 'Discover the number twelve and its representation',
      visual: _buildNumberVisual(12, Colors.red),
      instruction: 'Twelve is a dozen - like twelve eggs in a carton',
      options: ['12', 'Twelve', 'Twelfth'],
      name: 'Twelve',
      funFact: 'A dozen means twelve - like twelve donuts in a box!',
    ),
    NumberActivity(
      title: 'Numbers 13-15',
      description: 'Explore numbers thirteen through fifteen',
      visual: _buildCountingVisual(15),
      instruction: 'These numbers follow the pattern of "thir-teen", "four-teen", "fif-teen"',
      options: ['13', '14', '15'],
      name: 'Teen Numbers',
      funFact: 'Numbers 13-19 are called "teen" numbers because they end in "teen"!',
    ),
    NumberActivity(
      title: 'Numbers 16-20',
      description: 'Learn about numbers sixteen through twenty',
      visual: _buildCountingVisual(20),
      instruction: 'Practice counting from 16 to 20',
      options: ['16', '17', '18', '19', '20'],
      name: 'Higher Teens',
      funFact: 'Twenty is the first number that starts a new counting pattern!',
    ),
    NumberActivity(
      title: 'Number Sequence 11-20',
      description: 'Learn the order of numbers from 11 to 20',
      visual: _buildNumberLine(),
      instruction: 'Follow the number line and learn the sequence',
      options: List.generate(10, (index) => (index + 11).toString()),
      name: 'Number Order',
      funFact: 'Learning number order helps us count and do math!',
    ),
      ];

  static Widget _buildNumberVisual(int number, Color color) {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$number',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              math.min(number, 10),
              (index) => Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          if (number > 10)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                number - 10,
                (index) => Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeAnimation();
    if (isGameMode) {
      _startGame();
    }
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  void _handleActivityTap(NumberActivity activity, int index) {
    _speakText('${activity.title}. ${activity.instruction}');
    setState(() {
      expandedIndex = expandedIndex == index ? null : index;
    });
  }

  void _checkAnswer(int selectedOption) {
    if (!mounted) return;
    
    setState(() {
      selectedAnswer = selectedOption;
      showResult = true;
      isCorrect = selectedOption == questions[currentQuestion].correctAnswer;
    });

    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });

    if (isCorrect) {
      score++;
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      setState(() {
        if (currentQuestion < questions.length - 1) {
          currentQuestion++;
          selectedAnswer = null;
          showResult = false;
        } else {
          _showCompletionDialog();
        }
      });
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / questions.length) * 100;
    final isPassed = percentage >= 70;
    
    SharedPreferenceService.saveGameProgress('numbers_to_20', score, questions.length);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPassed ? Icons.star : Icons.star_border,
                size: 80,
                color: isPassed ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          ' / ${questions.length}',
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isPassed
                    ? 'Great job! You\'ve mastered these numbers!'
                    : 'You\'re getting there! Practice makes perfect.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _startGame();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Play Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame() {
    if (!mounted) return;
    
    setState(() {
      questions = List.generate(5, (index) {
        final operation = ['+', '-'][math.Random().nextInt(2)];
        int num1, num2;
        
        if (operation == '+') {
          num1 = math.Random().nextInt(10) + 11; // 11-20
          num2 = math.Random().nextInt(10) + 1;  // 1-10
        } else {
          num1 = math.Random().nextInt(10) + 11; // 11-20
          num2 = math.Random().nextInt(num1 - 10) + 1; // Ensures positive result
        }

        final correctAnswer = operation == '+' ? num1 + num2 : num1 - num2;
        final options = [correctAnswer];

        while (options.length < 4) {
          final wrongAnswer = math.Random().nextInt(20) + 1;
          if (!options.contains(wrongAnswer)) {
            options.add(wrongAnswer);
          }
        }

        options.shuffle();

        return Question(
          num1: num1,
          num2: num2,
          operation: operation,
          options: options,
          correctAnswer: correctAnswer,
        );
      });

      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
    });
  }

  void _initializeAnimation() {
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF7B2FF2),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF7B2FF2),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    
    if (isGameMode) {
      return _buildGameContent();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Numbers to 20'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: RawScrollbar(
                          thumbColor: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          radius: const Radius.circular(20),
                          thickness: 5,
                          child: activity.visual,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Instructions:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.instruction,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Fun Fact:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.funFact,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameContent() {
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: const Color(0xFF7B2FF2),
        systemNavigationBarColor: const Color(0xFF7B2FF2),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3EFFF),
        appBar: AppBar(
          title: const Text(
            'Numbers Practice',
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF3EFFF), Color(0xFFE3F0FF)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                    Theme.of(context).colorScheme.primary.withOpacity(0.9),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Question ${currentQuestion + 1}/${questions.length}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (currentQuestion + 1) / questions.length,
                                        backgroundColor: Colors.white.withOpacity(0.2),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Score: $score',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF7B2FF2), width: 2),
                              ),
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Question ${currentQuestion + 1}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF7B2FF2),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${questions[currentQuestion].num1} ${questions[currentQuestion].operation} ${questions[currentQuestion].num2} = ?',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7B2FF2),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...questions[currentQuestion].options.map((option) {
                            final isSelected = selectedAnswer == option;
                            final isCorrect = showResult && option == questions[currentQuestion].correctAnswer;
                            final isIncorrect = showResult && isSelected && option != questions[currentQuestion].correctAnswer;

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
                                        onTap: showResult ? null : () {
                                          if (mounted) {
                                            _checkAnswer(option);
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                                                          ? const Color(0xFF7B2FF2)
                                                          : Colors.grey.shade300,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            option.toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: isCorrect
                                                  ? Colors.green
                                                  : isIncorrect
                                                      ? Colors.red
                                                      : isSelected
                                                          ? const Color(0xFF7B2FF2)
                                                          : Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountingVisual(int count) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberLine() {
    return RawScrollbar(
      thumbColor: Theme.of(context).colorScheme.primary.withOpacity(0.6),
      radius: const Radius.circular(20),
      thickness: 5,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              21,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 2,
                      height: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$index',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getNumberWord(int number) {
    final words = [
      'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen', 'Twenty'
    ];
    return words[number - 1];
  }

  Color _getOptionColor(bool isSelected, bool isCorrect, bool isIncorrect) {
    if (isCorrect) {
      return Colors.green.withOpacity(0.9);
    } else if (isIncorrect) {
      return Colors.red.withOpacity(0.9);
    } else if (isSelected) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.9);
    } else {
      return Theme.of(context).colorScheme.primary.withOpacity(0.7);
    }
  }
} 