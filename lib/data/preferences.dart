/// طبقة التخزين المحلي (SharedPreferences) — Offline-First
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class PreferencesService {
  static late final PreferencesService instance;

  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    instance = PreferencesService._(sp);
  }

  final SharedPreferences _sp;

  PreferencesService._(this._sp);

  static const _kTheme = 'theme_mode';
  static const _kFont = 'font_scale';
  static const _kReciter = 'reciter_id';
  static const _kBookmarks = 'bookmarks';
  static const _kHighlights = 'highlights';
  static const _kNotes = 'notes';
  static const _kLastPage = 'last_page';
  static const _kKhatmah = 'khatmah';
  static const _kOnboarding = 'onboarding_done';
  static const _kWisdom = 'wisdom_date';

  // ---------- المظهر ----------
  ThemeMode get themeMode {
    final i = _sp.getInt(_kTheme);
    return (i != null && i < ThemeMode.values.length) ? ThemeMode.values[i] : ThemeMode.system;
  }

  void saveThemeMode(ThemeMode m) => _sp.setInt(_kTheme, m.index);

  double get fontScale => _sp.getDouble(_kFont) ?? 1.0;
  void saveFontScale(double v) => _sp.setDouble(_kFont, v);

  // ---------- الصوت ----------
  String get reciterId => _sp.getString(_kReciter) ?? 'minshawi';
  void saveReciterId(String id) => _sp.setString(_kReciter, id);

  // ---------- الإشارات ----------
  List<Bookmark> get bookmarks {
    final raw = _sp.getString(_kBookmarks);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void saveBookmarks(List<Bookmark> list) =>
      _sp.setString(_kBookmarks, jsonEncode(list.map((b) => b.toJson()).toList()));

  // ---------- التمييز اللوني ----------
  Map<String, int> get highlights {
    final raw = _sp.getString(_kHighlights);
    if (raw == null || raw.isEmpty) return {};
    try {
      return (jsonDecode(raw) as Map)
          .map((k, v) => MapEntry(k as String, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  void saveHighlights(Map<String, int> map) => _sp.setString(_kHighlights, jsonEncode(map));

  // ---------- الملاحظات ----------
  Map<String, String> get notes {
    final raw = _sp.getString(_kNotes);
    if (raw == null || raw.isEmpty) return {};
    try {
      return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k as String, v as String));
    } catch (_) {
      return {};
    }
  }

  void saveNotes(Map<String, String> map) => _sp.setString(_kNotes, jsonEncode(map));

  // ---------- آخر صفحة ----------
  int get lastPage => _sp.getInt(_kLastPage) ?? 1;
  void saveLastPage(int p) => _sp.setInt(_kLastPage, p);

  // ---------- الختمة ----------
  Khatmah? get khatmah {
    final raw = _sp.getString(_kKhatmah);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Khatmah.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  void saveKhatmah(Khatmah? k) =>
      _sp.setString(_kKhatmah, k == null ? '' : jsonEncode(k.toJson()));

  /// مسح كل بيانات المستخدم (إعادة التعيين)
  Future<void> clearAll() async {
    await _sp.clear();
  }

  // ---------- الدخول الأول ----------
  bool get onboardingDone => _sp.getBool(_kOnboarding) ?? false;
  void setOnboardingDone() => _sp.setBool(_kOnboarding, true);

  // ---------- اللؤلؤة اليومية ----------
  String? get wisdomDate => _sp.getString(_kWisdom);
  void setWisdomDate(String d) => _sp.setString(_kWisdom, d);
}
