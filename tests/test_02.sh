#!/bin/bash
# Test 02: ft_strlen
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

    /* EMPTY_STRING */
    ok=1;for(i=0;i<N;i++){got=ft_strlen("");if(got!=0){ok=0;break;}}
    if(ok)printf("PASS EMPTY_STRING\n");else printf("FAIL EMPTY_STRING\n>0\n<%d\n",got);

    /* SINGLE_CHAR */
    ok=1;for(i=0;i<N;i++){buf[0]=33+(rand()%94);buf[1]=0;got=ft_strlen(buf);if(got!=1){ok=0;break;}}
    if(ok)printf("PASS SINGLE_CHAR\n");else printf("FAIL SINGLE_CHAR\n>1\n<%d\n",got);

    /* SHORT_STRINGS */
    ok=1;for(i=0;i<N;i++){len=2+(rand()%9);for(j=0;j<len;j++)buf[j]='a'+(rand()%26);buf[len]=0;got=ft_strlen(buf);if(got!=len){ok=0;break;}}
    if(ok)printf("PASS SHORT_STRINGS\n");else printf("FAIL SHORT_STRINGS\n>%d\n<%d\n",len,got);

    /* SPACES_ONLY */
    ok=1;for(i=0;i<N;i++){len=1+(rand()%20);for(j=0;j<len;j++)buf[j]=' ';buf[len]=0;got=ft_strlen(buf);if(got!=len){ok=0;break;}}
    if(ok)printf("PASS SPACES_ONLY\n");else printf("FAIL SPACES_ONLY\n>%d\n<%d\n",len,got);

    /* LONG_STRINGS */
    ok=1;for(i=0;i<N;i++){len=50+(rand()%151);for(j=0;j<len;j++)buf[j]=33+(rand()%94);buf[len]=0;got=ft_strlen(buf);if(got!=len){ok=0;break;}}
    if(ok)printf("PASS LONG_STRINGS\n");else printf("FAIL LONG_STRINGS\n>%d\n<%d\n",len,got);

    /* MIXED_WHITESPACE */
    ok=1;for(i=0;i<N;i++){len=3+(rand()%15);for(j=0;j<len;j++)buf[j]=(rand()%2)?' ':'\t';buf[len]=0;got=ft_strlen(buf);if(got!=len){ok=0;break;}}
    if(ok)printf("PASS MIXED_WHITESPACE\n");else printf("FAIL MIXED_WHITESPACE\n>%d\n<%d\n",len,got);

    /* DIGITS_ONLY */
    ok=1;for(i=0;i<N;i++){len=1+(rand()%30);for(j=0;j<len;j++)buf[j]='0'+(rand()%10);buf[len]=0;got=ft_strlen(buf);if(got!=len){ok=0;break;}}
    if(ok)printf("PASS DIGITS_ONLY\n");else printf("FAIL DIGITS_ONLY\n>%d\n<%d\n",len,got);

    /* SPECIAL_SYMBOLS */
    ok=1;{char sym[]="!@#$%^&*()_+-=";int sl=strlen(sym);
    for(i=0;i<N;i++){len=5+(rand()%20);for(j=0;j<len;j++)buf[j]=sym[rand()%sl];buf[len]=0;got=ft_strlen(buf);if(got!=len){ok=0;break;}}}
    if(ok)printf("PASS SPECIAL_SYMBOLS\n");else printf("FAIL SPECIAL_SYMBOLS\n>%d\n<%d\n",len,got);

    /* ESCAPED_CHARS */
    ok=1;for(i=0;i<N;i++){len=5+(rand()%15);for(j=0;j<len;j++){int r=rand()%4;if(r==0)buf[j]='\t';else if(r==1)buf[j]='\n';else buf[j]='a'+(rand()%26);}buf[len]=0;got=ft_strlen(buf);if(got!=len){ok=0;break;}}
    if(ok)printf("PASS ESCAPED_CHARS\n");else printf("FAIL ESCAPED_CHARS\n>%d\n<%d\n",len,got);

    /* RANDOM_PRINTABLE */
    ok=1;for(i=0;i<N;i++){len=1+(rand()%500);for(j=0;j<len;j++)buf[j]=1+(rand()%126);buf[len]=0;got=ft_strlen(buf);if(got!=len){ok=0;break;}}
    if(ok)printf("PASS RANDOM_PRINTABLE\n");else printf("FAIL RANDOM_PRINTABLE\n>%d\n<%d\n",len,got);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_strlen.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
