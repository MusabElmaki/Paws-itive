import React from "react";

// Shared design tokens for the UTM Paws-itive design system board
export const C = {
  primary:    "#8B6248",
  secondary:  "#A67C5B",
  accent:     "#C9956C",
  background: "#F5EDE3",
  surface:    "#FDF9F5",
  text:       "#3A2212",
  error:      "#B85050",
  success:    "#5E876A",
  sick:       "#8C7AA9",
  unknown:    "#9E9E9E",
  border:     "rgba(58,34,18,0.10)",
  divider:    "rgba(58,34,18,0.07)",
};

// Paragraph convenience component
export function P({
  children,
  style,
}: {
  children: React.ReactNode;
  style?: React.CSSProperties;
}) {
  return (
    <p style={{ color: C.text, opacity: 0.65, fontSize: 13, lineHeight: 1.6, ...style }}>
      {children}
    </p>
  );
}

// A small Flutter widget annotation badge
export function FlutterBadge({ label }: { label: string }) {
  return (
    <span
      style={{
        backgroundColor: `${C.primary}15`,
        color: C.primary,
        fontSize: 9,
        fontWeight: 700,
        fontFamily: "monospace",
        padding: "2px 7px",
        borderRadius: 99,
        border: `1px solid ${C.primary}30`,
        letterSpacing: 0.3,
      }}
    >
      {label}
    </span>
  );
}

// Dart code block
export function DartCode({ code }: { code: string }) {
  const lines = code.trim().split("\n");
  return (
    <div
      className="rounded-xl overflow-hidden"
      style={{ backgroundColor: "#1E1E2E", border: "1px solid rgba(255,255,255,0.06)" }}
    >
      <div
        className="px-4 py-2 flex items-center gap-1.5"
        style={{ backgroundColor: "#181825", borderBottom: "1px solid rgba(255,255,255,0.05)" }}
      >
        {["#FF5F57", "#FFBD2E", "#28C840"].map((c) => (
          <div key={c} className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: c }} />
        ))}
        <span style={{ color: "#6C7086", fontSize: 10, marginLeft: 6, fontFamily: "monospace" }}>
          .dart
        </span>
      </div>
      <pre className="px-4 py-3 overflow-x-auto" style={{ margin: 0 }}>
        {lines.map((line, i) => (
          <DartLine key={i} line={line} />
        ))}
      </pre>
    </div>
  );
}

function DartLine({ line }: { line: string }) {
  // Very simple syntax colouring
  const parts: { text: string; color: string }[] = [];

  if (line.trim().startsWith("//")) {
    parts.push({ text: line, color: "#6C7086" });
  } else {
    // tokenise by keywords
    const keywords = ["const", "static", "final", "Color", "ThemeData", "ColorScheme", "TextTheme", "return", "class", "void", "Widget", "BuildContext", "override"];
    let remaining = line;
    while (remaining.length > 0) {
      let matched = false;
      for (const kw of keywords) {
        if (remaining.startsWith(kw) && (remaining.length === kw.length || /\W/.test(remaining[kw.length]))) {
          parts.push({ text: kw, color: "#89B4FA" });
          remaining = remaining.slice(kw.length);
          matched = true;
          break;
        }
      }
      if (!matched) {
        // hex strings
        const hexMatch = remaining.match(/^(0xFF[0-9A-Fa-f]{6}|"[^"]*"|'[^']*')/);
        if (hexMatch) {
          parts.push({ text: hexMatch[0], color: "#F38BA8" });
          remaining = remaining.slice(hexMatch[0].length);
        } else {
          // identifiers starting with k
          const identMatch = remaining.match(/^k[A-Za-z0-9]+/);
          if (identMatch) {
            parts.push({ text: identMatch[0], color: "#A6E3A1" });
            remaining = remaining.slice(identMatch[0].length);
          } else {
            parts.push({ text: remaining[0], color: "#CDD6F4" });
            remaining = remaining.slice(1);
          }
        }
      }
    }
  }

  return (
    <div style={{ lineHeight: 1.8 }}>
      {parts.map((p, i) => (
        <span key={i} style={{ color: p.color, fontFamily: "monospace", fontSize: 11 }}>
          {p.text}
        </span>
      ))}
    </div>
  );
}