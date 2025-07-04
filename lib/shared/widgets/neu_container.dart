import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';

class NeuContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final int depth;
  final Color? color;
  final bool spread;
  const NeuContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.depth = 20,
    this.color,
    this.spread = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClayContainer(
        color: color ?? defaultColor,
        height: height,
        width: width,
        borderRadius: borderRadius?.topLeft.x ?? 20,
        depth: depth,
        spread: spread ? 2 : 0,
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class NeuButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final int depth;
  final Color? color;

  const NeuButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.borderRadius = 16,
    this.depth = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);

    return GestureDetector(
      onTap: onPressed,
      child: ClayContainer(
        color: color ?? defaultColor,
        borderRadius: borderRadius,
        depth: depth,
        spread: 1,
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: child,
        ),
      ),
    );
  }
}

class NeuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final int depth;

  const NeuCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 20,
    this.depth = 15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: ClayContainer(
          color: cardColor,
          borderRadius: borderRadius,
          depth: depth,
          spread: 2,
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
