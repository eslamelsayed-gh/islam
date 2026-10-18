/// الإشارات والملاحظات — مصنّفة حسب النوع مع البحث والحذف
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/arabic.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../../state/providers.dart';
import '../reader/mushaf_reader_screen.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const BookmarksScreen({super.key, this.embedded = false});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(bookmarksProvider);
    final highlights = ref.watch(highlightsProvider);
    final notes = ref.watch(notesProvider);
    final notifier = ref.read(bookmarksProvider.notifier);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;

    final list = _filter == 'all'
        ? all
        : all.where((b) => b.type == _filter).toList();

    final body = Column(
      children: [
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final e in [
                ('all', 'الكل'),
                ...bookmarkTypeLabels.entries.map((e) => (e.key, e.value)),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: _filter == e.$1,
                    label: Text(e.$2),
                    selectedColor: accent.withOpacity(0.25),
                    onSelected: (_) => setState(() => _filter = e.$1),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty && highlights.isEmpty && notes.isEmpty
              ? Center(
                  child: Text(
                    'لا إشارات بعد\nاضغط مطوّلاً على أي آية في المصحف',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final b in list)
                      _BookmarkCard(
                        bookmark: b,
                        verse: VerseData.byKey(b.verseKey),
                        onDelete: () => notifier.remove(b.id),
                      ),
                    if (highlights.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('التمييز اللوني', style: Theme.of(context).textTheme.titleLarge),
                      for (final e in highlights.entries)
                        _HighlightTile(
                          verse: VerseData.byKey(e.key),
                          colorIndex: e.value,
                          onClear: () => ref
                              .read(highlightsProvider.notifier)
                              .remove(e.key),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('الإشارات')), body: body);
  }
}

class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final Verse? verse;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.bookmark,
    required this.verse,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final color = AppColors
        .highlightColors[bookmark.colorIndex % AppColors.highlightColors.length];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.bookmark, color: color, size: 18),
                const SizedBox(width: 8),
                Text(bookmarkTypeLabels[bookmark.type] ?? '',
                    style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                ),
              ],
            ),
            GestureDetector(
              onTap: verse == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MushafReaderScreen(initialPage: verse!.page),
                        ),
                      ),
              child: Text(
                verse?.text ?? bookmark.verseKey,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, height: 1.9),
              ),
            ),
            if (verse != null)
              Text('${verse!.surahName} : ${toArabicDigits(verse!.ayah)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 11)),
            if (bookmark.note.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(bookmark.note,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 13, height: 1.7)),
              ),
          ],
        ),
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final Verse? verse;
  final int colorIndex;
  final VoidCallback onClear;

  const _HighlightTile({
    required this.verse,
    required this.colorIndex,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.highlightColors[colorIndex % AppColors.highlightColors.length];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        dense: true,
        leading: Container(width: 16, height: 16, color: color),
        title: Text(verse?.text ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13)),
        subtitle: Text(verse?.surahName ?? ''),
        onTap: verse == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MushafReaderScreen(initialPage: verse!.page),
                  ),
                ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          onPressed: onClear,
        ),
      ),
    );
  }
}
