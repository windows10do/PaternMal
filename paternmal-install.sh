# paternmal-setup.sh
# Installer/Uninstaller for PaternMal into ~/.paternmal
# Run with: sh paternmal-setup.sh          (install)
#       or: sh paternmal-setup.sh uninstall   (remove)

set -eu   # portable across Unix and Termux

APP_HOME="$HOME/.paternmal"
BIN_DIR="$APP_HOME/bin"

PROFILE="$HOME/.bashrc"
if [ -n "${ZSH_VERSION:-}" ]; then
  PROFILE="$HOME/.zshrc"
fi
ALIAS_CMD="alias paternmal='$APP_HOME/paternmal-cli.sh'"

uninstall() {
  echo "[PaternMal] Uninstalling..."
  if [ -d "$APP_HOME" ]; then
    rm -rf "$APP_HOME"
    echo "[PaternMal] Removed $APP_HOME"
  fi
  if [ -f "$PROFILE" ]; then
    grep -Fxv "$ALIAS_CMD" "$PROFILE" > "${PROFILE}.tmp" || true
    mv "${PROFILE}.tmp" "$PROFILE"
    echo "[PaternMal] Alias removed from $PROFILE"
    grep -Fxv "export PATH=\"\$HOME/.paternmal/bin:\$PATH\"" "$PROFILE" > "${PROFILE}.tmp" || true
    mv "${PROFILE}.tmp" "$PROFILE"
    echo "[PaternMal] PATH entry removed from $PROFILE"
  fi
  echo "[PaternMal] Uninstall complete."
  exit 0
}

if [ "${1:-}" = "uninstall" ]; then
  uninstall
fi

echo "[PaternMal] Setting up in $APP_HOME"

# 1. Create directories
mkdir -p "$APP_HOME/public"
mkdir -p "$BIN_DIR"

# 2. Always create/overwrite paternmal.cpp
cat > "$APP_HOME/paternmal.cpp" <<'EOF'
// Minimal PaternMal C++ server skeleton
#include <iostream>
int main(int argc, char** argv) {
    std::cout << "PaternMal server running..." << std::endl;
    // For demo: just hang to simulate server
    while (true) {}
    return 0;
}
EOF
echo "[PaternMal] paternmal.cpp created/overwritten."

# 3. Create default CSP file
CSP_FILE="$APP_HOME/.csp"
cat > "$CSP_FILE" <<'EOF'
default-src 'self';
script-src 'self';
style-src 'self' 'unsafe-inline';
img-src 'self' data:;
connect-src 'self' http://localhost:5000;
EOF
echo "[PaternMal] Default .csp created/overwritten."

# 4. Create sample public files
cat > "$APP_HOME/public/index.html" <<'EOF'
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>PaternMal</title>
    <link rel="stylesheet" href="style.css">
  </head>
  <body>
    <h1>PaternMal Installed!</h1>
    <p>Static file served from ~/.paternmal/public</p>
    <script src="script.js"></script>
  </body>
</html>
EOF

echo "body { font-family: sans-serif; background: #f0f0f0; }" > "$APP_HOME/public/style.css"
echo "console.log('PaternMal client script loaded');" > "$APP_HOME/public/script.js"

# 5. Compile binary to paternmal.bin
echo "[PaternMal] Compiling to paternmal.bin..."
g++ -std=c++17 -O2 -pthread "$APP_HOME/paternmal.cpp" -o "$BIN_DIR/paternmal.bin"

# 6. Create CLI wrapper
cat > "$APP_HOME/paternmal-cli.sh" <<'EOF'
set -eu
APP_HOME="$HOME/.paternmal"
BIN="$APP_HOME/bin/paternmal.bin"
SETTINGS_FILE="$APP_HOME/settings.conf"

# Ensure settings file exists
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "EDUCATIONAL=off" > "$SETTINGS_FILE"
  echo "LAST_SERVER=" >> "$SETTINGS_FILE"
fi

. "$SETTINGS_FILE"

case "${1:-}" in
  "")
    echo "[PaternMal] Hanging... (press Ctrl+C to exit)"
    while true; do sleep 3600; done
    ;;
  --help)
    cat <<HELP
PaternMal commands:
  paternmal ~/your-server-dir/   Run server on localhost with given dir
  paternmal --educational --on   Enable educational mode (runs all .sh files in dir)
  paternmal --educational --off  Disable educational mode
  paternmal --settings           Show current settings
  paternmal --help               Show this help
HELP
    ;;
  --settings)
    echo "[PaternMal] Settings:"
    echo "  Educational mode: $EDUCATIONAL"
    echo "  Last server used: $LAST_SERVER"
    ;;
  --educational)
    if [ "${2:-}" = "--on" ]; then
      echo "[PaternMal] Educational mode ON"
      EDUCATIONAL=on
      echo "EDUCATIONAL=$EDUCATIONAL" > "$SETTINGS_FILE"
      echo "LAST_SERVER=$LAST_SERVER" >> "$SETTINGS_FILE"
      if [ -n "$LAST_SERVER" ] && [ -d "$LAST_SERVER" ]; then
        for f in "$LAST_SERVER"/*.sh; do
          [ -f "$f" ] && sh "$f"
        done
      fi
    elif [ "${2:-}" = "--off" ]; then
      echo "[PaternMal] Educational mode OFF"
      EDUCATIONAL=off
      echo "EDUCATIONAL=$EDUCATIONAL" > "$SETTINGS_FILE"
      echo "LAST_SERVER=$LAST_SERVER" >> "$SETTINGS_FILE"
    else
      echo "[PaternMal] Usage: paternmal --educational --on|--off"
    fi
    ;;
  *)
    SERVER_DIR="$1"
    if [ -d "$SERVER_DIR" ]; then
      echo "[PaternMal] Running server on $SERVER_DIR"
      LAST_SERVER="$SERVER_DIR"
      echo "EDUCATIONAL=$EDUCATIONAL" > "$SETTINGS_FILE"
      echo "LAST_SERVER=$LAST_SERVER" >> "$SETTINGS_FILE"
      "$BIN" --port 8080 --root "$SERVER_DIR" --csp "$APP_HOME/.csp" --proxy /api=localhost:5000
    else
      echo "[PaternMal] ERROR: $SERVER_DIR not found"
      exit 1
    fi
    ;;
esac
EOF
chmod +x "$APP_HOME/paternmal-cli.sh"

# 7. Add alias and PATH to shell profile
if ! grep -Fxq "$ALIAS_CMD" "$PROFILE"; then
  echo "$ALIAS_CMD" >> "$PROFILE"
  echo "[PaternMal] Alias added to $PROFILE"
fi
if ! grep -Fxq "export PATH=\"\$HOME/.paternmal/bin:\$PATH\"" "$PROFILE"; then
  echo "export PATH=\"\$HOME/.paternmal/bin:\$PATH\"" >> "$PROFILE"
  echo "[PaternMal] PATH updated in $PROFILE"
fi

echo "[PaternMal] Installation complete."
echo "Restart your shell or run 'source $PROFILE'."
echo "Then start with: paternmal"
