// import 'package:flutter/material.dart';
// import 'package:clay_containers/clay_containers.dart';

// /// A reusable neumorphic button with customizable appearance and animations
// class NeumorphicButton extends StatefulWidget {
//   final VoidCallback? onPressed;
//   final Widget child;
//   final double? width;
//   final double? height;
//   final EdgeInsetsGeometry? padding;
//   final Color? color;
//   final Duration animationDuration;
//   final bool isEnabled;
//   final double depth;
//   final double borderRadius;

//   const NeumorphicButton({super.key});

//   const ElevatedButton({
//     super.key,
//     required this.child,
//     this.onPressed,
//     this.width,
//     this.height,
//     this.padding,
//     this.color,
//     this.animationDuration = const Duration(milliseconds: 150),
//     this.isEnabled = true,
//     this.depth = 20.0,
//     this.borderRadius = 12.0,
//   });

//   @override
//   State<NeumorphicButton> createState() => _NeumorphicButtonState();
// }

// class _NeumorphicButtonState extends State<NeumorphicButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: widget.animationDuration,
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _handleTapDown(TapDownDetails details) {
//     if (widget.isEnabled && widget.onPressed != null) {
//       setState(() {
//         _isPressed = true;
//       });
//       _animationController.forward();
//     }
//   }

//   void _handleTapUp(TapUpDetails details) {
//     if (widget.isEnabled && widget.onPressed != null) {
//       setState(() {
//         _isPressed = false;
//       });
//       _animationController.reverse();
//       widget.onPressed?.call();
//     }
//   }

//   void _handleTapCancel() {
//     if (widget.isEnabled && widget.onPressed != null) {
//       setState(() {
//         _isPressed = false;
//       });
//       _animationController.reverse();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final buttonColor = widget.color ?? theme.scaffoldBackgroundColor;

//     return AnimatedBuilder(
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: GestureDetector(
//             onTapDown: _handleTapDown,
//             onTapUp: _handleTapUp,
//             onTapCancel: _handleTapCancel,
//             child: ClayContainer(
//               color: buttonColor,
//               height: widget.height,
//               width: widget.width,
//               depth: _isPressed ? 10 : widget.depth.toInt(),
//               borderRadius: widget.borderRadius,
//               child: Container(
//                 padding: widget.padding ?? const EdgeInsets.all(16),
//                 child: Center(
//                   child: DefaultTextStyle(
//                     style: TextStyle(
//                       color: widget.isEnabled
//                           ? theme.textTheme.bodyMedium?.color
//                           : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
//                     ),
//                     child: widget.child,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
