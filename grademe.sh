#!/bin/bash
# ============================================================================
#  GRADEME — Moulinette de correction
#  Usage: grademe.sh <exo_index> <rendu_path> <project_root>
# ============================================================================

EXO_IDX="$1"
RENDU_PATH="$2"
PROJECT_ROOT="$3"
TESTS_DIR="$PROJECT_ROOT/tests"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Charger les utilitaires
source "$TESTS_DIR/utils.sh"

# Lancer le test correspondant
TEST_SCRIPT="$TESTS_DIR/test_$(printf '%02d' $EXO_IDX).sh"

if [ ! -f "$TEST_SCRIPT" ]; then
    echo -e "${RED}Erreur: script de test introuvable: $TEST_SCRIPT${RESET}"
    exit 1
fi

# Exécuter le script de test
bash "$TEST_SCRIPT" "$RENDU_PATH" "$PROJECT_ROOT"
exit $?
