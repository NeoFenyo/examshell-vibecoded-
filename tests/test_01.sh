#!/bin/bash
# Test 01: ft_putstr — capture stdout et compare
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ft_putstr --${RESET}"

if [ ! -f "$RENDU/ft_putstr.c" ]; then
    echo -e "  ${RED}Fichier ft_putstr.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>

void ft_putstr(char *str);

#define CAP "/tmp/examshell_cap"
#define N 10
static int sv; static char cap[8192]; static int cn;
static void cs(void){fflush(stdout);sv=dup(1);int fd=open(CAP,O_WRONLY|O_CREAT|O_TRUNC,0644);dup2(fd,1);close(fd);}
static void ce(void){fflush(stdout);dup2(sv,1);close(sv);int fd=open(CAP,O_RDONLY);cn=read(fd,cap,8191);if(cn<0)cn=0;cap[cn]=0;close(fd);}

int main(void) {
    srand(time(NULL));
    int i, j, ok, len;
    char buf[1024];

    /* BASIC_LOWERCASE */
    ok=1;
    for(i=0;i<N;i++){len=3+(rand()%20);for(j=0;j<len;j++)buf[j]='a'+(rand()%26);buf[len]=0;
    cs();ft_putstr(buf);ce();if(cn!=len||memcmp(cap,buf,len)!=0){ok=0;break;}}
    if(ok)printf("PASS BASIC_LOWERCASE\n");else printf("FAIL BASIC_LOWERCASE\n>%s\n<%.*s\n",buf,cn,cap);

    /* BASIC_DIGITS */
    cs();ft_putstr("");ce();
    if(cn==0)printf("PASS BASIC_DIGITS\n");else printf("FAIL BASIC_DIGITS\n>(empty)\n<%.*s\n",cn,cap);

    /* SPECIAL_CHARS */
    ok=1;
    for(i=0;i<N;i++){cs();ft_putstr("Hello World");ce();if(cn!=11||memcmp(cap,"Hello World",11)!=0){ok=0;break;}}
    if(ok)printf("PASS SPECIAL_CHARS\n");else printf("FAIL SPECIAL_CHARS\n>Hello World\n<%.*s\n",cn,cap);

    /* WHITESPACE */
    ok=1;
    for(i=0;i<N;i++){len=50+(rand()%200);for(j=0;j<len;j++)buf[j]=33+(rand()%94);buf[len]=0;
    cs();ft_putstr(buf);ce();if(cn!=len||memcmp(cap,buf,len)!=0){ok=0;break;}}
    if(ok)printf("PASS WHITESPACE\n");else printf("FAIL WHITESPACE\n>len=%d\n<len=%d\n",len,cn);

    /* UPPER_CASE */
    cs();ft_putstr("A");ce();
    if(cn==1&&cap[0]=='A')printf("PASS UPPER_CASE\n");else printf("FAIL UPPER_CASE\n>A\n<%.*s\n",cn,cap);

    /* PRINTABLE_CHARS */
    ok=1;
    for(i=0;i<N;i++){len=1+(rand()%10);for(j=0;j<len;j++)buf[j]=' ';buf[len]=0;
    cs();ft_putstr(buf);ce();if(cn!=len){ok=0;break;}}
    if(ok)printf("PASS PRINTABLE_CHARS\n");else printf("FAIL PRINTABLE_CHARS\n>%d spaces\n<%d chars\n",len,cn);

    /* NEWLINES */
    ok=1;
    for(i=0;i<N;i++){len=1+(rand()%10);for(j=0;j<len;j++)buf[j]='\t';buf[len]=0;
    cs();ft_putstr(buf);ce();if(cn!=len){ok=0;break;}}
    if(ok)printf("PASS NEWLINES\n");else printf("FAIL NEWLINES\n>%d tabs\n<%d chars\n",len,cn);

    /* NULL_BYTES */
    cs();ft_putstr("Line1\nLine2\n");ce();
    if(cn==12&&memcmp(cap,"Line1\nLine2\n",12)==0)printf("PASS NULL_BYTES\n");
    else printf("FAIL NULL_BYTES\n>Line1\\nLine2\\n\n<%.*s\n",cn,cap);

    /* NORM_SCALE_X */
    ok=1;
    for(i=0;i<N;i++){len=2+(rand()%8);for(j=0;j<len;j++)buf[j]='0'+(rand()%10);buf[len]=0;
    cs();ft_putstr(buf);ce();if(cn!=len||memcmp(cap,buf,len)!=0){ok=0;break;}}
    if(ok)printf("PASS NORM_SCALE_X\n");else printf("FAIL NORM_SCALE_X\n>%s\n<%.*s\n",buf,cn,cap);

    /* NORM_NEG_XY */
    ok=1;{char sym[]="!@#$%^&*()";int sl=strlen(sym);
    for(i=0;i<N;i++){len=3+(rand()%10);for(j=0;j<len;j++)buf[j]=sym[rand()%sl];buf[len]=0;
    cs();ft_putstr(buf);ce();if(cn!=len||memcmp(cap,buf,len)!=0){ok=0;break;}}}
    if(ok)printf("PASS NORM_NEG_XY\n");else printf("FAIL NORM_NEG_XY\n>%s\n<%.*s\n",buf,cn,cap);

    unlink(CAP);
    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ft_putstr.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
