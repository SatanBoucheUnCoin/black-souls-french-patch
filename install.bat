@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Script d'installation du patch français BLACK SOULS
REM Copie les fichiers traduits et crée les fichiers audio avec les noms français

set SUCCESS=0
set ERRORS=0
set GAME_DIR=
set SCRIPT_DIR=%~dp0

echo Installation du patch francais BLACK SOULS...
echo.
echo Recherche du dossier du jeu...

REM Chemins possibles du jeu (Windows)
REM Vérifier le dossier courant d'abord
if exist "Audio\BGS" if exist "Audio\SE" if exist "Data" (
    set "GAME_DIR=%CD%"
    goto :found
)

REM Steam par défaut
if exist "C:\Program Files (x86)\Steam\steamapps\common\BLACK SOULS\Audio\BGS" (
    set "GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\BLACK SOULS"
    goto :found
)

REM Steam sur D:
if exist "D:\Steam\steamapps\common\BLACK SOULS\Audio\BGS" (
    set "GAME_DIR=D:\Steam\steamapps\common\BLACK SOULS"
    goto :found
)

REM Steam sur D: (SteamLibrary)
if exist "D:\SteamLibrary\steamapps\common\BLACK SOULS\Audio\BGS" (
    set "GAME_DIR=D:\SteamLibrary\steamapps\common\BLACK SOULS"
    goto :found
)

REM Steam sur E:
if exist "E:\Steam\steamapps\common\BLACK SOULS\Audio\BGS" (
    set "GAME_DIR=E:\Steam\steamapps\common\BLACK SOULS"
    goto :found
)

REM Steam sur E: (SteamLibrary)
if exist "E:\SteamLibrary\steamapps\common\BLACK SOULS\Audio\BGS" (
    set "GAME_DIR=E:\SteamLibrary\steamapps\common\BLACK SOULS"
    goto :found
)

REM Program Files
if exist "C:\Program Files\BLACK SOULS\Audio\BGS" (
    set "GAME_DIR=C:\Program Files\BLACK SOULS"
    goto :found
)

REM Games
if exist "C:\Games\BLACK SOULS\Audio\BGS" (
    set "GAME_DIR=C:\Games\BLACK SOULS"
    goto :found
)

REM Pas trouvé
echo.
echo ERREUR: Impossible de trouver le dossier du jeu BLACK SOULS.
echo.
echo Chemins verifies:
echo   - Dossier courant
echo   - C:\Program Files ^(x86^)\Steam\steamapps\common\BLACK SOULS
echo   - D:\Steam\steamapps\common\BLACK SOULS
echo   - D:\SteamLibrary\steamapps\common\BLACK SOULS
echo   - E:\Steam\steamapps\common\BLACK SOULS
echo   - C:\Program Files\BLACK SOULS
echo   - C:\Games\BLACK SOULS
echo.
echo Solutions:
echo   1. Executez ce script depuis le dossier du jeu
echo   2. Ou copiez ce script dans le dossier du jeu
pause
exit /b 1

:found
echo Dossier du jeu trouve: !GAME_DIR!

REM === ETAPE 1: Copier les fichiers Data traduits ===
echo.
echo Installation des fichiers de traduction...

if exist "!SCRIPT_DIR!Data\" (
    if not exist "!GAME_DIR!\Data\" mkdir "!GAME_DIR!\Data"
    set DATA_COUNT=0
    for %%f in ("!SCRIPT_DIR!Data\*.rvdata2") do (
        copy "%%f" "!GAME_DIR!\Data\" >nul 2>&1 && set /a DATA_COUNT+=1
    )
    echo   !DATA_COUNT! fichiers de donnees copies
) else (
    echo ATTENTION: Dossier Data\ non trouve dans le patch
    echo            Seuls les fichiers audio seront installes
)

REM Desactiver l'archive pour forcer le chargement depuis Data
if exist "!GAME_DIR!\Game.rgss3a" (
    ren "!GAME_DIR!\Game.rgss3a" "Game.rgss3a.disabled"
    echo   Archive Game.rgss3a desactivee
)

cd /d "!GAME_DIR!"

REM === ETAPE 2: Creer les fichiers audio avec noms francais ===


REM Vérifier que les sous-dossiers Audio existent
if not exist "Audio\BGS" (
    echo ERREUR: Le dossier Audio\BGS n'existe pas
    pause
    exit /b 2
)

if not exist "Audio\SE" (
    echo ERREUR: Le dossier Audio\SE n'existe pas
    pause
    exit /b 2
)

REM Tester les permissions d'écriture
echo test > "Audio\BGS\_test_write.tmp" 2>nul
if errorlevel 1 (
    echo ERREUR: Pas de permission d'ecriture dans Audio\BGS
    echo         Essayez d'executer ce script en tant qu'administrateur
    pause
    exit /b 3
)
del "Audio\BGS\_test_write.tmp" 2>nul

echo test > "Audio\SE\_test_write.tmp" 2>nul
if errorlevel 1 (
    echo ERREUR: Pas de permission d'ecriture dans Audio\SE
    echo         Essayez d'executer ce script en tant qu'administrateur
    pause
    exit /b 3
)
del "Audio\SE\_test_write.tmp" 2>nul


REM BGS (Background Sounds)
cd Audio\BGS
if exist "Fire.ogg" (
    copy "Fire.ogg" "Feu.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
)
if exist "Wind.ogg" (
    copy "Wind.ogg" "Vent.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
)
if exist "Darkness.ogg" (
    copy "Darkness.ogg" "Ténèbres.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
)
cd ..\..

REM SE (Sound Effects)
cd Audio\SE

REM Fire -> Feu
for %%i in (1 2 3 4 5 6 7 8 9) do (
    if exist "Fire%%i.ogg" (
        copy "Fire%%i.ogg" "Feu%%i.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
    )
)

REM Wind -> Vent
for %%i in (1 2 3 4 5 6 7 8 9 10 11) do (
    if exist "Wind%%i.ogg" (
        copy "Wind%%i.ogg" "Vent%%i.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
    )
)

REM Water -> Eau
for %%i in (1 2 3 4 5 6 10) do (
    if exist "Water%%i.ogg" (
        copy "Water%%i.ogg" "Eau%%i.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
    )
)

REM Darkness -> Ténèbres
for %%i in (1 2 3 4 5 6 7 8) do (
    if exist "Darkness%%i.ogg" (
        copy "Darkness%%i.ogg" "Ténèbres%%i.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
    )
)

REM Chicken -> Poulet
if exist "Chicken.ogg" (
    copy "Chicken.ogg" "Poulet.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
)

REM Attack -> Attaque
for %%i in (1 2 3) do (
    if exist "Attack%%i.ogg" (
        copy "Attack%%i.ogg" "Attaque%%i.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
    )
)

REM Ice -> Glace
for %%i in (1 2 3 4 5 6 7 8 9 10 11) do (
    if exist "Ice%%i.ogg" (
        copy "Ice%%i.ogg" "Glace%%i.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
    )
)

REM Thunder -> Tonnerre
for %%i in (1 2 3 4 5 6 7 8 9 10 11 12) do (
    if exist "Thunder%%i.ogg" (
        copy "Thunder%%i.ogg" "Tonnerre%%i.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
    )
)

REM Heal -> Soin
for %%i in (1 2 3 4 5 6 7) do (
    if exist "Heal%%i.ogg" (
        copy "Heal%%i.ogg" "Soin%%i.ogg" >nul 2>&1 && set /a SUCCESS+=1 || set /a ERRORS+=1
    )
)

cd ..\..

REM Résumé
echo.
if !ERRORS! EQU 0 (
    echo Installation terminee! ^(!SUCCESS! fichiers crees^)
    echo.
    echo Si ce projet vous plait, pensez a mettre ce depot en favori !
    echo GitHub : https://github.com/SatanBoucheUnCoin
    echo Twitter : https://x.com/Satan_Boucanes
    echo.
    echo Vous pouvez maintenant lancer le jeu.
    pause
    exit /b 0
) else (
    echo Installation terminee avec !ERRORS! erreur^(s^). ^(!SUCCESS! fichiers crees^)
    echo Certains fichiers n'ont pas pu etre copies.
    pause
    exit /b 4
)
