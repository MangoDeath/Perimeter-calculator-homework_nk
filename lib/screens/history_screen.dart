import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import '../models/log_entry.dart';
import 'log_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _db = DatabaseHelper();
  List<String> _dates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = await _db.getLoggedDates();
    if (mounted) setState(() => _dates = dates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _dates.isEmpty
          ? const Center(child: Text('No history yet.'))
          : ListView.builder(
              itemCount: _dates.length,
              itemBuilder: (_, i) =>
                  _DayTile(date: _dates[i], onChanged: _load),
            ),
    );
  }
}

class _DayTile extends StatefulWidget {
  final String date;
  final VoidCallback onChanged;

  const _DayTile({required this.date, required this.onChanged});

  @override
  State<_DayTile> createState() => _DayTileState();
}

class _DayTileState extends State<_DayTile> {
  final _db = DatabaseHelper();
  List<LogEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _db.getEntriesForDate(widget.date);
    if (mounted) setState(() => _entries = entries);
  }

  double get _totalCalories =>
      _entries.fold(0, (s, e) => s + e.totalCalories);

  String _fmtDate(String date) =>
      DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(date));

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text(_fmtDate(widget.date)),
        subtitle: Text(
            '${_totalCalories.toStringAsFixed(0)} kcal · ${_entries.length} items'),
        children: [
          ..._entries.map(
            (e) => ListTile(
              dense: true,
              title: Text(e.name),
              subtitle: Text(
                'P:${e.totalProtein.toStringAsFixed(1)}g  '
                'C:${e.totalCarbs.toStringAsFixed(1)}g  '
                'F:${e.totalFat.toStringAsFixed(1)}g'
                '${e.servings != 1.0 ? "  ×${e.servings}" : ""}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${e.totalCalories.toStringAsFixed(0)} kcal'),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LogEntryScreen(
                                    date: widget.date,
                                    existing: e,
                                  )));
                      _load();
                      widget.onChanged();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () async {
                      await _db.deleteLogEntry(e.id!);
                      _load();
                      widget.onChanged();
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add entry'),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              LogEntryScreen(date: widget.date)));
                  _load();
                  widget.onChanged();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
