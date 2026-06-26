import React, { useState } from "react";
import { C, FlutterBadge } from "./DSTokens";
import { SectionLabel } from "./ColorTokens";

interface FieldProps {
  label: string;
  placeholder: string;
  icon?: string;
  state: "normal" | "focused" | "error" | "filled";
  errorText?: string;
  value?: string;
  password?: boolean;
}

function TextField({ label, placeholder, icon, state, errorText, value, password }: FieldProps) {
  const isFocused = state === "focused";
  const isError   = state === "error";
  const isFilled  = state === "filled";

  const borderColor = isError   ? C.error
                    : isFocused ? C.primary
                    : `${C.text}22`;

  const bgColor = isFocused ? `${C.primary}08` : C.surface;
  const shadow  = isFocused ? `0 0 0 3px ${C.primary}18`
                : isError   ? `0 0 0 3px ${C.error}15`
                : "none";

  return (
    <div className="space-y-1">
      <label style={{ color: isFocused ? C.primary : isError ? C.error : C.text, fontSize: 12, fontWeight: 600, opacity: isError || isFocused ? 1 : 0.65 }}>
        {label}
      </label>
      <div
        className="flex items-center gap-3 rounded-xl px-4 py-3"
        style={{
          backgroundColor: bgColor,
          border: `1.5px solid ${borderColor}`,
          boxShadow: shadow,
          transition: "all 0.2s",
        }}
      >
        {icon && (
          <span style={{ fontSize: 16, opacity: isFocused ? 1 : 0.45 }}>{icon}</span>
        )}
        <input
          type={password ? "password" : "text"}
          placeholder={placeholder}
          defaultValue={value}
          readOnly
          className="flex-1 bg-transparent outline-none text-sm"
          style={{ color: isFilled ? C.text : `${C.text}45`, fontFamily: "inherit", cursor: "default" }}
        />
        {password && (
          <span style={{ fontSize: 14, opacity: 0.4 }}>👁</span>
        )}
        {isFilled && !password && (
          <span style={{ fontSize: 12, color: C.success }}>✓</span>
        )}
      </div>
      {isError && errorText && (
        <p style={{ color: C.error, fontSize: 11, marginTop: 2 }}>⚠ {errorText}</p>
      )}
      {isFocused && (
        <p style={{ color: C.primary, fontSize: 10, opacity: 0.7 }}>
          Focused state — border: kPrimary · shadow: kPrimary18
        </p>
      )}
    </div>
  );
}

function DropdownField({ label, value, icon }: { label: string; value: string; icon?: string }) {
  return (
    <div className="space-y-1">
      <label style={{ color: C.text, fontSize: 12, fontWeight: 600, opacity: 0.65 }}>{label}</label>
      <div
        className="flex items-center gap-3 rounded-xl px-4 py-3"
        style={{
          backgroundColor: C.surface,
          border: `1.5px solid ${C.text}22`,
        }}
      >
        {icon && <span style={{ fontSize: 16, opacity: 0.45 }}>{icon}</span>}
        <span className="flex-1 text-sm" style={{ color: C.text }}>{value}</span>
        <span style={{ color: C.text, opacity: 0.4, fontSize: 12 }}>▼</span>
      </div>
    </div>
  );
}

export function InputFields() {
  return (
    <section>
      <SectionLabel icon="✏️" title="Input Field Styles" sub="TextField · DropdownButtonFormField · SegmentedButton" />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">

        {/* TextField States */}
        <div
          className="rounded-2xl p-5 border space-y-4"
          style={{ backgroundColor: C.background, borderColor: C.border }}
        >
          <div className="flex items-center justify-between mb-2">
            <FlutterBadge label="TextField" />
            <span style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>3 states</span>
          </div>

          <TextField
            label="Email Address"
            placeholder="e.g. student@graduate.utm.my"
            icon="✉️"
            state="normal"
          />
          <TextField
            label="Email Address"
            placeholder="e.g. student@graduate.utm.my"
            icon="✉️"
            state="focused"
            value="ahmad.faris@graduate.utm.my"
          />
          <TextField
            label="Password"
            placeholder="Enter your password"
            icon="🔒"
            state="error"
            password
            errorText="Incorrect password. Please try again."
          />
          <TextField
            label="Full Name"
            placeholder="Your full name"
            icon="👤"
            state="filled"
            value="Ahmad Faris bin Abdullah"
          />
        </div>

        {/* Description & Dropdown Fields */}
        <div
          className="rounded-2xl p-5 border space-y-4"
          style={{ backgroundColor: C.background, borderColor: C.border }}
        >
          <div className="flex items-center justify-between mb-2">
            <FlutterBadge label="DropdownButtonFormField" />
            <span style={{ color: C.text, opacity: 0.4, fontSize: 10 }}>Select inputs</span>
          </div>

          <DropdownField label="Animal Type" value="Cat" icon="🐱" />
          <DropdownField label="Health Status" value="Needs Feeding" icon="🍽️" />
          <DropdownField label="Role" value="Student" icon="🎓" />

          {/* Multi-line text field */}
          <div className="space-y-1">
            <label style={{ color: C.text, fontSize: 12, fontWeight: 600, opacity: 0.65 }}>
              Description
            </label>
            <div
              className="rounded-xl px-4 py-3"
              style={{
                backgroundColor: C.surface,
                border: `1.5px solid ${C.text}22`,
              }}
            >
              <textarea
                readOnly
                rows={3}
                className="w-full bg-transparent outline-none text-sm resize-none"
                style={{ color: C.text, fontFamily: "inherit" }}
                defaultValue="Orange tabby cat spotted near N28. Appears hungry but friendly. No visible injuries."
              />
            </div>
            <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>maxLines: 4 · minLines: 3</p>
          </div>

          {/* Segmented Button */}
          <div className="space-y-1">
            <label style={{ color: C.text, fontSize: 12, fontWeight: 600, opacity: 0.65 }}>
              Animal Type (SegmentedButton)
            </label>
            <div className="flex rounded-xl overflow-hidden border" style={{ borderColor: C.primary }}>
              {["Cat", "Dog", "Unknown"].map((opt, i) => (
                <button
                  key={opt}
                  className="flex-1 py-2.5 text-sm transition-all"
                  style={{
                    backgroundColor: i === 0 ? C.primary : "transparent",
                    color: i === 0 ? "#fff" : C.primary,
                    fontWeight: 600,
                    borderRight: i < 2 ? `1px solid ${C.primary}` : "none",
                    fontSize: 13,
                  }}
                >
                  {opt}
                </button>
              ))}
            </div>
            <p style={{ color: C.text, opacity: 0.35, fontSize: 10 }}>
              SegmentedButton — Flutter 3.x+ Material 3
            </p>
          </div>
        </div>

      </div>
    </section>
  );
}
