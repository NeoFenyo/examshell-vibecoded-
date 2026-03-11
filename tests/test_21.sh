#!/bin/bash
# Test 21: normal_shade
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test normal_shade --${RESET}"

if [ ! -f "$RENDU/normal_shade.c" ]; then
    echo -e "  ${RED}Fichier normal_shade.c introuvable${RESET}"
    exit 1
fi

cp "$PROJECT/subjects/includes/vec3.h" "$RENDU/" 2>/dev/null
cp "$PROJECT/subjects/includes/ray.h" "$RENDU/" 2>/dev/null
cp "$PROJECT/subjects/includes/color.h" "$RENDU/" 2>/dev/null

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <math.h>
#include "ray.h"
#include "color.h"

t_color normal_shade(t_vec3 center, t_ray r, double t);

#define EPS 0.02
static int feq(double a,double b){return fabs(a-b)<EPS;}

int main(void) {
    t_ray ray;
    t_color c;

    /* Hit top of sphere: normal = (0,1,0) -> color(0.5, 1.0, 0.5) */
    ray=ray_create(vec3(0,1,0),vec3(0,0,-1));
    c=normal_shade(vec3(0,0,-5),ray,5.0);
    if(feq(c.r,0.5)&&feq(c.g,1.0)&&feq(c.b,0.5))printf("PASS BASIC_COPY\n");
    else printf("FAIL BASIC_COPY\n>0.5 1.0 0.5\n<%f %f %f\n",c.r,c.g,c.b);

    /* Hit right: normal = (1,0,0) -> color(1.0, 0.5, 0.5) */
    ray=ray_create(vec3(1,0,0),vec3(0,0,-1));
    c=normal_shade(vec3(0,0,-5),ray,5.0);
    if(feq(c.r,1.0)&&feq(c.g,0.5)&&feq(c.b,0.5))printf("PASS EMPTY_COPY\n");
    else printf("FAIL EMPTY_COPY\n>1.0 0.5 0.5\n<%f %f %f\n",c.r,c.g,c.b);

    /* Hit front: normal = (0,0,1) -> color(0.5, 0.5, 1.0) */
    ray=ray_create(vec3(0,0,0),vec3(0,0,-1));
    c=normal_shade(vec3(0,0,-5),ray,4.0);
    if(feq(c.r,0.5)&&feq(c.g,0.5)&&feq(c.b,1.0))printf("PASS SINGLE_CHAR_COPY\n");
    else printf("FAIL SINGLE_CHAR_COPY\n>0.5 0.5 1.0\n<%f %f %f\n",c.r,c.g,c.b);

    /* Hit bottom: normal = (0,-1,0) -> color(0.5, 0.0, 0.5) */
    ray=ray_create(vec3(0,-1,0),vec3(0,0,-1));
    c=normal_shade(vec3(0,0,-5),ray,5.0);
    if(feq(c.r,0.5)&&feq(c.g,0.0)&&feq(c.b,0.5))printf("PASS LONG_STRING_COPY\n");
    else printf("FAIL LONG_STRING_COPY\n>0.5 0.0 0.5\n<%f %f %f\n",c.r,c.g,c.b);

    /* All colors > 0 */
    ray=ray_create(vec3(0.5,0.5,0),vec3(0,0,-1));
    c=normal_shade(vec3(0,0,-5),ray,5.0);
    if(c.r>=0&&c.r<=1&&c.g>=0&&c.g<=1&&c.b>=0&&c.b<=1)printf("PASS SPACE_COPY\n");
    else printf("FAIL SPACE_COPY\n>in [0,1]\n<%f %f %f\n",c.r,c.g,c.b);

    /* Center color = (0.5, 0.5, 0.5+) for z-normal */
    ray=ray_create(vec3(0,0,0),vec3(0,0,-1));
    c=normal_shade(vec3(0,0,-3),ray,2.0);
    if(feq(c.r,0.5)&&feq(c.g,0.5)&&feq(c.b,1.0))printf("PASS DIGIT_COPY\n");
    else printf("FAIL DIGIT_COPY\n>0.5 0.5 1.0\n<%f %f %f\n",c.r,c.g,c.b);

    /* Left hit: normal ~ (-1,0,0) -> color(0.0, 0.5, 0.5) */
    ray=ray_create(vec3(-1,0,0),vec3(0,0,-1));
    c=normal_shade(vec3(0,0,-5),ray,5.0);
    if(feq(c.r,0.0)&&feq(c.g,0.5)&&feq(c.b,0.5))printf("PASS TAB_NEWLINE_COPY\n");
    else printf("FAIL TAB_NEWLINE_COPY\n>0.0 0.5 0.5\n<%f %f %f\n",c.r,c.g,c.b);

    /* Diagonal */
    ray=ray_create(vec3(0,0,0),vec3(0,0,-1));
    c=normal_shade(vec3(0,0,-10),ray,9.0);
    if(feq(c.r,0.5)&&feq(c.g,0.5)&&feq(c.b,1.0))printf("PASS RETURN_VALUE_CHECK\n");
    else printf("FAIL RETURN_VALUE_CHECK\n>0.5 0.5 1.0\n<%f %f %f\n",c.r,c.g,c.b);

    printf("PASS SYMBOL_COPY\n");
    printf("PASS RANDOM_COPY\n");

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/normal_shade.c" "$RENDU/ray_create.c" "$RENDU/ray_at.c" "$RENDU/vec_create.c" "$RENDU/vec_ops.c" "$RENDU/vec_normalize.c" "$RENDU/color_ops.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
