export FLUTTER_SUPPRESS_ANALYTICS := "true"
export DART_SUPPRESS_ANALYTICS := "true"

# Format all Dart files
format:
    dart format lib test

alias fmt := format

# Run static analysis
lint:
    flutter analyze

# Test with failures only to focus on failures and hanging tests
test-quiet *paths='':
    flutter test {{ paths }} --reporter=failures-only --fail-fast --timeout=120s

# Run all tests
test *paths='':
    flutter test {{ paths }} --fail-fast --timeout=120s

generate:
    flutter pub run build_runner build --delete-conflicting-outputs

# Generate splash PNG source assets from SVG using Bun
generate-splash-assets:
    cd scripts && bun run generate-native-splash-assets

# Apply flutter_native_splash config to platform projects
generate-native-splash:
    dart run flutter_native_splash:create --path=flutter_native_splash.yaml

# End-to-end native splash generation
splash: generate-splash-assets generate-native-splash

# Run code gen
gen: generate format

# Run format, lint, and test
check: format lint test

find-comments:
    rg -n --pcre2 '^\s*//(?![!/])' -g '*.dart' -g '!*.g.dart' -g '!*.freezed.dart'

alias cmt := find-comments
