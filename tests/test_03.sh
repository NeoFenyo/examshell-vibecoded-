#!/bin/bash
# Test 03: repeat_alpha — 10 tests randomises (programme)
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test repeat_alpha --${RESET}"

if [ ! -f "$RENDU/repeat_alpha.c" ]; then
    echo -e "  ${RED}Fichier repeat_alpha.c introuvable${RESET}"
    exit 1
fi

compile_files "$BIN" "$RENDU/repeat_alpha.c"
if [ $? -ne 0 ]; then rm -f "$BIN"; print_results; exit 1; fi

# Reference implementation
ref() {
    local s="$1" result="" c n
    for ((i=0; i<${#s}; i++)); do
        c="${s:$i:1}"
        if [[ "$c" =~ [a-z] ]]; then
            n=$(( $(printf '%d' "'$c") - 96 ))
            for ((j=0; j<n; j++)); do result+="$c"; done
        elif [[ "$c" =~ [A-Z] ]]; then
            n=$(( $(printf '%d' "'$c") - 64 ))
            for ((j=0; j<n; j++)); do result+="$c"; done
        else
            result+="$c"
        fi
    done
    echo "$result"
}

rword() { cat /dev/urandom | tr -dc 'a-z' | head -c $((1 + RANDOM % 6)); }

run() {
    local name="$1"; shift
    local ok=1 exp_save="" got_save=""
    for arg in "$@"; do
        local expected got
        if [ "$arg" = "__NOARG__" ]; then
            expected=""
            got=$(timeout 10 "$BIN" 2>/dev/null)
        else
            expected=$(ref "$arg")
            got=$(timeout 10 "$BIN" "$arg" 2>/dev/null)
        fi
        if [ "$got" != "$expected" ]; then
            ok=0; exp_save="$expected"; got_save="$got"; break
        fi
    done
    if [ $ok -eq 1 ]; then pass "$name"
    else fail "$name" "$exp_save" "$got_save"; fi
}

# VETO_AGAIN: 10 random lowercase strings
args=(); for i in $(seq 1 10); do args+=("$(rword)"); done
run "VETO_AGAIN" "${args[@]}"

# WAR_CRIME_REPEAT: 10 random uppercase strings
args=(); for i in $(seq 1 10); do
    w=$(cat /dev/urandom | tr -dc 'A-Z' | head -c $((1 + RANDOM % 6)))
    args+=("$w")
done
run "WAR_CRIME_REPEAT" "${args[@]}"

# UN_IGNORED_AGAIN: 10 digit-only strings (should print once each)
args=(); for i in $(seq 1 10); do
    w=$(cat /dev/urandom | tr -dc '0-9' | head -c $((1 + RANDOM % 8)))
    args+=("$w")
done
run "UN_IGNORED_AGAIN" "${args[@]}"

# VIOLATION_LOOP: 10 mixed alpha+digit strings
args=(); for i in $(seq 1 10); do
    w=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c $((3 + RANDOM % 6)))
    args+=("$w")
done
run "VIOLATION_LOOP" "${args[@]}"

# EXCUSE_RECYCLED: strings with z/Z (26 repetitions)
args=("z" "Z" "zz" "ZZ" "az" "Az" "zA" "zZ" "zzz" "ZZZ")
run "EXCUSE_RECYCLED" "${args[@]}"

# BOMBING_REPEAT: empty string and no arg
args=("" "" "" "" "" "__NOARG__" "__NOARG__" "__NOARG__" "__NOARG__" "__NOARG__")
run "BOMBING_REPEAT" "${args[@]}"

# DENIAL_AGAIN: strings with spaces
args=("a b" "a b c" " a" "a " "a  b" "a b" " " "  " "a b c d" "x y")
run "DENIAL_AGAIN" "${args[@]}"

# HASBARA_REPLAY: only non-alpha characters
args=("123" "!@#" "..." "   " "12 34" "!a" "1" "." " !" "##")
run "HASBARA_REPLAY" "${args[@]}"

# BLOCKADE_ONGOING: full alphabet tests
args=("abc" "xyz" "ABC" "XYZ" "abcxyz" "ABCXYZ" "aAbBcC" "zZaA" "mno" "MNO")
run "BLOCKADE_ONGOING" "${args[@]}"

# PROPAGANDA_LOOP: 10 fully random strings
args=(); for i in $(seq 1 10); do
    w=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9 !.' | head -c $((2 + RANDOM % 8)))
    args+=("$w")
done
run "PROPAGANDA_LOOP" "${args[@]}"

rm -f "$BIN"
print_results
