import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    // Navigate after animation plays once
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigate();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate() {
    Navigator.pushReplacementNamed(context, '/g');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top spacer ─────────────────────────────────
            const Spacer(flex: 2),

            // ── App Icon / Lottie ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Lottie.asset(
                'assets/lottie/splash.json',
                controller: _controller,
                onLoaded: (composition) {
                  // Play at 1.2x speed so it doesn't feel slow
                  _controller
                    ..duration = composition.duration * 0.85
                    ..forward();
                },
                width: 260,
                height: 260,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 32),

            // ── App Name ───────────────────────────────────
            const Text(
              'PayMinder',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            // ── Tagline ────────────────────────────────────
            const Text(
              'Never miss a bill again',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),

            // ── Bottom spacer ──────────────────────────────
            const Spacer(flex: 3),

            // ── Bottom branding ────────────────────────────
            const Padding(
              padding: EdgeInsets.only(bottom: 32),
              child: Text(
                'Manage • Track • Remind',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}