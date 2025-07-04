// import 'package:flutter/material.dart';

// /// Custom Neumorphic Container widget that's compatible with modern Flutter
// class NeumorphicContainer extends StatelessWidget {
//   final Widget? child;
//   final double width;
//   final double height;
//   final EdgeInsetsGeometry? margin;
//   final EdgeInsetsGeometry? padding;
//   final Color? color;
//   final double borderRadius;
//   final double depth;
//   final bool inset;
//   final NeumorphicShape shape;

//   const NeumorphicContainer({
//     super.key,
//     this.child,
//     this.width = 100,
//     this.height = 100,
//     this.margin,
//     this.padding,
//     this.color,
//     this.borderRadius = 12.0,
//     this.depth = 6.0,
//     this.inset = false,
//     this.shape = // NeumorphicShape.flat,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final backgroundColor = color ?? theme.scaffoldBackgroundColor;
    
//     return Container(
//       width: width,
//       height: height,
//       margin: margin,
//       padding: padding,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(borderRadius),
//         boxShadow: _getBoxShadows(backgroundColor),
//       ),
//       child: child,
//     );
//   }

//   List<BoxShadow> _getBoxShadows(Color backgroundColor) {
//     if (shape == // NeumorphicShape.flat) {
//       return [
//         BoxShadow(
//           color: _darken(backgroundColor, 0.15),
//           offset: Offset(depth, depth),
//           blurRadius: depth * 2,
//           spreadRadius: 0,
//         ),
//         BoxShadow(
//           color: _lighten(backgroundColor, 0.15),
//           offset: Offset(-depth, -depth),
//           blurRadius: depth * 2,
//           spreadRadius: 0,
//         ),
//       ];
//     } else if (shape == // NeumorphicShape.concave) {
//       return [
//         BoxShadow(
//           color: _darken(backgroundColor, 0.2),
//           offset: Offset(-depth, -depth),
//           blurRadius: depth * 2,
//           spreadRadius: 0,
//         ),
//         BoxShadow(
//           color: _lighten(backgroundColor, 0.2),
//           offset: Offset(depth, depth),
//           blurRadius: depth * 2,
//           spreadRadius: 0,
//         ),
//       ];
//     } else if (shape == // NeumorphicShape.convex) {
//       return [
//         BoxShadow(
//           color: _lighten(backgroundColor, 0.1),
//           offset: Offset(-depth / 2, -depth / 2),
//           blurRadius: depth,
//           spreadRadius: 0,
//         ),
//         BoxShadow(
//           color: _darken(backgroundColor, 0.1),
//           offset: Offset(depth / 2, depth / 2),
//           blurRadius: depth,
//           spreadRadius: 0,
//         ),
//       ];
//     }
//     return [];
//   }

//   Color _lighten(Color color, double amount) {
//     final hsl = HSLColor.fromColor(color);
//     return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
//   }

//   Color _darken(Color color, double amount) {
//     final hsl = HSLColor.fromColor(color);
//     return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
//   }
// }

// /// Custom Neumorphic Button widget
// class NeumorphicButton extends StatefulWidget {
//   final Widget? child;
//   final VoidCallback? onPressed;
//   final double width;
//   final double height;
//   final EdgeInsetsGeometry? margin;
//   final EdgeInsetsGeometry? padding;
//   final Color? color;
//   final double borderRadius;
//   final double depth;

//   const ElevatedButton({
//     super.key,
//     this.child,
//     this.onPressed,
//     this.width = 100,
//     this.height = 50,
//     this.margin,
//     this.padding,
//     this.color,
//     this.borderRadius = 12.0,
//     this.depth = 6.0,
//   });

//   @override
//   State<NeumorphicButton> createState() => _NeumorphicButtonState();
// }

// class _NeumorphicButtonState extends State<NeumorphicButton> {
//   bool _isPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final backgroundColor = widget.color ?? theme.scaffoldBackgroundColor;
    
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _isPressed = true),
//       onTapUp: (_) => setState(() => _isPressed = false),
//       onTapCancel: () => setState(() => _isPressed = false),
//       onTap: widget.onPressed,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         width: widget.width,
//         height: widget.height,
//         margin: widget.margin,
//         padding: widget.padding ?? const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(widget.borderRadius),
//           boxShadow: _isPressed ? _getPressedShadows(backgroundColor) : _getNormalShadows(backgroundColor),
//         ),
//         child: widget.child,
//       ),
//     );
//   }

//   List<BoxShadow> _getNormalShadows(Color backgroundColor) {
//     return [
//       BoxShadow(
//         color: _darken(backgroundColor, 0.15),
//         offset: Offset(widget.depth, widget.depth),
//         blurRadius: widget.depth * 2,
//         spreadRadius: 0,
//       ),
//       BoxShadow(
//         color: _lighten(backgroundColor, 0.15),
//         offset: Offset(-widget.depth, -widget.depth),
//         blurRadius: widget.depth * 2,
//         spreadRadius: 0,
//       ),
//     ];
//   }

//   List<BoxShadow> _getPressedShadows(Color backgroundColor) {
//     return [
//       BoxShadow(
//         color: _darken(backgroundColor, 0.2),
//         offset: Offset(widget.depth / 2, widget.depth / 2),
//         blurRadius: widget.depth,
//         spreadRadius: 0,
//       ),
//       BoxShadow(
//         color: _lighten(backgroundColor, 0.1),
//         offset: Offset(-widget.depth / 4, -widget.depth / 4),
//         blurRadius: widget.depth / 2,
//         spreadRadius: 0,
//       ),
//     ];
//   }

//   Color _lighten(Color color, double amount) {
//     final hsl = HSLColor.fromColor(color);
//     return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
//   }

//   Color _darken(Color color, double amount) {
//     final hsl = HSLColor.fromColor(color);
//     return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
//   }
// }

// /// Custom Neumorphic Card widget
// class NeumorphicCard extends StatelessWidget {
//   final Widget? child;
//   final double? width;
//   final double? height;
//   final EdgeInsetsGeometry? margin;
//   final EdgeInsetsGeometry? padding;
//   final Color? color;
//   final double borderRadius;
//   final double depth;

//   const NeumorphicCard({
//     super.key,
//     this.child,
//     this.width,
//     this.height,
//     this.margin,
//     this.padding,
//     this.color,
//     this.borderRadius = 16.0,
//     this.depth = 8.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final backgroundColor = color ?? theme.cardColor;
    
//     return Container(
//       width: width,
//       height: height,
//       margin: margin,
//       padding: padding ?? const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(borderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: _darken(backgroundColor, 0.15),
//             offset: Offset(depth, depth),
//             blurRadius: depth * 2,
//             spreadRadius: 0,
//           ),
//           BoxShadow(
//             color: _lighten(backgroundColor, 0.15),
//             offset: Offset(-depth, -depth),
//             blurRadius: depth * 2,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Color _lighten(Color color, double amount) {
//     final hsl = HSLColor.fromColor(color);
//     return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
//   }

//   Color _darken(Color color, double amount) {
//     final hsl = HSLColor.fromColor(color);
//     return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
//   }
// }

// /// Neumorphic shape types
// enum NeumorphicShape {
//   flat,
//   concave,
//   convex,
// }

// /// Neumorphic theme extension for consistent styling
// extension NeumorphicTheme on ThemeData {
//   Color get neumorphicBackgroundColor => scaffoldBackgroundColor;
  
//   Color get neumorphicLightShadow {
//     final hsl = HSLColor.fromColor(scaffoldBackgroundColor);
//     return hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
//   }
  
//   Color get neumorphicDarkShadow {
//     final hsl = HSLColor.fromColor(scaffoldBackgroundColor);
//     return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
//   }
// }
