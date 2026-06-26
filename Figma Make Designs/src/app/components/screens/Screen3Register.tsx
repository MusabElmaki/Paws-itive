import React, { useState } from "react";
import { C } from "../ds/DSTokens";

type Role = "Student" | "Staff" | "Volunteer";

function InputRow({
  label,
  placeholder,
  icon,
  value,
  isPassword = false,
  isConfirm = false,
}: {
  label: string;
  placeholder: string;
  icon: React.ReactNode;
  value?: string;
  isPassword?: boolean;
  isConfirm?: boolean;
}) {
  const [show, setShow] = useState(false);
  const isFilled = !!value;
  const mismatch = isConfirm && value === "wrongpass";

  return (
    <div>
      <p style={{ color: C.text, fontSize: 11, fontWeight: 600, marginBottom: 5, opacity: 0.6 }}>
        {label}
      </p>
      <div
        className="flex items-center rounded-xl px-3.5"
        style={{
          height: 48,
          backgroundColor: C.surface,
          border: `1.5px solid ${mismatch ? C.error : isFilled ? `${C.primary}50` : `${C.text}18`}`,
          gap: 10,
        }}
      >
        <span style={{ opacity: 0.4, flexShrink: 0 }}>{icon}</span>
        <div className="flex-1" style={{ color: value ? C.text : `${C.text}45`, fontSize: 13 }}>
          {value
            ? isPassword && !show
              ? "•".repeat(Math.min(value.length, 10))
              : value
            : placeholder}
        </div>
        {isPassword && (
          <button onClick={() => setShow(!show)}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill={`${C.text}50`}>
              <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z" />
            </svg>
          </button>
        )}
        {isFilled && !isPassword && !mismatch && (
          <svg width="16" height="16" viewBox="0 0 24 24" fill={C.success}>
            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
          </svg>
        )}
        {mismatch && (
          <svg width="16" height="16" viewBox="0 0 24 24" fill={C.error}>
            <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z" />
          </svg>
        )}
      </div>
      {mismatch && (
        <p style={{ color: C.error, fontSize: 10, marginTop: 3 }}>⚠ Passwords do not match</p>
      )}
    </div>
  );
}

export function Screen3Register() {
  const [role, setRole] = useState<Role>("Student");
  const roles: Role[] = ["Student", "Staff", "Volunteer"];

  return (
    <div
      className="relative w-full h-full flex flex-col overflow-hidden"
      style={{ backgroundColor: C.background, paddingTop: 54 }}
    >
      {/* ── AppBar ── */}
      <div
        className="flex items-center px-4 gap-3 flex-shrink-0"
        style={{
          height: 56,
          backgroundColor: C.primary,
        }}
      >
        {/* Leading back button */}
        <button
          className="flex items-center justify-center rounded-xl"
          style={{ width: 36, height: 36, backgroundColor: "rgba(255,255,255,0.15)" }}
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
            <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" />
          </svg>
        </button>
        <div className="flex-1">
          <p style={{ color: "#fff", fontWeight: 800, fontSize: 18 }}>Create Account</p>
        </div>
        {/* Paw icon */}
        <svg width="22" height="22" viewBox="0 0 64 64" fill="rgba(255,255,255,0.4)">
          <ellipse cx="32" cy="44" rx="17" ry="13" />
          <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
          <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
          <ellipse cx="21" cy="17" rx="7" ry="8" />
          <ellipse cx="43" cy="17" rx="7" ry="8" />
        </svg>
      </div>

      {/* ── Scrollable form ── */}
      <div className="flex-1 overflow-y-auto px-5" style={{ paddingTop: 20, paddingBottom: 24 }}>

        {/* Progress indicator */}
        <div className="flex items-center gap-2 mb-5">
          {["Personal Info", "Security", "Role"].map((step, i) => (
            <React.Fragment key={step}>
              <div className="flex items-center gap-1.5">
                <div
                  className="flex items-center justify-center rounded-full text-xs font-bold"
                  style={{
                    width: 22,
                    height: 22,
                    backgroundColor: i < 2 ? C.primary : `${C.primary}30`,
                    color: i < 2 ? "#fff" : C.primary,
                    fontSize: 10,
                    fontWeight: 700,
                  }}
                >
                  {i < 1 ? "✓" : i + 1}
                </div>
                <p style={{ color: i < 2 ? C.primary : `${C.text}50`, fontSize: 9, fontWeight: 600 }}>{step}</p>
              </div>
              {i < 2 && (
                <div
                  className="flex-1"
                  style={{ height: 2, backgroundColor: i === 0 ? C.primary : `${C.text}15`, borderRadius: 99 }}
                />
              )}
            </React.Fragment>
          ))}
        </div>

        {/* ── Section 1: Personal Information ── */}
        <div
          className="rounded-2xl p-4 mb-4"
          style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}
        >
          <div className="flex items-center gap-2 mb-4">
            <div
              className="w-7 h-7 rounded-lg flex items-center justify-center"
              style={{ backgroundColor: `${C.primary}18` }}
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary}>
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
              </svg>
            </div>
            <p style={{ color: C.text, fontSize: 13, fontWeight: 700 }}>Personal Information</p>
          </div>

          <div className="space-y-3">
            <InputRow
              label="Full Name"
              placeholder="e.g. Ahmad Faris bin Abdullah"
              value="Ahmad Faris bin Abdullah"
              icon={
                <svg width="18" height="18" viewBox="0 0 24 24" fill={C.text}>
                  <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                </svg>
              }
            />
            <InputRow
              label="Email Address"
              placeholder="student@graduate.utm.my"
              value="ahmad.faris@graduate.utm.my"
              icon={
                <svg width="18" height="18" viewBox="0 0 24 24" fill={C.text}>
                  <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z" />
                </svg>
              }
            />
          </div>
        </div>

        {/* ── Section 2: Security ── */}
        <div
          className="rounded-2xl p-4 mb-4"
          style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}
        >
          <div className="flex items-center gap-2 mb-4">
            <div
              className="w-7 h-7 rounded-lg flex items-center justify-center"
              style={{ backgroundColor: `${C.primary}18` }}
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary}>
                <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z" />
              </svg>
            </div>
            <p style={{ color: C.text, fontSize: 13, fontWeight: 700 }}>Security</p>
          </div>

          <div className="space-y-3">
            <InputRow
              label="Password"
              placeholder="Minimum 8 characters"
              value="mypassword123"
              isPassword
              icon={
                <svg width="18" height="18" viewBox="0 0 24 24" fill={C.text}>
                  <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2z" />
                </svg>
              }
            />
            {/* Password strength indicator */}
            <div className="px-1">
              <div className="flex gap-1 mb-1">
                {[1, 2, 3, 4].map((i) => (
                  <div
                    key={i}
                    className="flex-1 rounded-full"
                    style={{
                      height: 3,
                      backgroundColor: i <= 3 ? C.accent : `${C.text}15`,
                    }}
                  />
                ))}
              </div>
              <p style={{ color: C.text, opacity: 0.4, fontSize: 9 }}>Password strength: Good</p>
            </div>

            <InputRow
              label="Confirm Password"
              placeholder="Re-enter your password"
              value="mypassword123"
              isPassword
              icon={
                <svg width="18" height="18" viewBox="0 0 24 24" fill={C.text}>
                  <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2z" />
                </svg>
              }
            />
          </div>
        </div>

        {/* ── Section 3: Role ── */}
        <div
          className="rounded-2xl p-4 mb-5"
          style={{ backgroundColor: C.surface, border: `1px solid ${C.border}` }}
        >
          <div className="flex items-center gap-2 mb-4">
            <div
              className="w-7 h-7 rounded-lg flex items-center justify-center"
              style={{ backgroundColor: `${C.primary}18` }}
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary}>
                <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z" />
              </svg>
            </div>
            <p style={{ color: C.text, fontSize: 13, fontWeight: 700 }}>Account Role</p>
          </div>

          {/* SegmentedButton — role selector */}
          <div className="flex rounded-xl overflow-hidden border" style={{ borderColor: C.primary }}>
            {roles.map((r, i) => (
              <button
                key={r}
                onClick={() => setRole(r)}
                className="flex-1 py-3 flex flex-col items-center gap-1 transition-all"
                style={{
                  backgroundColor: role === r ? C.primary : "transparent",
                  borderRight: i < roles.length - 1 ? `1px solid ${C.primary}60` : "none",
                }}
              >
                <span style={{ fontSize: 14 }}>
                  {r === "Student" ? "🎓" : r === "Staff" ? "👔" : "🙌"}
                </span>
                <span
                  style={{
                    color: role === r ? "#fff" : C.primary,
                    fontWeight: 700,
                    fontSize: 12,
                  }}
                >
                  {r}
                </span>
              </button>
            ))}
          </div>

          {/* Role description */}
          <div
            className="mt-3 flex items-start gap-2 rounded-xl p-3"
            style={{ backgroundColor: `${C.primary}08` }}
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill={C.primary} style={{ flexShrink: 0, marginTop: 1 }}>
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z" />
            </svg>
            <p style={{ color: C.text, fontSize: 11, opacity: 0.65, lineHeight: 1.5 }}>
              {role === "Student"
                ? "Report and track animals as a UTM student. Join the campus wildlife care community."
                : role === "Staff"
                ? "Staff members can verify reports and coordinate with animal welfare teams."
                : "Volunteers can respond to reports and provide direct animal assistance."}
            </p>
          </div>
        </div>

        {/* Register ElevatedButton */}
        <button
          className="w-full flex items-center justify-center gap-2.5 rounded-2xl mb-4"
          style={{
            height: 54,
            background: `linear-gradient(135deg, #74503A, ${C.primary})`,
            boxShadow: `0 6px 20px ${C.primary}45`,
          }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
          </svg>
          <span style={{ color: "#fff", fontWeight: 800, fontSize: 16, letterSpacing: 0.4 }}>
            Create Account
          </span>
        </button>

        {/* Already have account TextButton */}
        <div className="flex items-center justify-center gap-1.5">
          <p style={{ color: `${C.text}60`, fontSize: 13 }}>Already have an account?</p>
          <button>
            <p style={{ color: C.primary, fontSize: 13, fontWeight: 700, textDecoration: "underline" }}>
              Login
            </p>
          </button>
        </div>

        <p style={{ color: `${C.text}30`, fontSize: 10, textAlign: "center", marginTop: 12 }}>
          UTM Paws-itive · UC01 Register Account
        </p>
      </div>
    </div>
  );
}
