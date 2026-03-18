import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF080B1A);
  static const Color backgroundCard = Color(0xFF0D1230);
  static const Color backgroundSurface = Color(0xFF111830);

  static const Color starWhite = Color(0xFFE8EEFF);
  static const Color starDim = Color(0xFF4A5580);
  static const Color starActive = Color(0xFF7EB8F7);
  static const Color starReviewable = Color(0xFFFBD786);
  static const Color starResolved = Color(0xFFB8A4E8);

  static const Color accentBlue = Color(0xFF7EB8F7);
  static const Color accentGold = Color(0xFFFBD786);
  static const Color accentPurple = Color(0xFFB8A4E8);
  static const Color accentPink = Color(0xFFF4A0C4);

  static const Color textPrimary = Color(0xFFE8EEFF);
  static const Color textSecondary = Color(0xFF8A94C0);
  static const Color textHint = Color(0xFF4A5580);

  static const Color divider = Color(0xFF1E2A50);

  // Planet colors - [light, base, dark] gradients for each planet
  static const Color plutoLight = Color(0xFFB8A890);
  static const Color plutoBase = Color(0xFF8B7D6B);
  static const Color plutoDark = Color(0xFF5C4E3C);

  static const Color mercuryLight = Color(0xFFD4D4D8);
  static const Color mercuryBase = Color(0xFFA0A0A8);
  static const Color mercuryDark = Color(0xFF6B6B73);

  static const Color marsLight = Color(0xFFF4A070);
  static const Color marsBase = Color(0xFFE07040);
  static const Color marsDark = Color(0xFF993320);

  static const Color venusLight = Color(0xFFF5E4B8);
  static const Color venusBase = Color(0xFFE0C88A);
  static const Color venusDark = Color(0xFFB89A50);

  static const Color earthLight = Color(0xFF7EC8F7);
  static const Color earthBase = Color(0xFF4A90D9);
  static const Color earthDark = Color(0xFF2A5A8A);

  static const Color neptuneLight = Color(0xFF6B8BE8);
  static const Color neptuneBase = Color(0xFF3D5BC0);
  static const Color neptuneDark = Color(0xFF1E2E80);

  static const Color uranusLight = Color(0xFFA0E8E8);
  static const Color uranusBase = Color(0xFF5CC8D0);
  static const Color uranusDark = Color(0xFF308890);

  static const Color saturnLight = Color(0xFFF0D480);
  static const Color saturnBase = Color(0xFFD4A840);
  static const Color saturnDark = Color(0xFF986820);

  static const Color jupiterLight = Color(0xFFE8B080);
  static const Color jupiterBase = Color(0xFFD08050);
  static const Color jupiterDark = Color(0xFF905030);

  static const Color sunLight = Color(0xFFFFE878);
  static const Color sunBase = Color(0xFFFFCC00);
  static const Color sunDark = Color(0xFFE89800);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlue,
        secondary: AppColors.accentPurple,
        surface: AppColors.backgroundCard,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Pretendard',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
