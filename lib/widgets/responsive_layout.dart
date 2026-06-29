import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key, 
    required this.mobileBody, 
    required this.desktopBody
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Threshold 768px sesuai standar tablet/desktop umum
        if (constraints.maxWidth < 768) {
          return mobileBody;
        } else {
          return desktopBody;
        }
      },
    );
  }
}