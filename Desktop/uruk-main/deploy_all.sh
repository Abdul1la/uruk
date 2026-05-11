#!/bin/bash
# Build Flutter web + zip dashboard + zip API backend for full deployment
# Produces three zip files in the project root:
#   web.zip        → extract on server at /uruk-services.com/
#   dashboard.zip  → extract on server at /uruk-services.com/dashboard/   (from local website/)
#   api.zip        → extract on server at /home/skuwvmglap/uruk-api/      (from local backend/)
#                    Keeps server-side uploads/, tmp/, node_modules, DB intact.

set -e
cd "$(dirname "$0")"

echo "=== Cleaning old zips ==="
rm -f web.zip dashboard.zip api.zip

# ── 1. Flutter web build ─────────────────────────────────────
echo ""
echo "=== [1/3] Building Flutter web (release) ==="
flutter pub get
flutter build web --release

echo "=== Normalizing build/web permissions (files 644, dirs 755) ==="
cd build/web
find . -type f -exec chmod 644 {} +
find . -type d -exec chmod 755 {} +
echo "=== Creating web.zip ==="
zip -rq ../../web.zip . -x "*.DS_Store"
cd ../..
echo "  ✓ web.zip: $(du -h web.zip | cut -f1)"

# ── 2. Dashboard (local: website/) ───────────────────────────
echo ""
echo "=== [2/3] Packaging dashboard from website/ ==="
if [ ! -d "website" ]; then
  echo "  ✗ ERROR: website/ folder not found. Skipping dashboard."
else
  cd website
  find . -type f -exec chmod 644 {} + 2>/dev/null || true
  find . -type d -exec chmod 755 {} + 2>/dev/null || true
  zip -rq ../dashboard.zip . \
    -x "*.DS_Store" \
    -x ".git/*" \
    -x "node_modules/*"
  cd ..
  echo "  ✓ dashboard.zip: $(du -h dashboard.zip | cut -f1)"
fi

# ── 3. API (local: backend/) — excludes DB, uploads, node_modules ─
echo ""
echo "=== [3/3] Packaging API backend from backend/ ==="
if [ ! -d "backend" ]; then
  echo "  ✗ ERROR: backend/ folder not found. Skipping API."
else
  cd backend
  # Normalize only source files (not uploads / node_modules / db files)
  find . -type f \
    -not -path "./node_modules/*" \
    -not -path "./uploads/*" \
    -not -path "./tmp/*" \
    -not -path "./.git/*" \
    -not -name "*.db" \
    -not -name "*.sqlite" \
    -not -name "*.sqlite3" \
    -not -name "*.log" \
    -exec chmod 644 {} + 2>/dev/null || true
  find . -type d \
    -not -path "./node_modules*" \
    -not -path "./uploads*" \
    -not -path "./tmp*" \
    -exec chmod 755 {} + 2>/dev/null || true
  zip -rq ../api.zip . \
    -x "node_modules/*" \
    -x "uploads/*" \
    -x "tmp/*" \
    -x ".git/*" \
    -x "*.DS_Store" \
    -x "*.log" \
    -x "*.db" \
    -x "*.sqlite" \
    -x "*.sqlite3" \
    -x ".env.local" \
    -x ".env"
  cd ..
  echo "  ✓ api.zip: $(du -h api.zip | cut -f1)"
fi

echo ""
echo "=== ✅ Done — all zips ready in $(pwd) ==="
ls -lh web.zip dashboard.zip api.zip 2>/dev/null
echo ""
echo "Drag the three zips to the cPanel upload page, then tell Claude 'رُفِعوا'."
