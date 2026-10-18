ضع هنا ملفات الخطوط التالية قبل التشغيل (اختياري — التطبيق يعمل بالخط الافتراضي بدونها):

1) Amiri-Regular.ttf    → https://fonts.google.com/specimen/Amiri
2) Amiri-Bold.ttf       → نفس الرابط (وزن 700)

ثم فعّل قسم fonts في pubspec.yaml (معلّق بالفعل هناك).

للإنتاج: أضف خط KFGQPC Uthmanic Script HAFS (يتطلب ترخيصاً من مجمع الملك فهد)
واحفظه في fonts/KFGQPC_Uthmanic_Script.ttf ثم فعّله في lib/core/theme/app_theme.dart
(const AppTheme.displayFont = 'KFGQPC_Uthmanic_Script').
