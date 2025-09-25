#!/usr/bin/env zsh

echo "=== Key Sequence Debugger ==="
echo "This will show exactly what your Terminal sends."

capture_key() {
    echo "Type sequence and then press Enter:"
    
    # Use read to capture the key sequence
    local sequence
    read -r sequence
    
    if [[ -n "$sequence" ]]; then
        printf "Raw sequence: "
        printf '%s\n' "$sequence"
        
        # Convert to bindkey format
        printf "Bindkey format: "
        printf '%q\n' "$sequence"
        
        # Show hex
        printf  "Hex: "
        echo -n "$sequence" | hexdump -C | head -1
    else
        echo "No sequence captured"
    fi
}
capture_key





