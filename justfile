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
    dart run build_runner build --delete-conflicting-outputs

# Run code gen
gen: generate format

# Run format, lint, and test
check: format lint test

find-comments:
    rg -n --pcre2 '^\s*//(?![!/])' -g '*.dart' -g '!*.g.dart' -g '!*.freezed.dart'

alias cmt := find-comments
