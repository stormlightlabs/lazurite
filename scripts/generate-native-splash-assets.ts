#!/usr/bin/env bun

import { mkdir, readFile, writeFile } from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";
import sharp from "sharp";

type RenderSpec = { outputFileName: string; color: string; canvasSize: number; logoScale: number };

const THEME = { darkPrimary: "#7dafff", lightPrimary: "#0b63d1" };

const RENDERS: RenderSpec[] = [
  { outputFileName: "lazurite_splash_logo_light.png", color: THEME.lightPrimary, canvasSize: 1024, logoScale: 0.63 },
  { outputFileName: "lazurite_splash_logo_dark.png", color: THEME.darkPrimary, canvasSize: 1024, logoScale: 0.63 },
  { outputFileName: "lazurite_android12_logo_light.png", color: THEME.lightPrimary, canvasSize: 1152, logoScale: 0.58 },
  { outputFileName: "lazurite_android12_logo_dark.png", color: THEME.darkPrimary, canvasSize: 1152, logoScale: 0.58 },
];

function withResolvedLogoColor(svgContent: string, color: string): string {
  return svgContent.replace('fill="currentColor"', `fill="${color}"`);
}

async function renderLogoPng(svgContent: string, spec: RenderSpec): Promise<Buffer> {
  const logoSize = Math.round(spec.canvasSize * spec.logoScale);
  const logoBuffer = await sharp(Buffer.from(withResolvedLogoColor(svgContent, spec.color)))
    .resize(logoSize, logoSize, { fit: "contain" })
    .png()
    .toBuffer();

  const inset = Math.round((spec.canvasSize - logoSize) / 2);

  return sharp({
    create: {
      width: spec.canvasSize,
      height: spec.canvasSize,
      channels: 4,
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    },
  })
    .composite([{ input: logoBuffer, left: inset, top: inset }])
    .png()
    .toBuffer();
}

async function main(): Promise<void> {
  const scriptsDir = path.dirname(fileURLToPath(import.meta.url));
  const projectRoot = path.resolve(scriptsDir, "..");
  const logoPath = path.join(projectRoot, "assets", "logo.svg");
  const outputDir = path.join(projectRoot, "assets", "splash");

  await mkdir(outputDir, { recursive: true });

  const svgContent = await readFile(logoPath, "utf-8");

  for (const spec of RENDERS) {
    const outputPath = path.join(outputDir, spec.outputFileName);
    const imageBuffer = await renderLogoPng(svgContent, spec);
    await writeFile(outputPath, imageBuffer);
    console.log(`Generated ${path.relative(projectRoot, outputPath)}`);
  }

  console.log("Done. Run `dart run flutter_native_splash:create` from project root.");
}

main().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`Failed to generate native splash assets: ${message}`);
  process.exit(1);
});
