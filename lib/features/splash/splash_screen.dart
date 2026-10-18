/// شاشة البداية — أسود OLED، «إسلام» زمردية، فاصل ذهبي بمعيّن، تاجلاين كريمي
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/preferences.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Timer(const Duration(milliseconds: 2300), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final done = PreferencesService.instance.onboardingDone;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => done ? const HomeScreen() : const OnboardingScreen()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF3AC9A0);
    const gold = Color(0xFFD4A84E);
    const cream = Color(0xFFEFE9D8);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('إسلام',
                      style: TextStyle(
                        fontSize: 92,
                        fontWeight: FontWeight.bold,
                        color: emerald,
                        height: 1.2,
                        fontFamily: AppTheme.displayFont,
                      )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 64, height: 1, color: gold.withOpacity(0.7)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Transform.rotate(
                          angle: 0.7853982,
                          child: Container(width: 10, height: 10, color: gold),
                        ),
                      ),
                      Container(width: 64, height: 1, color: gold.withOpacity(0.7)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('رَفِيقُكَ فِي تَدَبُّرِ كِتَابِ الله',
                      style: TextStyle(
                        fontSize: 21,
                        color: cream,
                        height: 1.9,
                        fontFamily: AppTheme.displayFont,
                      )),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Text('صُمِّم بواسطة إسلام السيد',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white38)),
          ),
        ],
      ),
    );
  }
}
