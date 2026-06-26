import React from "react";
import { C, FlutterBadge } from "./DSTokens";
import { SectionLabel } from "./ColorTokens";

const typeStyles = [
  {
    name: "displayLarge",
    sample: "UTM Paws-itive",
    size: 32,
    weight: 800,
    usage: "Splash screen app title",
    color: C.primary,
  },
  {
    name: "headlineMedium",
    sample: "Stray Animal Reports",
    size: 26,
    weight: 700,
    usage: "Screen titles / page headers",
    color: C.text,
  },
  {
    name: "titleLarge",
    sample: "Report Details",
    size: 20,
    weight: 700,
    usage: "Section titles / card headers",
    color: C.text,
  },
  {
    name: "titleMedium",
    sample: "Orange Tabby Cat · Female",
    size: 16,
    weight: 600,
    usage: "Animal name labels, list tile titles",
    color: C.text,
  },
  {
    name: "bodyLarge",
    sample: "Found near N28 Engineering Block, appears healthy and friendly. Spotted around 3pm.",
    size: 15,
    weight: 400,
    usage: "Main body text, descriptions",
    color: C.text,
  },
  {
    name: "bodyMedium",
    sample: "Reported by Ahmad Faris · 2 hours ago",
    size: 13,
    weight: 400,
    usage: "Secondary body, meta information",
    color: C.text,
    opacity: 0.65,
  },
  {
    name: "labelLarge",
    sample: "SUBMIT REPORT",
    size: 14,
    weight: 700,
    usage: "ElevatedButton & OutlinedButton text",
    color: C.primary,
    letterSpacing: 0.8,
  },
  {
    name: "labelMedium",
    sample: "Filter · Location · Status",
    size: 12,
    weight: 600,
    usage: "Chip labels, small button text",
    color: C.secondary,
    letterSpacing: 0.4,
  },
  {
    name: "bodySmall",
    sample: "📍 N28 Engineering Block, UTM Skudai",
    size: 11,
    weight: 400,
    usage: "Captions, timestamps, helper text",
    color: C.text,
    opacity: 0.5,
  },
];

export function Typography() {
  return (
    <section>
      <SectionLabel
        icon="🔤"
        title="TextTheme"
        sub="Material 3 type scale — Nunito Sans / Poppins recommended"
      />
      <div
        className="rounded-2xl overflow-hidden border"
        style={{ borderColor: C.border, backgroundColor: C.surface }}
      >
        {/* Font recommendation banner */}
        <div
          className="px-5 py-3 flex items-center gap-3 flex-wrap"
          style={{ backgroundColor: `${C.primary}10`, borderBottom: `1px solid ${C.border}` }}
        >
          <span style={{ fontSize: 13 }}>💡</span>
          <p style={{ color: C.primary, fontSize: 12, fontWeight: 600 }}>
            Recommended Flutter font:{" "}
            <code
              style={{
                backgroundColor: `${C.primary}18`,
                padding: "1px 6px",
                borderRadius: 4,
                fontFamily: "monospace",
                fontSize: 11,
              }}
            >
              google_fonts: ^6.x
            </code>{" "}
            →{" "}
            <strong>Nunito Sans</strong> (body) +{" "}
            <strong>Poppins</strong> (display/headline)
          </p>
        </div>

        <div className="divide-y" style={{ borderColor: C.divider }}>
          {typeStyles.map((t, i) => (
            <div
              key={t.name}
              className="px-5 py-4 flex items-start justify-between gap-4"
              style={{ backgroundColor: i % 2 === 0 ? "transparent" : `${C.text}02` }}
            >
              <div className="flex-1 min-w-0">
                <p
                  style={{
                    color: t.color,
                    fontSize: t.size,
                    fontWeight: t.weight,
                    letterSpacing: t.letterSpacing,
                    opacity: t.opacity,
                    lineHeight: 1.3,
                    wordBreak: "break-word",
                  }}
                >
                  {t.sample}
                </p>
              </div>
              <div className="flex-shrink-0 text-right space-y-1">
                <div>
                  <FlutterBadge label={t.name} />
                </div>
                <p style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>
                  {t.size}sp · w{t.weight}
                </p>
                <p style={{ color: C.text, opacity: 0.35, fontSize: 10, maxWidth: 160, lineHeight: 1.4 }}>
                  {t.usage}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
