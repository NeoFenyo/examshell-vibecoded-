#!/bin/bash
# Test 14: ppm_header
RENDU="$1"
PROJECT="$2"
source "$PROJECT/tests/utils.sh"

MAIN="/tmp/examshell_main_$$.c"
BIN="/tmp/examshell_bin_$$"

echo -e "${CYAN}${BOLD}-- Test ppm_header --${RESET}"

if [ ! -f "$RENDU/ppm_header.c" ]; then
    echo -e "  ${RED}Fichier ppm_header.c introuvable${RESET}"
    exit 1
fi

cat > "$MAIN" << 'EOF'
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

void ppm_header(int fd, int width, int height);

#define CAP "/tmp/examshell_cap"
static char cap[4096]; static int cn;
static void cs(void){fflush(stdout);int fd=open(CAP,O_WRONLY|O_CREAT|O_TRUNC,0644);dup2(fd,1);close(fd);}
static void ce(void){fflush(stdout);int fd=open(CAP,O_RDONLY);cn=read(fd,cap,4095);if(cn<0)cn=0;cap[cn]=0;close(fd);int sv=open("/dev/tty",O_WRONLY);if(sv>=0){dup2(sv,1);close(sv);}}

int main(void) {
    int sv=dup(1);

    /* NORMAL_STRING */
    dup2(sv,1);cs();ppm_header(1,400,300);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n400 300\n255\n")==0)printf("PASS NORMAL_STRING\n");
    else printf("FAIL NORMAL_STRING\n>P3\\n400 300\\n255\\n\n<%s\n",cap);

    /* LEADING_SPACES */
    dup2(sv,1);cs();ppm_header(1,1,1);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n1 1\n255\n")==0)printf("PASS LEADING_SPACES\n");
    else printf("FAIL LEADING_SPACES\n>P3\\n1 1\\n255\\n\n<%s\n",cap);

    /* MULTIPLE_WORDS */
    dup2(sv,1);cs();ppm_header(1,1920,1080);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n1920 1080\n255\n")==0)printf("PASS MULTIPLE_WORDS\n");
    else printf("FAIL MULTIPLE_WORDS\n>P3\\n1920 1080\\n255\\n\n<%s\n",cap);

    /* TRAILING_SPACES */
    dup2(sv,1);cs();ppm_header(1,100,200);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n100 200\n255\n")==0)printf("PASS TRAILING_SPACES\n");
    else printf("FAIL TRAILING_SPACES\n>P3\\n100 200\\n255\\n\n<%s\n",cap);

    /* MIXED_TABS_SPACES */
    dup2(sv,1);cs();ppm_header(1,10,10);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n10 10\n255\n")==0)printf("PASS MIXED_TABS_SPACES\n");
    else printf("FAIL MIXED_TABS_SPACES\n>P3\\n10 10\\n255\\n\n<%s\n",cap);

    /* ONLY_TABS */
    dup2(sv,1);cs();ppm_header(1,640,480);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n640 480\n255\n")==0)printf("PASS ONLY_TABS\n");
    else printf("FAIL ONLY_TABS\n>P3\\n640 480\\n255\\n\n<%s\n",cap);

    /* LONE_WORD */
    dup2(sv,1);cs();ppm_header(1,3840,2160);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n3840 2160\n255\n")==0)printf("PASS LONE_WORD\n");
    else printf("FAIL LONE_WORD\n>P3\\n3840 2160\\n255\\n\n<%s\n",cap);

    /* PUNCTUATION_WORD */
    dup2(sv,1);cs();ppm_header(1,42,42);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n42 42\n255\n")==0)printf("PASS PUNCTUATION_WORD\n");
    else printf("FAIL PUNCTUATION_WORD\n>P3\\n42 42\\n255\\n\n<%s\n",cap);

    /* NO_ARGS */
    dup2(sv,1);cs();ppm_header(1,800,600);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n800 600\n255\n")==0)printf("PASS NO_ARGS\n");
    else printf("FAIL NO_ARGS\n>P3\\n800 600\\n255\\n\n<%s\n",cap);

    /* WEIRD_CHARS */
    dup2(sv,1);cs();ppm_header(1,256,256);ce();dup2(sv,1);
    if(strcmp(cap,"P3\n256 256\n255\n")==0)printf("PASS WEIRD_CHARS\n");
    else printf("FAIL WEIRD_CHARS\n>P3\\n256 256\\n255\\n\n<%s\n",cap);

    close(sv);unlink(CAP);
    return 0;
}
EOF

compile_files "$BIN" "$RENDU/ppm_header.c" "$MAIN"
if [ $? -ne 0 ]; then rm -f "$MAIN" "$BIN"; print_results; exit 1; fi

OUTPUT=$(timeout 10 "$BIN" 2>/dev/null)
parse_results "$OUTPUT"
rm -f "$MAIN" "$BIN"
print_results
