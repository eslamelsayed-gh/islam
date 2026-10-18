/// نماذج البيانات الأساسية للتطبيق
library;

class SurahMeta {
  final int id;
  final String nameAr;
  final String nameEn;
  final int ayahCount;
  final String revelation; // مكية / مدنية
  final int startPage; // أول صفحة في مصحف المدينة

  const SurahMeta(this.id, this.nameAr, this.nameEn, this.ayahCount,
      this.revelation, this.startPage);

  int get juz => ((startPage - 1) ~/ 20) + 1;
}

class Verse {
  final int surahId;
  final int ayah;
  final int page;
  final String text;
  final String surahName;

  const Verse({
    required this.surahId,
    required this.ayah,
    required this.page,
    required this.text,
    required this.surahName,
  });

  /// مفتاح فريد مثل "2:255"
  String get key => '$surahId:$ayah';

  String get reference => '﴿ $surahName : ${surahName.isEmpty ? '' : ''}$ayah ﴾';
}

class Bookmark {
  final int id;
  final String verseKey;
  final String type; // bookmark | memorize | reflect | last_read
  final int colorIndex;
  final String note;
  final int createdAt;

  const Bookmark({
    required this.id,
    required this.verseKey,
    required this.type,
    this.colorIndex = 0,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'verseKey': verseKey,
        'type': type,
        'colorIndex': colorIndex,
        'note': note,
        'createdAt': createdAt,
      };

  factory Bookmark.fromJson(Map<String, dynamic> j) => Bookmark(
        id: j['id'] as int,
        verseKey: j['verseKey'] as String,
        type: j['type'] as String,
        colorIndex: (j['colorIndex'] as num?)?.toInt() ?? 0,
        note: (j['note'] as String?) ?? '',
        createdAt: (j['createdAt'] as num?)?.toInt() ?? 0,
      );
}

/// أنواع الإشارات المرجعية وأسماؤها العربية
const Map<String, String> bookmarkTypeLabels = {
  'bookmark': 'ورق',
  'memorize': 'حفظ',
  'reflect': 'تدبّر',
  'last_read': 'آخر قراءة',
};

class Khatmah {
  final String title;
  final int startDateMs;
  final int targetDateMs;
  final double pagesRead;
  final bool active;

  const Khatmah({
    required this.title,
    required this.startDateMs,
    required this.targetDateMs,
    this.pagesRead = 0,
    this.active = true,
  });

  double get progress => (pagesRead / 604).clamp(0.0, 1.0);

  /// الهدف اليومي الذكي — يُعاد توزيع المتبقي تلقائياً عند التأخر
  double dailyTarget(DateTime today) {
    final remaining = (604 - pagesRead).clamp(1, 604);
    final daysLeft = targetDateMs > today.millisecondsSinceEpoch
        ? DateTime.fromMillisecondsSinceEpoch(targetDateMs)
                .difference(today)
                .inDays +
            1
        : 1;
    return (remaining / daysLeft.clamp(1, 365)).clamp(1.0, 604.0);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'startDateMs': startDateMs,
        'targetDateMs': targetDateMs,
        'pagesRead': pagesRead,
        'active': active,
      };

  factory Khatmah.fromJson(Map<String, dynamic> j) => Khatmah(
        title: j['title'] as String,
        startDateMs: (j['startDateMs'] as num).toInt(),
        targetDateMs: (j['targetDateMs'] as num).toInt(),
        pagesRead: (j['pagesRead'] as num?)?.toDouble() ?? 0,
        active: (j['active'] as bool?) ?? true,
      );
}

class Reciter {
  final String id;
  final String name;
  final String folder; // مجلد everyayah.com

  const Reciter(this.id, this.name, this.folder);

  String audioUrl(int surah, int ayah) =>
      'https://everyayah.com/data/$folder/'
      '${surah.toString().padLeft(3, '0')}'
      '${ayah.toString().padLeft(3, '0')}.mp3';
}

class WisdomCard {
  final String id;
  final String type; // linguistic_gem | reflection | virtue
  final String title;
  final String body;
  final String verseRef;

  const WisdomCard({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.verseRef,
  });
}

enum SearchResultKind { verse, surah, page, juz }

class SearchResult {
  final SearchResultKind kind;
  final String title;
  final String subtitle;
  final Verse? verse;
  final SurahMeta? surah;
  final int? page;

  const SearchResult({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.verse,
    this.surah,
    this.page,
  });
}
