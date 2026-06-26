import React from "react";
import { C } from "../ds/DSTokens";

// Decorative paw print SVG path
function PawPrint({ size = 32, opacity = 0.15, rotate = 0 }: { size?: number; opacity?: number; rotate?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 64 64"
      fill="white"
      style={{ opacity, transform: `rotate(${rotate}deg)` }}
    >
      {/* Main pad */}
      <ellipse cx="32" cy="42" rx="16" ry="13" />
      {/* Toe pads */}
      <ellipse cx="14" cy="28" rx="7" ry="8" />
      <ellipse cx="50" cy="28" rx="7" ry="8" />
      <ellipse cx="22" cy="19" rx="7" ry="8.5" />
      <ellipse cx="42" cy="19" rx="7" ry="8.5" />
    </svg>
  );
}

// Animated-looking floating circle
function FloatingCircle({ size, x, y, opacity }: { size: number; x: number; y: number; opacity: number }) {
  return (
    <div
      className="absolute rounded-full"
      style={{
        width: size,
        height: size,
        left: x,
        top: y,
        backgroundColor: "rgba(255,255,255,0.06)",
        border: "1px solid rgba(255,255,255,0.08)",
      }}
    />
  );
}

export function Screen1Splash() {
  return (
    <div
      className="relative w-full h-full flex flex-col"
      style={{
        background: `linear-gradient(175deg, #6B4632 0%, ${C.primary} 35%, #A67C5B 100%)`,
        paddingTop: 54, // status bar height
      }}
    >
      {/* Decorative background circles */}
      <FloatingCircle size={280} x={-80} y={-60} opacity={0.06} />
      <FloatingCircle size={200} x={220} y={20} opacity={0.05} />
      <FloatingCircle size={160} x={-30} y={400} opacity={0.07} />
      <FloatingCircle size={120} x={260} y={580} opacity={0.05} />

      {/* Scattered paw prints */}
      <div className="absolute" style={{ top: 90, left: 28, transform: "rotate(-20deg)" }}>
        <PawPrint size={28} opacity={0.12} />
      </div>
      <div className="absolute" style={{ top: 160, right: 30, transform: "rotate(30deg)" }}>
        <PawPrint size={20} opacity={0.1} />
      </div>
      <div className="absolute" style={{ top: 500, left: 20, transform: "rotate(15deg)" }}>
        <PawPrint size={22} opacity={0.1} />
      </div>
      <div className="absolute" style={{ top: 620, right: 24, transform: "rotate(-35deg)" }}>
        <PawPrint size={26} opacity={0.1} />
      </div>
      <div className="absolute" style={{ top: 700, left: 140, transform: "rotate(10deg)" }}>
        <PawPrint size={18} opacity={0.08} />
      </div>

      {/* ── SafeArea content ── */}
      <div className="flex-1 flex flex-col items-center justify-center px-8 relative z-10">

        {/* Logo container — simulates ClipRRect + Container */}
        <div className="relative mb-8">
          {/* Outer glow ring */}
          <div
            className="absolute inset-0 rounded-full"
            style={{
              transform: "scale(1.18)",
              background: "radial-gradient(circle, rgba(255,255,255,0.12) 0%, transparent 70%)",
            }}
          />
          {/* Outer decorative ring */}
          <div
            className="absolute inset-0 rounded-full"
            style={{
              transform: "scale(1.08)",
              border: "2px solid rgba(255,255,255,0.15)",
            }}
          />
          {/* Main logo circle */}
          <div
            className="relative flex items-center justify-center rounded-full"
            style={{
              width: 120,
              height: 120,
              backgroundColor: "rgba(255,255,255,0.18)",
              border: "2.5px solid rgba(255,255,255,0.3)",
              backdropFilter: "blur(12px)",
            }}
          >
            {/* Paw SVG — simulates Icon(Icons.pets) */}
            <svg width="58" height="58" viewBox="0 0 64 64" fill="white">
              <ellipse cx="32" cy="44" rx="17" ry="13" />
              <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="21" cy="17" rx="7" ry="8" />
              <ellipse cx="43" cy="17" rx="7" ry="8" />
            </svg>
          </div>
        </div>

        {/* App name — displayLarge */}
        <div className="text-center mb-3">
          <h1
            style={{
              color: "#FFFFFF",
              fontSize: 34,
              fontWeight: 800,
              letterSpacing: 0.5,
              lineHeight: 1.15,
              textShadow: "0 2px 12px rgba(0,0,0,0.2)",
            }}
          >
            UTM Paws-itive
          </h1>
        </div>

        {/* Divider line */}
        <div
          className="mb-5"
          style={{
            width: 60,
            height: 3,
            backgroundColor: "rgba(255,255,255,0.4)",
            borderRadius: 99,
          }}
        />

        {/* Tagline — bodyLarge */}
        <p
          className="text-center mb-14"
          style={{
            color: "rgba(255,255,255,0.82)",
            fontSize: 15,
            lineHeight: 1.65,
            maxWidth: 270,
            letterSpacing: 0.1,
          }}
        >
          Report, Track, and Care for Stray Animals in UTM
        </p>

        {/* Get Started ElevatedButton */}
        <button
          className="w-full flex items-center justify-center gap-3 rounded-2xl relative overflow-hidden"
          style={{
            height: 56,
            backgroundColor: "#FFFFFF",
            boxShadow: "0 8px 24px rgba(0,0,0,0.25), 0 2px 6px rgba(0,0,0,0.15)",
          }}
        >
          <span style={{ color: C.primary, fontWeight: 800, fontSize: 16, letterSpacing: 0.5 }}>
            Get Started
          </span>
          <svg width="20" height="20" viewBox="0 0 24 24" fill={C.primary}>
            <path d="M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z" />
          </svg>
        </button>

        {/* Login hint */}
        <div className="flex items-center gap-1.5 mt-5">
          <p style={{ color: "rgba(255,255,255,0.6)", fontSize: 13 }}>
            Already have an account?
          </p>
          <button>
            <p
              style={{
                color: "rgba(255,255,255,0.95)",
                fontSize: 13,
                fontWeight: 700,
                textDecoration: "underline",
                textDecorationColor: "rgba(255,255,255,0.5)",
              }}
            >
              Login
            </p>
          </button>
        </div>
      </div>

      {/* Footer — UTM branding */}
      <div
        className="flex flex-col items-center gap-2 pb-10 relative z-10"
        style={{ paddingBottom: 40 }}
      >
        {/* UTM logo row */}
        <div
          className="flex items-center gap-2 px-5 py-2.5 rounded-2xl"
          style={{ backgroundColor: "rgba(255,255,255,0.1)", border: "1px solid rgba(255,255,255,0.15)" }}
        >
          <div
            className="w-6 h-6 rounded-md flex items-center justify-center"
            style={{ backgroundColor: "rgba(255,255,255,0.2)" }}
          >
            <span style={{ color: "#fff", fontSize: 12, fontWeight: 800 }}>U</span>
          </div>
          <p style={{ color: "rgba(255,255,255,0.75)", fontSize: 11, fontWeight: 600 }}>
            Universiti Teknologi Malaysia
          </p>
        </div>
        <p style={{ color: "rgba(255,255,255,0.3)", fontSize: 10 }}>
          Animal Welfare Initiative · UTM Campus
        </p>
      </div>
    </div>
  );
}
