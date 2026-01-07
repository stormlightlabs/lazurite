# Format all Dart files
format:
    dart format lib test

# Run static analysis
lint:
    flutter analyze

# Test with failures only to focus on failures and hanging tests
test-quiet:
    flutter test --reporter=failures-only --timeout=90s

# Run all tests
test:
    flutter test --timeout=90s

# Run code gen
gen:
    dart run build_runner build --delete-conflicting-outputs

# Run format, lint, and test
check: format lint test
