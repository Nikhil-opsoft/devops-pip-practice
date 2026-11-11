# Day 3 Git practice
Run ./healthcheck.sh to check the app.
Port is 9090 (agreed after conflict).
CI runs scripts/check.sh on every push and pull request.
A pre-commit hook in .githooks/ blocks conflict markers and broken shell scripts.
Enable it after cloning with: git config core.hooksPath .githooks
