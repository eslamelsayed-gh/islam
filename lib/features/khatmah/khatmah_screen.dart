/// الختمة — هدف ذكي يُعاد توزيعه تلقائياً عند التأخر
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/arabic.dart';
import '../home/widgets/progress_ring.dart';
import '../../state/providers.dart';

class KhatmahScreen extends ConsumerWidget {
  const KhatmahScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController(text: 'ختمة رمضان');
    DateTime target = DateTime.now().add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: target,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !context.mounted) return;
    target = picked;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ختمة جديدة'),
        content: TextField(
          controller: titleCtrl,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(labelText: 'اسم الختمة'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ابدأ')),
        ],
      ),
    );
    if (ok == true) {
      ref.read(khatmahProvider.notifier).create(titleCtrl.text.trim(), target);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final khatmah = ref.watch(khatmahProvider);
    final notifier = ref.read(khatmahProvider.notifier);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;
    final textTheme = Theme.of(context).textTheme;

    if (khatmah == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الختمة')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag_outlined, size: 64, color: muted),
                const SizedBox(height: 16),
                Text('ابدأ ختمتك القادمة', style: textTheme.headlineMedium?.copyWith(fontSize: 20)),
                const SizedBox(height: 8),
                Text(
                  'حدّد تاريخاً مستهدفاً وسيحسب لك التطبيق وردك اليومي — ويعيد توزيعه تلقائياً إن تأخرت.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('ختمة جديدة'),
                  onPressed: () => _create(context, ref),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final daily = khatmah.dailyTarget(DateTime.now());
    final daysLeft = DateTime.fromMillisecondsSinceEpoch(khatmah.targetDateMs)
        .difference(DateTime.now())
        .inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الختمة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => notifier.delete(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ProgressRing(
              progress: khatmah.progress,
              size: 170,
              strokeWidth: 14,
              trackColor: muted.withOpacity(0.2),
              valueColor: accent,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${toArabicDigits(((khatmah.progress) * 100).toStringAsFixed(1))}٪',
                      style: textTheme.headlineMedium?.copyWith(fontSize: 26, color: accent)),
                  Text('${toArabicDigits(khatmah.pagesRead.toStringAsFixed(0))} / ${toArabicDigits(604)}',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(khatmah.title,
              textAlign: TextAlign.center, style: textTheme.headlineMedium?.copyWith(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            daysLeft >= 0 ? 'متبقٍ ${toArabicDigits(daysLeft)} يوماً' : 'انتهى الموعد — أكمل على راحتك',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: gold.withOpacity(0.35)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(toArabicDigits(daily.toStringAsFixed(1)),
                          style: textTheme.headlineMedium?.copyWith(fontSize: 24, color: accent)),
                      Text('ورد اليوم (صفحات)', style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                    ],
                  ),
                  Container(width: 1, height: 40, color: muted.withOpacity(0.3)),
                  Column(
                    children: [
                      Text(toArabicDigits((604 - khatmah.pagesRead).toStringAsFixed(0)),
                          style: textTheme.headlineMedium?.copyWith(fontSize: 24, color: gold)),
                      Text('صفحات متبقية', style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('سجّل قراءتك', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.remove),
                  label: const Text('تراجع صفحة'),
                  onPressed: khatmah.pagesRead >= 1
                      ? () => notifier.readPages(-1)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('قرأت صفحة'),
                  onPressed: () => notifier.readPages(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.checklist),
            label: const Text('قرأت ${'\u0665'} صفحات'),
            onPressed: () => notifier.readPages(5),
          ),
        ],
      ),
    );
  }
}
