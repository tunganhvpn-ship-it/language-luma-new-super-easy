; ============================================================
; Luma installer (Inno Setup 6+)
; ------------------------------------------------------------
; Build steps:
;   1. Build the project first:
;        cmake -S . -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release
;        cmake --build build --config Release
;      This creates out\luma.exe, out\luma_vm.exe, out\luma-edit.exe
;   2. Open this file in Inno Setup Compiler and press Compile,
;      or run:  iscc install.iss
;   3. The result is installer\luma-setup.exe
;
; v0.6: Python-like syntax with legacy Luma alias support.
;   No C++ compiler needed — `luma build` bundles bytecode into a pre-compiled VM stub.
; ============================================================

#define MyAppName "Luma"
#define MyAppVersion "0.6.0"
#define MyAppPublisher "Luma Language"
#define MyAppURL "https://github.com/luma-lang/luma"
#define MyAppExeName "luma.exe"
#define MyVmExeName "luma_vm.exe"
#define MyEditorExeName "luma-edit.exe"
#define MyTestsExeName "luma_tests.exe"

[Setup]
AppId={{7E1B7C52-9F4C-45A3-B3D8-6A2E4B1C0F9D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
VersionInfoVersion={#MyAppVersion}.0
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=installer
OutputBaseFilename=luma-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesInstallIn64BitMode=x64compatible
ChangesEnvironment=yes
ChangesAssociations=yes
UninstallDisplayIcon={app}\bin\{#MyAppExeName}
SetupIconFile=icons\luma.ico
CloseApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
english.AddSystemPath=Add Luma to the SYSTEM PATH (all users)
english.AddUserPath=Add Luma to the current user's PATH
english.CreateDesktopIcon=Create a desktop icon for Luma Editor
english.AssociateLuma=Open .luma files with Luma Editor
english.OpenEditorNow=Open Luma Editor now
english.TryLumaCommand=Try the luma command (opens a terminal)
english.OldVersionDetected=A previous version of Luma was detected.
english.OldVersionUpgrading=Setup will now uninstall the old version and install the new one.
english.OldVersionUpgradeTitle=Old Version Detected

[Tasks]
Name: "addsystempath"; Description: "{cm:AddSystemPath}"; Check: IsAdminInstallMode
Name: "adduserpath"; Description: "{cm:AddUserPath}"; Flags: unchecked
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"
Name: "assoc"; Description: "{cm:AssociateLuma}"

[Files]
; === Core executables (4 files) ===
; Luma CLI - run, build, init, info, debug
Source: "out\{#MyAppExeName}"; DestDir: "{app}\bin"; Flags: ignoreversion
; Luma VM stub - reads bytecode from self-extracting .exe
Source: "out\{#MyVmExeName}"; DestDir: "{app}\bin"; Flags: ignoreversion
; Luma Editor - dark theme GUI with syntax highlighting
Source: "out\{#MyEditorExeName}"; DestDir: "{app}\bin"; Flags: ignoreversion
; Luma Tests - unit test runner
Source: "out\{#MyTestsExeName}"; DestDir: "{app}\bin"; Flags: ignoreversion skipifsourcedoesntexist
; SDL2 runtime (optional, for graphics programs)
Source: "out\SDL2.dll"; DestDir: "{app}\bin"; Flags: ignoreversion skipifsourcedoesntexist
; Icons for app and .luma files
Source: "icons\luma.ico"; DestDir: "{app}\bin"; Flags: ignoreversion
Source: "icons\luma_file.ico"; DestDir: "{app}\bin"; Flags: ignoreversion

; === Documentation ===
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.vi.md"; DestDir: "{app}"; Flags: ignoreversion

; === Example programs ===
Source: "examples\*"; DestDir: "{app}\examples"; Flags: recursesubdirs ignoreversion

[Registry]
; SYSTEM PATH (all users) - written only for admin installs.
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\bin"; Tasks: addsystempath; Check: NeedsAddSystemPath
; Current user's PATH.
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\bin"; Tasks: adduserpath; Check: NeedsAddUserPath
; .luma file association -> Luma Editor (double-click opens the editor).
Root: HKA; Subkey: "Software\Classes\.luma"; ValueType: string; ValueName: ""; ValueData: "Luma.Program"; Flags: uninsdeletevalue; Tasks: assoc
Root: HKA; Subkey: "Software\Classes\Luma.Program"; ValueType: string; ValueName: ""; ValueData: "Luma program"; Flags: uninsdeletekey; Tasks: assoc
Root: HKA; Subkey: "Software\Classes\Luma.Program\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\bin\luma_file.ico,0"; Tasks: assoc
Root: HKA; Subkey: "Software\Classes\Luma.Program\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\bin\{#MyEditorExeName}"" ""%1"""; Tasks: assoc

[Icons]
; Start menu
Name: "{group}\{#MyAppName} Editor"; Filename: "{app}\bin\{#MyEditorExeName}"
Name: "{group}\{#MyAppName} CLI"; Filename: "cmd.exe"; Parameters: "/k cd /d ""{app}"" && luma --version"
Name: "{group}\{#MyAppName} README"; Filename: "{app}\README.md"
Name: "{group}\{#MyAppName} Examples"; Filename: "{app}\examples"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
; Desktop shortcut
Name: "{autodesktop}\{#MyAppName} Editor"; Filename: "{app}\bin\{#MyEditorExeName}"; Tasks: desktopicon; IconFilename: "{app}\bin\luma.ico"

[Run]
Filename: "{app}\bin\{#MyEditorExeName}"; Description: "{cm:OpenEditorNow}"; Flags: postinstall skipifsilent nowait
Filename: "cmd.exe"; Parameters: "/k ""{app}\bin\{#MyAppExeName}"" --version"; Description: "{cm:TryLumaCommand}"; Flags: postinstall skipifsilent unchecked

[Code]
{ ---- PATH helpers ---- }

function PathSubKey(RootKey: Integer): string;
begin
  if RootKey = HKEY_LOCAL_MACHINE then
    Result := 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
  else
    Result := 'Environment';
end;

function NeedsAddPath(RootKey: Integer; Dir: string): Boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(RootKey, PathSubKey(RootKey), 'Path', OrigPath) then
  begin
    Result := True;
    exit;
  end;
  Result := Pos(';' + Uppercase(Dir) + ';', ';' + Uppercase(OrigPath) + ';') = 0;
end;

function NeedsAddSystemPath: Boolean;
begin
  Result := NeedsAddPath(HKEY_LOCAL_MACHINE, ExpandConstant('{app}\bin'));
end;

function NeedsAddUserPath: Boolean;
begin
  Result := NeedsAddPath(HKEY_CURRENT_USER, ExpandConstant('{app}\bin'));
end;

procedure RemoveFromPath(RootKey: Integer; Dir: string);
var
  OrigPath, NewPath: string;
  Position: Integer;
begin
  if not RegQueryStringValue(RootKey, PathSubKey(RootKey), 'Path', OrigPath) then
    exit;
  NewPath := ';' + OrigPath + ';';
  Position := Pos(';' + Uppercase(Dir) + ';', Uppercase(NewPath));
  if Position = 0 then
    exit;
  Delete(NewPath, Position, Length(Dir) + 1);
  if (Length(NewPath) > 0) and (NewPath[1] = ';') then
    Delete(NewPath, 1, 1);
  if (Length(NewPath) > 0) and (NewPath[Length(NewPath)] = ';') then
    Delete(NewPath, Length(NewPath), 1);
  RegWriteExpandStringValue(RootKey, PathSubKey(RootKey), 'Path', NewPath);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  BinDir: string;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    BinDir := ExpandConstant('{app}\bin');
    if IsAdminInstallMode then
      RemoveFromPath(HKEY_LOCAL_MACHINE, BinDir);
    RemoveFromPath(HKEY_CURRENT_USER, BinDir);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  TaskKill: string;
begin
  if CurStep = ssInstall then
  begin
    TaskKill := ExpandConstant('{sys}\taskkill.exe');
    { Kill any running Luma processes before installing }
    Exec(TaskKill, '/F /IM luma-edit.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec(TaskKill, '/F /IM luma.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec(TaskKill, '/F /IM luma_vm.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec(TaskKill, '/F /IM demo.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    { Let OS release file handles }
    Sleep(1000);
  end;
end;

{ ---- Detect old version and auto-uninstall before upgrading ---- }

function GetUninstallString(): string;
var
  UninstallRegKey: string;
  ResultStr: string;
begin
  UninstallRegKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{7E1B7C52-9F4C-45A3-B3D8-6A2E4B1C0F9D}_is1';
  if RegQueryStringValue(HKLM, UninstallRegKey, 'UninstallString', ResultStr) then
  begin
    Result := ResultStr;
    exit;
  end;
  if RegQueryStringValue(HKCU, UninstallRegKey, 'UninstallString', ResultStr) then
  begin
    Result := ResultStr;
    exit;
  end;
  Result := '';
end;

function IsOldVersionInstalled(): Boolean;
begin
  Result := GetUninstallString() <> '';
end;

function InitializeSetup(): Boolean;
var
  UninstallString: string;
  ResultCode: Integer;
begin
  Result := True;

  if IsOldVersionInstalled() then
  begin
    if MsgBox(CustomMessage('OldVersionDetected') + #13#10 + #13#10 +
              CustomMessage('OldVersionUpgrading'),
              mbInformation, MB_YESNO) = IDYES then
    begin
      UninstallString := GetUninstallString();
      if UninstallString <> '' then
      begin
        UninstallString := '"' + UninstallString + '"';
        Exec(UninstallString, '/SILENT /NORESTART', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
      end;
    end
    else
    begin
      Result := False;
    end;
  end;
end;
