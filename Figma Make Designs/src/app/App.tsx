import React, { useState } from "react";
import { C } from "./components/ds/DSTokens";
import { ColorTokens } from "./components/ds/ColorTokens";
import { Typography } from "./components/ds/Typography";
import { Buttons } from "./components/ds/Buttons";
import { InputFields } from "./components/ds/InputFields";
import { Cards } from "./components/ds/Cards";
import { StatusChipsSection } from "./components/ds/StatusChips";
import { AppBarPreview } from "./components/ds/AppBarPreview";
import { IconsReference } from "./components/ds/IconsReference";
import { ScreenList } from "./components/ds/ScreenList";
import { ThemeCode } from "./components/ds/ThemeCode";
import { MobileFrame } from "./components/screens/MobileFrame";
import { Screen1Splash } from "./components/screens/Screen1Splash";
import { Screen2Login } from "./components/screens/Screen2Login";
import { Screen3Register } from "./components/screens/Screen3Register";
import { Screen4Home } from "./components/screens/Screen4Home";
import { Screen5Report } from "./components/screens/Screen5Report";
import { Screen6Profile } from "./components/screens/Screen6Profile";
import { Screen7Success } from "./components/screens/Screen7Success";
import { Screen8Empty } from "./components/screens/Screen8Empty";

const tabs = [
  { id: "screens", label: "Screens",       icon: "📱" },
  { id: "system",  label: "Design System", icon: "🎨" },
  { id: "code",    label: "Dart Code",     icon: "🔧" },
];

const screenMeta = [
  {
    id: "S1", name: "Splash / Welcome",   uc: "Entry point",       emoji: "🐾",
    flutter: "Scaffold · SafeArea · Center · Column · ElevatedButton",
    widgets: "Scaffold → SafeArea → Center → Column → Icon(pets) → Text ×2 → ElevatedButton",
    done: true,
  },
  {
    id: "S2", name: "Login",              uc: "UC02 Login/Logout", emoji: "🔐",
    flutter: "Scaffold · TextField ×2 (obscureText) · ElevatedButton · TextButton",
    widgets: "Scaffold → Column → TextField (email) → TextField (password, obscure) → ElevatedButton → TextButton",
    done: true,
  },
  {
    id: "S3", name: "Register Account",   uc: "UC01 Register",     emoji: "📝",
    flutter: "Scaffold · AppBar · Form · TextFormField ×4 · SegmentedButton · ElevatedButton",
    widgets: "Scaffold → AppBar → Form → TextFormField ×4 → SegmentedButton → ElevatedButton",
    done: true,
  },
  {
    id: "S4", name: "Home / Animal List", uc: "UC04 View List",    emoji: "🏠",
    flutter: "Scaffold · AppBar · FilterChip ×5 · ListView.builder · Card · FAB.extended",
    widgets: "Scaffold → AppBar → TextField (search) → FilterChip ×5 → ListView.builder → Card → FAB.extended",
    done: true,
  },
  {
    id: "S5", name: "Report Animal",      uc: "UC03 Report",       emoji: "📸",
    flutter: "Scaffold · AppBar · SingleChildScrollView · Container (camera) · SegmentedButton · TextField ×2 · DropdownButtonFormField · ElevatedButton",
    widgets: "Scaffold → AppBar → SingleChildScrollView → Container(camera_alt) → SegmentedButton → TextField ×2 → DropdownButtonFormField → ElevatedButton",
    done: true,
  },
  {
    id: "S6", name: "Animal Profile",     uc: "UC05 View Profile", emoji: "🐱",
    flutter: "Scaffold · AppBar (back) · ClipRRect · Card · Chip · Row (location_on) · OutlinedButton · ElevatedButton",
    widgets: "Scaffold → AppBar (leading: BackButton) → ClipRRect → Card × 3 → Chip (status) → Row (location_on) → OutlinedButton → ElevatedButton",
    done: true,
  },
  {
    id: "S7", name: "Success Screen",     uc: "Post UC03",         emoji: "✅",
    flutter: "Scaffold · Center · Column · Icon(check_circle) · Card · ElevatedButton · OutlinedButton",
    widgets: "Scaffold → Center → Column → Icon(check_circle) → Card (report summary) → ElevatedButton → OutlinedButton",
    done: true,
  },
  {
    id: "S8", name: "Empty State",        uc: "UC04 no data",      emoji: "🌿",
    flutter: "Scaffold · AppBar · Center · Column · Icon(pets) · Text ×2 · ElevatedButton",
    widgets: "Scaffold → AppBar → Center → Column → Icon(pets, muted) → Text ×2 → ElevatedButton · FAB.extended (visible)",
    done: true,
  },
];

const screenComponents = [
  <Screen1Splash />,
  <Screen2Login />,
  <Screen3Register />,
  <Screen4Home />,
  <Screen5Report />,
  <Screen6Profile />,
  <Screen7Success />,
  <Screen8Empty />,
];

export default function App() {
  const [activeTab, setActiveTab] = useState<"screens" | "system" | "code">("screens");
  const [focusedScreen, setFocusedScreen] = useState<string | null>(null);

  const focusedMeta = focusedScreen ? screenMeta.find((s) => s.id === focusedScreen) : null;

  return (
    <div
      className="min-h-screen"
      style={{
        backgroundColor: "#1A1210",
        fontFamily: "'Segoe UI', system-ui, -apple-system, sans-serif",
      }}
    >
      {/* ── Sticky Header ── */}
      <div className="sticky top-0 z-50" style={{ backgroundColor: C.primary, boxShadow: "0 2px 20px rgba(0,0,0,0.4)" }}>
        <div className="px-6 py-3 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ backgroundColor: "rgba(255,255,255,0.18)" }}>
              <PawIcon size={20} color="white" />
            </div>
            <div>
              <p style={{ color: "#fff", fontWeight: 800, fontSize: 16, lineHeight: 1 }}>UTM Paws-itive</p>
              <p style={{ color: "rgba(255,255,255,0.6)", fontSize: 11 }}>Flutter Design System · Sprint 1 · 8/8 Screens ✅</p>
            </div>
          </div>
          <div
            className="px-3 py-1.5 rounded-full flex items-center gap-1.5"
            style={{ backgroundColor: "rgba(255,255,255,0.15)", border: "1px solid rgba(255,255,255,0.2)" }}
          >
            <div className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: C.accent }} />
            <span style={{ color: "#fff", fontSize: 11, fontWeight: 600 }}>Earthy Warmth ✓</span>
          </div>
        </div>
        {/* Tabs */}
        <div className="flex px-4 gap-1 pb-1" style={{ borderTop: "1px solid rgba(255,255,255,0.12)" }}>
          {tabs.map((t) => (
            <button
              key={t.id}
              onClick={() => setActiveTab(t.id as typeof activeTab)}
              className="flex items-center gap-2 px-5 py-2.5 rounded-t-xl transition-all"
              style={{
                backgroundColor: activeTab === t.id ? "#1A1210" : "transparent",
                color: activeTab === t.id ? C.accent : "rgba(255,255,255,0.7)",
                fontWeight: activeTab === t.id ? 700 : 500,
                fontSize: 13,
              }}
            >
              <span>{t.icon}</span>
              {t.label}
            </button>
          ))}
        </div>
      </div>

      {/* ────────────────────────────────────────────────
          TAB: Screens
      ──────────────────────────────────────────────── */}
      {activeTab === "screens" && (
        <div className="pb-12">

          {/* Banner */}
          <div className="px-6 pt-8 pb-6">
            <div
              className="rounded-2xl p-5 border"
              style={{ backgroundColor: "rgba(255,255,255,0.04)", borderColor: "rgba(255,255,255,0.08)" }}
            >
              <div className="flex items-center gap-3 mb-2 flex-wrap">
                <div className="px-3 py-1 rounded-full text-xs font-bold" style={{ backgroundColor: C.primary, color: "#fff" }}>
                  Sprint 1 · Complete
                </div>
                <div className="px-3 py-1 rounded-full text-xs font-bold" style={{ backgroundColor: `${C.success}25`, color: C.success, border: `1px solid ${C.success}40` }}>
                  ✅ 8 / 8 Screens
                </div>
              </div>
              <p style={{ color: "rgba(255,255,255,0.9)", fontWeight: 700, fontSize: 15, marginBottom: 4 }}>
                All Sprint 1 Screens Designed — UTM Paws-itive
              </p>
              <p style={{ color: "rgba(255,255,255,0.45)", fontSize: 12, lineHeight: 1.6 }}>
                Flutter Material 3 · <strong style={{ color: C.accent }}>390 × 800 mobile frames</strong> · Poppins + Nunito Sans ·
                Earthy Warmth palette · Click any screen to see Flutter widget breakdown.
              </p>

              {/* Screen badges */}
              <div className="flex flex-wrap gap-2 mt-4">
                {screenMeta.map((s) => (
                  <button
                    key={s.id}
                    onClick={() => setFocusedScreen(focusedScreen === s.id ? null : s.id)}
                    className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-xl transition-all"
                    style={{
                      backgroundColor: focusedScreen === s.id ? `${C.primary}50` : "rgba(255,255,255,0.06)",
                      border: `1px solid ${focusedScreen === s.id ? `${C.primary}80` : "rgba(255,255,255,0.08)"}`,
                    }}
                  >
                    <span className="text-xs px-1.5 py-0.5 rounded" style={{ backgroundColor: C.primary, color: "#fff", fontWeight: 700, fontSize: 9 }}>{s.id}</span>
                    <p style={{ color: "rgba(255,255,255,0.65)", fontSize: 11 }}>{s.emoji} {s.name}</p>
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* ── Row 1: S1–S4 ── */}
          <div className="px-6 mb-8">
            <p style={{ color: "rgba(255,255,255,0.35)", fontSize: 11, fontWeight: 700, letterSpacing: 1.2, marginBottom: 16 }}>
              AUTHENTICATION &amp; MAIN SCREENS
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-8 justify-items-center">
              {screenMeta.slice(0, 4).map((meta, i) => (
                <ScreenWrapper
                  key={meta.id}
                  meta={meta}
                  focused={focusedScreen === meta.id}
                  onClick={() => setFocusedScreen(focusedScreen === meta.id ? null : meta.id)}
                >
                  {screenComponents[i]}
                </ScreenWrapper>
              ))}
            </div>
          </div>

          {/* ── Row 2: S5–S8 ── */}
          <div className="px-6">
            <p style={{ color: "rgba(255,255,255,0.35)", fontSize: 11, fontWeight: 700, letterSpacing: 1.2, marginBottom: 16 }}>
              CORE FEATURES &amp; UTILITY SCREENS
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-8 justify-items-center">
              {screenMeta.slice(4, 8).map((meta, i) => (
                <ScreenWrapper
                  key={meta.id}
                  meta={meta}
                  focused={focusedScreen === meta.id}
                  onClick={() => setFocusedScreen(focusedScreen === meta.id ? null : meta.id)}
                >
                  {screenComponents[i + 4]}
                </ScreenWrapper>
              ))}
            </div>
          </div>

          {/* ── Focused screen detail panel ── */}
          {focusedMeta && (
            <div className="px-6 mt-8">
              <div
                className="rounded-2xl p-6 border"
                style={{ backgroundColor: "rgba(255,255,255,0.04)", borderColor: `${C.primary}50` }}
              >
                <div className="flex items-start justify-between gap-4 flex-wrap mb-4">
                  <div>
                    <div className="flex items-center gap-3 mb-2">
                      <span className="px-2.5 py-1 rounded-lg text-xs font-bold" style={{ backgroundColor: C.primary, color: "#fff" }}>
                        {focusedMeta.id}
                      </span>
                      <span style={{ color: "#fff", fontWeight: 800, fontSize: 18 }}>
                        {focusedMeta.emoji} {focusedMeta.name}
                      </span>
                      {focusedMeta.done && (
                        <span className="px-2 py-0.5 rounded-full text-xs font-bold" style={{ backgroundColor: `${C.success}20`, color: C.success }}>
                          ✅ Done
                        </span>
                      )}
                    </div>
                    <p style={{ color: "rgba(255,255,255,0.5)", fontSize: 13, marginBottom: 10 }}>
                      Use Case: <span style={{ color: C.accent, fontWeight: 600 }}>{focusedMeta.uc}</span>
                    </p>
                  </div>
                  <button
                    onClick={() => setFocusedScreen(null)}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl"
                    style={{ backgroundColor: "rgba(255,255,255,0.08)", color: "rgba(255,255,255,0.6)", fontSize: 12 }}
                  >
                    ✕ Close
                  </button>
                </div>
                <div
                  className="flex items-start gap-2.5 px-4 py-3 rounded-xl"
                  style={{ backgroundColor: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.07)" }}
                >
                  <PawIcon size={14} color={C.accent} />
                  <p style={{ color: "rgba(255,255,255,0.6)", fontSize: 11, fontFamily: "monospace", lineHeight: 1.7 }}>
                    {focusedMeta.widgets}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* ── Sprint 1 complete progress card ── */}
          <div className="px-6 mt-8">
            <div
              className="rounded-2xl p-5 border"
              style={{ backgroundColor: "rgba(255,255,255,0.03)", borderColor: "rgba(255,255,255,0.07)" }}
            >
              <div className="flex items-center justify-between mb-4">
                <p style={{ color: "rgba(255,255,255,0.7)", fontWeight: 700, fontSize: 14 }}>
                  📋 Sprint 1 — All Screens Complete
                </p>
                <span style={{ color: C.accent, fontSize: 13, fontWeight: 800 }}>8 / 8 ✅</span>
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 mb-4">
                {screenMeta.map((s) => (
                  <button
                    key={s.id}
                    onClick={() => setFocusedScreen(focusedScreen === s.id ? null : s.id)}
                    className="flex items-center gap-2 rounded-xl px-3 py-2.5 transition-all text-left"
                    style={{
                      backgroundColor: focusedScreen === s.id ? `${C.primary}35` : `${C.primary}18`,
                      border: `1px solid ${focusedScreen === s.id ? `${C.primary}60` : `${C.primary}30`}`,
                    }}
                  >
                    <span style={{ fontSize: 14 }}>✅</span>
                    <div>
                      <p style={{ color: "rgba(255,255,255,0.7)", fontSize: 11, fontWeight: 600 }}>{s.id}</p>
                      <p style={{ color: C.accent, fontSize: 10 }}>{s.name}</p>
                    </div>
                  </button>
                ))}
              </div>
              {/* Full progress bar */}
              <div>
                <div className="flex justify-between mb-1.5">
                  <p style={{ color: "rgba(255,255,255,0.4)", fontSize: 11 }}>Sprint 1 UI progress</p>
                  <p style={{ color: C.success, fontSize: 11, fontWeight: 700 }}>100% Complete 🎉</p>
                </div>
                <div className="rounded-full overflow-hidden" style={{ height: 7, backgroundColor: "rgba(255,255,255,0.08)" }}>
                  <div
                    className="h-full rounded-full"
                    style={{ width: "100%", background: `linear-gradient(90deg, ${C.primary}, ${C.accent}, ${C.success})` }}
                  />
                </div>
              </div>
            </div>
          </div>

        </div>
      )}

      {/* ────────────────────────────────────────────────
          TAB: Design System
      ──────────────────────────────────────────────── */}
      {activeTab === "system" && (
        <div className="max-w-7xl mx-auto px-4 py-8 space-y-12" style={{ backgroundColor: C.background, minHeight: "100vh" }}>
          <div
            className="rounded-2xl p-5 flex items-start gap-4 border"
            style={{ background: `linear-gradient(135deg, ${C.primary}12, ${C.accent}10)`, borderColor: `${C.primary}25` }}
          >
            <div className="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0" style={{ backgroundColor: C.primary }}>
              <span style={{ fontSize: 22 }}>✅</span>
            </div>
            <div>
              <p style={{ color: C.primary, fontWeight: 800, fontSize: 16, marginBottom: 4 }}>
                Palette Confirmed — Option 4: Earthy Warmth 🤎
              </p>
              <p style={{ color: C.text, opacity: 0.65, fontSize: 13, lineHeight: 1.6 }}>
                All design tokens are based on <strong>Chestnut Brown × Linen Cream × Sandy Gold × Sage</strong>.
              </p>
            </div>
          </div>
          <SectionDivider label="01  COLOR TOKENS" />
          <ColorTokens />
          <SectionDivider label="02  TYPOGRAPHY — TextTheme" />
          <Typography />
          <SectionDivider label="03  BUTTON STYLES" />
          <Buttons />
          <SectionDivider label="04  INPUT FIELD STYLES" />
          <InputFields />
          <SectionDivider label="05  CARD STYLES" />
          <Cards />
          <SectionDivider label="06  STATUS CHIPS" />
          <StatusChipsSection />
          <SectionDivider label="07  APPBAR & NAVIGATION" />
          <AppBarPreview />
          <SectionDivider label="08  ICONS REFERENCE" />
          <IconsReference />
          <SectionDivider label="09  SCREEN LIST OVERVIEW" />
          <ScreenList />
        </div>
      )}

      {/* ────────────────────────────────────────────────
          TAB: Dart Code
      ──────────────────────────────────────────────── */}
      {activeTab === "code" && (
        <div className="max-w-7xl mx-auto px-4 py-8 space-y-8" style={{ backgroundColor: C.background, minHeight: "100vh" }}>
          <div
            className="rounded-2xl p-5 border"
            style={{ background: `linear-gradient(135deg, ${C.primary}12, ${C.accent}08)`, borderColor: `${C.primary}25` }}
          >
            <p style={{ color: C.primary, fontWeight: 800, fontSize: 16, marginBottom: 4 }}>
              🔧 Flutter / Dart Design Tokens — Ready to Copy
            </p>
            <p style={{ color: C.text, opacity: 0.65, fontSize: 13, lineHeight: 1.6 }}>
              Three production-ready Dart files for your{" "}
              <code style={{ backgroundColor: `${C.primary}15`, padding: "1px 5px", borderRadius: 4, fontSize: 11 }}>lib/core/theme/</code>{" "}
              folder. Material 3 + Google Fonts (Poppins + Nunito Sans).
            </p>
          </div>
          <ThemeCode />
        </div>
      )}

      {/* Footer */}
      <div className="py-6 text-center border-t" style={{ borderColor: "rgba(255,255,255,0.06)" }}>
        <p style={{ color: "rgba(255,255,255,0.2)", fontSize: 11 }}>
          UTM Paws-itive · Flutter Design System · Sprint 1 Complete · Earthy Warmth · Universiti Teknologi Malaysia
        </p>
      </div>
    </div>
  );
}

// ── Helpers ──────────────────────────────────────────────────────────────────

function PawIcon({ size = 20, color = "white" }: { size?: number; color?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill={color}>
      <ellipse cx="32" cy="44" rx="17" ry="13" />
      <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
      <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
      <ellipse cx="21" cy="17" rx="7" ry="8" />
      <ellipse cx="43" cy="17" rx="7" ry="8" />
    </svg>
  );
}

function ScreenWrapper({
  children,
  meta,
  focused,
  onClick,
}: {
  children: React.ReactNode;
  meta: typeof screenMeta[0];
  focused: boolean;
  onClick: () => void;
}) {
  return (
    <div className="flex flex-col items-center w-full" style={{ maxWidth: 390 }}>
      {/* Screen ID badge */}
      <div className="flex items-center gap-2 mb-3 w-full">
        <span
          className="px-2.5 py-1 rounded-lg"
          style={{ backgroundColor: C.primary, color: "#fff", fontWeight: 700, fontSize: 11 }}
        >
          {meta.id}
        </span>
        <span style={{ color: "rgba(255,255,255,0.85)", fontWeight: 700, fontSize: 13 }}>
          {meta.emoji} {meta.name}
        </span>
        {meta.done && (
          <span style={{ color: C.success, fontSize: 12, marginLeft: "auto" }}>✅</span>
        )}
      </div>

      {/* Mobile frame */}
      <div
        className="cursor-pointer transition-all duration-300 w-full"
        onClick={onClick}
        style={{
          transform: focused ? "scale(1.015)" : "scale(1)",
          filter: focused ? `drop-shadow(0 0 28px ${C.primary}70)` : "none",
        }}
      >
        <MobileFrame>{children}</MobileFrame>
      </div>

      {/* Flutter widget annotation */}
      <div
        className="mt-3 px-4 py-2.5 rounded-xl w-full"
        style={{ backgroundColor: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.07)" }}
      >
        <p style={{ color: "rgba(255,255,255,0.3)", fontSize: 9, fontFamily: "monospace", lineHeight: 1.7 }}>
          {meta.widgets}
        </p>
      </div>

      {/* Use case tag */}
      <div className="mt-2">
        <span
          className="px-2.5 py-1 rounded-full text-xs"
          style={{ backgroundColor: "rgba(255,255,255,0.05)", color: "rgba(255,255,255,0.35)", fontSize: 10 }}
        >
          {meta.uc}
        </span>
      </div>
    </div>
  );
}

function SectionDivider({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-4">
      <div className="flex-1 border-t" style={{ borderColor: "rgba(58,34,18,0.07)" }} />
      <span style={{ color: C.primary, fontSize: 10, fontWeight: 800, letterSpacing: 1.5, opacity: 0.7, whiteSpace: "nowrap" }}>
        {label}
      </span>
      <div className="flex-1 border-t" style={{ borderColor: "rgba(58,34,18,0.07)" }} />
    </div>
  );
}
