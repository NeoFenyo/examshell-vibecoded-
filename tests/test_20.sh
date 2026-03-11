#!/bin/bash
# Test 20: sky_color
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test sky_color --${RESET}"

if [ ! -f "$RENDU/sky_color.c" ]; then
    echo -e "  ${RED}Fichier sky_color.c introuvable${RESET}"
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

t_color sky_color(t_ray r);

#define EPS 0.02
static int feq(double a,double b){return fabs(a-b)<EPS;}
static int ceq(t_color a,t_color b){return feq(a.r,b.r)&&feq(a.g,b.g)&&feq(a.b,b.b);}

int main(void) {
    t_ray r;
    t_color c;

    /* CROSS_XY: straight up = blue */
    r=ray_create(vec3(0,0,0),vec3(0,1,0));c=sky_color(r);
    if(ceq(c,color(0.5,0.7,1.0)))printf("PASS CROSS_XY\n");
    else printf("FAIL CROSS_XY\n>0.5 0.7 1.0\n<%f %f %f\n",c.r,c.g,c.b);

    /* CROSS_YX: straight down = white */
    r=ray_create(vec3(0,0,0),vec3(0,-1,0));c=sky_color(r);
    if(ceq(c,color(1,1,1)))printf("PASS CROSS_YX\n");
    else printf("FAIL CROSS_YX\n>1 1 1\n<%f %f %f\n",c.r,c.g,c.b);

    /* CROSS_XZ: horizontal = mix */
    r=ray_create(vec3(0,0,0),vec3(0,0,-1));c=sky_color(r);
    if(ceq(c,color(0.75,0.85,1.0)))printf("PASS CROSS_XZ\n");
    else printf("FAIL CROSS_XZ\n>0.75 0.85 1.0\n<%f %f %f\n",c.r,c.g,c.b);

    /* CROSS_SELF: 45 degrees up */
    r=ray_create(vec3(0,0,0),vec3(0,1,-1));c=sky_color(r);
    if(c.r>0.5&&c.r<0.9&&c.b>=0.99)printf("PASS CROSS_SELF\n");
    else printf("FAIL CROSS_SELF\n>blueish\n<%f %f %f\n",c.r,c.g,c.b);

    /* CROSS_ZERO: forward-Z */
    r=ray_create(vec3(0,0,0),vec3(1,0,0));c=sky_color(r);
    if(ceq(c,color(0.75,0.85,1.0)))printf("PASS CROSS_ZERO\n");
    else printf("FAIL CROSS_ZERO\n>0.75 0.85 1.0\n<%f %f %f\n",c.r,c.g,c.b);

    /* CROSS_BASIC: mostly up */
    r=ray_create(vec3(0,0,0),vec3(0.1,10,0.1));c=sky_color(r);
    if(c.r<0.6&&c.b>0.95)printf("PASS CROSS_BASIC\n");
    else printf("FAIL CROSS_BASIC\n>near blue\n<%f %f %f\n",c.r,c.g,c.b);

    /* CROSS_RANDOM: mostly down */
    r=ray_create(vec3(0,0,0),vec3(0.1,-10,0.1));c=sky_color(r);
    if(c.r>0.9&&c.g>0.9&&c.b>0.9)printf("PASS CROSS_RANDOM\n");
    else printf("FAIL CROSS_RANDOM\n>near white\n<%f %f %f\n",c.r,c.g,c.b);

    /* CROSS_ANTICOMMUTATIVE: origin doesn't matter */
    r=ray_create(vec3(100,200,300),vec3(0,1,0));c=sky_color(r);
    if(ceq(c,color(0.5,0.7,1.0)))printf("PASS CROSS_ANTICOMMUTATIVE\n");
    else printf("FAIL CROSS_ANTICOMMUTATIVE\n>0.5 0.7 1.0\n<%f %f %f\n",c.r,c.g,c.b);

    /* CROSS_PERPENDICULAR: negative X, up */
    r=ray_create(vec3(0,0,0),vec3(-1,1,0));c=sky_color(r);
    if(c.b>0.9)printf("PASS CROSS_PERPENDICULAR\n");
    else printf("FAIL CROSS_PERPENDICULAR\n>blueish\n<%f %f %f\n",c.r,c.g,c.b);

    /* CROSS_OPPOSITE: slight down */
    r=ray_create(vec3(0,0,0),vec3(0,-0.1,-1));c=sky_color(r);
    if(c.r>0.7&&c.b>0.95)printf("PASS CROSS_OPPOSITE\n");
    else printf("FAIL CROSS_OPPOSITE\n>whitish\n<%f %f %f\n",c.r,c.g,c.b);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/sky_color.c" "$RENDU/ray_create.c" "$RENDU/vec_create.c" "$RENDU/vec_ops.c" "$RENDU/vec_normalize.c" "$RENDU/color_ops.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
