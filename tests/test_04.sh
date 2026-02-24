#!/bin/bash
# Test 04: ft_swap — 10 tests randomises, 10 iterations chacun
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_swap --${RESET}"

if [ ! -f "$RENDU/ft_swap.c" ]; then
    echo -e "  ${RED}Fichier ft_swap.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void ft_swap(int *a, int *b);

#define N 10

static void t(char *name, int a_in, int b_in) {
    int a = a_in, b = b_in;
    ft_swap(&a, &b);
    if (a == b_in && b == a_in) printf("PASS %s\n", name);
    else printf("FAIL %s\n>%d %d\n<%d %d\n", name, b_in, a_in, a, b);
}

int main(void) {
    srand(time(NULL));
    int i, a, b, ok;
    int sa, sb, ga, gb;

    /* LAND_THEFT: 10 random positive pairs */
    ok = 1;
    for (i = 0; i < N; i++) {
        a = rand() % 1000; b = rand() % 1000;
        sa = a; sb = b;
        ft_swap(&a, &b);
        if (a != sb || b != sa) { ok = 0; ga = a; gb = b; break; }
    }
    if (ok) printf("PASS LAND_THEFT\n");
    else printf("FAIL LAND_THEFT\n>%d %d\n<%d %d\n", sb, sa, ga, gb);

    /* PRISONER_TRADE: one value is 0 */
    ok = 1;
    for (i = 0; i < N; i++) {
        a = 0; b = 1 + (rand() % 999);
        sa = a; sb = b;
        ft_swap(&a, &b);
        if (a != sb || b != sa) { ok = 0; ga = a; gb = b; break; }
    }
    if (ok) printf("PASS PRISONER_TRADE\n");
    else printf("FAIL PRISONER_TRADE\n>%d %d\n<%d %d\n", sb, sa, ga, gb);

    /* BORDER_SHUFFLE: identical values */
    ok = 1;
    for (i = 0; i < N; i++) {
        a = rand() % 1000; b = a;
        sa = a; sb = b;
        ft_swap(&a, &b);
        if (a != sb || b != sa) { ok = 0; ga = a; gb = b; break; }
    }
    if (ok) printf("PASS BORDER_SHUFFLE\n");
    else printf("FAIL BORDER_SHUFFLE\n>%d %d\n<%d %d\n", sb, sa, ga, gb);

    /* TERRITORY_GRAB: 10 random negative pairs */
    ok = 1;
    for (i = 0; i < N; i++) {
        a = -(rand() % 1000); b = -(rand() % 1000);
        sa = a; sb = b;
        ft_swap(&a, &b);
        if (a != sb || b != sa) { ok = 0; ga = a; gb = b; break; }
    }
    if (ok) printf("PASS TERRITORY_GRAB\n");
    else printf("FAIL TERRITORY_GRAB\n>%d %d\n<%d %d\n", sb, sa, ga, gb);

    /* PEACE_REJECTED: INT_MAX/INT_MIN boundaries */
    t("PEACE_REJECTED", 2147483647, -2147483648);

    /* MAP_REDRAWN: positive vs negative */
    ok = 1;
    for (i = 0; i < N; i++) {
        int v = 1 + (rand() % 10000);
        a = v; b = -v;
        sa = a; sb = b;
        ft_swap(&a, &b);
        if (a != sb || b != sa) { ok = 0; ga = a; gb = b; break; }
    }
    if (ok) printf("PASS MAP_REDRAWN\n");
    else printf("FAIL MAP_REDRAWN\n>%d %d\n<%d %d\n", sb, sa, ga, gb);

    /* DEAL_BROKEN: large random values */
    ok = 1;
    for (i = 0; i < N; i++) {
        a = rand(); b = rand();
        sa = a; sb = b;
        ft_swap(&a, &b);
        if (a != sb || b != sa) { ok = 0; ga = a; gb = b; break; }
    }
    if (ok) printf("PASS DEAL_BROKEN\n");
    else printf("FAIL DEAL_BROKEN\n>%d %d\n<%d %d\n", sb, sa, ga, gb);

    /* COLONY_PLANTED: small values -10 to 10 */
    ok = 1;
    for (i = 0; i < N; i++) {
        a = (rand() % 21) - 10; b = (rand() % 21) - 10;
        sa = a; sb = b;
        ft_swap(&a, &b);
        if (a != sb || b != sa) { ok = 0; ga = a; gb = b; break; }
    }
    if (ok) printf("PASS COLONY_PLANTED\n");
    else printf("FAIL COLONY_PLANTED\n>%d %d\n<%d %d\n", sb, sa, ga, gb);

    /* RIGHTS_REVOKED: always 1 and 0 */
    ok = 1;
    for (i = 0; i < N; i++) {
        a = (i % 2) ? 1 : 0; b = (i % 2) ? 0 : 1;
        sa = a; sb = b;
        ft_swap(&a, &b);
        if (a != sb || b != sa) { ok = 0; ga = a; gb = b; break; }
    }
    if (ok) printf("PASS RIGHTS_REVOKED\n");
    else printf("FAIL RIGHTS_REVOKED\n>%d %d\n<%d %d\n", sb, sa, ga, gb);

    /* WATER_STOLEN: 10 fully random int pairs */
    ok = 1;
    for (i = 0; i < N; i++) {
        a = rand() - rand(); b = rand() - rand();
        sa = a; sb = b;
        ft_swap(&a, &b);
        if (a != sb || b != sa) { ok = 0; ga = a; gb = b; break; }
    }
    if (ok) printf("PASS WATER_STOLEN\n");
    else printf("FAIL WATER_STOLEN\n>%d %d\n<%d %d\n", sb, sa, ga, gb);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_swap.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
