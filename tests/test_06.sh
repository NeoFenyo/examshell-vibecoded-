#!/bin/bash
# Test 06: ft_strdup
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_strdup --${RESET}"

if [ ! -f "$RENDU/ft_strdup.c" ]; then
    echo -e "  ${RED}Fichier ft_strdup.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

char *ft_strdup(char *src);

#define N 10

int main(void) {
    srand(time(NULL));
    int i, j, ok, len;
    char buf[512], *dup;

    /* BASIC_DUP */
    ok=1;for(i=0;i<N;i++){len=3+(rand()%20);for(j=0;j<len;j++)buf[j]='a'+(rand()%26);buf[len]=0;
    dup=ft_strdup(buf);if(!dup||strcmp(dup,buf)!=0){ok=0;break;}if(dup==buf){ok=0;break;}free(dup);}
    if(ok)printf("PASS BASIC_DUP\n");else printf("FAIL BASIC_DUP\n>%s\n<%s\n",buf,dup?dup:"(null)");

    /* EMPTY_DUP */
    dup=ft_strdup("");
    if(dup&&strcmp(dup,"")==0)printf("PASS EMPTY_DUP\n");else printf("FAIL EMPTY_DUP\n>(empty)\n<%s\n",dup?dup:"(null)");
    free(dup);

    /* SINGLE_CHAR_DUP */
    dup=ft_strdup("A");
    if(dup&&strcmp(dup,"A")==0&&dup!=buf)printf("PASS SINGLE_CHAR_DUP\n");else printf("FAIL SINGLE_CHAR_DUP\n>A\n<%s\n",dup?dup:"(null)");
    free(dup);

    /* LONG_STRING_DUP */
    ok=1;for(i=0;i<N;i++){len=50+(rand()%100);for(j=0;j<len;j++)buf[j]=33+(rand()%94);buf[len]=0;
    dup=ft_strdup(buf);if(!dup||strcmp(dup,buf)!=0){ok=0;break;}free(dup);}
    if(ok)printf("PASS LONG_STRING_DUP\n");else printf("FAIL LONG_STRING_DUP\n>len=%d\n<len=%d\n",len,dup?(int)strlen(dup):-1);

    /* SPACE_DUP */
    ok=1;for(i=0;i<N;i++){len=3+(rand()%10);for(j=0;j<len;j++)buf[j]=' ';buf[len]=0;
    dup=ft_strdup(buf);if(!dup||strcmp(dup,buf)!=0){ok=0;break;}free(dup);}
    if(ok)printf("PASS SPACE_DUP\n");else printf("FAIL SPACE_DUP\n>spaces\n<%s\n",dup?dup:"(null)");

    /* INDEPENDENCE_CHECK */
    ok=1;for(i=0;i<N;i++){strcpy(buf, "test");dup=ft_strdup(buf);if(!dup||dup==buf){ok=0;break;}
    buf[0]='Z';if(dup[0]=='Z'){ok=0;break;}free(dup);}
    if(ok)printf("PASS INDEPENDENCE_CHECK\n");else printf("FAIL INDEPENDENCE_CHECK\n>independent copy\n<shared memory\n");

    /* DIGIT_DUP */
    ok=1;for(i=0;i<N;i++){len=2+(rand()%8);for(j=0;j<len;j++)buf[j]='0'+(rand()%10);buf[len]=0;
    dup=ft_strdup(buf);if(!dup||strcmp(dup,buf)!=0){ok=0;break;}free(dup);}
    if(ok)printf("PASS DIGIT_DUP\n");else printf("FAIL DIGIT_DUP\n>%s\n<%s\n",buf,dup?dup:"(null)");

    /* TAB_NEWLINE_DUP */
    dup=ft_strdup("Hello\tWorld\n");
    if(dup&&strcmp(dup,"Hello\tWorld\n")==0)printf("PASS TAB_NEWLINE_DUP\n");else printf("FAIL TAB_NEWLINE_DUP\n>Hello\\tWorld\\n\n<%s\n",dup?dup:"(null)");
    free(dup);

    /* SYMBOL_DUP */
    ok=1;{char sym[]="!@#$%^&*()";int sl=strlen(sym);
    for(i=0;i<N;i++){len=3+(rand()%10);for(j=0;j<len;j++)buf[j]=sym[rand()%sl];buf[len]=0;
    dup=ft_strdup(buf);if(!dup||strcmp(dup,buf)!=0){ok=0;break;}free(dup);}}
    if(ok)printf("PASS SYMBOL_DUP\n");else printf("FAIL SYMBOL_DUP\n>%s\n<%s\n",buf,dup?dup:"(null)");

    /* RANDOM_DUP */
    ok=1;for(i=0;i<N;i++){len=1+(rand()%50);for(j=0;j<len;j++)buf[j]=1+(rand()%126);buf[len]=0;
    dup=ft_strdup(buf);if(!dup||strcmp(dup,buf)!=0||dup[len]!=0){ok=0;break;}free(dup);}
    if(ok)printf("PASS RANDOM_DUP\n");else printf("FAIL RANDOM_DUP\n>null terminated\n<wrong\n");

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_strdup.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
