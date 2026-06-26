import React from "react";
import { P } from "./DSTokens";

const tokens = [
  { name: "kPrimary",    hex: "#8B6248", role: "AppBar · ElevatedButton · FAB",        on: "#FFFFFF" },
  { name: "kSecondary",  hex: "#A67C5B", role: "OutlinedButton · Tab indicators",       on: "#FFFFFF" },
  { name: "kAccent",     hex: "#C9956C", role: "Active chips · Highlights · Badges",    on: "#3A2212" },
  { name: "kBackground", hex: "#F5EDE3", role: "Scaffold background",                   on: "#3A2212" },
  { name: "kSurface",    hex: "#FDF9F5", role: "Card · Dialog · BottomSheet",           on: "#3A2212" },
  { name: "kOnPrimary",  hex: "#FFFFFF", role: "Text/icons on primary surface",         on: "#8B6248" },
  { name: "kTextDark",   hex: "#3A2212", role: "Body & heading text",                   on: "#FDF9F5" },
  { name: "kError",      hex: "#B85050", role: "Error states · Injured chip",           on: "#FFFFFF" },
  { name: "kSuccess",    hex: "#5E876A", role: "Healthy chip · Success states",         on: "#FFFFFF" },
  { name: "kWarning",    hex: "#C9956C", role: "Needs Feeding chip · Warnings",         on: "#3A2212" },
  { name: "kSick",       hex: "#8C7AA9", role: "Sick chip",                             on: "#FFFFFF" },
  { name: "kUnknown",    hex: "#9E9E9E", role: "Unknown status chip",                   on: "#FFFFFF" },
];

export function ColorTokens() {
  return (
    <section>
      <SectionLabel icon="🎨" title="Color Tokens" sub="12 design tokens — paste into app_colors.dart" />
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-3">
        {tokens.map((t) => (
          <div key={t.name} className="rounded-2xl overflow-hidden shadow-sm border" style={{ borderColor: "rgba(58,34,18,0.08)" }}>
            <div
              className="h-16 w-full flex items-end justify-end p-1.5"
              style={{ backgroundColor: t.hex }}
            >
              <div
                className="text-xs px-1.5 py-0.5 rounded"
                style={{ backgroundColor: "rgba(0,0,0,0.18)", color: t.on === "#FFFFFF" ? "#fff" : "rgba(0,0,0,0.6)", fontSize: 9 }}
              >
                {t.hex}
              </div>
            </div>
            <div className="px-2.5 py-2" style={{ backgroundColor: "#FDF9F5" }}>
              <p style={{ color: "#8B6248", fontSize: 10, fontWeight: 700, fontFamily: "monospace" }}>{t.name}</p>
              <p style={{ color: "#3A2212", opacity: 0.5, fontSize: 9, lineHeight: 1.4, marginTop: 2 }}>{t.role}</p>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

export function SectionLabel({ icon, title, sub }: { icon: string; title: string; sub?: string }) {
  return (
    <div className="mb-4">
      <div className="flex items-center gap-2">
        <span className="text-lg">{icon}</span>
        <h2 style={{ color: "#3A2212", fontSize: 18, fontWeight: 800 }}>{title}</h2>
      </div>
      {sub && <p style={{ color: "#8B6248", fontSize: 12, marginTop: 2, paddingLeft: 28 }}>{sub}</p>}
    </div>
  );
}

// re-export P as a convenience
export { P };
