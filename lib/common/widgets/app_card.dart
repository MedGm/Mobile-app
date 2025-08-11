import 'package:flutter/material.dart';
import 'package:tarl_mobile_app/app/theme/app_colors.dart';

/// Beautiful, reusable card component with various styles
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.gradient,
    this.border,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Border? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(16);
    
    Widget cardChild = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Theme.of(context).cardColor) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: border,
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (onTap != null) {
      cardChild = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: cardChild,
        ),
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: elevation ?? 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: cardChild,
      ),
    );
  }

  /// Creates a gradient card with primary colors
  factory AppCard.gradient({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      gradient: AppColors.primaryGradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Creates a card with success colors
  factory AppCard.success({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      gradient: AppColors.successGradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Creates a card with warning colors
  factory AppCard.warning({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      gradient: AppColors.warningGradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Creates a bordered card
  factory AppCard.outlined({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    Color? borderColor,
    double borderWidth = 1,
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return AppCard(
      key: key,
      border: Border.all(
        color: borderColor ?? AppColors.neutralGray300,
        width: borderWidth,
      ),
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      width: width,
      height: height,
      elevation: 0,
      child: child,
    );
  }
}
