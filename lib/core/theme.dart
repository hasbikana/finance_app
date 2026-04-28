import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

final lightTheme = FlexThemeData.light(
  scheme: FlexScheme.blueM3,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 7,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 10,
    blendOnColors: false,
    useM2StyleDividerInM3: true,
    defaultRadius: 18.0,
    inputDecoratorRadius: 22.0,
    cardRadius: 24.0,
    // buttonRadius dihapus karena tidak dikenal di versi terbaru
    fabRadius: 20.0,
    dialogRadius: 28.0,
    bottomSheetRadius: 28.0,
    popupMenuRadius: 16.0,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  fontFamily: GoogleFonts.inter().fontFamily,
);

final darkTheme = FlexThemeData.dark(
  scheme: FlexScheme.blueM3,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 13,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    useM2StyleDividerInM3: true,
    defaultRadius: 18.0,
    inputDecoratorRadius: 22.0,
    cardRadius: 24.0,
    // buttonRadius dihapus
    fabRadius: 20.0,
    dialogRadius: 28.0,
    bottomSheetRadius: 28.0,
    popupMenuRadius: 16.0,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  fontFamily: GoogleFonts.inter().fontFamily,
);