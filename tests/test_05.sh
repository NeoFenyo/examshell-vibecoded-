#!/bin/bash
# Test 05: ft_strcpy
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_strcpy --${RESET}"

if [ ! -f "$RENDU/ft_strcpy.c" ]; then
    echo -e "  ${RED}Fichier ft_strcpy.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

char *ft_strcpy(char *dest, char *src);

#define N 10

int main(void) {
    srand(time(NULL));
    int i, j, ok, len;
    char buf[512], dest[512];
    char *ret;

    /* BASIC_COPY */
    ok=1;for(i=0;i<N;i++){len=3+(rand()%20);for(j=0;j<len;j++)buf[j]='a'+(rand()%26);buf[len]=0;
    memset(dest,'X',511);ret=ft_strcpy(dest,buf);if(ret!=dest||strcmp(dest,buf)!=0){ok=0;break;}}
    if(ok)printf("PASS BASIC_COPY\n");else printf("FAIL BASIC_COPY\n>%s\n<%s\n",buf,dest);

    /* EMPTY_COPY */
    memset(dest,'X',511);ret=ft_strcpy(dest,"");
    if(ret==dest&&dest[0]==0)printf("PASS EMPTY_COPY\n");else printf("FAIL EMPTY_COPY\n>(empty)\n<%s\n",dest);

    /* SINGLE_CHAR_COPY */
    memset(dest,'X',511);ret=ft_strcpy(dest,"A");
    if(ret==dest&&strcmp(dest,"A")==0)printf("PASS SINGLE_CHAR_COPY\n");else printf("FAIL SINGLE_CHAR_COPY\n>A\n<%s\n",dest);

    /* LONG_STRING_COPY */
    ok=1;for(i=0;i<N;i++){len=50+(rand()%100);for(j=0;j<len;j++)buf[j]=33+(rand()%94);buf[len]=0;
    memset(dest,'X',511);ft_strcpy(dest,buf);if(strcmp(dest,buf)!=0){ok=0;break;}}
    if(ok)printf("PASS LONG_STRING_COPY\n");else printf("FAIL LONG_STRING_COPY\n>len=%d\n<len=%d\n",len,(int)strlen(dest));

    /* SPACE_COPY */
    ok=1;for(i=0;i<N;i++){len=1+(rand()%10);for(j=0;j<len;j++)buf[j]=' ';buf[len]=0;
    memset(dest,'X',511);ft_strcpy(dest,buf);if(strcmp(dest,buf)!=0){ok=0;break;}}
    if(ok)printf("PASS SPACE_COPY\n");else printf("FAIL SPACE_COPY\n>spaces\n<%s\n",dest);

    /* DIGIT_COPY */
    ok=1;for(i=0;i<N;i++){len=2+(rand()%8);for(j=0;j<len;j++)buf[j]='0'+(rand()%10);buf[len]=0;
    memset(dest,'X',511);ft_strcpy(dest,buf);if(strcmp(dest,buf)!=0){ok=0;break;}}
    if(ok)printf("PASS DIGIT_COPY\n");else printf("FAIL DIGIT_COPY\n>%s\n<%s\n",buf,dest);

    /* TAB_NEWLINE_COPY */
    memset(dest,'X',511);ft_strcpy(dest,"Hello\tWorld\n");
    if(strcmp(dest,"Hello\tWorld\n")==0)printf("PASS TAB_NEWLINE_COPY\n");else printf("FAIL TAB_NEWLINE_COPY\n>Hello\\tWorld\\n\n<%s\n",dest);

    /* RETURN_VALUE_CHECK */
    ok=1;for(i=0;i<N;i++){ret=ft_strcpy(dest,buf);if(ret!=dest){ok=0;break;}}
    if(ok)printf("PASS RETURN_VALUE_CHECK\n");else printf("FAIL RETURN_VALUE_CHECK\n>returns dest\n<different pointer\n");

    /* SYMBOL_COPY */
    ok=1;{char sym[]="!@#$%^&*()";int sl=strlen(sym);
    for(i=0;i<N;i++){len=3+(rand()%10);for(j=0;j<len;j++)buf[j]=sym[rand()%sl];buf[len]=0;
    memset(dest,'X',511);ft_strcpy(dest,buf);if(strcmp(dest,buf)!=0){ok=0;break;}}}
    if(ok)printf("PASS SYMBOL_COPY\n");else printf("FAIL SYMBOL_COPY\n>%s\n<%s\n",buf,dest);

    /* RANDOM_COPY */
    ok=1;for(i=0;i<N;i++){len=1+(rand()%50);for(j=0;j<len;j++)buf[j]=1+(rand()%126);buf[len]=0;
    memset(dest,0,511);ft_strcpy(dest,buf);if(strcmp(dest,buf)!=0||dest[len]!=0){ok=0;break;}}
    if(ok)printf("PASS RANDOM_COPY\n");else printf("FAIL RANDOM_COPY\n>null terminated\n<not null terminated\n");

    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_strcpy.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
