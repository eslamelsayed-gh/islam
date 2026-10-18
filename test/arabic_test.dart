import 'package:flutter_test/flutter_test.dart';
import 'package:islam_app/core/utils/arabic.dart';

void main() {
  group('toArabicDigits', () {
    test('يحوّل الأرقام اللاتينية', () {
      expect(toArabicDigits(255), '٢٥٥');
      expect(toArabicDigits(604), '٦٠٤');
    });
  });

  group('normalizeArabic — التطبيع للبحث', () {
    test('يزيل التشكيل تماماً', () {
      expect(normalizeArabic('ٱلْكُرْسِيُّ'), 'الكرسي');
    });

    test('يوحّد الهمزات والألف المقصورة والتاء المربوطة', () {
      expect(normalizeArabic('إِلَٰه'), 'الاه');
      expect(normalizeArabic('إلى'), 'الي');
      expect(normalizeArabic('الرحمة'), 'الرحمه');
    });

    test('يحوّل الأرقام العربية إلى لاتينية', () {
      expect(normalizeArabic('١١٢'), '112');
    });

    test('«الكرسي» يطابق «ٱلْكُرْسِيُّ» — قلب حالة الاستخدام', () {
      expect(
        normalizeArabic('الكرسي'),
        normalizeArabic('ٱلْكُرْسِيُّ'),
      );
    });
  });
}
