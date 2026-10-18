/// الفهرس — تبويبان: السور (114) والأجزاء (30)
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/arabic.dart';
import '../../data/sample_data.dart';
import '../reader/mushaf_reader_screen.dart';

class SurahIndexScreen extends StatelessWidget {
  const SurahIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفهرس'),
          bottom: TabBar(
            labelColor: accent,
            unselectedLabelColor:
                dark ? AppColors.darkMuted : AppColors.muted,
            indicatorColor: accent,
            tabs: const [
              Tab(text: 'السور'),
              Tab(text: 'الأجزاء'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ===== السور =====
            ListView.builder(
              itemCount: SurahData.list.length,
              itemBuilder: (_, i) {
                final s = SurahData.list[i];
                return Card(
                  elevation: 0,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gold.withOpacity(0.5)),
                      ),
                      child: Text(toArabicDigits(s.id),
                          style: TextStyle(
                              fontSize: 13,
                              color: gold,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text('سورة ${s.nameAr}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${s.revelation} • ${toArabicDigits(s.ayahCount)} آية • جزء ${toArabicDigits(s.juz)} • صفحة ${toArabicDigits(s.startPage)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 11),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              MushafReaderScreen(initialPage: s.startPage)),
                    ),
                  ),
                );
              },
            ),
            // ===== الأجزاء =====
            ListView.builder(
              itemCount: 30,
              itemBuilder: (_, i) {
                final startPage = i * 20 + 1;
                final endPage = (i + 1) * 20;
                return Card(
                  elevation: 0,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withOpacity(0.5)),
                      ),
                      child: Text(toArabicDigits(i + 1),
                          style: TextStyle(
                              fontSize: 13,
                              color: accent,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text('الجزء ${toArabicDigits(i + 1)}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'من صفحة ${toArabicDigits(startPage)} إلى ${toArabicDigits(endPage > 604 ? 604 : endPage)} • يبدأ بسورة ${SurahData.nameForPage(startPage)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 11),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              MushafReaderScreen(initialPage: startPage)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
