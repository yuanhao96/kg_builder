#!/usr/bin/env bash
# batch_kg.sh — Run kg-builder on every .txt file in a directory.
#
# Usage:
#   ./batch_kg.sh <directory>              # sequential
#   ./batch_kg.sh <directory> --parallel   # parallel (caution: rate limits)
#
# Output: <directory>/kg_output/<filename>/nodes.csv + edges.csv
#         <directory>/kg_output/<filename>.log  (claude output per file)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIR="${1:?Usage: $0 <directory> [--parallel]}"
PARALLEL=false
[[ "${2:-}" == "--parallel" ]] && PARALLEL=true

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: '$INPUT_DIR' is not a directory" >&2
    exit 1
fi

INPUT_DIR="$(cd "$INPUT_DIR" && pwd)"  # normalise to absolute path

shopt -s nullglob
txt_files=("$INPUT_DIR"/*.txt)
shopt -u nullglob

if [[ ${#txt_files[@]} -eq 0 ]]; then
    echo "No .txt files found in '$INPUT_DIR'" >&2
    exit 1
fi

echo "Found ${#txt_files[@]} file(s) to process."
echo "Output root: $INPUT_DIR/kg_output/"
echo "---"

run_kg() {
    local txt_file="$1"
    local name
    name="$(basename "$txt_file" .txt)"
    local out_subdir="kg_output/$name"
    local log_file="$INPUT_DIR/kg_output/$name.log"

    mkdir -p "$INPUT_DIR/kg_output"

    echo "[START] $name"

    (
        cd "$INPUT_DIR"
        claude \
            --plugin-dir "$SCRIPT_DIR" \
            --dangerouslySkipPermissions \
            -p "Build a knowledge graph from '$txt_file'. \
Run in single-shot mode. \
Write all output files to '$out_subdir/' instead of the default kg_output/ \
(i.e. nodes.csv -> $out_subdir/nodes.csv, edges.csv -> $out_subdir/edges.csv, \
citation_map.json -> $out_subdir/citation_map.json)."
    ) > "$log_file" 2>&1 \
        && echo "[DONE]  $name  ->  $INPUT_DIR/$out_subdir/" \
        || echo "[FAIL]  $name  (see $log_file)"
}

if $PARALLEL; then
    pids=()
    for f in "${txt_files[@]}"; do
        run_kg "$f" &
        pids+=($!)
    done
    for pid in "${pids[@]}"; do
        wait "$pid" || true
    done
else
    for f in "${txt_files[@]}"; do
        run_kg "$f"
    done
fi

echo "---"
echo "All done. Outputs in $INPUT_DIR/kg_output/"
