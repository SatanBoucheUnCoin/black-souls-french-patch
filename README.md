# BLACK SOULS – Patch de Traduction Française

Traduction française non-officielle pour **BLACK SOULS** (RPG Maker VX Ace).

| Info | Détails |
|------|---------|
| **Version** | Uncensored (18+) |
| **État** | ~75% traduit |
| **Prérequis** | Aucun (inclut les corrections du patch anglais) |

---

## Installation

### Windows

1. Téléchargez `BlackSouls_PatchFR_vX.X.X.exe` depuis les [Releases](../../releases)
2. Lancez l'installateur
3. Le jeu sera détecté automatiquement (Steam)
4. Suivez les instructions

> L'installateur crée automatiquement une sauvegarde du fichier original.

### Linux / Steam Deck

1. Téléchargez `install.sh` et `Game.rgss3a` depuis les [Releases](../../releases)
2. Placez les deux fichiers dans le même dossier
3. Exécutez :
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

Le script détecte automatiquement Steam (natif et Flatpak) et propose une interface graphique si disponible (Zenity/KDialog).

### Installation manuelle

1. Localisez votre dossier d'installation de BLACK SOULS :
   - **Steam (Linux)** : `~/.local/share/Steam/steamapps/common/BLACK SOULS/`
   - **Steam (Windows)** : `C:\Program Files (x86)\Steam\steamapps\common\BLACK SOULS\`

   > *Clic droit sur le jeu dans Steam → Propriétés → Fichiers installés → Parcourir*

2. Renommez l'original `Game.rgss3a` en `Game.rgss3a.backup`
3. Copiez le nouveau `Game.rgss3a` du patch dans le dossier
4. Lancez le jeu

### Désinstallation

Dans Steam : *Propriétés → Fichiers installés → Vérifier l'intégrité des fichiers*

Cela restaurera le `Game.rgss3a` original.

---

## Dépannage

### Le jeu ne charge pas la traduction

Vérifiez que `Game.rgss3a` du patch a bien remplacé celui du jeu.

### Mode fenêtré avec mise à l'échelle (Linux)

Utilisez **gamescope** dans les options de lancement Steam.

Exemple pour un scaling 2x sans filtre :
```
LD_PRELOAD="" gamescope -w 640 -h 480 -W 1280 -H 960 -F pixel -r 60 -- %command%
```

---

## À propos de la traduction

Cette traduction est réalisée par **une seule personne**. Il peut donc y avoir :
- Des coquilles ou fautes de frappe
- Des erreurs d'adaptation ou de contexte
- Des incohérences de terminologie

**La traduction est amenée à évoluer.**
Les retours de la communauté sont essentiels pour améliorer la qualité et finaliser le patch.

N'hésitez pas à ouvrir une *issue* ou une *pull request* pour signaler un problème.

---

## Crédits

| Rôle | Nom |
|------|-----|
| Traduction | **PierrePaolo** |
| Développement | **Satan_Bouche_Un_Coin** |
| Jeu original | **Sushi Yuusha Toro** (すしゆうしゃトロ) |

---

## Licence

Ce patch appartient à **PierrePaolo** et **Satan_Bouche_Un_Coin**.
Il est **destiné au public**, librement distribuable, et **ne doit en aucun cas être vendu**.

> Ce patch est une traduction **non-officielle** créée par des fans.
> Le jeu original et l'ensemble de ses contenus appartiennent à leurs créateurs respectifs.
