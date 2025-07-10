import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xffB51D1E),
      surfaceTint: Color(0xffB51D1E),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdad6),
      onPrimaryContainer: Color(0xff410002),
      secondary: Color(0xff413939),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd8c2bc),
      onSecondaryContainer: Color(0xff2c1510),
      tertiary: Color(0xffA8A7A7),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffe8e8e8),
      onTertiaryContainer: Color(0xff3c3c3c),
      error: Color(0xffB51D1E),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xffffffff),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff49454f),
      outline: Color(0xffA8A7A7),
      outlineVariant: Color(0xffd8c2bc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffffb4ab),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff410002),
      primaryFixedDim: Color(0xffffb4ab),
      onPrimaryFixedVariant: Color(0xff690005),
      secondaryFixed: Color(0xffd8c2bc),
      onSecondaryFixed: Color(0xff2c1510),
      secondaryFixedDim: Color(0xffbca8a2),
      onSecondaryFixedVariant: Color(0xff413939),
      tertiaryFixed: Color(0xffe8e8e8),
      onTertiaryFixed: Color(0xff3c3c3c),
      tertiaryFixedDim: Color(0xffcccccc),
      onTertiaryFixedVariant: Color(0xff5c5c5c),
      surfaceDim: Color(0xffdddcdc),
      surfaceBright: Color(0xffffffff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2f2),
      surfaceContainer: Color(0xfff2eded),
      surfaceContainerHigh: Color(0xffece8e8),
      surfaceContainerHighest: Color(0xffe6e2e2),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff690005),
      surfaceTint: Color(0xffB51D1E),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff8f2726),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3d3434),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5a4f4f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff8c8b8b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffb0afaf),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff690005),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8f2726),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xffffffff),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff454343),
      outline: Color(0xffA8A7A7),
      outlineVariant: Color(0xff7b7776),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffffb4ab),
      primaryFixed: Color(0xff8f2726),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff730a12),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5a4f4f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff433939),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xffb0afaf),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff949393),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdddcdc),
      surfaceBright: Color(0xffffffff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2f2),
      surfaceContainer: Color(0xfff2eded),
      surfaceContainerHigh: Color(0xffece8e8),
      surfaceContainerHighest: Color(0xffe6e2e2),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff410002),
      surfaceTint: Color(0xffB51D1E),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff690005),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2c1510),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff413939),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff6b6b6b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff8c8b8b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff410002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff690005),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xffffffff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff2c1510),
      outline: Color(0xffA8A7A7),
      outlineVariant: Color(0xff454343),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffffb4ab),
      primaryFixed: Color(0xff690005),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff4c0001),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff413939),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2c1510),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff8c8b8b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff706f6f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdddcdc),
      surfaceBright: Color(0xffffffff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f2f2),
      surfaceContainer: Color(0xfff2eded),
      surfaceContainerHigh: Color(0xffece8e8),
      surfaceContainerHighest: Color(0xffe6e2e2),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb4ab),
      surfaceTint: Color(0xffffb4ab),
      onPrimary: Color(0xff690005),
      primaryContainer: Color(0xff8f2726),
      onPrimaryContainer: Color(0xffffdad6),
      secondary: Color(0xffbca8a2),
      onSecondary: Color(0xff2c1510),
      secondaryContainer: Color(0xff413939),
      onSecondaryContainer: Color(0xffd8c2bc),
      tertiary: Color(0xffcccccc),
      onTertiary: Color(0xff3c3c3c),
      tertiaryContainer: Color(0xffA8A7A7),
      onTertiaryContainer: Color(0xffe8e8e8),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff8f2726),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141414),
      onSurface: Color(0xffe6e2e2),
      onSurfaceVariant: Color(0xffd8c2bc),
      outline: Color(0xffA8A7A7),
      outlineVariant: Color(0xff49454f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e2e2),
      inversePrimary: Color(0xffB51D1E),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff410002),
      primaryFixedDim: Color(0xffffb4ab),
      onPrimaryFixedVariant: Color(0xff690005),
      secondaryFixed: Color(0xffd8c2bc),
      onSecondaryFixed: Color(0xff2c1510),
      secondaryFixedDim: Color(0xffbca8a2),
      onSecondaryFixedVariant: Color(0xff413939),
      tertiaryFixed: Color(0xffe8e8e8),
      onTertiaryFixed: Color(0xff3c3c3c),
      tertiaryFixedDim: Color(0xffcccccc),
      onTertiaryFixedVariant: Color(0xffA8A7A7),
      surfaceDim: Color(0xff141414),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0f0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2a2929),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffdad6),
      surfaceTint: Color(0xffffb4ab),
      onPrimary: Color(0xff4c0001),
      primaryContainer: Color(0xffcb5e5e),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc0adad),
      onSecondary: Color(0xff25100c),
      secondaryContainer: Color(0xff877271),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffd0d0d0),
      onTertiary: Color(0xff323232),
      tertiaryContainer: Color(0xffb0afaf),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffdad6),
      onError: Color(0xff4c0001),
      errorContainer: Color(0xffcb5e5e),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141414),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd8c2bc),
      outline: Color(0xffA8A7A7),
      outlineVariant: Color(0xff928d8c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e2e2),
      inversePrimary: Color(0xff8f2726),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff2c0000),
      primaryFixedDim: Color(0xffffb4ab),
      onPrimaryFixedVariant: Color(0xff690005),
      secondaryFixed: Color(0xffd8c2bc),
      onSecondaryFixed: Color(0xff1b0906),
      secondaryFixedDim: Color(0xffbca8a2),
      onSecondaryFixedVariant: Color(0xff413939),
      tertiaryFixed: Color(0xffe8e8e8),
      onTertiaryFixed: Color(0xff282828),
      tertiaryFixedDim: Color(0xffcccccc),
      onTertiaryFixedVariant: Color(0xff8c8b8b),
      surfaceDim: Color(0xff141414),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0f0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2a2929),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffffff),
      surfaceTint: Color(0xffffb4ab),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffb4ab),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffbca8a2),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffffff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffcccccc),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffffff),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffb4ab),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141414),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffA8A7A7),
      outlineVariant: Color(0xffd8c2bc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e2e2),
      inversePrimary: Color(0xff8f2726),
      primaryFixed: Color(0xffffdad6),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb4ab),
      onPrimaryFixedVariant: Color(0xff2c0000),
      secondaryFixed: Color(0xffd8c2bc),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffbca8a2),
      onSecondaryFixedVariant: Color(0xff1b0906),
      tertiaryFixed: Color(0xffe8e8e8),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffcccccc),
      onTertiaryFixedVariant: Color(0xff282828),
      surfaceDim: Color(0xff141414),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0f0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2a2929),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
