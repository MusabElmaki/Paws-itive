import React, { useState } from "react";

interface ColorSwatch {
  label: string;
  hex: string;
  textColor?: string;
}

interface PaletteCardProps {
  number: number;
  name: string;
  tagline: string;
  description: string;
  colors: ColorSwatch[];
  palette: {
    primary: string;
    secondary: string;
    accent: string;
    background: string;
    surface: string;
    text: string;
    error: string;
    success: string;
    primaryText: string;
    surfaceText: string;
  };
  emoji: string;
}

export function PaletteCard({ number, name, tagline, description, colors, palette, emoji }: PaletteCardProps) {
  const [focusedInput, setFocusedInput] = useState(false);

  return (
    <div
      className="rounded-3xl overflow-hidden shadow-2xl border border-black/8"
      style={{ backgroundColor: palette.background }}
    >
      {/* Palette Header */}
      <div className="relative px-8 pt-8 pb-6" style={{ backgroundColor: palette.primary }}>
        <div className="flex items-start justify-between">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span
                className="text-xs px-2 py-0.5 rounded-full"
                style={{
                  backgroundColor: "rgba(255,255,255,0.2)",
                  color: palette.primaryText,
                }}
              >
                Option {number}
              </span>
            </div>
            <h2 className="text-2xl" style={{ color: palette.primaryText, fontWeight: 700 }}>
              {emoji} {name}
            </h2>
            <p className="text-sm mt-1" style={{ color: palette.primaryText, opacity: 0.85 }}>
              {tagline}
            </p>
          </div>
        </div>

        {/* Simulated AppBar */}
        <div className="mt-5 rounded-xl overflow-hidden shadow-lg">
          <div
            className="flex items-center justify-between px-4 py-3"
            style={{ backgroundColor: palette.primary }}
          >
            <div className="flex items-center gap-3">
              <div
                className="w-5 h-5 flex flex-col justify-center gap-1"
                style={{ color: palette.primaryText }}
              >
                <div className="w-full h-0.5 rounded" style={{ backgroundColor: palette.primaryText }} />
                <div className="w-3/4 h-0.5 rounded" style={{ backgroundColor: palette.primaryText }} />
                <div className="w-full h-0.5 rounded" style={{ backgroundColor: palette.primaryText }} />
              </div>
              <div>
                <p className="text-xs" style={{ color: palette.primaryText, opacity: 0.75 }}>
                  UTM Paws-itive
                </p>
                <p style={{ color: palette.primaryText, fontWeight: 700, fontSize: 15 }}>
                  Stray Reports 🐾
                </p>
              </div>
            </div>
            <div className="flex gap-2">
              <div
                className="w-8 h-8 rounded-full flex items-center justify-center"
                style={{ backgroundColor: "rgba(255,255,255,0.15)" }}
              >
                <span style={{ color: palette.primaryText, fontSize: 14 }}>🔔</span>
              </div>
              <div
                className="w-8 h-8 rounded-full flex items-center justify-center"
                style={{ backgroundColor: "rgba(255,255,255,0.15)" }}
              >
                <span style={{ color: palette.primaryText, fontSize: 14 }}>👤</span>
              </div>
            </div>
          </div>
          <div
            className="px-3 py-2 flex gap-2"
            style={{ backgroundColor: palette.primary, borderTop: `1px solid rgba(255,255,255,0.15)` }}
          >
            {["All", "Cats", "Dogs", "Urgent"].map((tab, i) => (
              <div
                key={tab}
                className="px-3 py-1 rounded-full text-xs"
                style={{
                  backgroundColor: i === 0 ? "rgba(255,255,255,0.25)" : "transparent",
                  color: palette.primaryText,
                  fontWeight: i === 0 ? 600 : 400,
                  border: i !== 0 ? `1px solid rgba(255,255,255,0.3)` : "none",
                }}
              >
                {tab}
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="px-6 py-6 space-y-6">
        {/* Color Swatches Grid */}
        <div>
          <p className="text-xs mb-3" style={{ color: palette.text, opacity: 0.5, fontWeight: 600, letterSpacing: 1.2 }}>
            COLOR TOKENS
          </p>
          <div className="grid grid-cols-4 gap-2">
            {colors.map((color) => (
              <div key={color.label} className="group">
                <div
                  className="rounded-xl h-14 w-full shadow-sm mb-1.5 transition-transform hover:scale-105"
                  style={{ backgroundColor: color.hex }}
                />
                <p className="text-center leading-tight" style={{ color: palette.text, opacity: 0.6, fontSize: 9, fontWeight: 600 }}>
                  {color.label}
                </p>
                <p className="text-center" style={{ color: palette.text, opacity: 0.45, fontSize: 8 }}>
                  {color.hex}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Divider */}
        <div className="border-t" style={{ borderColor: `${palette.text}15` }} />

        {/* Sample Components */}
        <div>
          <p className="text-xs mb-4" style={{ color: palette.text, opacity: 0.5, fontWeight: 600, letterSpacing: 1.2 }}>
            FLUTTER COMPONENTS PREVIEW
          </p>

          {/* Buttons Row */}
          <div className="flex gap-3 mb-4">
            {/* ElevatedButton */}
            <button
              className="flex-1 py-3 rounded-xl text-sm shadow-md transition-all hover:opacity-90 active:scale-95"
              style={{
                backgroundColor: palette.primary,
                color: palette.primaryText,
                fontWeight: 600,
                boxShadow: `0 4px 12px ${palette.primary}55`,
              }}
            >
              Report Animal
            </button>
            {/* OutlinedButton */}
            <button
              className="flex-1 py-3 rounded-xl text-sm transition-all hover:opacity-80"
              style={{
                backgroundColor: "transparent",
                color: palette.primary,
                fontWeight: 600,
                border: `1.5px solid ${palette.primary}`,
              }}
            >
              View Map
            </button>
          </div>

          {/* TextField */}
          <div
            className="flex items-center gap-3 rounded-xl px-4 py-3 mb-4"
            style={{
              backgroundColor: palette.surface,
              border: focusedInput ? `2px solid ${palette.primary}` : `1.5px solid ${palette.text}20`,
              boxShadow: focusedInput ? `0 0 0 3px ${palette.primary}18` : "none",
              transition: "all 0.2s",
            }}
          >
            <span style={{ color: palette.text, opacity: 0.4, fontSize: 16 }}>🔍</span>
            <input
              type="text"
              placeholder="Search animals near campus..."
              className="flex-1 bg-transparent text-sm outline-none"
              style={{ color: palette.text, fontFamily: "inherit" }}
              onFocus={() => setFocusedInput(true)}
              onBlur={() => setFocusedInput(false)}
            />
          </div>

          {/* Animal Report Card */}
          <div
            className="rounded-2xl p-4 mb-4 shadow-sm"
            style={{
              backgroundColor: palette.surface,
              border: `1px solid ${palette.text}10`,
            }}
          >
            <div className="flex items-start gap-3">
              {/* Paw icon avatar */}
              <div
                className="w-14 h-14 rounded-2xl flex items-center justify-center text-2xl flex-shrink-0 shadow-sm"
                style={{ backgroundColor: `${palette.primary}18` }}
              >
                🐱
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between mb-1">
                  <p className="text-sm" style={{ color: palette.text, fontWeight: 700 }}>
                    Tabby Cat — Female
                  </p>
                  <span style={{ color: palette.text, opacity: 0.4, fontSize: 10 }}>2h ago</span>
                </div>
                <p style={{ color: palette.text, opacity: 0.55, fontSize: 11, marginBottom: 8 }}>
                  📍 N28 Engineering Block, UTM
                </p>
                {/* Status Chips */}
                <div className="flex flex-wrap gap-1.5">
                  <span
                    className="px-2 py-0.5 rounded-full text-xs"
                    style={{
                      backgroundColor: `${palette.success}20`,
                      color: palette.success,
                      fontWeight: 600,
                      border: `1px solid ${palette.success}35`,
                      fontSize: 10,
                    }}
                  >
                    ✓ Healthy
                  </span>
                  <span
                    className="px-2 py-0.5 rounded-full text-xs"
                    style={{
                      backgroundColor: `${palette.accent}25`,
                      color: palette.accent === "#FDD835" ? "#B8860B" : palette.accent,
                      fontWeight: 600,
                      border: `1px solid ${palette.accent}40`,
                      fontSize: 10,
                    }}
                  >
                    🍽 Needs Feeding
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Status Chips Full Row */}
          <div>
            <p style={{ color: palette.text, opacity: 0.45, fontSize: 10, fontWeight: 600, marginBottom: 8 }}>
              STATUS CHIPS
            </p>
            <div className="flex gap-2 flex-wrap">
              <span
                className="px-3 py-1.5 rounded-full text-xs"
                style={{
                  backgroundColor: `${palette.success}18`,
                  color: palette.success,
                  fontWeight: 700,
                  border: `1.5px solid ${palette.success}40`,
                }}
              >
                🟢 Healthy
              </span>
              <span
                className="px-3 py-1.5 rounded-full text-xs"
                style={{
                  backgroundColor: `${palette.accent}20`,
                  color: palette.accent === "#FDD835" ? "#9A7000" : palette.secondary,
                  fontWeight: 700,
                  border: `1.5px solid ${palette.accent}45`,
                }}
              >
                🟡 Needs Feeding
              </span>
              <span
                className="px-3 py-1.5 rounded-full text-xs"
                style={{
                  backgroundColor: `${palette.error}15`,
                  color: palette.error,
                  fontWeight: 700,
                  border: `1.5px solid ${palette.error}35`,
                }}
              >
                🔴 Injured
              </span>
            </div>
          </div>
        </div>

        {/* Divider */}
        <div className="border-t" style={{ borderColor: `${palette.text}15` }} />

        {/* Bottom Navigation Preview */}
        <div>
          <p className="text-xs mb-3" style={{ color: palette.text, opacity: 0.5, fontWeight: 600, letterSpacing: 1.2 }}>
            BOTTOM NAVIGATION BAR
          </p>
          <div
            className="rounded-2xl px-4 py-3 flex justify-around items-center shadow-sm"
            style={{
              backgroundColor: palette.surface,
              border: `1px solid ${palette.text}10`,
            }}
          >
            {[
              { icon: "🏠", label: "Home", active: true },
              { icon: "🗺️", label: "Map", active: false },
              { icon: "📋", label: "Reports", active: false },
              { icon: "👤", label: "Profile", active: false },
            ].map((item) => (
              <div key={item.label} className="flex flex-col items-center gap-1">
                <div
                  className="w-8 h-8 rounded-full flex items-center justify-center"
                  style={{
                    backgroundColor: item.active ? `${palette.primary}20` : "transparent",
                  }}
                >
                  <span style={{ fontSize: 16 }}>{item.icon}</span>
                </div>
                <span
                  style={{
                    fontSize: 9,
                    fontWeight: item.active ? 700 : 400,
                    color: item.active ? palette.primary : `${palette.text}60`,
                  }}
                >
                  {item.label}
                </span>
                {item.active && (
                  <div
                    className="w-1 h-1 rounded-full"
                    style={{ backgroundColor: palette.primary }}
                  />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Description */}
        <div
          className="rounded-xl p-4"
          style={{ backgroundColor: `${palette.primary}10`, border: `1px solid ${palette.primary}20` }}
        >
          <p className="text-xs mb-1" style={{ color: palette.primary, fontWeight: 700 }}>
            🎨 Palette Mood
          </p>
          <p style={{ color: palette.text, opacity: 0.75, fontSize: 12, lineHeight: 1.6 }}>
            {description}
          </p>
        </div>
      </div>
    </div>
  );
}
