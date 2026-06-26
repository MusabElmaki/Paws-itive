import React, { useState } from "react";
import { C } from "../ds/DSTokens";

type AnimalType = "Cat" | "Dog" | "Unknown";
type HealthStatus = "Healthy" | "Needs Feeding" | "Injured" | "Sick" | "Unknown";

const healthOptions: { value: HealthStatus; emoji: string; color: string }[] = [
  { value: "Healthy",       emoji: "🟢", color: C.success  },
  { value: "Needs Feeding", emoji: "🟡", color: "#8A5E20"  },
  { value: "Injured",       emoji: "🔴", color: C.error    },
  { value: "Sick",          emoji: "🟣", color: "#8C7AA9"  },
  { value: "Unknown",       emoji: "⚪", color: "#888"     },
];

// Reusable form label
function FormLabel({ text, required }: { text: string; required?: boolean }) {
  return (
    <p style={{ color: C.text, fontSize: 12, fontWeight: 600, marginBottom: 6, opacity: 0.65 }}>
      {text}
      {required && <span style={{ color: C.error, marginLeft: 3 }}>*</span>}
    </p>
  );
}

// Validation error message
function ValidationError({ message }: { message: string }) {
  return (
    <div className="flex items-center gap-1.5 mt-1.5">
      <svg width="12" height="12" viewBox="0 0 24 24" fill={C.error} style={{ flexShrink: 0 }}>
        <path d="M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" />
      </svg>
      <p style={{ color: C.error, fontSize: 11 }}>{message}</p>
    </div>
  );
}

export function Screen5Report() {
  const [animalType, setAnimalType] = useState<AnimalType>("Cat");
  const [healthStatus, setHealthStatus] = useState<HealthStatus | "">("");
  const [showDropdown, setShowDropdown] = useState(false);
  const [imageUploaded, setImageUploaded] = useState(false);

  // Show validation errors for demo
  const showLocationError = true;
  const showImageError    = !imageUploaded;
  const showStatusError   = healthStatus === "";

  const types: AnimalType[] = ["Cat", "Dog", "Unknown"];
  const typeEmoji: Record<AnimalType, string> = { Cat: "🐱", Dog: "🐶", Unknown: "❓" };

  return (
    <div
      className="relative w-full h-full flex flex-col overflow-hidden"
      style={{ backgroundColor: C.background, paddingTop: 54 }}
    >
      {/* ── AppBar ── */}
      <div
        className="flex items-center px-4 gap-3 flex-shrink-0"
        style={{ height: 56, background: `linear-gradient(175deg, #6B4632, ${C.primary})` }}
      >
        <button
          className="flex items-center justify-center rounded-xl flex-shrink-0"
          style={{ width: 36, height: 36, backgroundColor: "rgba(255,255,255,0.15)" }}
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
            <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" />
          </svg>
        </button>
        <div className="flex-1">
          <p style={{ color: "rgba(255,255,255,0.65)", fontSize: 10 }}>UC03 · Report Stray Animal</p>
          <p style={{ color: "#fff", fontWeight: 800, fontSize: 17 }}>Report Animal</p>
        </div>
        <button
          className="px-3 py-1.5 rounded-xl"
          style={{ backgroundColor: "rgba(255,255,255,0.15)", color: "#fff", fontSize: 11, fontWeight: 600 }}
        >
          Clear
        </button>
      </div>

      {/* ── SingleChildScrollView body ── */}
      <div className="flex-1 overflow-y-auto" style={{ paddingBottom: 20 }}>

        {/* ─ Photo Upload Section ─ */}
        <div className="px-5 pt-5 pb-4">
          <FormLabel text="Animal Photo" required />

          {imageUploaded ? (
            /* Uploaded state */
            <div className="relative rounded-2xl overflow-hidden" style={{ height: 180 }}>
              <div className="w-full h-full" style={{ background: `linear-gradient(135deg, ${C.primary}25, ${C.accent}20)` }}>
                <div className="absolute inset-0 flex items-center justify-center">
                  <span style={{ fontSize: 60 }}>🐱</span>
                </div>
              </div>
              <div
                className="absolute inset-0 flex items-end p-3"
                style={{ background: "linear-gradient(transparent 40%, rgba(0,0,0,0.45))" }}
              >
                <div className="flex items-center justify-between w-full">
                  <p style={{ color: "#fff", fontSize: 11, fontWeight: 600 }}>photo_20260504.jpg</p>
                  <button
                    className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl"
                    style={{ backgroundColor: "rgba(255,255,255,0.2)", backdropFilter: "blur(4px)" }}
                    onClick={() => setImageUploaded(false)}
                  >
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="white">
                      <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z" />
                    </svg>
                    <p style={{ color: "#fff", fontSize: 10, fontWeight: 600 }}>Change</p>
                  </button>
                </div>
              </div>
            </div>
          ) : (
            /* Upload placeholder — Container with camera_alt */
            <div>
              <button
                className="w-full flex flex-col items-center justify-center gap-3 rounded-2xl"
                style={{
                  height: 150,
                  backgroundColor: `${C.primary}08`,
                  border: `2px dashed ${showImageError ? C.error : `${C.primary}40`}`,
                  transition: "all 0.2s",
                }}
                onClick={() => setImageUploaded(true)}
              >
                {/* camera_alt icon */}
                <div
                  className="flex items-center justify-center rounded-2xl"
                  style={{
                    width: 52,
                    height: 52,
                    backgroundColor: showImageError ? `${C.error}15` : `${C.primary}15`,
                  }}
                >
                  <svg width="26" height="26" viewBox="0 0 24 24" fill={showImageError ? C.error : C.primary}>
                    <path d="M12 15.2a3.2 3.2 0 1 0 0-6.4 3.2 3.2 0 0 0 0 6.4z" />
                    <path d="M9 2L7.17 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2h-3.17L15 2H9zm3 15c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5z" />
                  </svg>
                </div>
                <div className="text-center px-4">
                  <p style={{ color: showImageError ? C.error : C.primary, fontSize: 13, fontWeight: 700 }}>
                    Tap to upload photo
                  </p>
                  <p style={{ color: C.text, opacity: 0.4, fontSize: 10, marginTop: 2 }}>
                    camera_alt · image · JPG, PNG · max 5MB
                  </p>
                </div>
              </button>
              {showImageError && <ValidationError message="Animal photo is required before submitting" />}
            </div>
          )}
        </div>

        {/* Divider */}
        <div className="mx-5 mb-4" style={{ height: 1, backgroundColor: C.divider }} />

        {/* ─ Animal Type SegmentedButton ─ */}
        <div className="px-5 mb-4">
          <FormLabel text="Animal Type" required />
          <div
            className="flex rounded-2xl overflow-hidden border"
            style={{ borderColor: C.primary, borderWidth: 1.5 }}
          >
            {types.map((t, i) => (
              <button
                key={t}
                onClick={() => setAnimalType(t)}
                className="flex-1 flex flex-col items-center justify-center py-3 gap-1 transition-all"
                style={{
                  backgroundColor: animalType === t ? C.primary : "transparent",
                  borderRight: i < types.length - 1 ? `1px solid ${C.primary}60` : "none",
                  transition: "background 0.18s",
                }}
              >
                <span style={{ fontSize: 18 }}>{typeEmoji[t]}</span>
                <span
                  style={{
                    color: animalType === t ? "#fff" : C.primary,
                    fontWeight: 700,
                    fontSize: 12,
                  }}
                >
                  {t}
                </span>
                {animalType === t && (
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="rgba(255,255,255,0.7)">
                    <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
                  </svg>
                )}
              </button>
            ))}
          </div>
          <p style={{ color: C.text, opacity: 0.35, fontSize: 10, marginTop: 4 }}>
            SegmentedButton — Flutter 3 Material 3
          </p>
        </div>

        {/* ─ Location TextField ─ */}
        <div className="px-5 mb-4">
          <FormLabel text="Location Found" required />
          <div
            className="flex items-center rounded-2xl px-4 gap-3"
            style={{
              height: 52,
              backgroundColor: C.surface,
              border: `1.5px solid ${showLocationError ? C.error : `${C.text}20`}`,
              boxShadow: showLocationError ? `0 0 0 3px ${C.error}12` : "none",
            }}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill={showLocationError ? C.error : C.primary} style={{ flexShrink: 0, opacity: 0.75 }}>
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
            </svg>
            <span style={{ color: `${C.text}45`, fontSize: 14, flex: 1 }}>
              e.g. N28 Engineering Block, UTM
            </span>
          </div>
          {showLocationError && <ValidationError message="Please enter the location where the animal was found" />}
        </div>

        {/* ─ Description TextField (maxLines: 4) ─ */}
        <div className="px-5 mb-4">
          <FormLabel text="Description" required />
          <div
            className="rounded-2xl px-4 py-3"
            style={{
              backgroundColor: C.surface,
              border: `1.5px solid ${C.text}20`,
            }}
          >
            <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
              <svg width="17" height="17" viewBox="0 0 24 24" fill={C.primary} style={{ flexShrink: 0, marginTop: 2, opacity: 0.6 }}>
                <path d="M14 17H4v2h10v-2zm6-8H4v2h16V9zM4 15h16v-2H4v2zM4 5v2h16V5H4z" />
              </svg>
              <div className="flex-1">
                <p style={{ color: `${C.text}45`, fontSize: 13, lineHeight: 1.6 }}>
                  Describe the animal's condition, appearance, and behaviour…
                </p>
                {/* Simulates 4-line height */}
                <div style={{ height: 56 }} />
              </div>
            </div>
          </div>
          <div className="flex justify-between mt-1">
            <p style={{ color: C.text, opacity: 0.3, fontSize: 10 }}>maxLines: 4 · minLines: 3</p>
            <p style={{ color: C.text, opacity: 0.3, fontSize: 10 }}>0 / 300</p>
          </div>
        </div>

        {/* ─ Health Status DropdownButtonFormField ─ */}
        <div className="px-5 mb-5">
          <FormLabel text="Health Status" required />
          <div className="relative">
            <button
              className="w-full flex items-center rounded-2xl px-4 gap-3"
              style={{
                height: 52,
                backgroundColor: C.surface,
                border: `1.5px solid ${showStatusError ? C.error : `${C.text}20`}`,
                boxShadow: showStatusError ? `0 0 0 3px ${C.error}12` : "none",
              }}
              onClick={() => setShowDropdown(!showDropdown)}
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill={showStatusError ? C.error : C.primary} style={{ flexShrink: 0, opacity: 0.75 }}>
                <path d="M12 2c-4.97 0-9 4.03-9 9 0 4.17 2.84 7.67 6.69 8.69L12 22l2.31-2.31C18.16 18.67 21 15.17 21 11c0-4.97-4.03-9-9-9zm0 2c3.86 0 7 3.14 7 7s-3.14 7-7 7-7-3.14-7-7 3.14-7 7-7zm-1 3v5l4.25 2.52.77-1.28-3.52-2.09V7H11z" />
              </svg>

              {healthStatus ? (
                <div className="flex items-center gap-2 flex-1">
                  <span style={{ fontSize: 14 }}>
                    {healthOptions.find((h) => h.value === healthStatus)?.emoji}
                  </span>
                  <span style={{ color: C.text, fontSize: 14 }}>{healthStatus}</span>
                </div>
              ) : (
                <span style={{ color: `${C.text}45`, fontSize: 14, flex: 1 }}>
                  Select health status…
                </span>
              )}
              <svg
                width="18" height="18" viewBox="0 0 24 24"
                fill={showStatusError ? C.error : `${C.text}50`}
                style={{ transform: showDropdown ? "rotate(180deg)" : "none", transition: "transform 0.2s" }}
              >
                <path d="M7 10l5 5 5-5z" />
              </svg>
            </button>

            {/* Dropdown menu */}
            {showDropdown && (
              <div
                className="absolute left-0 right-0 z-20 rounded-2xl overflow-hidden mt-1"
                style={{
                  backgroundColor: C.surface,
                  border: `1.5px solid ${C.primary}40`,
                  boxShadow: `0 8px 24px rgba(58,34,18,0.18)`,
                }}
              >
                {healthOptions.map((opt, i) => (
                  <button
                    key={opt.value}
                    className="w-full flex items-center gap-3 px-4 py-3 text-left transition-all hover:bg-orange-50"
                    style={{
                      borderBottom: i < healthOptions.length - 1 ? `1px solid ${C.divider}` : "none",
                      backgroundColor: healthStatus === opt.value ? `${C.primary}08` : "transparent",
                    }}
                    onClick={() => { setHealthStatus(opt.value); setShowDropdown(false); }}
                  >
                    <span style={{ fontSize: 16 }}>{opt.emoji}</span>
                    <span style={{ color: opt.color, fontWeight: 600, fontSize: 13 }}>{opt.value}</span>
                    {healthStatus === opt.value && (
                      <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary} style={{ marginLeft: "auto" }}>
                        <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
                      </svg>
                    )}
                  </button>
                ))}
              </div>
            )}
          </div>
          {showStatusError && !showDropdown && <ValidationError message="Please select the animal's current health status" />}
        </div>

        {/* ─ Additional Info ─ */}
        <div className="px-5 mb-5">
          <div
            className="rounded-2xl p-3.5 flex items-start gap-3"
            style={{ backgroundColor: `${C.primary}08`, border: `1px solid ${C.primary}18` }}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill={C.primary} style={{ flexShrink: 0, marginTop: 1 }}>
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z" />
            </svg>
            <p style={{ color: C.text, fontSize: 11, lineHeight: 1.55, opacity: 0.7 }}>
              Your report will be reviewed by UTM animal welfare volunteers. Please provide as much detail as possible to help us assist the animal quickly.
            </p>
          </div>
        </div>

        {/* ─ Validation Summary Banner ─ */}
        <div
          className="mx-5 mb-5 rounded-2xl p-4 border"
          style={{ backgroundColor: `${C.error}08`, borderColor: `${C.error}30` }}
        >
          <div className="flex items-center gap-2 mb-2">
            <svg width="16" height="16" viewBox="0 0 24 24" fill={C.error}>
              <path d="M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" />
            </svg>
            <p style={{ color: C.error, fontWeight: 700, fontSize: 13 }}>Required fields missing</p>
          </div>
          <ul className="space-y-1 pl-1">
            {[
              { field: "Animal Photo", done: imageUploaded },
              { field: "Location Found", done: false },
              { field: "Health Status", done: healthStatus !== "" },
            ]
              .filter((f) => !f.done)
              .map((f) => (
                <li key={f.field} className="flex items-center gap-2">
                  <div className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: C.error }} />
                  <p style={{ color: C.error, fontSize: 11, opacity: 0.8 }}>{f.field} is required</p>
                </li>
              ))}
          </ul>
        </div>

        {/* ─ Submit ElevatedButton ─ */}
        <div className="px-5">
          <button
            className="w-full flex items-center justify-center gap-3 rounded-2xl"
            style={{
              height: 56,
              background: `linear-gradient(135deg, #74503A, ${C.primary})`,
              boxShadow: `0 6px 20px ${C.primary}50`,
              opacity: showImageError || showLocationError || showStatusError ? 0.55 : 1,
            }}
          >
            <svg width="20" height="20" viewBox="0 0 64 64" fill="white">
              <ellipse cx="32" cy="44" rx="17" ry="13" />
              <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="21" cy="17" rx="7" ry="8" />
              <ellipse cx="43" cy="17" rx="7" ry="8" />
            </svg>
            <span style={{ color: "#fff", fontWeight: 800, fontSize: 16, letterSpacing: 0.5 }}>
              Submit Report
            </span>
          </button>
          <p style={{ color: C.text, opacity: 0.3, fontSize: 10, textAlign: "center", marginTop: 8 }}>
            UTM Paws-itive · UC03 Report Stray Animal
          </p>
        </div>
      </div>
    </div>
  );
}
