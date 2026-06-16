import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/food.dart';
import '../models/log_entry.dart';

class LogEntryScreen extends StatefulWidget {
  final String date;
  final LogEntry? existing;

  const LogEntryScreen({super.key, required this.date, this.existing});

  @override
  State<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends State<LogEntryScreen> {
  final _db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  late final TextEditingController _servings;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _calories = TextEditingController(text: e?.calories.toString() ?? '');
    _protein = TextEditingController(text: e?.proteinG.toString() ?? '');
    _carbs = TextEditingController(text: e?.carbsG.toString() ?? '');
    _fat = TextEditingController(text: e?.fatG.toString() ?? '');
    _servings =
        TextEditingController(text: (e?.servings ?? 1.0).toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _servings.dispose();
    super.dispose();
  }

  void _fillFromFood(Food food) {
    _name.text = food.name;
    _calories.text = food.calories.toString();
    _protein.text = food.proteinG.toString();
    _carbs.text = food.carbsG.toString();
    _fat.text = food.fatG.toString();
    _servings.text = '1';
  }

  Future<void> _pickPreset() async {
    final foods = await _db.getFoods();
    if (!mounted) return;
    if (foods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No presets saved yet.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        itemCount: foods.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(foods[i].name),
          subtitle: Text(
              '${foods[i].calories.toStringAsFixed(0)} kcal  '
              'P:${foods[i].proteinG.toStringAsFixed(1)}  '
              'C:${foods[i].carbsG.toStringAsFixed(1)}  '
              'F:${foods[i].fatG.toStringAsFixed(1)}'),
          onTap: () {
            Navigator.pop(context);
            _fillFromFood(foods[i]);
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final entry = LogEntry(
      id: widget.existing?.id,
      date: widget.date,
      name: _name.text.trim(),
      calories: double.parse(_calories.text),
      proteinG: double.parse(_protein.text),
      carbsG: double.parse(_carbs.text),
      fatG: double.parse(_fat.text),
      servings: double.parse(_servings.text),
    );
    if (entry.id == null) {
      await _db.insertLogEntry(entry);
    } else {
      await _db.updateLogEntry(entry);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'Add Food'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!isEditing)
              OutlinedButton.icon(
                onPressed: _pickPreset,
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Pick from Presets'),
              ),
            if (!isEditing) const SizedBox(height: 16),
            _Field(controller: _name, label: 'Food name', isText: true),
            const SizedBox(height: 12),
            _Field(controller: _calories, label: 'Calories (kcal)'),
            const SizedBox(height: 12),
            _Field(controller: _protein, label: 'Protein (g)'),
            const SizedBox(height: 12),
            _Field(controller: _carbs, label: 'Carbs (g)'),
            const SizedBox(height: 12),
            _Field(controller: _fat, label: 'Fat (g)'),
            const SizedBox(height: 12),
            _Field(controller: _servings, label: 'Servings'),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isText;

  const _Field(
      {required this.controller, required this.label, this.isText = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isText
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (!isText && double.tryParse(v) == null) return 'Enter a number';
        return null;
      },
    );
  }
}
