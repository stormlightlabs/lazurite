# Format all Dart files
format:
    dart format lib test

# Run static analysis
lint:
    flutter analyze

# Run all tests
test:
    flutter test

# Run code gen
gen:
    dart run build_runner build --delete-conflicting-outputs

# Run format, lint, and test
check: format lint test
