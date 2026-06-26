import React, { useState } from "react";
import { C, DartCode, FlutterBadge } from "./DSTokens";
import { SectionLabel } from "./ColorTokens";

const files = [
  {
    filename: "app_colors.dart",
    label: "Color Constants",
    emoji: "🎨",
    code: `// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ── Primary palette ──────────────────────
  static const Color kPrimary    = Color(0xFF8B6248); // Chestnut Brown
  static const Color kSecondary  = Color(0xFFA67C5B); // Warm Caramel
  static const Color kAccent     = Color(0xFFC9956C); // Sandy Gold

  // ── Backgrounds & Surfaces ───────────────
  static const Color kBackground = Color(0xFFF5EDE3); // Linen Cream
  static const Color kSurface    = Color(0xFFFDF9F5); // Warm White
  static const Color kOnPrimary  = Color(0xFFFFFFFF); // White on primary

  // ── Text ─────────────────────────────────
  static const Color kTextDark   = Color(0xFF3A2212); // Deep Espresso

  // ── Semantic ─────────────────────────────
  static const Color kError      = Color(0xFFB85050); // Muted Brick Red
  static const Color kSuccess    = Color(0xFF5E876A); // Sage Green
  static const Color kWarning    = Color(0xFFC9956C); // Sandy (same as accent)
  static const Color kSick       = Color(0xFF8C7AA9); // Muted Purple
  static const Color kUnknown    = Color(0xFF9E9E9E); // Grey
}`,
  },
  {
    filename: "app_theme.dart",
    label: "ThemeData",
    emoji: "🎛️",
    code: `// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary:    AppColors.kPrimary,
      secondary:  AppColors.kSecondary,
      surface:    AppColors.kSurface,
      error:      AppColors.kError,
      onPrimary:  AppColors.kOnPrimary,
      onSurface:  AppColors.kTextDark,
    ),
    scaffoldBackgroundColor: AppColors.kBackground,
    appBarTheme: AppBarTheme(
      backgroundColor:  AppColors.kPrimary,
      foregroundColor:  AppColors.kOnPrimary,
      elevation:        0,
      centerTitle:      false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:  AppColors.kPrimary,
        foregroundColor:  AppColors.kOnPrimary,
        minimumSize:      const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.kPrimary,
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: AppColors.kPrimary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:           true,
      fillColor:        AppColors.kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.kTextDark.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.kError, width: 1.5),
      ),
      labelStyle:  TextStyle(color: AppColors.kTextDark.withOpacity(0.65)),
      hintStyle:   TextStyle(color: AppColors.kTextDark.withOpacity(0.4)),
    ),
    cardTheme: CardThemeData(
      color:        AppColors.kSurface,
      elevation:    1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    textTheme: GoogleFonts.nunitoSansTextTheme().copyWith(
      displayLarge:   GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800),
      headlineMedium: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700),
      titleLarge:     GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium:    GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge:      GoogleFonts.nunitoSans(fontSize: 15, fontWeight: FontWeight.w400),
      bodyMedium:     GoogleFonts.nunitoSans(fontSize: 13, fontWeight: FontWeight.w400),
      labelLarge:     GoogleFonts.nunitoSans(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.6),
      bodySmall:      GoogleFonts.nunitoSans(fontSize: 11, fontWeight: FontWeight.w400),
    ),
  );
}`,
  },
  {
    filename: "status_chip.dart",
    label: "StatusChip Widget",
    emoji: "🏷️",
    code: `// lib/widgets/status_chip.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum AnimalStatus { healthy, needsFeeding, injured, sick, unknown }

class StatusChip extends StatelessWidget {
  final AnimalStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label:           Text(_label, style: TextStyle(color: _textColor, fontSize: 11, fontWeight: FontWeight.w700)),
      backgroundColor: _bgColor,
      side:            BorderSide(color: _borderColor),
      padding:         const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity:   VisualDensity.compact,
      avatar:          Text(_icon, style: const TextStyle(fontSize: 10)),
    );
  }

  String get _label => switch (status) {
    AnimalStatus.healthy      => 'Healthy',
    AnimalStatus.needsFeeding => 'Needs Feeding',
    AnimalStatus.injured      => 'Injured',
    AnimalStatus.sick         => 'Sick',
    AnimalStatus.unknown      => 'Unknown',
  };

  String get _icon => switch (status) {
    AnimalStatus.healthy      => '🟢',
    AnimalStatus.needsFeeding => '🟡',
    AnimalStatus.injured      => '🔴',
    AnimalStatus.sick         => '🟣',
    AnimalStatus.unknown      => '⚪',
  };

  Color get _textColor => switch (status) {
    AnimalStatus.healthy      => AppColors.kSuccess,
    AnimalStatus.needsFeeding => const Color(0xFF8A5E20),
    AnimalStatus.injured      => AppColors.kError,
    AnimalStatus.sick         => AppColors.kSick,
    AnimalStatus.unknown      => AppColors.kUnknown,
  };

  Color get _bgColor => _textColor.withOpacity(0.12);
  Color get _borderColor => _textColor.withOpacity(0.35);
}`,
  },
];

export function ThemeCode() {
  const [activeFile, setActiveFile] = useState(0);

  return (
    <section>
      <SectionLabel
        icon="🔧"
        title="Flutter Dart Code — Design Tokens"
        sub="Ready-to-paste files: app_colors.dart · app_theme.dart · status_chip.dart"
      />

      {/* File tabs */}
      <div className="flex gap-2 mb-4 flex-wrap">
        {files.map((f, i) => (
          <button
            key={f.filename}
            onClick={() => setActiveFile(i)}
            className="flex items-center gap-2 px-4 py-2.5 rounded-xl transition-all"
            style={{
              backgroundColor: activeFile === i ? C.primary : `${C.primary}12`,
              color: activeFile === i ? "#fff" : C.primary,
              fontWeight: 700,
              fontSize: 12,
              border: `1.5px solid ${activeFile === i ? C.primary : `${C.primary}30`}`,
              boxShadow: activeFile === i ? `0 3px 10px ${C.primary}40` : "none",
            }}
          >
            <span>{f.emoji}</span>
            <code style={{ fontFamily: "monospace", fontSize: 11 }}>{f.filename}</code>
          </button>
        ))}
      </div>

      {/* Active file code */}
      <DartCode code={files[activeFile].code} />

      {/* pubspec.yaml dependency note */}
      <div
        className="mt-4 rounded-2xl p-4 border"
        style={{ backgroundColor: `${C.primary}08`, borderColor: `${C.primary}20` }}
      >
        <p className="flex items-center gap-2 mb-2" style={{ color: C.primary, fontWeight: 700, fontSize: 12 }}>
          <span>📦</span> Required pubspec.yaml dependencies
        </p>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
          {[
            { pkg: "google_fonts: ^6.2.1",     use: "Poppins + Nunito Sans" },
            { pkg: "flutter_svg: ^2.0.9",       use: "SVG icon support" },
            { pkg: "image_picker: ^1.0.7",      use: "Animal photo upload" },
          ].map((d) => (
            <div key={d.pkg} className="flex items-start gap-2">
              <FlutterBadge label={d.pkg} />
              <span style={{ color: C.text, opacity: 0.5, fontSize: 10, marginTop: 1 }}>— {d.use}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
