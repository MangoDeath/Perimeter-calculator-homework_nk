import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/food.dart';

class PresetsScreen extends StatefulWidget {
  const PresetsScreen({super.key});

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  final _db = DatabaseHelper();
  List<Food> _foods = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final foods = await _db.getFoods();
    if (mounted) setState(() => _foods = foods);
  }

  Future<void> _showEditor([Food? food]) async {
    await showDialog(
      context: context,
      builder: (_) => _FoodEditor(food: food),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presets')),
      body: _foods.isEmpty
          ? const Center(child: Text('No presets yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _foods.length,
              itemBuilder: (_, i) {
                final food = _foods[i];
                return ListTile(
                  title: Text(food.name),
                  subtitle: Text(
                    '${food.calories.toStringAsFixed(0)} kcal  '
                    'P:${food.proteinG.toStringAsFixed(1)}g  '
                    'C:${food.carbsG.toStringAsFixed(1)}g  '
                    'F:${food.fatG.toStringAsFixed(1)}g',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEditor(food),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await _db.deleteFood(food.id!);
                          _load();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FoodEditor extends StatefulWidget {
  final Food? food;
  const _FoodEditor({this.food});

  @override
  State<_FoodEditor> createState() => _FoodEditorState();
}

class _FoodEditorState extends State<_FoodEditor> {
  final _db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;

  @override
  void initState() {
    super.initState();
    final f = widget.food;
    _name = TextEditingController(text: f?.name ?? '');
    _calories = TextEditingController(text: f?.calories.toString() ?? '');
    _protein = TextEditingController(text: f?.proteinG.toString() ?? '');
    _carbs = TextEditingController(text: f?.carbsG.toString() ?? '');
    _fat = TextEditingController(text: f?.fatG.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final food = Food(
      id: widget.food?.id,
      name: _name.text.trim(),
      calories: double.parse(_calories.text),
      proteinG: double.parse(_protein.text),
      carbsG: double.parse(_carbs.text),
      fatG: double.parse(_fat.text),
    );
    if (food.id == null) {
      await _db.insertFood(food);
    } else {
      await _db.updateFood(food);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.food == null ? 'Add Preset' : 'Edit Preset'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                  controller: _name, label: 'Food name', isText: true),
              const SizedBox(height: 8),
              _DialogField(controller: _calories, label: 'Calories (kcal)'),
              const SizedBox(height: 8),
              _DialogField(controller: _protein, label: 'Protein (g)'),
              const SizedBox(height: 8),
              _DialogField(controller: _carbs, label: 'Carbs (g)'),
              const SizedBox(height: 8),
              _DialogField(controller: _fat, label: 'Fat (g)'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isText;

  const _DialogField(
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
        isDense: true,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (!isText && double.tryParse(v) == null) return 'Enter a number';
        return null;
      },
    );
  }
}
