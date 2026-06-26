import React from "react";
import { C, FlutterBadge } from "./DSTokens";
import { SectionLabel } from "./ColorTokens";

export type StatusType = "Healthy" | "NeedsFeeding" | "Injured" | "Sick" | "Unknown";

const chipConfig: Record<StatusType, { label: string; icon: string; bg: string; text: string; border: string }> = {
  Healthy: {
    label: "Healthy",
    icon: "🟢",
    bg: `${C.success}18`,
    text: C.success,
    border: `${C.success}35`,
  },
  NeedsFeeding: {
    label: "Needs Feeding",
    icon: "🟡",
    bg: `${C.accent}22`,
    text: "#8A5E20",
    border: `${C.accent}45`,
  },
  Injured: {
    label: "Injured",
    icon: "🔴",
    bg: `${C.error}15`,
    text: C.error,
    border: `${C.error}35`,
  },
  Sick: {
    label: "Sick",
    icon: "🟣",
    bg: `${C.sick}18`,
    text: C.sick,
    border: `${C.sick}35`,
  },
  Unknown: {
    label: "Unknown",
    icon: "⚪",
    bg: `${C.unknown}15`,
    text: "#666",
    border: `${C.unknown}35`,
  },
};

interface StatusChipProps {
  status: StatusType;
  size?: "sm" | "md" | "lg";
}

export function StatusChip({ status, size = "md" }: StatusChipProps) {
  const cfg = chipConfig[status];
  const padding = size === "sm" ? "2px 8px" : size === "lg" ? "6px 14px" : "4px 10px";
  const fontSize = size === "sm" ? 10 : size === "lg" ? 13 : 11;
  const iconSize = size === "sm" ? 8 : size === "lg" ? 12 : 10;

  return (
    <span
      style={{
        backgroundColor: cfg.bg,
        color: cfg.text,
        border: `1.5px solid ${cfg.border}`,
        borderRadius: 99,
        padding,
        fontSize,
        fontWeight: 700,
        display: "inline-flex",
        alignItems: "center",
        gap: size === "sm" ? 3 : 5,
        lineHeight: 1,
        whiteSpace: "nowrap",
      }}
    >
      <span style={{ fontSize: iconSize }}>{cfg.icon}</span>
      {cfg.label}
    </span>
  );
}

export function StatusChipsSection() {
  const sizes: Array<"sm" | "md" | "lg"> = ["sm", "md", "lg"];
  const statuses: StatusType[] = ["Healthy", "NeedsFeeding", "Injured", "Sick", "Unknown"];

  return (
    <section>
      <SectionLabel icon="🏷️" title="Status Chips" sub="FilterChip · Chip · ChoiceChip — 5 health statuses × 3 sizes" />

      <div
        className="rounded-2xl border overflow-hidden"
        style={{ backgroundColor: C.surface, borderColor: C.border }}
      >
        {/* Header row */}
        <div
          className="grid px-5 py-3"
          style={{
            gridTemplateColumns: "1.6fr 1fr 1fr 1fr",
            backgroundColor: `${C.primary}10`,
            borderBottom: `1px solid ${C.border}`,
          }}
        >
          {["Status", "Small (sm)", "Medium (md)", "Large (lg)"].map((h) => (
            <div key={h} style={{ color: C.primary, fontSize: 11, fontWeight: 700 }}>{h}</div>
          ))}
        </div>

        {statuses.map((status, i) => (
          <div
            key={status}
            className="grid px-5 py-4 items-center"
            style={{
              gridTemplateColumns: "1.6fr 1fr 1fr 1fr",
              backgroundColor: i % 2 === 0 ? "transparent" : `${C.text}02`,
              borderBottom: i < statuses.length - 1 ? `1px solid ${C.divider}` : "none",
            }}
          >
            <div>
              <p style={{ color: C.text, fontSize: 12, fontWeight: 600 }}>{status}</p>
              <p style={{ color: C.text, opacity: 0.4, fontSize: 10, marginTop: 1 }}>
                {chipConfig[status].text}
              </p>
            </div>
            {sizes.map((sz) => (
              <div key={sz}>
                <StatusChip status={status} size={sz} />
              </div>
            ))}
          </div>
        ))}

        {/* Usage notes */}
        <div
          className="px-5 py-4 grid grid-cols-1 sm:grid-cols-3 gap-3"
          style={{ backgroundColor: `${C.text}03`, borderTop: `1px solid ${C.border}` }}
        >
          {[
            { badge: "FilterChip", note: "Home screen filter bar — All, Cats, Dogs, Healthy, Needs Help" },
            { badge: "Chip (status)", note: "Inside Animal Report Cards and Profile screen" },
            { badge: "ChoiceChip", note: "Report form — health status selection" },
          ].map((item) => (
            <div key={item.badge} className="flex items-start gap-2">
              <FlutterBadge label={item.badge} />
              <p style={{ color: C.text, opacity: 0.5, fontSize: 10, lineHeight: 1.5, marginTop: 1 }}>
                {item.note}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
