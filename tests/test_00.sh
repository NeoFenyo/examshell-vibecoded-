#!/bin/bash
# Test 00: ft_putchar — 10 tests randomises, 10 iterations chacun
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_putchar --${RESET}"

if [ ! -f "$RENDU/ft_putchar.c" ]; then
    echo -e "  ${RED}Fichier ft_putchar.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>

void ft_putchar(char c);

#define CAP "/tmp/examshell_cap"
#define N 10

static int sv;
static char cap[4096];
static int cn;

static void cs(void) {
    fflush(stdout); sv = dup(1);
    int fd = open(CAP, O_WRONLY|O_CREAT|O_TRUNC, 0644);
    dup2(fd, 1); close(fd);
}
static void ce(void) {
    fflush(stdout); dup2(sv, 1); close(sv);
    int fd = open(CAP, O_RDONLY);
    cn = read(fd, cap, 4095); if (cn < 0) cn = 0;
    cap[cn] = 0; close(fd);
}
static void show(char *b, int l, char *o) {
    int j = 0;
    for (int i = 0; i < l && j < 200; i++) {
        if (b[i] >= 32 && b[i] < 127) o[j++] = b[i];
        else j += sprintf(o + j, "\\x%02x", (unsigned char)b[i]);
    }
    o[j] = 0;
}
static void test(char *name, char *exp, int elen) {
    char e[256], g[256];
    if (cn == elen && memcmp(cap, exp, elen) == 0)
        printf("PASS %s\n", name);
    else { show(exp, elen, e); show(cap, cn, g); printf("FAIL %s\n>%s\n<%s\n", name, e, g); }
}

int main(void) {
    srand(time(NULL));
    int i; char buf[256];

    /* BASIC_LOWERCASE: 10 random lowercase */
    for (i = 0; i < N; i++) buf[i] = 'a' + (rand() % 26);
    cs(); for (i = 0; i < N; i++) ft_putchar(buf[i]); ce();
    test("BASIC_LOWERCASE", buf, N);

    /* BASIC_DIGITS: 10 random digits */
    for (i = 0; i < N; i++) buf[i] = '0' + (rand() % 10);
    cs(); for (i = 0; i < N; i++) ft_putchar(buf[i]); ce();
    test("BASIC_DIGITS", buf, N);

    /* SPECIAL_CHARS: 10 random special chars */
    { char sp[] = "!@#$%^&*()-_=+[]{}|;:,.<>?/~"; int sl = strlen(sp);
      for (i = 0; i < N; i++) buf[i] = sp[rand() % sl];
      cs(); for (i = 0; i < N; i++) ft_putchar(buf[i]); ce();
      test("SPECIAL_CHARS", buf, N); }

    /* WHITESPACE: 10 random spaces/tabs */
    for (i = 0; i < N; i++) buf[i] = (rand() % 2) ? ' ' : '\t';
    cs(); for (i = 0; i < N; i++) ft_putchar(buf[i]); ce();
    test("WHITESPACE", buf, N);

    /* UPPER_CASE: 10 random uppercase */
    for (i = 0; i < N; i++) buf[i] = 'A' + (rand() % 26);
    cs(); for (i = 0; i < N; i++) ft_putchar(buf[i]); ce();
    test("UPPER_CASE", buf, N);

    /* PRINTABLE_CHARS: 10 random printable */
    for (i = 0; i < N; i++) buf[i] = 33 + (rand() % 94);
    cs(); for (i = 0; i < N; i++) ft_putchar(buf[i]); ce();
    test("PRINTABLE_CHARS", buf, N);

    /* NEWLINES: 10 newlines */
    for (i = 0; i < N; i++) buf[i] = '\n';
    cs(); for (i = 0; i < N; i++) ft_putchar('\n'); ce();
    test("NEWLINES", buf, N);

    /* NULL_BYTES: 10 null bytes */
    for (i = 0; i < N; i++) buf[i] = '\0';
    cs(); for (i = 0; i < N; i++) ft_putchar('\0'); ce();
    if (cn == N) { int ok = 1; for (i = 0; i < N; i++) if (cap[i] != 0) ok = 0;
        if (ok) printf("PASS NULL_BYTES\n");
        else printf("FAIL NULL_BYTES\n>10 null bytes\n<data mismatch (%d bytes)\n", cn);
    } else printf("FAIL NULL_BYTES\n>10 bytes\n<%d bytes\n", cn);

    /* NORM_SCALE_X: all 95 printable ASCII */
    { int elen = 0; for (i = 32; i < 127; i++) buf[elen++] = i;
      cs(); for (i = 32; i < 127; i++) ft_putchar(i); ce();
      if (cn == elen && memcmp(cap, buf, elen) == 0) printf("PASS NORM_SCALE_X\n");
      else printf("FAIL NORM_SCALE_X\n>95 printable chars\n<%d chars\n", cn); }

    /* NORM_NEG_XY: 10 random from 1-126 */
    for (i = 0; i < N; i++) buf[i] = 1 + (rand() % 126);
    cs(); for (i = 0; i < N; i++) ft_putchar(buf[i]); ce();
    test("NORM_NEG_XY", buf, N);

    unlink(CAP);
    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_putchar.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
