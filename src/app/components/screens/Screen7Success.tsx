import React, { useState, useEffect } from "react";
import { C } from "../ds/DSTokens";

// Animated check mark SVG
function AnimatedCheck({ visible }: { visible: boolean }) {
  return (
    <svg width="56" height="56" viewBox="0 0 56 56">
      <circle cx="28" cy="28" r="26" fill={`${C.success}18`} stroke={C.success} strokeWidth="2.5" />
      <polyline
        points="16,28 24,36 40,20"
        fill="none"
        stroke={C.success}
        strokeWidth="3.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        style={{
          strokeDasharray: 40,
          strokeDashoffset: visible ? 0 : 40,
          transition: "stroke-dashoffset 0.6s cubic-bezier(0.22,1,0.36,1) 0.2s",
        }}
      />
    </svg>
  );
}

// Confetti dot
function ConfettiDot({ x, y, color, size, delay }: { x: number; y: number; color: string; size: number; delay: number }) {
  return (
    <div
      className="absolute rounded-full"
      style={{
        left: x,
        top: y,
        width: size,
        height: size,
        backgroundColor: color,
        opacity: 0.7,
        animation: `bounce 2s ease-in-out ${delay}s infinite alternate`,
      }}
    />
  );
}

const confettiColors = [C.primary, C.accent, C.success, "#F6C90E", C.secondary, "#8C7AA9"];

const confettiDots = [
  { x: 30,  y: 120, color: confettiColors[0], size: 8,  delay: 0    },
  { x: 70,  y: 90,  color: confettiColors[1], size: 6,  delay: 0.3  },
  { x: 300, y: 100, color: confettiColors[2], size: 7,  delay: 0.1  },
  { x: 330, y: 140, color: confettiColors[3], size: 5,  delay: 0.5  },
  { x: 50,  y: 220, color: confettiColors[4], size: 9,  delay: 0.2  },
  { x: 320, y: 210, color: confettiColors[5], size: 6,  delay: 0.4  },
  { x: 20,  y: 320, color: confettiColors[1], size: 5,  delay: 0.6  },
  { x: 345, y: 310, color: confettiColors[0], size: 7,  delay: 0.15 },
  { x: 160, y: 60,  color: confettiColors[3], size: 5,  delay: 0.35 },
  { x: 200, y: 55,  color: confettiColors[2], size: 6,  delay: 0.25 },
];

export function Screen7Success() {
  const [checkVisible, setCheckVisible] = useState(false);
  const [reported] = useState({
    animal: "Milo (Ginger Tabby)",
    location: "N28 Engineering Block",
    status: "Healthy",
    date: "4 May 2026, 2:35 PM",
    id: "RPT-2026-0047",
  });

  useEffect(() => {
    const t = setTimeout(() => setCheckVisible(true), 300);
    return () => clearTimeout(t);
  }, []);

  return (
    <div
      className="relative w-full h-full flex flex-col overflow-hidden"
      style={{ backgroundColor: C.background, paddingTop: 54 }}
    >
      {/* Confetti decoration */}
      {confettiDots.map((d, i) => (
        <ConfettiDot key={i} {...d} />
      ))}

      {/* Top wave decoration */}
      <div
        className="absolute top-0 left-0 right-0"
        style={{
          height: 200,
          background: `radial-gradient(ellipse at 50% 0%, ${C.success}18 0%, transparent 70%)`,
        }}
      />

      {/* ── Scaffold body — Center / Column ── */}
      <div className="flex-1 flex flex-col items-center justify-center px-7 relative z-10">

        {/* Success icon circle — simulates check_circle */}
        <div className="relative mb-6">
          {/* Outer pulse ring */}
          <div
            className="absolute inset-0 rounded-full"
            style={{
              transform: "scale(1.35)",
              backgroundColor: `${C.success}08`,
            }}
          />
          <div
            className="absolute inset-0 rounded-full"
            style={{
              transform: "scale(1.15)",
              backgroundColor: `${C.success}12`,
            }}
          />
          {/* Main icon container */}
          <div
            className="relative flex items-center justify-center rounded-full"
            style={{
              width: 96,
              height: 96,
              backgroundColor: `${C.success}15`,
              border: `3px solid ${C.success}40`,
            }}
          >
            <AnimatedCheck visible={checkVisible} />
          </div>
        </div>

        {/* Paw decoration row */}
        <div className="flex items-center gap-2 mb-4">
          {[0, 1, 2].map((i) => (
            <svg
              key={i}
              width={14 + i * 3}
              height={14 + i * 3}
              viewBox="0 0 64 64"
              fill={C.success}
              style={{ opacity: 0.25 + i * 0.1 }}
            >
              <ellipse cx="32" cy="44" rx="17" ry="13" />
              <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="21" cy="17" rx="7" ry="8" />
              <ellipse cx="43" cy="17" rx="7" ry="8" />
            </svg>
          ))}
        </div>

        {/* Main success text */}
        <div className="text-center mb-2">
          <h1
            style={{
              color: C.text,
              fontWeight: 800,
              fontSize: 22,
              lineHeight: 1.25,
              marginBottom: 8,
            }}
          >
            Report Submitted!
          </h1>
          <p
            style={{
              color: C.text,
              opacity: 0.6,
              fontSize: 14,
              lineHeight: 1.65,
              maxWidth: 280,
              margin: "0 auto",
            }}
          >
            Animal report submitted successfully. Our volunteers have been notified.
          </p>
        </div>

        {/* Report summary card */}
        <div
          className="w-full rounded-2xl p-4 my-5"
          style={{
            backgroundColor: C.surface,
            border: `1.5px solid ${C.success}30`,
            boxShadow: `0 4px 16px ${C.success}12`,
          }}
        >
          {/* Report ID badge */}
          <div
            className="flex items-center justify-between mb-3 pb-3"
            style={{ borderBottom: `1px solid ${C.divider}` }}
          >
            <div className="flex items-center gap-2">
              <svg width="14" height="14" viewBox="0 0 24 24" fill={C.success}>
                <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
              </svg>
              <p style={{ color: C.success, fontSize: 12, fontWeight: 700 }}>Report Confirmed</p>
            </div>
            <span
              className="px-2.5 py-1 rounded-lg"
              style={{ backgroundColor: `${C.primary}12`, color: C.primary, fontSize: 10, fontWeight: 800, fontFamily: "monospace" }}
            >
              {reported.id}
            </span>
          </div>

          {/* Details grid */}
          <div className="space-y-2.5">
            {[
              { icon: "🐱", label: "Animal",   value: reported.animal   },
              { icon: "📍", label: "Location", value: reported.location },
              {
                icon: "🟢",
                label: "Health",
                value: reported.status,
                valueColor: C.success,
              },
              { icon: "📅", label: "Submitted", value: reported.date    },
            ].map((row) => (
              <div key={row.label} className="flex items-center gap-3">
                <span style={{ fontSize: 14, width: 20, textAlign: "center" }}>{row.icon}</span>
                <p style={{ color: C.text, opacity: 0.45, fontSize: 11, width: 64, flexShrink: 0 }}>
                  {row.label}
                </p>
                <p
                  style={{
                    color: (row as any).valueColor || C.text,
                    fontSize: 12,
                    fontWeight: 600,
                    flex: 1,
                  }}
                >
                  {row.value}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* ElevatedButton: View Animal List */}
        <button
          className="w-full flex items-center justify-center gap-2.5 rounded-2xl mb-3"
          style={{
            height: 54,
            background: `linear-gradient(135deg, #74503A, ${C.primary})`,
            boxShadow: `0 6px 20px ${C.primary}45`,
          }}
        >
          <svg width="18" height="18" viewBox="0 0 64 64" fill="white">
            <ellipse cx="32" cy="44" rx="17" ry="13" />
            <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="21" cy="17" rx="7" ry="8" />
            <ellipse cx="43" cy="17" rx="7" ry="8" />
          </svg>
          <span style={{ color: "#fff", fontWeight: 800, fontSize: 15, letterSpacing: 0.4 }}>
            View Animal List
          </span>
        </button>

        {/* OutlinedButton: Submit Another Report */}
        <button
          className="w-full flex items-center justify-center gap-2.5 rounded-2xl"
          style={{
            height: 52,
            backgroundColor: "transparent",
            border: `2px solid ${C.primary}`,
          }}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill={C.primary}>
            <path d="M19 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z" />
          </svg>
          <span style={{ color: C.primary, fontWeight: 700, fontSize: 14 }}>
            Submit Another Report
          </span>
        </button>
      </div>

      {/* Footer note */}
      <div className="pb-8 px-7 text-center relative z-10">
        <div
          className="flex items-center justify-center gap-2 px-4 py-2.5 rounded-2xl"
          style={{ backgroundColor: `${C.primary}08` }}
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary}>
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z" />
          </svg>
          <p style={{ color: C.primary, fontSize: 11, opacity: 0.75 }}>
            UTM volunteers will review your report within 24 hours
          </p>
        </div>
        <p style={{ color: `${C.text}30`, fontSize: 10, marginTop: 8 }}>
          UTM Paws-itive · Post UC03 Confirmation
        </p>
      </div>
    </div>
  );
}
