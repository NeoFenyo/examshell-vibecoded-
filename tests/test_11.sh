#!/bin/bash
# Test 11: vec_dot
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test vec_dot --${RESET}"

if [ ! -f "$RENDU/vec_dot.c" ]; then
    echo -e "  ${RED}Fichier vec_dot.c introuvable${RESET}"
    exit 1
fi

cp "$PROJECT/subjects/includes/vec3.h" "$RENDU/" 2>/dev/null

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "vec3.h"

#define EPS 1e-6
#define N 10
static int feq(double a,double b){return fabs(a-b)<EPS;}

int main(void) {
    srand(time(NULL));
    int i, ok;
    double got, exp;

    /* BASIC_SPLIT */ got=vec_dot(vec3(1,0,0),vec3(0,1,0));
    if(feq(got,0))printf("PASS BASIC_SPLIT\n");else printf("FAIL BASIC_SPLIT\n>0\n<%f\n",got);

    /* MULTIPLE_SEPARATORS */ got=vec_dot(vec3(1,2,3),vec3(4,5,6));
    if(feq(got,32))printf("PASS MULTIPLE_SEPARATORS\n");else printf("FAIL MULTIPLE_SEPARATORS\n>32\n<%f\n",got);

    /* EMPTY_CHARSET */ got=vec_dot(vec3(1,0,0),vec3(1,0,0));
    if(feq(got,1))printf("PASS EMPTY_CHARSET\n");else printf("FAIL EMPTY_CHARSET\n>1\n<%f\n",got);

    /* CONSECUTIVE_SEPS */ got=vec_dot(vec3(0,0,0),vec3(1,2,3));
    if(feq(got,0))printf("PASS CONSECUTIVE_SEPS\n");else printf("FAIL CONSECUTIVE_SEPS\n>0\n<%f\n",got);

    /* ONLY_SEPARATORS */ got=vec_dot(vec3(1,1,1),vec3(-1,-1,-1));
    if(feq(got,-3))printf("PASS ONLY_SEPARATORS\n");else printf("FAIL ONLY_SEPARATORS\n>-3\n<%f\n",got);

    /* EMPTY_STRING_SPLIT */ got=vec_dot(vec3(3,4,0),vec3(3,4,0));
    if(feq(got,25))printf("PASS EMPTY_STRING_SPLIT\n");else printf("FAIL EMPTY_STRING_SPLIT\n>25\n<%f\n",got);

    /* LEADING_TRAILING_SEPS */ got=vec_dot(vec3(0.5,0.5,0.5),vec3(2,2,2));
    if(feq(got,3))printf("PASS LEADING_TRAILING_SEPS\n");else printf("FAIL LEADING_TRAILING_SEPS\n>3\n<%f\n",got);

    /* TAB_SEPS */
    ok=1;for(i=0;i<N;i++){double a1=(rand()%200-100)/10.0,a2=(rand()%200-100)/10.0,a3=(rand()%200-100)/10.0;
    double b1=(rand()%200-100)/10.0,b2=(rand()%200-100)/10.0,b3=(rand()%200-100)/10.0;
    exp=a1*b1+a2*b2+a3*b3;got=vec_dot(vec3(a1,a2,a3),vec3(b1,b2,b3));if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS TAB_SEPS\n");else printf("FAIL TAB_SEPS\n>%f\n<%f\n",exp,got);

    /* NO_SEPS_IN_STRING */ got=vec_dot(vec3(1,0,0),vec3(-1,0,0));
    if(feq(got,-1))printf("PASS NO_SEPS_IN_STRING\n");else printf("FAIL NO_SEPS_IN_STRING\n>-1\n<%f\n",got);

    /* RANDOM_SPLIT */ got=vec_dot(vec3(0.577,0.577,0.577),vec3(0.577,0.577,0.577));
    if(fabs(got-0.999507)<0.001)printf("PASS RANDOM_SPLIT\n");else printf("FAIL RANDOM_SPLIT\n>~1\n<%f\n",got);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/vec_dot.c" "$RENDU/vec_create.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
