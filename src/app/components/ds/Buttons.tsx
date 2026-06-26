import React, { useState } from "react";
import { C, FlutterBadge } from "./DSTokens";
import { SectionLabel } from "./ColorTokens";

export function Buttons() {
  const [hoveredFab, setHoveredFab] = useState(false);

  return (
    <section>
      <SectionLabel icon="🔘" title="Button Styles" sub="ElevatedButton · OutlinedButton · TextButton · FAB" />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

        {/* ElevatedButton */}
        <div
          className="rounded-2xl p-5 border space-y-3"
          style={{ backgroundColor: C.surface, borderColor: C.border }}
        >
          <div className="flex items-center justify-between mb-1">
            <FlutterBadge label="ElevatedButton" />
            <span style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>Primary action</span>
          </div>
          {/* Normal */}
          <button
            className="w-full py-3.5 rounded-xl transition-all"
            style={{
              backgroundColor: C.primary,
              color: "#FFFFFF",
              fontWeight: 700,
              fontSize: 14,
              letterSpacing: 0.6,
              boxShadow: `0 3px 10px ${C.primary}50`,
            }}
          >
            Submit Report
          </button>
          {/* Hover state visual */}
          <button
            className="w-full py-3.5 rounded-xl transition-all"
            style={{
              backgroundColor: "#74503A",
              color: "#FFFFFF",
              fontWeight: 700,
              fontSize: 14,
              letterSpacing: 0.6,
              boxShadow: `0 5px 14px ${C.primary}60`,
            }}
          >
            Submit Report <span style={{ opacity: 0.6, fontSize: 10, marginLeft: 4 }}>(hover)</span>
          </button>
          {/* Disabled */}
          <button
            disabled
            className="w-full py-3.5 rounded-xl"
            style={{
              backgroundColor: `${C.text}15`,
              color: `${C.text}40`,
              fontWeight: 700,
              fontSize: 14,
              letterSpacing: 0.6,
              cursor: "not-allowed",
            }}
          >
            Submit Report (disabled)
          </button>
          <p style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>
            borderRadius: 12 · elevation: 3 · padding: 16h × 48h
          </p>
        </div>

        {/* OutlinedButton */}
        <div
          className="rounded-2xl p-5 border space-y-3"
          style={{ backgroundColor: C.surface, borderColor: C.border }}
        >
          <div className="flex items-center justify-between mb-1">
            <FlutterBadge label="OutlinedButton" />
            <span style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>Secondary action</span>
          </div>
          <button
            className="w-full py-3.5 rounded-xl transition-all"
            style={{
              backgroundColor: "transparent",
              color: C.primary,
              fontWeight: 700,
              fontSize: 14,
              letterSpacing: 0.6,
              border: `2px solid ${C.primary}`,
            }}
          >
            View Animal List
          </button>
          <button
            className="w-full py-3.5 rounded-xl"
            style={{
              backgroundColor: `${C.primary}10`,
              color: C.primary,
              fontWeight: 700,
              fontSize: 14,
              letterSpacing: 0.6,
              border: `2px solid ${C.primary}`,
            }}
          >
            View Animal List <span style={{ opacity: 0.6, fontSize: 10, marginLeft: 4 }}>(hover)</span>
          </button>
          <button
            disabled
            className="w-full py-3.5 rounded-xl"
            style={{
              backgroundColor: "transparent",
              color: `${C.text}35`,
              fontWeight: 700,
              fontSize: 14,
              letterSpacing: 0.6,
              border: `2px solid ${C.text}25`,
              cursor: "not-allowed",
            }}
          >
            Contact Volunteer (disabled)
          </button>
          <p style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>
            borderRadius: 12 · side: BorderSide(color: kPrimary, width: 2)
          </p>
        </div>

        {/* TextButton */}
        <div
          className="rounded-2xl p-5 border space-y-3"
          style={{ backgroundColor: C.surface, borderColor: C.border }}
        >
          <div className="flex items-center justify-between mb-1">
            <FlutterBadge label="TextButton" />
            <span style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>Inline / link actions</span>
          </div>
          <div className="space-y-2">
            <button style={{ color: C.primary, fontWeight: 600, fontSize: 14, display: "block" }}>
              Already have an account? <span style={{ textDecoration: "underline" }}>Login</span>
            </button>
            <button style={{ color: C.secondary, fontWeight: 600, fontSize: 14, display: "block" }}>
              Forgot password?
            </button>
            <button style={{ color: C.error, fontWeight: 600, fontSize: 14, display: "block" }}>
              🚪 Logout
            </button>
          </div>
          <p style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>
            No background · foreground: kPrimary / kError · underline optional
          </p>
        </div>

        {/* FAB */}
        <div
          className="rounded-2xl p-5 border"
          style={{ backgroundColor: C.surface, borderColor: C.border }}
        >
          <div className="flex items-center justify-between mb-4">
            <FlutterBadge label="FloatingActionButton.extended" />
            <span style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>Home screen</span>
          </div>
          <div className="flex flex-col items-center gap-4">
            {/* FAB Extended */}
            <button
              className="flex items-center gap-2 px-6 py-3.5 rounded-2xl transition-all"
              onMouseEnter={() => setHoveredFab(true)}
              onMouseLeave={() => setHoveredFab(false)}
              style={{
                backgroundColor: hoveredFab ? "#74503A" : C.primary,
                color: "#FFFFFF",
                fontWeight: 700,
                fontSize: 14,
                letterSpacing: 0.5,
                boxShadow: hoveredFab
                  ? `0 6px 18px ${C.primary}65`
                  : `0 4px 12px ${C.primary}50`,
                transition: "all 0.2s",
                transform: hoveredFab ? "translateY(-1px)" : "none",
              }}
            >
              <span style={{ fontSize: 18 }}>🐾</span>
              Report Animal
            </button>
            {/* FAB regular */}
            <div
              className="w-14 h-14 rounded-2xl flex items-center justify-center shadow-lg"
              style={{
                backgroundColor: C.accent,
                boxShadow: `0 4px 14px ${C.accent}60`,
              }}
            >
              <span style={{ fontSize: 22 }}>➕</span>
            </div>
            <p style={{ color: C.text, opacity: 0.4, fontSize: 10, textAlign: "center" }}>
              Extended FAB: bottom-right · icon: pets · label: "Report Animal"
              <br />
              Regular FAB: add icon · backgroundColor: kAccent
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
