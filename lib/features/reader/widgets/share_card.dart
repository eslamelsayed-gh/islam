/// بطاقة مشاركة الآية — تُرسم محلياً وتُلتقط كصورة PNG
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/arabic.dart';
import '../../../data/models.dart';

class AyahShareCard extends StatelessWidget {
  final Verse verse;

  const AyahShareCard({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDFCF7), Color(0xFFF3EDDD)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.55), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('﴿ ﴾', style: TextStyle(fontSize: 20, color: AppColors.gold)),
          const SizedBox(height: 12),
          Text(
            verse.text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 21,
              color: AppColors.ink,
              height: 2.1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold.withOpacity(0.6)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '﴿ ${verse.surahName} — ${toArabicDigits(verse.ayah)} ﴾',
              style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 4, color: AppColors.gold.withOpacity(0.7)),
              const SizedBox(width: 8),
              const Text('إسلام — رَفِيقُكَ فِي تَدَبُّرِ كِتَابِ الله',
                  style: TextStyle(fontSize: 10, color: AppColors.muted)),
              const SizedBox(width: 8),
              Icon(Icons.circle, size: 4, color: AppColors.gold.withOpacity(0.7)),
            ],
          ),
        ],
      ),
    );
  }
}
