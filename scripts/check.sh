#!/usr/bin/env bash
# CI checks: same rules as the pre-commit hook, run on every tracked file
fail=0
for f in $(git ls-files); do
  if grep -qE '^(<<<<<<<|=======|>>>>>>>)( |$)' "$f"; then
    echo "FAIL: conflict markers in $f"
    fail=1
  fi
done
for f in $(git ls-files '*.sh'); do
  if bash -n "$f"; then
    echo "OK: $f"
  else
    echo "FAIL: syntax error in $f"
    fail=1
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "All checks passed"
fi
exit $fail
