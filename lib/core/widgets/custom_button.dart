import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final bool iconOnRight;
  final double borderRadius;
  final double fontSize;
  final double height;
  final EdgeInsetsGeometry? padding;
  final FontWeight fontWeight;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.iconOnRight = false,
    this.borderRadius = 12,
    this.fontSize = 16,
    this.height = 50,
    this.padding,
    this.fontWeight = FontWeight.bold,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? (isOutlined ? Colors.transparent : Colors.blueAccent);
    final Color txtColor = textColor ?? (isOutlined ? Colors.blueAccent : Colors.white);
    final Color brColor = borderColor ?? Colors.blueAccent;

    final Widget childContent = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: txtColor,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: iconOnRight ? TextDirection.rtl : TextDirection.ltr,
            children: [
              if (icon != null) Icon(icon, color: txtColor, size: 20),
              if (icon != null) const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: txtColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: bg,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: isOutlined
                ? BorderSide(color: brColor, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: childContent,
      ),
    );
  }
}
