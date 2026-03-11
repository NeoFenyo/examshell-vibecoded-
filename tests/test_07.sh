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

    /* BASIC_RANGE: 10 random min < max positive ranges */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = rand() % 50; max = min + 1 + (rand() % 20);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS BASIC_RANGE\n");
    else printf("FAIL BASIC_RANGE\n>range(%d,%d) valid\n<NULL or wrong values\n", min, max);

    /* NEGATIVE_RANGE: 10 negative ranges */
    ok = 1;
    for (i = 0; i < N; i++) {
        max = -(rand() % 10); min = max - 1 - (rand() % 20);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS NEGATIVE_RANGE\n");
    else printf("FAIL NEGATIVE_RANGE\n>range(%d,%d) valid\n<NULL or wrong values\n", min, max);

    /* ZERO_CROSS_RANGE: min == max should return NULL */
    ok = 1;
    for (i = 0; i < N; i++) {
        int v = (rand() % 200) - 100;
        r = ft_range(v, v);
        if (r != NULL) { ok = 0; min = v; max = v; free(r); break; }
    }
    if (ok) printf("PASS ZERO_CROSS_RANGE\n");
    else printf("FAIL ZERO_CROSS_RANGE\n>NULL\n<non-NULL for range(%d,%d)\n", min, max);

    /* INVALID_MIN_MAX: min > max should return NULL */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = 10 + (rand() % 50); max = min - 1 - (rand() % 20);
        r = ft_range(min, max);
        if (r != NULL) { ok = 0; free(r); break; }
    }
    if (ok) printf("PASS INVALID_MIN_MAX\n");
    else printf("FAIL INVALID_MIN_MAX\n>NULL\n<non-NULL for range(%d,%d)\n", min, max);

    /* EMPTY_RANGE: ranges of 2 elements */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = (rand() % 200) - 100; max = min + 1;
        r = ft_range(min, max);
        if (!r || r[0] != min || r[1] != max) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS EMPTY_RANGE\n");
    else printf("FAIL EMPTY_RANGE\n>%d %d\n<%d %d\n", min, min+1, r?r[0]:-1, r?r[1]:-1);

    /* SINGLE_ELEM_RANGE: ranges crossing zero */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = -(1 + (rand() % 10)); max = 1 + (rand() % 10);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS SINGLE_ELEM_RANGE\n");
    else printf("FAIL SINGLE_ELEM_RANGE\n>range(%d,%d) valid\n<wrong values\n", min, max);

    /* LARGE_RANGE: larger ranges 50-100 elements */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = (rand() % 100) - 50; max = min + 50 + (rand() % 51);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS LARGE_RANGE\n");
    else printf("FAIL LARGE_RANGE\n>range(%d,%d) valid\n<wrong values\n", min, max);

    /* SAME_BOUNDS: min = 0, max varies */
    ok = 1;
    for (i = 0; i < N; i++) {
        max = 1 + (rand() % 30);
        r = ft_range(0, max);
        if (!r || !check_range(r, 0, max)) { ok = 0; min = 0; break; }
        free(r);
    }
    if (ok) printf("PASS SAME_BOUNDS\n");
    else printf("FAIL SAME_BOUNDS\n>range(0,%d) valid\n<wrong values\n", max);

    /* RANDOM_BOUNDS: fully negative ranges */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = -(50 + (rand() % 50)); max = min + 1 + (rand() % 30);
        if (max >= 0) max = -1;
        if (min >= max) min = max - 5;
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS RANDOM_BOUNDS\n");
    else printf("FAIL RANDOM_BOUNDS\n>range(%d,%d) valid\n<wrong values\n", min, max);

    /* MIXED_BOUNDS: fully random valid/invalid ranges */
    ok = 1;
    for (i = 0; i < N; i++) {
        min = (rand() % 200) - 100;
        max = min + 1 + (rand() % 50);
        r = ft_range(min, max);
        if (!r || !check_range(r, min, max)) { ok = 0; break; }
        free(r);
    }
    if (ok) printf("PASS MIXED_BOUNDS\n");
    else printf("FAIL MIXED_BOUNDS\n>range(%d,%d) valid\n<wrong values\n", min, max);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_range.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
