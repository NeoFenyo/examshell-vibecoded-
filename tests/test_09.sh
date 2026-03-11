#!/bin/bash
# Test 09: vec_create
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test vec_create --${RESET}"

if [ ! -f "$RENDU/vec_create.c" ]; then
    echo -e "  ${RED}Fichier vec_create.c introuvable${RESET}"
    exit 1
fi

# Copy header to rendu
cp "$PROJECT/subjects/includes/vec3.h" "$RENDU/" 2>/dev/null

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "vec3.h"

#define EPS 1e-9
#define N 10
static int feq(double a,double b){return fabs(a-b)<EPS;}

int main(void) {
    srand(time(NULL));
    int i, ok;
    t_vec3 v;

    /* BASIC_RANGE */
    v=vec3(0,0,0);
    if(feq(v.x,0)&&feq(v.y,0)&&feq(v.z,0))printf("PASS BASIC_RANGE\n");
    else printf("FAIL BASIC_RANGE\n>0 0 0\n<%f %f %f\n",v.x,v.y,v.z);

    /* NEGATIVE_RANGE */
    v=vec3(1,2,3);
    if(feq(v.x,1)&&feq(v.y,2)&&feq(v.z,3))printf("PASS NEGATIVE_RANGE\n");
    else printf("FAIL NEGATIVE_RANGE\n>1 2 3\n<%f %f %f\n",v.x,v.y,v.z);

    /* ZERO_CROSS_RANGE */
    ok=1;for(i=0;i<N;i++){double x=(rand()%2000-1000)/10.0,y=(rand()%2000-1000)/10.0,z=(rand()%2000-1000)/10.0;
    v=vec3(x,y,z);if(!feq(v.x,x)||!feq(v.y,y)||!feq(v.z,z)){ok=0;break;}}
    if(ok)printf("PASS ZERO_CROSS_RANGE\n");else printf("FAIL ZERO_CROSS_RANGE\n>random values\n<mismatch\n");

    /* INVALID_MIN_MAX */
    v=vec3(-1,-2,-3);
    if(feq(v.x,-1)&&feq(v.y,-2)&&feq(v.z,-3))printf("PASS INVALID_MIN_MAX\n");
    else printf("FAIL INVALID_MIN_MAX\n>-1 -2 -3\n<%f %f %f\n",v.x,v.y,v.z);

    /* EMPTY_RANGE */
    v=vec3(3.14,2.71,1.41);
    if(feq(v.x,3.14)&&feq(v.y,2.71)&&feq(v.z,1.41))printf("PASS EMPTY_RANGE\n");
    else printf("FAIL EMPTY_RANGE\n>3.14 2.71 1.41\n<%f %f %f\n",v.x,v.y,v.z);

    /* SINGLE_ELEM_RANGE */
    v=vec3(1e10,-1e10,1e-10);
    if(feq(v.x,1e10)&&feq(v.y,-1e10)&&feq(v.z,1e-10))printf("PASS SINGLE_ELEM_RANGE\n");
    else printf("FAIL SINGLE_ELEM_RANGE\n>extreme values\n<%f %f %f\n",v.x,v.y,v.z);

    /* LARGE_RANGE */
    ok=1;for(i=0;i<N;i++){v=vec3(i,i*2,i*3);if(!feq(v.x,i)||!feq(v.y,i*2)||!feq(v.z,i*3)){ok=0;break;}}
    if(ok)printf("PASS LARGE_RANGE\n");else printf("FAIL LARGE_RANGE\n>sequential\n<mismatch\n");

    /* SAME_BOUNDS */
    v=vec3(0.5,0.5,0.5);
    if(feq(v.x,0.5)&&feq(v.y,0.5)&&feq(v.z,0.5))printf("PASS SAME_BOUNDS\n");
    else printf("FAIL SAME_BOUNDS\n>0.5 0.5 0.5\n<%f %f %f\n",v.x,v.y,v.z);

    /* RANDOM_BOUNDS */
    v=vec3(-0.001,0.001,-0.001);
    if(feq(v.x,-0.001)&&feq(v.y,0.001)&&feq(v.z,-0.001))printf("PASS RANDOM_BOUNDS\n");
    else printf("FAIL RANDOM_BOUNDS\n>small values\n<%f %f %f\n",v.x,v.y,v.z);

    /* MIXED_BOUNDS */
    ok=1;for(i=0;i<N;i++){double x=rand()/(double)RAND_MAX,y=rand()/(double)RAND_MAX,z=rand()/(double)RAND_MAX;
    v=vec3(x,y,z);if(!feq(v.x,x)||!feq(v.y,y)||!feq(v.z,z)){ok=0;break;}}
    if(ok)printf("PASS MIXED_BOUNDS\n");else printf("FAIL MIXED_BOUNDS\n>random doubles\n<mismatch\n");

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/vec_create.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
