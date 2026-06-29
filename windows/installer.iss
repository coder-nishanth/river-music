[Setup]
AppName=River Music
AppVersion=1.1.0
AppVerName=River Music 1.1.0
AppPublisher=coder-nishanth
AppPublisherURL=https://github.com/coder-nishanth/river-music
DefaultDirName={autopf}\River Music
DefaultGroupName=River Music
UninstallDisplayIcon={app}\river-music.exe
UninstallDisplayName=River Music
Compression=lzma2
SolidCompression=yes
OutputDir=..\installers
OutputBaseFilename=RiverMusic-Setup-1.1.0
SetupIconFile=runner\resources\app_icon.ico
VersionInfoVersion=1.1.0.0
VersionInfoCompany=coder-nishanth
VersionInfoDescription=River Music Installer
VersionInfoProductName=River Music
VersionInfoProductVersion=1.1.0
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\River Music"; Filename: "{app}\river-music.exe"; IconFilename: "{app}\river-music.exe"
Name: "{group}\Uninstall River Music"; Filename: "{uninstallexe}"
Name: "{commondesktop}\River Music"; Filename: "{app}\river-music.exe"; IconFilename: "{app}\river-music.exe"

[Run]
Filename: "{app}\river-music.exe"; Description: "Launch River Music"; Flags: postinstall nowait skipifsilent
