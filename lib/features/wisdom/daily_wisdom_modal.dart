/// اللؤلؤة اليومية — Modal يظهر عند فتح التطبيق مرة واحدة يومياً
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models.dart';

void showDailyWisdom(BuildContext context, WisdomCard card) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: _WisdomCardView(card: card),
    ),
  );
}

class _WisdomCardView extends ConsumerWidget {
  final WisdomCard card;

  const _WisdomCardView({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = dark ? AppColors.darkGold : AppColors.gold;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: gold.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: gold, size: 20),
              const SizedBox(width: 8),
              Text('لؤلؤة اليوم',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: gold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(card.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(card.body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(card.verseRef,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: gold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('مشاركة'),
                onPressed: () => Share.share('${card.title}\n\n${card.body}\n\n— ${card.verseRef}\n\nvia تطبيق إسلام'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('تدبّر'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
