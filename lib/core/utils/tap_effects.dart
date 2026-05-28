import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Sound Service ────────────────────────────────────────────────────────────

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();
  Uint8List? _clickBytes;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    _clickBytes = _buildClickWav();
    await _player.setPlayerMode(PlayerMode.lowLatency);
    _ready = true;
  }

  Future<void> playClick() async {
    if (!_ready) await init();
    try {
      await _player.play(BytesSource(_clickBytes!));
    } catch (_) {
      // Silently ignore audio errors so UI is never blocked
    }
  }

  // Generates a 40ms exponentially-decaying sine click sound as PCM WAV bytes
  static Uint8List _buildClickWav() {
    const rate = 22050;
    const samples = rate * 40 ~/ 1000; // 882 samples
    final bd = ByteData(44 + samples * 2);

    void str(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        bd.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    // RIFF header
    str(0, 'RIFF');
    bd.setUint32(4, 36 + samples * 2, Endian.little);
    str(8, 'WAVE');
    // fmt chunk
    str(12, 'fmt ');
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little); // PCM
    bd.setUint16(22, 1, Endian.little); // mono
    bd.setUint32(24, rate, Endian.little);
    bd.setUint32(28, rate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);
    // data chunk
    str(36, 'data');
    bd.setUint32(40, samples * 2, Endian.little);
    for (int i = 0; i < samples; i++) {
      final t = i / rate;
      final envelope = math.exp(-t * 130.0);
      final v = (envelope * math.sin(2 * math.pi * 900 * t) * 26000)
          .round()
          .clamp(-32768, 32767);
      bd.setInt16(44 + i * 2, v, Endian.little);
    }
    return bd.buffer.asUint8List();
  }
}

// ─── TapEffect Widget ─────────────────────────────────────────────────────────

/// Wraps any widget with:
///  • elastic scale-down-then-spring-back on press
///  • haptic + click sound on tap
///  • optional ripple overlay
class TapEffect extends StatefulWidget {
  const TapEffect({
    super.key,
    required this.onTap,
    required this.child,
    this.scaleTo = 0.93,
    this.borderRadius = 12.0,
    this.enableSound = true,
    this.enableHaptic = true,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double scaleTo;
  final double borderRadius;
  final bool enableSound;
  final bool enableHaptic;

  @override
  State<TapEffect> createState() => _TapEffectState();
}

class _TapEffectState extends State<TapEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 480),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleTo).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    SoundService.instance.init();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onUp(TapUpDetails _) {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  void _onCancel() {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  void _onTap() {
    if (widget.onTap == null) return;
    if (widget.enableHaptic) HapticFeedback.lightImpact();
    if (widget.enableSound) SoundService.instance.playClick();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onDown,
      onTapUp: _onUp,
      onTapCancel: _onCancel,
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          return Transform.scale(
            scale: _scale.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: _pressed
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.0),
                          blurRadius: 0,
                        )
                      ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

// ─── Animated Nav Item ────────────────────────────────────────────────────────

/// Wraps a bottom-nav item or menu tile with sound + scale feedback.
class NavItemEffect extends StatefulWidget {
  const NavItemEffect({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<NavItemEffect> createState() => _NavItemEffectState();
}

class _NavItemEffectState extends State<NavItemEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 350),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: () {
        HapticFeedback.selectionClick();
        SoundService.instance.playClick();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
