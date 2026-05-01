#!/bin/bash
set -e

TOTAL_STEPS=9
STEP=0
step() {
  STEP=$((STEP + 1))
  echo
  echo "[$STEP/$TOTAL_STEPS] $1"
}

step "Installing dependencies"
dart pub get

step "Running tests"
dart test

step "Running example"
dart run example/example.dart

step "Validating package (dry-run)"
dart pub publish --dry-run

step "Running pana (pub.dev score)"
PANA_OUT=$(pana --no-warning . | tee /dev/stderr)
if ! grep -q "Points: 160/160" <<<"$PANA_OUT"; then
  echo
  echo "❌ Aborting release: pana score is below 160/160. Fix the issues above."
  exit 1
fi

VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
VALIDART_VERSION=$(grep -E '^\s+validart: \^' pubspec.yaml | head -n1 | sed -E 's/.*\^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')

step "Verifying README installation snippet matches pubspec versions"

README_BR_VERSION=$(grep -E '^\s*validart_br: \^' README.md | head -n1 | sed -E 's/.*\^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
if [ -z "$README_BR_VERSION" ]; then
  echo
  echo "❌ Aborting release: could not find 'validart_br: ^X.Y.Z' in README.md."
  echo "   The Installation section must pin the current pubspec.yaml version."
  exit 1
fi
if [ "$README_BR_VERSION" != "$VERSION" ]; then
  echo
  echo "❌ Aborting release: README pins validart_br ^${README_BR_VERSION}, but pubspec.yaml is ${VERSION}."
  echo "   Update the README '## Instalação' block to '^${VERSION}' before releasing."
  exit 1
fi

README_CORE_VERSION=$(grep -E '^\s*validart: \^' README.md | head -n1 | sed -E 's/.*\^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
if [ -z "$README_CORE_VERSION" ]; then
  echo
  echo "❌ Aborting release: could not find 'validart: ^X.Y.Z' in README.md."
  echo "   The Installation section must pin the current validart constraint."
  exit 1
fi
if [ "$README_CORE_VERSION" != "$VALIDART_VERSION" ]; then
  echo
  echo "❌ Aborting release: README pins validart ^${README_CORE_VERSION}, but pubspec.yaml requires ^${VALIDART_VERSION}."
  echo "   Update the README '## Instalação' block to '^${VALIDART_VERSION}' before releasing."
  exit 1
fi

echo "README pinned at validart ^${README_CORE_VERSION}, validart_br ^${README_BR_VERSION} ✓"

step "Creating tag v$VERSION"
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "Tag v$VERSION already exists, skipping"
else
  git tag "v$VERSION"
fi

step "Pushing"
git push origin master
git push --tags

step "Publishing to pub.dev"
dart pub publish --force

echo
echo "🎉 Done! Published v$VERSION"
