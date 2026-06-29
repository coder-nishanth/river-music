[Setup]
AppName=River Music
AppVersion=1.1.0
AppPublisher=coder-nishanth
DefaultDirName={autopf}\River Music
DefaultGroupName=River Music
UninstallDisplayIcon={app}\river-music.exe
Compression=lzma2
SolidCompression=yes
OutputDir=..\installers
OutputBaseFilename=RiverMusic-Setup-1.1.0
SetupIconFile=runner\resources\app_icon.ico

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\River Music"; Filename: "{app}\river-music.exe"; IconFilename: "{app}\river-music.exe"
Name: "{group}\Uninstall River Music"; Filename: "{uninstallexe}"
Name: "{commondesktop}\River Music"; Filename: "{app}\river-music.exe"; IconFilename: "{app}\river-music.exe"

[Run]
Filename: "{app}\river-music.exe"; Description: "Launch River Music"; Flags: postinstall nowait skipifsilent
