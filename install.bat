@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Script d'installation du patch français BLACK SOULS

set SUCCESS=0
set ERRORS=0
set GAME_DIR=
set SCRIPT_DIR=%~dp0

echo Installation du patch francais BLACK SOULS...
echo.
echo Recherche du dossier du jeu...

REM Recherche du jeu dans les chemins courants
for %%P in (
    "%CD%"
    "C:\Program Files (x86)\Steam\steamapps\common\BLACK SOULS"
    "D:\Steam\steamapps\common\BLACK SOULS"
    "D:\SteamLibrary\steamapps\common\BLACK SOULS"
    "E:\Steam\steamapps\common\BLACK SOULS"
    "E:\SteamLibrary\steamapps\common\BLACK SOULS"
    "C:\Program Files\BLACK SOULS"
    "C:\Games\BLACK SOULS"
) do (
    if exist "%%~P\Audio\BGS" if exist "%%~P\Audio\SE" if exist "%%~P\Data" (
        set "GAME_DIR=%%~P"
        goto :found
    )
)

echo.
echo ERREUR: Impossible de trouver le dossier du jeu BLACK SOULS.
echo.
echo Solutions:
echo   1. Executez ce script depuis le dossier du jeu
echo   2. Ou copiez ce script dans le dossier du jeu
pause
exit /b 1

:found
echo Dossier du jeu trouve: !GAME_DIR!

REM === ETAPE 1: Copier Data ===
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
)

REM Desactiver l'archive
if exist "!GAME_DIR!\Game.rgss3a" (
    ren "!GAME_DIR!\Game.rgss3a" "Game.rgss3a.disabled"
    echo   Archive Game.rgss3a desactivee
)

REM Copier steam_api.dll (necessaire pour certaines configurations)
if exist "!SCRIPT_DIR!steam_api.dll" (
    copy "!SCRIPT_DIR!steam_api.dll" "!GAME_DIR!\" >nul 2>&1
    echo   steam_api.dll copie
)

cd /d "!GAME_DIR!"

REM === ETAPE 2: Audio ===
REM    ╔═══════════════════════════════════════════════════════════╗
REM    ║  Qu'est-ce que tu cherches exactement ?                   ║
REM    ╚═══════════════════════════════════════════════════════════╝

echo.
echo Installation des fichiers audio...

if exist "!SCRIPT_DIR!Audio\" (
    REM Methode 1: Copier depuis le patch
    set AUDIO_COUNT=0
    for %%D in (BGS SE) do (
        if exist "!SCRIPT_DIR!Audio\%%D\" (
            if not exist "!GAME_DIR!\Audio\%%D\" mkdir "!GAME_DIR!\Audio\%%D"
            for %%f in ("!SCRIPT_DIR!Audio\%%D\*.ogg") do (
                copy "%%f" "!GAME_DIR!\Audio\%%D\" >nul 2>&1 && set /a AUDIO_COUNT+=1
            )
        )
    )
    echo   !AUDIO_COUNT! fichiers audio copies ^(depuis le patch^)
    set SUCCESS=!AUDIO_COUNT!
) else (
    REM Methode 2: Creer depuis le jeu (fallback)
    echo   Creation des fichiers audio depuis le jeu...

    cd Audio\BGS
    call :copy_pair Fire Feu
    call :copy_pair Wind Vent
    call :copy_pair Darkness Tenebres
    cd ..\..

    cd Audio\SE
    for %%i in (1 2 3 4 5 6 7 8 9) do call :copy_pair_num Fire Feu %%i
    for %%i in (1 2 3 4 5 6 7 8 9 10 11) do call :copy_pair_num Wind Vent %%i
    for %%i in (1 2 3 4 5 6 10) do call :copy_pair_num Water Eau %%i
    for %%i in (1 2 3 4 5 6 7 8) do call :copy_pair_num Darkness Tenebres %%i
    for %%i in (1 2 3) do call :copy_pair_num Attack Attaque %%i
    for %%i in (1 2 3 4 5 6 7 8 9 10 11) do call :copy_pair_num Ice Glace %%i
    for %%i in (1 2 3 4 5 6 7 8 9 10 11 12) do call :copy_pair_num Thunder Tonnerre %%i
    for %%i in (1 2 3 4 5 6 7) do call :copy_pair_num Heal Soin %%i
    call :copy_pair Chicken Poulet
    cd ..\..

    echo   !SUCCESS! fichiers audio crees ^(depuis le jeu^)
)

REM Resume
echo.
if !ERRORS! EQU 0 (
    echo Installation terminee! ^(!SUCCESS! fichiers^)
    echo.
    echo Vous pouvez maintenant lancer le jeu.
) else (
    echo Installation terminee avec !ERRORS! erreur^(s^).
)
pause
exit /b 0

REM === Sous-routines ===

:copy_pair
REM Copie source.ogg vers dest.ogg et DEST.ogg
if exist "%~1.ogg" (
    copy "%~1.ogg" "%~2.ogg" >nul 2>&1 && set /a SUCCESS+=1
    for %%U in (%~2) do copy "%~1.ogg" "%%U.ogg" >nul 2>&1 && set /a SUCCESS+=1
)
exit /b

:copy_pair_num
REM Copie sourceN.ogg vers destN.ogg et DESTN.ogg
if exist "%~1%~3.ogg" (
    copy "%~1%~3.ogg" "%~2%~3.ogg" >nul 2>&1 && set /a SUCCESS+=1
    for %%U in (%~2) do copy "%~1%~3.ogg" "%%U%~3.ogg" >nul 2>&1 && set /a SUCCESS+=1
)
exit /b
