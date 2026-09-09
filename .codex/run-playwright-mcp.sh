#!/bin/sh
set -eu

cache_root="${PLAYWRIGHT_BROWSERS_PATH:-${HOME}/.cache/ms-playwright}"
browser_path="$({ find "$cache_root" -type f -path '*/chrome-linux64/chrome' 2>/dev/null || true; } | sort -V | tail -n 1)"

if [ -z "$browser_path" ]; then
  echo "Playwright Chromium is missing. Run: npx -y playwright@latest install chromium" >&2
  exit 1
fi

exec npx -y @playwright/mcp@latest --isolated --executable-path "$browser_path"
