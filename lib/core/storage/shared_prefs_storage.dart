import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage.dart';

/// Concrete [LocalStorage] implementation backed by [SharedPreferences].
/// Use for non-sensitive data (preferences, onboarding flags, cached user data).
///
/// For sensitive data (tokens), replace or extend this with
/// `flutter_secure_storage` when integrating a real auth backend.
class SharedPrefsStorage implements LocalStorage {
  SharedPrefsStorage._();

  static SharedPrefsStorage? _instance;
  static SharedPreferences? _prefs;

  /// Call once in [main] before [runApp] to warm-up the instance.
  static Future<SharedPrefsStorage> getInstance() async {
    if (_instance == null) {
      _prefs = await SharedPreferences.getInstance();
      _instance = SharedPrefsStorage._();
    }
    return _instance!;
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'SharedPrefsStorage not initialized. Call getInstance() first.');
    return _prefs!;
  }

  // ── String ──────────────────────────────────────────────────────────────
  @override
  Future<void> setString(String key, String value) => _p.setString(key, value);

  @override
  Future<String?> getString(String key) async => _p.getString(key);

  // ── Bool ─────────────────────────────────────────────────────────────────
  Future<void> setBool(String key, {required bool value}) => _p.setBool(key, value);

  Future<bool?> getBool(String key) async => _p.getBool(key);

  // ── Remove / Clear ───────────────────────────────────────────────────────
  @override
  Future<void> remove(String key) => _p.remove(key);

  @override
  Future<void> clear() => _p.clear();
}
