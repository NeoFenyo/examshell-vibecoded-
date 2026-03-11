#!/bin/bash
# Test 18: ray_at
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ray_at --${RESET}"

if [ ! -f "$RENDU/ray_at.c" ]; then
    echo -e "  ${RED}Fichier ray_at.c introuvable${RESET}"
    exit 1
fi

cp "$PROJECT/subjects/includes/vec3.h" "$RENDU/" 2>/dev/null
cp "$PROJECT/subjects/includes/ray.h" "$RENDU/" 2>/dev/null

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "ray.h"

#define EPS 1e-6
#define N 10
static int feq(double a,double b){return fabs(a-b)<EPS;}
static int veq(t_vec3 a,t_vec3 b){return feq(a.x,b.x)&&feq(a.y,b.y)&&feq(a.z,b.z);}

int main(void) {
    srand(time(NULL));
    int i, ok;
    t_ray r;
    t_vec3 p;

    r=ray_create(vec3(0,0,0),vec3(1,0,0));

    /* BASIC_DUP */ p=ray_at(r,5);
    if(veq(p,vec3(5,0,0)))printf("PASS BASIC_DUP\n");else printf("FAIL BASIC_DUP\n>5 0 0\n<%f %f %f\n",p.x,p.y,p.z);

    /* EMPTY_DUP */ p=ray_at(r,0);
    if(veq(p,vec3(0,0,0)))printf("PASS EMPTY_DUP\n");else printf("FAIL EMPTY_DUP\n>0 0 0\n<%f %f %f\n",p.x,p.y,p.z);

    /* SINGLE_CHAR_DUP */ p=ray_at(r,-1);
    if(veq(p,vec3(-1,0,0)))printf("PASS SINGLE_CHAR_DUP\n");else printf("FAIL SINGLE_CHAR_DUP\n>-1 0 0\n<%f %f %f\n",p.x,p.y,p.z);

    r=ray_create(vec3(1,2,3),vec3(0,0,-1));

    /* LONG_STRING_DUP */ p=ray_at(r,5);
    if(veq(p,vec3(1,2,-2)))printf("PASS LONG_STRING_DUP\n");else printf("FAIL LONG_STRING_DUP\n>1 2 -2\n<%f %f %f\n",p.x,p.y,p.z);

    /* SPACE_DUP */ p=ray_at(r,0);
    if(veq(p,vec3(1,2,3)))printf("PASS SPACE_DUP\n");else printf("FAIL SPACE_DUP\n>1 2 3\n<%f %f %f\n",p.x,p.y,p.z);

    r=ray_create(vec3(0,0,0),vec3(1,1,1));

    /* INDEPENDENCE_CHECK */ p=ray_at(r,1);
    if(veq(p,vec3(1,1,1)))printf("PASS INDEPENDENCE_CHECK\n");else printf("FAIL INDEPENDENCE_CHECK\n>1 1 1\n<%f %f %f\n",p.x,p.y,p.z);

    /* DIGIT_DUP */ p=ray_at(r,0.5);
    if(veq(p,vec3(0.5,0.5,0.5)))printf("PASS DIGIT_DUP\n");else printf("FAIL DIGIT_DUP\n>0.5 0.5 0.5\n<%f %f %f\n",p.x,p.y,p.z);

    /* TAB_NEWLINE_DUP */
    ok=1;for(i=0;i<N;i++){double ox=rand()%100,oy=rand()%100,oz=rand()%100;
    double dx=(rand()%200-100)/10.0,dy=(rand()%200-100)/10.0,dz=(rand()%200-100)/10.0;
    double t=(rand()%100)/10.0;r=ray_create(vec3(ox,oy,oz),vec3(dx,dy,dz));p=ray_at(r,t);
    if(!feq(p.x,ox+t*dx)||!feq(p.y,oy+t*dy)||!feq(p.z,oz+t*dz)){ok=0;break;}}
    if(ok)printf("PASS TAB_NEWLINE_DUP\n");else printf("FAIL TAB_NEWLINE_DUP\n>random ray_at\n<mismatch\n");

    /* SYMBOL_DUP */ r=ray_create(vec3(0,0,0),vec3(0,0,-1));p=ray_at(r,3);
    if(veq(p,vec3(0,0,-3)))printf("PASS SYMBOL_DUP\n");else printf("FAIL SYMBOL_DUP\n>0 0 -3\n<%f %f %f\n",p.x,p.y,p.z);

    /* RANDOM_DUP */ r=ray_create(vec3(0,0,0),vec3(0,1,0));p=ray_at(r,100);
    if(veq(p,vec3(0,100,0)))printf("PASS RANDOM_DUP\n");else printf("FAIL RANDOM_DUP\n>0 100 0\n<%f %f %f\n",p.x,p.y,p.z);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ray_at.c" "$RENDU/ray_create.c" "$RENDU/vec_create.c" "$RENDU/vec_ops.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
