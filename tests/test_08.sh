#!/bin/bash
# Test 08: ft_split — 10 tests randomises, 10 iterations chacun
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_split --${RESET}"

if [ ! -f "$RENDU/ft_split.c" ]; then
    echo -e "  ${RED}Fichier ft_split.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

char **ft_split(char *str, char *charset);

static int in_charset(char c, char *cs) {
    while (*cs) { if (*cs == c) return 1; cs++; }
    return 0;
}

/* Reference split: returns pipe-separated string of words */
static void ref_split(char *str, char *cs, char *out) {
    int oi = 0, first = 1;
    while (*str) {
        if (in_charset(*str, cs)) { str++; continue; }
        if (!first) out[oi++] = '|';
        first = 0;
        while (*str && !in_charset(*str, cs))
            out[oi++] = *str++;
    }
    out[oi] = 0;
}

static void join(char **arr, char *out) {
    int oi = 0, first = 1, i = 0;
    if (!arr) { out[0] = 0; return; }
    while (arr[i]) {
        if (!first) out[oi++] = '|';
        first = 0;
        int j = 0;
        while (arr[i][j]) out[oi++] = arr[i][j++];
        i++;
    }
    out[oi] = 0;
}

static void free_split(char **arr) {
    if (!arr) return;
    int i = 0;
    while (arr[i]) free(arr[i++]);
    free(arr);
}

#define N 10

int main(void) {
    srand(time(NULL));
    int i, j, ok, len;
    char buf[512], cs[64], expected[1024], got_s[1024];
    char **r;

    /* BASIC_SPLIT: split by space, random words */
    ok = 1;
    for (i = 0; i < N; i++) {
        int nw = 2 + (rand() % 4);
        buf[0] = 0;
        for (j = 0; j < nw; j++) {
            if (j > 0) { int sp = 1 + (rand() % 3); for (int k = 0; k < sp; k++) strcat(buf, " "); }
            char w[16]; int wl = 2 + (rand() % 6);
            for (int k = 0; k < wl; k++) w[k] = 'a' + (rand() % 26); w[wl] = 0;
            strcat(buf, w);
        }
        ref_split(buf, " ", expected);
        r = ft_split(buf, " "); join(r, got_s); free_split(r);
        if (strcmp(expected, got_s) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS BASIC_SPLIT\n");
    else printf("FAIL BASIC_SPLIT\n>%s\n<%s\n", expected, got_s);

    /* MULTIPLE_SEPARATORS: split by *, lots of consecutive seps */
    ok = 1;
    for (i = 0; i < N; i++) {
        buf[0] = 0;
        for (j = 0; j < 3; j++) {
            int sp = 1 + (rand() % 5); for (int k = 0; k < sp; k++) strcat(buf, "*");
            char w[8]; int wl = 2 + (rand() % 4);
            for (int k = 0; k < wl; k++) w[k] = 'a' + (rand() % 26); w[wl] = 0;
            strcat(buf, w);
        }
        int sp = rand() % 4; for (j = 0; j < sp; j++) strcat(buf, "*");
        ref_split(buf, "*", expected);
        r = ft_split(buf, "*"); join(r, got_s); free_split(r);
        if (strcmp(expected, got_s) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS MULTIPLE_SEPARATORS\n");
    else printf("FAIL MULTIPLE_SEPARATORS\n>%s\n<%s\n", expected, got_s);

    /* EMPTY_CHARSET: empty charset -> whole string as one word */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 3 + (rand() % 10);
        for (j = 0; j < len; j++) buf[j] = 'a' + (rand() % 26); buf[len] = 0;
        ref_split(buf, "", expected);
        r = ft_split(buf, ""); join(r, got_s); free_split(r);
        if (strcmp(expected, got_s) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS EMPTY_CHARSET\n");
    else printf("FAIL EMPTY_CHARSET\n>%s\n<%s\n", expected, got_s);

    /* CONSECUTIVE_SEPS: multiple delimiter characters */
    ok = 1;
    for (i = 0; i < N; i++) {
        strcpy(buf, "");
        for (j = 0; j < 4; j++) {
            if (j > 0) { char d = ",;:"[rand() % 3]; char ds[2] = {d, 0}; strcat(buf, ds); }
            char w[8]; int wl = 2 + (rand() % 5);
            for (int k = 0; k < wl; k++) w[k] = 'a' + (rand() % 26); w[wl] = 0;
            strcat(buf, w);
        }
        ref_split(buf, ",;:", expected);
        r = ft_split(buf, ",;:"); join(r, got_s); free_split(r);
        if (strcmp(expected, got_s) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS CONSECUTIVE_SEPS\n");
    else printf("FAIL CONSECUTIVE_SEPS\n>%s\n<%s\n", expected, got_s);

    /* ONLY_SEPARATORS: only separators -> empty result */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 3 + (rand() % 10);
        char sep = "*+#"[rand() % 3];
        for (j = 0; j < len; j++) buf[j] = sep; buf[len] = 0;
        char css[2] = {sep, 0};
        r = ft_split(buf, css); join(r, got_s); free_split(r);
        if (strlen(got_s) != 0) { ok = 0; strcpy(expected, ""); break; }
    }
    if (ok) printf("PASS ONLY_SEPARATORS\n");
    else printf("FAIL ONLY_SEPARATORS\n>(empty)\n<%s\n", got_s);

    /* EMPTY_STRING_SPLIT: empty string */
    ok = 1;
    for (i = 0; i < N; i++) {
        r = ft_split("", " "); join(r, got_s); free_split(r);
        if (strlen(got_s) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS EMPTY_STRING_SPLIT\n");
    else printf("FAIL EMPTY_STRING_SPLIT\n>(empty)\n<%s\n", got_s);

    /* LEADING_TRAILING_SEPS: seps at beginning and end */
    ok = 1;
    for (i = 0; i < N; i++) {
        buf[0] = 0;
        int pre = 1 + (rand() % 3); for (j = 0; j < pre; j++) strcat(buf, " ");
        char w[8]; int wl = 3 + (rand() % 5);
        for (j = 0; j < wl; j++) w[j] = 'a' + (rand() % 26); w[wl] = 0;
        strcat(buf, w);
        int post = 1 + (rand() % 3); for (j = 0; j < post; j++) strcat(buf, " ");
        ref_split(buf, " ", expected);
        r = ft_split(buf, " "); join(r, got_s); free_split(r);
        if (strcmp(expected, got_s) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS LEADING_TRAILING_SEPS\n");
    else printf("FAIL LEADING_TRAILING_SEPS\n>%s\n<%s\n", expected, got_s);

    /* TAB_SEPS: split by tab */
    ok = 1;
    for (i = 0; i < N; i++) {
        buf[0] = 0;
        for (j = 0; j < 3; j++) {
            if (j > 0) strcat(buf, "\t");
            char w[8]; int wl = 2 + (rand() % 5);
            for (int k = 0; k < wl; k++) w[k] = 'a' + (rand() % 26); w[wl] = 0;
            strcat(buf, w);
        }
        ref_split(buf, "\t", expected);
        r = ft_split(buf, "\t"); join(r, got_s); free_split(r);
        if (strcmp(expected, got_s) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS TAB_SEPS\n");
    else printf("FAIL TAB_SEPS\n>%s\n<%s\n", expected, got_s);

    /* NO_SEPS_IN_STRING: no separator in string */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 3 + (rand() % 10);
        for (j = 0; j < len; j++) buf[j] = 'a' + (rand() % 26); buf[len] = 0;
        ref_split(buf, " ", expected);
        r = ft_split(buf, " "); join(r, got_s); free_split(r);
        if (strcmp(expected, got_s) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS NO_SEPS_IN_STRING\n");
    else printf("FAIL NO_SEPS_IN_STRING\n>%s\n<%s\n", expected, got_s);

    /* RANDOM_SPLIT: fully random strings and charsets */
    ok = 1;
    for (i = 0; i < N; i++) {
        len = 5 + (rand() % 30);
        char pool[] = "abcde ,.;:*";
        for (j = 0; j < len; j++) buf[j] = pool[rand() % (int)strlen(pool)]; buf[len] = 0;
        strcpy(cs, " ,");
        ref_split(buf, cs, expected);
        r = ft_split(buf, cs); join(r, got_s); free_split(r);
        if (strcmp(expected, got_s) != 0) { ok = 0; break; }
    }
    if (ok) printf("PASS RANDOM_SPLIT\n");
    else printf("FAIL RANDOM_SPLIT\n>%s\n<%s\n", expected, got_s);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_split.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
