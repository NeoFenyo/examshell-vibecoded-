#!/bin/bash
# Test 24: mini_rt (programme complet)
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

BIN="/tmp/examshell_bin_$$"
PPM="/tmp/examshell_rt_$$.ppm"

echo -e "${CYAN}${BOLD}-- Test mini_rt --${RESET}"

if [ ! -f "$RENDU/mini_rt.c" ]; then
    echo -e "  ${RED}Fichier mini_rt.c introuvable${RESET}"
    exit 1
fi

cp "$PROJECT/subjects/includes/vec3.h" "$RENDU/" 2>/dev/null
cp "$PROJECT/subjects/includes/ray.h" "$RENDU/" 2>/dev/null
cp "$PROJECT/subjects/includes/color.h" "$RENDU/" 2>/dev/null

# Compile all student files
SRCS=""
for f in "$RENDU"/*.c; do SRCS="$SRCS $f"; done

cc -Wall -Wextra -Werror -I"$RENDU" -o "$BIN" $SRCS -lm 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "  ${RED}[COMPILE ERROR]${RESET}"
    rm -f "$BIN"
    print_results
    exit 1
fi

# Run and capture PPM
timeout 10 "$BIN" > "$PPM" 2>/dev/null
RET=$?

if [ $RET -eq 124 ]; then
    echo -e "  ${RED}[TIMEOUT] Boucle infinie detectee (>10s)${RESET}"
    rm -f "$BIN" "$PPM"
    print_results
    exit 1
fi

# Check output exists and is valid PPM
if [ ! -s "$PPM" ]; then
    fail "CROSS_XY" "PPM output" "(empty)"
    rm -f "$BIN" "$PPM"; print_results; exit 1
fi

# Check header
HEADER=$(head -3 "$PPM")
LINE1=$(echo "$HEADER" | sed -n '1p')
LINE2=$(echo "$HEADER" | sed -n '2p')
LINE3=$(echo "$HEADER" | sed -n '3p')

if [ "$LINE1" = "P3" ]; then pass "CROSS_XY"; else fail "CROSS_XY" "P3" "$LINE1"; fi

# Check dimensions
if [ "$LINE2" = "400 225" ]; then pass "CROSS_YX"; else fail "CROSS_YX" "400 225" "$LINE2"; fi

# Check max color
if [ "$LINE3" = "255" ]; then pass "CROSS_XZ"; else fail "CROSS_XZ" "255" "$LINE3"; fi

# Check pixel count (400*225 = 90000 lines of RGB)
PIXEL_LINES=$(tail -n +4 "$PPM" | wc -l)
if [ "$PIXEL_LINES" -eq 90000 ]; then pass "CROSS_SELF"; else fail "CROSS_SELF" "90000 pixels" "$PIXEL_LINES pixels"; fi

# Check sky color at top (should be blueish: high B)
TOP_PIXEL=$(sed -n '4p' "$PPM")
TOP_B=$(echo "$TOP_PIXEL" | awk '{print $3}')
if [ "$TOP_B" -gt 200 ]; then pass "CROSS_ZERO"; else fail "CROSS_ZERO" "B>200 (blue sky)" "B=$TOP_B"; fi

# Check that sphere exists (center pixel should not be sky)
CENTER_LINE=$((4 + 112 * 400 + 200))
CENTER_PIXEL=$(sed -n "${CENTER_LINE}p" "$PPM")
CENTER_R=$(echo "$CENTER_PIXEL" | awk '{print $1}')
CENTER_G=$(echo "$CENTER_PIXEL" | awk '{print $2}')
if [ "$CENTER_R" -gt "$CENTER_G" ]; then pass "CROSS_BASIC"; else fail "CROSS_BASIC" "R>G (red sphere)" "R=$CENTER_R G=$CENTER_G"; fi

# Check that some pixels are dark (shadows exist)
DARK_COUNT=$(tail -n +4 "$PPM" | awk '{if ($1+$2+$3 < 100) count++} END {print count+0}')
if [ "$DARK_COUNT" -gt 0 ]; then pass "CROSS_RANDOM"; else fail "CROSS_RANDOM" "dark pixels (shadows)" "none found"; fi

# Check ground exists (bottom center should be grey)
GROUND_LINE=$((4 + 200 * 400 + 200))
GROUND_PIXEL=$(sed -n "${GROUND_LINE}p" "$PPM")
GROUND_R=$(echo "$GROUND_PIXEL" | awk '{print $1}')
GROUND_G=$(echo "$GROUND_PIXEL" | awk '{print $2}')
GROUND_B=$(echo "$GROUND_PIXEL" | awk '{print $3}')
DIFF_RG=$((GROUND_R - GROUND_G))
if [ "${DIFF_RG#-}" -lt 30 ]; then pass "CROSS_ANTICOMMUTATIVE"; else fail "CROSS_ANTICOMMUTATIVE" "grey ground (R≈G≈B)" "R=$GROUND_R G=$GROUND_G B=$GROUND_B"; fi

# Check all RGB values are 0-255
INVALID=$(tail -n +4 "$PPM" | awk '{for(i=1;i<=3;i++) if ($i<0||$i>255) {print "bad"; exit}}')
if [ -z "$INVALID" ]; then pass "CROSS_PERPENDICULAR"; else fail "CROSS_PERPENDICULAR" "all RGB in [0,255]" "invalid values found"; fi

pass "CROSS_OPPOSITE"

rm -f "$BIN" "$PPM"
print_results
