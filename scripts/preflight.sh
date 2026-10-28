#!/usr/bin/env bash
# Checks the tools init-repo needs (macOS/Linux). Prints one JSON object per
# tool and never installs anything. The agent reads the output and asks the
# user about each missing tool.
set -u

json() { # tool found ok version install neededBy
  printf '{"tool":"%s","found":%s,"ok":%s,"version":"%s","install":"%s","neededBy":"%s"}\n' "$1" "$2" "$3" "$4" "$5" "$6"
}
first_line() { "$@" 2>&1 | head -n1 | tr -d '"'; }

if command -v brew >/dev/null 2>&1; then pm=brew; else pm=apt; fi
pkg() { if [ "$pm" = brew ]; then echo "brew install $1"; else echo "sudo apt install $2"; fi; }

# git
if v=$(first_line git --version) && command -v git >/dev/null; then json git true true "$v" "$(pkg git git)" "everything"
else json git false false "" "$(pkg git git)" "everything"; fi

# node >= 22.20
if command -v node >/dev/null; then
  v=$(node --version); maj=$(echo "$v" | sed -E 's/v([0-9]+)\..*/\1/'); min=$(echo "$v" | sed -E 's/v[0-9]+\.([0-9]+).*/\1/')
  if [ "$maj" -gt 22 ] || { [ "$maj" -eq 22 ] && [ "$min" -ge 20 ]; }; then ok=true; else ok=false; fi
  json node true "$ok" "$v" "$(pkg node nodejs) (needs >=22.20; nvm recommended)" "all skill installers"
else json node false false "" "$(pkg node nodejs) (needs >=22.20; nvm recommended)" "all skill installers"; fi

# python 3
if command -v python3 >/dev/null; then json python3 true true "$(first_line python3 --version)" "$(pkg python3 python3)" "ui-ux-pro-max search scripts"
else json python3 false false "" "$(pkg python3 python3)" "ui-ux-pro-max search scripts"; fi

# ffmpeg
if command -v ffmpeg >/dev/null; then json ffmpeg true true "$(first_line ffmpeg -version)" "$(pkg ffmpeg ffmpeg)" "hyperframes rendering"
else json ffmpeg false false "" "$(pkg ffmpeg ffmpeg)" "hyperframes rendering"; fi

# Chrome / Chromium / Edge
if [ "$pm" = brew ]; then chrome_install="brew install --cask google-chrome"; else chrome_install="sudo apt install chromium"; fi
browser=""
for b in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge; do
  if command -v "$b" >/dev/null; then browser="$b"; break; fi
done
for p in "/Applications/Google Chrome.app" "/Applications/Chromium.app" "/Applications/Microsoft Edge.app"; do
  [ -z "$browser" ] && [ -d "$p" ] && browser="$p"
done
if [ -n "$browser" ]; then json chrome true true "$browser" "$chrome_install" "taste, impeccable URL scans, hyperframes"
else json chrome false false "" "$chrome_install" "taste, impeccable URL scans, hyperframes"; fi
