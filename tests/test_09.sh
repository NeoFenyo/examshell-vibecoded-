#!/bin/bash
# Test 09: fprime — 10 tests randomises (programme)
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test fprime --${RESET}"

if [ ! -f "$RENDU/fprime.c" ]; then
    echo -e "  ${RED}Fichier fprime.c introuvable${RESET}"
    exit 1
fi

compile_files "$BIN" "$RENDU/fprime.c"
if [ $? -ne 0 ]; then rm -f "$BIN"; print_results; exit 1; fi

# Reference implementation en bash
ref_fprime() {
    local n=$1
    if [ "$n" -eq 1 ]; then echo "1"; return; fi
    local d=2 first=1 result=""
    while [ $((d * d)) -le $n ]; do
        while [ $((n % d)) -eq 0 ]; do
            if [ $first -eq 1 ]; then result="$d"; first=0
            else result="$result * $d"; fi
            n=$((n / d))
        done
        d=$((d + 1))
    done
    if [ $n -gt 1 ]; then
        if [ $first -eq 1 ]; then result="$n"
        else result="$result * $n"; fi
    fi
    echo "$result"
}

run() {
    local name="$1"; shift
    local ok=1 exp_save="" got_save=""
    for arg in "$@"; do
        local expected got
        if [ "$arg" = "__NOARG__" ]; then
            expected=""
            got=$(timeout 10 "$BIN" 2>/dev/null)
        else
            expected=$(ref_fprime "$arg")
            got=$(timeout 10 "$BIN" "$arg" 2>/dev/null)
        fi
        if [ "$got" != "$expected" ]; then
            ok=0; exp_save="$expected"; got_save="$got"; break
        fi
    done
    if [ $ok -eq 1 ]; then pass "$name"
    else fail "$name" "$exp_save" "$got_save"; fi
}

# BIBI_INDICTED: n=1, 10 times
args=(); for i in $(seq 1 10); do args+=("1"); done
run "BIBI_INDICTED" "${args[@]}"

# LIKUD_CRUMBLES: 10 known prime numbers
run "LIKUD_CRUMBLES" 2 3 5 7 11 13 17 19 23 29

# COALITION_SPLIT: powers of 2
run "COALITION_SPLIT" 2 4 8 16 32 64 128 256 512 1024

# KNESSET_CIRCUS: classic composite numbers
run "KNESSET_CIRCUS" 42 100 360 720 1000 1234 5678 9999 12345 99999

# CORRUPTION_PRIME: mix of primes and composites
run "CORRUPTION_PRIME" 6 10 14 15 21 35 77 91 143 221

# BRIBERY_FACTOR: larger composites
run "BRIBERY_FACTOR" 225225 100000 999999 123456 654321 111111 222222 333333 444444 555555

# FRAUD_EXPOSED: perfect squares
run "FRAUD_EXPOSED" 4 9 25 49 121 169 289 361 529 841

# SCANDAL_UNFOLDS: no argument, 10 times
args=(); for i in $(seq 1 10); do args+=("__NOARG__"); done
run "SCANDAL_UNFOLDS" "${args[@]}"

# ELECTION_FARCE: larger prime numbers
run "ELECTION_FARCE" 97 101 103 107 109 113 127 131 137 139

# REGIME_COLLAPSE: 10 random numbers between 2 and 100000
args=()
for i in $(seq 1 10); do
    n=$((2 + RANDOM % 99999))
    args+=("$n")
done
run "REGIME_COLLAPSE" "${args[@]}"

rm -f "$BIN"
print_results
