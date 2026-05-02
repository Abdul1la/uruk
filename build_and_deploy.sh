#!/bin/bash
# Build Flutter web and create web.zip for deployment to uruk-services.com
set -e

# Run from the script's own directory (so it works wherever the folder lives)
cd "$(dirname "$0")"

echo "=== Cleaning previous build artifacts ==="
rm -f web.zip uruk-flutter-web.zip

echo ""
echo "=== Fetching dependencies ==="
flutter pub get

echo ""
echo "=== Building Flutter web (release) ==="
flutter build web --release

echo ""
echo "=== Normalizing permissions (files 644, dirs 755) ==="
cd build/web
find . -type f -exec chmod 644 {} +
find . -type d -exec chmod 755 {} +

echo ""
echo "=== Creating web.zip ==="
zip -rq ../../web.zip . -x "*.DS_Store"
cd ../..

echo ""
echo "=== Done ==="
echo "File: $(pwd)/web.zip"
echo "Size: $(du -h web.zip | cut -f1)"
echo ""
echo "Now tell Claude to re-upload and extract web.zip on the server."
