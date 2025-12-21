#!/bin/bash
# Script d'installation du patch français BLACK SOULS
# Copie les fichiers traduits et crée les fichiers audio avec les noms français

set -u  # Erreur si variable non définie

# Compteurs
SUCCESS=0
ERRORS=0
GAME_DIR=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Chemins possibles du jeu (Linux)
POSSIBLE_PATHS=(
    "$HOME/.steam/steam/steamapps/common/BLACK SOULS"
    "$HOME/.local/share/Steam/steamapps/common/BLACK SOULS"
    "$HOME/.steam/debian-installation/steamapps/common/BLACK SOULS"
    "$HOME/Games/BLACK SOULS"
    "/opt/BLACK SOULS"
)

# Fonction pour copier un fichier avec gestion d'erreur
copy_audio() {
    local src="$1"
    local dst="$2"
    if [ -f "$src" ]; then
        if cp "$src" "$dst" 2>/dev/null; then
            SUCCESS=$((SUCCESS + 1))
            return 0
        else
            echo "ERREUR: Impossible de copier $src -> $dst"
            ERRORS=$((ERRORS + 1))
            return 1
        fi
    fi
    return 0  # Fichier source n'existe pas, pas une erreur
}

# Fonction pour vérifier si un dossier est le dossier du jeu
is_game_directory() {
    local dir="$1"
    [ -d "$dir/Audio" ] && [ -d "$dir/Data" ] && [ -d "$dir/Audio/BGS" ] && [ -d "$dir/Audio/SE" ]
}

echo "Installation du patch français BLACK SOULS..."
echo ""

# Chercher le dossier du jeu
echo "Recherche du dossier du jeu..."

for path in "${POSSIBLE_PATHS[@]}"; do
    if is_game_directory "$path"; then
        GAME_DIR="$path"
        break
    fi
done

# Si pas trouvé, demander à l'utilisateur
if [ -z "$GAME_DIR" ]; then
    echo ""
    echo "ERREUR: Impossible de trouver le dossier du jeu BLACK SOULS."
    echo ""
    echo "Chemins vérifiés:"
    for path in "${POSSIBLE_PATHS[@]}"; do
        echo "  - $path"
    done
    echo ""
    echo "Solutions:"
    echo "  1. Exécutez ce script depuis le dossier du jeu"
    echo "  2. Ou spécifiez le chemin: $0 /chemin/vers/BLACK\\ SOULS"
    exit 1
fi

# Permettre de spécifier un chemin en argument
if [ $# -ge 1 ]; then
    if is_game_directory "$1"; then
        GAME_DIR="$1"
    else
        echo "ERREUR: '$1' n'est pas un dossier de jeu valide"
        exit 1
    fi
fi

echo "Dossier du jeu trouvé: $GAME_DIR"

# === ÉTAPE 1: Copier les fichiers Data traduits ===
echo ""
echo "Installation des fichiers de traduction..."

if [ -d "$SCRIPT_DIR/Data" ]; then
    # Créer le dossier Data s'il n'existe pas
    mkdir -p "$GAME_DIR/Data"

    # Copier tous les fichiers .rvdata2
    DATA_COUNT=0
    for file in "$SCRIPT_DIR/Data/"*.rvdata2; do
        if [ -f "$file" ]; then
            cp "$file" "$GAME_DIR/Data/" && DATA_COUNT=$((DATA_COUNT + 1))
        fi
    done
    echo "  $DATA_COUNT fichiers de données copiés"
else
    echo "ATTENTION: Dossier Data/ non trouvé dans le patch"
    echo "           Seuls les fichiers audio seront installés"
fi

# Désactiver l'archive pour forcer le chargement depuis Data/
if [ -f "$GAME_DIR/Game.rgss3a" ]; then
    mv "$GAME_DIR/Game.rgss3a" "$GAME_DIR/Game.rgss3a.disabled"
    echo "  Archive Game.rgss3a désactivée"
fi

cd "$GAME_DIR" || exit 2

# === ÉTAPE 2: Créer les fichiers audio avec noms français ===
echo ""

# Vérifier que les sous-dossiers Audio existent
if [ ! -d "Audio/BGS" ]; then
    echo "ERREUR: Le dossier Audio/BGS n'existe pas"
    exit 2
fi

if [ ! -d "Audio/SE" ]; then
    echo "ERREUR: Le dossier Audio/SE n'existe pas"
    exit 2
fi

# Vérifier les permissions d'écriture
if [ ! -w "Audio/BGS" ]; then
    echo "ERREUR: Pas de permission d'écriture dans Audio/BGS"
    echo "        Essayez d'exécuter ce script en tant qu'administrateur"
    exit 3
fi

if [ ! -w "Audio/SE" ]; then
    echo "ERREUR: Pas de permission d'écriture dans Audio/SE"
    echo "        Essayez d'exécuter ce script en tant qu'administrateur"
    exit 3
fi

# BGS (Background Sounds)
cd Audio/BGS || exit 2
copy_audio "Fire.ogg" "Feu.ogg"
copy_audio "Fire.ogg" "FEU.ogg"
copy_audio "Wind.ogg" "Vent.ogg"
copy_audio "Wind.ogg" "VENT.ogg"
copy_audio "Darkness.ogg" "Ténèbres.ogg"
copy_audio "Darkness.ogg" "TÉNÈBRES.ogg"
cd ../..

# SE (Sound Effects)
cd Audio/SE || exit 2

# Fire -> Feu
for i in 1 2 3 4 5 6 7 8 9; do
    copy_audio "Fire$i.ogg" "Feu$i.ogg"
    copy_audio "Fire$i.ogg" "FEU$i.ogg"
done

# Wind -> Vent
for i in 1 2 3 4 5 6 7 8 9 10 11; do
    copy_audio "Wind$i.ogg" "Vent$i.ogg"
    copy_audio "Wind$i.ogg" "VENT$i.ogg"
done

# Water -> Eau
for i in 1 2 3 4 5 6 10; do
    copy_audio "Water$i.ogg" "Eau$i.ogg"
    copy_audio "Water$i.ogg" "EAU$i.ogg"
done

# Darkness -> Ténèbres
for i in 1 2 3 4 5 6 7 8; do
    copy_audio "Darkness$i.ogg" "Ténèbres$i.ogg"
    copy_audio "Darkness$i.ogg" "TÉNÈBRES$i.ogg"
done

# Chicken -> Poulet
copy_audio "Chicken.ogg" "Poulet.ogg"
copy_audio "Chicken.ogg" "POULET.ogg"

# Attack -> Attaque
for i in 1 2 3; do
    copy_audio "Attack$i.ogg" "Attaque$i.ogg"
    copy_audio "Attack$i.ogg" "ATTAQUE$i.ogg"
done

# Ice -> Glace
for i in 1 2 3 4 5 6 7 8 9 10 11; do
    copy_audio "Ice$i.ogg" "Glace$i.ogg"
    copy_audio "Ice$i.ogg" "GLACE$i.ogg"
done

# Thunder -> Tonnerre
for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    copy_audio "Thunder$i.ogg" "Tonnerre$i.ogg"
    copy_audio "Thunder$i.ogg" "TONNERRE$i.ogg"
done

# Heal -> Soin
for i in 1 2 3 4 5 6 7; do
    copy_audio "Heal$i.ogg" "Soin$i.ogg"
    copy_audio "Heal$i.ogg" "SOIN$i.ogg"
done

cd ../..

# Résumé
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "Installation terminée! ($SUCCESS fichiers créés)"
    echo ""
    echo "Si ce projet vous plaît, pensez à mettre ce dépôt en favori !"
    echo "GitHub : https://github.com/SatanBoucheUnCoin"
    echo "Twitter : https://x.com/Satan_Boucanes"
    echo ""
    echo "Vous pouvez maintenant lancer le jeu."
    exit 0
else
    echo "Installation terminée avec $ERRORS erreur(s). ($SUCCESS fichiers créés)"
    echo "Certains fichiers n'ont pas pu être copiés."
    exit 4
fi
