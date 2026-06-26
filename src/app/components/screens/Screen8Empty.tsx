import React from "react";
import { C } from "../ds/DSTokens";

// Large decorative paw illustration
function LargePawIllustration() {
  return (
    <div className="relative flex items-center justify-center" style={{ width: 160, height: 160 }}>
      {/* Background rings */}
      <div
        className="absolute inset-0 rounded-full"
        style={{ backgroundColor: `${C.primary}06`, transform: "scale(1)" }}
      />
      <div
        className="absolute inset-0 rounded-full"
        style={{ backgroundColor: `${C.primary}08`, transform: "scale(0.78)" }}
      />
      <div
        className="absolute inset-0 rounded-full"
        style={{ backgroundColor: `${C.primary}10`, transform: "scale(0.56)" }}
      />

      {/* Main paw SVG */}
      <svg
        width="72"
        height="72"
        viewBox="0 0 64 64"
        fill={C.primary}
        style={{ opacity: 0.22, position: "relative", zIndex: 10 }}
      >
        <ellipse cx="32" cy="44" rx="17" ry="13" />
        <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
        <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
        <ellipse cx="21" cy="17" rx="7" ry="8" />
        <ellipse cx="43" cy="17" rx="7" ry="8" />
      </svg>

      {/* Small floating paws */}
      {[
        { x: -10, y: 20,   size: 22, opacity: 0.12, rotate: -25 },
        { x: 130, y: 15,   size: 18, opacity: 0.10, rotate: 30  },
        { x: -18, y: 108,  size: 16, opacity: 0.09, rotate: 15  },
        { x: 138, y: 100,  size: 20, opacity: 0.11, rotate: -15 },
      ].map((p, i) => (
        <div
          key={i}
          className="absolute"
          style={{ left: p.x, top: p.y, transform: `rotate(${p.rotate}deg)` }}
        >
          <svg width={p.size} height={p.size} viewBox="0 0 64 64" fill={C.primary} style={{ opacity: p.opacity }}>
            <ellipse cx="32" cy="44" rx="17" ry="13" />
            <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="21" cy="17" rx="7" ry="8" />
            <ellipse cx="43" cy="17" rx="7" ry="8" />
          </svg>
        </div>
      ))}
    </div>
  );
}

// Decorative card skeleton — looks like a ghost card
function GhostCard({ opacity }: { opacity: number }) {
  return (
    <div
      className="w-full rounded-2xl p-4 flex items-start gap-3"
      style={{
        backgroundColor: C.surface,
        border: `1px solid ${C.border}`,
        opacity,
      }}
    >
      <div className="rounded-2xl flex-shrink-0" style={{ width: 72, height: 72, backgroundColor: `${C.text}08` }} />
      <div className="flex-1 space-y-2 pt-1">
        <div className="rounded-full" style={{ height: 12, width: "65%", backgroundColor: `${C.text}10` }} />
        <div className="rounded-full" style={{ height: 9, width: "45%", backgroundColor: `${C.text}07` }} />
        <div className="rounded-full" style={{ height: 9, width: "80%", backgroundColor: `${C.text}07` }} />
        <div className="flex gap-2 pt-1">
          <div className="rounded-full" style={{ height: 18, width: 70, backgroundColor: `${C.text}08` }} />
        </div>
      </div>
    </div>
  );
}

export function Screen8Empty() {
  return (
    <div
      className="relative w-full h-full flex flex-col overflow-hidden"
      style={{ backgroundColor: C.background, paddingTop: 54 }}
    >
      {/* ── Minimal AppBar ── */}
      <div
        className="flex items-center px-4 gap-3 flex-shrink-0"
        style={{ height: 56, background: `linear-gradient(175deg, #6B4632, ${C.primary})` }}
      >
        <div className="flex-1">
          <p style={{ color: "rgba(255,255,255,0.6)", fontSize: 10 }}>UTM Paws-itive 🐾</p>
          <p style={{ color: "#fff", fontWeight: 800, fontSize: 17 }}>Animal Reports</p>
        </div>
        <div
          className="flex items-center justify-center rounded-xl"
          style={{ width: 36, height: 36, backgroundColor: "rgba(255,255,255,0.15)" }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
            <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
          </svg>
        </div>
      </div>

      {/* Search bar + chips (disabled, empty state context) */}
      <div className="px-4 py-3 flex-shrink-0">
        <div
          className="flex items-center gap-2 rounded-2xl px-4"
          style={{ height: 44, backgroundColor: C.surface, border: `1.5px solid ${C.text}15` }}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill={`${C.text}40`}>
            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5z" />
          </svg>
          <span style={{ color: `${C.text}35`, fontSize: 13 }}>Search animals near campus…</span>
        </div>
        {/* Filter chips */}
        <div className="flex gap-2 mt-2.5 overflow-x-hidden">
          {["All", "Cats", "Dogs", "Healthy"].map((f, i) => (
            <span
              key={f}
              className="flex-shrink-0 px-3 py-1.5 rounded-full"
              style={{
                backgroundColor: i === 0 ? `${C.primary}15` : "transparent",
                border: `1.5px solid ${i === 0 ? `${C.primary}40` : `${C.text}15`}`,
                color: i === 0 ? C.primary : `${C.text}40`,
                fontSize: 11,
                fontWeight: i === 0 ? 700 : 400,
              }}
            >
              {f}
            </span>
          ))}
        </div>
      </div>

      {/* Ghost cards behind — creates depth that content is loading/empty */}
      <div className="absolute left-4 right-4 space-y-3" style={{ top: 230, zIndex: 1 }}>
        <GhostCard opacity={0.4} />
        <GhostCard opacity={0.2} />
        <GhostCard opacity={0.1} />
      </div>

      {/* Subtle gradient to cover ghost cards below */}
      <div
        className="absolute left-0 right-0 bottom-0"
        style={{
          top: 360,
          background: `linear-gradient(to bottom, transparent 0%, ${C.background} 40%)`,
          zIndex: 2,
        }}
      />

      {/* ── Center empty state ── */}
      <div
        className="absolute flex flex-col items-center text-center px-8"
        style={{
          top: 210,
          left: 0,
          right: 0,
          bottom: 0,
          zIndex: 10,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          paddingBottom: 60,
        }}
      >
        {/* Paw illustration */}
        <LargePawIllustration />

        {/* Primary empty text */}
        <div className="mt-5 mb-2">
          <h2
            style={{
              color: C.text,
              fontWeight: 800,
              fontSize: 20,
              opacity: 0.65,
              lineHeight: 1.25,
            }}
          >
            No animal reports yet
          </h2>
        </div>

        {/* Secondary text */}
        <p
          style={{
            color: C.text,
            opacity: 0.4,
            fontSize: 13,
            lineHeight: 1.7,
            maxWidth: 260,
            marginBottom: 28,
          }}
        >
          Be the first to report a stray animal in UTM and help build a safer campus for them 🐾
        </p>

        {/* ElevatedButton: Report Animal */}
        <button
          className="flex items-center justify-center gap-2.5 rounded-2xl"
          style={{
            height: 54,
            paddingLeft: 32,
            paddingRight: 32,
            background: `linear-gradient(135deg, #74503A, ${C.primary})`,
            boxShadow: `0 6px 20px ${C.primary}50`,
          }}
        >
          <svg width="20" height="20" viewBox="0 0 64 64" fill="white">
            <ellipse cx="32" cy="44" rx="17" ry="13" />
            <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="21" cy="17" rx="7" ry="8" />
            <ellipse cx="43" cy="17" rx="7" ry="8" />
          </svg>
          <span style={{ color: "#fff", fontWeight: 800, fontSize: 15, letterSpacing: 0.4 }}>
            Report Animal
          </span>
        </button>

        {/* Secondary action */}
        <button className="mt-3 flex items-center gap-1.5">
          <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary}>
            <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z" />
          </svg>
          <p style={{ color: C.primary, fontSize: 13, fontWeight: 600 }}>How to report?</p>
        </button>
      </div>

      {/* FAB hint — shows FAB still visible in empty state */}
      <div
        className="absolute flex items-center justify-end pr-4"
        style={{ bottom: 20, left: 0, right: 0, zIndex: 20 }}
      >
        <div
          className="flex items-center gap-2.5 rounded-2xl opacity-60"
          style={{
            height: 50,
            paddingLeft: 18,
            paddingRight: 22,
            backgroundColor: C.primary,
            boxShadow: `0 4px 14px ${C.primary}50`,
          }}
        >
          <svg width="18" height="18" viewBox="0 0 64 64" fill="white">
            <ellipse cx="32" cy="44" rx="17" ry="13" />
            <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="21" cy="17" rx="7" ry="8" />
            <ellipse cx="43" cy="17" rx="7" ry="8" />
          </svg>
          <span style={{ color: "#fff", fontWeight: 800, fontSize: 13 }}>Report Animal</span>
        </div>
      </div>

      {/* UC reference */}
      <div
        className="absolute bottom-0 left-0 right-0 flex justify-center pb-2"
        style={{ zIndex: 25 }}
      >
        <p style={{ color: `${C.text}25`, fontSize: 9 }}>
          UTM Paws-itive · UC04 Empty State · EmptyState widget
        </p>
      </div>
    </div>
  );
}
