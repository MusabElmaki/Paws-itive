import React, { useState } from "react";
import { C } from "../ds/DSTokens";

type FilterTag = "All" | "Cats" | "Dogs" | "Healthy" | "Needs Help";
type StatusType = "Healthy" | "NeedsFeeding" | "Injured" | "Sick" | "Unknown";

const statusConfig: Record<StatusType, { label: string; dot: string; color: string; bg: string; border: string }> = {
  Healthy:      { label: "Healthy",       dot: "🟢", color: C.success,        bg: `${C.success}18`,      border: `${C.success}35` },
  NeedsFeeding: { label: "Needs Feeding", dot: "🟡", color: "#8A5E20",        bg: `${C.accent}22`,       border: `${C.accent}45`  },
  Injured:      { label: "Injured",       dot: "🔴", color: C.error,          bg: `${C.error}15`,        border: `${C.error}35`   },
  Sick:         { label: "Sick",          dot: "🟣", color: "#8C7AA9",        bg: "rgba(140,122,169,.15)", border: "rgba(140,122,169,.35)" },
  Unknown:      { label: "Unknown",       dot: "⚪", color: "#888",           bg: "rgba(158,158,158,.15)", border: "rgba(158,158,158,.35)" },
};

const animals = [
  {
    id: 1,
    name: "Milo",
    type: "Cat",
    breed: "Ginger Tabby · Male",
    location: "N28 Engineering Block",
    status: "Healthy" as StatusType,
    desc: "Friendly ginger cat. Approaches students during lunch. Well-fed.",
    date: "Today, 2:30 PM",
    reporter: "Ahmad Faris",
    img: "https://images.unsplash.com/photo-1758607405481-4cfa0341c43d?w=200&h=200&fit=crop&crop=face",
    tag: "Cats",
  },
  {
    id: 2,
    name: "Luna",
    type: "Dog",
    breed: "Mixed Breed · Female",
    location: "Kolej 13, UTM Skudai",
    status: "NeedsFeeding" as StatusType,
    desc: "Small brown dog spotted near hostel. Ribs slightly visible. Friendly.",
    date: "Yesterday, 9:15 AM",
    reporter: "Siti Nabilah",
    img: "https://images.unsplash.com/photo-1721647317927-c4131e54b750?w=200&h=200&fit=crop&crop=face",
    tag: "Dogs",
  },
  {
    id: 3,
    name: "Calico",
    type: "Cat",
    breed: "Calico · Unknown sex",
    location: "KRP Library, UTM",
    status: "Sick" as StatusType,
    desc: "Lethargic calico cat near library. Sneezing frequently. Needs vet.",
    date: "2 days ago",
    reporter: "Haziq Ariff",
    img: "https://images.unsplash.com/photo-1769942893195-83a935c25d33?w=200&h=200&fit=crop&crop=face",
    tag: "Cats",
  },
  {
    id: 4,
    name: "Shadow",
    type: "Cat",
    breed: "Black Kitten · Unknown",
    location: "Tasik Danga, UTM",
    status: "Unknown" as StatusType,
    desc: "Small black kitten seen by the lake. Skittish but not visibly harmed.",
    date: "3 days ago",
    reporter: "Nurul Ain",
    img: "https://images.unsplash.com/photo-1766532280788-2ebac9b44bc6?w=200&h=200&fit=crop&crop=face",
    tag: "Cats",
  },
];

function StatusBadge({ status, small = false }: { status: StatusType; small?: boolean }) {
  const cfg = statusConfig[status];
  return (
    <span
      style={{
        backgroundColor: cfg.bg,
        color: cfg.color,
        border: `1.5px solid ${cfg.border}`,
        borderRadius: 99,
        padding: small ? "2px 7px" : "3px 9px",
        fontSize: small ? 9 : 10,
        fontWeight: 700,
        display: "inline-flex",
        alignItems: "center",
        gap: 4,
        whiteSpace: "nowrap",
        lineHeight: 1.4,
      }}
    >
      <span style={{ fontSize: small ? 7 : 8 }}>{cfg.dot}</span>
      {cfg.label}
    </span>
  );
}

export function Screen4Home() {
  const [activeFilter, setActiveFilter] = useState<FilterTag>("All");
  const filters: FilterTag[] = ["All", "Cats", "Dogs", "Healthy", "Needs Help"];

  const filtered = animals.filter((a) => {
    if (activeFilter === "All") return true;
    if (activeFilter === "Cats") return a.type === "Cat";
    if (activeFilter === "Dogs") return a.type === "Dog";
    if (activeFilter === "Healthy") return a.status === "Healthy";
    if (activeFilter === "Needs Help") return a.status !== "Healthy";
    return true;
  });

  return (
    <div
      className="relative w-full h-full flex flex-col overflow-hidden"
      style={{ backgroundColor: C.background, paddingTop: 54 }}
    >
      {/* ── Custom AppBar (no elevation, blends with search bar) ── */}
      <div
        className="flex-shrink-0"
        style={{
          background: `linear-gradient(175deg, #6B4632, ${C.primary})`,
          paddingBottom: 14,
        }}
      >
        {/* Title row */}
        <div className="flex items-center justify-between px-4 pt-1 pb-2">
          <div>
            <p style={{ color: "rgba(255,255,255,0.65)", fontSize: 11 }}>UTM Paws-itive 🐾</p>
            <p style={{ color: "#fff", fontWeight: 800, fontSize: 19 }}>Animal Reports</p>
          </div>
          <div className="flex items-center gap-2">
            {/* Notification bell */}
            <button
              className="relative flex items-center justify-center rounded-xl"
              style={{ width: 38, height: 38, backgroundColor: "rgba(255,255,255,0.15)" }}
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
                <path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z" />
              </svg>
              {/* Badge dot */}
              <div
                className="absolute rounded-full"
                style={{
                  width: 8, height: 8,
                  backgroundColor: C.accent,
                  top: 6, right: 6,
                  border: `1.5px solid ${C.primary}`,
                }}
              />
            </button>
            {/* Profile avatar */}
            <button
              className="flex items-center justify-center rounded-xl overflow-hidden"
              style={{
                width: 38, height: 38,
                background: `linear-gradient(135deg, ${C.accent}, ${C.secondary})`,
                border: "2px solid rgba(255,255,255,0.3)",
              }}
            >
              <span style={{ color: "#fff", fontWeight: 800, fontSize: 14 }}>AF</span>
            </button>
          </div>
        </div>

        {/* Search bar */}
        <div className="px-4 mb-3">
          <div
            className="flex items-center gap-2.5 rounded-2xl px-4"
            style={{
              height: 44,
              backgroundColor: "rgba(255,255,255,0.16)",
              border: "1px solid rgba(255,255,255,0.22)",
              backdropFilter: "blur(8px)",
            }}
          >
            <svg width="17" height="17" viewBox="0 0 24 24" fill="rgba(255,255,255,0.7)">
              <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
            </svg>
            <span style={{ color: "rgba(255,255,255,0.55)", fontSize: 13, flex: 1 }}>
              Search animals near campus…
            </span>
            {/* Filter icon */}
            <button
              className="flex items-center justify-center rounded-lg"
              style={{ width: 30, height: 30, backgroundColor: "rgba(255,255,255,0.12)" }}
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill="rgba(255,255,255,0.85)">
                <path d="M10 18h4v-2h-4v2zM3 6v2h18V6H3zm3 7h12v-2H6v2z" />
              </svg>
            </button>
          </div>
        </div>

        {/* Filter chips — horizontal scroll */}
        <div className="flex gap-2 px-4 overflow-x-auto" style={{ scrollbarWidth: "none" }}>
          {filters.map((f) => {
            const isActive = activeFilter === f;
            return (
              <button
                key={f}
                onClick={() => setActiveFilter(f)}
                className="flex-shrink-0 flex items-center gap-1.5 rounded-full transition-all"
                style={{
                  padding: "6px 14px",
                  backgroundColor: isActive ? "rgba(255,255,255,0.95)" : "rgba(255,255,255,0.15)",
                  border: `1.5px solid ${isActive ? "rgba(255,255,255,0.8)" : "rgba(255,255,255,0.25)"}`,
                  color: isActive ? C.primary : "rgba(255,255,255,0.9)",
                  fontSize: 12,
                  fontWeight: isActive ? 700 : 500,
                }}
              >
                {f === "Cats" && "🐱"}
                {f === "Dogs" && "🐶"}
                {f === "Healthy" && "💚"}
                {f === "Needs Help" && "🆘"}
                {f}
              </button>
            );
          })}
        </div>
      </div>

      {/* ── Animal count header ── */}
      <div className="flex items-center justify-between px-4 py-3 flex-shrink-0">
        <p style={{ color: C.text, fontSize: 13, fontWeight: 700 }}>
          {filtered.length} {filtered.length === 1 ? "animal" : "animals"} found
        </p>
        <div className="flex items-center gap-1.5">
          <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary}>
            <path d="M3 18h6v-2H3v2zM3 6v2h18V6H3zm3 7h12v-2H6v2z" />
          </svg>
          <p style={{ color: C.primary, fontSize: 12, fontWeight: 600 }}>Sort</p>
        </div>
      </div>

      {/* ── ListView.builder ── */}
      <div className="flex-1 overflow-y-auto px-4" style={{ paddingBottom: 80 }}>
        {filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 gap-3">
            <svg width="48" height="48" viewBox="0 0 64 64" fill={C.primary} style={{ opacity: 0.25 }}>
              <ellipse cx="32" cy="44" rx="17" ry="13" />
              <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="21" cy="17" rx="7" ry="8" />
              <ellipse cx="43" cy="17" rx="7" ry="8" />
            </svg>
            <p style={{ color: C.text, opacity: 0.45, fontSize: 14, fontWeight: 600 }}>No animals found</p>
          </div>
        ) : (
          <div className="space-y-3">
            {filtered.map((animal) => (
              <AnimalCard key={animal.id} animal={animal} />
            ))}
          </div>
        )}
      </div>

      {/* ── FloatingActionButton.extended ── */}
      <div
        className="absolute flex items-center justify-center"
        style={{ bottom: 20, right: 16 }}
      >
        <button
          className="flex items-center gap-2.5 rounded-2xl"
          style={{
            height: 52,
            paddingLeft: 20,
            paddingRight: 24,
            background: `linear-gradient(135deg, #74503A, ${C.primary})`,
            boxShadow: `0 6px 20px ${C.primary}55, 0 2px 6px rgba(0,0,0,0.2)`,
          }}
        >
          {/* pets icon */}
          <svg width="20" height="20" viewBox="0 0 64 64" fill="white">
            <ellipse cx="32" cy="44" rx="17" ry="13" />
            <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="21" cy="17" rx="7" ry="8" />
            <ellipse cx="43" cy="17" rx="7" ry="8" />
          </svg>
          <span style={{ color: "#fff", fontWeight: 800, fontSize: 14, letterSpacing: 0.4 }}>
            Report Animal
          </span>
        </button>
      </div>
    </div>
  );
}

// ── Animal Report Card ─────────────────────────────────────────────────────

function AnimalCard({ animal }: { animal: typeof animals[0] }) {
  return (
    <div
      className="rounded-2xl overflow-hidden border transition-all"
      style={{
        backgroundColor: C.surface,
        borderColor: C.border,
        boxShadow: `0 2px 10px rgba(58,34,18,0.06)`,
      }}
    >
      <div className="flex items-start gap-3 p-3.5">
        {/* Animal image — ClipRRect */}
        <div
          className="flex-shrink-0 rounded-2xl overflow-hidden"
          style={{ width: 76, height: 76, backgroundColor: `${C.primary}15` }}
        >
          <img
            src={animal.img}
            alt={animal.name}
            className="w-full h-full object-cover"
          />
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          {/* Name row */}
          <div className="flex items-start justify-between gap-2 mb-0.5">
            <div className="min-w-0">
              <p style={{ color: C.text, fontWeight: 800, fontSize: 14, lineHeight: 1.2 }}>
                {animal.name}
              </p>
              <p style={{ color: C.secondary, fontSize: 11, marginTop: 1 }}>{animal.breed}</p>
            </div>
            <StatusBadge status={animal.status} small />
          </div>

          {/* Location row — location_on icon */}
          <div className="flex items-center gap-1 mt-1.5 mb-1.5">
            <svg width="12" height="12" viewBox="0 0 24 24" fill={C.primary} style={{ flexShrink: 0, opacity: 0.75 }}>
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
            </svg>
            <p style={{ color: C.text, opacity: 0.55, fontSize: 11 }}>{animal.location}</p>
          </div>

          {/* Description */}
          <p
            style={{
              color: C.text,
              opacity: 0.6,
              fontSize: 11,
              lineHeight: 1.45,
              overflow: "hidden",
              display: "-webkit-box",
              WebkitLineClamp: 2,
              WebkitBoxOrient: "vertical" as const,
            }}
          >
            {animal.desc}
          </p>

          {/* Date & reporter row */}
          <div className="flex items-center justify-between mt-2">
            <div className="flex items-center gap-1">
              <svg width="10" height="10" viewBox="0 0 24 24" fill={C.text} style={{ opacity: 0.3 }}>
                <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z" />
              </svg>
              <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>{animal.date}</p>
            </div>
            <div className="flex items-center gap-1">
              <svg width="10" height="10" viewBox="0 0 24 24" fill={C.primary} style={{ opacity: 0.6 }}>
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
              </svg>
              <p style={{ color: C.primary, opacity: 0.65, fontSize: 10 }}>{animal.reporter}</p>
            </div>
          </div>
        </div>
      </div>

      {/* View Profile button row */}
      <div
        className="flex items-center justify-between px-3.5 py-2.5 border-t"
        style={{ borderColor: C.divider, backgroundColor: `${C.primary}04` }}
      >
        <div className="flex items-center gap-1.5">
          <span style={{ fontSize: 10 }}>
            {animal.type === "Cat" ? "🐱" : "🐶"}
          </span>
          <p style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>{animal.type}</p>
        </div>
        <button className="flex items-center gap-1">
          <p style={{ color: C.primary, fontSize: 11, fontWeight: 700 }}>View Profile</p>
          <svg width="12" height="12" viewBox="0 0 24 24" fill={C.primary}>
            <path d="M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z" />
          </svg>
        </button>
      </div>
    </div>
  );
}
