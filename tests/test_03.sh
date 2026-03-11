#!/bin/bash
# Test 03: ft_atoi
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

    /* ZERO_VARIANTS */
    {char *zs[]={"0","+0","-0","  0"," +0"," -0","  \t0","000","+000","-000"};
    ok=1;for(i=0;i<N;i++){got=ft_atoi(zs[i]);expected=atoi(zs[i]);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS ZERO_VARIANTS\n");else printf("FAIL ZERO_VARIANTS\n>%d\n<%d\n",expected,got);}

    /* POSITIVE_NUMBERS */
    ok=1;for(i=0;i<N;i++){sprintf(buf,"%d",rand()%100000);expected=atoi(buf);got=ft_atoi(buf);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS POSITIVE_NUMBERS\n");else printf("FAIL POSITIVE_NUMBERS\n>%d\n<%d\n",expected,got);

    /* NEGATIVE_NUMBERS */
    ok=1;for(i=0;i<N;i++){sprintf(buf,"-%d",1+(rand()%100000));expected=atoi(buf);got=ft_atoi(buf);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS NEGATIVE_NUMBERS\n");else printf("FAIL NEGATIVE_NUMBERS\n>%d\n<%d\n",expected,got);

    /* PLUS_PREFIX */
    ok=1;for(i=0;i<N;i++){sprintf(buf,"+%d",rand()%100000);expected=atoi(buf);got=ft_atoi(buf);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS PLUS_PREFIX\n");else printf("FAIL PLUS_PREFIX\n>%d\n<%d\n",expected,got);

    /* LEADING_WHITESPACE */
    ok=1;for(i=0;i<N;i++){int ws=1+(rand()%5);int j;for(j=0;j<ws;j++)buf[j]=" \t\n\v\f\r"[rand()%6];sprintf(buf+ws,"%d",(rand()%2?1:-1)*(rand()%10000));expected=atoi(buf);got=ft_atoi(buf);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS LEADING_WHITESPACE\n");else printf("FAIL LEADING_WHITESPACE\n>%d\n<%d\n",expected,got);

    /* TRAILING_JUNK */
    ok=1;for(i=0;i<N;i++){int v=rand()%10000;sprintf(buf,"%dabc%d",v,rand());expected=atoi(buf);got=ft_atoi(buf);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS TRAILING_JUNK\n");else printf("FAIL TRAILING_JUNK\n>%d\n<%d\n",expected,got);

    /* INVALID_INPUTS */
    {char *vs[]={"","   ","+","-","  +","  -","abc","  abc","+-1","--1"};
    ok=1;for(i=0;i<N;i++){expected=atoi(vs[i]);got=ft_atoi(vs[i]);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS INVALID_INPUTS\n");else printf("FAIL INVALID_INPUTS\n>%d\n<%d\n",expected,got);}

    /* DOUBLE_SIGNS */
    {char *ds[]={"--42","++42","+-42","-+42","--0","++0","+-0","-+0","---1","+++1"};
    ok=1;for(i=0;i<N;i++){expected=atoi(ds[i]);got=ft_atoi(ds[i]);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS DOUBLE_SIGNS\n");else printf("FAIL DOUBLE_SIGNS\n>%d\n<%d\n",expected,got);}

    /* EDGE_LIMITS */
    {char *es[]={"2147483647","-2147483648","2147483646","-2147483647","1000000000","-1000000000","999999999","-999999999","2000000000","-2000000000"};
    ok=1;for(i=0;i<N;i++){expected=atoi(es[i]);got=ft_atoi(es[i]);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS EDGE_LIMITS\n");else printf("FAIL EDGE_LIMITS\n>%d\n<%d\n",expected,got);}

    /* RANDOM_FORMAT_STRING */
    ok=1;for(i=0;i<N;i++){int ws=rand()%4;int j;for(j=0;j<ws;j++)buf[j]=" \t\n"[rand()%3];int sign=rand()%3;if(sign==1)buf[ws++]='+';else if(sign==2)buf[ws++]='-';sprintf(buf+ws,"%d",rand()%100000);expected=atoi(buf);got=ft_atoi(buf);if(got!=expected){ok=0;break;}}
    if(ok)printf("PASS RANDOM_FORMAT_STRING\n");else printf("FAIL RANDOM_FORMAT_STRING\n>%d\n<%d\n",expected,got);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_atoi.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
