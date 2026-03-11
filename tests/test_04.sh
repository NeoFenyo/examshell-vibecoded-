#!/bin/bash
# Test 04: ft_atof
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_atof --${RESET}"

if [ ! -f "$RENDU/ft_atof.c" ]; then
    echo -e "  ${RED}Fichier ft_atof.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

double ft_atof(const char *str);

#define EPS 1e-6
static int feq(double a, double b) { return fabs(a - b) < EPS; }

int main(void) {
    srand(time(NULL));
    int i, ok;
    double got, exp;

    /* NORMAL_STRING */
    {char *ts[]={"3.14","0.5","1.0","100.0","0.001","99.99","42.42","0.0","1.23456","9.9"};
    ok=1;for(i=0;i<10;i++){exp=atof(ts[i]);got=ft_atof(ts[i]);if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS NORMAL_STRING\n");else printf("FAIL NORMAL_STRING\n>%f\n<%f\n",exp,got);}

    /* LEADING_SPACES */
    {char *ts[]={"-3.14","-0.5","-1.0","-100.0","-0.001","-99.99","-42.42","-0.0","-1.23","-9.9"};
    ok=1;for(i=0;i<10;i++){exp=atof(ts[i]);got=ft_atof(ts[i]);if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS LEADING_SPACES\n");else printf("FAIL LEADING_SPACES\n>%f\n<%f\n",exp,got);}

    /* MULTIPLE_WORDS */
    {char *ts[]={"42","0","100","-42","+100","-0","999","+1","-1","12345"};
    ok=1;for(i=0;i<10;i++){exp=atof(ts[i]);got=ft_atof(ts[i]);if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS MULTIPLE_WORDS\n");else printf("FAIL MULTIPLE_WORDS\n>%f\n<%f\n",exp,got);}

    /* TRAILING_SPACES */
    {char *ts[]={".5",".25",".1",".01",".001","-.5","-.25","+.5","+.1","+.01"};
    ok=1;for(i=0;i<10;i++){exp=atof(ts[i]);got=ft_atof(ts[i]);if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS TRAILING_SPACES\n");else printf("FAIL TRAILING_SPACES\n>%f\n<%f\n",exp,got);}

    /* MIXED_TABS_SPACES */
    {char *ts[]={"  3.14"," +42.0","\t-1.5","  0.0","  100"," \t+.5","\t\t-99","  .25","   42","  +0"};
    ok=1;for(i=0;i<10;i++){exp=atof(ts[i]);got=ft_atof(ts[i]);if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS MIXED_TABS_SPACES\n");else printf("FAIL MIXED_TABS_SPACES\n>%f\n<%f\n",exp,got);}

    /* ONLY_TABS */
    {char *ts[]={"1.2abc","42xyz","3.14 5","-1.0!","0.5,2","100$","99.a",".5b","1.","2."};
    ok=1;for(i=0;i<10;i++){exp=atof(ts[i]);got=ft_atof(ts[i]);if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS ONLY_TABS\n");else printf("FAIL ONLY_TABS\n>%f\n<%f\n",exp,got);}

    /* LONE_WORD */
    ok=1;got=ft_atof("");if(!feq(got,0.0)){ok=0;}
    if(ok){got=ft_atof("abc");if(!feq(got,0.0))ok=0;}
    if(ok){got=ft_atof("   ");if(!feq(got,0.0))ok=0;}
    if(ok)printf("PASS LONE_WORD\n");else printf("FAIL LONE_WORD\n>0.0\n<%f\n",got);

    /* PUNCTUATION_WORD */
    {char *ts[]={"+3.14","+0.5","+1.0","+100.0","+0.001","+99.99","+42.42","+0.0","+1.23","+9.9"};
    ok=1;for(i=0;i<10;i++){exp=atof(ts[i]);got=ft_atof(ts[i]);if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS PUNCTUATION_WORD\n");else printf("FAIL PUNCTUATION_WORD\n>%f\n<%f\n",exp,got);}

    /* NO_ARGS */
    {char *ts[]={"0.123456","1.000001","99.999999","0.000001","-0.000001","3.141592","2.718281","1.414213","0.577215","1.618033"};
    ok=1;for(i=0;i<10;i++){exp=atof(ts[i]);got=ft_atof(ts[i]);if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS NO_ARGS\n");else printf("FAIL NO_ARGS\n>%f\n<%f\n",exp,got);}

    /* WEIRD_CHARS */
    ok=1;
    {char buf[64];for(i=0;i<10;i++){int n=rand()%1000;int d=rand()%10000;sprintf(buf,"%d.%04d",n,d);exp=atof(buf);got=ft_atof(buf);if(!feq(got,exp)){ok=0;break;}}}
    if(ok)printf("PASS WEIRD_CHARS\n");else printf("FAIL WEIRD_CHARS\n>%f\n<%f\n",exp,got);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_atof.c" "$MAIN" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
