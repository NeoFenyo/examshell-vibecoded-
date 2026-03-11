#!/bin/bash
# Test 13: vec_normalize
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test vec_normalize --${RESET}"

if [ ! -f "$RENDU/vec_normalize.c" ]; then
    echo -e "  ${RED}Fichier vec_normalize.c introuvable${RESET}"
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
    double got;
    t_vec3 v;

    /* BASIC_LOWERCASE */ got=vec_length(vec3(3,4,0));
    if(feq(got,5))printf("PASS BASIC_LOWERCASE\n");else printf("FAIL BASIC_LOWERCASE\n>5\n<%f\n",got);

    /* BASIC_DIGITS */ got=vec_length(vec3(0,0,0));
    if(feq(got,0))printf("PASS BASIC_DIGITS\n");else printf("FAIL BASIC_DIGITS\n>0\n<%f\n",got);

    /* SPECIAL_CHARS */ got=vec_length(vec3(1,1,1));
    if(feq(got,sqrt(3)))printf("PASS SPECIAL_CHARS\n");else printf("FAIL SPECIAL_CHARS\n>%f\n<%f\n",sqrt(3.0),got);

    /* WHITESPACE */ v=vec_normalize(vec3(3,4,0));
    if(feq(v.x,0.6)&&feq(v.y,0.8)&&feq(v.z,0))printf("PASS WHITESPACE\n");
    else printf("FAIL WHITESPACE\n>0.6 0.8 0\n<%f %f %f\n",v.x,v.y,v.z);

    /* UPPER_CASE */ v=vec_normalize(vec3(0,0,0));
    if(feq(v.x,0)&&feq(v.y,0)&&feq(v.z,0))printf("PASS UPPER_CASE\n");
    else printf("FAIL UPPER_CASE\n>0 0 0\n<%f %f %f\n",v.x,v.y,v.z);

    /* PRINTABLE_CHARS */ v=vec_normalize(vec3(1,0,0));
    if(feq(v.x,1)&&feq(v.y,0)&&feq(v.z,0))printf("PASS PRINTABLE_CHARS\n");
    else printf("FAIL PRINTABLE_CHARS\n>1 0 0\n<%f %f %f\n",v.x,v.y,v.z);

    /* NEWLINES: normalized length = 1 */
    ok=1;for(i=0;i<N;i++){double x=1+(rand()%100),y=1+(rand()%100),z=1+(rand()%100);
    v=vec_normalize(vec3(x,y,z));got=sqrt(v.x*v.x+v.y*v.y+v.z*v.z);if(!feq(got,1)){ok=0;break;}}
    if(ok)printf("PASS NEWLINES\n");else printf("FAIL NEWLINES\n>1.0\n<%f\n",got);

    /* NULL_BYTES: length of random vectors */
    ok=1;for(i=0;i<N;i++){double x=(rand()%200-100)/10.0,y=(rand()%200-100)/10.0,z=(rand()%200-100)/10.0;
    double exp=sqrt(x*x+y*y+z*z);got=vec_length(vec3(x,y,z));if(!feq(got,exp)){ok=0;break;}}
    if(ok)printf("PASS NULL_BYTES\n");else printf("FAIL NULL_BYTES\n>random length\n<mismatch\n");

    /* NORM_SCALE_X */ v=vec_normalize(vec3(10,0,0));
    if(feq(v.x,1)&&feq(v.y,0)&&feq(v.z,0))printf("PASS NORM_SCALE_X\n");
    else printf("FAIL NORM_SCALE_X\n>1 0 0\n<%f %f %f\n",v.x,v.y,v.z);

    /* NORM_NEG_XY */ v=vec_normalize(vec3(-3,-4,0));
    if(feq(v.x,-0.6)&&feq(v.y,-0.8)&&feq(v.z,0))printf("PASS NORM_NEG_XY\n");
    else printf("FAIL NORM_NEG_XY\n>-0.6 -0.8 0\n<%f %f %f\n",v.x,v.y,v.z);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/vec_normalize.c" "$RENDU/vec_create.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
