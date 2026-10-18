/// مدير تخزين الصوتيات محلياً — Offline-First
/// يحفظ الملفات في مجلد التطبيق ويعمل المشغّل منها دون إنترنت
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class AudioCacheService {
  AudioCacheService._();

  static final AudioCacheService instance = AudioCacheService._();

  Future<Directory> get _dir async {
    final d = await getApplicationDocumentsDirectory();
    final sub = Directory('${d.path}/audio');
    if (!await sub.exists()) await sub.create(recursive: true);
    return sub;
  }

  String key(String reciterId, int surah, int ayah) =>
      '$reciterId-${surah}_$ayah';

  String _fileName(String k) => '$k.mp3';

  Future<File?> getCached(String reciterId, int surah, int ayah) async {
    final f =
        File('${(await _dir).path}/${_fileName(key(reciterId, surah, ayah))}');
    return await f.exists() ? f : null;
  }

  Future<Set<String>> listCached() async {
    final dir = await _dir;
    return dir
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last.replaceAll('.mp3', ''))
        .toSet();
  }

  Future<void> download(Reciter reciter, Verse verse) async {
    final uri = Uri.parse(reciter.audioUrl(verse.surahId, verse.ayah));
    final bytes = await http.readBytes(uri).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('انتهت مهلة التحميل'),
        );
    final file = File(
        '${(await _dir).path}/${_fileName(key(reciter.id, verse.surahId, verse.ayah))}');
    await file.writeAsBytes(bytes);
  }

  Future<void> clearAll() async {
    final dir = await _dir;
    for (final f in dir.listSync().whereType<File>()) {
      await f.delete();
    }
  }
}
