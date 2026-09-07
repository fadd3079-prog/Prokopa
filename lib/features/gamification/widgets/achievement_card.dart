import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final String name;
  final String description;
  final String iconEmoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementCard({
    super.key,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.isUnlocked,
    this.unlockedAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: isUnlocked
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              )
            : Border.all(color: theme.dividerColor),
        color: isUnlocked
            ? theme.cardColor
            : theme.disabledColor.withValues(alpha: 0.1),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(iconEmoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUnlocked ? description : '???',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isUnlocked && unlockedAt != null) ...[
                    const Spacer(),
                    Text(
                      '${unlockedAt!.day}/${unlockedAt!.month}/${unlockedAt!.year}',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isUnlocked)
              Container(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                child: const Center(
                  child: Icon(Icons.lock, size: 32, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
