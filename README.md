# 🎓 Examshell 42

Simulateur d'examen 42 avec 10 exercices C et moulinette exhaustive.

## Lancer l'exam (WSL)

```bash
cd /mnt/c/Users/Neo/Desktop/examshell
chmod +x examshell.sh grademe.sh tests/*.sh
./examshell.sh
```

## Commandes pendant l'exam

| Commande | Description |
|----------|-------------|
| `grademe` | Lancer la moulinette |
| `subject` | Revoir le sujet |
| `status` | Voir ton score |
| `help` | Liste des commandes |
| `quit` | Quitter |

## Les 10 exercices

| # | Exercice | Niveau | Points |
|---|----------|--------|--------|
| 00 | ft_putchar | 0 | 4 pts |
| 01 | ft_strlen | 0 | 4 pts |
| 02 | first_word | 1 | 8 pts |
| 03 | repeat_alpha | 1 | 8 pts |
| 04 | ft_swap | 1 | 8 pts |
| 05 | ft_strrev | 2 | 16 pts |
| 06 | ft_atoi | 2 | 16 pts |
| 07 | ft_range | 3 | 32 pts |
| 08 | ft_split | 3 | 32 pts |
| 09 | fprime | 4 | 64 pts |

**Total: 192 pts**

## Compilation

Tous les fichiers sont compilés avec :
```bash
cc -Wall -Wextra -Werror
```

## Structure

```
examshell/
├── examshell.sh      # Lanceur d'exam
├── grademe.sh        # Moulinette
├── subjects/         # Sujets (10 exercices)
├── tests/            # Tests exhaustifs
└── rendu/            # Ton code (créé au runtime)
```
