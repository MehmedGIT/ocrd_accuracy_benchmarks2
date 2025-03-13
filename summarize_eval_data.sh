#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

OUTPUT_FILE=$SCRIPT_DIR/output_summarized.txt

WORKSPACES_ROOT="$SCRIPT_DIR/workspaces"
for json_file in $WORKSPACES_ROOT/data/OCR-D-EVAL-SEG-LINE/*.json; do
    echo "$json_file" >> "$OUTPUT_FILE"
    cat "$json_file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done
