import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/tap_effects.dart';

enum AppButtonVariant { primary, accent, danger, outline }

/// Gradient button with press-scale and loading-state animations.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.color,
    this.width = double.infinity,
    this.height = 52.0,
    this.fontSize = 15.0,
    this.borderRadius = 14.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;

  /// Override tint for outline variant (e.g. AppColors.error for a red outline).
  final Color? color;

  final double width;
  final double height;
  final double fontSize;
  final double borderRadius;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 85),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _disabled => widget.isLoading || widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final bool isOutline = widget.variant == AppButtonVariant.outline;
    final Color tint = widget.color ??
        switch (widget.variant) {
          AppButtonVariant.accent => AppColors.accent,
          AppButtonVariant.danger => AppColors.error,
          _ => AppColors.primary,
        };

    final LinearGradient? gradient = isOutline || _disabled
        ? null
        : LinearGradient(
            colors: switch (widget.variant) {
              AppButtonVariant.accent => const [
                  Color(0xFFFF6B35),
                  Color(0xFFFF8A65)
                ],
              AppButtonVariant.danger => const [
                  Color(0xFFC62828),
                  Color(0xFFE53935)
                ],
              _ => const [Color(0xFF1565C0), Color(0xFF1E88E5)],
            },
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );

    final Color fgColor = isOutline ? tint : Colors.white;

    return GestureDetector(
      onTapDown: _disabled ? null : (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: _disabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              SoundService.instance.playClick();
              widget.onPressed!();
            },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _disabled ? 0.58 : 1.0,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradient,
                color: _disabled && !isOutline
                    ? AppColors.primaryLight.withValues(alpha: 0.4)
                    : (isOutline ? tint.withValues(alpha: 0.05) : null),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: isOutline
                    ? Border.all(
                        color: tint.withValues(alpha: 0.55),
                        width: 1.5,
                      )
                    : null,
                boxShadow: _disabled || isOutline
                    ? const []
                    : [
                        BoxShadow(
                          color: tint.withValues(alpha: 0.28),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: fgColor,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: fgColor, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w700,
                              color: fgColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
