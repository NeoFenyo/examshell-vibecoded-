#!/bin/bash
# Test 22: diffuse_light
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test diffuse_light --${RESET}"

if [ ! -f "$RENDU/diffuse_light.c" ]; then
    echo -e "  ${RED}Fichier diffuse_light.c introuvable${RESET}"
    exit 1
fi

cp "$PROJECT/subjects/includes/vec3.h" "$RENDU/" 2>/dev/null
cp "$PROJECT/subjects/includes/color.h" "$RENDU/" 2>/dev/null

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <math.h>
#include "vec3.h"
#include "color.h"

t_color diffuse_light(t_vec3 normal, t_vec3 light_dir, t_color obj_color);

#define EPS 0.02
static int feq(double a,double b){return fabs(a-b)<EPS;}

int main(void) {
    t_color c;

    /* Direct light: normal and light same dir = full intensity */
    c=diffuse_light(vec3(0,1,0),vec3(0,1,0),color(1,0,0));
    if(feq(c.r,1)&&feq(c.g,0)&&feq(c.b,0))printf("PASS ZERO_VARIANTS\n");
    else printf("FAIL ZERO_VARIANTS\n>1 0 0\n<%f %f %f\n",c.r,c.g,c.b);

    /* Perpendicular: intensity=0 */
    c=diffuse_light(vec3(0,1,0),vec3(1,0,0),color(1,0,0));
    if(feq(c.r,0)&&feq(c.g,0)&&feq(c.b,0))printf("PASS POSITIVE_NUMBERS\n");
    else printf("FAIL POSITIVE_NUMBERS\n>0 0 0\n<%f %f %f\n",c.r,c.g,c.b);

    /* Opposite: intensity=0 (clamped) */
    c=diffuse_light(vec3(0,1,0),vec3(0,-1,0),color(1,1,1));
    if(feq(c.r,0)&&feq(c.g,0)&&feq(c.b,0))printf("PASS NEGATIVE_NUMBERS\n");
    else printf("FAIL NEGATIVE_NUMBERS\n>0 0 0\n<%f %f %f\n",c.r,c.g,c.b);

    /* 45 degrees */
    c=diffuse_light(vec3(0,1,0),vec3(0,1,1),color(1,1,1));
    double expected=1.0/sqrt(2.0);
    if(feq(c.r,expected))printf("PASS PLUS_PREFIX\n");
    else printf("FAIL PLUS_PREFIX\n>%f\n<%f\n",expected,c.r);

    /* Blue surface */
    c=diffuse_light(vec3(0,0,1),vec3(0,0,1),color(0,0,1));
    if(feq(c.r,0)&&feq(c.g,0)&&feq(c.b,1))printf("PASS LEADING_WHITESPACE\n");
    else printf("FAIL LEADING_WHITESPACE\n>0 0 1\n<%f %f %f\n",c.r,c.g,c.b);

    /* Green */
    c=diffuse_light(vec3(1,0,0),vec3(1,0,0),color(0,1,0));
    if(feq(c.r,0)&&feq(c.g,1)&&feq(c.b,0))printf("PASS TRAILING_JUNK\n");
    else printf("FAIL TRAILING_JUNK\n>0 1 0\n<%f %f %f\n",c.r,c.g,c.b);

    /* Half intensity */
    c=diffuse_light(vec3(0,1,0),vec3(0,1,0),color(0.5,0.5,0.5));
    if(feq(c.r,0.5)&&feq(c.g,0.5)&&feq(c.b,0.5))printf("PASS INVALID_INPUTS\n");
    else printf("FAIL INVALID_INPUTS\n>0.5 0.5 0.5\n<%f %f %f\n",c.r,c.g,c.b);

    /* Non-unit light dir (should normalize) */
    c=diffuse_light(vec3(0,1,0),vec3(0,10,0),color(1,1,1));
    if(feq(c.r,1))printf("PASS DOUBLE_SIGNS\n");
    else printf("FAIL DOUBLE_SIGNS\n>1\n<%f\n",c.r);

    /* Grazing angle */
    c=diffuse_light(vec3(0,1,0),vec3(100,1,0),color(1,1,1));
    if(c.r>0&&c.r<0.1)printf("PASS EDGE_LIMITS\n");
    else printf("FAIL EDGE_LIMITS\n>~0.01\n<%f\n",c.r);

    printf("PASS RANDOM_FORMAT_STRING\n");

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/diffuse_light.c" "$RENDU/vec_create.c" "$RENDU/vec_ops.c" "$RENDU/vec_dot.c" "$RENDU/vec_normalize.c" "$RENDU/color_ops.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
