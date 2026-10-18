/// البيانات التجريبية: فهرس السور + آيات حقيقية للصفحات التجريبية
/// النسخة الإنتاجية تستبدل هذا بقاعدة بيانات SQLite مضمّنة (604 صفحات)
import 'models.dart';
import 'quran_texts.dart';

class SurahData {
  SurahData._();

  static const List<SurahMeta> list = [
    SurahMeta(1, 'الفاتحة', 'Al-Fatihah', 7, 'مكية', 1),
    SurahMeta(2, 'البقرة', 'Al-Baqarah', 286, 'مدنية', 2),
    SurahMeta(3, 'آل عمران', 'Aal-e-Imran', 200, 'مدنية', 50),
    SurahMeta(4, 'النساء', 'An-Nisa', 176, 'مدنية', 77),
    SurahMeta(5, 'المائدة', 'Al-Ma\u0027idah', 120, 'مدنية', 106),
    SurahMeta(6, 'الأنعام', 'Al-An\u0027am', 165, 'مكية', 128),
    SurahMeta(7, 'الأعراف', 'Al-A\u0027raf', 206, 'مكية', 151),
    SurahMeta(8, 'الأنفال', 'Al-Anfal', 75, 'مدنية', 177),
    SurahMeta(9, 'التوبة', 'At-Tawbah', 129, 'مدنية', 187),
    SurahMeta(10, 'يونس', 'Yunus', 109, 'مكية', 208),
    SurahMeta(11, 'هود', 'Hud', 123, 'مكية', 221),
    SurahMeta(12, 'يوسف', 'Yusuf', 111, 'مكية', 235),
    SurahMeta(13, 'الرعد', 'Ar-Ra\u0027d', 43, 'مدنية', 249),
    SurahMeta(14, 'إبراهيم', 'Ibrahim', 52, 'مكية', 255),
    SurahMeta(15, 'الحجر', 'Al-Hijr', 99, 'مكية', 262),
    SurahMeta(16, 'النحل', 'An-Nahl', 128, 'مكية', 267),
    SurahMeta(17, 'الإسراء', 'Al-Isra', 111, 'مكية', 282),
    SurahMeta(18, 'الكهف', 'Al-Kahf', 110, 'مكية', 293),
    SurahMeta(19, 'مريم', 'Maryam', 98, 'مكية', 305),
    SurahMeta(20, 'طه', 'Taha', 135, 'مكية', 312),
    SurahMeta(21, 'الأنبياء', 'Al-Anbiya', 112, 'مكية', 322),
    SurahMeta(22, 'الحج', 'Al-Hajj', 78, 'مدنية', 332),
    SurahMeta(23, 'المؤمنون', 'Al-Mu\u0027minun', 118, 'مكية', 342),
    SurahMeta(24, 'النور', 'An-Nur', 64, 'مدنية', 350),
    SurahMeta(25, 'الفرقان', 'Al-Furqan', 77, 'مكية', 359),
    SurahMeta(26, 'الشعراء', 'Ash-Shu\u0027ara', 227, 'مكية', 367),
    SurahMeta(27, 'النمل', 'An-Naml', 93, 'مكية', 377),
    SurahMeta(28, 'القصص', 'Al-Qasas', 88, 'مكية', 385),
    SurahMeta(29, 'العنكبوت', 'Al-Ankabut', 69, 'مكية', 396),
    SurahMeta(30, 'الروم', 'Ar-Rum', 60, 'مكية', 404),
    SurahMeta(31, 'لقمان', 'Luqman', 34, 'مكية', 411),
    SurahMeta(32, 'السجدة', 'As-Sajdah', 30, 'مكية', 415),
    SurahMeta(33, 'الأحزاب', 'Al-Ahzab', 73, 'مدنية', 418),
    SurahMeta(34, 'سبأ', 'Saba', 54, 'مكية', 428),
    SurahMeta(35, 'فاطر', 'Fatir', 45, 'مكية', 434),
    SurahMeta(36, 'يس', 'Ya-Sin', 83, 'مكية', 440),
    SurahMeta(37, 'الصافات', 'As-Saffat', 182, 'مكية', 446),
    SurahMeta(38, 'ص', 'Sad', 88, 'مكية', 453),
    SurahMeta(39, 'الزمر', 'Az-Zumar', 75, 'مكية', 458),
    SurahMeta(40, 'غافر', 'Ghafir', 85, 'مكية', 467),
    SurahMeta(41, 'فصلت', 'Fussilat', 54, 'مكية', 477),
    SurahMeta(42, 'الشورى', 'Ash-Shura', 53, 'مكية', 483),
    SurahMeta(43, 'الزخرف', 'Az-Zukhruf', 89, 'مكية', 489),
    SurahMeta(44, 'الدخان', 'Ad-Dukhan', 59, 'مكية', 496),
    SurahMeta(45, 'الجاثية', 'Al-Jathiyah', 37, 'مكية', 499),
    SurahMeta(46, 'الأحقاف', 'Al-Ahqaf', 35, 'مكية', 502),
    SurahMeta(47, 'محمد', 'Muhammad', 38, 'مدنية', 507),
    SurahMeta(48, 'الفتح', 'Al-Fath', 29, 'مدنية', 511),
    SurahMeta(49, 'الحجرات', 'Al-Hujurat', 18, 'مدنية', 515),
    SurahMeta(50, 'ق', 'Qaf', 45, 'مكية', 518),
    SurahMeta(51, 'الذاريات', 'Adh-Dhariyat', 60, 'مكية', 520),
    SurahMeta(52, 'الطور', 'At-Tur', 49, 'مكية', 523),
    SurahMeta(53, 'النجم', 'An-Najm', 62, 'مكية', 526),
    SurahMeta(54, 'القمر', 'Al-Qamar', 55, 'مكية', 528),
    SurahMeta(55, 'الرحمن', 'Ar-Rahman', 78, 'مدنية', 531),
    SurahMeta(56, 'الواقعة', 'Al-Waqi\u0027ah', 96, 'مكية', 534),
    SurahMeta(57, 'الحديد', 'Al-Hadid', 29, 'مدنية', 537),
    SurahMeta(58, 'المجادلة', 'Al-Mujadila', 22, 'مدنية', 542),
    SurahMeta(59, 'الحشر', 'Al-Hashr', 24, 'مدنية', 545),
    SurahMeta(60, 'الممتحنة', 'Al-Mumtahanah', 13, 'مدنية', 549),
    SurahMeta(61, 'الصف', 'As-Saff', 14, 'مدنية', 551),
    SurahMeta(62, 'الجمعة', 'Al-Jumu\u0027ah', 11, 'مدنية', 553),
    SurahMeta(63, 'المنافقون', 'Al-Munafiqun', 11, 'مدنية', 554),
    SurahMeta(64, 'التغابن', 'At-Taghabun', 18, 'مدنية', 556),
    SurahMeta(65, 'الطلاق', 'At-Talaq', 12, 'مدنية', 558),
    SurahMeta(66, 'التحريم', 'At-Tahrim', 12, 'مدنية', 560),
    SurahMeta(67, 'الملك', 'Al-Mulk', 30, 'مكية', 562),
    SurahMeta(68, 'القلم', 'Al-Qalam', 52, 'مكية', 564),
    SurahMeta(69, 'الحاقة', 'Al-Haqqah', 52, 'مكية', 566),
    SurahMeta(70, 'المعارج', 'Al-Ma\u0027arij', 44, 'مكية', 568),
    SurahMeta(71, 'نوح', 'Nuh', 28, 'مكية', 570),
    SurahMeta(72, 'الجن', 'Al-Jinn', 28, 'مكية', 572),
    SurahMeta(73, 'المزمل', 'Al-Muzzammil', 20, 'مكية', 574),
    SurahMeta(74, 'المدثر', 'Al-Muddaththir', 56, 'مكية', 575),
    SurahMeta(75, 'القيامة', 'Al-Qiyamah', 40, 'مكية', 577),
    SurahMeta(76, 'الإنسان', 'Al-Insan', 31, 'مدنية', 578),
    SurahMeta(77, 'المرسلات', 'Al-Mursalat', 50, 'مكية', 580),
    SurahMeta(78, 'النبأ', 'An-Naba', 40, 'مكية', 582),
    SurahMeta(79, 'النازعات', 'An-Nazi\u0027at', 46, 'مكية', 583),
    SurahMeta(80, 'عبس', 'Abasa', 42, 'مكية', 585),
    SurahMeta(81, 'التكوير', 'At-Takwir', 29, 'مكية', 586),
    SurahMeta(82, 'الانفطار', 'Al-Infitar', 19, 'مكية', 587),
    SurahMeta(83, 'المطففين', 'Al-Mutaffifin', 36, 'مكية', 587),
    SurahMeta(84, 'الانشقاق', 'Al-Inshiqaq', 25, 'مكية', 589),
    SurahMeta(85, 'البروج', 'Al-Buruj', 22, 'مكية', 590),
    SurahMeta(86, 'الطارق', 'At-Tariq', 17, 'مكية', 591),
    SurahMeta(87, 'الأعلى', 'Al-A\u0027la', 19, 'مكية', 591),
    SurahMeta(88, 'الغاشية', 'Al-Ghashiyah', 26, 'مكية', 592),
    SurahMeta(89, 'الفجر', 'Al-Fajr', 30, 'مكية', 593),
    SurahMeta(90, 'البلد', 'Al-Balad', 20, 'مكية', 594),
    SurahMeta(91, 'الشمس', 'Ash-Shams', 15, 'مكية', 595),
    SurahMeta(92, 'الليل', 'Al-Layl', 21, 'مكية', 595),
    SurahMeta(93, 'الضحى', 'Ad-Duha', 11, 'مكية', 596),
    SurahMeta(94, 'الشرح', 'Ash-Sharh', 8, 'مكية', 596),
    SurahMeta(95, 'التين', 'At-Tin', 8, 'مكية', 597),
    SurahMeta(96, 'العلق', 'Al-Alaq', 19, 'مكية', 597),
    SurahMeta(97, 'القدر', 'Al-Qadr', 5, 'مكية', 598),
    SurahMeta(98, 'البينة', 'Al-Bayyinah', 8, 'مدنية', 598),
    SurahMeta(99, 'الزلزلة', 'Az-Zalzalah', 8, 'مدنية', 599),
    SurahMeta(100, 'العاديات', 'Al-Adiyat', 11, 'مكية', 599),
    SurahMeta(101, 'القارعة', 'Al-Qari\u0027ah', 11, 'مكية', 600),
    SurahMeta(102, 'التكاثر', 'At-Takathur', 8, 'مكية', 600),
    SurahMeta(103, 'العصر', 'Al-Asr', 3, 'مكية', 601),
    SurahMeta(104, 'الهمزة', 'Al-Humazah', 9, 'مكية', 601),
    SurahMeta(105, 'الفيل', 'Al-Fil', 5, 'مكية', 601),
    SurahMeta(106, 'قريش', 'Quraysh', 4, 'مكية', 602),
    SurahMeta(107, 'الماعون', 'Al-Ma\u0027un', 7, 'مكية', 602),
    SurahMeta(108, 'الكوثر', 'Al-Kawthar', 3, 'مكية', 602),
    SurahMeta(109, 'الكافرون', 'Al-Kafirun', 6, 'مكية', 603),
    SurahMeta(110, 'النصر', 'An-Nasr', 3, 'مدنية', 603),
    SurahMeta(111, 'المسد', 'Al-Masad', 5, 'مكية', 603),
    SurahMeta(112, 'الإخلاص', 'Al-Ikhlas', 4, 'مكية', 604),
    SurahMeta(113, 'الفلق', 'Al-Falaq', 5, 'مكية', 604),
    SurahMeta(114, 'الناس', 'An-Nas', 6, 'مكية', 604),
  ];

  static SurahMeta byId(int id) => list[id - 1];

  /// اسم آخر سورة بدأت قبل هذه الصفحة أو عندها (للترويسة)
  static String nameForPage(int page) {
    var name = '';
    for (final s in list) {
      if (s.startPage <= page) {
        name = s.nameAr;
      } else {
        break;
      }
    }
    return name;
  }

  /// السورة التي تبدأ عند هذه الصفحة بالضبط (إن وجدت)
  static SurahMeta? startsAt(int page) {
    for (final s in list) {
      if (s.startPage == page) return s;
    }
    return null;
  }
}

class VerseData {
  VerseData._();

  /// الآيات من الملف الموثق المولَّد من api.quran.com (انظر quran_texts.dart)
  static List<Verse> get verses => [
        for (final q in kQuranVerses)
          Verse(
            surahId: q.surah,
            ayah: q.ayah,
            page: q.page,
            text: q.text,
            surahName: SurahData.byId(q.surah).nameAr,
          ),
      ];

  static Verse? byKey(String key) {
    for (final v in verses) {
      if (v.key == key) return v;
    }
    return null;
  }

  static List<Verse> byPage(int page) =>
      verses.where((v) => v.page == page).toList();

  static List<Verse> get playable => verses;
}

class TafsirData {
  TafsirData._();

  /// تفسير السعدي الأصلي — يُملأ آلياً من المصدر الرسمي api.quran.com (91)
  /// عبر: python3 tool/generate_quran_data.py
  static String? get(String verseKey) => kSaadiTafsir[verseKey];
}

class Reciters {
  Reciters._();

  static const List<Reciter> all = [
    Reciter('minshawi', 'محمد صديق المنشاوي', 'Minshawi_Murattal_128kbps'),
    Reciter('husary', 'محمود خليل الحصري', 'Husary_64kbps'),
    Reciter('afasy', 'مشاري راشد العفاسي', 'Alafasy_64kbps'),
    Reciter('basit', 'عبد الباسط عبد الصمد', 'Abdul_Basit_Murattal_64kbps'),
    Reciter('basfar', 'عبد الله بصفر', 'Abdullah_Basfar_64kbps'),
    Reciter('ghamdi', 'سعد الغامدي', 'Ghamadi_40kbps'),
    Reciter('shatri', 'أبو بكر الشاطري', 'Shaatree_64kbps'),
    Reciter('sudais', 'عبد الرحمن السديس', 'Abdurrahmaan_As-Sudais_64kbps'),
    Reciter('ayyub', 'محمد أيوب', 'Muhammad_Ayyub_64kbps'),
    Reciter('parhizgar', 'شهريار برهيزكار', 'Parhizgar_48kbps'),
  ];

  static Reciter byId(String id) =>
      all.firstWhere((r) => r.id == id, orElse: () => all.first);
}

class WisdomData {
  WisdomData._();

  static const List<WisdomCard> cards = [
    WisdomCard(
      id: 'gem_01',
      type: 'linguistic_gem',
      title: 'لماذا «وَالْعَصْرِ» بالقسم؟',
      body: 'أقسم الله بالعصر — وهو الدهر — لأنه يشهد على أحوال العباد، فمن لم يشغل وقته بطاعة الله فقد خسر رأس ماله الحقيقي: الزمن.',
      verseRef: 'سورة العصر',
    ),
    WisdomCard(
      id: 'gem_02',
      type: 'reflection',
      title: 'سرّ تكرار «الرحمن الرحيم»',
      body: 'في الفاتحة يذكر الله اسمه ثم يقرنه بالرحمة مرتين قبل ذكر العبادة، ليأتي العبد طامعاً في الرحمة لا خائفاً من السلطان.',
      verseRef: 'سورة الفاتحة',
    ),
    WisdomCard(
      id: 'gem_03',
      type: 'virtue',
      title: 'فضل آية الكرسي',
      body: 'قال ﷺ: «من قرأ آية الكرسي دبر كل صلاة لم يمنعه من دخول الجنة إلا أن يموت». رواه النسائي.',
      verseRef: 'البقرة ٢٥٥',
    ),
    WisdomCard(
      id: 'gem_04',
      type: 'linguistic_gem',
      title: '«الصَّمَد» في ثلاثة أحرف',
      body: 'اجمعت معاني الكمال في ثلاثة أحرف: السين للعلو والميم للغنى والدال للدوام — الصمد: العلي الغني الدائم الذي تُقصَد حوائجه.',
      verseRef: 'الإخلاص ٢',
    ),
    WisdomCard(
      id: 'gem_05',
      type: 'reflection',
      title: 'الكوثار: نهر في الجنة',
      body: 'أعطى الله نبيه ﷺ نهراً في الجنة حوضه أوسع من البحر، فكان شفاءً من هم الدنيا: «إنا أعطيناك الكوثر».',
      verseRef: 'الكوثر ١',
    ),
  ];

  /// بطاقة اليوم — حسب رقم اليوم في السنة
  static WisdomCard today() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return cards[dayOfYear % cards.length];
  }
}
