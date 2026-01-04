; BLACK SOULS - Patch Francais - Installateur Windows
; Compile avec Inno Setup 6.x (https://jrsoftware.org/isinfo.php)

#define MyAppName "BLACK SOULS - Patch Francais"
#define MyAppVersion "0.3.0"
#define MyAppPublisher "SatanBoucheUnCoin & PierrePaolo"
#define MyAppURL "https://github.com/SatanBoucheUnCoin/black-souls-french-patch"
#define SteamAppID "3755860"
#define GameFolder "BLACK SOULS"

[Setup]
AppId={{B1ACK-50UL5-FR-PATCH-2024}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={code:GetGamePath}
DisableDirPage=no
DisableProgramGroupPage=yes
OutputDir=..\..\dist
OutputBaseFilename=BlackSouls_PatchFR_v{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
PrivilegesRequired=lowest
WizardStyle=modern
UninstallDisplayName={#MyAppName}
CreateUninstallRegKey=no
Uninstallable=no

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
french.WelcomeLabel2=Cet assistant va installer le patch de traduction francaise pour BLACK SOULS.%n%nAssurez-vous que le jeu est installe avant de continuer.%n%nVersion du patch: {#MyAppVersion}
french.SelectDirLabel3=Selectionnez le dossier ou BLACK SOULS est installe.
french.SelectDirBrowseLabel=Le dossier doit contenir Game.exe
french.FinishedHeadingLabel=Installation terminee!
french.FinishedLabel=Le patch francais a ete installe avec succes.%n%nVous pouvez maintenant lancer le jeu via Steam.
english.WelcomeLabel2=This wizard will install the French translation patch for BLACK SOULS.%n%nMake sure the game is installed before continuing.%n%nPatch version: {#MyAppVersion}
english.SelectDirLabel3=Select the folder where BLACK SOULS is installed.
english.SelectDirBrowseLabel=The folder must contain Game.exe
english.FinishedHeadingLabel=Installation Complete!
english.FinishedLabel=The French patch has been successfully installed.%n%nYou can now launch the game via Steam.

[Files]
Source: "..\..\Game.rgss3a"; DestDir: "{app}"; Flags: ignoreversion
; Fichiers audio traduits (BGS)
Source: "..\..\Audio\BGS\Feu.ogg"; DestDir: "{app}\Audio\BGS"; Flags: ignoreversion
Source: "..\..\Audio\BGS\Vent.ogg"; DestDir: "{app}\Audio\BGS"; Flags: ignoreversion
Source: "..\..\Audio\BGS\Ténèbres.ogg"; DestDir: "{app}\Audio\BGS"; Flags: ignoreversion
; Fichiers audio traduits (SE)
Source: "..\..\Audio\SE\Feu*.ogg"; DestDir: "{app}\Audio\SE"; Flags: ignoreversion
Source: "..\..\Audio\SE\Vent*.ogg"; DestDir: "{app}\Audio\SE"; Flags: ignoreversion
Source: "..\..\Audio\SE\Eau*.ogg"; DestDir: "{app}\Audio\SE"; Flags: ignoreversion
Source: "..\..\Audio\SE\Glace*.ogg"; DestDir: "{app}\Audio\SE"; Flags: ignoreversion
Source: "..\..\Audio\SE\Tonnerre*.ogg"; DestDir: "{app}\Audio\SE"; Flags: ignoreversion
Source: "..\..\Audio\SE\Soin*.ogg"; DestDir: "{app}\Audio\SE"; Flags: ignoreversion
Source: "..\..\Audio\SE\Attaque*.ogg"; DestDir: "{app}\Audio\SE"; Flags: ignoreversion
Source: "..\..\Audio\SE\Ténèbres*.ogg"; DestDir: "{app}\Audio\SE"; Flags: ignoreversion

[Code]
var
  GamePath: string;
  GameDetected: Boolean;

// Recherche le jeu via le registre Steam (entree directe du jeu)
function FindViaSteamRegistry(): string;
var
  Path: string;
begin
  Result := '';

  // Steam App registry (64-bit)
  if RegQueryStringValue(HKLM64,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App {#SteamAppID}',
    'InstallLocation', Path) then
  begin
    if FileExists(Path + '\Game.exe') then
    begin
      Log('Found via Steam App registry (64-bit): ' + Path);
      Result := Path;
      Exit;
    end;
  end;

  // Steam App registry (32-bit)
  if RegQueryStringValue(HKLM32,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App {#SteamAppID}',
    'InstallLocation', Path) then
  begin
    if FileExists(Path + '\Game.exe') then
    begin
      Log('Found via Steam App registry (32-bit): ' + Path);
      Result := Path;
      Exit;
    end;
  end;
end;

// Recherche le chemin Steam principal
function GetSteamPath(): string;
var
  Path: string;
begin
  Result := '';

  // HKCU - SteamPath
  if RegQueryStringValue(HKCU, 'SOFTWARE\Valve\Steam', 'SteamPath', Path) then
  begin
    // Convertir les / en \
    StringChangeEx(Path, '/', '\', True);
    Log('Steam path from HKCU: ' + Path);
    Result := Path;
    Exit;
  end;

  // HKLM 64-bit
  if RegQueryStringValue(HKLM64, 'SOFTWARE\Valve\Steam', 'InstallPath', Path) then
  begin
    Log('Steam path from HKLM64: ' + Path);
    Result := Path;
    Exit;
  end;

  // HKLM 32-bit (WOW6432Node)
  if RegQueryStringValue(HKLM32, 'SOFTWARE\Valve\Steam', 'InstallPath', Path) then
  begin
    Log('Steam path from HKLM32: ' + Path);
    Result := Path;
    Exit;
  end;
end;

// Cherche dans le dossier Steam principal
function FindInMainSteamFolder(): string;
var
  SteamPath, GameDir: string;
begin
  Result := '';
  SteamPath := GetSteamPath();

  if SteamPath <> '' then
  begin
    GameDir := SteamPath + '\steamapps\common\{#GameFolder}';
    if FileExists(GameDir + '\Game.exe') then
    begin
      Log('Found in main Steam folder: ' + GameDir);
      Result := GameDir;
    end;
  end;
end;

// Parse libraryfolders.vdf pour trouver les bibliotheques Steam additionnelles
function FindInSteamLibraries(): string;
var
  SteamPath, VdfFile, GameDir: string;
  Lines: TArrayOfString;
  I, J: Integer;
  Line, LibPath: string;
  QuotePos1, QuotePos2: Integer;
begin
  Result := '';
  SteamPath := GetSteamPath();

  if SteamPath = '' then
    Exit;

  VdfFile := SteamPath + '\steamapps\libraryfolders.vdf';
  Log('Checking library folders VDF: ' + VdfFile);

  if not FileExists(VdfFile) then
  begin
    Log('VDF file not found');
    Exit;
  end;

  if LoadStringsFromFile(VdfFile, Lines) then
  begin
    for I := 0 to GetArrayLength(Lines) - 1 do
    begin
      Line := Lines[I];

      // Cherche les lignes contenant "path"
      if Pos('"path"', Line) > 0 then
      begin
        // Extrait le chemin entre guillemets apres "path"
        // Format: "path"		"C:\SteamLibrary"
        QuotePos1 := 0;
        for J := Pos('"path"', Line) + 6 to Length(Line) do
        begin
          if Line[J] = '"' then
          begin
            if QuotePos1 = 0 then
              QuotePos1 := J + 1
            else
            begin
              QuotePos2 := J;
              Break;
            end;
          end;
        end;

        if (QuotePos1 > 0) and (QuotePos2 > QuotePos1) then
        begin
          LibPath := Copy(Line, QuotePos1, QuotePos2 - QuotePos1);
          // Gerer les echappements \\
          StringChangeEx(LibPath, '\\', '\', True);

          GameDir := LibPath + '\steamapps\common\{#GameFolder}';
          Log('Checking library: ' + GameDir);

          if FileExists(GameDir + '\Game.exe') then
          begin
            Log('Found in Steam library: ' + GameDir);
            Result := GameDir;
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

// Cherche dans les chemins classiques
function FindInCommonPaths(): string;
var
  Paths: array of string;
  I: Integer;
  Path: string;
begin
  Result := '';

  SetArrayLength(Paths, 8);
  Paths[0] := 'C:\Program Files (x86)\Steam\steamapps\common\{#GameFolder}';
  Paths[1] := 'C:\Program Files\Steam\steamapps\common\{#GameFolder}';
  Paths[2] := 'D:\Steam\steamapps\common\{#GameFolder}';
  Paths[3] := 'D:\SteamLibrary\steamapps\common\{#GameFolder}';
  Paths[4] := 'E:\Steam\steamapps\common\{#GameFolder}';
  Paths[5] := 'E:\SteamLibrary\steamapps\common\{#GameFolder}';
  Paths[6] := 'F:\Steam\steamapps\common\{#GameFolder}';
  Paths[7] := 'F:\SteamLibrary\steamapps\common\{#GameFolder}';

  for I := 0 to GetArrayLength(Paths) - 1 do
  begin
    Path := Paths[I];
    if FileExists(Path + '\Game.exe') then
    begin
      Log('Found in common path: ' + Path);
      Result := Path;
      Exit;
    end;
  end;
end;

// Cherche le jeu dans un home Linux specifique
function CheckLinuxHome(UserHome: string): string;
var
  Paths: array of string;
  I: Integer;
  Path: string;
begin
  Result := '';

  SetArrayLength(Paths, 5);
  // Steam natif Linux
  Paths[0] := UserHome + '\.local\share\Steam\steamapps\common\{#GameFolder}';
  Paths[1] := UserHome + '\.steam\steam\steamapps\common\{#GameFolder}';
  // Steam Flatpak
  Paths[2] := UserHome + '\.var\app\com.valvesoftware.Steam\.local\share\Steam\steamapps\common\{#GameFolder}';
  // Emplacements personnalises
  Paths[3] := UserHome + '\Games\Steam\steamapps\common\{#GameFolder}';
  Paths[4] := UserHome + '\SteamLibrary\steamapps\common\{#GameFolder}';

  for I := 0 to GetArrayLength(Paths) - 1 do
  begin
    Path := Paths[I];
    if FileExists(Path + '\Game.exe') then
    begin
      Log('Found in Linux home: ' + Path);
      Result := Path;
      Exit;
    end;
  end;
end;

// Cherche via le lecteur Z: (Wine/Proton)
function FindInWineZDrive(): string;
var
  FindRec: TFindRec;
  UserHome, Path: string;
begin
  Result := '';

  // Verifier si le lecteur Z: existe (indicateur Wine/Proton)
  if not DirExists('Z:\home') then
  begin
    Log('Z:\home not found - not running under Wine/Proton');
    Exit;
  end;

  Log('Wine/Proton detected, scanning Z:\home for users...');

  // Parcourir tous les dossiers utilisateurs dans /home
  if FindFirst('Z:\home\*', FindRec) then
  begin
    try
      repeat
        // Ignorer . et .. et les fichiers
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') and
           (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY <> 0) then
        begin
          UserHome := 'Z:\home\' + FindRec.Name;
          Log('Checking user home: ' + UserHome);

          Result := CheckLinuxHome(UserHome);
          if Result <> '' then
            Exit;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end;

  // Verifier aussi /run/media pour les disques externes (Steam Deck)
  if DirExists('Z:\run\media') then
  begin
    Log('Checking external media at Z:\run\media...');
    if FindFirst('Z:\run\media\*', FindRec) then
    begin
      try
        repeat
          if (FindRec.Name <> '.') and (FindRec.Name <> '..') and
             (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY <> 0) then
          begin
            // Pour chaque utilisateur dans /run/media
            UserHome := 'Z:\run\media\' + FindRec.Name;
            // Chercher les SteamLibrary sur les disques montes
            Path := UserHome + '\SteamLibrary\steamapps\common\{#GameFolder}';
            if FileExists(Path + '\Game.exe') then
            begin
              Log('Found on external media: ' + Path);
              Result := Path;
              Exit;
            end;
          end;
        until not FindNext(FindRec);
      finally
        FindClose(FindRec);
      end;
    end;
  end;
end;

// Fonction principale de detection
function GetGamePath(Param: string): string;
begin
  if GamePath = '' then
  begin
    Log('=== Starting game detection ===');

    // Methode 1: Registre Steam direct
    GamePath := FindViaSteamRegistry();

    // Methode 2: Dossier Steam principal
    if GamePath = '' then
      GamePath := FindInMainSteamFolder();

    // Methode 3: Bibliotheques Steam additionnelles
    if GamePath = '' then
      GamePath := FindInSteamLibraries();

    // Methode 4: Chemins classiques Windows
    if GamePath = '' then
      GamePath := FindInCommonPaths();

    // Methode 5: Lecteur Z: pour Wine/Proton (Steam Deck, Linux)
    if GamePath = '' then
      GamePath := FindInWineZDrive();

    GameDetected := (GamePath <> '');

    if GameDetected then
      Log('Game detected at: ' + GamePath)
    else
    begin
      Log('Game not detected, using default path');
      GamePath := 'C:\Program Files (x86)\Steam\steamapps\common\{#GameFolder}';
    end;

    Log('=== Game detection complete ===');
  end;

  Result := GamePath;
end;

function InitializeSetup(): Boolean;
begin
  // Force la detection au demarrage
  GetGamePath('');
  Result := True;
end;

// Sauvegarde l'original avant installation
procedure CurStepChanged(CurStep: TSetupStep);
var
  OriginalFile, BackupFile: string;
begin
  if CurStep = ssInstall then
  begin
    OriginalFile := ExpandConstant('{app}\Game.rgss3a');
    BackupFile := ExpandConstant('{app}\Game.rgss3a.disabled');

    if FileExists(OriginalFile) then
    begin
      if not FileExists(BackupFile) then
      begin
        Log('Backing up original Game.rgss3a...');
        if RenameFile(OriginalFile, BackupFile) then
          Log('Backup successful: ' + BackupFile)
        else
          Log('WARNING: Could not rename original file');
      end
      else
      begin
        Log('Backup already exists, deleting current Game.rgss3a...');
        DeleteFile(OriginalFile);
      end;
    end;
  end;
end;

// Validation du dossier selectionne
function NextButtonClick(CurPageID: Integer): Boolean;
var
  GameExe: string;
begin
  Result := True;

  if CurPageID = wpSelectDir then
  begin
    GameExe := ExpandConstant('{app}\Game.exe');

    if not FileExists(GameExe) then
    begin
      if MsgBox('Game.exe non trouve dans ce dossier.' + #13#10 + #13#10 +
                'Chemin selectionne:' + #13#10 +
                ExpandConstant('{app}') + #13#10 + #13#10 +
                'Etes-vous sur que c''est le bon dossier?',
                mbConfirmation, MB_YESNO) = IDNO then
        Result := False;
    end;
  end;
end;

// Resume avant installation
function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo,
  MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  Status: string;
begin
  if GameDetected then
    Status := 'Jeu detecte automatiquement'
  else
    Status := 'Jeu non detecte - verifiez le chemin';

  Result := 'Dossier d''installation:' + NewLine +
            Space + ExpandConstant('{app}') + NewLine + NewLine +
            'Status: ' + Status + NewLine + NewLine +
            'Actions:' + NewLine +
            Space + '1. Sauvegarde de Game.rgss3a original' + NewLine +
            Space + '   -> Game.rgss3a.disabled' + NewLine +
            Space + '2. Installation du patch francais' + NewLine +
            Space + '3. Copie des fichiers audio traduits' + NewLine + NewLine +
            'Pour desinstaller: verifiez l''integrite des fichiers dans Steam';
end;
