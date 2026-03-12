#!/usr/bin/env sh
#
# Unified test execution script (Angular / Spring Boot).
# Usage: ./run-tests.sh <angular|springboot>
# Exit: 0 = success, non-zero = failure
#

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
RESULTS_DIR="${PROJECT_ROOT}/test-results"

usage() {
  echo "Usage: $0 [angular]"
  echo "  angular  -  Run Angular (Karma/Jasmine) tests (default)"
  echo "Output: JUnit XML in test-results/"
  exit 1
}

clean_test_artifacts() {
  echo "[run-tests] Cleaning previous test artifacts..."
  rm -rf "${RESULTS_DIR:?}"
  mkdir -p "${RESULTS_DIR}"
}

# --- Angular: Karma + JUnit XML (outputDir in karma.conf.js) ---
run_angular_tests() {
  cd "${PROJECT_ROOT}" || exit 1
  if ! command -v npm >/dev/null 2>&1; then
    echo "[run-tests] Error: npm not found. Install Node.js (v20+)."
    return 1
  fi
  echo "[run-tests] Installing dependencies..."
  npm ci --ignore-scripts
  echo "[run-tests] Running Angular tests..."
  if ! npm test; then
    return 1
  fi
  if [ -d "${RESULTS_DIR}" ] && [ -n "$(ls -A "${RESULTS_DIR}" 2>/dev/null)" ]; then
    echo "[run-tests] JUnit report in ${RESULTS_DIR}/"
  fi
  return 0
}

# --- Main ---
main() {
  APP_TYPE="${1:-angular}"
  case "$APP_TYPE" in
    angular)
      clean_test_artifacts
      if run_angular_tests; then
        echo "[run-tests] Angular tests passed."
        exit 0
      fi
      echo "[run-tests] Angular tests failed."
      exit 1
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
