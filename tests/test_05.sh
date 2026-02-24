#!/bin/bash
# Test 05: ft_strrev — 10 tests randomises, 10 iterations chacun
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_strrev --${RESET}"

if [ ! -f "$RENDU/ft_strrev.c" ]; then
    echo -e "  ${RED}Fichier ft_strrev.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

char *ft_strrev(char *str);

#define N 10

static void rev(char *s, char *out) {
    int len = strlen(s), i;
    for (i = 0; i < len; i++) out[i] = s[len - 1 - i];
    out[len] = 0;
}

int main(void) {
    srand(time(NULL));
    int i, j, ok, len;
    char buf[512], expected[512], *ret;

    /* HISTORY_REWRITE: 10 random words reversed */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 3 + (rand() % 10);
        for (j = 0; j < len; j++) buf[j] = 'a' + (rand() % 26);
        buf[len] = 0;
        rev(buf, expected);
        char copy[512]; strcpy(copy, buf);
        ret = ft_strrev(copy);
        if (strcmp(copy, expected) != 0 || ret != copy) { ok = 0; break; }
    }
    if (ok) printf("PASS HISTORY_REWRITE\n");
    else printf("FAIL HISTORY_REWRITE\n>%s\n<%s\n", expected, ret ? ret : "(null)");

    /* NARRATIVE_FLIP: 10 empty strings */
    ok = 1;
    for (i = 0; i < N; i++) {
        buf[0] = 0;
        ret = ft_strrev(buf);
        if (buf[0] != 0 || ret != buf) { ok = 0; break; }
    }
    if (ok) printf("PASS NARRATIVE_FLIP\n");
    else printf("FAIL NARRATIVE_FLIP\n>(empty)\n<%s\n", ret ? ret : "(null)");

    /* TRUTH_INVERTED: 10 random single chars */
    ok = 1;
    for (i = 0; i < N; i++) {
        buf[0] = 33 + (rand() % 94); buf[1] = 0;
        char save = buf[0];
        ret = ft_strrev(buf);
        if (buf[0] != save || ret != buf) { ok = 0; break; }
    }
    if (ok) printf("PASS TRUTH_INVERTED\n");
    else printf("FAIL TRUTH_INVERTED\n>%c\n<%s\n", buf[0], ret ? ret : "(null)");

    /* FACTS_REVERSED: palindromes should stay the same */
    ok = 1;
    { char *pals[] = {"aba","abcba","racecar","madam","abba","a","aa","aabbaa","abacaba","civic"};
      for (i = 0; i < N; i++) {
        strcpy(buf, pals[i]);
        strcpy(expected, pals[i]);
        ret = ft_strrev(buf);
        if (strcmp(buf, expected) != 0) { ok = 0; break; }
    }}
    if (ok) printf("PASS FACTS_REVERSED\n");
    else printf("FAIL FACTS_REVERSED\n>%s\n<%s\n", expected, buf);

    /* TIMELINE_FAKE: 10 digit strings reversed */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 2 + (rand() % 8);
        for (j = 0; j < len; j++) buf[j] = '0' + (rand() % 10);
        buf[len] = 0;
        rev(buf, expected);
        char copy[512]; strcpy(copy, buf);
        ret = ft_strrev(copy);
        if (strcmp(copy, expected) != 0) { ok = 0; strcpy(buf, copy); break; }
    }
    if (ok) printf("PASS TIMELINE_FAKE\n");
    else printf("FAIL TIMELINE_FAKE\n>%s\n<%s\n", expected, buf);

    /* MAP_DISTORTED: strings with spaces */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 4 + (rand() % 8);
        for (j = 0; j < len; j++) buf[j] = (rand() % 3 == 0) ? ' ' : ('a' + (rand() % 26));
        buf[len] = 0;
        rev(buf, expected);
        char copy[512]; strcpy(copy, buf);
        ret = ft_strrev(copy);
        if (strcmp(copy, expected) != 0) { ok = 0; strcpy(buf, copy); break; }
    }
    if (ok) printf("PASS MAP_DISTORTED\n");
    else printf("FAIL MAP_DISTORTED\n>%s\n<%s\n", expected, buf);

    /* VICTIM_CARD: special char strings */
    ok = 1;
    { char sym[] = "!@#$%^&*()_+-=";
      for (i = 0; i < N; i++) {
        len = 3 + (rand() % 8);
        for (j = 0; j < len; j++) buf[j] = sym[rand() % (int)strlen(sym)];
        buf[len] = 0;
        rev(buf, expected);
        char copy[512]; strcpy(copy, buf);
        ret = ft_strrev(copy);
        if (strcmp(copy, expected) != 0) { ok = 0; strcpy(buf, copy); break; }
    }}
    if (ok) printf("PASS VICTIM_CARD\n");
    else printf("FAIL VICTIM_CARD\n>%s\n<%s\n", expected, buf);

    /* STORY_TWISTED: long strings 50-100 chars */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 50 + (rand() % 51);
        for (j = 0; j < len; j++) buf[j] = 33 + (rand() % 94);
        buf[len] = 0;
        rev(buf, expected);
        char copy[512]; strcpy(copy, buf);
        ret = ft_strrev(copy);
        if (strcmp(copy, expected) != 0) { ok = 0; strcpy(buf, copy); break; }
    }
    if (ok) printf("PASS STORY_TWISTED\n");
    else printf("FAIL STORY_TWISTED\n>%.30s...\n<%.30s...\n", expected, buf);

    /* LOGIC_BROKEN: reverse twice should give original */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 5 + (rand() % 20);
        for (j = 0; j < len; j++) buf[j] = 'a' + (rand() % 26);
        buf[len] = 0;
        strcpy(expected, buf);
        ft_strrev(buf);
        ft_strrev(buf);
        if (strcmp(buf, expected) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS LOGIC_BROKEN\n");
    else printf("FAIL LOGIC_BROKEN\n>%s\n<%s\n", expected, buf);

    /* MEMORY_ERASED: fully random */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 1 + (rand() % 50);
        for (j = 0; j < len; j++) buf[j] = 1 + (rand() % 126);
        buf[len] = 0;
        rev(buf, expected);
        char copy[512]; strcpy(copy, buf);
        ret = ft_strrev(copy);
        if (strcmp(copy, expected) != 0) { ok = 0; strcpy(buf, copy); break; }
    }
    if (ok) printf("PASS MEMORY_ERASED\n");
    else printf("FAIL MEMORY_ERASED\n>%.40s\n<%.40s\n", expected, buf);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_strrev.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
