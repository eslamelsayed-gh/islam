/// صفحة المصحف — إطار المدينة + الآيات أو بطاقة العرض
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/arabic.dart';
import '../../../data/models.dart';
import '../../../data/sample_data.dart';
import '../../../state/providers.dart';
import 'verse_action_sheet.dart';

class MushafPage extends ConsumerWidget {
  final int pageNumber;
  final double fontScale;

  const MushafPage({
    super.key,
    required this.pageNumber,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verses = VerseData.byPage(pageNumber);
    final starting = SurahData.startsAt(pageNumber);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final ink = dark ? AppColors.darkInk : AppColors.ink;

    // حجم الخط حسب كثافة الصفحة — الصفحات القرآنية 15 سطراً في الأصل
    final baseSize = verses.isEmpty
        ? 0.0
        : verses.length <= 3
            ? 26.0
            : verses.length <= 8
                ? 22.0
                : 18.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: gold.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // الإطار الداخلي المزدوج (طابع مصحف المدينة)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: gold.withOpacity(0.35)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: verses.isEmpty
                    ? _PlaceholderPage(
                        pageNumber: pageNumber,
                        gold: gold,
                        ink: ink,
                        starting: starting,
                      )
                    : Column(
                        children: [
                          if (starting != null)
                            _SurahBanner(surah: starting, gold: gold),
                          if (pageNumber == 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 20 * fontScale,
                                  color: gold,
                                  fontWeight: FontWeight.w600,
                                  height: 1.8,
                                ),
                              ),
                            ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final v in verses)
                                    VerseLine(
                                      verse: v,
                                      fontSize: baseSize * fontScale,
                                      ink: ink,
                                      gold: gold,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            // رقم الصفحة أسفل الوسط
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: gold.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    toArabicDigits(pageNumber),
                    style: TextStyle(
                      fontSize: 13,
                      color: gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// سطر آية واحد — ضغطة مطوّلة تفتح نافذة الإجراءات
class VerseLine extends ConsumerWidget {
  final Verse verse;
  final double fontSize;
  final Color ink;
  final Color gold;

  const VerseLine({
    super.key,
    required this.verse,
    required this.fontSize,
    required this.ink,
    required this.gold,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlight = ref.watch(highlightsProvider)[verse.key];
    final note = ref.watch(notesProvider)[verse.key];
    // تمييز الآية الجاري تشغيلها صوتياً
    final isPlaying = ref.watch(audioProvider
        .select((s) => s.current?.key == verse.key && (s.playing || s.loading)));

    return GestureDetector(
      onLongPress: () => showVerseActionSheet(context, verse),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: highlight != null
              ? AppColors.highlightColors[highlight % AppColors.highlightColors.length]
                  .withOpacity(0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isPlaying
              ? Border.all(color: AppColors.emerald, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: verse.text,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: ink,
                      height: 2.0,
                      fontFamily: 'KFGQPC_Uthmanic_Script', // يُفعّل تلقائياً عند إضافة الخط
                    ),
                  ),
                  TextSpan(
                    text: ' ﴿${toArabicDigits(verse.ayah)}﴾ ',
                    style: TextStyle(
                      fontSize: fontSize * 0.75,
                      color: gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
            if (note != null && note.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4, right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(right: BorderSide(color: gold, width: 3)),
                ),
                child: Text(
                  note,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: fontSize * 0.62, color: ink.withOpacity(0.85), height: 1.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ترويسة السورة — زخرفة ذهبية
class _SurahBanner extends StatelessWidget {
  final SurahMeta surah;
  final Color gold;

  const _SurahBanner({required this.surah, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: gold.withOpacity(0.6), width: 1.5),
          bottom: BorderSide(color: gold.withOpacity(0.6), width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 5, color: gold),
          const SizedBox(width: 10),
          Text(
            'سورة ${surah.nameAr}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: gold,
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.circle, size: 5, color: gold),
        ],
      ),
    );
  }
}

/// الصفحات غير المحمّلة في النسخة التجريبية
class _PlaceholderPage extends StatelessWidget {
  final int pageNumber;
  final Color gold;
  final Color ink;
  final SurahMeta? starting;

  const _PlaceholderPage({
    required this.pageNumber,
    required this.gold,
    required this.ink,
    this.starting,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (starting != null) ...[
            Text('سورة ${starting!.nameAr}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: gold)),
            const SizedBox(height: 6),
            Text('${starting!.revelation} • ${toArabicDigits(starting!.ayahCount)} آية',
                style: TextStyle(fontSize: 13, color: ink.withOpacity(0.7))),
            const SizedBox(height: 24),
          ],
          Text('﴿ ${toArabicDigits(pageNumber)} ﴾',
              style: TextStyle(fontSize: 34, color: gold.withOpacity(0.8))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'نص هذه الصفحة يُضمَّن من قاعدة بيانات مصحف المدينة في النسخة الكاملة\n(٦٠٤ صفحات مطابقة للمصحف الأم)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: ink.withOpacity(0.55), height: 1.8),
            ),
          ),
        ],
      ),
    );
  }
}
