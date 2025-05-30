import 'package:flutter/material.dart';

class IntensitySelector extends StatelessWidget {
  final Function(int) onChanged;
  final int currentLevel;

  const IntensitySelector({
    super.key,
    required this.onChanged,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton('Low', 1),
        _buildButton('Medium', 2),
        _buildButton('High', 3),
        _buildButton('Max', 4),
      ],
    );
  }
  
  Widget _buildButton(String label, int level) {
    return ElevatedButton(
      onPressed: () => onChanged(level),
      style: ElevatedButton.styleFrom(
        backgroundColor: currentLevel == level ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }
}
