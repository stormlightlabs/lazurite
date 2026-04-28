#!/usr/bin/env bash
set -euo pipefail

readonly OBJECTBOX_DART_COMMIT="5c96e04"
readonly INSTALL_URL="https://raw.githubusercontent.com/objectbox/objectbox-dart/${OBJECTBOX_DART_COMMIT}/install.sh"
readonly SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<'EOF'
Usage:
  scripts/objectbox_runtime.sh check
  scripts/objectbox_runtime.sh install

Commands:
  check    Verify the ObjectBox native runtime library exists for this platform.
  install  Install ObjectBox native runtime from a pinned upstream revision,
           then run check.
EOF
}

platform_label() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    *) echo "unsupported" ;;
  esac
}

expected_libs() {
  case "$(platform_label)" in
    macos)
      printf '%s\n' "lib/libobjectbox.dylib"
      ;;
    linux)
      printf '%s\n' \
        "lib/libobjectbox.so" \
        "lib/libobjectbox-arm.so" \
        "lib/libobjectbox-arm64.so"
      ;;
    *)
      return 1
      ;;
  esac
}

check_runtime() {
  local platform
  platform="$(platform_label)"

  if [[ "${platform}" == "unsupported" ]]; then
    echo "Unsupported platform: $(uname -s). Supported local platforms: macOS and Linux."
    return 2
  fi

  local found=1
  while IFS= read -r lib_path; do
    if [[ -f "${lib_path}" ]]; then
      found=0
      break
    fi
  done < <(expected_libs)

  if [[ "${found}" -ne 0 ]]; then
    cat <<EOF
ObjectBox native runtime library is missing for ${platform}.

Expected one of:
$(expected_libs | sed 's/^/  - /')

Install it with:
  just objectbox-setup

Or run directly:
  ${SCRIPT_NAME} install
EOF
    return 1
  fi

  echo "ObjectBox runtime check passed for ${platform}."
}

install_runtime() {
  local platform
  platform="$(platform_label)"
  if [[ "${platform}" == "unsupported" ]]; then
    echo "Unsupported platform: $(uname -s). Supported local platforms: macOS and Linux."
    return 2
  fi

  echo "Installing ObjectBox runtime from pinned revision ${OBJECTBOX_DART_COMMIT}..."
  curl -sSfL "${INSTALL_URL}" | bash
  check_runtime
}

main() {
  if [[ $# -ne 1 ]]; then
    usage
    return 1
  fi

  case "$1" in
    check) check_runtime ;;
    install) install_runtime ;;
    -h|--help|help) usage ;;
    *)
      echo "Unknown command: $1"
      usage
      return 1
      ;;
  esac
}

main "$@"
