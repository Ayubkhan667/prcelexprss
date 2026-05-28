import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Sound Service ────────────────────────────────────────────────────────────

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _confirmPlayer = AudioPlayer();
  final AudioPlayer _rejectPlayer = AudioPlayer();
  Uint8List? _clickBytes;
  Uint8List? _confirmBytes;
  Uint8List? _rejectBytes;
  Timer? _pendingClick;
  Future<void>? _initializing;
  DateTime _lastClickAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _ready = false;

  Future<void> init() {
    if (_ready) return Future.value();
    final initializing = _initializing;
    if (initializing != null) return initializing;
    _initializing = _init();
    return _initializing!;
  }

  Future<void> _init() async {
    _clickBytes = _buildClickWav();
    _confirmBytes = _buildConfirmWav();
    _rejectBytes = _buildRejectWav();
    try {
      await Future.wait([
        _clickPlayer.setPlayerMode(PlayerMode.lowLatency),
        _confirmPlayer.setPlayerMode(PlayerMode.lowLatency),
        _rejectPlayer.setPlayerMode(PlayerMode.lowLatency),
      ]);
    } catch (_) {
      // Sound support differs by platform/device; UI should never fail for it.
    } finally {
      _ready = true;
      _initializing = null;
    }
  }

  Future<void> playClick({
    Duration delay = Duration.zero,
  }) async {
    if (delay > Duration.zero) {
      if (DateTime.now().difference(_lastClickAt) <
          const Duration(milliseconds: 120)) {
        return;
      }
      _pendingClick?.cancel();
      _pendingClick = Timer(delay, () {
        _pendingClick = null;
        unawaited(_playClickNow());
      });
      return;
    }
    cancelPendingClick();
    await _playClickNow();
  }

  Future<void> playConfirm() async {
    cancelPendingClick();
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
    await _play(_confirmPlayer, _confirmBytes);
  }

  Future<void> playReject() async {
    cancelPendingClick();
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
    await _play(_rejectPlayer, _rejectBytes);
  }

  void cancelPendingClick() {
    _pendingClick?.cancel();
    _pendingClick = null;
  }

  Future<void> _playClickNow() async {
    if (!_ready) await init();
    final now = DateTime.now();
    if (now.difference(_lastClickAt) < const Duration(milliseconds: 45)) {
      return;
    }
    _lastClickAt = now;
    await _play(_clickPlayer, _clickBytes);
  }

  Future<void> _play(AudioPlayer player, Uint8List? bytes) async {
    try {
      if (!_ready) await init();
      if (bytes == null) return;
      await player.stop();
      await player.play(BytesSource(bytes));
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

  static Uint8List _buildConfirmWav() {
    const rate = 22050;
    const durationMs = 180;
    final samples = rate * durationMs ~/ 1000;
    var phase = 0.0;

    return _buildWav(samples, (i) {
      final t = i / rate;
      final progress = i / (samples - 1);
      final ms = t * 1000;
      if (ms > 78 && ms < 98) return 0;

      final isSecondTone = ms >= 98;
      final segmentProgress = isSecondTone ? (ms - 98) / 82 : ms / 78;
      final attackRelease = math.sin(math.pi * segmentProgress.clamp(0, 1));
      final freq = isSecondTone ? 1040.0 : 660.0;
      phase += 2 * math.pi * freq / rate;
      final envelope = attackRelease * (1 - progress * 0.15);
      return (math.sin(phase) * envelope * 24000).round().clamp(-32768, 32767);
    });
  }

  static Uint8List _buildRejectWav() {
    const rate = 22050;
    const durationMs = 230;
    final samples = rate * durationMs ~/ 1000;
    var phase = 0.0;

    return _buildWav(samples, (i) {
      final t = i / rate;
      final progress = i / (samples - 1);
      final freq =
          310.0 - (progress * 115.0) + math.sin(2 * math.pi * 18 * t) * 22;
      phase += 2 * math.pi * freq / rate;
      final envelope = math.sin(math.pi * progress) *
          (0.82 + 0.18 * math.sin(2 * math.pi * 32 * t));
      return (math.sin(phase) * envelope * 25000).round().clamp(-32768, 32767);
    });
  }

  static Uint8List _buildWav(int samples, int Function(int i) sampleAt) {
    const rate = 22050;
    final bd = ByteData(44 + samples * 2);

    void str(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        bd.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    str(0, 'RIFF');
    bd.setUint32(4, 36 + samples * 2, Endian.little);
    str(8, 'WAVE');
    str(12, 'fmt ');
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);
    bd.setUint16(22, 1, Endian.little);
    bd.setUint32(24, rate, Endian.little);
    bd.setUint32(28, rate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);
    str(36, 'data');
    bd.setUint32(40, samples * 2, Endian.little);

    for (int i = 0; i < samples; i++) {
      bd.setInt16(44 + i * 2, sampleAt(i), Endian.little);
    }
    return bd.buffer.asUint8List();
  }
}

class AppSoundScope extends StatefulWidget {
  const AppSoundScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppSoundScope> createState() => _AppSoundScopeState();
}

class _AppSoundScopeState extends State<AppSoundScope> {
  static const double _maxTapMove = 14;
  final Map<int, Offset> _starts = {};

  bool _isPrimaryPointer(PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.mouse) {
      return event.buttons == kPrimaryMouseButton;
    }
    return true;
  }

  void _handleDown(PointerDownEvent event) {
    if (!_isPrimaryPointer(event)) return;
    _starts[event.pointer] = event.position;
  }

  void _handleMove(PointerMoveEvent event) {
    final start = _starts[event.pointer];
    if (start == null) return;
    if ((event.position - start).distance > _maxTapMove) {
      _starts.remove(event.pointer);
    }
  }

  void _handleUp(PointerUpEvent event) {
    final start = _starts.remove(event.pointer);
    if (start == null) return;
    if ((event.position - start).distance <= _maxTapMove) {
      SoundService.instance.playClick(
        delay: const Duration(milliseconds: 70),
      );
    }
  }

  void _handleCancel(PointerCancelEvent event) {
    _starts.remove(event.pointer);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleDown,
      onPointerMove: _handleMove,
      onPointerUp: _handleUp,
      onPointerCancel: _handleCancel,
      child: widget.child,
    );
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
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
