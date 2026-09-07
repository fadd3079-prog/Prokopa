import 'package:flutter/material.dart';
import 'package:habitflow/shared/models/enums.dart';

/// A row of mood emoji buttons for selecting mood (1-5 scale).
class MoodSelector extends StatelessWidget {
  final MoodType? selectedMood;
  final ValueChanged<MoodType> onChanged;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onChanged,
  });

  String _getEmojiForMood(MoodType mood) {
    switch (mood) {
      case MoodType.veryBad:
        return '😫';
      case MoodType.bad:
        return '😞';
      case MoodType.normal:
        return '😐';
      case MoodType.good:
        return '🙂';
      case MoodType.excellent:
        return '🤩';
    }
  }

  String _getLabelForMood(MoodType mood) {
    switch (mood) {
      case MoodType.veryBad:
        return 'Awful';
      case MoodType.bad:
        return 'Bad';
      case MoodType.normal:
        return 'Neutral';
      case MoodType.good:
        return 'Good';
      case MoodType.excellent:
        return 'Great';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MoodType.values.map((mood) {
        final isSelected = selectedMood == mood;
        return GestureDetector(
          onTap: () => onChanged(mood),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Text(
                  _getEmojiForMood(mood),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getLabelForMood(mood),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
