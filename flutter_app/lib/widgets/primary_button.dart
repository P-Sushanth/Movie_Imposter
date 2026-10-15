import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant {
  primary,
  secondary,
  danger,
  ghost,
}

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPress;
  final bool disabled;
  final ButtonVariant variant;
  final double? width;
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPress,
    this.disabled = false,
    this.variant = ButtonVariant.primary,
    this.width,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    Color getBgColor() {
      if (disabled) return AppColors.surfaceBorder;
      switch (variant) {
        case ButtonVariant.primary:
          return AppColors.primary;
        case ButtonVariant.secondary:
          return AppColors.surfaceElevated;
        case ButtonVariant.danger:
          return AppColors.danger;
        case ButtonVariant.ghost:
          return Colors.transparent;
      }
    }

    Color getTextColor() {
      if (disabled) return AppColors.textMuted;
      switch (variant) {
        case ButtonVariant.primary:
        case ButtonVariant.danger:
          return AppColors.textOnPrimary;
        case ButtonVariant.secondary:
        case ButtonVariant.ghost:
          return AppColors.textPrimary;
      }
    }

    BorderSide getBorder() {
      if (variant == ButtonVariant.secondary) {
        return const BorderSide(color: AppColors.surfaceBorder, width: 1);
      }
      return BorderSide.none;
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBgColor(),
          disabledBackgroundColor: AppColors.surfaceBorder,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: getBorder(),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: getTextColor(),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
