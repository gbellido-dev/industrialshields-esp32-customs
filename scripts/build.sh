#!/usr/bin/env bash
# Construye el paquete framework-industrialshields-esp32 con los arreglos de
# patches/ a partir del original de Industrial Shields.
#
#   scripts/build.sh                 descarga el original y construye dist/
#   ORIGINAL=ruta.tar.bz2 scripts/build.sh   usa un original ya descargado
#
# Sale en dist/:
#   framework-industrialshields-esp32-<BASE>-customs.<N>.tar.gz
# (.tar.gz y no .tar.bz2: PlatformIO toma como repositorio git cualquier URL
# de github.com que no acabe en .zip, .tar.gz o .tar.xz)
#   SHA256SUMS
set -euo pipefail

BASE_VERSION="2.7.1"
CUSTOMS="2"   # sube con cada release de los arreglos (y INDUSTRIALSHIELDS_ESP32_CUSTOMS en 0001)
ORIGINAL_URL="https://apps.industrialshields.com/main/arduino/boards/industrialshields-boards-esp32-${BASE_VERSION}.tar.bz2"
ORIGINAL_SHA256="da808ea908c24243c212d6aa691633d001ce6d7802d00580667a2c123ab37e2a"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
NAME="framework-industrialshields-esp32-${BASE_VERSION}-customs.${CUSTOMS}"
VERSION="${BASE_VERSION}+customs.${CUSTOMS}"

if [[ -n "${ORIGINAL:-}" ]]; then
  cp "$ORIGINAL" "$WORK/original.tar.bz2"
else
  echo "Descargando $ORIGINAL_URL"
  curl -fL --retry 3 -o "$WORK/original.tar.bz2" "$ORIGINAL_URL"
fi
echo "${ORIGINAL_SHA256}  $WORK/original.tar.bz2" | sha256sum -c -

echo "Extrayendo"
tar xjf "$WORK/original.tar.bz2" -C "$WORK"
test -f "$WORK/esp32/package.json"

for p in "$ROOT"/patches/*.patch; do
  echo "Aplicando $(basename "$p")"
  patch -d "$WORK/esp32" -p1 --forward --batch < "$p"
done
find "$WORK/esp32" -name '*.orig' -delete

python3 - "$WORK/esp32/package.json" "$VERSION" <<'PY'
import json, sys
p, version = sys.argv[1], sys.argv[2]
d = json.load(open(p))
d["version"] = version
d["description"] = (d.get("description", "") +
    " - con arreglos no oficiales de github.com/gbellido-dev/industrialshields-esp32-customs")
json.dump(d, open(p, "w"), indent=4, ensure_ascii=False)
open(p, "a").write("\n")
PY
cp "$ROOT/README.md" "$WORK/esp32/CUSTOMS.md"

mkdir -p "$ROOT/dist"
echo "Empaquetando $NAME.tar.gz"
tar czf "$ROOT/dist/$NAME.tar.gz" -C "$WORK" esp32
(cd "$ROOT/dist" && sha256sum "$NAME.tar.gz" > SHA256SUMS && cat SHA256SUMS)
