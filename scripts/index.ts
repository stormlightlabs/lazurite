#!/usr/bin/env bun

import { createCanvas, loadImage } from "canvas";
import chalk from "chalk";
import { mkdir } from "fs/promises";
import { parseArgs } from "util";
import inquirer from "inquirer";
import sharp from "sharp";
import { readFile } from "fs/promises";
import path from "path";
import type { ThemeColors } from "./types";
import { ANDROID_SIZES, IOS_SIZES, THEMES, getThemeFromKey } from "./constants";

async function generateSplashScreen(
  theme: ThemeColors,
  width: number,
  height: number,
  logoSvgPath: string,
  outputPath: string,
): Promise<void> {
  const canvas = createCanvas(width, height);
  const ctx = canvas.getContext("2d");

  ctx.fillStyle = theme.background;
  ctx.fillRect(0, 0, width, height);

  const minDim = Math.min(width, height);
  const logoSize = minDim * 0.22;
  const gap = minDim * 0.04; // Gap between logo and text (like 16px in about screen)
  const fontSize = minDim * 0.07;

  // Calculate total height of logo + gap + text to center the group
  const totalGroupHeight = logoSize + gap + fontSize;
  const groupCenterY = height / 2;
  const logoY = groupCenterY - totalGroupHeight / 2;
  const textY = logoY + logoSize + gap + fontSize / 2;

  try {
    let svgContent = await readFile(logoSvgPath, "utf-8");
    svgContent = svgContent.replace('fill="currentColor"', `fill="${theme.primary}"`);

    const svgBuffer = Buffer.from(svgContent);
    const logoPngBuffer = await sharp(svgBuffer).resize(Math.round(logoSize), Math.round(logoSize)).png().toBuffer();
    const logo = await loadImage(logoPngBuffer);
    const logoX = (width - logoSize) / 2;

    ctx.drawImage(logo, logoX, logoY, logoSize, logoSize);
  } catch (error) {
    console.warn(chalk.yellow("⚠ Warning: Could not load logo, drawing placeholder"));
    ctx.beginPath();
    ctx.arc(width / 2, logoY + logoSize / 2, logoSize / 2, 0, Math.PI * 2);
    ctx.fillStyle = theme.primary;
    ctx.fill();
  }

  ctx.font = `${fontSize}px serif`;
  ctx.fillStyle = theme.text;
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  ctx.fillText("Lazurite", width / 2, textY);

  const buffer = canvas.toBuffer("image/png");
  await Bun.write(outputPath, buffer);
}

async function main() {
  console.log(chalk.cyan.bold("🎨 Lazurite Splash Screen Generator\n"));

  const { values, positionals } = parseArgs({
    args: Bun.argv.slice(2),
    options: {
      theme: {
        type: "string",
        short: "t",
        help: "Theme name (oxocarbon, catppuccin, nord, rosePine) or with -light suffix",
      },
      variant: { type: "string", short: "v", help: "Theme variant (light or dark)" },
      output: { type: "string", short: "o", default: "./dist", help: "Output directory for generated images" },
      all: { type: "boolean", short: "a", default: false, help: "Generate for all themes" },
      help: { type: "boolean", short: "h", default: false, help: "Show help" },
    },
    strict: true,
    allowPositionals: true,
  });

  if (values.help) {
    console.log(chalk.bold("Usage:"));
    console.log("  bun run index.ts [options]\n");
    console.log(chalk.bold("Options:"));
    console.log("  -t, --theme <name>     Theme name (oxocarbon, catppuccin, nord, rosePine)");
    console.log("  -v, --variant <type>   Theme variant (light or dark)");
    console.log("  -o, --output <dir>     Output directory (default: ./dist)");
    console.log("  -a, --all              Generate for all themes");
    console.log("  -h, --help             Show this help message\n");
    console.log(chalk.bold("Examples:"));
    console.log("  bun run index.ts -t oxocarbon -v dark");
    console.log("  bun run index.ts --all");
    console.log("  bun run index.ts -t nord -o ./splash\n");
    process.exit(0);
  }

  let themesToGenerate: ThemeColors[] = [];

  if (values.all) {
    themesToGenerate = Object.values(THEMES);
  } else if (values.theme) {
    const themeKey = values.variant === "light" ? `${values.theme}-light` : values.theme;
    const theme = getThemeFromKey(themeKey);
    themesToGenerate = [theme];
  } else {
    const answers = await inquirer.prompt([
      {
        type: "list",
        name: "palette",
        message: "Select theme palette:",
        choices: [
          { name: "Oxocarbon", value: "oxocarbon" },
          { name: "Catppuccin", value: "catppuccin" },
          { name: "Nord", value: "nord" },
          { name: "Rosé Pine", value: "rosePine" },
        ],
      },
      {
        type: "list",
        name: "variant",
        message: "Select theme variant:",
        choices: [
          { name: "Dark", value: "dark" },
          { name: "Light", value: "light" },
        ],
      },
      { type: "confirm", name: "generateAll", message: "Generate for all themes instead?", default: false },
    ]);

    if (answers.generateAll) {
      themesToGenerate = Object.values(THEMES);
    } else {
      const themeKey = answers.variant === "light" ? `${answers.palette}-light` : answers.palette;
      themesToGenerate = [getThemeFromKey(themeKey)];
    }
  }

  const outputDir = values.output || "./dist";
  const logoPath = path.resolve("../assets/logo.svg");

  console.log(chalk.blue(`\n📁 Output directory: ${outputDir}`));
  console.log(chalk.blue(`🎨 Themes to generate: ${themesToGenerate.length}`));
  console.log();

  for (const theme of themesToGenerate) {
    console.log(chalk.magenta(`\n🖼  Generating for ${theme.name} (${theme.variant})...`));

    const themeDir = path.join(outputDir, theme.name.toLowerCase().replace(" ", "-"));
    const androidDir = path.join(themeDir, "android");
    const iosDir = path.join(themeDir, "ios");

    await mkdir(androidDir, { recursive: true });
    await mkdir(iosDir, { recursive: true });

    for (const size of ANDROID_SIZES) {
      const fileName = `splash_${size.name}.png`;
      const outputPath = path.join(androidDir, fileName);

      await generateSplashScreen(theme, size.size, Math.round(size.size * 1.5), logoPath, outputPath);

      console.log(chalk.green(`  ✓ ${fileName}`));
    }

    for (const size of IOS_SIZES) {
      const width = size.size;
      const height = size.height || Math.round(width * 1.5);
      const fileName = `${size.name}.png`;
      const outputPath = path.join(iosDir, fileName);

      await generateSplashScreen(theme, width, height, logoPath, outputPath);

      console.log(chalk.green(`  ✓ ${fileName}`));
    }
  }

  console.log(chalk.cyan.bold("\n✅ Splash screen generation complete!\n"));
}

main().catch((error) => {
  console.error(chalk.red("✗ Error:"), error.message);
  process.exit(1);
});
