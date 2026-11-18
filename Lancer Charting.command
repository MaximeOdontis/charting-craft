#!/bin/bash
# Lance Charting Craft dans Google Chrome (double-cliquez ce fichier).
cd "$(dirname "$0")" || exit 1
PORT=8765
URL="http://localhost:$PORT/charting.html"

if ! lsof -nP -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
  PY="$(command -v python3)"
  if [ -n "$PY" ] && { [ "$PY" != "/usr/bin/python3" ] || xcode-select -p >/dev/null 2>&1; }; then
    "$PY" -m http.server $PORT --bind 127.0.0.1 >/dev/null 2>&1 &
  else
    ruby -run -e httpd . -p $PORT -b 127.0.0.1 >/dev/null 2>&1 &
  fi
  SERVER=$!
  sleep 1
fi

open -a "Google Chrome" "$URL" 2>/dev/null || open "$URL"

echo ""
echo "  Charting Craft est ouvert dans Chrome : $URL"
echo "  Laissez cette fenêtre ouverte pendant l'utilisation."
echo "  Fermez-la (ou Ctrl+C) pour arrêter."
echo ""
[ -n "$SERVER" ] && wait $SERVER
