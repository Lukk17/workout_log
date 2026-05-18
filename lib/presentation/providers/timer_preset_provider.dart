import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _key = 'timer_preset_seconds';
const Duration _default = Duration(seconds: 60);

class _TimerPresetNotifier extends StateNotifier<Duration> {
  _TimerPresetNotifier() : super(_default) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_key);
    if (stored != null && stored > 0) {
      state = Duration(seconds: stored);
    }
  }

  Future<void> set(Duration value) async {
    if (value.inSeconds <= 0) return;
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, value.inSeconds);
  }
}

final timerPresetProvider =
    StateNotifierProvider<_TimerPresetNotifier, Duration>(
        (ref) => _TimerPresetNotifier());
