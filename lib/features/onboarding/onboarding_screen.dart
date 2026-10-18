/// شاشة التعريف — ثلاث شرائح (تظهر مرة واحدة فقط)
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/preferences.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _index = 0;

  static const _pages = [
    ('﴿ ﴾', 'قراءة متدبّرة', 'مصحف المدينة بخطه العثماني الأصيل، بلا إعلانات وبلا ضجيج — مساحة سكون كاملة لكتاب الله.'),
    ('🎧', 'استماع رائع', 'أشهر المقرئين بجودة عالية، تكرار الآيات للحفظ، ومؤقت نوم يُطفئ الصوت تدريجياً.'),
    ('🔖', 'وردك وختمتك', 'إشارات ذكية تتبّع تقدمك، ختمة تُعيد توزيع وردك اليومي تلقائياً، ولؤلؤة يومية تُلهِمك.'),
  ];

  void _finish() {
    PreferencesService.instance.setOnboardingDone();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? AppColors.darkEmerald : AppColors.emerald;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: TextButton(
                onPressed: _finish,
                child: Text('تخطي', style: TextStyle(color: muted)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final (icon, title, body) = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 72)),
                        const SizedBox(height: 24),
                        Text(title, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        Text(body,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? accent : muted.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_index < _pages.length - 1) {
                      _ctrl.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    } else {
                      _finish();
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(_index < _pages.length - 1 ? 'التالي' : 'ابدأ الرحلة'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
