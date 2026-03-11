#!/bin/bash
# Test 19: hit_sphere
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test hit_sphere --${RESET}"

if [ ! -f "$RENDU/hit_sphere.c" ]; then
    echo -e "  ${RED}Fichier hit_sphere.c introuvable${RESET}"
    exit 1
fi

cp "$PROJECT/subjects/includes/vec3.h" "$RENDU/" 2>/dev/null
cp "$PROJECT/subjects/includes/ray.h" "$RENDU/" 2>/dev/null

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <math.h>
#include "ray.h"

double hit_sphere(t_vec3 center, double radius, t_ray r);

#define EPS 1e-4
static int feq(double a,double b){return fabs(a-b)<EPS;}

int main(void) {
    t_ray r;
    double t;

    /* BASIC_LOWERCASE: ray hits sphere dead center */
    r=ray_create(vec3(0,0,0),vec3(0,0,-1));
    t=hit_sphere(vec3(0,0,-5),1,r);
    if(feq(t,4))printf("PASS BASIC_LOWERCASE\n");else printf("FAIL BASIC_LOWERCASE\n>4.0\n<%f\n",t);

    /* BASIC_DIGITS: miss */
    t=hit_sphere(vec3(100,0,0),1,r);
    if(t<0)printf("PASS BASIC_DIGITS\n");else printf("FAIL BASIC_DIGITS\n>-1\n<%f\n",t);

    /* SPECIAL_CHARS: tangent */
    t=hit_sphere(vec3(1,0,-5),1,r);
    if(feq(t,5))printf("PASS SPECIAL_CHARS\n");else printf("FAIL SPECIAL_CHARS\n>5.0\n<%f\n",t);

    /* WHITESPACE: sphere behind camera */
    t=hit_sphere(vec3(0,0,5),1,r);
    if(t<0)printf("PASS WHITESPACE\n");else printf("FAIL WHITESPACE\n>-1\n<%f\n",t);

    /* UPPER_CASE: different radius */
    t=hit_sphere(vec3(0,0,-5),2,r);
    if(feq(t,3))printf("PASS UPPER_CASE\n");else printf("FAIL UPPER_CASE\n>3.0\n<%f\n",t);

    /* PRINTABLE_CHARS: camera inside sphere */
    t=hit_sphere(vec3(0,0,0),10,r);
    if(t>0)printf("PASS PRINTABLE_CHARS\n");else printf("FAIL PRINTABLE_CHARS\n>positive t\n<%f\n",t);

    /* NEWLINES: off-axis ray */
    r=ray_create(vec3(0,0,0),vec3(1,0,-1));
    t=hit_sphere(vec3(5,0,-5),1,r);
    if(t>0)printf("PASS NEWLINES\n");else printf("FAIL NEWLINES\n>positive t\n<%f\n",t);

    /* NULL_BYTES: unit sphere at origin */
    r=ray_create(vec3(0,0,3),vec3(0,0,-1));
    t=hit_sphere(vec3(0,0,0),1,r);
    if(feq(t,2))printf("PASS NULL_BYTES\n");else printf("FAIL NULL_BYTES\n>2.0\n<%f\n",t);

    /* NORM_SCALE_X: large sphere (ground plane) */
    r=ray_create(vec3(0,0,0),vec3(0,-1,0));
    t=hit_sphere(vec3(0,-101,0),100,r);
    if(feq(t,1))printf("PASS NORM_SCALE_X\n");else printf("FAIL NORM_SCALE_X\n>1.0\n<%f\n",t);

    /* NORM_NEG_XY: miss just barely */
    r=ray_create(vec3(0,0,0),vec3(0,0,-1));
    t=hit_sphere(vec3(1.01,0,-5),1,r);
    if(t<0)printf("PASS NORM_NEG_XY\n");else printf("FAIL NORM_NEG_XY\n>-1 (miss)\n<%f\n",t);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/hit_sphere.c" "$RENDU/ray_create.c" "$RENDU/vec_create.c" "$RENDU/vec_ops.c" "$RENDU/vec_dot.c" "$RENDU/vec_normalize.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
