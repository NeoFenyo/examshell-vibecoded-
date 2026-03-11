#!/bin/bash
# Test 16: color_ops
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test color_ops --${RESET}"

if [ ! -f "$RENDU/color_ops.c" ]; then
    echo -e "  ${RED}Fichier color_ops.c introuvable${RESET}"
    exit 1
fi

cp "$PROJECT/subjects/includes/color.h" "$RENDU/" 2>/dev/null

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <math.h>
#include "color.h"

#define EPS 1e-6
static int feq(double a,double b){return fabs(a-b)<EPS;}

int main(void) {
    t_color c;
    int v;

    /* ADD_BASIC */ c=color(1,0.5,0);
    if(feq(c.r,1)&&feq(c.g,0.5)&&feq(c.b,0))printf("PASS ADD_BASIC\n");
    else printf("FAIL ADD_BASIC\n>1 0.5 0\n<%f %f %f\n",c.r,c.g,c.b);

    /* SUB_BASIC */ c=color_add(color(0.5,0.3,0.1),color(0.2,0.4,0.6));
    if(feq(c.r,0.7)&&feq(c.g,0.7)&&feq(c.b,0.7))printf("PASS SUB_BASIC\n");
    else printf("FAIL SUB_BASIC\n>0.7 0.7 0.7\n<%f %f %f\n",c.r,c.g,c.b);

    /* SCALE_BASIC */ c=color_scale(color(0.5,0.5,0.5),2);
    if(feq(c.r,1)&&feq(c.g,1)&&feq(c.b,1))printf("PASS SCALE_BASIC\n");
    else printf("FAIL SCALE_BASIC\n>1 1 1\n<%f %f %f\n",c.r,c.g,c.b);

    /* ADD_ZEROS */ c=color_clamp(color(1.5,-0.2,0.5));
    if(feq(c.r,1)&&feq(c.g,0)&&feq(c.b,0.5))printf("PASS ADD_ZEROS\n");
    else printf("FAIL ADD_ZEROS\n>1 0 0.5\n<%f %f %f\n",c.r,c.g,c.b);

    /* SCALE_ZERO */ v=color_to_int(color(1,0,0));
    if(v==0xFF0000)printf("PASS SCALE_ZERO\n");else printf("FAIL SCALE_ZERO\n>16711680\n<%d\n",v);

    /* SUB_SELF */ v=color_to_int(color(0,1,0));
    if(v==0x00FF00)printf("PASS SUB_SELF\n");else printf("FAIL SUB_SELF\n>65280\n<%d\n",v);

    /* SCALE_NEGATIVE */ v=color_to_int(color(0,0,1));
    if(v==0x0000FF)printf("PASS SCALE_NEGATIVE\n");else printf("FAIL SCALE_NEGATIVE\n>255\n<%d\n",v);

    /* ADD_RANDOM */ c=color_clamp(color(0.5,0.5,0.5));
    if(feq(c.r,0.5)&&feq(c.g,0.5)&&feq(c.b,0.5))printf("PASS ADD_RANDOM\n");
    else printf("FAIL ADD_RANDOM\n>0.5 0.5 0.5\n<%f %f %f\n",c.r,c.g,c.b);

    /* SUB_RANDOM */ c=color_scale(color(1,1,1),0);
    if(feq(c.r,0)&&feq(c.g,0)&&feq(c.b,0))printf("PASS SUB_RANDOM\n");
    else printf("FAIL SUB_RANDOM\n>0 0 0\n<%f %f %f\n",c.r,c.g,c.b);

    /* SCALE_RANDOM */ v=color_to_int(color(1,0.5,0));
    if(v==0xFF7F00||v==0xFF8000)printf("PASS SCALE_RANDOM\n");else printf("FAIL SCALE_RANDOM\n>0xFF7F00\n<%06X\n",v);

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/color_ops.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
