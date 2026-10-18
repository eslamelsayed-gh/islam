/// البحث الفوري — آيات + سور + صفحات + أجزاء (تطبيع عربي كامل)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/arabic.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../reader/mushaf_reader_screen.dart';

final _queryProvider = StateProvider<String>((ref) => '');

final _resultsProvider = Provider<List<SearchResult>>((ref) {
  final raw = ref.watch(_queryProvider);
  final q = normalizeArabic(raw);
  if (q.isEmpty) return [];

  final results = <SearchResult>[];

  // 1) آيات (في النسخة التجريبية: الآيات المحمّلة — النهائية: FTS5 على 6236 آية)
  for (final v in VerseData.verses) {
    if (normalizeArabic(v.text).contains(q) ||
        normalizeArabic(v.surahName).contains(q)) {
      results.add(SearchResult(
        kind: SearchResultKind.verse,
        title: v.text,
        subtitle: '${v.surahName} • ${toArabicDigits(v.ayah)} • صفحة ${toArabicDigits(v.page)}',
        verse: v,
      ));
    }
  }

  // 2) سور
  for (final s in SurahData.list) {
    if (normalizeArabic(s.nameAr).contains(q) ||
        s.nameEn.toLowerCase().contains(q) ||
        '${s.id}' == q) {
      results.add(SearchResult(
        kind: SearchResultKind.surah,
        title: 'سورة ${s.nameAr}',
        subtitle: '${s.revelation} • ${toArabicDigits(s.ayahCount)} آية • صفحة ${toArabicDigits(s.startPage)}',
        surah: s,
        page: s.startPage,
      ));
    }
  }

  // 3) رقم صفحة أو جزء مباشر
  final num = int.tryParse(q);
  if (num != null) {
    if (num >= 1 && num <= 604) {
      results.insert(0, SearchResult(
        kind: SearchResultKind.page,
        title: 'الانتقال إلى الصفحة ${toArabicDigits(num)}',
        subtitle: SurahData.nameForPage(num).isEmpty ? '' : 'سورة ${SurahData.nameForPage(num)}',
        page: num,
      ));
    }
    if (num >= 1 && num <= 30) {
      results.insert(1, SearchResult(
        kind: SearchResultKind.juz,
        title: 'الجزء ${toArabicDigits(num)}',
        subtitle: 'يبدأ من الصفحة ${toArabicDigits((num - 1) * 20 + 1)}',
        page: (num - 1) * 20 + 1,
      ));
    }
  }

  return results.take(60).toList();
});

class SearchScreen extends ConsumerStatefulWidget {
  /// embedded: داخل شريط التنقل السفلي (بدون AppBar)
  final bool embedded;

  const SearchScreen({super.key, this.embedded = false});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final results = ref.watch(_resultsProvider);
    final query = ref.watch(_queryProvider);

    final body = Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, widget.embedded ? 16 : 8, 16, 8),
          child: TextField(
            controller: _ctrl,
            textDirection: TextDirection.rtl,
            autofocus: !widget.embedded,
            decoration: InputDecoration(
              hintText: 'ابحث في القرآن، السور، الصفحات…',
              hintTextDirection: TextDirection.rtl,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _ctrl.clear();
                        ref.read(_queryProvider.notifier).state = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => ref.read(_queryProvider.notifier).state = v,
          ),
        ),
        Expanded(
          child: query.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'جرّب: «الكرسي» • «يس» • «٥٦٢» لصفحة • «٣٠» لجزء',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              : results.isEmpty
                  ? const Center(child: Text('لا توجد نتائج'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final r = results[i];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: Icon(
                              switch (r.kind) {
                                SearchResultKind.verse => Icons.format_quote,
                                SearchResultKind.surah => Icons.auto_awesome,
                                SearchResultKind.page => Icons.menu_book,
                                SearchResultKind.juz => Icons.library_books,
                              },
                              color: r.kind == SearchResultKind.verse
                                  ? accent
                                  : gold,
                              size: 20,
                            ),
                            title: Text(r.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, height: 1.7)),
                            subtitle: Text(r.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 11)),
                            onTap: r.page == null
                                ? null
                                : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MushafReaderScreen(initialPage: r.page!),
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('البحث')), body: body);
  }
}
