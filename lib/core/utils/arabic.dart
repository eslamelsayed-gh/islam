/// أدوات اللغة العربية: أرقام عربية + تطبيع نصوص للبحث
library;

const String _arabicDigits = '٠١٢٣٤٥٦٧٨٩';
const String _latinDigits = '0123456789';

/// تحويل الأرقام اللاتينية إلى أرقام عربية مشرقية ﴿١٢٣﴾
String toArabicDigits(Object input) {
  return input.toString().split('').map((c) {
    final i = _latinDigits.indexOf(c);
    return i >= 0 ? _arabicDigits[i] : c;
  }).join();
}

/// تحويل الأرقام العربية إلى لاتينية (للبحث)
String toLatinDigits(String input) {
  return input.split('').map((c) {
    final i = _arabicDigits.indexOf(c);
    return i >= 0 ? _latinDigits[i] : c;
  }).join();
}

/// تطبيع النص العربي للبحث الفوري:
/// إزالة التشكيل والتطويل وتوحيد الألف والياء والتاء المربوطة
String normalizeArabic(String input) {
  return toLatinDigits(input)
      // حركات التشكيل + الألف الخنجرية + التطويل
      .replaceAll(RegExp('[\u064B-\u0652\u0670\u0640]'), '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .trim()
      .toLowerCase();
}
