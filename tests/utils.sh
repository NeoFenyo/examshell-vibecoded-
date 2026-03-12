#!/bin/bash
# ============================================================================
#  UTILS — Fonctions utilitaires pour la moulinette
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

TEST_OK=0
TEST_KO=0
TEST_TOTAL=0

# Timeout wrapper multiplateforme
timeout() {
    local max_time="$1"
    shift
    if command -v timeout >/dev/null 2>&1; then
        command timeout "$max_time" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        command gtimeout "$max_time" "$@"
    else
        # Fallback pour macOS sans coreutils
        "$@" &
        local pid=$!
        ( sleep "$max_time" && kill -9 $pid 2>/dev/null ) &
        local watcher=$!
        wait $pid 2>/dev/null
        local status=$?
        kill -9 $watcher 2>/dev/null
        return $status
    fi
}

# Compile avec cc -Wall -Wextra -Werror
# Usage: compile_files <output> <sources...>
compile_files() {
    local output="$1"
    shift
    if ! command -v cc >/dev/null 2>&1; then
        echo -e "  ${RED}[ERROR]${RESET} 'cc' (compiler) non trouve."
        return 1
    fi
    local compiler_output
    compiler_output=$(cc -Wall -Wextra -Werror -Wno-deprecated-declarations -o "$output" "$@" 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "  ${RED}[COMPILE ERROR]${RESET}"
        echo "$compiler_output" | sed 's/^/    /'
        return 1
    fi
    return 0
}


# Parse le protocole de sortie des tests C
# Format: PASS NAME / FAIL NAME\n>expected\n<got
parse_results() {
    local output="$1"
    local state="normal"
    local test_name=""
    local expected=""

    while IFS= read -r line; do
        case "$state" in
            normal)
                if [[ "$line" == PASS\ * ]]; then
                    TEST_TOTAL=$((TEST_TOTAL + 1))
                    TEST_OK=$((TEST_OK + 1))
                    echo -e "  ${GREEN}[OK]${RESET} ${line#PASS }"
                elif [[ "$line" == FAIL\ * ]]; then
                    test_name="${line#FAIL }"
                    state="expect"
                fi
                ;;
            expect)
                expected="${line#>}"
                state="got"
                ;;
            got)
                local got="${line#<}"
                TEST_TOTAL=$((TEST_TOTAL + 1))
                TEST_KO=$((TEST_KO + 1))
                echo -e "  ${RED}[KO]${RESET} $test_name"
                echo -e "    ${DIM}attendu :${RESET} $expected"
                echo -e "    ${DIM}obtenu  :${RESET} $got"
                state="normal"
                ;;
        esac
    done <<< "$output"
}

# Pour les tests bash (programmes)
pass() {
    TEST_TOTAL=$((TEST_TOTAL + 1))
    TEST_OK=$((TEST_OK + 1))
    echo -e "  ${GREEN}[OK]${RESET} $1"
}

fail() {
    local name="$1"
    local expected="$2"
    local got="$3"
    TEST_TOTAL=$((TEST_TOTAL + 1))
    TEST_KO=$((TEST_KO + 1))
    echo -e "  ${RED}[KO]${RESET} $name"
    echo -e "    ${DIM}attendu :${RESET} $expected"
    echo -e "    ${DIM}obtenu  :${RESET} $got"
}

print_results() {
    echo ""
    if [ $TEST_TOTAL -eq 0 ]; then
        echo -e "  ${RED}Aucun test execute${RESET}"
        return 1
    elif [ $TEST_KO -eq 0 ]; then
        echo -e "  ${GREEN}${BOLD}$TEST_OK/$TEST_TOTAL tests OK${RESET}"
        return 0
    else
        echo -e "  ${RED}${BOLD}$TEST_KO/$TEST_TOTAL KO${RESET} ${DIM}($TEST_OK/$TEST_TOTAL OK)${RESET}"
        return 1
    fi
}

cleanup() {
    rm -f /tmp/examshell_test_* /tmp/examshell_cap
}
trap cleanup EXIT
