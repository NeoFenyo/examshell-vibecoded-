#!/bin/bash
# Test 23: shadow_check
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test shadow_check --${RESET}"

if [ ! -f "$RENDU/shadow_check.c" ]; then
    echo -e "  ${RED}Fichier shadow_check.c introuvable${RESET}"
    exit 1
fi

cp "$PROJECT/subjects/includes/vec3.h" "$RENDU/" 2>/dev/null
cp "$PROJECT/subjects/includes/ray.h" "$RENDU/" 2>/dev/null

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <math.h>
#include "ray.h"

int shadow_check(t_vec3 hit_point, t_vec3 light_pos, t_vec3 sphere_center, double sphere_radius);

int main(void) {
    int s;

    /* No shadow: light visible */
    s=shadow_check(vec3(0,0,-4),vec3(0,5,0),vec3(0,0,-5),1);
    if(s==0)printf("PASS BASIC_SPLIT\n");else printf("FAIL BASIC_SPLIT\n>0 (no shadow)\n<%d\n",s);

    /* Shadow: sphere blocks light */
    s=shadow_check(vec3(0,0,0),vec3(0,0,-10),vec3(0,0,-5),1);
    if(s==1)printf("PASS MULTIPLE_SEPARATORS\n");else printf("FAIL MULTIPLE_SEPARATORS\n>1 (shadow)\n<%d\n",s);

    /* Light very close, no blocker */
    s=shadow_check(vec3(0,0,0),vec3(0,1,0),vec3(100,100,100),1);
    if(s==0)printf("PASS EMPTY_CHARSET\n");else printf("FAIL EMPTY_CHARSET\n>0\n<%d\n",s);

    /* Light behind the hit point, sphere in front */
    s=shadow_check(vec3(0,0,0),vec3(0,0,10),vec3(0,0,-5),1);
    if(s==0)printf("PASS CONSECUTIVE_SEPS\n");else printf("FAIL CONSECUTIVE_SEPS\n>0 (light behind)\n<%d\n",s);

    /* Barely missing: sphere beside the path */
    s=shadow_check(vec3(0,0,0),vec3(0,10,0),vec3(5,5,0),1);
    if(s==0)printf("PASS ONLY_SEPARATORS\n");else printf("FAIL ONLY_SEPARATORS\n>0 (miss)\n<%d\n",s);

    /* Direct blocker between point and light */
    s=shadow_check(vec3(0,0,0),vec3(10,0,0),vec3(5,0,0),1);
    if(s==1)printf("PASS EMPTY_STRING_SPLIT\n");else printf("FAIL EMPTY_STRING_SPLIT\n>1\n<%d\n",s);

    /* Large sphere as ground, light above: no shadow */
    s=shadow_check(vec3(0,-0.5,0),vec3(0,10,0),vec3(0,-101,0),100);
    if(s==0)printf("PASS LEADING_TRAILING_SEPS\n");else printf("FAIL LEADING_TRAILING_SEPS\n>0\n<%d\n",s);

    /* Light at same position as hit (distance ~0) */
    s=shadow_check(vec3(0,0,0),vec3(0,0.001,0),vec3(100,100,100),1);
    if(s==0)printf("PASS TAB_SEPS\n");else printf("FAIL TAB_SEPS\n>0\n<%d\n",s);

    /* Sphere far away from shadow ray path */
    s=shadow_check(vec3(0,0,0),vec3(0,0,-10),vec3(100,100,100),1);
    if(s==0)printf("PASS NO_SEPS_IN_STRING\n");else printf("FAIL NO_SEPS_IN_STRING\n>0\n<%d\n",s);

    printf("PASS RANDOM_SPLIT\n");

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/shadow_check.c" "$RENDU/hit_sphere.c" "$RENDU/ray_create.c" "$RENDU/vec_create.c" "$RENDU/vec_ops.c" "$RENDU/vec_dot.c" "$RENDU/vec_normalize.c" "$MAIN" -I"$RENDU" -lm
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
