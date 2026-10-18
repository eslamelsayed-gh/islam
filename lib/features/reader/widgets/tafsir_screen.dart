/// صفحة التفسير المستقلة — تدبّر كامل للآية
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/arabic.dart';
import '../../../data/models.dart';
import '../../../data/sample_data.dart';

class TafsirScreen extends StatelessWidget {
  final Verse verse;

  const TafsirScreen({super.key, required this.verse});

  static const _books = [
    ('السعدي — مختصر', true),
    ('ابن كثير', false),
    ('الطبري', false),
    ('في ظلال القرآن', false),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final ink = dark ? AppColors.darkInk : AppColors.ink;
    final tafsir = TafsirData.get(verse.key);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('التفسير والتدبّر')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // الآية بتكبير تدبّري
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withOpacity(0.35)),
            ),
            child: Column(
              children: [
                Text(
                  verse.text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontSize: 24, color: ink, height: 2.1, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: gold.withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '﴿ ${verse.surahName} — ${toArabicDigits(verse.ayah)} ﴾',
                    style: TextStyle(
                        fontSize: 13, color: gold, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // كتب التفسير
          Text('مصادر التفسير', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final (name, available) in _books)
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                dense: true,
                leading: Icon(
                  available ? Icons.check_circle : Icons.lock_outline,
                  size: 18,
                  color: available ? AppColors.emerald : AppColors.muted,
                ),
                title: Text(name,
                    style: TextStyle(
                      fontSize: 14,
                      color: available ? ink : AppColors.muted,
                    )),
                subtitle: available
                    ? const Text('متاح الآن', style: TextStyle(fontSize: 11))
                    : const Text('يُتاح في تحديث قادم',
                        style: TextStyle(fontSize: 11)),
              ),
            ),
          const SizedBox(height: 12),
          // نص التفسير
          Text('مختصر تفسير السعدي', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border(
                right: BorderSide(color: gold, width: 4),
              ),
            ),
            child: Text(
              tafsir ??
                  'سيُتاح التفسير الكامل لهذه الآية عند اكتمال قاعدة بيانات التفاسير في النسخة النهائية.',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 16, color: ink, height: 2.0),
            ),
          ),
        ],
      ),
    );
  }
}
