import React, { useState } from "react";
import { C } from "../ds/DSTokens";

const CAT_IMG = "https://images.unsplash.com/photo-1777548554058-b6bac696d4a0?w=800&h=480&fit=crop&crop=face";

type StatusType = "Healthy" | "NeedsFeeding" | "Injured" | "Sick" | "Unknown";

const statusCfg: Record<StatusType, { label: string; icon: string; color: string; bg: string; border: string }> = {
  Healthy:      { label: "Healthy",       icon: "🟢", color: C.success,    bg: `${C.success}18`,            border: `${C.success}40`           },
  NeedsFeeding: { label: "Needs Feeding", icon: "🟡", color: "#8A5E20",   bg: `${C.accent}22`,             border: `${C.accent}45`            },
  Injured:      { label: "Injured",       icon: "🔴", color: C.error,      bg: `${C.error}15`,              border: `${C.error}40`             },
  Sick:         { label: "Sick",          icon: "🟣", color: "#8C7AA9",   bg: "rgba(140,122,169,0.15)",    border: "rgba(140,122,169,0.4)"    },
  Unknown:      { label: "Unknown",       icon: "⚪", color: "#888",       bg: "rgba(158,158,158,0.15)",   border: "rgba(158,158,158,0.4)"    },
};

function StatusChip({ status }: { status: StatusType }) {
  const cfg = statusCfg[status];
  return (
    <span
      style={{
        backgroundColor: cfg.bg,
        color: cfg.color,
        border: `1.5px solid ${cfg.border}`,
        borderRadius: 99,
        padding: "5px 12px",
        fontSize: 12,
        fontWeight: 700,
        display: "inline-flex",
        alignItems: "center",
        gap: 5,
        lineHeight: 1,
      }}
    >
      <span style={{ fontSize: 9 }}>{cfg.icon}</span>
      {cfg.label}
    </span>
  );
}

function DetailRow({ icon, label, value, accent }: { icon: React.ReactNode; label: string; value: string; accent?: boolean }) {
  return (
    <div className="flex items-start gap-2.5">
      <div
        className="flex items-center justify-center rounded-xl flex-shrink-0"
        style={{ width: 32, height: 32, backgroundColor: `${C.primary}12`, marginTop: 2 }}
      >
        {icon}
      </div>
      <div>
        <p style={{ color: C.text, fontSize: 10, fontWeight: 600, opacity: 0.45, letterSpacing: 0.3 }}>
          {label.toUpperCase()}
        </p>
        <p style={{ color: accent ? C.primary : C.text, fontSize: 13, fontWeight: accent ? 700 : 500, marginTop: 1 }}>
          {value}
        </p>
      </div>
    </div>
  );
}

export function Screen6Profile() {
  const [marked, setMarked] = useState(false);
  const [imgError, setImgError] = useState(false);

  const status: StatusType = "Healthy";

  return (
    <div
      className="relative w-full h-full flex flex-col overflow-hidden"
      style={{ backgroundColor: C.background, paddingTop: 54 }}
    >
      {/* ── AppBar (transparent over image) ── */}
      <div
        className="absolute top-0 left-0 right-0 z-20 flex items-center px-4 gap-3"
        style={{
          height: 110,
          paddingTop: 54,
          background: "linear-gradient(to bottom, rgba(58,34,18,0.55) 0%, transparent 100%)",
        }}
      >
        {/* Back button */}
        <button
          className="flex items-center justify-center rounded-xl"
          style={{ width: 36, height: 36, backgroundColor: "rgba(255,255,255,0.18)", backdropFilter: "blur(8px)" }}
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
            <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" />
          </svg>
        </button>
        <p style={{ color: "#fff", fontWeight: 700, fontSize: 17, flex: 1, textShadow: "0 1px 4px rgba(0,0,0,0.4)" }}>
          Animal Profile
        </p>
        {/* Share icon */}
        <button
          className="flex items-center justify-center rounded-xl"
          style={{ width: 36, height: 36, backgroundColor: "rgba(255,255,255,0.18)", backdropFilter: "blur(8px)" }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
            <path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92s2.92-1.31 2.92-2.92-1.31-2.92-2.92-2.92z" />
          </svg>
        </button>
      </div>

      {/* ── Scrollable content ── */}
      <div className="flex-1 overflow-y-auto">

        {/* Hero Image — ClipRRect */}
        <div className="relative w-full overflow-hidden" style={{ height: 240 }}>
          {!imgError ? (
            <img
              src={CAT_IMG}
              alt="Milo the tabby cat"
              className="w-full h-full object-cover"
              onError={() => setImgError(true)}
            />
          ) : (
            <div
              className="w-full h-full flex items-center justify-center"
              style={{ background: `linear-gradient(135deg, ${C.primary}25, ${C.accent}20)` }}
            >
              <span style={{ fontSize: 64 }}>🐱</span>
            </div>
          )}
          {/* Gradient overlay at bottom */}
          <div
            className="absolute bottom-0 left-0 right-0"
            style={{ height: 80, background: `linear-gradient(transparent, ${C.background})` }}
          />
        </div>

        {/* ── Profile content card ── */}
        <div className="px-5 pb-6" style={{ marginTop: -20 }}>

          {/* Name + status row */}
          <div className="flex items-start justify-between gap-3 mb-4">
            <div>
              <h1 style={{ color: C.text, fontWeight: 800, fontSize: 24, lineHeight: 1.15 }}>Milo</h1>
              <div className="flex items-center gap-2 mt-1">
                <span style={{ fontSize: 13 }}>🐱</span>
                <p style={{ color: C.secondary, fontSize: 13, fontWeight: 600 }}>
                  Ginger Tabby · Male · ~2 yrs
                </p>
              </div>
            </div>
            <div className="flex flex-col items-end gap-2">
              <StatusChip status={status} />
              <div
                className="flex items-center gap-1 px-2.5 py-1 rounded-xl"
                style={{ backgroundColor: `${C.primary}12` }}
              >
                <span style={{ fontSize: 10 }}>🐱</span>
                <p style={{ color: C.primary, fontSize: 10, fontWeight: 600 }}>Cat</p>
              </div>
            </div>
          </div>

          {/* ── Location row ── */}
          <div
            className="flex items-center gap-3 rounded-2xl px-4 py-3 mb-4"
            style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}
          >
            {/* location_on icon */}
            <svg width="18" height="18" viewBox="0 0 24 24" fill={C.primary}>
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
            </svg>
            <div className="flex-1">
              <p style={{ color: C.text, fontSize: 13, fontWeight: 600 }}>N28 Engineering Block</p>
              <p style={{ color: C.text, opacity: 0.45, fontSize: 11 }}>UTM Skudai, Johor · ~150m away</p>
            </div>
            <button
              className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl"
              style={{ backgroundColor: `${C.primary}12` }}
            >
              <svg width="13" height="13" viewBox="0 0 24 24" fill={C.primary}>
                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" />
              </svg>
              <p style={{ color: C.primary, fontSize: 10, fontWeight: 700 }}>Map</p>
            </button>
          </div>

          {/* ── Description Card ── */}
          <div
            className="rounded-2xl p-4 mb-4"
            style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}
          >
            <div className="flex items-center gap-2 mb-3">
              <div
                className="w-6 h-6 rounded-lg flex items-center justify-center"
                style={{ backgroundColor: `${C.primary}18` }}
              >
                <svg width="13" height="13" viewBox="0 0 24 24" fill={C.primary}>
                  <path d="M14 17H4v2h10v-2zm6-8H4v2h16V9zM4 15h16v-2H4v2zM4 5v2h16V5H4z" />
                </svg>
              </div>
              <p style={{ color: C.text, fontSize: 12, fontWeight: 700, opacity: 0.65 }}>DESCRIPTION</p>
            </div>
            <p style={{ color: C.text, fontSize: 13, lineHeight: 1.65, opacity: 0.8 }}>
              Friendly ginger tabby spotted near the N28 parking area. Approaches students confidently, appears well-fed and healthy. No visible injuries. Spotted around 2–3 PM during lunch hour. Responds to gentle calling.
            </p>
          </div>

          {/* ── Reporter info grid ── */}
          <div className="grid grid-cols-2 gap-3 mb-4">
            {/* Date reported */}
            <div
              className="rounded-2xl p-3.5"
              style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}
            >
              <DetailRow
                label="Date Reported"
                value="4 May 2026, 2:30 PM"
                icon={
                  <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary}>
                    <path d="M20 3h-1V1h-2v2H7V1H5v2H4c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 18H4V8h16v13z" />
                  </svg>
                }
              />
            </div>
            {/* Reported by */}
            <div
              className="rounded-2xl p-3.5"
              style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}
            >
              <DetailRow
                label="Reported By"
                value="Ahmad Faris"
                accent
                icon={
                  <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary}>
                    <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                  </svg>
                }
              />
            </div>
          </div>

          {/* ── Sighting history ── */}
          <div
            className="rounded-2xl p-4 mb-5"
            style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}
          >
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <div className="w-6 h-6 rounded-lg flex items-center justify-center" style={{ backgroundColor: `${C.primary}18` }}>
                  <svg width="13" height="13" viewBox="0 0 24 24" fill={C.primary}>
                    <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z" />
                  </svg>
                </div>
                <p style={{ color: C.text, fontSize: 12, fontWeight: 700, opacity: 0.65 }}>SIGHTING HISTORY</p>
              </div>
              <span
                className="px-2 py-0.5 rounded-full"
                style={{ backgroundColor: `${C.primary}15`, color: C.primary, fontSize: 10, fontWeight: 700 }}
              >
                3 times
              </span>
            </div>
            {[
              { time: "Today, 2:30 PM",    person: "Ahmad Faris",  note: "Near N28 parking — healthy" },
              { time: "3 May, 10:15 AM",   person: "Siti Nabilah", note: "Engineering cafeteria area" },
              { time: "1 May, 4:45 PM",    person: "Haziq Ariff",  note: "First sighting near N28" },
            ].map((s, i) => (
              <div
                key={i}
                className="flex items-start gap-2.5 py-2"
                style={{ borderTop: i > 0 ? `1px solid ${C.divider}` : "none" }}
              >
                <div className="w-1.5 h-1.5 rounded-full mt-2 flex-shrink-0" style={{ backgroundColor: C.accent }} />
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <p style={{ color: C.text, fontSize: 12, fontWeight: 600 }}>{s.person}</p>
                    <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>{s.time}</p>
                  </div>
                  <p style={{ color: C.text, opacity: 0.5, fontSize: 11, marginTop: 1 }}>{s.note}</p>
                </div>
              </div>
            ))}
          </div>

          {/* ── Action buttons ── */}
          <div className="flex gap-3">
            {/* OutlinedButton: Contact Volunteer */}
            <button
              className="flex-1 flex items-center justify-center gap-2 rounded-2xl"
              style={{
                height: 52,
                backgroundColor: "transparent",
                border: `2px solid ${C.primary}`,
              }}
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill={C.primary}>
                <path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z" />
              </svg>
              <span style={{ color: C.primary, fontWeight: 700, fontSize: 13 }}>Contact Volunteer</span>
            </button>

            {/* ElevatedButton: Mark as Seen */}
            <button
              className="flex-1 flex items-center justify-center gap-2 rounded-2xl"
              style={{
                height: 52,
                background: marked
                  ? `linear-gradient(135deg, #4A7358, ${C.success})`
                  : `linear-gradient(135deg, #74503A, ${C.primary})`,
                boxShadow: marked
                  ? `0 5px 16px ${C.success}45`
                  : `0 5px 16px ${C.primary}45`,
                transition: "all 0.3s",
              }}
              onClick={() => setMarked(!marked)}
            >
              {marked ? (
                <>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="white">
                    <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
                  </svg>
                  <span style={{ color: "#fff", fontWeight: 700, fontSize: 13 }}>Seen ✓</span>
                </>
              ) : (
                <>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="white">
                    <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z" />
                  </svg>
                  <span style={{ color: "#fff", fontWeight: 700, fontSize: 13 }}>Mark as Seen</span>
                </>
              )}
            </button>
          </div>

          <p style={{ color: `${C.text}30`, fontSize: 10, textAlign: "center", marginTop: 10 }}>
            UTM Paws-itive · UC05 View Animal Profile
          </p>
        </div>
      </div>
    </div>
  );
}
