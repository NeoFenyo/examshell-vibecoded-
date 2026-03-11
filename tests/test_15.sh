#!/bin/bash
# Test 15: ppm_gradient (programme)
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ppm_gradient --${RESET}"

if [ ! -f "$RENDU/ppm_gradient.c" ]; then
    echo -e "  ${RED}Fichier ppm_gradient.c introuvable${RESET}"
    exit 1
fi

compile_files "$BIN" "$RENDU/ppm_gradient.c"
if [ $? -ne 0 ]; then rm -f "$BIN"; print_results; exit 1; fi

# Reference implementation
ref_gradient() {
    local w=$1 h=$2
    echo "P3"
    echo "$w $h"
    echo "255"
    for ((y=0; y<h; y++)); do
        for ((x=0; x<w; x++)); do
            local r=$((x * 255 / (w - 1)))
            local g=$((y * 255 / (h - 1)))
            local b=63
            echo "$r $g $b"
        done
    done
}

run() {
    local name="$1" w="$2" h="$3"
    local expected got
    expected=$(ref_gradient "$w" "$h")
    got=$(timeout 10 "$BIN" "$w" "$h" 2>/dev/null)
    if [ "$got" = "$expected" ]; then pass "$name"
    else
        local exp_lines=$(echo "$expected" | wc -l)
        local got_lines=$(echo "$got" | wc -l)
        fail "$name" "${exp_lines} lines" "${got_lines} lines"
    fi
}

# BASIC_LOWERCASE: 4x3
run "BASIC_LOWERCASE" 4 3

# BASIC_DIGITS: 10x10
run "BASIC_DIGITS" 10 10

# SPECIAL_CHARS: no args
got=$(timeout 10 "$BIN" 2>/dev/null)
if [ -z "$got" ]; then pass "SPECIAL_CHARS"; else fail "SPECIAL_CHARS" "(empty)" "$got"; fi

# WHITESPACE: check header
got=$(timeout 10 "$BIN" 20 15 2>/dev/null | head -3)
exp=$(printf "P3\n20 15\n255")
if [ "$got" = "$exp" ]; then pass "WHITESPACE"; else fail "WHITESPACE" "$exp" "$got"; fi

# UPPER_CASE: pixel count
got_lines=$(timeout 10 "$BIN" 5 5 2>/dev/null | tail -n +4 | wc -l)
if [ "$got_lines" -eq 25 ]; then pass "UPPER_CASE"; else fail "UPPER_CASE" "25 pixels" "$got_lines pixels"; fi

# PRINTABLE_CHARS: first pixel (0,0) = 0 0 63
got=$(timeout 10 "$BIN" 10 10 2>/dev/null | sed -n '4p')
if [ "$got" = "0 0 63" ]; then pass "PRINTABLE_CHARS"; else fail "PRINTABLE_CHARS" "0 0 63" "$got"; fi

# NEWLINES: last pixel (w-1,h-1) = 255 255 63 
got=$(timeout 10 "$BIN" 10 10 2>/dev/null | tail -1)
if [ "$got" = "255 255 63" ]; then pass "NEWLINES"; else fail "NEWLINES" "255 255 63" "$got"; fi

# NULL_BYTES: 2x2
run "NULL_BYTES" 2 2

# NORM_SCALE_X: 3x3
run "NORM_SCALE_X" 3 3

# NORM_NEG_XY: 8x6
run "NORM_NEG_XY" 8 6

rm -f "$BIN"
print_results
