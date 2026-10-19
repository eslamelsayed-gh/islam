/// نافذة الإجراءات للآية — Bottom Sheet قابل للسحب
/// تشغيل • تفسير • تمييز • إشارة • ملاحظة • مشاركة صورة • نسخ
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/arabic.dart';
import '../../../data/models.dart';
import '../../../data/sample_data.dart';
import '../../../state/providers.dart';
import '../../audio/audio_player_screen.dart';
import 'share_card.dart';
import 'tafsir_screen.dart';

Future<void> showVerseActionSheet(BuildContext context, Verse verse) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, controller) => VerseActionSheet(verse: verse, controller: controller),
    ),
  );
}

class VerseActionSheet extends ConsumerStatefulWidget {
  final Verse verse;
  final ScrollController controller;

  const VerseActionSheet({
    super.key,
    required this.verse,
    required this.controller,
  });

  @override
  ConsumerState<VerseActionSheet> createState() => _VerseActionSheetState();
}

class _VerseActionSheetState extends ConsumerState<VerseActionSheet> {
  final _shareKey = GlobalKey();
  late final TextEditingController _noteCtrl;

  Verse get verse => widget.verse;

  @override
  void initState() {
    super.initState();
   _noteCtrl = TextEditingController(text: ref.read(notesProvider)[verse.key] ?? '');  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _saveNote() {
    ref.read(notesProvider.notifier).set(verse.key, _noteCtrl.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الملاحظة')),
    );
  }

  Future<void> _shareImage() async {
    try {
      final boundary =
          _shareKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ayah_${verse.key.replaceAll(':', '_')}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)],
          text: '${verse.text}\n﴿${verse.surahName} : ${toArabicDigits(verse.ayah)}﴾');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر إنشاء الصورة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final ink = dark ? AppColors.darkInk : AppColors.ink;
    final card = Theme.of(context).cardColor;

    final highlight = ref.watch(highlightsProvider)[verse.key];
    final bookmarks = ref.watch(bookmarksProvider);
    final tafsir = TafsirData.get(verse.key);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        controller: widget.controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // معاينة الآية
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gold.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold.withOpacity(0.3)),
            ),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: verse.text,
                  style: TextStyle(fontSize: 20, color: ink, height: 2.0),
                ),
                TextSpan(
                  text: ' ﴿${toArabicDigits(verse.ayah)}﴾',
                  style: TextStyle(fontSize: 15, color: gold, fontWeight: FontWeight.bold),
                ),
              ]),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 16),
          // تشغيل الصوت
          _ActionTile(
            icon: Icons.play_circle_outline,
            color: accent,
            title: 'التشغيل من هذه الآية',
            subtitle: 'استماع بالمقرئ المختار',
            onTap: () async {
              Navigator.of(context).pop();
              await ref.read(audioProvider.notifier).playVerse(verse);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AudioPlayerScreen()),
                );
              }
            },
          ),
          // التفسير المختصر
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            leading: Icon(Icons.menu_book_outlined, color: gold),
            title: const Text('التفسير المختصر'),
            subtitle: Text('مختصر تفسير السعدي',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tafsir ?? 'سيُتاح التفسير الكامل لهذه الآية في النسخة النهائية.',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 14, color: ink, height: 1.9),
                ),
              ),
            ],
          ),
          // التفسير في صفحة مستقلة
          _ActionTile(
            icon: Icons.library_books_outlined,
            color: accent,
            title: 'صفحة التفسير والتدبّر',
            subtitle: 'قراءة التفسير في مساحة مستقلة',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TafsirScreen(verse: verse)),
              );
            },
          ),
          // التمييز اللوني
          _ActionRow(
            icon: Icons.brush_outlined,
            color: gold,
            title: 'التمييز',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < AppColors.highlightColors.length; i++)
                  GestureDetector(
                    onTap: () {
                      final notifier = ref.read(highlightsProvider.notifier);
                      if (highlight == i) {
                        notifier.remove(verse.key);
                      } else {
                        notifier.set(verse.key, i);
                      }
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.highlightColors[i],
                        border: highlight == i
                            ? Border.all(color: ink, width: 2)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: highlight == i
                          ? Icon(Icons.check, size: 15, color: ink)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          // الإشارات
          _ActionRow(
            icon: Icons.bookmark_border,
            color: accent,
            title: 'الإشارة المرجعية',
            trailing: Wrap(
              spacing: 6,
              children: [
                for (final e in bookmarkTypeLabels.entries)
                  FilterChip(
                    selected: bookmarks.any((b) => b.verseKey == verse.key && b.type == e.key),
                    label: Text(e.value, style: const TextStyle(fontSize: 12)),
                    selectedColor: accent.withOpacity(0.25),
                    checkmarkColor: accent,
                    onSelected: (_) =>
                        ref.read(bookmarksProvider.notifier).toggle(verse.key, e.key),
                  ),
              ],
            ),
          ),
          // الملاحظة
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              controller: _noteCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              minLines: 2,
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظتك على هذه الآية…',
                hintTextDirection: TextDirection.rtl,
                suffixIcon: IconButton(
                  icon: Icon(Icons.save_outlined, color: accent),
                  onPressed: _saveNote,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: ink.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: ink.withOpacity(0.15)),
                ),
              ),
            ),
          ),
          // بطاقة المشاركة (معاينة حيّة)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text('معاينة بطاقة المشاركة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
          ),
          const SizedBox(height: 8),
          Center(
            child: RepaintBoundary(
              key: _shareKey,
              child: AyahShareCard(verse: verse),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: const Text('مشاركة الصورة'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _shareImage,
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('نسخ'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text: '${verse.text}\n﴿${verse.surahName} : ${toArabicDigits(verse.ayah)}﴾'));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ الآية')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
      onTap: onTap,
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget trailing;

  const _ActionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
