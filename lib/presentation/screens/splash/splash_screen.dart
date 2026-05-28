import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _peBlue   = Color(0xFF1B3F6B);
const _peOrange = Color(0xFFE87722);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(
        parent: _entryController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.elasticOut));
    _slideAnim = Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Blue header wave ──────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: size.height * 0.32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_peBlue, Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(52),
                  bottomRight: Radius.circular(52),
                ),
              ),
            ),
          ),

          // ── Decorative circles ────────────────────────────────────
          Positioned(
            top: -50, right: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: 30, left: -35,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _peOrange.withValues(alpha: 0.18),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: size.height * 0.04),

                  // ── Monogram card ───────────────────────────────
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) =>
                        Transform.scale(scale: _pulseAnim.value, child: child),
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 170,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _peBlue.withValues(alpha: 0.2),
                              blurRadius: 36,
                              spreadRadius: 4,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: _peOrange.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          'assets/images/pe_monogram.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── English: Parcel Express ─────────────────────
                  AnimatedBuilder(
                    animation: _slideAnim,
                    builder: (_, child) => Transform.translate(
                        offset: Offset(0, _slideAnim.value), child: child),
                    child: Column(
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Parcel ',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: _peBlue,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              TextSpan(
                                text: 'Express',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: _peOrange,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── Divider bar orange + blue ───────────────
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56, height: 3,
                              decoration: BoxDecoration(
                                color: _peBlue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 56, height: 3,
                              decoration: BoxDecoration(
                                color: _peOrange,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ── Arabic: بارسل إكسبريس ───────────────────
                        RichText(
                          textDirection: TextDirection.rtl,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'إكسبريس ',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: _peBlue,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              TextSpan(
                                text: 'بارسل',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: _peOrange,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Subtitle ────────────────────────────────
                        Text(
                          'HR MANAGEMENT SYSTEM',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            letterSpacing: 2.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 52),

                  // ── Animated loader ─────────────────────────────
                  _DotsLoader(),
                ],
              ),
            ),
          ),

          // ── Bottom tagline ────────────────────────────────────────
          Positioned(
            bottom: 36, left: 0, right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: _peOrange, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fast & Reliable',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: _peBlue, shape: BoxShape.circle),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated dots loader ──────────────────────────────────────────────────────

class _DotsLoader extends StatefulWidget {
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final val = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = val < 0.5
                ? 0.5 + (val / 0.5) * 0.7
                : 1.2 - ((val - 0.5) / 0.5) * 0.7;
            final opacity = val < 0.5
                ? 0.3 + (val / 0.5) * 0.7
                : 1.0 - ((val - 0.5) / 0.5) * 0.7;
            final color = i == 1 ? _peOrange : _peBlue;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale.clamp(0.5, 1.2),
                child: Container(
                  width: 9, height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: opacity.clamp(0.3, 1.0)),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
