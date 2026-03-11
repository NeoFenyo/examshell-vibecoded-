#!/bin/bash
# Test 12: vec_cross
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test vec_cross --${RESET}"

if [ ! -f "$RENDU/vec_cross.c" ]; then
    echo -e "  ${RED}Fichier vec_cross.c introuvable${RESET}"
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
static int veq(t_vec3 a,t_vec3 b){return feq(a.x,b.x)&&feq(a.y,b.y)&&feq(a.z,b.z);}

int main(void) {
    srand(time(NULL));
    int i, ok;
    t_vec3 r, exp;

    /* CROSS_XY */ r=vec_cross(vec3(1,0,0),vec3(0,1,0));
    if(veq(r,vec3(0,0,1)))printf("PASS CROSS_XY\n");else printf("FAIL CROSS_XY\n>0 0 1\n<%f %f %f\n",r.x,r.y,r.z);

    /* CROSS_YX */ r=vec_cross(vec3(0,1,0),vec3(1,0,0));
    if(veq(r,vec3(0,0,-1)))printf("PASS CROSS_YX\n");else printf("FAIL CROSS_YX\n>0 0 -1\n<%f %f %f\n",r.x,r.y,r.z);

    /* CROSS_XZ */ r=vec_cross(vec3(1,0,0),vec3(0,0,1));
    if(veq(r,vec3(0,-1,0)))printf("PASS CROSS_XZ\n");else printf("FAIL CROSS_XZ\n>0 -1 0\n<%f %f %f\n",r.x,r.y,r.z);

    /* CROSS_SELF */ r=vec_cross(vec3(1,0,0),vec3(1,0,0));
    if(veq(r,vec3(0,0,0)))printf("PASS CROSS_SELF\n");else printf("FAIL CROSS_SELF\n>0 0 0\n<%f %f %f\n",r.x,r.y,r.z);

    /* CROSS_ZERO */ r=vec_cross(vec3(0,0,0),vec3(1,2,3));
    if(veq(r,vec3(0,0,0)))printf("PASS CROSS_ZERO\n");else printf("FAIL CROSS_ZERO\n>0 0 0\n<%f %f %f\n",r.x,r.y,r.z);

    /* CROSS_BASIC */ r=vec_cross(vec3(2,3,4),vec3(5,6,7));
    exp=vec3(3*7-4*6,4*5-2*7,2*6-3*5);
    if(veq(r,exp))printf("PASS CROSS_BASIC\n");else printf("FAIL CROSS_BASIC\n>%f %f %f\n<%f %f %f\n",exp.x,exp.y,exp.z,r.x,r.y,r.z);

    /* CROSS_RANDOM */
    ok=1;for(i=0;i<N;i++){double a1=(rand()%200-100)/10.0,a2=(rand()%200-100)/10.0,a3=(rand()%200-100)/10.0;
    double b1=(rand()%200-100)/10.0,b2=(rand()%200-100)/10.0,b3=(rand()%200-100)/10.0;
    exp=vec3(a2*b3-a3*b2,a3*b1-a1*b3,a1*b2-a2*b1);r=vec_cross(vec3(a1,a2,a3),vec3(b1,b2,b3));
    if(!veq(r,exp)){ok=0;break;}}
    if(ok)printf("PASS CROSS_RANDOM\n");else printf("FAIL CROSS_RANDOM\n>random cross\n<mismatch\n");

    /* CROSS_ANTICOMMUTATIVE: cross(a,b) = -cross(b,a) */
    ok=1;for(i=0;i<N;i++){t_vec3 a=vec3((rand()%100)/10.0,(rand()%100)/10.0,(rand()%100)/10.0);
    t_vec3 b=vec3((rand()%100)/10.0,(rand()%100)/10.0,(rand()%100)/10.0);
    t_vec3 ab=vec_cross(a,b);t_vec3 ba=vec_cross(b,a);
    if(!feq(ab.x,-ba.x)||!feq(ab.y,-ba.y)||!feq(ab.z,-ba.z)){ok=0;break;}}
    if(ok)printf("PASS CROSS_ANTICOMMUTATIVE\n");else printf("FAIL CROSS_ANTICOMMUTATIVE\n>anticommutative\n<not anticommutative\n");

    /* CROSS_PERPENDICULAR: cross perpendicular to both */
    ok=1;for(i=0;i<N;i++){t_vec3 a=vec3(1+(rand()%10),1+(rand()%10),1+(rand()%10));
    t_vec3 b=vec3(1+(rand()%10),1+(rand()%10),1+(rand()%10));
    r=vec_cross(a,b);double da=r.x*a.x+r.y*a.y+r.z*a.z;double db=r.x*b.x+r.y*b.y+r.z*b.z;
    if(!feq(da,0)||!feq(db,0)){ok=0;break;}}
    if(ok)printf("PASS CROSS_PERPENDICULAR\n");else printf("FAIL CROSS_PERPENDICULAR\n>perpendicular\n<not perpendicular\n");

    /* CROSS_OPPOSITE */ r=vec_cross(vec3(1,2,3),vec3(-1,-2,-3));
    if(veq(r,vec3(0,0,0)))printf("PASS CROSS_OPPOSITE\n");else printf("FAIL CROSS_OPPOSITE\n>0 0 0\n<%f %f %f\n",r.x,r.y,r.z);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/vec_cross.c" "$RENDU/vec_create.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
