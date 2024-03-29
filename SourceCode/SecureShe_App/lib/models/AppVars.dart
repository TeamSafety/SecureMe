import 'package:flutter/material.dart';

class AppVars {
  static Color primary = Colors.white;
  static Color secondary = const Color(0xff2F2C23);
  static Color accent = const Color(0xffFF8D83);

  static double pagePadding = 20;
  static double sectionPadding = 24;
  static double titleMargin = 16;
  static double elementMargin = 8;

  static double bigHeader = 34;
  static double textHeader = 20;
  static double textTitle = 16;
  static double textHref = 16;

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: AppVars.primary,
    backgroundColor: AppVars.accent,
    shadowColor: AppVars.secondary.withOpacity(0.8),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );
}
