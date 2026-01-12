#!/bin/bash
#
# BLACK SOULS - Installateur du Patch Français
# Version: 0.3.0
#
# Compatible: Linux, Steam Deck, toutes distros
# GUI: Zenity (GNOME/SteamOS), kdialog (KDE), ou mode CLI
#

set -euo pipefail

readonly VERSION="0.3.0"
readonly STEAM_APPID="3755860"
readonly GAME_FOLDER="BLACK SOULS"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Couleurs pour le terminal
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Mode GUI détecté
GUI_MODE=""

#=============================================================================
# LOGGING
#=============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

#=============================================================================
# DÉTECTION GUI
#=============================================================================

detect_gui() {
    # Vérifier si on a un display
    if [[ -z "${DISPLAY:-}" ]] && [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
        log_info "Pas de display détecté, mode CLI"
        return
    fi

    # Priorité: zenity (GNOME/SteamOS) > kdialog (KDE) > yad
    if command -v zenity &> /dev/null; then
        GUI_MODE="zenity"
        log_info "GUI détectée: Zenity"
    elif command -v kdialog &> /dev/null; then
        GUI_MODE="kdialog"
        log_info "GUI détectée: KDialog"
    elif command -v yad &> /dev/null; then
        GUI_MODE="yad"
        log_info "GUI détectée: YAD"
    else
        log_info "Pas de GUI disponible, mode CLI"
    fi
}

#=============================================================================
# FONCTIONS GUI / CLI
#=============================================================================

show_info() {
    local title="$1"
    local message="$2"

    case "$GUI_MODE" in
        zenity)
            zenity --info --title="$title" --text="$message" \
                   --width=450 --height=150 2>/dev/null || true
            ;;
        kdialog)
            kdialog --title "$title" --msgbox "$message" 2>/dev/null || true
            ;;
        yad)
            yad --title="$title" --text="$message" --button=OK:0 \
                --width=450 --height=150 2>/dev/null || true
            ;;
        *)
            echo ""
            echo -e "${GREEN}=== $title ===${NC}"
            echo -e "$message"
            echo ""
            ;;
    esac
}

show_error() {
    local title="$1"
    local message="$2"

    case "$GUI_MODE" in
        zenity)
            zenity --error --title="$title" --text="$message" \
                   --width=400 2>/dev/null || true
            ;;
        kdialog)
            kdialog --title "$title" --error "$message" 2>/dev/null || true
            ;;
        yad)
            yad --title="$title" --text="$message" --button=OK:0 \
                --image=dialog-error --width=400 2>/dev/null || true
            ;;
        *)
            log_error "$message"
            ;;
    esac
}

show_question() {
    local title="$1"
    local message="$2"

    case "$GUI_MODE" in
        zenity)
            zenity --question --title="$title" --text="$message" \
                   --width=450 2>/dev/null
            return $?
            ;;
        kdialog)
            kdialog --title "$title" --yesno "$message" 2>/dev/null
            return $?
            ;;
        yad)
            yad --title="$title" --text="$message" \
                --button=Oui:0 --button=Non:1 --width=450 2>/dev/null
            return $?
            ;;
        *)
            echo ""
            echo -e "${YELLOW}$message${NC}"
            read -p "Continuer? [O/n] " -n 1 -r
            echo ""
            [[ -z "$REPLY" || $REPLY =~ ^[OoYy]$ ]]
            return $?
            ;;
    esac
}

select_directory() {
    local title="$1"
    local start_dir="${2:-$HOME}"
    local result=""

    case "$GUI_MODE" in
        zenity)
            result=$(zenity --file-selection --directory \
                           --title="$title" \
                           --filename="$start_dir/" 2>/dev/null) || true
            ;;
        kdialog)
            result=$(kdialog --title "$title" \
                            --getexistingdirectory "$start_dir" 2>/dev/null) || true
            ;;
        yad)
            result=$(yad --file --directory \
                        --title="$title" \
                        --filename="$start_dir/" 2>/dev/null) || true
            ;;
        *)
            echo ""
            echo -e "${YELLOW}$title${NC}"
            echo "Chemin par défaut: $start_dir"
            read -p "Entrez le chemin (ou appuyez sur Entrée pour le défaut): " result
            if [[ -z "$result" ]]; then
                result="$start_dir"
            fi
            ;;
    esac

    echo "$result"
}

#=============================================================================
# DÉTECTION STEAM
#=============================================================================

find_steam_root() {
    local paths=(
        "$HOME/.steam/steam"
        "$HOME/.local/share/Steam"
        "$HOME/.steam/debian-installation"
        "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"  # Flatpak
        "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"        # Flatpak alt
    )

    for path in "${paths[@]}"; do
        if [[ -d "$path/steamapps" ]]; then
            log_info "Steam trouvé: $path"
            echo "$path"
            return 0
        fi
    done

    log_warning "Installation Steam non trouvée"
    return 1
}

# Parse libraryfolders.vdf pour obtenir toutes les bibliothèques Steam
get_steam_libraries() {
    local steam_root="$1"
    local vdf_file="$steam_root/steamapps/libraryfolders.vdf"

    # Toujours inclure le dossier Steam principal
    echo "$steam_root"

    if [[ ! -f "$vdf_file" ]]; then
        log_warning "libraryfolders.vdf non trouvé"
        return
    fi

    # Extraire les chemins des bibliothèques
    # Format: "path"		"/chemin/vers/library"
    grep -oP '"path"\s*"\K[^"]+' "$vdf_file" 2>/dev/null | while read -r path; do
        # Ignorer le chemin principal (déjà ajouté)
        if [[ "$path" != "$steam_root" ]]; then
            echo "$path"
        fi
    done
}

# Cherche le jeu dans toutes les bibliothèques Steam
find_game() {
    local steam_root

    if ! steam_root=$(find_steam_root); then
        return 1
    fi

    log_info "Recherche du jeu dans les bibliothèques Steam..."

    while IFS= read -r library; do
        # Gérer les deux conventions de nommage (steamapps vs SteamApps)
        for apps_dir in "steamapps" "SteamApps"; do
            local game_path="$library/$apps_dir/common/$GAME_FOLDER"

            if [[ -f "$game_path/Game.exe" ]] || [[ -f "$game_path/Game.rgss3a" ]]; then
                log_success "Jeu trouvé: $game_path"
                echo "$game_path"
                return 0
            fi
        done
    done < <(get_steam_libraries "$steam_root")

    log_warning "Jeu non trouvé dans les bibliothèques Steam"
    return 1
}

#=============================================================================
# INSTALLATION
#=============================================================================

validate_game_directory() {
    local path="$1"

    if [[ ! -d "$path" ]]; then
        log_error "Le dossier n'existe pas: $path"
        return 1
    fi

    if [[ ! -f "$path/Game.exe" ]] && [[ ! -f "$path/Game.rgss3a" ]]; then
        log_error "Ce dossier ne contient pas BLACK SOULS (Game.exe non trouvé)"
        return 1
    fi

    if [[ ! -w "$path" ]]; then
        log_error "Pas de permission d'écriture dans: $path"
        return 1
    fi

    return 0
}

do_install() {
    local game_path="$1"
    local patch_file="$SCRIPT_DIR/Game.rgss3a"
    local original="$game_path/Game.rgss3a"
    local backup="$game_path/Game.rgss3a.disabled"

    # Vérifier que le patch existe
    if [[ ! -f "$patch_file" ]]; then
        show_error "Erreur" "Fichier Game.rgss3a non trouvé!\n\nCherché dans:\n$patch_file"
        return 1
    fi

    log_info "Installation en cours..."

    # Créer une sauvegarde si nécessaire
    if [[ -f "$original" ]]; then
        if [[ ! -f "$backup" ]]; then
            log_info "Sauvegarde de l'original..."
            if mv "$original" "$backup"; then
                log_success "Backup créé: Game.rgss3a.disabled"
            else
                show_error "Erreur" "Impossible de créer la sauvegarde"
                return 1
            fi
        else
            log_info "Backup existant, suppression de l'ancien patch..."
            rm -f "$original"
        fi
    fi

    # Copier le patch
    log_info "Copie du patch français..."
    if cp "$patch_file" "$original"; then
        log_success "Patch installé avec succès!"
    else
        show_error "Erreur" "Impossible de copier le patch"
        return 1
    fi

    # Copier steam_api.dll pour les achievements Steam
    local steam_api="$SCRIPT_DIR/steam_api.dll"
    if [[ -f "$steam_api" ]]; then
        log_info "Copie de steam_api.dll (achievements Steam)..."
        if cp "$steam_api" "$game_path/steam_api.dll"; then
            log_success "steam_api.dll installé!"
        else
            log_warning "Impossible de copier steam_api.dll"
        fi
    fi

    # Copier les fichiers Audio traduits
    local audio_dir="$SCRIPT_DIR/Audio"
    if [[ -d "$audio_dir" ]]; then
        log_info "Copie des fichiers audio traduits..."
        cp -r "$audio_dir"/* "$game_path/Audio/" 2>/dev/null || true
        log_success "Fichiers audio copiés!"
    fi

    # Copier les polices (Fonts)
    local fonts_dir="$SCRIPT_DIR/Fonts"
    if [[ -d "$fonts_dir" ]]; then
        log_info "Copie des polices..."
        mkdir -p "$game_path/Fonts"
        cp -r "$fonts_dir"/* "$game_path/Fonts/" 2>/dev/null || true
        log_success "Polices copiées!"
    fi

    return 0
}

run_installation_gui() {
    local game_path="$1"
    local patch_file="$SCRIPT_DIR/Game.rgss3a"
    local original="$game_path/Game.rgss3a"
    local backup="$game_path/Game.rgss3a.disabled"

    case "$GUI_MODE" in
        zenity)
            (
                echo "10"
                echo "# Vérification des fichiers..."
                sleep 0.3

                if [[ ! -f "$patch_file" ]]; then
                    echo "# ERREUR: Patch non trouvé!"
                    exit 1
                fi

                echo "30"
                echo "# Sauvegarde de l'original..."

                if [[ -f "$original" ]] && [[ ! -f "$backup" ]]; then
                    mv "$original" "$backup"
                elif [[ -f "$original" ]]; then
                    rm -f "$original"
                fi

                echo "50"
                echo "# Installation du patch français..."
                cp "$patch_file" "$original"

                echo "65"
                echo "# Installation de steam_api.dll..."
                if [[ -f "$SCRIPT_DIR/steam_api.dll" ]]; then
                    cp "$SCRIPT_DIR/steam_api.dll" "$game_path/steam_api.dll" 2>/dev/null || true
                fi

                echo "70"
                echo "# Copie des fichiers audio..."
                if [[ -d "$SCRIPT_DIR/Audio" ]]; then
                    cp -r "$SCRIPT_DIR/Audio"/* "$game_path/Audio/" 2>/dev/null || true
                fi

                echo "85"
                echo "# Copie des polices..."
                if [[ -d "$SCRIPT_DIR/Fonts" ]]; then
                    mkdir -p "$game_path/Fonts"
                    cp -r "$SCRIPT_DIR/Fonts"/* "$game_path/Fonts/" 2>/dev/null || true
                fi

                echo "100"
                echo "# Installation terminée!"
                sleep 0.5

            ) | zenity --progress \
                       --title="Installation du Patch" \
                       --text="Démarrage..." \
                       --percentage=0 \
                       --auto-close \
                       --width=400 2>/dev/null

            return ${PIPESTATUS[0]}
            ;;
        kdialog)
            local dbus_ref
            dbus_ref=$(kdialog --title "Installation" --progressbar "Démarrage..." 100 2>/dev/null)

            qdbus $dbus_ref Set "" value 10 2>/dev/null || true
            qdbus $dbus_ref setLabelText "Vérification des fichiers..." 2>/dev/null || true

            if [[ ! -f "$patch_file" ]]; then
                qdbus $dbus_ref close 2>/dev/null || true
                return 1
            fi

            qdbus $dbus_ref Set "" value 30 2>/dev/null || true
            qdbus $dbus_ref setLabelText "Sauvegarde de l'original..." 2>/dev/null || true

            if [[ -f "$original" ]] && [[ ! -f "$backup" ]]; then
                mv "$original" "$backup"
            elif [[ -f "$original" ]]; then
                rm -f "$original"
            fi

            qdbus $dbus_ref Set "" value 50 2>/dev/null || true
            qdbus $dbus_ref setLabelText "Installation du patch..." 2>/dev/null || true

            cp "$patch_file" "$original"

            qdbus $dbus_ref Set "" value 65 2>/dev/null || true
            qdbus $dbus_ref setLabelText "Installation de steam_api.dll..." 2>/dev/null || true

            if [[ -f "$SCRIPT_DIR/steam_api.dll" ]]; then
                cp "$SCRIPT_DIR/steam_api.dll" "$game_path/steam_api.dll" 2>/dev/null || true
            fi

            qdbus $dbus_ref Set "" value 70 2>/dev/null || true
            qdbus $dbus_ref setLabelText "Copie des fichiers audio..." 2>/dev/null || true

            if [[ -d "$SCRIPT_DIR/Audio" ]]; then
                cp -r "$SCRIPT_DIR/Audio"/* "$game_path/Audio/" 2>/dev/null || true
            fi

            qdbus $dbus_ref Set "" value 85 2>/dev/null || true
            qdbus $dbus_ref setLabelText "Copie des polices..." 2>/dev/null || true

            if [[ -d "$SCRIPT_DIR/Fonts" ]]; then
                mkdir -p "$game_path/Fonts"
                cp -r "$SCRIPT_DIR/Fonts"/* "$game_path/Fonts/" 2>/dev/null || true
            fi

            qdbus $dbus_ref Set "" value 100 2>/dev/null || true
            sleep 0.5
            qdbus $dbus_ref close 2>/dev/null || true

            return 0
            ;;
        *)
            do_install "$game_path"
            return $?
            ;;
    esac
}

#=============================================================================
# MAIN
#=============================================================================

print_banner() {
    echo ""
    echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║                                                  ║${NC}"
    echo -e "${BLUE}${BOLD}║   ${NC}${BOLD}BLACK SOULS - Patch Français v$VERSION${NC}${BLUE}${BOLD}        ║${NC}"
    echo -e "${BLUE}${BOLD}║                                                  ║${NC}"
    echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

main() {
    print_banner
    detect_gui

    local game_path=""

    # Étape 1: Chercher le jeu automatiquement
    log_info "Recherche automatique du jeu..."

    if game_path=$(find_game 2>/dev/null); then
        log_success "Jeu détecté: $game_path"

        if ! show_question "Jeu trouvé" \
            "BLACK SOULS trouvé dans:\n\n$game_path\n\nInstaller le patch français ici?"; then
            log_info "Chemin refusé par l'utilisateur"
            game_path=""
        fi
    else
        log_warning "Jeu non trouvé automatiquement"
    fi

    # Étape 2: Demander le chemin si nécessaire
    if [[ -z "$game_path" ]]; then
        log_info "Sélection manuelle du dossier..."

        local default_dir="$HOME"
        if steam_root=$(find_steam_root 2>/dev/null); then
            default_dir="$steam_root/steamapps/common"
        fi

        game_path=$(select_directory \
            "Sélectionnez le dossier BLACK SOULS" \
            "$default_dir")

        if [[ -z "$game_path" ]]; then
            show_error "Annulé" "Installation annulée par l'utilisateur."
            exit 1
        fi
    fi

    # Étape 3: Valider le dossier
    if ! validate_game_directory "$game_path"; then
        show_error "Erreur" \
            "Le dossier sélectionné n'est pas valide.\n\n$game_path\n\nGame.exe non trouvé."
        exit 1
    fi

    # Étape 4: Installer
    log_info "Dossier validé, installation..."

    if run_installation_gui "$game_path"; then
        show_info "Installation réussie!" \
            "Le patch français a été installé avec succès!\n\nDossier: $game_path\n\nVous pouvez maintenant lancer le jeu via Steam."
        log_success "Installation terminée avec succès!"
        exit 0
    else
        show_error "Échec" "L'installation a échoué.\n\nVérifiez les permissions du dossier."
        exit 1
    fi
}

# Point d'entrée
main "$@"
