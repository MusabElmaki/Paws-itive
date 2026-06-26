import React from "react";
import { C } from "../ds/DSTokens";

interface MobileFrameProps {
  children: React.ReactNode;
  label?: string;
  screenId?: string;
}

export function MobileFrame({ children, label, screenId }: MobileFrameProps) {
  return (
    <div className="flex flex-col items-center">
      {/* Frame shell */}
      <div
        className="relative"
        style={{
          width: 390,
          borderRadius: 50,
          background: "linear-gradient(145deg, #2A2A2A, #1A1A1A)",
          padding: "12px 10px",
          boxShadow:
            "0 0 0 1px #3A3A3A, 0 30px 80px rgba(0,0,0,0.45), inset 0 0 0 2px #444, 0 4px 20px rgba(0,0,0,0.3)",
        }}
      >
        {/* Side buttons (left) */}
        <div className="absolute" style={{ left: -3, top: 120, width: 3, height: 32, background: "#333", borderRadius: "2px 0 0 2px" }} />
        <div className="absolute" style={{ left: -3, top: 168, width: 3, height: 64, background: "#333", borderRadius: "2px 0 0 2px" }} />
        <div className="absolute" style={{ left: -3, top: 244, width: 3, height: 64, background: "#333", borderRadius: "2px 0 0 2px" }} />
        {/* Power button (right) */}
        <div className="absolute" style={{ right: -3, top: 180, width: 3, height: 80, background: "#333", borderRadius: "0 2px 2px 0" }} />

        {/* Inner screen area */}
        <div
          className="relative overflow-hidden"
          style={{
            borderRadius: 40,
            width: 370,
            height: 800,
            background: C.background,
            overflow: "hidden",
          }}
        >
          {/* Dynamic island */}
          <div
            className="absolute top-3 left-1/2 z-50 flex items-center justify-center"
            style={{
              transform: "translateX(-50%)",
              width: 120,
              height: 34,
              backgroundColor: "#000",
              borderRadius: 20,
            }}
          />

          {/* Status bar */}
          <div
            className="absolute top-0 left-0 right-0 z-40 flex items-center justify-between px-6"
            style={{ height: 54, paddingTop: 14 }}
          >
            <span style={{ color: "rgba(255,255,255,0.9)", fontSize: 12, fontWeight: 700, mixBlendMode: "difference" }}>
              9:41
            </span>
            <div className="flex items-center gap-1.5">
              {/* Signal bars */}
              <svg width="17" height="12" viewBox="0 0 17 12" style={{ mixBlendMode: "difference" }}>
                <rect x="0" y="8" width="3" height="4" rx="0.5" fill="white" fillOpacity="0.9" />
                <rect x="4.5" y="5" width="3" height="7" rx="0.5" fill="white" fillOpacity="0.9" />
                <rect x="9" y="2.5" width="3" height="9.5" rx="0.5" fill="white" fillOpacity="0.9" />
                <rect x="13.5" y="0" width="3" height="12" rx="0.5" fill="white" fillOpacity="0.5" />
              </svg>
              {/* WiFi */}
              <svg width="15" height="12" viewBox="0 0 15 12" style={{ mixBlendMode: "difference" }}>
                <path d="M7.5 9.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3z" fill="white" fillOpacity="0.9" />
                <path d="M3.2 6.8a6 6 0 0 1 8.6 0" stroke="white" strokeWidth="1.3" fill="none" strokeOpacity="0.9" />
                <path d="M0.5 4.2a10 10 0 0 1 14 0" stroke="white" strokeWidth="1.3" fill="none" strokeOpacity="0.5" />
              </svg>
              {/* Battery */}
              <svg width="25" height="12" viewBox="0 0 25 12" style={{ mixBlendMode: "difference" }}>
                <rect x="0" y="1" width="21" height="10" rx="2.5" stroke="white" strokeWidth="1" strokeOpacity="0.9" fill="none" />
                <rect x="21.5" y="3.5" width="2.5" height="5" rx="1" fill="white" fillOpacity="0.9" />
                <rect x="1.5" y="2.5" width="16" height="7" rx="1.5" fill="white" fillOpacity="0.9" />
              </svg>
            </div>
          </div>

          {/* Screen content */}
          <div className="absolute inset-0 overflow-hidden" style={{ paddingTop: 0 }}>
            {children}
          </div>
        </div>
      </div>

      {/* Home indicator bar */}
      <div className="mt-1 flex justify-center" style={{
        width: 390,
        background: "linear-gradient(145deg, #2A2A2A, #1A1A1A)",
        borderRadius: "0 0 50px 50px",
        padding: "6px 0 10px",
      }}>
        <div style={{ width: 120, height: 5, backgroundColor: "#555", borderRadius: 99 }} />
      </div>

      {/* Screen label below */}
      {label && (
        <div className="mt-4 text-center">
          <p style={{ color: C.primary, fontWeight: 700, fontSize: 13 }}>{label}</p>
        </div>
      )}
    </div>
  );
}
