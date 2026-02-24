#!/bin/bash
# Test 06: ft_atoi — 10 tests randomises, 10 iterations chacun
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_atoi --${RESET}"

if [ ! -f "$RENDU/ft_atoi.c" ]; then
    echo -e "  ${RED}Fichier ft_atoi.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int ft_atoi(const char *str);

#define N 10

int main(void) {
    srand(time(NULL));
    int i, ok, expected, got;
    char buf[256];

    /* CASUALTIES_HIDDEN: variations of zero */
    { char *zs[] = {"0","+0","-0","  0"," +0"," -0","  \t0","000","+000","-000"};
      ok = 1;
      for (i = 0; i < N; i++) {
        got = ft_atoi(zs[i]); expected = atoi(zs[i]);
        if (got != expected) { ok = 0; break; }
      }
      if (ok) printf("PASS CASUALTIES_HIDDEN\n");
      else printf("FAIL CASUALTIES_HIDDEN\n>%d\n<%d\n", expected, got);
    }

    /* AID_BLOCKED: 10 random positive numbers */
    ok = 1;
    for (i = 0; i < N; i++) {
        sprintf(buf, "%d", rand() % 100000);
        expected = atoi(buf); got = ft_atoi(buf);
        if (got != expected) { ok = 0; break; }
    }
    if (ok) printf("PASS AID_BLOCKED\n");
    else printf("FAIL AID_BLOCKED\n>%d\n<%d\n", expected, got);

    /* BUDGET_MILITARY: 10 random negative numbers */
    ok = 1;
    for (i = 0; i < N; i++) {
        sprintf(buf, "-%d", 1 + (rand() % 100000));
        expected = atoi(buf); got = ft_atoi(buf);
        if (got != expected) { ok = 0; break; }
    }
    if (ok) printf("PASS BUDGET_MILITARY\n");
    else printf("FAIL BUDGET_MILITARY\n>%d\n<%d\n", expected, got);

    /* SUBSIDY_US: 10 with explicit + sign */
    ok = 1;
    for (i = 0; i < N; i++) {
        sprintf(buf, "+%d", rand() % 100000);
        expected = atoi(buf); got = ft_atoi(buf);
        if (got != expected) { ok = 0; break; }
    }
    if (ok) printf("PASS SUBSIDY_US\n");
    else printf("FAIL SUBSIDY_US\n>%d\n<%d\n", expected, got);

    /* BILLION_WASTED: 10 with leading whitespace */
    ok = 1;
    for (i = 0; i < N; i++) {
        int ws = 1 + (rand() % 5);
        int j; for (j = 0; j < ws; j++) buf[j] = " \t\n\v\f\r"[rand() % 6];
        sprintf(buf + ws, "%d", (rand() % 2 ? 1 : -1) * (rand() % 10000));
        expected = atoi(buf); got = ft_atoi(buf);
        if (got != expected) { ok = 0; break; }
    }
    if (ok) printf("PASS BILLION_WASTED\n");
    else printf("FAIL BILLION_WASTED\n>%d\n<%d\n", expected, got);

    /* FUNDING_WEAPONS: number followed by junk */
    ok = 1;
    for (i = 0; i < N; i++) {
        int v = rand() % 10000;
        sprintf(buf, "%dabc%d", v, rand());
        expected = atoi(buf); got = ft_atoi(buf);
        if (got != expected) { ok = 0; break; }
    }
    if (ok) printf("PASS FUNDING_WEAPONS\n");
    else printf("FAIL FUNDING_WEAPONS\n>%d\n<%d\n", expected, got);

    /* DEFICIT_MORAL: empty/space/sign-only strings */
    { char *vs[] = {"","   ","+","-","  +","  -","abc","  abc","+-1","--1"};
      ok = 1;
      for (i = 0; i < N; i++) {
        expected = atoi(vs[i]); got = ft_atoi(vs[i]);
        if (got != expected) { ok = 0; break; }
      }
      if (ok) printf("PASS DEFICIT_MORAL\n");
      else printf("FAIL DEFICIT_MORAL\n>%d\n<%d\n", expected, got);
    }

    /* DEATH_TOLL_REAL: double signs should stop */
    { char *ds[] = {"--42","++42","+-42","-+42","--0","++0","+-0","-+0","---1","+++1"};
      ok = 1;
      for (i = 0; i < N; i++) {
        expected = atoi(ds[i]); got = ft_atoi(ds[i]);
        if (got != expected) { ok = 0; break; }
      }
      if (ok) printf("PASS DEATH_TOLL_REAL\n");
      else printf("FAIL DEATH_TOLL_REAL\n>%d\n<%d\n", expected, got);
    }

    /* COST_OF_WAR: INT_MAX and INT_MIN */
    { char *es[] = {"2147483647","-2147483648","2147483646","-2147483647","1000000000",
                    "-1000000000","999999999","-999999999","2000000000","-2000000000"};
      ok = 1;
      for (i = 0; i < N; i++) {
        expected = atoi(es[i]); got = ft_atoi(es[i]);
        if (got != expected) { ok = 0; break; }
      }
      if (ok) printf("PASS COST_OF_WAR\n");
      else printf("FAIL COST_OF_WAR\n>%d\n<%d\n", expected, got);
    }

    /* GDP_BLOOD: 10 fully random format strings */
    ok = 1;
    for (i = 0; i < N; i++) {
        int ws = rand() % 4;
        int j; for (j = 0; j < ws; j++) buf[j] = " \t\n"[rand() % 3];
        int sign = rand() % 3; /* 0=none, 1=+, 2=- */
        if (sign == 1) buf[ws++] = '+';
        else if (sign == 2) buf[ws++] = '-';
        sprintf(buf + ws, "%d", rand() % 100000);
        expected = atoi(buf); got = ft_atoi(buf);
        if (got != expected) { ok = 0; break; }
    }
    if (ok) printf("PASS GDP_BLOOD\n");
    else printf("FAIL GDP_BLOOD\n>%d\n<%d\n", expected, got);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_atoi.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
