import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';

class MoneyConcept {
  final String name;
  final Widget visual;
  final String description;
  final List<String> options;
  final String correctAnswer;

  MoneyConcept({
    required this.name,
    required this.visual,
    required this.description,
    required this.options,
    required this.correctAnswer,
  });
}

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<MoneyConcept> shuffledConcepts = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;

  final List<MoneyConcept> concepts = [
    MoneyConcept(
      name: 'Penny',
      visual: _buildMoneyVisual('1¢', 'Penny'),
      description: '1 cent coin',
      options: ['Penny', 'Nickel', 'Dime', 'Quarter', 'Dollar'],
      correctAnswer: 'Penny',
    ),
    MoneyConcept(
      name: 'Nickel',
      visual: _buildMoneyVisual('5¢', 'Nickel'),
      description: '5 cents coin',
      options: ['Nickel', 'Penny', 'Dime', 'Quarter', 'Dollar'],
      correctAnswer: 'Nickel',
    ),
    MoneyConcept(
      name: 'Dime',
      visual: _buildMoneyVisual('10¢', 'Dime'),
      description: '10 cents coin',
      options: ['Dime', 'Penny', 'Nickel', 'Quarter', 'Dollar'],
      correctAnswer: 'Dime',
    ),
    MoneyConcept(
      name: 'Quarter',
      visual: _buildMoneyVisual('25¢', 'Quarter'),
      description: '25 cents coin',
      options: ['Quarter', 'Penny', 'Nickel', 'Dime', 'Dollar'],
      correctAnswer: 'Quarter',
    ),
    MoneyConcept(
      name: 'Dollar',
      visual: _buildMoneyVisual('\$1', 'Dollar'),
      description: '1 dollar bill',
      options: ['Dollar', 'Penny', 'Nickel', 'Dime', 'Quarter'],
      correctAnswer: 'Dollar',
    ),
  ];

  static Widget _buildMoneyVisual(String value, String name) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeTts();
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
    _initializeStorage();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _initializeStorage() async {
    try {
      await PreferenceService.initialize();
      await _loadGameState();
    } catch (e) {
      developer.log('Error initializing storage: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGameState() async {
    try {
      final savedScore = await PreferenceService.getInt('money_score') ?? 0;
      final savedQuestion = await PreferenceService.getInt('money_question') ?? 0;
      final savedGameMode = await PreferenceService.getBool('money_game_mode') ?? false;

      setState(() {
        score = savedScore;
        currentQuestion = savedQuestion;
        isGameMode = savedGameMode;
        _isLoading = false;
      });

      if (isGameMode) {
        _startGame();
      }
    } catch (e) {
      developer.log('Error loading game state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGameState() async {
    try {
      await PreferenceService.setInt('money_score', score);
      await PreferenceService.setInt('money_question', currentQuestion);
      await PreferenceService.setBool('money_game_mode', isGameMode);
    } catch (e) {
      developer.log('Error saving game state: $e');
    }
  }

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledConcepts = List.from(concepts)..shuffle();
      for (var concept in shuffledConcepts) {
        concept.options.shuffle();
      }
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledConcepts[currentQuestion].correctAnswer;
      if (isCorrect) {
        score++;
        _animationController.reset();
        _animationController.forward();
        _speakText('Yay! You got it right! ${shuffledConcepts[currentQuestion].name} is correct!');
      } else {
        _speakText('Oops! Try again! Think about the money value');
      }

      // Save score if this is the last question
      if (currentQuestion == shuffledConcepts.length - 1) {
        SharedPreferenceService.saveGameProgress('money', score, shuffledConcepts.length);
      }
    });
  }

  void _nextQuestion() async {
    if (currentQuestion < shuffledConcepts.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        _animationController.reset();
        _animationController.forward();
      });
      _speakText('Great job! Let\'s try another one!');
      await _saveGameState();
    } else {
      setState(() {
        isGameMode = false;
      });
      _speakText('Wow! You finished the game! You got $score out of ${shuffledConcepts.length} correct! You\'re amazing!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isGameMode ? 'Money Game' : 'Learn Money'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!isGameMode)
            IconButton(
              icon: const Icon(Icons.games),
              onPressed: _startGame,
              tooltip: 'Start Game',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.3),
              Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            ],
          ),
        ),
        child: isGameMode ? _buildGameMode() : _buildLearningMode(),
      ),
    );
  }

  Widget _buildGameMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Question ${currentQuestion + 1} of ${concepts.length}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Score: $score',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              shuffledConcepts[currentQuestion].visual,
              const SizedBox(height: 10),
              Text(
                shuffledConcepts[currentQuestion].description,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: shuffledConcepts[currentQuestion].options.map((option) {
            return ElevatedButton(
              onPressed: showResult ? null : () => _checkAnswer(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: showResult
                    ? (selectedAnswer == option
                        ? (isCorrect ? Colors.green : Colors.red)
                        : (shuffledConcepts[currentQuestion].correctAnswer == option ? Colors.green : null))
                    : null,
              ),
              child: Text(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLearningMode() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: concepts.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => _speakText(concepts[index].description),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: concepts[index].visual,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        concepts[index].name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        concepts[index].description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _startGame,
          icon: const Icon(Icons.games),
          label: const Text('Start Game'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }
} 