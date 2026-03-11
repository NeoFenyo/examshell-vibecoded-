#!/bin/bash
# Test 10: vec_ops (add, sub, scale)
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test vec_ops --${RESET}"

if [ ! -f "$RENDU/vec_ops.c" ]; then
    echo -e "  ${RED}Fichier vec_ops.c introuvable${RESET}"
    exit 1
fi

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
static int veq(t_vec3 a,t_vec3 b){return feq(a.x,b.x)&&feq(a.y,b.y)&&feq(a.z,b.z);}

int main(void) {
    srand(time(NULL));
    int i, ok;
    t_vec3 r;

    /* ADD_BASIC */ r=vec_add(vec3(1,2,3),vec3(4,5,6));
    if(veq(r,vec3(5,7,9)))printf("PASS ADD_BASIC\n");else printf("FAIL ADD_BASIC\n>5 7 9\n<%f %f %f\n",r.x,r.y,r.z);

    /* SUB_BASIC */ r=vec_sub(vec3(5,5,5),vec3(1,2,3));
    if(veq(r,vec3(4,3,2)))printf("PASS SUB_BASIC\n");else printf("FAIL SUB_BASIC\n>4 3 2\n<%f %f %f\n",r.x,r.y,r.z);

    /* SCALE_BASIC */ r=vec_scale(vec3(1,2,3),2.0);
    if(veq(r,vec3(2,4,6)))printf("PASS SCALE_BASIC\n");else printf("FAIL SCALE_BASIC\n>2 4 6\n<%f %f %f\n",r.x,r.y,r.z);

    /* ADD_ZEROS */ r=vec_add(vec3(0,0,0),vec3(0,0,0));
    if(veq(r,vec3(0,0,0)))printf("PASS ADD_ZEROS\n");else printf("FAIL ADD_ZEROS\n>0 0 0\n<%f %f %f\n",r.x,r.y,r.z);

    /* SCALE_ZERO */ r=vec_scale(vec3(1,2,3),0);
    if(veq(r,vec3(0,0,0)))printf("PASS SCALE_ZERO\n");else printf("FAIL SCALE_ZERO\n>0 0 0\n<%f %f %f\n",r.x,r.y,r.z);

    /* SUB_SELF */ r=vec_sub(vec3(1,1,1),vec3(1,1,1));
    if(veq(r,vec3(0,0,0)))printf("PASS SUB_SELF\n");else printf("FAIL SUB_SELF\n>0 0 0\n<%f %f %f\n",r.x,r.y,r.z);

    /* SCALE_NEGATIVE */ r=vec_scale(vec3(1,2,3),-1);
    if(veq(r,vec3(-1,-2,-3)))printf("PASS SCALE_NEGATIVE\n");else printf("FAIL SCALE_NEGATIVE\n>-1 -2 -3\n<%f %f %f\n",r.x,r.y,r.z);

    /* ADD_RANDOM */
    ok=1;for(i=0;i<N;i++){double a1=(rand()%200-100)/10.0,a2=(rand()%200-100)/10.0,a3=(rand()%200-100)/10.0;
    double b1=(rand()%200-100)/10.0,b2=(rand()%200-100)/10.0,b3=(rand()%200-100)/10.0;
    r=vec_add(vec3(a1,a2,a3),vec3(b1,b2,b3));if(!veq(r,vec3(a1+b1,a2+b2,a3+b3))){ok=0;break;}}
    if(ok)printf("PASS ADD_RANDOM\n");else printf("FAIL ADD_RANDOM\n>random add\n<mismatch\n");

    /* SUB_RANDOM */
    ok=1;for(i=0;i<N;i++){double a1=(rand()%200-100)/10.0,a2=(rand()%200-100)/10.0,a3=(rand()%200-100)/10.0;
    double b1=(rand()%200-100)/10.0,b2=(rand()%200-100)/10.0,b3=(rand()%200-100)/10.0;
    r=vec_sub(vec3(a1,a2,a3),vec3(b1,b2,b3));if(!veq(r,vec3(a1-b1,a2-b2,a3-b3))){ok=0;break;}}
    if(ok)printf("PASS SUB_RANDOM\n");else printf("FAIL SUB_RANDOM\n>random sub\n<mismatch\n");

    /* SCALE_RANDOM */
    ok=1;for(i=0;i<N;i++){double x=(rand()%200-100)/10.0,y=(rand()%200-100)/10.0,z=(rand()%200-100)/10.0;
    double t=(rand()%100)/10.0;r=vec_scale(vec3(x,y,z),t);if(!veq(r,vec3(x*t,y*t,z*t))){ok=0;break;}}
    if(ok)printf("PASS SCALE_RANDOM\n");else printf("FAIL SCALE_RANDOM\n>random scale\n<mismatch\n");

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/vec_ops.c" "$RENDU/vec_create.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
