import React, { useState } from "react";
import { C } from "../ds/DSTokens";

function TextFieldWidget({
  label,
  placeholder,
  icon,
  isPassword = false,
  hasError = false,
  value = "",
}: {
  label: string;
  placeholder: string;
  icon: React.ReactNode;
  isPassword?: boolean;
  hasError?: boolean;
  value?: string;
}) {
  const [showPass, setShowPass] = useState(false);
  const borderColor = hasError ? C.error : `${C.text}20`;
  const focusShadow  = hasError ? `0 0 0 3px ${C.error}18` : "none";

  return (
    <div className="w-full">
      <p style={{ color: hasError ? C.error : C.text, fontSize: 12, fontWeight: 600, marginBottom: 6, opacity: hasError ? 1 : 0.65 }}>
        {label}
      </p>
      <div
        className="flex items-center rounded-2xl px-4"
        style={{
          height: 52,
          backgroundColor: C.surface,
          border: `1.5px solid ${borderColor}`,
          boxShadow: focusShadow,
          gap: 10,
        }}
      >
        <span style={{ flexShrink: 0, opacity: 0.45 }}>{icon}</span>
        <div className="flex-1" style={{ color: value ? C.text : `${C.text}45`, fontSize: 14 }}>
          {value
            ? isPassword && !showPass
              ? "•".repeat(value.length)
              : value
            : placeholder}
        </div>
        {isPassword && (
          <button onClick={() => setShowPass(!showPass)} style={{ padding: "4px" }}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill={`${C.text}60`}>
              {showPass ? (
                <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z" />
              ) : (
                <path d="M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z" />
              )}
            </svg>
          </button>
        )}
        {!isPassword && value && !hasError && (
          <svg width="18" height="18" viewBox="0 0 24 24" fill={C.success}>
            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
          </svg>
        )}
      </div>
    </div>
  );
}

export function Screen2Login() {
  return (
    <div
      className="relative w-full h-full flex flex-col overflow-hidden"
      style={{ backgroundColor: C.background, paddingTop: 54 }}
    >
      {/* Top decorative wave with paw branding */}
      <div
        className="relative w-full flex flex-col items-center pb-8"
        style={{
          background: `linear-gradient(175deg, #6B4632, ${C.primary})`,
          borderBottomLeftRadius: 40,
          borderBottomRightRadius: 40,
          paddingTop: 12,
          paddingBottom: 36,
        }}
      >
        {/* Paw icon — Icon(Icons.pets) */}
        <div
          className="flex items-center justify-center rounded-2xl mb-3"
          style={{
            width: 68,
            height: 68,
            backgroundColor: "rgba(255,255,255,0.18)",
            border: "2px solid rgba(255,255,255,0.28)",
          }}
        >
          <svg width="36" height="36" viewBox="0 0 64 64" fill="white">
            <ellipse cx="32" cy="44" rx="17" ry="13" />
            <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
            <ellipse cx="21" cy="17" rx="7" ry="8" />
            <ellipse cx="43" cy="17" rx="7" ry="8" />
          </svg>
        </div>
        <h1 style={{ color: "#fff", fontSize: 24, fontWeight: 800 }}>Welcome Back</h1>
        <p style={{ color: "rgba(255,255,255,0.65)", fontSize: 13, marginTop: 4 }}>
          Sign in to UTM Paws-itive
        </p>
      </div>

      {/* ── Scrollable form body ── */}
      <div className="flex-1 px-6 overflow-y-auto" style={{ paddingTop: 28, paddingBottom: 24 }}>

        {/* Error Banner — simulates wrong credentials state */}
        <div
          className="flex items-start gap-3 rounded-2xl p-3.5 mb-5"
          style={{
            backgroundColor: `${C.error}12`,
            border: `1.5px solid ${C.error}35`,
          }}
        >
          <div
            className="flex-shrink-0 rounded-full flex items-center justify-center"
            style={{ width: 28, height: 28, backgroundColor: `${C.error}20`, marginTop: 1 }}
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill={C.error}>
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" />
            </svg>
          </div>
          <div>
            <p style={{ color: C.error, fontSize: 13, fontWeight: 700, marginBottom: 2 }}>
              Incorrect credentials
            </p>
            <p style={{ color: C.error, fontSize: 11, opacity: 0.8, lineHeight: 1.5 }}>
              The email or password you entered is incorrect. Please try again.
            </p>
          </div>
        </div>

        {/* Email field */}
        <div className="mb-4">
          <TextFieldWidget
            label="Email Address"
            placeholder="student@graduate.utm.my"
            icon={
              <svg width="20" height="20" viewBox="0 0 24 24" fill={C.text}>
                <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z" />
              </svg>
            }
            value="ahmad.faris@graduate.utm.my"
            hasError={true}
          />
        </div>

        {/* Password field */}
        <div className="mb-2">
          <TextFieldWidget
            label="Password"
            placeholder="Enter your password"
            icon={
              <svg width="20" height="20" viewBox="0 0 24 24" fill={C.text}>
                <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z" />
              </svg>
            }
            isPassword
            value="wrongpass123"
            hasError={true}
          />
        </div>

        {/* Forgot password */}
        <div className="flex justify-end mb-6">
          <button>
            <p style={{ color: C.primary, fontSize: 12, fontWeight: 600 }}>Forgot password?</p>
          </button>
        </div>

        {/* Login ElevatedButton */}
        <button
          className="w-full flex items-center justify-center gap-2 rounded-2xl"
          style={{
            height: 54,
            background: `linear-gradient(135deg, #74503A, ${C.primary})`,
            boxShadow: `0 6px 20px ${C.primary}50`,
            marginBottom: 16,
          }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
            <path d="M11 7L9.6 8.4l2.6 2.6H2v2h10.2l-2.6 2.6L11 17l5-5-5-5zm9 12h-8v2h8c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2h-8v2h8v14z" />
          </svg>
          <span style={{ color: "#fff", fontWeight: 800, fontSize: 16, letterSpacing: 0.5 }}>
            Login
          </span>
        </button>

        {/* Divider */}
        <div className="flex items-center gap-3 mb-5">
          <div className="flex-1" style={{ height: 1, backgroundColor: `${C.text}15` }} />
          <p style={{ color: `${C.text}45`, fontSize: 11 }}>or</p>
          <div className="flex-1" style={{ height: 1, backgroundColor: `${C.text}15` }} />
        </div>

        {/* Create account TextButton */}
        <button
          className="w-full flex items-center justify-center gap-2 rounded-2xl"
          style={{
            height: 52,
            backgroundColor: "transparent",
            border: `1.5px solid ${C.primary}50`,
          }}
        >
          <span style={{ color: C.primary, fontWeight: 700, fontSize: 14 }}>
            Create New Account
          </span>
        </button>

        {/* Friendly cat paw visual element */}
        <div className="flex items-center justify-center gap-3 mt-6">
          {[0, 1, 2, 3].map((i) => (
            <svg
              key={i}
              width={14 + i * 2}
              height={14 + i * 2}
              viewBox="0 0 64 64"
              fill={C.primary}
              style={{ opacity: 0.15 + i * 0.05 }}
            >
              <ellipse cx="32" cy="44" rx="17" ry="13" />
              <ellipse cx="13" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="51" cy="28" rx="7.5" ry="8.5" />
              <ellipse cx="21" cy="17" rx="7" ry="8" />
              <ellipse cx="43" cy="17" rx="7" ry="8" />
            </svg>
          ))}
        </div>
        <p style={{ color: `${C.text}30`, fontSize: 10, textAlign: "center", marginTop: 4 }}>
          UTM Paws-itive · UC02 Login
        </p>
      </div>
    </div>
  );
}
