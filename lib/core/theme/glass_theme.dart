import 'package:flutter/material.dart';
import 'dart:ui';

class GlassTheme {
  GlassTheme._();

  // Blue Glassmorphism Color Palette
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color secondaryBlue = Color(0xFF00D4FF);
  static const Color darkBlue = Color(0xFF001F3F);
  static const Color lightBlue = Color(0xFF4DA6FF);
  static const Color accentCyan = Color(0xFF00FFF0);

  // Glass Effect Colors
  static const Color glassWhite = Color(0x30FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassHighlight = Color(0x60FFFFFF);

  // Background Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0066FF),
      Color(0xFF00D4FF),
      Color(0xFF7B2CBF),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF001F3F),
      Color(0xFF002855),
      Color(0xFF003E7E),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x20FFFFFF),
    ],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x00FFFFFF),
      Color(0x40FFFFFF),
      Color(0x00FFFFFF),
    ],
  );

  // Glass Container Decoration
  static BoxDecoration glassDecoration({
    double blur = 10,
    double opacity = 0.2,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white.withOpacity(opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: border ?? Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // Elevated Glass Card
  static BoxDecoration elevatedGlassDecoration({
    double blur = 15,
    double opacity = 0.25,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: cardGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.4),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // Button Gradient
  static LinearGradient buttonGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0066FF),
      Color(0xFF00AAFF),
    ],
  );

  // Status Colors
  static const Color successGreen = Color(0xFF00FF88);
  static const Color warningYellow = Color(0xFFFFD700);
  static const Color errorRed = Color(0xFFFF4444);
  static const Color infoBlue = Color(0xFF00D4FF);

  // Text Styles with Glass Effect
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.black26,
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Colors.white70,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    color: Colors.white60,
  );
}

// Glass Morphism Widget
class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const GlassMorphism({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.2,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: GlassTheme.glassDecoration(
        blur: blur,
        opacity: opacity,
        borderRadius: borderRadius,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(opacity),
                  Colors.white.withOpacity(opacity * 0.5),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Animated Glass Button
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 56,
    this.isLoading = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: GlassTheme.buttonGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: GlassTheme.primaryBlue.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
