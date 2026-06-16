# Calorie Tracker

A personal, offline-only calorie tracking app built with Flutter and SQLite.

## Features

- Set and edit a daily calorie goal
- Log food entries with name, calories, protein, carbs, fat, and servings
- Save foods as reusable presets (pick without retyping)
- Today screen: progress bar, calories consumed vs goal, macro totals
- Browse and edit past days
- Manage presets: add, edit, delete

## Setup

1. **Clone and checkout**
   ```bash
   git clone <repo-url>
   cd <repo-name>
   git checkout claude/flutter-calorie-tracker-ktxf15
   ```

2. **Generate missing platform files** (launcher icons, iOS config, etc.)
   ```bash
   flutter create . --project-name calorie_tracker --org com.example
   ```
   This generates missing files without overwriting your source code.

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run**
   ```bash
   flutter run
   ```

## Project structure

```
lib/
  main.dart                      # App entry point & bottom-nav shell
  models/
    food.dart                    # Food preset model
    log_entry.dart               # Log entry model (stores own values)
  data/
    database_helper.dart         # SQLite layer (sqflite)
  screens/
    today_screen.dart            # Dashboard: goal, progress, macros
    log_entry_screen.dart        # Add / edit a food log entry
    presets_screen.dart          # Manage reusable food presets
    history_screen.dart          # Browse past days
    settings_screen.dart         # Edit daily calorie goal
```

## Data model

| Table | Columns |
|---|---|
| `foods` | id, name, calories, protein\_g, carbs\_g, fat\_g |
| `log_entries` | id, date, name, calories, protein\_g, carbs\_g, fat\_g, servings |
| `settings` | key, value |

Log entries store their own nutritional values so editing a preset never changes history.
