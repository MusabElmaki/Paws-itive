import React from "react";
import { C, FlutterBadge } from "./DSTokens";
import { SectionLabel } from "./ColorTokens";
import { StatusChip } from "./StatusChips";

const mockAnimals = [
  {
    emoji: "🐱",
    name: "Tabby Cat · Female",
    type: "Cat",
    location: "N28 Engineering Block",
    status: "Healthy" as const,
    description: "Friendly orange tabby found near the parking lot. Appears well-fed.",
    date: "Today, 2:30 PM",
    reporter: "Ahmad Faris",
    bg: `${C.primary}12`,
  },
  {
    emoji: "🐶",
    name: "Brown Puppy · Unknown",
    type: "Dog",
    location: "Kolej 13, UTM Skudai",
    status: "NeedsFeeding" as const,
    description: "Small brown dog, ribs slightly visible. Friendly with students.",
    date: "Yesterday, 9:15 AM",
    reporter: "Siti Nabilah",
    bg: `${C.accent}18`,
  },
];

export function Cards() {
  return (
    <section>
      <SectionLabel icon="🃏" title="Card Styles" sub="Animal report Card · Profile detail Card" />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">

        {/* Animal Report Cards */}
        <div className="space-y-3">
          <div className="flex items-center justify-between mb-1">
            <FlutterBadge label="Card — Animal Report (ListView)" />
          </div>
          {mockAnimals.map((a, i) => (
            <AnimalReportCard key={i} animal={a} />
          ))}
          <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>
            elevation: 1 · borderRadius: 16 · margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6)
          </p>
        </div>

        {/* Profile Detail Card */}
        <div className="space-y-3">
          <div className="flex items-center justify-between mb-1">
            <FlutterBadge label="Card — Animal Profile (Detail view)" />
          </div>
          <ProfileDetailCard />
          <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>
            elevation: 0 · borderRadius: 20 · padding: 16 · border: kBorder
          </p>
        </div>

      </div>
    </section>
  );
}

function AnimalReportCard({ animal }: {
  animal: {
    emoji: string; name: string; type: string; location: string;
    status: "Healthy" | "NeedsFeeding" | "Injured" | "Sick" | "Unknown";
    description: string; date: string; reporter: string; bg: string;
  }
}) {
  return (
    <div
      className="rounded-2xl p-4 border transition-all hover:shadow-md"
      style={{
        backgroundColor: C.surface,
        borderColor: C.border,
        boxShadow: `0 1px 6px rgba(58,34,18,0.06)`,
      }}
    >
      <div className="flex items-start gap-3">
        {/* Image placeholder */}
        <div
          className="w-16 h-16 rounded-xl flex-shrink-0 flex items-center justify-center text-2xl"
          style={{ backgroundColor: animal.bg }}
        >
          {animal.emoji}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-2 mb-0.5">
            <p style={{ color: C.text, fontWeight: 700, fontSize: 14, lineHeight: 1.3 }}>
              {animal.name}
            </p>
            <StatusChip status={animal.status} size="sm" />
          </div>
          <div className="flex items-center gap-1 mb-2">
            <span style={{ fontSize: 11, opacity: 0.6 }}>📍</span>
            <p style={{ color: C.text, opacity: 0.55, fontSize: 11 }}>{animal.location}</p>
          </div>
          <p style={{ color: C.text, opacity: 0.55, fontSize: 12, lineHeight: 1.4 }}>
            {animal.description}
          </p>
          <div className="flex items-center justify-between mt-2">
            <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>🕐 {animal.date}</p>
            <p style={{ color: C.primary, opacity: 0.7, fontSize: 10 }}>👤 {animal.reporter}</p>
          </div>
        </div>
      </div>
    </div>
  );
}

function ProfileDetailCard() {
  return (
    <div>
      {/* Hero image */}
      <div
        className="w-full h-44 rounded-2xl flex items-center justify-center mb-4 relative overflow-hidden"
        style={{ backgroundColor: `${C.primary}15` }}
      >
        <span style={{ fontSize: 64 }}>🐱</span>
        <div
          className="absolute bottom-3 right-3 px-3 py-1.5 rounded-xl"
          style={{ backgroundColor: "rgba(0,0,0,0.4)", backdropFilter: "blur(4px)" }}
        >
          <p style={{ color: "#fff", fontSize: 10, fontWeight: 600 }}>🖼 Image placeholder</p>
          <p style={{ color: "rgba(255,255,255,0.6)", fontSize: 9 }}>ClipRRect · borderRadius: 16</p>
        </div>
      </div>

      {/* Detail card */}
      <div
        className="rounded-2xl p-4 border space-y-3"
        style={{ backgroundColor: C.surface, borderColor: C.border }}
      >
        <div className="flex items-start justify-between">
          <div>
            <p style={{ color: C.text, fontWeight: 800, fontSize: 18 }}>Tabby Cat</p>
            <p style={{ color: C.secondary, fontSize: 13 }}>Female · Approximately 2 years old</p>
          </div>
          <StatusChip status="Healthy" />
        </div>

        <div className="flex items-center gap-2 py-2 rounded-xl px-3" style={{ backgroundColor: `${C.primary}08` }}>
          <span style={{ fontSize: 14 }}>📍</span>
          <p style={{ color: C.text, fontSize: 13 }}>N28 Engineering Block, UTM Skudai</p>
        </div>

        <div
          className="rounded-xl p-3"
          style={{ backgroundColor: C.background, border: `1px solid ${C.border}` }}
        >
          <p style={{ color: C.text, opacity: 0.5, fontSize: 10, fontWeight: 600, marginBottom: 4 }}>
            DESCRIPTION
          </p>
          <p style={{ color: C.text, fontSize: 13, lineHeight: 1.6, opacity: 0.8 }}>
            Orange tabby cat found near N28 parking. Friendly and approachable. Appears healthy with no visible injuries. Spotted around 3pm during lunch hour.
          </p>
        </div>

        <div className="grid grid-cols-2 gap-2">
          <div className="rounded-xl p-3" style={{ backgroundColor: C.background }}>
            <p style={{ color: C.text, opacity: 0.4, fontSize: 10, fontWeight: 600 }}>REPORTED BY</p>
            <p style={{ color: C.text, fontSize: 13, fontWeight: 600 }}>Ahmad Faris</p>
          </div>
          <div className="rounded-xl p-3" style={{ backgroundColor: C.background }}>
            <p style={{ color: C.text, opacity: 0.4, fontSize: 10, fontWeight: 600 }}>DATE</p>
            <p style={{ color: C.text, fontSize: 13, fontWeight: 600 }}>4 May 2026</p>
          </div>
        </div>

        <div className="flex gap-2 pt-1">
          <button
            className="flex-1 py-3 rounded-xl text-sm"
            style={{
              backgroundColor: C.primary,
              color: "#fff",
              fontWeight: 700,
              boxShadow: `0 3px 10px ${C.primary}45`,
            }}
          >
            ✅ Mark as Seen
          </button>
          <button
            className="flex-1 py-3 rounded-xl text-sm"
            style={{
              backgroundColor: "transparent",
              color: C.primary,
              fontWeight: 700,
              border: `2px solid ${C.primary}`,
            }}
          >
            📞 Contact Volunteer
          </button>
        </div>
      </div>
    </div>
  );
}
