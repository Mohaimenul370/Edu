import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/shared_preference_service.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import '../utils/utils_func.dart';

class Question {
  final String type;
  final int num1;
  final int num2;
  final String operation;
  final List<dynamic> options;
  final dynamic correctAnswer;
  final String? imageUrl;
  final String questionText;

  Question({
    required this.type,
    required this.num1,
    required this.num2,
    required this.operation,
    required this.options,
    required this.correctAnswer,
    this.imageUrl,
    required this.questionText,
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

class NumbersTo10Screen extends StatefulWidget {
  final bool isGameMode;
  
  const NumbersTo10Screen({
    super.key,
    this.isGameMode = false,
  });

  @override
  State<NumbersTo10Screen> createState() => _NumbersTo10ScreenState();
}

class _NumbersTo10ScreenState extends State<NumbersTo10Screen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  int? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<Question> questions = [];
  List<NumberActivity> shuffledActivities = [];

  // Animation controllers
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _resultAnimationController;
  late Animation<double> _resultAnimation;
  late AnimationController _correctAnimationController;
  late Animation<double> _correctAnimation;
  late AnimationController _incorrectAnimationController;
  late Animation<double> _incorrectAnimation;

  List<NumberActivity> get activities => [
    NumberActivity(
      title: 'Counting Sets of Objects',
      description: 'Learn how to count different sets of objects correctly',
      visual: _buildCountingSetVisual(),
      instruction: 'Count objects one by one, saying each number as you point to an object. The last number you say tells you how many objects there are.',
      options: ['Count in order', 'One object at a time', 'Last number is total'],
      name: 'Counting Sets',
      funFact: 'Counting helps us know exactly how many things we have!',
    ),
    NumberActivity(
      title: 'Reading and Writing Numbers',
      description: 'Learn to say, read, and write numbers from 1 to 10',
      visual: _buildNumberWritingVisual(),
      instruction: 'Practice saying each number while looking at its written form',
      options: ['1-One', '2-Two', '3-Three', '4-Four', '5-Five'],
      name: 'Number Reading',
      funFact: 'Every number has its own special word and symbol!',
    ),
    NumberActivity(
      title: 'Comparing Numbers',
      description: 'Learn which numbers are bigger, smaller, or equal',
      visual: _buildComparisonVisual(),
      instruction: 'Compare two groups of objects to see which has more or less',
      options: ['Greater than >', 'Less than <', 'Equal to ='],
      name: 'Number Comparison',
      funFact: 'We use special symbols like < and > to show which number is bigger!',
    ),
    NumberActivity(
      title: 'Number Words',
      description: 'Learn the words for numbers 1 to 10',
      visual: _buildNumberWordsVisual(),
      instruction: 'Match each number to its word',
      options: ['one', 'two', 'three', 'four', 'five'],
      name: 'Number Words',
      funFact: 'Number words help us read and write about quantities!',
    ),
    NumberActivity(
      title: 'Odd and Even Numbers',
      description: 'Discover which numbers are odd and which are even',
      visual: _buildOddEvenVisual(),
      instruction: 'Group objects in pairs to find odd and even numbers',
      options: ['Even: 2,4,6,8,10', 'Odd: 1,3,5,7,9'],
      name: 'Odd Even',
      funFact: 'Even numbers can make equal pairs, odd numbers always have one left over!',
    ),
    NumberActivity(
      title: 'Practice with Numbers 1-10',
      description: 'Put all your number skills together',
      visual: _buildCountingVisual(10),
      instruction: 'Use your counting, comparing, and number word skills',
      options: ['Count', 'Compare', 'Read', 'Write'],
      name: 'Number Practice',
      funFact: 'Numbers help us understand the world around us!',
    ),
  ];

  static Widget _buildCountingSetVisual() {
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
      child: Stack(
        children: [
          // Objects to count (circles with numbers)
          ...List.generate(
            5,
            (index) => Positioned(
              left: 20.0 + (index * 35),
              top: 30.0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Arrow showing counting direction
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_forward, color: Colors.blue),
                Text(
                  ' Count this way',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNumberWritingVisual() {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '1 → One',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Number & Word',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildComparisonVisual() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              ...List.generate(3, (index) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              )),
            ],
          ),
          const Text(
            '<',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('5', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              ...List.generate(5, (index) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildNumberWordsVisual() {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text('1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
              Text('One', style: TextStyle(fontSize: 20, color: Colors.purple)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text('2', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
              Text('Two', style: TextStyle(fontSize: 20, color: Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildOddEvenVisual() {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Even: 2 4 6 8',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Odd: 1 3 5 7',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildCountingVisual(int maxNumber) {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Numbers 1-10',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Container(
                width: 25,
                height: 25,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Container(
                width: 25,
                height: 25,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: Center(
                  child: Text(
                    '${index + 6}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
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
    _initializeServices();
    if (isGameMode) {
      _generateQuestions();
    }
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Scale animation for selected button
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.easeInOut),
    );

    // Result animation for correct/incorrect feedback
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultAnimationController, curve: Curves.easeInOut),
    );

    // Correct animation for correct answer - pulsing effect
    _correctAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _correctAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _correctAnimationController, curve: Curves.elasticOut),
    );

    // Incorrect animation for incorrect answer - shake effect
    _incorrectAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _incorrectAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _incorrectAnimationController, curve: Curves.elasticOut),
    );
  }

  Future<void> _initializeServices() async {
    await SharedPreferenceService.initialize();
    await _initializeTts();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  void _generateQuestions() {
    final random = Random();
    questions = [];
    
    // Game 1: Counting Sets
    final count = random.nextInt(5) + 1;
    List<int> options = [count]; // Start with correct answer
    
    // Generate 3 unique wrong answers
    while (options.length < 4) {
      int wrongOption = random.nextInt(10) + 1;
      if (!options.contains(wrongOption)) {
        options.add(wrongOption);
      }
    }
    
    options.shuffle(); // Shuffle all options
    
    questions.add(Question(
      type: 'counting',
      num1: count,
      num2: 0,
      operation: 'count',
      questionText: 'How many objects are there?',
      options: options,
      correctAnswer: count,
    ));

    // Game 2: Number Reading
    final numberWords = {
      1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five',
      6: 'six', 7: 'seven', 8: 'eight', 9: 'nine', 10: 'ten'
    };
    final number = random.nextInt(10) + 1;
    questions.add(Question(
      type: 'reading',
      num1: number,
      num2: 0,
      operation: 'read',
      questionText: 'What is this number in words?',
      options: List.generate(4, (index) {
        int optionNum = (number - 2 + index) % 10 + 1;
        return numberWords[optionNum]!;
      }),
      correctAnswer: numberWords[number],
    ));

    // Game 3: Number Comparison
    final num1 = random.nextInt(5) + 1;
    final num2 = random.nextInt(5) + 1;
    final symbols = ['<', '>', '='];
    final correctSymbol = num1 < num2 ? '<' : (num1 > num2 ? '>' : '=');
    questions.add(Question(
      type: 'comparison',
      num1: num1,
      num2: num2,
      operation: 'compare',
      questionText: 'Choose the correct symbol to compare the numbers',
      options: symbols,
      correctAnswer: correctSymbol,
    ));

    // Game 4: Number Words Matching
    final matchNumber = random.nextInt(10) + 1;
    questions.add(Question(
      type: 'matching',
      num1: matchNumber,
      num2: 0,
      operation: 'match',
      questionText: 'Match the number to its word',
      options: List.generate(4, (index) {
        int optionNum = (matchNumber - 2 + index) % 10 + 1;
        return numberWords[optionNum]!;
      }),
      correctAnswer: numberWords[matchNumber],
    ));

    // Game 5: Odd or Even
    final oddEvenNumber = random.nextInt(10) + 1;
    questions.add(Question(
      type: 'oddeven',
      num1: oddEvenNumber,
      num2: 0,
      operation: 'identify',
      questionText: 'Is this number odd or even?',
      options: ['Odd', 'Even'],
      correctAnswer: oddEvenNumber % 2 == 0 ? 'Even' : 'Odd',
    ));

    questions.shuffle(); // Shuffle all questions
  }

  void _checkAnswer(int selectedIndex) {
    if (showResult) return;

    setState(() {
      selectedAnswer = selectedIndex;
      showResult = true;
      isCorrect = questions[currentQuestion].options[selectedIndex] == questions[currentQuestion].correctAnswer;
      
      if (isCorrect) {
        score++;
      }
    });

    // Animate the selected button
    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });

    // Play sound based on correct/incorrect answer
    if (isCorrect) {
      _playCorrectSound();
    } else {
      _playIncorrectSound();
    }

    // Delay before moving to next question
    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        if (currentQuestion < questions.length - 1) {
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
              'numbers_to_10',
              score,
              questions.length,
            );
            developer.log('Game progress saved for numbers_to_10: Score $score out of ${questions.length}');
            setState(() {
              SharedPreferenceService.updateOverallProgress();
            });
            showGameCompletionDialog(context, score, questions, setState, _generateQuestions, 'Numbers to 10');
          }
        }
      }
    });
  }

 

  void _playCorrectSound() async {
    // Add your sound playing logic here
    await flutterTts.speak("Correct!");
  }

  void _playIncorrectSound() async {
    // Add your sound playing logic here
    await flutterTts.speak("Try again!");
  }

  @override
  Widget build(BuildContext context) {
    if (isGameMode) {
      return _buildGameContent();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Numbers to 10'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                      Center(child: activity.visual),
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B2FF2), Color(0xFF6B1FE2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text(
                  'Numbers Practice',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3EFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Question',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      '${currentQuestion + 1} of ${questions.length}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Score: $score',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (currentQuestion < questions.length)
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
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                _buildQuestionWidget(questions[currentQuestion]),
                                const SizedBox(height: 30),
                                _buildAnswerOptions(questions[currentQuestion]),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(Question question) {
    switch (question.type) {
      case 'counting':
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                question.num1,
                (index) => Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple),
                  ),
                ),
              ),
            ),
          ],
        );

      case 'reading':
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '${question.num1}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ],
        );

      case 'comparison':
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${question.num1}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 40),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('?', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 40),
                Text(
                  '${question.num2}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        );

      case 'matching':
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${question.num1}',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );

      case 'oddeven':
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${question.num1}',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAnswerOptions(Question question) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: question.options.map((option) {
        bool isSelected = selectedAnswer == question.options.indexOf(option);
        bool isCorrect = showResult && option == question.correctAnswer;
        bool isIncorrect = showResult && isSelected && option != question.correctAnswer;
        
        return AnimatedBuilder(
          animation: _scaleAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _scaleAnimation.value : 1.0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: isSelected ? 4 : 1,
                  child: InkWell(
                    onTap: showResult ? null : () => _checkAnswer(question.options.indexOf(option)),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                                      ? Colors.purple
                                      : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _resultAnimationController.dispose();
    _correctAnimationController.dispose();
    _incorrectAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
} 