;===============================================================================
; git-crypt Windows Installer
; NSIS Modern User Interface 2.0 Script
;
; Description: Installer for git-crypt - transparent file encryption in git
; Author:      Andrew Ayer
; License:     GPL v3
; Website:     https://www.agwa.name/projects/git-crypt/
;
; Build command: makensis git-crypt-installer.nsi
;===============================================================================

;-------------------------------------------------------------------------------
; Build Configuration and Compiler Settings
;-------------------------------------------------------------------------------

; Use Unicode for proper Windows integration (NSIS 3.0+)
Unicode True

; Enable high compression for smaller installer size
SetCompressor /SOLID lzma
SetCompressorDictSize 64

; Request administrator privileges for Program Files installation
RequestExecutionLevel admin

;-------------------------------------------------------------------------------
; Product Information
;-------------------------------------------------------------------------------

!define PRODUCT_NAME "git-crypt"
!define PRODUCT_VERSION "0.8.0"
!define PRODUCT_PUBLISHER "Andrew Ayer"
!define PRODUCT_WEB_SITE "https://www.agwa.name/projects/git-crypt/"
!define PRODUCT_GITHUB "https://github.com/AGWA/git-crypt"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; File paths relative to the .nsi script
!define SOURCE_DIR "files"

;-------------------------------------------------------------------------------
; Modern User Interface 2 (MUI2) Configuration
;-------------------------------------------------------------------------------

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "WinMessages.nsh"
!include "StrFunc.nsh"
${StrStr}
${StrRep}
${UnStrStr}
${UnStrRep}

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING

; Welcome page settings
!define MUI_WELCOMEPAGE_TITLE "Welcome to ${PRODUCT_NAME} ${PRODUCT_VERSION} Setup"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of ${PRODUCT_NAME} ${PRODUCT_VERSION}.$\r$\n$\r$\n\
git-crypt enables transparent encryption and decryption of files in a git repository. \
Files which you choose to protect are encrypted when committed, and decrypted when checked out.$\r$\n$\r$\n\
Click Next to continue."

; License page settings
!define MUI_LICENSEPAGE_CHECKBOX

; Finish page settings
!define MUI_FINISHPAGE_TITLE "Installation Complete"
!define MUI_FINISHPAGE_TEXT "${PRODUCT_NAME} has been installed on your computer.$\r$\n$\r$\n\
To use git-crypt, open a command prompt or Git Bash and run 'git-crypt --help' for usage information.$\r$\n$\r$\n\
Click Finish to close the Setup wizard."
!define MUI_FINISHPAGE_LINK "Visit ${PRODUCT_NAME} website"
!define MUI_FINISHPAGE_LINK_LOCATION "${PRODUCT_WEB_SITE}"
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

;-------------------------------------------------------------------------------
; Installer Pages
;-------------------------------------------------------------------------------

; Installation pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${SOURCE_DIR}\COPYING"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstallation pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;-------------------------------------------------------------------------------
; Language Configuration
;-------------------------------------------------------------------------------

!insertmacro MUI_LANGUAGE "English"

;-------------------------------------------------------------------------------
; Installer Attributes
;-------------------------------------------------------------------------------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "git-crypt-${PRODUCT_VERSION}-x64-setup.exe"

; Default installation directory (64-bit Program Files)
InstallDir "$PROGRAMFILES64\${PRODUCT_NAME}"

; Get installation folder from registry if previously installed
InstallDirRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation"

; Show installation details
ShowInstDetails show
ShowUnInstDetails show

; Version information embedded in the executable
VIProductVersion "${PRODUCT_VERSION}.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${PRODUCT_PUBLISHER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright (C) Andrew Ayer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${PRODUCT_NAME} Windows Installer"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${PRODUCT_VERSION}"

;-------------------------------------------------------------------------------
; Installer Sections
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Section: Core Files (Required)
;-------------------------------------------------------------------------------
Section "!Core Files (required)" SEC_CORE
    ; This section is required and cannot be deselected
    SectionIn RO

    ; Set output path to installation directory
    SetOutPath "$INSTDIR"

    ; Install the main executable
    DetailPrint "Installing git-crypt executable..."
    File "${SOURCE_DIR}\git-crypt.exe"

    ; Install documentation files
    DetailPrint "Installing documentation..."
    SetOutPath "$INSTDIR\doc"
    File "${SOURCE_DIR}\README.md"
    File "${SOURCE_DIR}\COPYING"
    File "${SOURCE_DIR}\NEWS.md"

    ; Create uninstaller
    DetailPrint "Creating uninstaller..."
    SetOutPath "$INSTDIR"
    WriteUninstaller "$INSTDIR\uninstall.exe"

    ; Write registry entries for Add/Remove Programs
    DetailPrint "Registering application..."
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "${PRODUCT_NAME}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLUpdateInfo" "${PRODUCT_GITHUB}/releases"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\git-crypt.exe"
    WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoModify" 1
    WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoRepair" 1

    ; Calculate and store installed size
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "EstimatedSize" "$0"
SectionEnd

;-------------------------------------------------------------------------------
; Section: Add to PATH (Optional)
;-------------------------------------------------------------------------------
Section "Add to system PATH" SEC_PATH
    DetailPrint "Adding git-crypt to system PATH..."

    ; Read current PATH
    ReadRegStr $0 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"

    ; Check if already in PATH
    ${StrStr} $1 $0 "$INSTDIR"
    ${If} $1 == ""
        ; Not found, append to PATH
        ${If} $0 != ""
            StrCpy $0 "$0;$INSTDIR"
        ${Else}
            StrCpy $0 "$INSTDIR"
        ${EndIf}

        ; Write new PATH
        WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path" $0

        ; Notify running applications of environment change
        SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
    ${EndIf}

    ; Mark that PATH was modified (for uninstaller)
    WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "PathModified" 1
SectionEnd

;-------------------------------------------------------------------------------
; Section: Start Menu Shortcuts (Optional)
;-------------------------------------------------------------------------------
Section "Start Menu Shortcuts" SEC_STARTMENU
    DetailPrint "Creating Start Menu shortcuts..."

    ; Create the Start Menu folder
    CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"

    ; Create shortcuts to documentation
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\README.lnk" "$INSTDIR\doc\README.md" "" "" "" SW_SHOWNORMAL "" "git-crypt Documentation"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\License.lnk" "$INSTDIR\doc\COPYING" "" "" "" SW_SHOWNORMAL "" "GPL v3 License"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Changelog.lnk" "$INSTDIR\doc\NEWS.md" "" "" "" SW_SHOWNORMAL "" "git-crypt Changelog"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk" "${PRODUCT_WEB_SITE}" "" "" "" SW_SHOWNORMAL "" "Visit git-crypt Website"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "" "" SW_SHOWNORMAL "" "Uninstall git-crypt"

    ; Mark that shortcuts were created (for uninstaller)
    WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "StartMenuCreated" 1
SectionEnd

;-------------------------------------------------------------------------------
; Section Descriptions
;-------------------------------------------------------------------------------
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CORE} "Install the git-crypt executable and documentation. This component is required."
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_PATH} "Add git-crypt to the system PATH environment variable so it can be run from any command prompt without specifying the full path."
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_STARTMENU} "Create shortcuts in the Start Menu for documentation, website link, and uninstaller."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;-------------------------------------------------------------------------------
; Uninstaller Section
;-------------------------------------------------------------------------------
Section "Uninstall"
    ; Remove from PATH if it was added during installation
    ReadRegDWORD $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "PathModified"
    ${If} $0 == 1
        DetailPrint "Removing git-crypt from system PATH..."

        ; Read current PATH
        ReadRegStr $1 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path"

        ; Remove our directory from PATH (handle various cases)
        ${UnStrRep} $1 $1 ";$INSTDIR;" ";"
        ${UnStrRep} $1 $1 "$INSTDIR;" ""
        ${UnStrRep} $1 $1 ";$INSTDIR" ""
        ${UnStrRep} $1 $1 "$INSTDIR" ""

        ; Clean up double semicolons
        ${UnStrRep} $1 $1 ";;" ";"

        ; Write back
        WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "Path" $1

        ; Notify running applications
        SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
    ${EndIf}

    ; Remove Start Menu shortcuts if they were created
    ReadRegDWORD $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "StartMenuCreated"
    ${If} $0 == 1
        DetailPrint "Removing Start Menu shortcuts..."
        Delete "$SMPROGRAMS\${PRODUCT_NAME}\README.lnk"
        Delete "$SMPROGRAMS\${PRODUCT_NAME}\License.lnk"
        Delete "$SMPROGRAMS\${PRODUCT_NAME}\Changelog.lnk"
        Delete "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk"
        Delete "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk"
        RMDir "$SMPROGRAMS\${PRODUCT_NAME}"
    ${EndIf}

    ; Remove installed files
    DetailPrint "Removing installed files..."
    Delete "$INSTDIR\git-crypt.exe"
    Delete "$INSTDIR\doc\README.md"
    Delete "$INSTDIR\doc\COPYING"
    Delete "$INSTDIR\doc\NEWS.md"
    RMDir "$INSTDIR\doc"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"

    ; Remove registry entries
    DetailPrint "Removing registry entries..."
    DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
SectionEnd

;-------------------------------------------------------------------------------
; Callback Functions
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Function: .onInit
;-------------------------------------------------------------------------------
Function .onInit
    ; Check for Windows 64-bit
    ${IfNot} ${RunningX64}
        MessageBox MB_OK|MB_ICONSTOP "This installer requires a 64-bit version of Windows."
        Abort
    ${EndIf}

    ; Enable 64-bit registry and file system access
    SetRegView 64

    ; Check for administrator privileges
    UserInfo::GetAccountType
    Pop $0
    ${If} $0 != "admin"
        MessageBox MB_OK|MB_ICONSTOP "This installer requires administrator privileges.$\r$\n$\r$\nPlease right-click the installer and select 'Run as administrator'."
        Abort
    ${EndIf}

    ; Check if git-crypt is already installed
    ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion"
    ${If} $0 != ""
        MessageBox MB_YESNO|MB_ICONQUESTION "${PRODUCT_NAME} version $0 is already installed.$\r$\n$\r$\nDo you want to replace it with version ${PRODUCT_VERSION}?" IDYES continue
        Abort
        continue:
    ${EndIf}
FunctionEnd

;-------------------------------------------------------------------------------
; Function: un.onInit
;-------------------------------------------------------------------------------
Function un.onInit
    ; Enable 64-bit registry access
    ${If} ${RunningX64}
        SetRegView 64
    ${EndIf}

    ; Confirm uninstallation
    MessageBox MB_YESNO|MB_ICONQUESTION "Are you sure you want to completely remove ${PRODUCT_NAME} and all of its components?" IDYES +2
    Abort
FunctionEnd

;-------------------------------------------------------------------------------
; Function: un.onUninstSuccess
;-------------------------------------------------------------------------------
Function un.onUninstSuccess
    HideWindow
    MessageBox MB_ICONINFORMATION|MB_OK "${PRODUCT_NAME} was successfully removed from your computer."
FunctionEnd
