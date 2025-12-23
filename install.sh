#!/bin/bash
# Script d'installation du patch français BLACK SOULS

set -u

SUCCESS=0
ERRORS=0
GAME_DIR=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Chemins possibles du jeu
POSSIBLE_PATHS=(
    "$HOME/.steam/steam/steamapps/common/BLACK SOULS"
    "$HOME/.local/share/Steam/steamapps/common/BLACK SOULS"
    "$HOME/.steam/debian-installation/steamapps/common/BLACK SOULS"
    "$HOME/Games/BLACK SOULS"
    "/opt/BLACK SOULS"
)

# Mappings audio: "source:destination:max" (0 = pas de numéro)
AUDIO_BGS=("Fire:Feu:0" "Wind:Vent:0" "Darkness:Ténèbres:0")
AUDIO_SE=(
    "Fire:Feu:9" "Wind:Vent:11" "Ice:Glace:11" "Thunder:Tonnerre:12"
    "Heal:Soin:7" "Darkness:Ténèbres:8" "Attack:Attaque:3" "Chicken:Poulet:0"
)
AUDIO_SE_SPECIAL=("Water:Eau:1 2 3 4 5 6 10")

is_game_directory() { [[ -d "$1/Audio/BGS" && -d "$1/Audio/SE" && -d "$1/Data" ]]; }

copy_audio() {
    local src="$1" dst="$2"
    [[ -f "$src" ]] && cp "$src" "$dst" 2>/dev/null && ((SUCCESS++))
}

copy_numbered() {
    local en="$1" fr="$2" max="$3"
    local FR_UPPER="${fr^^}"
    if [[ "$max" == "0" ]]; then
        copy_audio "$en.ogg" "$fr.ogg"
        copy_audio "$en.ogg" "$FR_UPPER.ogg"
    else
        for i in $(seq 1 "$max"); do
            copy_audio "$en$i.ogg" "$fr$i.ogg"
            copy_audio "$en$i.ogg" "$FR_UPPER$i.ogg"
        done
    fi
}

echo "Installation du patch français BLACK SOULS..."
echo ""
echo "Recherche du dossier du jeu..."

# Chercher le jeu
for path in "${POSSIBLE_PATHS[@]}"; do
    is_game_directory "$path" && GAME_DIR="$path" && break
done

# Argument en ligne de commande
if [[ $# -ge 1 ]]; then
    if is_game_directory "$1"; then
        GAME_DIR="$1"
    else
        echo "ERREUR: '$1' n'est pas un dossier de jeu valide"
        exit 1
    fi
fi

if [[ -z "$GAME_DIR" ]]; then
    echo -e "\nERREUR: Impossible de trouver le dossier du jeu.\n"
    printf "  - %s\n" "${POSSIBLE_PATHS[@]}"
    echo -e "\nSpécifiez le chemin: $0 /chemin/vers/BLACK\\ SOULS"
    exit 1
fi

echo "Dossier du jeu trouvé: $GAME_DIR"

# === ÉTAPE 1: Copier Data ===
echo -e "\nInstallation des fichiers de traduction..."

if [[ -d "$SCRIPT_DIR/Data" ]]; then
    mkdir -p "$GAME_DIR/Data"
    DATA_COUNT=$(find "$SCRIPT_DIR/Data" -name "*.rvdata2" -exec cp {} "$GAME_DIR/Data/" \; -print | wc -l)
    echo "  $DATA_COUNT fichiers de données copiés"
else
    echo "ATTENTION: Dossier Data/ non trouvé"
fi

# Désactiver l'archive
[[ -f "$GAME_DIR/Game.rgss3a" ]] && mv "$GAME_DIR/Game.rgss3a" "$GAME_DIR/Game.rgss3a.disabled" && echo "  Archive désactivée"

# Copier steam_api.dll (nécessaire pour Steam Deck/Proton)
if [[ -f "$SCRIPT_DIR/steam_api.dll" ]]; then
    cp "$SCRIPT_DIR/steam_api.dll" "$GAME_DIR/" && echo "  steam_api.dll copié"
fi

# === ÉTAPE 2: Audio ===
#    ╔═══════════════════════════════════════════════════════════╗
#    ║  Qu'est-ce que tu cherches exactement ?                   ║
#    ╚═══════════════════════════════════════════════════════════╝

echo -e "\nInstallation des fichiers audio..."

if [[ -d "$SCRIPT_DIR/Audio" ]]; then
    for subdir in BGS SE; do
        [[ -d "$SCRIPT_DIR/Audio/$subdir" ]] && {
            mkdir -p "$GAME_DIR/Audio/$subdir"
            for f in "$SCRIPT_DIR/Audio/$subdir/"*.ogg; do
                [[ -f "$f" ]] && cp "$f" "$GAME_DIR/Audio/$subdir/" && ((SUCCESS++))
            done
        }
    done
    echo "  $SUCCESS fichiers audio copiés (depuis le patch)"
else
    echo "  Création depuis le jeu..."

    # BGS
    cd "$GAME_DIR/Audio/BGS" 2>/dev/null && {
        for mapping in "${AUDIO_BGS[@]}"; do
            IFS=':' read -r en fr max <<< "$mapping"
            copy_numbered "$en" "$fr" "$max"
        done
        cd "$GAME_DIR"
    }

    # SE
    cd "$GAME_DIR/Audio/SE" 2>/dev/null && {
        for mapping in "${AUDIO_SE[@]}"; do
            IFS=':' read -r en fr max <<< "$mapping"
            copy_numbered "$en" "$fr" "$max"
        done
        # Water (numéros spéciaux)
        for i in 1 2 3 4 5 6 10; do
            copy_audio "Water$i.ogg" "Eau$i.ogg"
            copy_audio "Water$i.ogg" "EAU$i.ogg"
        done
        cd "$GAME_DIR"
    }
    echo "  $SUCCESS fichiers audio créés (depuis le jeu)"
fi

# Résumé
echo ""
if [[ $ERRORS -eq 0 ]]; then
    echo "Installation terminée! ($SUCCESS fichiers)"
    echo -e "\nVous pouvez maintenant lancer le jeu."
    exit 0
else
    echo "Installation terminée avec $ERRORS erreur(s)."
    exit 4
fi
