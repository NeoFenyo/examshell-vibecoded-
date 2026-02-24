#!/bin/bash
# Test 01: ft_strlen — 10 tests randomises, 10 iterations chacun
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_strlen --${RESET}"

if [ ! -f "$RENDU/ft_strlen.c" ]; then
    echo -e "  ${RED}Fichier ft_strlen.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int ft_strlen(char *str);

#define N 10


int main(void) {
    srand(time(NULL));
    int i, j, ok, len, got;
    char buf[1024];

    /* WALL_TOO_SHORT: 10x string vide */
    ok = 1; got = 0;
    for (i = 0; i < N; i++) { got = ft_strlen(""); if (got != 0) { ok = 0; break; } }
    if (ok) printf("PASS WALL_TOO_SHORT\n");
    else printf("FAIL WALL_TOO_SHORT\n>0\n<%d\n", got);

    /* BORDER_SHRUNK: 10 random single-char strings */
    ok = 1;
    for (i = 0; i < N; i++) {
        buf[0] = 33 + (rand() % 94); buf[1] = 0;
        got = ft_strlen(buf);
        if (got != 1) { ok = 0; break; }
    }
    if (ok) printf("PASS BORDER_SHRUNK\n");
    else printf("FAIL BORDER_SHRUNK\n>1\n<%d\n", got);

    /* SETTLEMENT_SMALL: 10 random strings 2-10 chars */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 2 + (rand() % 9);
        for (j = 0; j < len; j++) buf[j] = 'a' + (rand() % 26);
        buf[len] = 0;
        got = ft_strlen(buf);
        if (got != len) { ok = 0; break; }
    }
    if (ok) printf("PASS SETTLEMENT_SMALL\n");
    else printf("FAIL SETTLEMENT_SMALL\n>%d\n<%d\n", len, got);

    /* TERRITORY_EMPTY: strings of only spaces */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 1 + (rand() % 20);
        for (j = 0; j < len; j++) buf[j] = ' ';
        buf[len] = 0;
        got = ft_strlen(buf);
        if (got != len) { ok = 0; break; }
    }
    if (ok) printf("PASS TERRITORY_EMPTY\n");
    else printf("FAIL TERRITORY_EMPTY\n>%d\n<%d\n", len, got);

    /* LEGITIMACY_ZERO: 10 random strings 50-200 chars */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 50 + (rand() % 151);
        for (j = 0; j < len; j++) buf[j] = 33 + (rand() % 94);
        buf[len] = 0;
        got = ft_strlen(buf);
        if (got != len) { ok = 0; break; }
    }
    if (ok) printf("PASS LEGITIMACY_ZERO\n");
    else printf("FAIL LEGITIMACY_ZERO\n>%d\n<%d\n", len, got);

    /* SUPPORT_DECLINING: tabs + spaces mixes */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 3 + (rand() % 15);
        for (j = 0; j < len; j++) buf[j] = (rand() % 2) ? ' ' : '\t';
        buf[len] = 0;
        got = ft_strlen(buf);
        if (got != len) { ok = 0; break; }
    }
    if (ok) printf("PASS SUPPORT_DECLINING\n");
    else printf("FAIL SUPPORT_DECLINING\n>%d\n<%d\n", len, got);

    /* ALIBI_THIN: only digits */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 1 + (rand() % 30);
        for (j = 0; j < len; j++) buf[j] = '0' + (rand() % 10);
        buf[len] = 0;
        got = ft_strlen(buf);
        if (got != len) { ok = 0; break; }
    }
    if (ok) printf("PASS ALIBI_THIN\n");
    else printf("FAIL ALIBI_THIN\n>%d\n<%d\n", len, got);

    /* EXCUSE_SHORT: special characters */
    ok = 1;
    for (i = 0; i < N; i++) {
        char sym[] = "!@#$%^&*()_+-=[]{}|;:,.<>?/~";
        int sl = strlen(sym);
        len = 5 + (rand() % 20);
        for (j = 0; j < len; j++) buf[j] = sym[rand() % sl];
        buf[len] = 0;
        got = ft_strlen(buf);
        if (got != len) { ok = 0; break; }
    }
    if (ok) printf("PASS EXCUSE_SHORT\n");
    else printf("FAIL EXCUSE_SHORT\n>%d\n<%d\n", len, got);

    /* CREDIBILITY_NULL: strings with embedded newlines/tabs */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 5 + (rand() % 15);
        for (j = 0; j < len; j++) {
            int r = rand() % 4;
            if (r == 0) buf[j] = '\t';
            else if (r == 1) buf[j] = '\n';
            else buf[j] = 'a' + (rand() % 26);
        }
        buf[len] = 0;
        got = ft_strlen(buf);
        if (got != len) { ok = 0; break; }
    }
    if (ok) printf("PASS CREDIBILITY_NULL\n");
    else printf("FAIL CREDIBILITY_NULL\n>%d\n<%d\n", len, got);

    /* PATIENCE_GONE: full random printable 1-500 chars */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 1 + (rand() % 500);
        for (j = 0; j < len; j++) buf[j] = 1 + (rand() % 126);
        buf[len] = 0;
        got = ft_strlen(buf);
        if (got != len) { ok = 0; break; }
    }
    if (ok) printf("PASS PATIENCE_GONE\n");
    else printf("FAIL PATIENCE_GONE\n>%d\n<%d\n", len, got);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_strlen.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
