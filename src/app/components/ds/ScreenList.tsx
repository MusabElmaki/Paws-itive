import React, { useState } from "react";
import { C, FlutterBadge } from "./DSTokens";
import { SectionLabel } from "./ColorTokens";

const screens = [
  {
    number: "S1",
    name: "Splash / Welcome",
    emoji: "🐾",
    useCase: "App entry point",
    bg: C.primary,
    textColor: "#FFFFFF",
    widgets: ["Scaffold", "Center", "Column", "Icon(pets)", "ElevatedButton"],
    elements: [
      "Paw / pets icon (large, centered)",
      "App name: UTM Paws-itive",
      'Tagline: "Report, Track, and Care for Stray Animals in UTM"',
      "ElevatedButton: Get Started",
    ],
    navigation: "→ Login Screen",
    preview: <SplashPreview />,
  },
  {
    number: "S2",
    name: "Login",
    emoji: "🔐",
    useCase: "UC02 Login / Logout",
    bg: C.surface,
    textColor: C.text,
    widgets: ["Scaffold", "Column", "TextField ×2", "ElevatedButton", "TextButton"],
    elements: [
      "Email TextField",
      "Password TextField (obscureText)",
      "ElevatedButton: Login",
      "TextButton: Create new account",
      "Error message widget",
    ],
    navigation: "→ Home · ← Register",
    preview: <LoginPreview />,
  },
  {
    number: "S3",
    name: "Register Account",
    emoji: "📝",
    useCase: "UC01 Register Account",
    bg: C.surface,
    textColor: C.text,
    widgets: ["Scaffold", "AppBar", "Form", "TextField ×4", "SegmentedButton", "ElevatedButton"],
    elements: [
      "Full Name, Email, Password, Confirm Password TextFields",
      "Role selector: Student / Staff / Volunteer",
      "ElevatedButton: Register",
      "TextButton: Already have an account?",
    ],
    navigation: "→ Home · ← Login",
    preview: <RegisterPreview />,
  },
  {
    number: "S4",
    name: "Home / Animal List",
    emoji: "🏠",
    useCase: "UC04 View Animal List",
    bg: C.background,
    textColor: C.text,
    widgets: ["Scaffold", "AppBar", "TextField (search)", "FilterChip list", "ListView.builder", "Card", "FAB.extended"],
    elements: [
      "AppBar with search + filter chips",
      "ListView of Animal Report Cards",
      "Each card: image, name, location, status chip, date",
      "FAB.extended: 🐾 Report Animal",
    ],
    navigation: "→ Animal Profile · → Report Form",
    preview: <HomePreview />,
  },
  {
    number: "S5",
    name: "Report Stray Animal",
    emoji: "📸",
    useCase: "UC03 Report Stray Animal",
    bg: C.surface,
    textColor: C.text,
    widgets: ["Scaffold", "AppBar", "Form", "Container (image)", "SegmentedButton", "TextField ×2", "DropdownButtonFormField", "ElevatedButton"],
    elements: [
      "Image upload placeholder (camera_alt)",
      "Animal type selector: Cat / Dog / Unknown",
      "Location & Description TextFields",
      "Health status Dropdown",
      "ElevatedButton: Submit Report",
      "Validation error messages",
    ],
    navigation: "→ Success Screen · ← Home",
    preview: <ReportPreview />,
  },
  {
    number: "S6",
    name: "Animal Profile",
    emoji: "🐱",
    useCase: "UC05 View Animal Profile",
    bg: C.background,
    textColor: C.text,
    widgets: ["Scaffold", "AppBar", "ClipRRect (image)", "Card", "Chip (status)", "Row (location)", "ElevatedButton", "OutlinedButton"],
    elements: [
      "Full-width animal image (ClipRRect)",
      "Animal name, type, status chip",
      "Location row with location_on icon",
      "Description Card",
      "Reported by & Date info",
      "ElevatedButton: Mark as Seen",
      "OutlinedButton: Contact Volunteer",
    ],
    navigation: "← Home (back button)",
    preview: <ProfilePreview />,
  },
  {
    number: "S7",
    name: "Success / Confirmation",
    emoji: "✅",
    useCase: "After UC03 submit",
    bg: C.surface,
    textColor: C.text,
    widgets: ["Scaffold or AlertDialog", "Icon(check_circle)", "ElevatedButton", "OutlinedButton"],
    elements: [
      "Large check_circle icon (kSuccess color)",
      'Text: "Animal report submitted successfully!"',
      "ElevatedButton: View Animal List",
      "OutlinedButton: Submit Another Report",
    ],
    navigation: "→ Home · → Report Form",
    preview: <SuccessPreview />,
  },
  {
    number: "S8",
    name: "Empty State",
    emoji: "🌵",
    useCase: "UC04 — no reports yet",
    bg: C.background,
    textColor: C.text,
    widgets: ["Scaffold or Widget", "Center", "Column", "Icon(pets)", "ElevatedButton"],
    elements: [
      "Friendly paw/pets icon (muted)",
      'Text: "No animal reports yet"',
      'Text: "Be the first to report a stray animal in UTM"',
      "ElevatedButton: Report Animal",
    ],
    navigation: "→ Report Form",
    preview: <EmptyPreview />,
  },
];

export function ScreenList() {
  const [expandedScreen, setExpandedScreen] = useState<string | null>(null);

  return (
    <section>
      <SectionLabel
        icon="📱"
        title="Sprint 1 — Screen List"
        sub="8 screens · Flutter widgets · Use case references · Mobile 390×844"
      />

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
        {screens.map((s) => (
          <div key={s.number}>
            {/* Mobile frame card */}
            <div
              className="rounded-3xl overflow-hidden border-2 cursor-pointer transition-all hover:shadow-xl"
              style={{
                borderColor: expandedScreen === s.number ? C.primary : C.border,
                boxShadow: expandedScreen === s.number ? `0 8px 24px ${C.primary}35` : `0 2px 8px rgba(58,34,18,0.07)`,
                transform: expandedScreen === s.number ? "translateY(-2px)" : "none",
                transition: "all 0.2s",
              }}
              onClick={() => setExpandedScreen(expandedScreen === s.number ? null : s.number)}
            >
              {/* Status bar */}
              <div className="px-4 py-1.5 flex justify-between" style={{ backgroundColor: "#74503A" }}>
                <span style={{ color: "rgba(255,255,255,0.7)", fontSize: 8 }}>9:41</span>
                <span style={{ color: "rgba(255,255,255,0.7)", fontSize: 8 }}>📶 🔋</span>
              </div>

              {/* Screen preview */}
              <div style={{ backgroundColor: s.bg, minHeight: 280 }}>
                {s.preview}
              </div>
            </div>

            {/* Screen label */}
            <div className="mt-2 px-1">
              <div className="flex items-center gap-2 mb-1">
                <span
                  className="text-xs px-2 py-0.5 rounded"
                  style={{ backgroundColor: C.primary, color: "#fff", fontWeight: 700, fontSize: 10 }}
                >
                  {s.number}
                </span>
                <span style={{ color: C.text, fontWeight: 700, fontSize: 13 }}>{s.name}</span>
              </div>
              <p style={{ color: C.primary, fontSize: 10, opacity: 0.7 }}>{s.useCase}</p>
              <p style={{ color: C.text, opacity: 0.4, fontSize: 10, marginTop: 2 }}>{s.navigation}</p>
            </div>

            {/* Expanded details */}
            {expandedScreen === s.number && (
              <div
                className="mt-2 rounded-2xl p-4 border space-y-3"
                style={{ backgroundColor: C.surface, borderColor: `${C.primary}30` }}
              >
                <div>
                  <p style={{ color: C.primary, fontSize: 11, fontWeight: 700, marginBottom: 6 }}>
                    Flutter Widgets
                  </p>
                  <div className="flex flex-wrap gap-1.5">
                    {s.widgets.map((w) => (
                      <FlutterBadge key={w} label={w} />
                    ))}
                  </div>
                </div>
                <div>
                  <p style={{ color: C.primary, fontSize: 11, fontWeight: 700, marginBottom: 4 }}>
                    UI Elements
                  </p>
                  <ul className="space-y-1">
                    {s.elements.map((el) => (
                      <li key={el} className="flex items-start gap-2">
                        <span style={{ color: C.accent, fontSize: 10, marginTop: 2 }}>▸</span>
                        <p style={{ color: C.text, opacity: 0.65, fontSize: 11, lineHeight: 1.5 }}>{el}</p>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      <p className="text-center mt-4" style={{ color: C.text, opacity: 0.4, fontSize: 11 }}>
        💡 Tap any screen card to see Flutter widget details and UI element breakdown
      </p>
    </section>
  );
}

// ─── Inline screen previews ──────────────────────────────────────────────────

function SplashPreview() {
  return (
    <div className="flex flex-col items-center justify-center py-10 px-4 gap-3" style={{ backgroundColor: C.primary }}>
      <div className="w-16 h-16 rounded-2xl flex items-center justify-center" style={{ backgroundColor: "rgba(255,255,255,0.2)" }}>
        <span style={{ fontSize: 32 }}>🐾</span>
      </div>
      <p style={{ color: "#fff", fontWeight: 800, fontSize: 18, textAlign: "center" }}>UTM Paws-itive</p>
      <p style={{ color: "rgba(255,255,255,0.7)", fontSize: 10, textAlign: "center", lineHeight: 1.5 }}>
        Report, Track, and Care for<br />Stray Animals in UTM
      </p>
      <div className="w-full mt-4 py-3 rounded-xl text-center" style={{ backgroundColor: "#fff" }}>
        <span style={{ color: C.primary, fontWeight: 700, fontSize: 13 }}>Get Started</span>
      </div>
      <p style={{ color: "rgba(255,255,255,0.4)", fontSize: 9, marginTop: 8 }}>Universiti Teknologi Malaysia</p>
    </div>
  );
}

function LoginPreview() {
  return (
    <div className="px-4 py-6 space-y-3" style={{ backgroundColor: C.surface }}>
      <div className="flex justify-center mb-2">
        <span style={{ fontSize: 28 }}>🐾</span>
      </div>
      <p style={{ color: C.text, fontWeight: 800, fontSize: 16, textAlign: "center" }}>Welcome Back</p>
      <FieldMini label="Email" placeholder="student@graduate.utm.my" icon="✉️" />
      <FieldMini label="Password" placeholder="••••••••" icon="🔒" />
      <div className="pt-1">
        <div className="w-full py-2.5 rounded-xl text-center" style={{ backgroundColor: C.primary }}>
          <span style={{ color: "#fff", fontWeight: 700, fontSize: 12 }}>Login</span>
        </div>
      </div>
      <p style={{ color: C.primary, fontSize: 10, textAlign: "center", textDecoration: "underline" }}>
        Create new account
      </p>
    </div>
  );
}

function RegisterPreview() {
  return (
    <div className="px-4 py-4 space-y-2.5" style={{ backgroundColor: C.surface }}>
      <p style={{ color: C.text, fontWeight: 800, fontSize: 14 }}>Create Account</p>
      {["Full Name", "Email", "Password", "Confirm Password"].map((f) => (
        <FieldMini key={f} label={f} placeholder={`Enter ${f.toLowerCase()}`} />
      ))}
      <div>
        <p style={{ color: C.text, fontSize: 10, opacity: 0.6, marginBottom: 4 }}>Role</p>
        <div className="flex rounded-xl overflow-hidden border" style={{ borderColor: C.primary }}>
          {["Student", "Staff", "Volunteer"].map((r, i) => (
            <div key={r} className="flex-1 py-1.5 text-center" style={{
              backgroundColor: i === 0 ? C.primary : "transparent",
              fontSize: 9, color: i === 0 ? "#fff" : C.primary, fontWeight: 600,
              borderRight: i < 2 ? `1px solid ${C.primary}` : "none",
            }}>{r}</div>
          ))}
        </div>
      </div>
      <div className="w-full py-2.5 rounded-xl text-center" style={{ backgroundColor: C.primary }}>
        <span style={{ color: "#fff", fontWeight: 700, fontSize: 12 }}>Register</span>
      </div>
    </div>
  );
}

function HomePreview() {
  return (
    <div style={{ backgroundColor: C.background }}>
      {/* AppBar */}
      <div className="px-3 py-2" style={{ backgroundColor: C.primary }}>
        <div className="flex items-center justify-between mb-1.5">
          <p style={{ color: "#fff", fontWeight: 700, fontSize: 12 }}>Animal Reports 🐾</p>
          <div className="flex gap-1">
            {["🔔", "👤"].map(i => (
              <div key={i} className="w-6 h-6 rounded-full flex items-center justify-center" style={{ backgroundColor: "rgba(255,255,255,0.15)" }}>
                <span style={{ fontSize: 10 }}>{i}</span>
              </div>
            ))}
          </div>
        </div>
        <div className="flex items-center gap-1.5 rounded-lg px-2 py-1.5" style={{ backgroundColor: "rgba(255,255,255,0.15)" }}>
          <span style={{ fontSize: 10, color: "rgba(255,255,255,0.6)" }}>🔍</span>
          <span style={{ color: "rgba(255,255,255,0.5)", fontSize: 9 }}>Search…</span>
        </div>
        <div className="flex gap-1.5 mt-1.5">
          {["All", "Cats", "Dogs"].map((t, i) => (
            <span key={t} className="px-2 py-0.5 rounded-full" style={{
              backgroundColor: i === 0 ? "rgba(255,255,255,0.25)" : "transparent",
              color: "rgba(255,255,255,0.85)", fontSize: 8, fontWeight: 600,
              border: i !== 0 ? "1px solid rgba(255,255,255,0.25)" : "none",
            }}>{t}</span>
          ))}
        </div>
      </div>
      {/* Animal cards */}
      <div className="px-3 py-2 space-y-2">
        {[
          { emoji: "🐱", name: "Tabby Cat · Female", loc: "N28 Block", status: "Healthy", statusColor: C.success, statusBg: `${C.success}18` },
          { emoji: "🐶", name: "Brown Puppy", loc: "Kolej 13", status: "Needs Feeding", statusColor: "#8A5E20", statusBg: `${C.accent}20` },
        ].map((a) => (
          <div key={a.name} className="rounded-xl p-2.5 flex items-start gap-2" style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}>
            <div className="w-10 h-10 rounded-lg flex items-center justify-center text-lg flex-shrink-0" style={{ backgroundColor: `${C.primary}15` }}>{a.emoji}</div>
            <div className="flex-1">
              <p style={{ color: C.text, fontWeight: 700, fontSize: 10 }}>{a.name}</p>
              <p style={{ color: C.text, opacity: 0.5, fontSize: 8 }}>📍 {a.loc}</p>
              <span className="inline-block px-1.5 py-0.5 rounded-full mt-1" style={{ backgroundColor: a.statusBg, color: a.statusColor, fontSize: 8, fontWeight: 700 }}>{a.status}</span>
            </div>
          </div>
        ))}
      </div>
      {/* FAB */}
      <div className="flex justify-end px-3 pb-3">
        <div className="flex items-center gap-1.5 px-3 py-2 rounded-xl" style={{ backgroundColor: C.primary, boxShadow: `0 3px 10px ${C.primary}50` }}>
          <span style={{ fontSize: 12 }}>🐾</span>
          <span style={{ color: "#fff", fontWeight: 700, fontSize: 10 }}>Report Animal</span>
        </div>
      </div>
    </div>
  );
}

function ReportPreview() {
  return (
    <div className="px-4 py-4 space-y-2.5" style={{ backgroundColor: C.surface }}>
      <p style={{ color: C.text, fontWeight: 800, fontSize: 13 }}>Report Stray Animal</p>
      {/* Image upload */}
      <div className="rounded-xl flex flex-col items-center justify-center py-4 gap-1.5" style={{ backgroundColor: `${C.primary}10`, border: `2px dashed ${C.primary}40` }}>
        <span style={{ fontSize: 22 }}>📷</span>
        <p style={{ color: C.primary, fontSize: 9, fontWeight: 600 }}>Tap to upload photo</p>
      </div>
      {/* Segment */}
      <div className="flex rounded-xl overflow-hidden border" style={{ borderColor: C.primary }}>
        {["Cat", "Dog", "Unknown"].map((r, i) => (
          <div key={r} className="flex-1 py-1.5 text-center" style={{
            backgroundColor: i === 0 ? C.primary : "transparent",
            fontSize: 9, color: i === 0 ? "#fff" : C.primary, fontWeight: 600,
            borderRight: i < 2 ? `1px solid ${C.primary}` : "none",
          }}>{r}</div>
        ))}
      </div>
      <FieldMini label="Location" placeholder="e.g. N28 Engineering Block" icon="📍" />
      <div>
        <p style={{ color: C.text, fontSize: 9, opacity: 0.6, marginBottom: 3 }}>Description</p>
        <div className="rounded-lg px-2.5 py-2" style={{ backgroundColor: C.surface, border: `1px solid ${C.text}22` }}>
          <p style={{ color: C.text, opacity: 0.55, fontSize: 9 }}>Describe the animal's condition…</p>
          <div style={{ height: 20 }} />
        </div>
      </div>
      <div className="w-full py-2.5 rounded-xl text-center" style={{ backgroundColor: C.primary }}>
        <span style={{ color: "#fff", fontWeight: 700, fontSize: 11 }}>Submit Report</span>
      </div>
    </div>
  );
}

function ProfilePreview() {
  return (
    <div style={{ backgroundColor: C.background }}>
      {/* Hero image */}
      <div className="w-full h-24 flex items-center justify-center" style={{ backgroundColor: `${C.primary}20` }}>
        <span style={{ fontSize: 40 }}>🐱</span>
      </div>
      {/* Details */}
      <div className="px-4 py-3 space-y-2">
        <div className="flex items-start justify-between">
          <div>
            <p style={{ color: C.text, fontWeight: 800, fontSize: 13 }}>Tabby Cat</p>
            <p style={{ color: C.secondary, fontSize: 10 }}>Female · ~2 years</p>
          </div>
          <span className="px-2 py-0.5 rounded-full" style={{ backgroundColor: `${C.success}18`, color: C.success, fontSize: 9, fontWeight: 700, border: `1px solid ${C.success}35` }}>✓ Healthy</span>
        </div>
        <div className="flex items-center gap-1.5 rounded-lg px-2.5 py-1.5" style={{ backgroundColor: `${C.primary}10` }}>
          <span style={{ fontSize: 10 }}>📍</span>
          <p style={{ color: C.text, fontSize: 9 }}>N28 Engineering Block</p>
        </div>
        <div className="rounded-lg p-2.5" style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}>
          <p style={{ color: C.text, opacity: 0.5, fontSize: 8, fontWeight: 700 }}>DESCRIPTION</p>
          <p style={{ color: C.text, fontSize: 9, opacity: 0.7, marginTop: 2, lineHeight: 1.5 }}>Friendly orange tabby near N28 parking. No visible injuries…</p>
        </div>
        <div className="flex gap-2">
          <div className="flex-1 py-2 rounded-xl text-center" style={{ backgroundColor: C.primary }}>
            <span style={{ color: "#fff", fontWeight: 700, fontSize: 9 }}>✅ Mark Seen</span>
          </div>
          <div className="flex-1 py-2 rounded-xl text-center" style={{ border: `1.5px solid ${C.primary}` }}>
            <span style={{ color: C.primary, fontWeight: 700, fontSize: 9 }}>📞 Volunteer</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function SuccessPreview() {
  return (
    <div className="flex flex-col items-center justify-center py-12 px-6 gap-4" style={{ backgroundColor: C.surface }}>
      <div className="w-16 h-16 rounded-full flex items-center justify-center" style={{ backgroundColor: `${C.success}18`, border: `3px solid ${C.success}40` }}>
        <span style={{ fontSize: 32 }}>✅</span>
      </div>
      <div className="text-center">
        <p style={{ color: C.text, fontWeight: 800, fontSize: 14 }}>Report Submitted!</p>
        <p style={{ color: C.text, opacity: 0.55, fontSize: 10, marginTop: 4, lineHeight: 1.5 }}>
          Animal report submitted<br />successfully.
        </p>
      </div>
      <div className="w-full space-y-2">
        <div className="py-2.5 rounded-xl text-center" style={{ backgroundColor: C.primary }}>
          <span style={{ color: "#fff", fontWeight: 700, fontSize: 11 }}>View Animal List</span>
        </div>
        <div className="py-2.5 rounded-xl text-center" style={{ border: `1.5px solid ${C.primary}` }}>
          <span style={{ color: C.primary, fontWeight: 700, fontSize: 11 }}>Submit Another</span>
        </div>
      </div>
    </div>
  );
}

function EmptyPreview() {
  return (
    <div className="flex flex-col items-center justify-center py-12 px-6 gap-3" style={{ backgroundColor: C.background }}>
      <div className="w-16 h-16 rounded-full flex items-center justify-center" style={{ backgroundColor: `${C.text}08` }}>
        <span style={{ fontSize: 30, opacity: 0.4 }}>🐾</span>
      </div>
      <div className="text-center">
        <p style={{ color: C.text, fontWeight: 700, fontSize: 13, opacity: 0.7 }}>No animal reports yet</p>
        <p style={{ color: C.text, opacity: 0.4, fontSize: 10, marginTop: 4, lineHeight: 1.5 }}>
          Be the first to report a<br />stray animal in UTM
        </p>
      </div>
      <div className="px-6 py-2.5 rounded-xl" style={{ backgroundColor: C.primary }}>
        <span style={{ color: "#fff", fontWeight: 700, fontSize: 11 }}>🐾 Report Animal</span>
      </div>
    </div>
  );
}

function FieldMini({ label, placeholder, icon }: { label: string; placeholder: string; icon?: string }) {
  return (
    <div>
      <p style={{ color: C.text, fontSize: 9, opacity: 0.6, marginBottom: 2 }}>{label}</p>
      <div className="flex items-center gap-2 rounded-lg px-2.5 py-2" style={{ backgroundColor: C.surface, border: `1px solid ${C.text}20` }}>
        {icon && <span style={{ fontSize: 11, opacity: 0.45 }}>{icon}</span>}
        <span style={{ color: `${C.text}45`, fontSize: 9 }}>{placeholder}</span>
      </div>
    </div>
  );
}
