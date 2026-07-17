#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

MCM_BIN="${MCM_BIN:-mihomo}"

echo "==> Compiling rule-sets"
echo

find . -name meta.yaml -print0 | while IFS= read -r -d '' META; do

    RULE_DIR="$(dirname "$META")"

    LIST_FILE="${RULE_DIR}/rule.list"
    MRS_FILE="${RULE_DIR}/rule.mrs"

    if [[ ! -f "$LIST_FILE" ]]; then
        echo "ERROR: Missing ${LIST_FILE}"
        exit 1
    fi

    BEHAVIOR="$(yq -r '.behavior' "$META")"

    case "$BEHAVIOR" in
        domain|ipcidr|classical)
            ;;
        *)
            echo "ERROR: Unknown behavior '$BEHAVIOR' in $META"
            exit 1
            ;;
    esac

    TMP="$(mktemp)"

    {
        echo "payload:"
        sed 's/^/  - /' "$LIST_FILE"
    } > "$TMP"

    echo "[${BEHAVIOR}] ${RULE_DIR}"

    "$MCM_BIN" convert-ruleset \
        "$BEHAVIOR" \
        "$TMP" \
        "$MRS_FILE"

    rm -f "$TMP"

done

echo
echo "✓ Done."
