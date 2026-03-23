import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _moveToCorner = false;

  @override
  void initState() {
    super.initState();
    _playAnimation();
  }

  Future<void> _playAnimation() async {
    // Wait for the initial animations to finish 
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Trigger movement to corner
    if (mounted) {
      setState(() {
        _moveToCorner = true;
      });
    }

    // Wait for movement to finish
    await Future.delayed(const Duration(milliseconds: 1000));

    // Route to main app
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // We animate the positioned widget using a Stack
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8E8EE), // Soft pink
              Color(0xFFE3D5FF), // Soft lavender
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Floating Particles/Shimmer effect (A simple approximation using animate)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/icons/Dressify_withName.png', // Fallback or transparent texture if we had one
                  fit: BoxFit.none,
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.5))
                 .fadeOut(),
              ),
            ),
            
            // Animated Logo
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _moveToCorner ? 60 : MediaQuery.of(context).size.height / 2 - 100,
              right: _moveToCorner ? 30 : MediaQuery.of(context).size.width / 2 - 80,
              width: _moveToCorner ? 60 : 160,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: _moveToCorner ? 0.0 : 1.0, 
                // We'll fade it out as it hits the corner to simulate a seamless transition
                child: Image.asset(
                  "assets/icons/Dressify_withName.png",
                  fit: BoxFit.contain,
                )
                .animate()
                .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 800.ms, curve: Curves.easeOutBack)
                .slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOut)
                .then() // Subtle continuous floating after it appears
                .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.4))
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(begin: -5, end: 5, duration: 1500.ms, curve: Curves.easeInOutSine),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
