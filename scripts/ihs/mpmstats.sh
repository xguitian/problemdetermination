#!/bin/sh
command -v perl >/dev/null 2>&1 || { echo >&2 "perl required"; exit 1; }
command -v R >/dev/null 2>&1 || { echo >&2 "R required"; exit 1; }
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export INPUT_TITLE="mpmstats ${1}"
export INPUT_PNGFILE="${INPUT_TITLE//[^a-zA-Z0-9_]/}.png"
export INPUT_COLS=2
cat "$1" |\
  perl -n "${DIR}/mpmstats.pl" \
    > "$1.csv"
R --silent --no-save -f "${DIR}/../r/graphcsv.r" < "$1.csv"
if hash eog 2>/dev/null; then
  eog "${INPUT_PNGFILE}" > /dev/null 2>&1 &
fi
