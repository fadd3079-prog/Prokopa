import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/shared/models/enums.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/core/database/app_database.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  final int? habitId;

  const HabitFormScreen({super.key, this.habitId});

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  HabitCategory _selectedCategory = HabitCategory.health;
  String _frequency = 'Daily';
  int _selectedColor = 0xFF3F51B5; // Indigo
  String _selectedIcon = 'fitness_center';

  final List<int> _colors = [
    0xFF3F51B5, // Indigo
    0xFFF44336, // Red
    0xFF4CAF50, // Green
    0xFFFF9800, // Orange
    0xFF9C27B0, // Purple
  ];

  final Map<String, IconData> _icons = {
    'fitness_center': Icons.fitness_center,
    'book': Icons.book,
    'water_drop': Icons.water_drop,
    'directions_run': Icons.directions_run,
    'self_improvement': Icons.self_improvement,
    'monitor_heart': Icons.monitor_heart,
  };

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _loadHabit();
    }
  }

  Future<void> _loadHabit() async {
    final db = ref.read(databaseProvider);
    final habit = await db.habitDao.getHabit(widget.habitId!);
    setState(() {
      _titleController.text = habit.title;
      _descriptionController.text = habit.description;
      _selectedCategory = HabitCategory.values.firstWhere(
        (c) => c.name == habit.category,
        orElse: () => HabitCategory.health,
      );
      _frequency = habit.frequency;
      _selectedColor = habit.color ?? _colors[0];
      _selectedIcon = habit.icon ?? 'fitness_center';
      _selectedColor = habit.color;
      _selectedIcon = habit.icon;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final db = ref.read(databaseProvider);

      if (widget.habitId == null) {
        // Create new habit
        await db.habitDao.createHabit(
          HabitsCompanion.insert(
            title: _titleController.text,
            description: Value(_descriptionController.text),
            category: Value(_selectedCategory.name),
            frequency: Value(_frequency),
            color: Value(_selectedColor),
            icon: Value(_selectedIcon),
          ),
        );
      } else {
        // Update existing habit
        await db.habitDao.updateHabit(
          widget.habitId!,
          HabitsCompanion(
            title: Value(_titleController.text),
            description: Value(_descriptionController.text),
            category: Value(_selectedCategory.name),
            frequency: Value(_frequency),
            color: Value(_selectedColor),
            icon: Value(_selectedIcon),
          ),
        );
      }

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitId == null ? 'New Habit' : 'Edit Habit'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveHabit),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Habit Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<HabitCategory>(
                value: _selectedCategory,
                items: HabitCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              const Text(
                'Frequency',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Daily'),
                    selected: _frequency == 'Daily',
                    onSelected: (val) {
                      if (val) setState(() => _frequency = 'Daily');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Weekly'),
                    selected: _frequency == 'Weekly',
                    onSelected: (val) {
                      if (val) setState(() => _frequency = 'Weekly');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Color',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: _colors.map((colorValue) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorValue),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        border: _selectedColor == colorValue
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.entries.map((entry) {
                  final isSelected = _selectedIcon == entry.key;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = entry.key),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[300] : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        entry.value,
                        size: 32,
                        color: Color(_selectedColor),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveHabit,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Save Habit', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
