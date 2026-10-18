/// قارئ المصحف — وضعان:
/// flip: تقليب أفقي صفحة-صفحة (طابع المصحف الورقي)
/// scroll: تمرير عمودي صفحة-صفحة (قراءة متصلة)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/arabic.dart';
import '../../data/sample_data.dart';
import '../../state/providers.dart';
import '../search/search_screen.dart';
import 'widgets/mushaf_page.dart';

class MushafReaderScreen extends ConsumerStatefulWidget {
  final int initialPage;

  const MushafReaderScreen({super.key, this.initialPage = 1});

  @override
  ConsumerState<MushafReaderScreen> createState() => _MushafReaderScreenState();
}

class _MushafReaderScreenState extends ConsumerState<MushafReaderScreen> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialPage.clamp(1, 604);
    _ctrl = PageController(initialPage: _current - 1, viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _current = i + 1);
    ref.read(lastPageProvider.notifier).set(i + 1);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final surahName = SurahData.nameForPage(_current);
    final juz = ((_current - 1) ~/ 20) + 1;
    final fontScale = ref.watch(fontScaleProvider);
    final mode = ref.watch(readerModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(surahName.isEmpty ? 'المصحف' : 'سورة $surahName'),
            Text(
              'صفحة ${toArabicDigits(_current)} • الجزء ${toArabicDigits(juz)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12, color: gold),
            ),
          ],
        ),
        actions: [
          // تبديل وضع القراءة
          IconButton(
            tooltip: mode == ReaderMode.flip
                ? 'التمرير العمودي'
                : 'التقليب الأفقي',
            icon: Icon(mode == ReaderMode.flip
                ? Icons.swipe_vertical
                : Icons.swipe_left_alt),
            onPressed: () {
              final newMode = mode == ReaderMode.flip
                  ? ReaderMode.scroll
                  : ReaderMode.flip;
              ref.read(readerModeProvider.notifier).state = newMode;
              final page = _current;
              // إعادة بناء المتحكم بنفس الصفحة
              _ctrl.jumpToPage(page - 1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: 604,
        scrollDirection:
            mode == ReaderMode.flip ? Axis.horizontal : Axis.vertical,
        onPageChanged: _onPageChanged,
        itemBuilder: (_, i) => MushafPage(
          pageNumber: i + 1,
          fontScale: fontScale,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _current > 1
                    ? () => _ctrl.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut)
                    : null,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(trackHeight: 3),
                  child: Slider(
                    value: _current.toDouble(),
                    min: 1,
                    max: 604,
                    divisions: 603,
                    activeColor: gold,
                    inactiveColor: gold.withOpacity(0.2),
                    onChanged: (v) => _ctrl.jumpToPage(v.round() - 1),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _current < 604
                    ? () => _ctrl.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
