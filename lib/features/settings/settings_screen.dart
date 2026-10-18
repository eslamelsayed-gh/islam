/// الإعدادات — المظهر، حجم الخط، المقرئ، الرصيد، حول التطبيق
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/preferences.dart';
import '../../data/sample_data.dart';
import '../../state/providers.dart';

class SettingsScreen extends ConsumerWidget {
  final bool embedded;

  const SettingsScreen({super.key, this.embedded = false});

  Future<void> _resetData(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تعيين البيانات'),
        content: const Text('سيتم مسح الإشارات والملاحظات والتمييز والختمة. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
    if (ok == true) await PreferencesService.instance.clearAll();
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fontScale = ref.watch(fontScaleProvider);
    final reciter = ref.watch(reciterProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final textTheme = Theme.of(context).textTheme;

    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('المظهر', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, label: Text('نهاري'), icon: Icon(Icons.light_mode)),
            ButtonSegment(value: ThemeMode.system, label: Text('تلقائي'), icon: Icon(Icons.settings_suggest)),
            ButtonSegment(value: ThemeMode.dark, label: Text('ليلي'), icon: Icon(Icons.dark_mode)),
          ],
          selected: {themeMode},
          onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
        ),
        const SizedBox(height: 24),
        Text('حجم خط المصحف', style: textTheme.titleLarge),
        Slider(
          value: fontScale,
          min: 0.8,
          max: 1.6,
          divisions: 8,
          label: '${(fontScale * 100).round()}٪',
          activeColor: gold,
          onChanged: (v) => ref.read(fontScaleProvider.notifier).set(v),
        ),
        const SizedBox(height: 12),
        Text('المقرئ الافتراضي', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField(
          initialValue: reciter,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: [
            for (final r in Reciters.all)
              DropdownMenuItem(value: r, child: Text(r.name)),
          ],
          onChanged: (r) {
            if (r != null) ref.read(reciterProvider.notifier).set(r);
          },
        ),
        const SizedBox(height: 24),
        // ===== بطاقة التطبيق والرصيد =====
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: gold.withOpacity(0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('إسلام', style: textTheme.headlineMedium),
                Text('رَفِيقُكَ فِي تَدَبُّرِ كِتَابِ الله',
                    style: textTheme.bodyMedium?.copyWith(color: gold)),
                const Divider(height: 24),
                Text('صُمِّم بواسطة',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                Text('إسلام السيد',
                    style: textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.facebook, size: 18),
                      label: const Text('فيسبوك'),
                      onPressed: () => _open(
                          'https://www.facebook.com/eslam.elsayed.570?mibextid=rS40aB7S9Ucbxw6v'),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.work_outline, size: 18),
                      label: const Text('لينكدإن'),
                      onPressed: () => _open(
                          'https://www.linkedin.com/in/eslam-elsayed-249b7935b'),
                    ),
                  ],
                ),
                Text('نسخة 1.1.0 — بلا إعلانات، Offline-First',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.restart_alt),
          label: const Text('إعادة تعيين جميع البيانات'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
          onPressed: () => _resetData(context),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('الإعدادات')), body: body);
  }
}
