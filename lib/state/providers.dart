/// إدارة الحالة المركزية — Riverpod
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../data/audio_cache.dart';
import '../data/models.dart';
import '../data/preferences.dart';
import '../data/sample_data.dart';

final prefsProvider = Provider<PreferencesService>((ref) => PreferencesService.instance);

// ==================== المظهر ====================

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(PreferencesService.instance.themeMode);
  void set(ThemeMode m) {
    state = m;
    PreferencesService.instance.saveThemeMode(m);
  }
}

final fontScaleProvider =
    StateNotifierProvider<FontScaleNotifier, double>((ref) => FontScaleNotifier());

class FontScaleNotifier extends StateNotifier<double> {
  FontScaleNotifier() : super(PreferencesService.instance.fontScale);
  void set(double v) {
    state = v;
    PreferencesService.instance.saveFontScale(v);
  }
}

// ==================== المقرئ ====================

final reciterProvider =
    StateNotifierProvider<ReciterNotifier, Reciter>((ref) => ReciterNotifier());

class ReciterNotifier extends StateNotifier<Reciter> {
  ReciterNotifier() : super(Reciters.byId(PreferencesService.instance.reciterId));
  void set(Reciter r) {
    state = r;
    PreferencesService.instance.saveReciterId(r.id);
  }
}

// ==================== الإشارات المرجعية ====================

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<Bookmark>>((ref) => BookmarksNotifier());

class BookmarksNotifier extends StateNotifier<List<Bookmark>> {
  BookmarksNotifier() : super(PreferencesService.instance.bookmarks);

  void _persist() => PreferencesService.instance.saveBookmarks(state);

  void toggle(String verseKey, String type, {int colorIndex = 0}) {
    final i = state.indexWhere((b) => b.verseKey == verseKey && b.type == type);
    if (i >= 0) {
      state = [...state]..removeAt(i);
    } else {
      state = [
        ...state,
        Bookmark(
          id: DateTime.now().millisecondsSinceEpoch,
          verseKey: verseKey,
          type: type,
          colorIndex: colorIndex,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ];
    }
    _persist();
  }

  void updateNote(String verseKey, String note) {
    final i = state.indexWhere((b) => b.verseKey == verseKey);
    if (i >= 0) {
      final old = state[i];
      final updated = Bookmark(
        id: old.id,
        verseKey: old.verseKey,
        type: old.type,
        colorIndex: old.colorIndex,
        note: note,
        createdAt: old.createdAt,
      );
      state = [...state]..[i] = updated;
      _persist();
    } else if (note.isNotEmpty) {
      state = [
        ...state,
        Bookmark(
          id: DateTime.now().millisecondsSinceEpoch,
          verseKey: verseKey,
          type: 'bookmark',
          note: note,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ];
      _persist();
    }
  }

  void remove(int id) {
    state = state.where((b) => b.id != id).toList();
    _persist();
  }

  bool has(String verseKey, String type) =>
      state.any((b) => b.verseKey == verseKey && b.type == type);
}

// ==================== التمييز اللوني ====================

final highlightsProvider =
    StateNotifierProvider<HighlightsNotifier, Map<String, int>>((ref) => HighlightsNotifier());

class HighlightsNotifier extends StateNotifier<Map<String, int>> {
  HighlightsNotifier() : super(Map.of(PreferencesService.instance.highlights));

  void set(String verseKey, int colorIndex) {
    state = {...state, verseKey: colorIndex};
    PreferencesService.instance.saveHighlights(state);
  }

  void remove(String verseKey) {
    final m = {...state}..remove(verseKey);
    state = m;
    PreferencesService.instance.saveHighlights(m);
  }
}

// ==================== الملاحظات ====================

final notesProvider =
    StateNotifierProvider<NotesNotifier, Map<String, String>>((ref) => NotesNotifier());

class NotesNotifier extends StateNotifier<Map<String, String>> {
  NotesNotifier() : super(Map.of(PreferencesService.instance.notes));

  void set(String verseKey, String note) {
    final m = {...state};
    if (note.isEmpty) {
      m.remove(verseKey);
    } else {
      m[verseKey] = note;
    }
    state = m;
    PreferencesService.instance.saveNotes(m);
  }
}

// ==================== آخر قراءة ====================

final lastPageProvider =
    StateNotifierProvider<LastPageNotifier, int>((ref) => LastPageNotifier());

class LastPageNotifier extends StateNotifier<int> {
  LastPageNotifier() : super(PreferencesService.instance.lastPage);
  void set(int p) {
    if (p < 1 || p > 604) return;
    state = p;
    PreferencesService.instance.saveLastPage(p);
  }
}

// ==================== الختمة ====================

final khatmahProvider =
    StateNotifierProvider<KhatmahNotifier, Khatmah?>((ref) => KhatmahNotifier());

class KhatmahNotifier extends StateNotifier<Khatmah?> {
  KhatmahNotifier() : super(PreferencesService.instance.khatmah);

  void create(String title, DateTime target) {
    state = Khatmah(
      title: title,
      startDateMs: DateTime.now().millisecondsSinceEpoch,
      targetDateMs: target.millisecondsSinceEpoch,
    );
    _persist();
  }

  void readPages(double n) {
    final k = state;
    if (k == null) return;
    state = Khatmah(
      title: k.title,
      startDateMs: k.startDateMs,
      targetDateMs: k.targetDateMs,
      pagesRead: (k.pagesRead + n).clamp(0, 604),
      active: k.active,
    );
    _persist();
  }

  void delete() {
    state = null;
    PreferencesService.instance.saveKhatmah(null);
  }

  void _persist() => PreferencesService.instance.saveKhatmah(state);
}

// ==================== وضع القارئ ====================

enum ReaderMode { flip, scroll }

/// flip: تقليب أفقي صفحة-صفحة | scroll: تمرير عمودي صفحة-صفحة
final readerModeProvider =
    StateProvider<ReaderMode>((ref) => ReaderMode.flip);

// ==================== تخزين الصوتيات ====================

final audioCacheProvider =
    StateNotifierProvider<AudioCacheNotifier, Set<String>>(
        (ref) => AudioCacheNotifier());

class AudioCacheNotifier extends StateNotifier<Set<String>> {
  AudioCacheNotifier() : super({}) {
    refresh();
  }

  Future<void> refresh() async {
    state = await AudioCacheService.instance.listCached();
  }

  void markPresent(String k) => state = {...state, k};

  bool has(Reciter r, Verse v) =>
      state.contains(AudioCacheService.instance.key(r.id, v.surahId, v.ayah));

  /// تحميل آية للتشغيل دون إنترنت
  Future<bool> download(Reciter r, Verse v) async {
    final k = AudioCacheService.instance.key(r.id, v.surahId, v.ayah);
    if (state.contains(k)) return true;
    try {
      await AudioCacheService.instance.download(r, v);
      markPresent(k);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearAll() async {
    await AudioCacheService.instance.clearAll();
    state = {};
  }
}

// ==================== محرك الصوت ====================

class AudioState {
  final Verse? current;
  final bool playing;
  final bool loading;
  final int repeatAyah; // عدد مرات تكرار الآية (1 = بدون تكرار)
  final int sleepMinutes; // 0 = مطفأ
  final Duration position;
  final Duration duration;

  const AudioState({
    this.current,
    this.playing = false,
    this.loading = false,
    this.repeatAyah = 1,
    this.sleepMinutes = 0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioState copyWith({
    Verse? Function()? current,
    bool? playing,
    bool? loading,
    int? repeatAyah,
    int? sleepMinutes,
    Duration? position,
    Duration? duration,
  }) {
    return AudioState(
      current: current != null ? current() : this.current,
      playing: playing ?? this.playing,
      loading: loading ?? this.loading,
      repeatAyah: repeatAyah ?? this.repeatAyah,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

final audioProvider =
    StateNotifierProvider<AudioNotifier, AudioState>((ref) => AudioNotifier(ref));

class AudioNotifier extends StateNotifier<AudioState> {
  AudioNotifier(this.ref) : super(const AudioState()) {
    _init();
  }

  final Ref ref;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _stateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  Timer? _sleepTimer;
  Timer? _fadeTimer;
  int _playCount = 0;

  void _init() {
    _stateSub = _player.playerStateStream.listen((ps) async {
      if (ps.processingState == ProcessingState.completed) {
        await _onAyahCompleted();
      } else {
        state = state.copyWith(playing: ps.playing);
      }
    });
    _posSub = _player.positionStream.listen((p) => state = state.copyWith(position: p));
    _durSub = _player.durationStream
        .listen((d) => state = state.copyWith(duration: d ?? Duration.zero));
  }

  Future<void> playVerse(Verse verse) async {
    state = state.copyWith(current: () => verse, loading: true, playing: false);
    _playCount = 0;
    await _loadAndPlay(verse);
  }

  Future<void> _loadAndPlay(Verse verse) async {
    try {
      final reciter = ref.read(reciterProvider);
      // Offline-First: ملف محلي إن وُجد، وإلا بث مباشر
      final cached = await AudioCacheService.instance
          .getCached(reciter.id, verse.surahId, verse.ayah);
      if (cached != null) {
        await _player.setFilePath(cached.path);
      } else {
        await _player.setUrl(reciter.audioUrl(verse.surahId, verse.ayah));
      }
      await _player.play();
      state = state.copyWith(loading: false, playing: true);
    } catch (_) {
      // فشل التحميل (لا شبكة/الآية غير متوفرة صوتياً)
      state = state.copyWith(loading: false, playing: false);
    }
  }

  Future<void> _onAyahCompleted() async {
    final current = state.current;
    if (current == null) return;
    if (_playCount < state.repeatAyah - 1) {
      _playCount++;
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }
    await next();
  }

  Future<void> toggle() async {
    if (state.current == null) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> next() async {
    final current = state.current;
    if (current == null) return;
    final list = VerseData.playable;
    final i = list.indexWhere((v) => v.key == current.key);
    if (i >= 0 && i < list.length - 1) {
      await playVerse(list[i + 1]);
    } else {
      await stop();
    }
  }

  Future<void> prev() async {
    final current = state.current;
    if (current == null) return;
    final list = VerseData.playable;
    final i = list.indexWhere((v) => v.key == current.key);
    if (i > 0) {
      await playVerse(list[i - 1]);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = const AudioState(
      repeatAyah: 1,
      sleepMinutes: 0,
    );
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
  }

  void setRepeat(int n) {
    state = state.copyWith(repeatAyah: n.clamp(1, 10));
    _playCount = 0;
  }

  /// مؤقت النوم — إطفاء تدريجي للصوت
  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    if (minutes <= 0) {
      state = state.copyWith(sleepMinutes: 0);
      return;
    }
    state = state.copyWith(sleepMinutes: minutes);
    _sleepTimer = Timer(Duration(minutes: minutes), _fadeOutAndStop);
  }

  void _fadeOutAndStop() {
    const steps = 20;
    var i = 0;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 250), (t) async {
      i++;
      await _player.setVolume((1 - i / steps).clamp(0.0, 1.0));
      if (i >= steps) {
        t.cancel();
        await _player.pause();
        await _player.setVolume(1.0);
        state = state.copyWith(sleepMinutes: 0);
      }
    });
  }

  Future<void> seek(Duration d) => _player.seek(d);

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _sleepTimer?.cancel();
    _fadeTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}

// ==================== اللؤلؤة اليومية ====================

final wisdomProvider = Provider<WisdomCard>((ref) => WisdomData.today());
