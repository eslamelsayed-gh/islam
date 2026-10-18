/// الشاشة الرئيسية — الرفيق اليومي للقارئ
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/arabic.dart';
import '../../data/models.dart';
import '../../data/preferences.dart';
import '../../data/sample_data.dart';
import '../../state/providers.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../khatmah/khatmah_screen.dart';
import '../reader/mushaf_reader_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../audio/audio_player_screen.dart';
import '../surah_index/surah_index_screen.dart';
import '../wisdom/daily_wisdom_modal.dart';
import 'widgets/progress_ring.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // اللؤلؤة اليومية — مرة واحدة يومياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final today = '${now.year}-${now.month}-${now.day}';
      if (PreferencesService.instance.wisdomDate != today) {
        PreferencesService.instance.setWisdomDate(today);
        showDailyWisdom(context, ref.read(wisdomProvider));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;

    final bodies = [
      _HomeBody(accent: accent, gold: gold, muted: muted),
      const SearchScreen(embedded: true),
      const BookmarksScreen(embedded: true),
      const SettingsScreen(embedded: true),
    ];

    return Scaffold(
      body: SafeArea(child: bodies[_tab]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _MiniAudioBar(),
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
              NavigationDestination(icon: Icon(Icons.search), label: 'البحث'),
              NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark), label: 'الإشارات'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'الإعدادات'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  final Color accent, gold, muted;

  const _HomeBody({required this.accent, required this.gold, required this.muted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastPage = ref.watch(lastPageProvider);
    final khatmah = ref.watch(khatmahProvider);
    final wisdom = ref.watch(wisdomProvider);
    final surahName = SurahData.nameForPage(lastPage);
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        // ===== الترويسة — الهوية =====
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold, width: 1.5),
                  ),
                  child: Center(child: Text('﴿﴾', style: TextStyle(color: gold, fontSize: 16))),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إسلام', style: textTheme.headlineMedium),
                    Text('رَفِيقُكَ فِي تَدَبُّرِ كِتَابِ الله',
                        style: textTheme.bodyMedium?.copyWith(color: gold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ===== متابعة القراءة =====
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: gold.withOpacity(0.35)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MushafReaderScreen(initialPage: lastPage)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_outlined, color: accent, size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('متابعة القراءة',
                                style: textTheme.bodyMedium?.copyWith(color: muted)),
                            const SizedBox(height: 2),
                            Text('صفحة ${toArabicDigits(lastPage)} — سورة $surahName',
                                style: textTheme.titleLarge?.copyWith(fontSize: 17)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_back_ios_new, color: muted, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // ===== الختمة + اللؤلؤة =====
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // الختمة
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const KhatmahScreen()),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ProgressRing(
                              progress: khatmah?.progress ?? 0,
                              size: 68,
                              strokeWidth: 7,
                              trackColor: muted.withOpacity(0.2),
                              valueColor: accent,
                              center: Text(
                                '${toArabicDigits(((khatmah?.progress ?? 0) * 100).round())}٪',
                                style: TextStyle(fontSize: 13, color: accent, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(khatmah?.title ?? 'ابدأ ختمتك',
                                      style: textTheme.titleLarge?.copyWith(fontSize: 15)),
                                  Text(
                                    khatmah == null
                                        ? 'ختمة في ٣٠ يوماً مثلاً'
                                        : 'ورد اليوم: ${toArabicDigits(khatmah.dailyTarget(DateTime.now()).toStringAsFixed(0))} صفحات',
                                    style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // اللؤلؤة
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => showDailyWisdom(context, wisdom),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Icon(Icons.auto_awesome, color: gold, size: 28),
                            const SizedBox(height: 6),
                            Text('لؤلؤة اليوم',
                                style: textTheme.titleLarge?.copyWith(fontSize: 14)),
                            Text('تأمّل قصير',
                                style: textTheme.bodyMedium?.copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ===== أدوات سريعة =====
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أدواتك', style: textTheme.titleLarge),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QuickTool(
                      icon: Icons.format_list_numbered,
                      label: 'الفهرس',
                      color: accent,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SurahIndexScreen()),
                      ),
                    ),
                    _QuickTool(
                      icon: Icons.search,
                      label: 'البحث',
                      color: gold,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                    ),
                    _QuickTool(
                      icon: Icons.headset,
                      label: 'الاستماع',
                      color: accent,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AudioPlayerScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ===== آخر الإشارات =====
        SliverToBoxAdapter(
          child: Consumer(
            builder: (context, ref, _) {
              final bookmarks = ref.watch(bookmarksProvider);
              if (bookmarks.isEmpty) return const SizedBox.shrink();
              final recent = bookmarks.reversed.take(3).toList();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('آخر الإشارات', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    for (final b in recent)
                      _BookmarkTile(bookmark: b, muted: muted),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickTool extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickTool({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 6),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final Bookmark bookmark;
  final Color muted;

  const _BookmarkTile({required this.bookmark, required this.muted});

  @override
  Widget build(BuildContext context) {
    final verse = VerseData.byKey(bookmark.verseKey);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        dense: true,
        leading: Icon(
          bookmark.type == 'memorize'
              ? Icons.psychology_outlined
              : bookmark.type == 'reflect'
                  ? Icons.lightbulb_outline
                  : Icons.bookmark_border,
          color: AppColors.highlightColors[bookmark.colorIndex % AppColors.highlightColors.length],
        ),
        title: Text(
          verse?.text ?? bookmark.verseKey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          '${bookmarkTypeLabels[bookmark.type] ?? ''} • ${verse?.surahName ?? ''}',
          style: TextStyle(fontSize: 11, color: muted),
        ),
        onTap: verse == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MushafReaderScreen(initialPage: verse.page),
                  ),
                ),
      ),
    );
  }
}

/// الشريط المصغّر للمشغّل — يظهر عند تشغيل صوت
class _MiniAudioBar extends ConsumerWidget {
  const _MiniAudioBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioProvider);
    final current = audio.current;
    if (current == null) return const SizedBox.shrink();

    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;

    return Material(
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AudioPlayerScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              Icon(Icons.graphic_eq, color: accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${current.surahName} • ${current.key}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: Icon(audio.playing ? Icons.pause : Icons.play_arrow, color: accent),
                onPressed: () => ref.read(audioProvider.notifier).toggle(),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => ref.read(audioProvider.notifier).stop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
