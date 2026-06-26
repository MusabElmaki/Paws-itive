import React from "react";
import { C, FlutterBadge } from "./DSTokens";
import { SectionLabel } from "./ColorTokens";

export function AppBarPreview() {
  return (
    <section>
      <SectionLabel icon="📱" title="AppBar & Navigation" sub="AppBar · BottomNavigationBar · DrawerHeader" />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-5">

        {/* Home AppBar */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <FlutterBadge label="AppBar — Home" />
          </div>
          <div className="rounded-2xl overflow-hidden border" style={{ borderColor: C.border }}>
            {/* Status bar sim */}
            <div className="px-4 pt-2 pb-1 flex justify-between items-center" style={{ backgroundColor: "#74503A" }}>
              <span style={{ color: "rgba(255,255,255,0.7)", fontSize: 9 }}>9:41 AM</span>
              <div className="flex gap-1">
                {["📶", "🔋"].map(i => <span key={i} style={{ fontSize: 9 }}>{i}</span>)}
              </div>
            </div>
            {/* AppBar */}
            <div className="px-4 py-3 flex items-center justify-between" style={{ backgroundColor: C.primary }}>
              <div>
                <p style={{ color: "rgba(255,255,255,0.65)", fontSize: 10 }}>UTM Paws-itive 🐾</p>
                <p style={{ color: "#FFFFFF", fontWeight: 800, fontSize: 17 }}>Animal Reports</p>
              </div>
              <div className="flex gap-2">
                {["🔔", "👤"].map((ico, i) => (
                  <div key={i} className="w-8 h-8 rounded-full flex items-center justify-center"
                    style={{ backgroundColor: "rgba(255,255,255,0.15)" }}>
                    <span style={{ fontSize: 14 }}>{ico}</span>
                  </div>
                ))}
              </div>
            </div>
            {/* Search bar */}
            <div className="px-4 py-2" style={{ backgroundColor: C.primary }}>
              <div className="flex items-center gap-2 rounded-xl px-3 py-2"
                style={{ backgroundColor: "rgba(255,255,255,0.15)" }}>
                <span style={{ fontSize: 13, color: "rgba(255,255,255,0.6)" }}>🔍</span>
                <span style={{ color: "rgba(255,255,255,0.55)", fontSize: 13 }}>Search animals near campus…</span>
              </div>
            </div>
            {/* Tab row */}
            <div className="px-3 pb-2 flex gap-2" style={{ backgroundColor: C.primary }}>
              {["All", "Cats", "Dogs", "Healthy", "Needs Help"].map((tab, i) => (
                <span key={tab} className="px-3 py-1 rounded-full text-xs"
                  style={{
                    backgroundColor: i === 0 ? "rgba(255,255,255,0.25)" : "transparent",
                    color: "rgba(255,255,255,0.85)",
                    fontWeight: i === 0 ? 700 : 400,
                    border: i !== 0 ? "1px solid rgba(255,255,255,0.25)" : "none",
                    whiteSpace: "nowrap",
                    fontSize: 11,
                  }}>
                  {tab}
                </span>
              ))}
            </div>
          </div>
          <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>
            backgroundColor: kPrimary · elevation: 0 · preferredSize: 56+search+chips
          </p>
        </div>

        {/* Profile / Back AppBar */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <FlutterBadge label="AppBar — Detail (with back)" />
          </div>
          <div className="rounded-2xl overflow-hidden border" style={{ borderColor: C.border }}>
            <div className="px-4 pt-2 pb-1 flex justify-between items-center" style={{ backgroundColor: "#74503A" }}>
              <span style={{ color: "rgba(255,255,255,0.7)", fontSize: 9 }}>9:41 AM</span>
              <div className="flex gap-1">
                {["📶", "🔋"].map(i => <span key={i} style={{ fontSize: 9 }}>{i}</span>)}
              </div>
            </div>
            <div className="px-4 py-3 flex items-center gap-3" style={{ backgroundColor: C.primary }}>
              <div className="w-8 h-8 rounded-full flex items-center justify-center"
                style={{ backgroundColor: "rgba(255,255,255,0.15)" }}>
                <span style={{ color: "#fff", fontSize: 16 }}>←</span>
              </div>
              <p style={{ color: "#FFFFFF", fontWeight: 700, fontSize: 17 }}>Animal Profile</p>
            </div>
          </div>
          <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>
            leading: BackButton · title: "Animal Profile"
          </p>

          {/* BottomNavigationBar */}
          <div className="flex items-center justify-between mt-3">
            <FlutterBadge label="BottomNavigationBar" />
          </div>
          <div
            className="rounded-2xl border px-4 py-3 flex justify-around items-center"
            style={{ backgroundColor: C.surface, borderColor: C.border, boxShadow: `0 -2px 10px rgba(58,34,18,0.06)` }}
          >
            {[
              { icon: "🏠", label: "Home", active: true },
              { icon: "🗺️", label: "Map", active: false },
              { icon: "📋", label: "Reports", active: false },
              { icon: "👤", label: "Profile", active: false },
            ].map((item) => (
              <div key={item.label} className="flex flex-col items-center gap-1">
                <div
                  className="w-9 h-9 rounded-full flex items-center justify-center"
                  style={{ backgroundColor: item.active ? `${C.primary}18` : "transparent" }}
                >
                  <span style={{ fontSize: 17 }}>{item.icon}</span>
                </div>
                <span style={{
                  fontSize: 10,
                  fontWeight: item.active ? 700 : 400,
                  color: item.active ? C.primary : `${C.text}55`,
                }}>
                  {item.label}
                </span>
                {item.active && (
                  <div className="w-1 h-1 rounded-full" style={{ backgroundColor: C.primary }} />
                )}
              </div>
            ))}
          </div>
          <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>
            selectedItemColor: kPrimary · unselectedItemColor: kTextDark55 · type: fixed
          </p>
        </div>
      </div>
    </section>
  );
}
