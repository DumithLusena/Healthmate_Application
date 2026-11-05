import 'package:flutter/material.dart';
import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});
  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  late final Animation<double> _logoScale =
  CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.45, curve: Curves.elasticOut));
  late final Animation<double> _logoFade =
  CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.2, curve: Curves.easeOut));
  late final Animation<double> _ring =
  CurvedAnimation(parent: _c, curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic));
  late final Animation<double> _text =
  CurvedAnimation(parent: _c, curve: const Interval(0.45, 0.8, curve: Curves.easeOut));
  late final Animation<double> _bar =
  CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.brand, AppTheme.brandDeep],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final ringSize = 120 + 140 * _ring.value;
              final ringAlpha = (70 * (1 - _ring.value)).round();
              return Column(children: [
                const Spacer(flex: 3),
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(alignment: Alignment.center, children: [
                    // expanding pulse ring
                    Container(
                      width: ringSize,
                      height: ringSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(ringAlpha),
                      ),
                    ),
                    Opacity(
                      opacity: _logoFade.value.clamp(0.0, 1.0).toDouble(),
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10))],
                          ),
                          child: const Icon(Icons.favorite, size: 62, color: AppTheme.brand),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: _text.value.clamp(0.0, 1.0).toDouble(),
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - _text.value)),
                    child: const Column(children: [
                      Text('HealthMate',
                          style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      SizedBox(height: 6),
                      Text('Find Your Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ]),
                  ),
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _bar.value,
                      minHeight: 5,
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Loading your health data...', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 40),
              ]);
            },
          ),
        ),
      ),
    );
  }
}