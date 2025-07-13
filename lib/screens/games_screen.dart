import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final List<Map<String, dynamic>> cards = [
    {'letter': 'A', 'image': '🍎'},
    {'letter': 'B', 'image': '🍌'},
    {'letter': 'C', 'image': '🐱'},
    {'letter': 'D', 'image': '🐶'},
    {'letter': 'E', 'image': '🐘'},
    {'letter': 'F', 'image': '🐟'},
  ];

  List<bool> matched = [];
  String? selectedLetter;
  String? selectedImage;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  void _initializeGame() {
    matched = List.generate(cards.length, (index) => false);
    selectedLetter = null;
    selectedImage = null;
    score = 0;
  }

  void _checkMatch(String letter, String image) async {
    if (selectedLetter == null) {
      setState(() {
        selectedLetter = letter;
      });
      await flutterTts.speak(letter);
    } else if (selectedImage == null && letter != selectedLetter) {
      setState(() {
        selectedImage = image;
      });

      // Find if they match
      final matchingCard = cards.firstWhere((card) => card['letter'] == selectedLetter);
      if (matchingCard['image'] == image) {
        // Correct match
        final index = cards.indexWhere((card) => card['letter'] == selectedLetter);
        setState(() {
          matched[index] = true;
          score += 10;
          selectedLetter = null;
          selectedImage = null;
        });
        await flutterTts.speak("Correct!");
      } else {
        // Wrong match
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          selectedLetter = null;
          selectedImage = null;
        });
        await flutterTts.speak("Try again!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching Game'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...cards.map((card) => _buildCard(
                          card['letter'],
                          isSelected: card['letter'] == selectedLetter,
                          isMatched: matched[cards.indexOf(card)],
                        )),
                    ...cards.map((card) => _buildCard(
                          card['image'],
                          isSelected: card['image'] == selectedImage,
                          isMatched: matched[cards.indexOf(card)],
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeGame();
                    });
                  },
                  child: const Text('Reset Game'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String content, {bool isSelected = false, bool isMatched = false}) {
    return GestureDetector(
      onTap: isMatched ? null : () => _checkMatch(content, content),
      child: Card(
        color: isMatched
            ? Colors.green.withOpacity(0.3)
            : isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Colors.white,
        child: Center(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: isMatched ? Colors.green : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
} 