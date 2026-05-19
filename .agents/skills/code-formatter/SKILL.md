---
name: code-formatter
description: Universal source-code formatting patterns the project owner expects, opinionated about visual hierarchy and reading flow rather than line length. Intentionally diverges from default auto-formatters (gofmt, dart format, black, google-java-format) in specific places — see each rule.
origin: workout_log
---

# Code Formatter

## When to Activate

Apply these patterns when:

- Writing new source files (any language).
- Editing existing files — match the rules when the file is already in this style; don't silently auto-format an unrelated file.
- Reviewing a PR or a teammate's branch and flagging readability issues.

These rules are about *visual hierarchy* — how a reader's eyes find the
landmarks of a function — not about line length or column alignment.
Default tooling tends to optimise for line length and consistency;
this skill optimises for "the next person reading this can locate
the control-flow exits and async phase transitions in one scan."

## The 10 Rules

### 1. Brace every inline `if (x) return y;` / `if (x) throw z;`

A control-flow exit should never share a line with its condition.
Multi-line, braced, body indented.

```dart
// Dart — wrong
if (rows.isEmpty) return null;

// Dart — right
if (rows.isEmpty) {
  return null;
}
```

```java
// Java — wrong
if (rows.isEmpty()) return null;

// Java — right
if (rows.isEmpty()) {
    return null;
}
```

```python
# Python — wrong
if not rows: return None

# Python — right
if not rows:
    return None
```

### 2. Empty lines around `try` / `catch` / `finally` blocks

`try` is a control-flow landmark. Give it room to breathe before and
after so the eye treats it as a phase, not a wall of text.

```dart
// Dart
final messenger = ScaffoldMessenger.of(context);

try {
  await service.backup();

  if (!mounted) {
    return;
  }

  messenger.showSnackBar(const SnackBar(content: Text('Backup created.')));
} on BackupException catch (e) {
  if (!mounted) {
    return;
  }

  messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
}
```

```java
// Java
final var logger = LoggerFactory.getLogger(getClass());

try {
    service.backup();

    logger.info("backup complete");
} catch (BackupException e) {
    logger.error("backup failed", e);
}
```

```python
# Python
logger = logging.getLogger(__name__)

try:
    service.backup()

    logger.info("backup complete")
except BackupError as e:
    logger.error("backup failed: %s", e)
```

### 3. Empty line above significant standalone `await` / async I/O calls

When an async call marks a phase transition in a function (setup →
I/O → cleanup), give the I/O line a blank above. This applies to
**standalone** awaits, not awaits that are part of a line-wrapped
assignment (see rule 4).

```dart
// Dart
state = state.copyWith(running: true);

await _gateway.show(id: 1001, title: 'Rest over', body: 'Time to lift');

logFine('alarm fired', name: _tag);
```

```java
// Java
state = state.toBuilder().running(true).build();

CompletableFuture<Void> shown = gateway.show(1001, "Rest over", "Time to lift");

logger.info("alarm fired");
```

```python
# Python
state.running = True

await gateway.show(id=1001, title="Rest over", body="Time to lift")

logger.info("alarm fired")
```

### 4. If `final x = await ...` doesn't fit one line, extract a local

The auto-formatter will break at `=` and leave `await` orphaned on the
next line. That is unreadable. The fix is to shorten the right-hand
side by extracting a local, not to accept the wrap.

```dart
// Dart — wrong (formatter-imposed wrap at =)
final exercise =
    await _exerciseDao.getById(rows.first['exercise_id'].toString());

// Dart — right (extract the long argument)
final exerciseId = rows.first['exercise_id'].toString();
final exercise = await _exerciseDao.getById(exerciseId);
```

```java
// Java — same pattern
String exerciseId = rows.getFirst().get("exercise_id").toString();
Exercise exercise = exerciseDao.getById(exerciseId);
```

```python
# Python
exercise_id = rows[0]["exercise_id"]
exercise = await exercise_dao.get_by_id(exercise_id)
```

### 5. Empty line above `return` when it ends a multi-statement block

When a function does several things and then returns, the `return`
gets a blank line above so it reads as "and now hand back the result"
rather than blending into the last statement. Doesn't apply to single-
statement bodies or arrow / one-line functions.

```dart
// Dart
Future<void> _addWorkLog(Exercise e, DateTime date) async {
  final list = await _dao.getForDate(date);

  for (final w in list) {
    if (w.exercise.name == e.name) {
      await _dao.merge(w);

      return;
    }
  }

  await _dao.insert(WorkLog.create(exercise: e, on: date));
}
```

```java
// Java
public Optional<WorkLog> findFor(Exercise e, LocalDate date) {
    var list = dao.getForDate(date);

    for (var w : list) {
        if (w.exercise().name().equals(e.name())) {
            dao.merge(w);

            return Optional.of(w);
        }
    }

    return Optional.empty();
}
```

```python
# Python
async def add_work_log(exercise: Exercise, date: date) -> None:
    existing = await dao.get_for_date(date)

    for w in existing:
        if w.exercise.name == exercise.name:
            await dao.merge(w)

            return

    await dao.insert(WorkLog.create(exercise=exercise, on=date))
```

### 6. Empty line above operation-terminating calls

Calls that *end* a phase — navigation pops, popups, state assignments,
timer cancels, log lines that mark phase boundaries — get a blank
line above. Same intent as rule 5: the eye should see "the act"
separated from the local-var arithmetic that prepared for it.

Examples of operation-terminators:

- `Navigator.pop(context)`, `navigator.push(...)`
- `ScaffoldMessenger.of(context).showSnackBar(...)`
- `state = state.copyWith(...)` (Riverpod / BLoC state mutation)
- `_ticker?.cancel()`
- `logFine('phase done', name: _tag)` — log lines that are explicit phase markers

```dart
// Dart
final normalized = _startOfDay(day);
ref.read(selectedDateProvider.notifier).state = normalized;
logFine('Chosen date: $normalized', name: _tag);

Navigator.of(context).pop();
```

```java
// Java
var normalized = startOfDay(day);
state.setSelectedDate(normalized);
logger.info("Chosen date: {}", normalized);

dialog.dismiss();
```

```python
# Python
normalized = start_of_day(day)
state.selected_date = normalized
logger.info("Chosen date: %s", normalized)

dialog.dismiss()
```

### 7. Comments on their own line above the code they describe

Never trailing. Trailing comments get truncated by long lines and
force horizontal scrolling.

```dart
// Dart — wrong
final delay = computeBackoff(retryCount); // exponential, max 30s

// Dart — right
// Exponential backoff, capped at 30s to avoid hammering the server.
final delay = computeBackoff(retryCount);
```

```java
// Java — wrong
var delay = computeBackoff(retryCount); // exponential, max 30s

// Java — right
// Exponential backoff, capped at 30s to avoid hammering the server.
var delay = computeBackoff(retryCount);
```

```python
# Python — wrong
delay = compute_backoff(retry_count)  # exponential, max 30s

# Python — right
# Exponential backoff, capped at 30s to avoid hammering the server.
delay = compute_backoff(retry_count)
```

Exception: throwaway tag comments like `// TODO(ABC-123): ...` may
trail in some communities — but even then, prefer the comment above.

### 8. One concept per blank-line-separated paragraph inside a function body

Related lines stick together with no blank between them; a topic
transition gets one blank. Two blank lines anywhere inside a function
body is a smell — extract a method.

```dart
// Dart — well-paragraphed
Future<void> save() async {
  final navigator = Navigator.of(context);
  final selectedDate = ref.read(selectedDateProvider);

  final updated = widget.exercise!.copyWith(
    name: _nameController.text,
    bodyParts: form.primary,
  );
  await _dao.replace(updated);

  if (!mounted) {
    return;
  }

  ref.invalidate(exercisesProvider);

  navigator.pop();
}
```

Each paragraph: setup, build + persist, mounted-guard, invalidate,
exit.

### 9. Method chains: line-break before each `.`

Fluent / functional pipelines (filter, map, reduce, take, toList)
read top-down, one transformation per line. Easier to diff, easier
to insert / remove a step.

```dart
// Dart
final activeNames = exercises
    .where((e) => e.isActive)
    .map((e) => e.name)
    .toList();
```

```java
// Java — Stream API
var activeNames = exercises.stream()
    .filter(Exercise::isActive)
    .map(Exercise::name)
    .toList();
```

```python
# Python — list comprehensions are the idiomatic equivalent
active_names = [e.name for e in exercises if e.is_active]

# When using a chain (rare in Python — usually a comprehension is
# better), still one transformation per line:
active_names = (
    pipe(exercises)
    .filter(lambda e: e.is_active)
    .map(lambda e: e.name)
    .to_list()
)
```

The point isn't "always use streams" — that's a coding-standards
question (see the related skill). The formatter point is: *when*
you do chain, one step per line.

### 10. Single-expression bodies stay on one line

The blank-line rules in this skill apply to *blocks*, not arrow
functions or one-line `def`s. Don't expand a pure transformation
into a multi-line function body just to satisfy a "blank line above
return" rule that doesn't apply.

```dart
// Dart — right
int doubled(int x) => x * 2;
DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
```

```java
// Java — right
record Exercise(String id, String name) {
    boolean isActive() { return !name.isBlank(); }
}

Function<Integer, Integer> doubled = x -> x * 2;
```

```python
# Python — right (def preferred over lambda for named functions)
def doubled(x: int) -> int:
    return x * 2

# inline lambda only when passing as an argument
sorted(items, key=lambda i: i.priority)
```

## What This Skill Does Not Cover

- Naming conventions, class-member ordering, import ordering — those
  vary per language. See language-specific style guides (PEP 8,
  Google Java Style, effective Dart) and the `coding-standards`
  skill.
- Line length caps — kept readable by extracting locals (rule 4)
  rather than wrapping. Each project sets its own column budget.
- Trailing commas, brace placement, indent width — handled by the
  default formatter for each language; we don't override.

## How This Interacts With Default Formatters

These rules **intentionally** disagree with default auto-formatters in
specific places — most notably rules 1, 2, 3, 5, 6. Running
`dart format` / `black` / `google-java-format` on a file written in
this style will revert some of these patterns.

Project-level enforcement (e.g. a `--set-exit-if-changed` CI gate)
should be **disabled** for files in this style. Static analysis
(lint, mypy, dart analyze) still applies and is the gate that
matters — the formatter just adjusts visual hierarchy.
