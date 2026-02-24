#!/bin/bash
# Test 02: first_word — 10 tests randomises (programme)
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test first_word --${RESET}"

if [ ! -f "$RENDU/first_word.c" ]; then
    echo -e "  ${RED}Fichier first_word.c introuvable${RESET}"
    exit 1
fi

compile_files "$BIN" "$RENDU/first_word.c"
if [ $? -ne 0 ]; then rm -f "$BIN"; print_results; exit 1; fi

# Reference: extract first word
ref() {
    local s="$1"
    echo "$s" | sed 's/^[ \t]*//' | sed 's/[ \t].*//'
}

run() {
    local name="$1"; shift
    local expected got
    local ok=1 exp_save="" got_save=""
    for arg in "$@"; do
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

# Generate random words
rword() { cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c $((1 + RANDOM % 10)); }

# FREE_PALESTINE: 10 simple words
args=()
for i in $(seq 1 10); do args+=("$(rword)"); done
run "FREE_PALESTINE" "${args[@]}"

# APARTHEID_STATE: 10 strings with leading spaces
args=()
for i in $(seq 1 10); do
    sp=$(printf '%*s' $((1 + RANDOM % 5)) '')
    args+=("${sp}$(rword) $(rword)")
done
run "APARTHEID_STATE" "${args[@]}"

# NAKBA_REMEMBER: 10 strings with leading tabs
args=()
for i in $(seq 1 10); do
    tb=$(printf '\t%.0s' $(seq 1 $((1 + RANDOM % 3))))
    args+=("${tb}$(rword) $(rword)")
done
run "NAKBA_REMEMBER" "${args[@]}"

# CEASEFIRE_NOW: 10 strings with multiple spaces between words
args=()
for i in $(seq 1 10); do
    sp=$(printf '%*s' $((2 + RANDOM % 5)) '')
    args+=("$(rword)${sp}$(rword)")
done
run "CEASEFIRE_NOW" "${args[@]}"

# OCCUPATION_OVER: 10 single isolated words
args=()
for i in $(seq 1 10); do args+=("$(rword)"); done
run "OCCUPATION_OVER" "${args[@]}"

# BOYCOTT_ISRAEL: no argument, 10x
args=()
for i in $(seq 1 10); do args+=("__NOARG__"); done
run "BOYCOTT_ISRAEL" "${args[@]}"

# SETTLER_VIOLENCE: 10 strings of only whitespace
args=()
for i in $(seq 1 10); do
    sp=$(printf '%*s' $((3 + RANDOM % 8)) '')
    args+=("$sp")
done
run "SETTLER_VIOLENCE" "${args[@]}"

# RESISTANCE_FIRST: 10 strings with tabs AND spaces before
args=()
for i in $(seq 1 10); do
    w="$(printf '\t')  $(printf '\t') $(rword) $(rword)"
    args+=("$w")
done
run "RESISTANCE_FIRST" "${args[@]}"

# CHECKPOINT_HELL: 10 first words with punctuation
args=()
for i in $(seq 1 10); do
    args+=("$(rword)!$(rword) $(rword)")
done
run "CHECKPOINT_HELL" "${args[@]}"

# JUSTICE_FIRST: 10 fully random multi-word strings
args=()
for i in $(seq 1 10); do
    s="$(rword) $(rword) $(rword) $(rword)"
    args+=("$s")
done
run "JUSTICE_FIRST" "${args[@]}"

rm -f "$BIN"
print_results
