import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1000;
  
  // Check device type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;
  
  // Get responsive value based on screen size
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
  
  // Get responsive padding
  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(
        context: context,
        mobile: 16.0,
        tablet: 32.0,
        desktop: 48.0,
      ),
      vertical: value(
        context: context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      ),
    );
  }
  
  // Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return baseSize * 0.85;
    if (width < tabletBreakpoint) return baseSize * 0.95;
    return baseSize;
  }
  
  // Get responsive spacing
  static double spacing(BuildContext context, double baseSpacing) {
    return value(
      context: context,
      mobile: baseSpacing * 0.75,
      tablet: baseSpacing * 0.9,
      desktop: baseSpacing,
    );
  }
}

// Widget للتحكم في Layout بناءً على حجم الشاشة
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Responsive.tabletBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Responsive.mobileBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}