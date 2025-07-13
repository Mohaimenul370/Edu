import 'package:flutter/material.dart';

class PatternVisual extends StatelessWidget {
  final List<String> pattern;
  final String type;

  const PatternVisual({
    super.key,
    required this.pattern,
    this.type = 'emoji',
  });

  @override
  Widget build(BuildContext context) {
    if (type == 'size') {
      return _buildSizePattern();
    } else if (type == 'number') {
      return _buildNumberPattern();
    } else {
      return _buildEmojiPattern();
    }
  }

  Widget _buildEmojiPattern() {
    // Special case for Inside and Outside pattern
    if (pattern.length == 2 && pattern.contains('⬛️') && pattern.contains('⚽️')) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '⬛️',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Text(
                '⚽️',
                style: const TextStyle(fontSize: 32),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'outside',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pattern.map((emoji) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizePattern() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pattern.map((size) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size == 'big' ? 48 : 24,
                height: size == 'big' ? 48 : 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                size,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberPattern() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pattern.map((number) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.purple),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
} 