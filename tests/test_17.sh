#!/bin/bash
# Test 17: ray_create
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ray_create --${RESET}"

if [ ! -f "$RENDU/ray_create.c" ]; then
    echo -e "  ${RED}Fichier ray_create.c introuvable${RESET}"
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

#define EPS 1e-9
#define N 10
static int feq(double a,double b){return fabs(a-b)<EPS;}

int main(void) {
    srand(time(NULL));
    int i, ok;
    t_ray r;

    /* NORMAL_STRING */ r=ray_create(vec3(0,0,0),vec3(0,0,-1));
    if(feq(r.origin.x,0)&&feq(r.origin.y,0)&&feq(r.origin.z,0)&&feq(r.direction.x,0)&&feq(r.direction.y,0)&&feq(r.direction.z,-1))
        printf("PASS NORMAL_STRING\n");else printf("FAIL NORMAL_STRING\n>o(0,0,0) d(0,0,-1)\n<o(%f,%f,%f) d(%f,%f,%f)\n",r.origin.x,r.origin.y,r.origin.z,r.direction.x,r.direction.y,r.direction.z);

    /* LEADING_SPACES */ r=ray_create(vec3(1,2,3),vec3(4,5,6));
    if(feq(r.origin.x,1)&&feq(r.origin.y,2)&&feq(r.origin.z,3)&&feq(r.direction.x,4)&&feq(r.direction.y,5)&&feq(r.direction.z,6))
        printf("PASS LEADING_SPACES\n");else printf("FAIL LEADING_SPACES\n>o(1,2,3) d(4,5,6)\n<wrong\n");

    /* MULTIPLE_WORDS */ r=ray_create(vec3(-1,-2,-3),vec3(-4,-5,-6));
    if(feq(r.origin.x,-1)&&feq(r.direction.z,-6))printf("PASS MULTIPLE_WORDS\n");else printf("FAIL MULTIPLE_WORDS\n>negatives\n<wrong\n");

    /* TRAILING_SPACES */
    ok=1;for(i=0;i<N;i++){double ox=(rand()%200-100)/10.0,oy=(rand()%200-100)/10.0,oz=(rand()%200-100)/10.0;
    double dx=(rand()%200-100)/10.0,dy=(rand()%200-100)/10.0,dz=(rand()%200-100)/10.0;
    r=ray_create(vec3(ox,oy,oz),vec3(dx,dy,dz));
    if(!feq(r.origin.x,ox)||!feq(r.origin.y,oy)||!feq(r.origin.z,oz)||!feq(r.direction.x,dx)||!feq(r.direction.y,dy)||!feq(r.direction.z,dz)){ok=0;break;}}
    if(ok)printf("PASS TRAILING_SPACES\n");else printf("FAIL TRAILING_SPACES\n>random\n<mismatch\n");

    /* MIXED_TABS_SPACES */ r=ray_create(vec3(0,0,0),vec3(1,0,0));
    if(feq(r.direction.x,1)&&feq(r.direction.y,0))printf("PASS MIXED_TABS_SPACES\n");else printf("FAIL MIXED_TABS_SPACES\n>d(1,0,0)\n<wrong\n");

    /* ONLY_TABS */ r=ray_create(vec3(0,0,0),vec3(0,1,0));
    if(feq(r.direction.y,1))printf("PASS ONLY_TABS\n");else printf("FAIL ONLY_TABS\n>d(0,1,0)\n<wrong\n");

    /* LONE_WORD */ r=ray_create(vec3(0.5,0.5,0.5),vec3(0.1,0.2,0.3));
    if(feq(r.origin.x,0.5)&&feq(r.direction.z,0.3))printf("PASS LONE_WORD\n");else printf("FAIL LONE_WORD\n>floats\n<wrong\n");

    /* PUNCTUATION_WORD */ r=ray_create(vec3(100,200,300),vec3(-1,-1,-1));
    if(feq(r.origin.x,100)&&feq(r.direction.x,-1))printf("PASS PUNCTUATION_WORD\n");else printf("FAIL PUNCTUATION_WORD\n>large origin\n<wrong\n");

    /* NO_ARGS */ r=ray_create(vec3(0,0,0),vec3(0,0,0));
    if(feq(r.origin.x,0)&&feq(r.direction.x,0))printf("PASS NO_ARGS\n");else printf("FAIL NO_ARGS\n>zeros\n<wrong\n");

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ray_create.c" "$RENDU/vec_create.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
