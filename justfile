# Format all Dart files
format:
    dart format lib test

# Run static analysis
lint:
    flutter analyze

# Test with failures only to focus on failures and hanging tests
test-quiet *paths='':
    flutter test {{ paths }} --reporter=failures-only --timeout=120s

# Run all tests
test *paths='':
    flutter test {{ paths }} --timeout=120s

# Run code gen
gen:
    dart run build_runner build --delete-conflicting-outputs

# Run format, lint, and test
check: format lint test
