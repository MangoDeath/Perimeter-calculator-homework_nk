import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import '../models/log_entry.dart';
import 'log_entry_screen.dart';
import 'settings_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _db = DatabaseHelper();
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<LogEntry> _entries = [];
  int _goal = 2000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _db.getEntriesForDate(_today);
    final goal = await _db.getDailyGoal();
    if (mounted) setState(() { _entries = entries; _goal = goal; });
  }

  double get _totalCalories => _entries.fold(0, (s, e) => s + e.totalCalories);
  double get _totalProtein => _entries.fold(0, (s, e) => s + e.totalProtein);
  double get _totalCarbs => _entries.fold(0, (s, e) => s + e.totalCarbs);
  double get _totalFat => _entries.fold(0, (s, e) => s + e.totalFat);

  @override
  Widget build(BuildContext context) {
    final remaining = _goal - _totalCalories;
    final progress = (_totalCalories / _goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEE, MMM d').format(DateTime.now())),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
              _load();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _CalorieSummaryCard(
                      goal: _goal,
                      consumed: _totalCalories,
                      remaining: remaining,
                      progress: progress,
                    ),
                    const SizedBox(height: 12),
                    _MacroRow(
                      protein: _totalProtein,
                      carbs: _totalCarbs,
                      fat: _totalFat,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Today's Food",
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ],
                ),
              ),
            ),
            if (_entries.isEmpty)
              const SliverFillRemaining(
                child:
                    Center(child: Text('No entries yet. Tap + to add food.')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _EntryTile(
                    entry: _entries[i],
                    onDelete: () async {
                      await _db.deleteLogEntry(_entries[i].id!);
                      _load();
                    },
                    onTap: () async {
                      await Navigator.push(
                          ctx,
                          MaterialPageRoute(
                              builder: (_) => LogEntryScreen(
                                    date: _today,
                                    existing: _entries[i],
                                  )));
                      _load();
                    },
                  ),
                  childCount: _entries.length,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => LogEntryScreen(date: _today)));
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  final int goal;
  final double consumed;
  final double remaining;
  final double progress;

  const _CalorieSummaryCard({
    required this.goal,
    required this.consumed,
    required this.remaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatColumn(label: 'Goal', value: goal.toString()),
                _StatColumn(
                  label: 'Consumed',
                  value: consumed.toStringAsFixed(0),
                  color: consumed > goal ? cs.error : null,
                ),
                _StatColumn(
                  label: 'Remaining',
                  value: remaining.toStringAsFixed(0),
                  color: remaining < 0 ? cs.error : cs.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                color: consumed > goal ? cs.error : cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatColumn({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text('kcal', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;

  const _MacroRow(
      {required this.protein, required this.carbs, required this.fat});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _MacroChip(
                label: 'Protein', value: protein, color: Colors.blue)),
        const SizedBox(width: 8),
        Expanded(
            child: _MacroChip(
                label: 'Carbs', value: carbs, color: Colors.orange)),
        const SizedBox(width: 8),
        Expanded(
            child:
                _MacroChip(label: 'Fat', value: fat, color: Colors.red)),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      // ignore: deprecated_member_use
      color: color.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 11)),
            Text(
              '${value.toStringAsFixed(1)}g',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final LogEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _EntryTile(
      {required this.entry, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(entry.name),
      subtitle: Text(
        'P: ${entry.totalProtein.toStringAsFixed(1)}g  '
        'C: ${entry.totalCarbs.toStringAsFixed(1)}g  '
        'F: ${entry.totalFat.toStringAsFixed(1)}g'
        '${entry.servings != 1.0 ? "  ×${entry.servings}" : ""}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${entry.totalCalories.toStringAsFixed(0)} kcal',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
