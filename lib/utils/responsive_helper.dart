import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Check if device is mobile (width < 600)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // Check if device is tablet (600 <= width < 900)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  // Check if device is desktop (width >= 900)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  // Get responsive font size with named parameters for different screen sizes
  static double getFontSize(BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return small * 0.95; // Extra small phones
    } else if (width < 600) {
      return small; // Regular phones (small)
    } else if (width < 900) {
      return medium; // Tablets (medium)
    } else {
      return large; // Desktop/Large tablets (large)
    }
  }

  // Get responsive padding with named parameters
  static double getPadding(BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return small * 0.9;
    } else if (width < 600) {
      return small;
    } else if (width < 900) {
      return medium;
    } else {
      return large;
    }
  }

  // Get grid cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 2; // Mobile: 2 columns
    } else if (width < 900) {
      return 3; // Tablet: 3 columns
    } else {
      return 4; // Desktop: 4 columns
    }
  }

  // Get max cross axis extent for grid
  static double getMaxCrossAxisExtent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return 160; // Small phones
    } else if (width < 600) {
      return 200; // Regular phones
    } else if (width < 900) {
      return 250; // Tablets
    } else {
      return 300; // Desktop
    }
  }

  // Get child aspect ratio for grid items
  static double getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return 0.65; // Smaller phones need more vertical space
    } else if (width < 600) {
      return 0.7; // Regular phones
    } else {
      return 0.75; // Tablets and desktop
    }
  }

  // Get spacing based on screen size with optional parameters
  static double getSpacing(BuildContext context, {
    double small = 8,
    double medium = 12,
    double large = 16,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return small * 0.8;
    } else if (width < 600) {
      return small;
    } else if (width < 900) {
      return medium;
    } else {
      return large;
    }
  }

  // Get icon size with optional base size parameter
  static double getIconSize(BuildContext context, {double baseSize = 20}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return baseSize * 0.9;
    } else if (width < 600) {
      return baseSize;
    } else if (width < 900) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  // Get button height based on screen size
  static double getButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return 45;
    } else if (width < 600) {
      return 50;
    } else if (width < 900) {
      return 54;
    } else {
      return 56;
    }
  }

  // Get screen orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
