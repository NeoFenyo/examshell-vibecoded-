#!/bin/bash
# Test 07: ft_range — 10 tests randomises, 10 iterations chacun
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_range --${RESET}"

if [ ! -f "$RENDU/ft_range.c" ]; then
    echo -e "  ${RED}Fichier ft_range.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int *ft_range(int min, int max);

#define N 10

static int check_range(int *arr, int min, int max) {
    int i, size = max - min + 1;
    if (!arr) return 0;
    for (i = 0; i < size; i++)
        if (arr[i] != min + i) return 0;
    return 1;
}

int main(void) {
    srand(time(NULL));
    int i, ok, min, max, *r;

    /* BORDER_ILLEGAL: 10 random min < max positive ranges */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = rand() % 50; max = min + 1 + (rand() % 20);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS BORDER_ILLEGAL\n");
    else printf("FAIL BORDER_ILLEGAL\n>range(%d,%d) valid\n<NULL or wrong values\n", min, max);

    /* NO_BOUNDARY: 10 negative ranges */
    ok = 1;
    for (i = 0; i < N; i++) {
        max = -(rand() % 10); min = max - 1 - (rand() % 20);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS NO_BOUNDARY\n");
    else printf("FAIL NO_BOUNDARY\n>range(%d,%d) valid\n<NULL or wrong values\n", min, max);

    /* EXPANSION_ENDLESS: min == max should return NULL */
    ok = 1;
    for (i = 0; i < N; i++) {
        int v = (rand() % 200) - 100;
        r = ft_range(v, v);
        if (r != NULL) { ok = 0; min = v; max = v; free(r); break; }
    }
    if (ok) printf("PASS EXPANSION_ENDLESS\n");
    else printf("FAIL EXPANSION_ENDLESS\n>NULL\n<non-NULL for range(%d,%d)\n", min, max);

    /* SETTLEMENT_CREEP: min > max should return NULL */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = 10 + (rand() % 50); max = min - 1 - (rand() % 20);
        r = ft_range(min, max);
        if (r != NULL) { ok = 0; free(r); break; }
    }
    if (ok) printf("PASS SETTLEMENT_CREEP\n");
    else printf("FAIL SETTLEMENT_CREEP\n>NULL\n<non-NULL for range(%d,%d)\n", min, max);

    /* ANNEX_MORE: ranges of 2 elements */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = (rand() % 200) - 100; max = min + 1;
        r = ft_range(min, max);
        if (!r || r[0] != min || r[1] != max) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS ANNEX_MORE\n");
    else printf("FAIL ANNEX_MORE\n>%d %d\n<%d %d\n", min, min+1, r?r[0]:-1, r?r[1]:-1);

    /* GREEN_LINE_ERASED: ranges crossing zero */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = -(1 + (rand() % 10)); max = 1 + (rand() % 10);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS GREEN_LINE_ERASED\n");
    else printf("FAIL GREEN_LINE_ERASED\n>range(%d,%d) valid\n<wrong values\n", min, max);

    /* BUFFER_STOLEN: larger ranges 50-100 elements */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = (rand() % 100) - 50; max = min + 50 + (rand() % 51);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS BUFFER_STOLEN\n");
    else printf("FAIL BUFFER_STOLEN\n>range(%d,%d) valid\n<wrong values\n", min, max);

    /* GOLAN_GRABBED: min = 0, max varies */
    ok = 1;
    for (i = 0; i < N; i++) {
        max = 1 + (rand() % 30);
        r = ft_range(0, max);
        if (!r || !check_range(r, 0, max)) { ok = 0; min = 0; break; }
        free(r);
    }
    if (ok) printf("PASS GOLAN_GRABBED\n");
    else printf("FAIL GOLAN_GRABBED\n>range(0,%d) valid\n<wrong values\n", max);

    /* WEST_BANK_GONE: fully negative ranges */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = -(50 + (rand() % 50)); max = min + 1 + (rand() % 30);
        if (max >= 0) max = -1;
        if (min >= max) min = max - 5;
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS WEST_BANK_GONE\n");
    else printf("FAIL WEST_BANK_GONE\n>range(%d,%d) valid\n<wrong values\n", min, max);

    /* OCCUPATION_RANGE: fully random valid/invalid ranges */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = (rand() % 200) - 100;
        max = min + 1 + (rand() % 50);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS OCCUPATION_RANGE\n");
    else printf("FAIL OCCUPATION_RANGE\n>range(%d,%d) valid\n<wrong values\n", min, max);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_range.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
