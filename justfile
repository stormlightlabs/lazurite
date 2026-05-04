export FLUTTER_SUPPRESS_ANALYTICS := "true"
export DART_SUPPRESS_ANALYTICS := "true"

# Format all Dart files
format:
    dart format lib test

alias fmt := format

# Run static analysis
lint:
    flutter analyze

# Install pinned ObjectBox runtime library for local development
objectbox-setup:
    bash scripts/objectbox_runtime.sh install

# Verify ObjectBox runtime library is present (fails fast if missing)
objectbox-check:
    bash scripts/objectbox_runtime.sh check

# Test with failures only to focus on failures and hanging tests
test-quiet *paths='':
    just objectbox-check
    flutter test {{ paths }} --reporter=failures-only --fail-fast --timeout=120s

# Run all tests
test *paths='':
    just objectbox-check
    flutter test {{ paths }} --fail-fast --timeout=120s

# Run end-to-end style integration tests from integration_test/
e2e:
    just objectbox-check
    flutter test integration_test --reporter=failures-only --fail-fast --timeout=180s

# Run one specific end-to-end test file
e2e-file path:
    just objectbox-check
    flutter test {{ path }} --reporter=failures-only --fail-fast --timeout=180s

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
