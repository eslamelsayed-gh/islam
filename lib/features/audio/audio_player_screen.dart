/// مشغّل الصوت الكامل — المقرئ، التكرار، مؤقت النوم، التنقّل بين الآيات
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/arabic.dart';
import '../../data/models.dart';
import '../../data/sample_data.dart';
import '../../data/audio_cache.dart';
import '../../state/providers.dart';

class AudioPlayerScreen extends ConsumerWidget {
  const AudioPlayerScreen({super.key});

  String _fmt(Duration d) {
    final m = d.inMinutes, s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioProvider);
    final reciter = ref.watch(reciterProvider);
    final notifier = ref.read(audioProvider.notifier);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;
    final gold = dark ? AppColors.darkGold : AppColors.gold;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;

    final current = audio.current;
    // الآية التالية في قائمة التشغيل التجريبية
    final playlist = VerseData.playable;
    final idx = current == null ? -1 : playlist.indexWhere((v) => v.key == current.key);
    final nextVerse = (idx >= 0 && idx < playlist.length - 1) ? playlist[idx + 1] : null;

    return Scaffold(
      appBar: AppBar(title: const Text('الاستماع')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold.withOpacity(0.5), width: 2),
                color: gold.withOpacity(0.06),
              ),
              child: Center(
                child: audio.playing
                    ? Icon(Icons.graphic_eq, size: 52, color: accent)
                    : Icon(Icons.headset, size: 52, color: muted),
              ),
            ),
            const SizedBox(height: 24),
            Text(current?.surahName ?? 'اختر آية من المصحف',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              current == null ? 'اضغط مطوّلاً على آية ثم «التشغيل»' : 'الآية ${toArabicDigits(current.ayah)} • ${current.key}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (nextVerse != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('التالية: ${nextVerse.surahName} ${toArabicDigits(nextVerse.ayah)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ),
            const SizedBox(height: 24),
            // شريط التقدم
            SliderTheme(
              data: SliderTheme.of(context).copyWith(trackHeight: 3),
              child: Slider(
                value: audio.position.inSeconds
                    .clamp(0, audio.duration.inSeconds)
                    .toDouble(),
                max: audio.duration.inSeconds > 0
                    ? audio.duration.inSeconds.toDouble()
                    : 1,
                activeColor: accent,
                inactiveColor: accent.withOpacity(0.2),
                onChanged: (v) => notifier.seek(Duration(seconds: v.toInt())),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(audio.position), style: TextStyle(fontSize: 12, color: muted)),
                  Text(_fmt(audio.duration), style: TextStyle(fontSize: 12, color: muted)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous, size: 34, color: accent),
                  onPressed: current == null ? null : notifier.prev,
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                    boxShadow: [
                      BoxShadow(color: accent.withOpacity(0.4), blurRadius: 16),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 42,
                    color: Colors.white,
                    icon: audio.loading
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Icon(audio.playing ? Icons.pause : Icons.play_arrow),
                    onPressed: current == null
                        ? () => notifier.playVerse(playlist.first)
                        : notifier.toggle,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 34, color: accent),
                  onPressed: current == null ? null : notifier.next,
                ),
              ],
            ),
            const Spacer(),
            // اختيار المقرئ
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('المقرئ', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Reciter>(
              initialValue: reciter,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              items: [
                for (final r in Reciters.all)
                  DropdownMenuItem(value: r, child: Text(r.name)),
              ],
              onChanged: (r) {
                if (r != null) ref.read(reciterProvider.notifier).set(r);
              },
            ),
            const SizedBox(height: 14),
            // تكرار الآية
            Row(
              children: [
                Icon(Icons.repeat, size: 20, color: gold),
                const SizedBox(width: 10),
                Text('تكرار الآية', style: Theme.of(context).textTheme.bodyLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: accent,
                  onPressed: () => notifier.setRepeat(audio.repeatAyah - 1),
                ),
                Text(toArabicDigits(audio.repeatAyah),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: accent,
                  onPressed: () => notifier.setRepeat(audio.repeatAyah + 1),
                ),
              ],
            ),
            // مؤقت النوم
            Row(
              children: [
                Icon(Icons.bedtime_outlined, size: 20, color: gold),
                const SizedBox(width: 10),
                Text('مؤقت النوم', style: Theme.of(context).textTheme.bodyLarge),
                const Spacer(),
                for (final m in [0, 15, 30, 60])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FilterChip(
                      selected: audio.sleepMinutes == m,
                      label: Text(m == 0 ? 'إيقاف' : toArabicDigits(m)),
                      selectedColor: gold.withOpacity(0.3),
                      onSelected: (_) => notifier.setSleepTimer(m),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_outlined, size: 16, color: muted),
                const SizedBox(width: 6),
                Text(
                  'حمّل الآية للاستماع دون إنترنت',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                ),
                const SizedBox(width: 6),
                if (current != null)
                  _DownloadButton(verse: current, reciter: reciter),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
/// زر تحميل/حالة التخزين المحلي للآية
class _DownloadButton extends ConsumerStatefulWidget {
  final Verse verse;
  final Reciter reciter;

  const _DownloadButton({required this.verse, required this.reciter});

  @override
  ConsumerState<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends ConsumerState<_DownloadButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;
    final cached = ref.watch(audioCacheProvider
        .select((s) => s.contains(AudioCacheService.instance
            .key(widget.reciter.id, widget.verse.surahId, widget.verse.ayah))));

    if (cached) {
      return Icon(Icons.check_circle, size: 20, color: accent);
    }
    return IconButton(
      icon: _busy
          ? const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(Icons.download_for_offline_outlined, size: 20, color: accent),
      onPressed: _busy
          ? null
          : () async {
              setState(() => _busy = true);
              final ok = await ref
                  .read(audioCacheProvider.notifier)
                  .download(widget.reciter, widget.verse);
              if (!mounted) return;
              setState(() => _busy = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(ok
                        ? 'تم التحميل — ستُشغَّل الآية دون إنترنت'
                        : 'تعذّر التحميل — تحقق من الاتصال')),
              );
            },
    );
  }
}
