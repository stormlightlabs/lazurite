export type ThemeVariant = "light" | "dark";

export type ThemeColors = { name: string; variant: ThemeVariant; background: string; text: string; primary: string };

export type ThemeKey =
  | "lazurite"
  | "lazurite-light"
  | "oxocarbon"
  | "oxocarbon-light"
  | "catppuccin"
  | "catppuccin-light"
  | "nord"
  | "nord-light"
  | "rosePine"
  | "rosePine-light";
