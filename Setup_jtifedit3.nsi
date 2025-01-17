; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

Unicode true

!define APP   "jtifedit3"
!define TITLE "J TIFF Editor 3"
!define BINDIR64 "jtifedit3\bin\release"
!define BINDIR32 "jtifedit3\bin\x86\release"

!system 'DefineAsmVer.exe ${BINDIR64}\jtifedit3.exe "!define VER ""[SFVER]"" " > Appver.tmp'
!include "Appver.tmp"

!searchreplace APV ${VER} "." "_"

!define MIME "image/tiff"

!define EXT ".tif"
!define EXT2 ".tiff"

!system 'MySign "${BINDIR32}\jtifedit3.exe" "${BINDIR64}\jtifedit3.exe"'
!finalize 'MySign "%1"'

XPStyle on

;--------------------------------

; The name of the installer
Name "${TITLE} -- ${VER}"

; The file to write
OutFile "Setup_${APP}_${APV}_user.exe"

; The default installation directory
InstallDir "$APPDATA\${APP}"

; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
InstallDirRegKey HKCU "Software\HIRAOKA HYPERS TOOLS, Inc.\${APP}" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel user

AutoCloseWindow true

AllowSkipFiles off

!include LogicLib.nsh

;--------------------------------

; Pages

Page license
Page directory
Page components
Page instfiles

LicenseData GNUGPL2.txt

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

!ifdef SHCNE_ASSOCCHANGED
!undef SHCNE_ASSOCCHANGED
!endif
!define SHCNE_ASSOCCHANGED 0x08000000

!ifdef SHCNF_FLUSH
!undef SHCNF_FLUSH
!endif
!define SHCNF_FLUSH        0x1000

!ifdef SHCNF_IDLIST
!undef SHCNF_IDLIST
!endif
!define SHCNF_IDLIST       0x0000

!macro UPDATEFILEASSOC
  IntOp $1 ${SHCNE_ASSOCCHANGED} | 0
  IntOp $0 ${SHCNF_IDLIST} | ${SHCNF_FLUSH}
; Using the system.dll plugin to call the SHChangeNotify Win32 API function so we
; can update the shell.
  System::Call "shell32::SHChangeNotify(i,i,i,i) ($1, $0, 0, 0)"
!macroend

;--------------------------------

InstType "32 ビット版"
InstType "Any CPU 版 (64 or 32 ビット自動)"

; The stuff to install
Section "${APP}" ;No components page, name is not important
  SectionIn ro

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  ; Put file there

  WriteRegStr HKCU "Software\Classes\${APP}" "" "${TITLE}"
  WriteRegstr HKCU "Software\Classes\${APP}\DefaultIcon" "" "$INSTDIR\1.ico,0"
  WriteRegStr HKCU "Software\Classes\${APP}\shell\open\command" "" '"$INSTDIR\${APP}" "%1"'

  WriteRegStr HKCU "Software\HIRAOKA HYPERS TOOLS, Inc.\${APP}" "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "DisplayName" "${TITLE}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
SectionEnd ; end the section

Section /o "32 ビット版"
  SectionIn 1

  Delete "$INSTDIR\FreeImage.dll"
  
  File /r /x "*.vshost.*" /x "*.xml" "${BINDIR32}\*.*"
SectionEnd

Section "Any CPU 版 (64 or 32 ビット自動)"
  SectionIn 2

  Delete "$INSTDIR\FreeImage.dll"
  
  File /r /x "*.vshost.*" /x "*.xml" "${BINDIR64}\*.*"
SectionEnd

Section "関連付け(現在のアカウント)"
  SectionIn 1 2
  
  WriteRegStr HKCU "Software\Classes\${EXT}" "" "${APP}"
  WriteRegStr HKCU "Software\Classes\${EXT}" "Content Type" "${MIME}"
  WriteRegStr HKCU "Software\Classes\${EXT}\OpenWithProgids" "${APP}" ""
  
  WriteRegStr HKCU "Software\Classes\${EXT2}" "" "${APP}"
  WriteRegStr HKCU "Software\Classes\${EXT2}" "Content Type" "${MIME}"
  WriteRegStr HKCU "Software\Classes\${EXT2}\OpenWithProgids" "${APP}" ""

  WriteRegStr HKCU "Software\Classes\Applications\${APP}.exe\shell\open\command" "" '"$INSTDIR\${APP}.exe" "%1"'

  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\${EXT}\UserChoice"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\${EXT2}\UserChoice"

  DetailPrint "関連付け更新中です。お待ちください。"
  !insertmacro UPDATEFILEASSOC
SectionEnd

Section "スタートメニュー(現在のアカウント)"
  SectionIn 1 2

  CreateDirectory "$SMPROGRAMS\${TITLE}"
  CreateShortCut "$SMPROGRAMS\${TITLE}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\${TITLE}\起動.lnk" "$INSTDIR\${APP}.exe" "" "$INSTDIR\${APP}.exe" 0
SectionEnd

Section "起動"
  SectionIn 1 2

  SetOutPath $INSTDIR
  Exec "$INSTDIR\jtifedit3.exe"
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

  ; Remove registry keys
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}"
  DeleteRegKey HKCU "Software\HIRAOKA HYPERS TOOLS, Inc.\${APP}"
  
  DeleteRegValue HKCU "Software\Classes\${EXT}\OpenWithProgids" "${APP}"
  DeleteRegValue HKCU "Software\Classes\${EXT2}\OpenWithProgids" "${APP}"

  ReadRegStr $0 HKCU "Software\Classes\${EXT}" ""
  ${If} $0 == "${APP}"
  ReadRegStr $0 HKLM "Software\Classes\${EXT}" ""
  WriteRegStr   HKCU "Software\Classes\${EXT}" "" "$0"
  ${EndIf}

  ReadRegStr $0 HKCU "Software\Classes\${EXT2}" ""
  ${If} $0 == "${APP}"
  ReadRegStr $0 HKLM "Software\Classes\${EXT2}" ""
  WriteRegStr   HKCU "Software\Classes\${EXT2}" "" "$0"
  ${EndIf}

  DeleteRegKey HKCU "Software\Classes\Applications\${APP}.exe"

  ; Remove files and uninstaller

  DetailPrint "関連付け更新中です。お待ちください。"
  !insertmacro UPDATEFILEASSOC

  Delete "$INSTDIR\uninstall.exe"

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\${TITLE}\Uninstall.lnk"
  Delete "$SMPROGRAMS\${TITLE}\起動.lnk"

  ; Remove directories used
  RMDir "$SMPROGRAMS\${TITLE}"
  RMDir /r "$INSTDIR"

SectionEnd
