import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5C2A0A), AppTheme.primary, Color(0xFFB5651D)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.5), width: 2),
              ),
              child: const Center(
                child: Text('قرآن',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 52,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ).animate().scale(
                delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 32),

            // Nom de l'app
            const Text('تعلم القرآن',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 8),

            const Text('APPRENDRE CORAN',
                    style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.accent,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700))
                .animate()
                .fadeIn(delay: 800.ms, duration: 500.ms),

            const SizedBox(height: 60),

            // Bismillah
            const Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        color: Colors.white70,
                        height: 2))
                .animate()
                .fadeIn(delay: 1000.ms, duration: 800.ms),

            const SizedBox(height: 60),

            // Loading indicator
            const SizedBox(
              width: 40,
              height: 4,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white24,
                color: AppTheme.accent,
              ),
            ).animate().fadeIn(delay: 1400.ms),
          ],
        ),
      ),
    );
  }
}
