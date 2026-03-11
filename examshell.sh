#!/bin/bash
# ============================================================================
#  EXAMSHELL 42 — Simulateur d'examen
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RENDU_DIR="$SCRIPT_DIR/rendu"
SUBJECTS_DIR="$SCRIPT_DIR/subjects"
TESTS_DIR="$SCRIPT_DIR/tests"
GRADEME="$SCRIPT_DIR/grademe.sh"

cleanup_rendu() {
    local win_path
    win_path=$(echo "$RENDU_DIR" | sed 's|/mnt/\(.\)|\1:|' | sed 's|/|\\|g') 2>/dev/null
    cmd.exe /c "rd /s /q \"$win_path\"" 2>/dev/null
    rm -rf "$RENDU_DIR" 2>/dev/null
}
trap cleanup_rendu EXIT

# ── Couleurs ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Exercices ────────────────────────────────────────────────────────────────
EXERCISES=(
    "00_ft_putchar"
    "01_ft_putstr"
    "02_ft_strlen"
    "03_ft_atoi"
    "04_ft_atof"
    "05_ft_strcpy"
    "06_ft_strdup"
    "07_ft_range"
    "08_ft_split"
    "09_vec_create"
    "10_vec_ops"
    "11_vec_dot"
    "12_vec_cross"
    "13_vec_normalize"
    "14_ppm_header"
    "15_ppm_gradient"
    "16_color_ops"
    "17_ray_create"
    "18_ray_at"
    "19_hit_sphere"
    "20_sky_color"
    "21_normal_shade"
    "22_diffuse_light"
    "23_shadow_check"
    "24_mini_rt"
)

EXNAMES=(
    "ft_putchar"
    "ft_putstr"
    "ft_strlen"
    "ft_atoi"
    "ft_atof"
    "ft_strcpy"
    "ft_strdup"
    "ft_range"
    "ft_split"
    "vec_create"
    "vec_ops"
    "vec_dot"
    "vec_cross"
    "vec_normalize"
    "ppm_header"
    "ppm_gradient"
    "color_ops"
    "ray_create"
    "ray_at"
    "hit_sphere"
    "sky_color"
    "normal_shade"
    "diffuse_light"
    "shadow_check"
    "mini_rt"
)

LEVELS=(0 0 0 0 0 1 1 1 1 2 2 2 2 2 3 3 3 4 4 4 4 5 5 5 5)
POINTS=(4 4 4 4 4 8 8 8 8 12 12 12 12 12 16 16 16 20 20 20 20 28 28 28 28)

TOTAL_POSSIBLE=0
for p in "${POINTS[@]}"; do
    TOTAL_POSSIBLE=$((TOTAL_POSSIBLE + p))
done

# ── Fonctions utilitaires ───────────────────────────────────────────────────
clear_screen() {
    clear
}

print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║${RESET}${BOLD}${CYAN}        ███████╗██╗  ██╗ █████╗ ███╗   ███╗                 ${RESET}${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}${BOLD}${CYAN}        ██╔════╝╚██╗██╔╝██╔══██╗████╗ ████║                 ${RESET}${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}${BOLD}${CYAN}        █████╗   ╚███╔╝ ███████║██╔████╔██║                 ${RESET}${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}${BOLD}${CYAN}        ██╔══╝   ██╔██╗ ██╔══██║██║╚██╔╝██║                 ${RESET}${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}${BOLD}${CYAN}        ███████╗██╔╝ ██╗██║  ██║██║ ╚═╝ ██║                 ${RESET}${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}${BOLD}${CYAN}        ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝                 ${RESET}${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}                                                              ${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}  ${BOLD}${YELLOW}            E X A M S H E L L   4 2${RESET}                        ${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}  ${DIM}       25 exercices • C basics → Raytracer${RESET}               ${BLUE}║${RESET}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_separator() {
    echo -e "${DIM}──────────────────────────────────────────────────────────────${RESET}"
}

show_subject() {
    local exo_idx=$1
    local exo="${EXERCISES[$exo_idx]}"
    local subject_file="$SUBJECTS_DIR/$exo/subject.txt"

    if [ ! -f "$subject_file" ]; then
        echo -e "${RED}Erreur: sujet introuvable: $subject_file${RESET}"
        return 1
    fi

    echo -e "${MAGENTA}${BOLD}═══ SUJET ═══${RESET}"
    echo ""
    cat "$subject_file"
    echo ""
    print_separator
}

show_progress_bar() {
    local current=$1
    local total=${#EXERCISES[@]}
    local width=40
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "${CYAN}Progression: [${RESET}"
    printf "${GREEN}"
    for ((i=0; i<filled; i++)); do printf "█"; done
    printf "${DIM}"
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "${RESET}${CYAN}] %d/%d${RESET}\n" "$current" "$total"
}

format_time() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(( (total_seconds % 3600) / 60 ))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $seconds
}

# ── Boucle principale ───────────────────────────────────────────────────────
main() {
    rm -rf "$RENDU_DIR"
    clear_screen
    print_header

    echo -e "${BOLD}Bienvenue dans l'examshell 42 !${RESET}"
    echo ""
    echo -e "${DIM}Règles :${RESET}"
    echo -e "  • Tu as 10 exercices de difficulté croissante (niveaux 0 → 4)"
    echo -e "  • Code ta solution dans ${CYAN}rendu/<nom_exo>/${RESET}"
    echo -e "  • Tape ${GREEN}${BOLD}grademe${RESET} pour lancer la moulinette"
    echo -e "  • Tape ${YELLOW}subject${RESET} pour revoir le sujet"
    echo -e "  • Tape ${RED}quit${RESET} pour quitter"
    echo ""
    echo -e "${BOLD}Compilation: ${CYAN}cc -Wall -Wextra -Werror${RESET}"
    echo ""
    print_separator
    echo ""

    START_TIME=$(date +%s)
    SCORE=0
    RESULTS=()
    current=0

    while [ $current -lt ${#EXERCISES[@]} ]; do
        exo="${EXERCISES[$current]}"
        exname="${EXNAMES[$current]}"
        level="${LEVELS[$current]}"
        points="${POINTS[$current]}"

        # Créer le dossier de rendu
        mkdir -p "$RENDU_DIR/$exname"

        echo ""
        print_separator
        show_progress_bar $current

        echo ""
        echo -e "${BOLD}${YELLOW}► Exercice $((current + 1))/10 : ${CYAN}$exname${RESET} ${DIM}(niveau $level — $points pts)${RESET}"
        echo ""

        # Afficher le sujet
        show_subject $current
        echo ""
        echo -e "> Ton rendu : ${CYAN}rendu/$exname/${RESET}"
        echo ""

        # Shell interactif pour cet exercice
        local passed=0
        while [ $passed -eq 0 ]; do
            NOW=$(date +%s)
            ELAPSED=$((NOW - START_TIME))
            echo -ne "${DIM}[$(format_time $ELAPSED)]${RESET} ${BOLD}examshell>${RESET} "
            read -r cmd

            case "$cmd" in
                grademe)
                    echo ""
                    echo -e "${YELLOW}${BOLD}>>> Moulinette en cours...${RESET}"
                    echo ""

                    # Lancer la moulinette
                    bash "$GRADEME" "$current" "$RENDU_DIR/$exname" "$SCRIPT_DIR"
                    result=$?

                    if [ $result -eq 0 ]; then
                        echo ""
                        echo -e "${GREEN}${BOLD}[OK] Exercice $exname valide ! (+$points pts)${RESET}"
                        SCORE=$((SCORE + points))
                        RESULTS+=("${GREEN}[OK] $exname (+$points pts)${RESET}")
                        passed=1
                        sleep 2
                    else
                        echo ""
                        echo -e "${RED}${BOLD}[KO] Exercice $exname echoue. Corrige et relance grademe.${RESET}"
                        RESULTS_TMP="${RED}[KO] $exname (0 pts)${RESET}"
                        echo ""
                    fi
                    ;;
                subject)
                    echo ""
                    show_subject $current
                    ;;
                quit|exit)
                    RESULTS+=("${RED}[KO] $exname (abandonne)${RESET}")
                    for ((j=current+1; j<${#EXERCISES[@]}; j++)); do
                        RESULTS+=("${DIM} -- ${EXNAMES[$j]} (non tente)${RESET}")
                    done
                    current=${#EXERCISES[@]}
                    passed=1
                    ;;
                status)
                    echo ""
                    echo -e "${BOLD}Score actuel : ${CYAN}$SCORE${RESET}/${TOTAL_POSSIBLE} pts"
                    show_progress_bar $current
                    echo ""
                    ;;
                help)
                    echo ""
                    echo -e "${BOLD}Commandes disponibles :${RESET}"
                    echo -e "  ${GREEN}grademe${RESET}  — Lancer la moulinette"
                    echo -e "  ${YELLOW}subject${RESET}  — Revoir le sujet"
                    echo -e "  ${CYAN}status${RESET}   — Voir ton score"
                    echo -e "  ${CYAN}help${RESET}     — Cette aide"
                    echo -e "  ${RED}quit${RESET}     — Quitter l'exam"
                    echo ""
                    ;;
                "")
                    ;;
                *)
                    echo -e "${DIM}Commande inconnue. Tape ${RESET}${BOLD}help${RESET}${DIM} pour la liste.${RESET}"
                    ;;
            esac
        done

        current=$((current + 1))
    done

    # ── Récapitulatif final ──────────────────────────────────────────────────
    END_TIME=$(date +%s)
    TOTAL_TIME=$((END_TIME - START_TIME))

    clear_screen
    print_header

    echo -e "${BOLD}${YELLOW}══════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${YELLOW}           RÉSULTATS DE L'EXAMEN          ${RESET}"
    echo -e "${BOLD}${YELLOW}══════════════════════════════════════════${RESET}"
    echo ""

    for r in "${RESULTS[@]}"; do
        echo -e "  $r"
    done

    echo ""
    print_separator
    echo ""

    local pct=0
    if [ $TOTAL_POSSIBLE -gt 0 ]; then
        pct=$((SCORE * 100 / TOTAL_POSSIBLE))
    fi

    echo -e "${BOLD}Score final : ${CYAN}$SCORE${RESET} / ${TOTAL_POSSIBLE} pts ${DIM}($pct%)${RESET}"
    echo -e "${BOLD}Durée totale : ${CYAN}$(format_time $TOTAL_TIME)${RESET}"
    echo ""

    if [ $pct -ge 80 ]; then
        echo -e "${GREEN}${BOLD}*** Excellent ! Tu as tout defonce !${RESET}"
    elif [ $pct -ge 50 ]; then
        echo -e "${YELLOW}${BOLD}** Pas mal ! Continue a t'entrainer.${RESET}"
    elif [ $pct -ge 25 ]; then
        echo -e "${YELLOW}* Courage, ca va venir !${RESET}"
    else
        echo -e "${RED}Faut bosser les bases, mais t'inquiete ca vient avec la pratique.${RESET}"
    fi

    echo ""
    print_separator
    echo -e "${DIM}Examshell 42 — Merci d'avoir passe l'exam !${RESET}"
    echo ""
    rm -rf "$RENDU_DIR"
}

main "$@"
