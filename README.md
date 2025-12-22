# BLACK SOULS – Patch de Traduction Française

Traduction française non-officielle pour **BLACK SOULS** (RPG Maker VX Ace).

| Info | Détails |
|------|---------|
|  **Version** | Uncensored (18+) |
|  **État** | ~75% traduit |
|  **Prérequis** | Aucun (inclut les corrections du patch anglais) |

---

## Installation

> 💡 **Conseil** : Lancez le jeu une fois avant d'installer le patch pour que tous les fichiers soient créés.

### Méthode automatique (recommandée)

1. Téléchargez et extrayez le patch
2. Exécutez le script d'installation :
   - **Windows** : Double-cliquez sur `install.bat`
   - **Linux** : Exécutez `./install.sh` dans un terminal
3. Lancez le jeu

### Méthode manuelle

1. Localisez votre dossier d'installation de BLACK SOULS :
   - **Steam (Linux)** : `~/.local/share/Steam/steamapps/common/BLACK SOULS/`
   - **Steam (Windows)** : `C:\Program Files (x86)\Steam\steamapps\common\BLACK SOULS\`

   > 💡 *Clic droit sur le jeu dans Steam → Propriétés → Fichiers installés → Parcourir*

2. Renommez `Game.rgss3a` en `Game.rgss3a.disabled`
3. Copiez le contenu du dossier `Data/` du patch dans le dossier `Data/` du jeu
4. Copiez le contenu du dossier `Audio/` du patch dans le dossier `Audio/` du jeu
5. Lancez le jeu

### Désinstallation

1. Supprimez le dossier `Data/` du jeu
2. Renommez `Game.rgss3a.disabled` en `Game.rgss3a`

Le jeu utilisera automatiquement les fichiers originaux contenus dans l'archive.

---

## Dépannage

### Le jeu ne charge pas la traduction

Vérifiez que :
- Le dossier `Data/` est bien placé à la racine du jeu (à côté de `Game.exe`)
- Les fichiers `.rvdata2` sont directement dans `Data/`, et non dans un sous-dossier

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

> ⚠️ Ce patch est une traduction **non-officielle** créée par des fans.
> Le jeu original et l'ensemble de ses contenus appartiennent à leurs créateurs respectifs.
