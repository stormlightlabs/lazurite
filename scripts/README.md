# Lazurite Splash Screen Generator

CLI tool to generate PNG splash screen images (for Android and iOS) for Lazurite, styled with different color themes.

## Usage

Run without arguments to use the interactive theme selector:

```bash
bun run index.ts
```

### Args

```bash
bun run index.ts [options]
```

#### Options

| Option      | Short | Description                                               | Default     |
| ----------- | ----- | --------------------------------------------------------- | ----------- |
| `--theme`   | `-t`  | Theme name: `oxocarbon`, `catppuccin`, `nord`, `rosePine` | Interactive |
| `--variant` | `-v`  | Theme variant: `light` or `dark`                          | Interactive |
| `--output`  | `-o`  | Output directory for generated images                     | `./output`  |
| `--all`     | `-a`  | Generate splash screens for all themes                    | `false`     |
| `--help`    | `-h`  | Show help message                                         | -           |

### Examples

Generate splash screens for a specific theme:

```bash
bun run index.ts -t oxocarbon -v dark
```

Generate all themes at once:

```bash
bun run index.ts --all
```

Specify custom output directory:

```bash
bun run index.ts -t nord -v light -o ./assets/splash
```

## Output Structure

```sh
./dist/
├── oxocarbon/
│   ├── android/
│   │   ├── splash_mdpi.png
│   │   ├── splash_hdpi.png
│   │   ├── splash_xhdpi.png
│   │   ├── splash_xxhdpi.png
│   │   └── splash_xxxhdpi.png
│   └── ios/
│       ├── Default.png
│       ├── Default@2x.png
│       ├── Default-568h@2x.png
│       └── ... (more sizes)
├── catppuccin/
│   └── ...
└── ...
```

## Available Themes

| Theme      | Dark Background | Light Background | Primary Color |
| ---------- | --------------- | ---------------- | ------------- |
| Oxocarbon  | `#161616`       | `#ffffff`        | `#78a9ff`     |
| Catppuccin | `#1e1e2e`       | `#eff1f5`        | `#b4befe`     |
| Nord       | `#2e3440`       | `#eceff4`        | `#88c0d0`     |
| Rosé Pine  | `#191724`       | `#faf4ed`        | `#ebbcba`     |

## Technical Details

- **Logo**: Uses the Lazurite SVG logo from `../assets/logo.svg`
- **Font**: Falls back to system serif font (Crimson Pro recommended)
- **Canvas**: Uses `node-canvas` for rendering
- **SVG Processing**: Uses `sharp` for SVG to PNG conversion

## Requirements

[Bun](https://bun.sh/) runtime

## License

See [LICENSE](../LICENSE).
