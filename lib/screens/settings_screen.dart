import 'package:flutter/material.dart';
import '../data/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _goalCtrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _goalCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final goal = await _db.getDailyGoal();
    if (mounted) {
      setState(() {
        _goalCtrl.text = goal.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _db.setDailyGoal(int.parse(_goalCtrl.text));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Goal saved!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _goalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Daily Calorie Goal (kcal)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0)
                          return 'Enter a positive number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: _save, child: const Text('Save Goal')),
                  ],
                ),
              ),
            ),
    );
  }
}
