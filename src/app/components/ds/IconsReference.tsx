import React from "react";
import { C, FlutterBadge } from "./DSTokens";
import { SectionLabel } from "./ColorTokens";

const icons = [
  { material: "pets",             emoji: "🐾", usage: "App logo, FAB, animal type identifier",     screen: "Splash · Home · Report" },
  { material: "location_on",      emoji: "📍", usage: "Location row in Cards and Profile",          screen: "Home · Profile" },
  { material: "camera_alt",       emoji: "📷", usage: "Image upload placeholder in Report form",    screen: "Report" },
  { material: "image",            emoji: "🖼️", usage: "Animal photo placeholder in cards",          screen: "Home · Profile" },
  { material: "health_and_safety",emoji: "🩺", usage: "Health status section in Profile screen",   screen: "Profile" },
  { material: "person",           emoji: "👤", usage: "Reporter info, AppBar profile icon",         screen: "Home · Profile · Login" },
  { material: "logout",           emoji: "🚪", usage: "Logout action in AppBar or drawer",          screen: "Home · Profile" },
  { material: "search",           emoji: "🔍", usage: "Search field in Home screen AppBar",         screen: "Home" },
  { material: "filter_list",      emoji: "⚙️", usage: "Filter toggle button beside search",        screen: "Home" },
  { material: "check_circle",     emoji: "✅", usage: "Success screen / confirmation icon",         screen: "Success" },
  { material: "error_outline",    emoji: "⚠️", usage: "Validation error messages in forms",        screen: "Login · Register · Report" },
  { material: "add",              emoji: "➕", usage: "FAB icon (regular variant)",                  screen: "Home" },
  { material: "arrow_back",       emoji: "←",  usage: "Back navigation in detail screens",          screen: "Profile · Report" },
  { material: "calendar_today",   emoji: "📅", usage: "Date reported in Animal Profile card",       screen: "Profile" },
  { material: "info_outline",     emoji: "ℹ️", usage: "Empty state illustration support",           screen: "Empty State" },
];

export function IconsReference() {
  return (
    <section>
      <SectionLabel icon="🔷" title="Icons Reference" sub="Material Icons used across all Sprint 1 screens" />

      <div
        className="rounded-2xl border overflow-hidden"
        style={{ backgroundColor: C.surface, borderColor: C.border }}
      >
        {/* Header */}
        <div
          className="grid px-5 py-3"
          style={{
            gridTemplateColumns: "40px 1fr 1fr 1fr",
            gap: "12px",
            backgroundColor: `${C.primary}10`,
            borderBottom: `1px solid ${C.border}`,
          }}
        >
          {["", "Material Icon Name", "Usage", "Screens"].map((h, i) => (
            <p key={i} style={{ color: C.primary, fontSize: 11, fontWeight: 700 }}>{h}</p>
          ))}
        </div>

        <div className="divide-y" style={{ borderColor: C.divider }}>
          {icons.map((ic, i) => (
            <div
              key={ic.material}
              className="grid px-5 py-3 items-center"
              style={{
                gridTemplateColumns: "40px 1fr 1fr 1fr",
                gap: "12px",
                backgroundColor: i % 2 === 0 ? "transparent" : `${C.text}02`,
              }}
            >
              {/* Emoji icon */}
              <div
                className="w-9 h-9 rounded-xl flex items-center justify-center"
                style={{ backgroundColor: `${C.primary}12` }}
              >
                <span style={{ fontSize: 18 }}>{ic.emoji}</span>
              </div>
              {/* Material name */}
              <div>
                <code
                  style={{
                    color: C.primary,
                    fontSize: 11,
                    fontFamily: "monospace",
                    backgroundColor: `${C.primary}12`,
                    padding: "2px 6px",
                    borderRadius: 4,
                  }}
                >
                  Icons.{ic.material}
                </code>
              </div>
              {/* Usage */}
              <p style={{ color: C.text, opacity: 0.6, fontSize: 11, lineHeight: 1.4 }}>
                {ic.usage}
              </p>
              {/* Screens */}
              <div className="flex flex-wrap gap-1">
                {ic.screen.split(" · ").map((s) => (
                  <span
                    key={s}
                    style={{
                      backgroundColor: `${C.accent}20`,
                      color: "#7A4A1A",
                      fontSize: 9,
                      fontWeight: 600,
                      padding: "2px 6px",
                      borderRadius: 6,
                      border: `1px solid ${C.accent}35`,
                    }}
                  >
                    {s}
                  </span>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Flutter import note */}
        <div
          className="px-5 py-3 flex items-center gap-3"
          style={{ backgroundColor: "#1E1E2E", borderTop: `1px solid ${C.border}` }}
        >
          <span style={{ color: "#6C7086", fontSize: 10, fontFamily: "monospace" }}>
            // Already included with Flutter Material —{" "}
          </span>
          <code style={{ color: "#A6E3A1", fontSize: 10, fontFamily: "monospace" }}>
            import 'package:flutter/material.dart';
          </code>
        </div>
      </div>
    </section>
  );
}
