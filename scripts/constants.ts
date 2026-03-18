import type { ThemeColors, ThemeKey } from "./types";

/** Splash screen sizes for Android  */
export const ANDROID_SIZES = [
  { name: "mdpi", size: 320 },
  { name: "hdpi", size: 480 },
  { name: "xhdpi", size: 640 },
  { name: "xxhdpi", size: 960 },
  { name: "xxxhdpi", size: 1280 },
];

const IPHONE_X = { name: "Default-Portrait-812h@3x", size: 1125, scale: 3, height: 2436 };
const IPHONE_XR = { name: "Default-Portrait-896h@3x", size: 828, scale: 3, height: 1792 };
/** Also 13, 14 */
const IPHONE_12 = { name: "Default-Portrait-926h@3x", size: 1170, scale: 3, height: 2532 };
const IPHONE_14_PRO = { name: "Default-Portrait-932h@3x", size: 1179, scale: 3, height: 2556 };

/** Splash screen sizes for iOS */
export const IOS_SIZES: { name: string; size: number; scale: number; height?: number }[] = [
  IPHONE_X,
  IPHONE_XR,
  IPHONE_12,
  IPHONE_14_PRO,
  { name: "Default", size: 320, scale: 1 },
  { name: "Default@2x", size: 640, scale: 2 },
  { name: "Default-568h@2x", size: 640, scale: 2, height: 1136 },
  { name: "Default-667h@2x", size: 750, scale: 2, height: 1334 },
  { name: "Default-Portrait-736h@3x", size: 1242, scale: 3, height: 2208 },
  { name: "Default-Landscape-736h@3x", size: 2208, scale: 3, height: 1242 },
  { name: "Default-Landscape-812h@3x", size: 2436, scale: 3, height: 1125 },
  { name: "Default-Landscape-896h@3x", size: 1792, scale: 3, height: 828 },
  { name: "Default-Landscape-926h@3x", size: 2532, scale: 3, height: 1170 },
  { name: "Default-Landscape-932h@3x", size: 2556, scale: 3, height: 1179 },
];

export const THEMES: Record<ThemeKey, ThemeColors> = {
  oxocarbon: { name: "Oxocarbon", variant: "dark", background: "#161616", text: "#f2f4f8", primary: "#78a9ff" },
  "oxocarbon-light": {
    name: "Oxocarbon Light",
    variant: "light",
    background: "#ffffff",
    text: "#161616",
    primary: "#0f62fe",
  },
  catppuccin: { name: "Catppuccin", variant: "dark", background: "#1e1e2e", text: "#cdd6f4", primary: "#b4befe" },
  "catppuccin-light": {
    name: "Catppuccin Light",
    variant: "light",
    background: "#eff1f5",
    text: "#4c4f69",
    primary: "#7287fd",
  },
  nord: { name: "Nord", variant: "dark", background: "#2e3440", text: "#e5e9f0", primary: "#88c0d0" },
  "nord-light": { name: "Nord Light", variant: "light", background: "#eceff4", text: "#4c566a", primary: "#88c0d0" },
  rosePine: { name: "Rosé Pine", variant: "dark", background: "#191724", text: "#e0def4", primary: "#ebbcba" },
  "rosePine-light": {
    name: "Rosé Pine Light",
    variant: "light",
    background: "#faf4ed",
    text: "#575279",
    primary: "#d7827e",
  },
};

export function getThemeFromKey(k: ThemeKey | string): ThemeColors {
  switch (k) {
    case "oxocarbon":
      return THEMES.oxocarbon;
    case "oxocarbon-light":
      return THEMES["oxocarbon-light"];
    case "catppuccin":
      return THEMES.catppuccin;
    case "catppuccin-light":
      return THEMES["catppuccin-light"];
    case "nord":
      return THEMES.nord;
    case "nord-light":
      return THEMES["nord-light"];
    case "rosePine":
      return THEMES.rosePine;
    default:
      return THEMES["rosePine-light"];
  }
}
