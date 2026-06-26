import React from "react";

interface Token {
  token: string;
  hex: string;
  usage: string;
  bg: string;
  text: string;
}

interface TokenTableProps {
  tokens: Token[];
  accentColor: string;
  bgColor: string;
  textColor: string;
}

export function TokenTable({ tokens, accentColor, bgColor, textColor }: TokenTableProps) {
  return (
    <div
      className="rounded-2xl overflow-hidden border"
      style={{ borderColor: `${textColor}12`, backgroundColor: bgColor }}
    >
      <div
        className="px-5 py-3 flex items-center gap-2"
        style={{ backgroundColor: `${textColor}07`, borderBottom: `1px solid ${textColor}10` }}
      >
        <span style={{ fontSize: 14 }}>🎨</span>
        <p style={{ color: textColor, fontWeight: 700, fontSize: 13 }}>
          Flutter Design Tokens — Dart Color Constants
        </p>
      </div>
      <div className="divide-y" style={{ borderColor: `${textColor}08` }}>
        {tokens.map((token, i) => (
          <div
            key={token.token}
            className="flex items-center gap-3 px-5 py-3"
            style={{ backgroundColor: i % 2 === 0 ? "transparent" : `${textColor}03` }}
          >
            <div
              className="w-8 h-8 rounded-lg flex-shrink-0 shadow-sm border"
              style={{
                backgroundColor: token.bg,
                borderColor: `${textColor}15`,
              }}
            />
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <code
                  className="text-xs px-2 py-0.5 rounded"
                  style={{
                    backgroundColor: `${accentColor}15`,
                    color: accentColor,
                    fontFamily: "monospace",
                    fontSize: 11,
                  }}
                >
                  {token.token}
                </code>
                <span
                  className="text-xs"
                  style={{ color: textColor, opacity: 0.45, fontFamily: "monospace" }}
                >
                  {token.hex}
                </span>
              </div>
              <p className="text-xs mt-0.5" style={{ color: textColor, opacity: 0.55, fontSize: 11 }}>
                {token.usage}
              </p>
            </div>
          </div>
        ))}
      </div>
      {/* Dart code snippet preview */}
      <div
        className="px-5 py-4"
        style={{ backgroundColor: "#1E1E2E", borderTop: `1px solid ${textColor}15` }}
      >
        <p style={{ color: "#CDD6F4", fontSize: 11, fontFamily: "monospace", marginBottom: 6, opacity: 0.6 }}>
          // lib/core/theme/app_colors.dart
        </p>
        {tokens.slice(0, 4).map((token) => (
          <p key={token.token} style={{ fontSize: 11, fontFamily: "monospace", lineHeight: 1.8 }}>
            <span style={{ color: "#89B4FA" }}>static</span>
            <span style={{ color: "#CDD6F4" }}> </span>
            <span style={{ color: "#89DCEB" }}>const</span>
            <span style={{ color: "#CDD6F4" }}> Color </span>
            <span style={{ color: "#A6E3A1" }}>{token.token}</span>
            <span style={{ color: "#CDD6F4" }}> = </span>
            <span style={{ color: "#FAB387" }}>Color(</span>
            <span style={{ color: "#F38BA8" }}>0xFF{token.hex.replace("#", "")}</span>
            <span style={{ color: "#FAB387" }}>)</span>
            <span style={{ color: "#CDD6F4" }}>;</span>
          </p>
        ))}
        <p style={{ color: "#6C7086", fontSize: 11, fontFamily: "monospace", marginTop: 4 }}>
          // ... and more
        </p>
      </div>
    </div>
  );
}
