; example2.nsi
;
; This script is based on example1.nsi, but it remember the directory,
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects,

;--------------------------------

;Include Modern UI

!include "MUI2.nsh"

; Section define/macro header file
; See this header file for more info

!include "Sections.nsh"

; For code readability
!include "LogicLib.nsh"

; For win7 install path
!include "WinVer.nsh"

;--------------------------------

!define PROGRAM_NAME PyBingWallpaper

; The name of the installer
Name ${PROGRAM_NAME}

; The file to write
OutFile "pybingwp-1-6-0.exe"

InstallDir $PROGRAMFILES\Genzj\${PROGRAM_NAME}

; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\Genzj\${PROGRAM_NAME}" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

; My license
LicenseData $(license)
;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
  ;!define MUI_LANGDLL_REGISTRY_ROOT "HKCU"
  ;!define MUI_LANGDLL_REGISTRY_KEY "Software\Genzj"
  ;!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

;--------------------------------
;Variables
Var MARKET_CODE
Var COUNTRY_CHOSEN
Var STARTUP_MODE

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE $(license)
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"
  !insertmacro MUI_LANGUAGE "SimpChinese"


LicenseLangString license ${LANG_ENGLISH} LICENSE.txt
LicenseLangString license ${LANG_SimpChinese} LICENSE-zhcn.txt

;--------------------------------
;Reserve Files

  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.

  !insertmacro MUI_RESERVEFILE_LANGDLL


;--------------------------------

; The stuff to install
Section $(NAME_SecMain) SecMain

  SectionIn RO

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  ; Build target files
  !system 'pyinstaller -y build.spec'

  ; Put file there
  !cd ./dist/BingWallpaper
  File /r /x *.pyc /x __pycache__ /x tk*.dll /x tcl*.dll "*"
  !cd ../..
  File "res\bingwallpaper.ico"

  ; Write the installation path into the registry
  WriteRegStr HKLM Software\Genzj\${PROGRAM_NAME} "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "DisplayName" ${PROGRAM_NAME}
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
SectionEnd

SectionGroup $(NAME_SecGrCountry) SecGrCountry
  Section "Auto" country_auto
    StrCpy $MARKET_CODE ""
  SectionEnd
  Section /o "Australia" country_au
    StrCpy $MARKET_CODE "en-AU"
  SectionEnd
  Section /o "Brazil" country_br
    StrCpy $MARKET_CODE "pt-BR"
  SectionEnd
  Section /o "Canada" country_ca
    StrCpy $MARKET_CODE "en-CA"
  SectionEnd
  Section /o "China (HD)" country_cn
    StrCpy $MARKET_CODE "zh-CN"
  SectionEnd
  Section /o "Germany" country_de
    StrCpy $MARKET_CODE "de-DE"
  SectionEnd
  Section /o "France" country_fr
    StrCpy $MARKET_CODE "fr-FR"
  SectionEnd
  Section /o "Japan" country_jp
    StrCpy $MARKET_CODE "ja-JP"
  SectionEnd
  Section /o "New Zealand (HD)" country_nz
    StrCpy $MARKET_CODE "en-NZ"
  SectionEnd
  Section /o "USA (HD)" country_us
    StrCpy $MARKET_CODE "en-US"
  SectionEnd
  Section /o "United Kingdom" country_uk
    StrCpy $MARKET_CODE "en-GB"
  SectionEnd
SectionGroupEnd

Section "-generate configuration file"
  IfFileExists "$INSTDIR\settings.conf" +2 0
    ExecWait '"$INSTDIR\BingWallpaper.exe" --country auto --market "$MARKET_CODE" --generate-config'
SectionEnd

Section $(NAME_SecStartMenu) SecStartMenu
  CreateDirectory "$SMPROGRAMS\${PROGRAM_NAME}"
  CreateShortCut "$SMPROGRAMS\${PROGRAM_NAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\${PROGRAM_NAME}\${PROGRAM_NAME}.lnk" "$INSTDIR\BingWallpaper.exe" \
                 "--redownload --foreground" "$INSTDIR\bingwallpaper.ico" 0
  CreateShortCut "$SMPROGRAMS\${PROGRAM_NAME}\${PROGRAM_NAME} Commandline Mode.lnk" "cmd" \
                 '/k "$INSTDIR\BingWallpaper-cli.exe" --redownload --foreground' \
                 "$INSTDIR\bingwallpaper.ico" 0
  CreateShortCut "$SMPROGRAMS\${PROGRAM_NAME}\Edit Configuration.lnk" "notepad.exe" \
                 '"$INSTDIR\settings.conf"' \
                 "$INSTDIR\bingwallpaper.ico" 0
SectionEnd

; Create auto startup
Section $(NAME_SecStartup) SecStartup
  StrCpy $STARTUP_MODE "background"
SectionEnd

; Create auto startup
Section /o $(NAME_SecStartupOnce) SecStartupOnce
  StrCpy $STARTUP_MODE "foreground"
SectionEnd

Section -InstallStartup
  ${If} $STARTUP_MODE == 'background'
    CreateShortCut "$SMSTARTUP\${PROGRAM_NAME}.lnk" "$INSTDIR\BingWallpaper.exe" "-b" "$INSTDIR\bingwallpaper.ico" 0
  ${ElseIf} $STARTUP_MODE == 'foreground'
    CreateShortCut "$SMSTARTUP\${PROGRAM_NAME}.lnk" "$INSTDIR\BingWallpaper.exe" "--foreground" "$INSTDIR\bingwallpaper.ico" 0
  ${Else}
    ; no startup
  ${EndIf}

SectionEnd

; Run it immediately
Section $(NAME_SecRunit) SecRunit
  Exec '"$INSTDIR\BingWallpaper.exe" -b'
SectionEnd

;--------------------------------
;Descriptions

  ;USE A LANGUAGE STRING IF YOU WANT YOUR DESCRIPTIONS TO BE LANGAUGE SPECIFIC
  LangString NAME_SecMain ${LANG_ENGLISH} "!PyBingWallpaper Main Programs"
  LangString NAME_SecStartMenu ${LANG_ENGLISH} "Start Menu Shortcuts"
  LangString NAME_SecStartup ${LANG_ENGLISH} "Run at Windows Startup"
  LangString NAME_SecStartupOnce ${LANG_ENGLISH} "Don't run in background after auto start."
  LangString NAME_SecRunit ${LANG_ENGLISH} "Change Wallpaper After Installation"
  LangString NAME_SecGrCountry ${LANG_ENGLISH} "Country Setting"

  LangString DESC_SecMain ${LANG_ENGLISH} "Main program files of ${PROGRAM_NAME}."
  LangString DESC_SecStartMenu ${LANG_ENGLISH} "Create Start Menu shortcuts for ${PROGRAM_NAME}"
  LangString DESC_SecStartup ${LANG_ENGLISH} "Auto run ${PROGRAM_NAME} at Windows startup (network connection at startup is required)"
  LangString DESC_SecStartupOnce ${LANG_ENGLISH} "Exit after downloading wallpaper (i.e. disables auto updating)."
  LangString DESC_SecRunit ${LANG_ENGLISH} "Run ${PROGRAM_NAME} and change wallpaper immediately after installation"
  LangString DESC_SecGrCountry ${LANG_ENGLISH} "wallpaper may vary in different countries. Countries marked (HD) support high resolution wallpapers(1920x1200)"

  LangString ASK_FOR_CONFIG_DEL1 ${LANG_ENGLISH} "Do you want to remove all files in installation path?"
  LangString ASK_FOR_CONFIG_DEL2 ${LANG_ENGLISH} "Removed files (including configuration and wallpapers if you put them under installation path) can't be restored, are you sure you want to remove them?"



  LangString NAME_SecMain ${LANG_SimpChinese} "PyBingWallpaper������"
  LangString NAME_SecStartMenu ${LANG_SimpChinese} "������ʼ�˵���ݷ�ʽ"
  LangString NAME_SecStartup ${LANG_SimpChinese} "ϵͳ����ʱ����"
  LangString NAME_SecStartupOnce ${LANG_SimpChinese} "�Զ����в�פ���ڴ�"
  LangString NAME_SecRunit ${LANG_SimpChinese} "������������"
  LangString NAME_SecGrCountry ${LANG_SimpChinese} "��������"

  LangString DESC_SecMain ${LANG_SimpChinese} "${PROGRAM_NAME}�������ļ�"
  LangString DESC_SecStartMenu ${LANG_SimpChinese} "�ڿ�ʼ�˵�����${PROGRAM_NAME}��ݷ�ʽ"
  LangString DESC_SecStartup ${LANG_SimpChinese} "����Windowsʱ�Զ�����${PROGRAM_NAME}������ʱ��Ҫ�������磩"
  LangString DESC_SecStartupOnce ${LANG_SimpChinese} "�Զ����к��˳����򣬲�פ���ڴ棨�����Զ�������ѡ�д���رն�ʱ�������ܣ�"
  LangString DESC_SecRunit ${LANG_SimpChinese} "��װ��ɺ�����${PROGRAM_NAME}����Ҫ�������磩"
  LangString DESC_SecGrCountry ${LANG_SimpChinese} "��ͬ���ҷ���Bing.comʱ������ܻ᲻ͬ������HD�ķ�վ֧�ָ߷ֱ�������(4K/1920x1200)"

  LangString ASK_FOR_CONFIG_DEL1 ${LANG_SimpChinese} "�Ƿ�ɾ����װĿ¼�µ������ļ���"
  LangString ASK_FOR_CONFIG_DEL2 ${LANG_SimpChinese} "��װĿ¼�µ������ļ������������ļ��������û������ļ���ɾ���󲻿ɻָ���ȷ��ɾ����"

  ;Assign descriptions to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} $(DESC_SecStartMenu)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecStartup} $(DESC_SecStartup)
	!insertmacro MUI_DESCRIPTION_TEXT ${SecStartupOnce} $(DESC_SecStartupOnce)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecRunit} $(DESC_SecRunit)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecGrCountry} $(DESC_SecGrCountry)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END


;--------------------------------

; Uninstaller

Function un.kill_running_instances
  Push $0
  Push $1
  StrCpy $0 $R1
  DetailPrint "Searching for processes called '$0'"
  KillProc::FindProcesses
  StrCmp $1 "-1" wooops
  DetailPrint "-> Found $0 processes"

  StrCmp $0 "0" completed
  Sleep 1500

  StrCpy $0 $R1
  DetailPrint "Killing all processes called '$0'"
  KillProc::KillProcesses
  StrCmp $1 "-1" wooops
  DetailPrint "-> Killed $0 processes, failed to kill $1 processes"

  Goto completed

  wooops:
  DetailPrint "-> Error: Something went wrong :-("
  Pop $1
  Pop $0
  Abort

  completed:
  DetailPrint "Everything went okay :-D"
  Pop $1
  Pop $0
FunctionEnd

Section "Uninstall"

  StrCpy $R1 "BingWallpaper.exe"
  Call un.kill_running_instances

  StrCpy $R1 "BingWallpaper-cli.exe"
  Call un.kill_running_instances

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}"
  DeleteRegKey HKLM "Software\Genzj\${PROGRAM_NAME}"
  DeleteRegKey /ifempty HKLM "Software\Genzj"

  ; Remove files and uninstaller
  Delete "$INSTDIR\*.pyd"
  Delete "$INSTDIR\*.exe"
  Delete "$INSTDIR\*.zip"
  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\bingwallpaper.ico"
  Delete "$INSTDIR\__pycache__\*.*"
  RMDir /r "$INSTDIR\__pycache__"

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\${PROGRAM_NAME}\*.*"
  Delete "$SMSTARTUP\${PROGRAM_NAME}.lnk"

  ; Remove directories used
  RMDir "$SMPROGRAMS\${PROGRAM_NAME}"

  MessageBox MB_YESNO|MB_DEFBUTTON2 $(ASK_FOR_CONFIG_DEL1) /SD IDNO IDYES askagain IDNO keepconfig
askagain:
  MessageBox MB_YESNO|MB_DEFBUTTON2 $(ASK_FOR_CONFIG_DEL2) IDYES delall IDNO keepconfig
delall:
  Delete "$INSTDIR\*.*"
  RMDir /r "$INSTDIR"
  Quit
keepconfig:
  DetailPrint "keep user files in $INSTDIR"
SectionEnd

;--------------------------------
Function upgrade
  Push $R0
; Uninstall old version before install a new one
  ReadRegStr $R0 HKLM \
        "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" \
        "UninstallString"
  StrCmp $R0 "" done
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
          "${PROGRAM_NAME} is already installed. $\n$\nClick 'OK' to remove the \
          previous version or 'Cancel' to cancel this upgrade." \
          IDOK uninst
  Abort

uninst:
  ReadRegStr $R0 HKLM "Software\Genzj\${PROGRAM_NAME}" "Install_Dir"
  ClearErrors
  Exec $R0\uninstall.exe
done:
  Pop $R0
FunctionEnd

Function .onInit
  StrCpy $MARKET_CODE ""
  StrCpy $COUNTRY_CHOSEN ${country_auto}
  StrCpy $STARTUP_MODE ""

  ; issue #31: for win7 and above, program files folder is access-limited so
  ; that editing configuration file becomes inconvenient. install to appdata
  ; instead
  ${If} ${AtLeastWin7}
    StrCpy $INSTDIR "$APPDATA\Genzj\PyBingWallpaper"
  ${EndIf}

  Call upgrade
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function un.onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function .onSelChange

  !insertmacro StartRadioButtons $COUNTRY_CHOSEN
    !insertmacro RadioButton ${country_auto}
    !insertmacro RadioButton ${country_au}
    !insertmacro RadioButton ${country_br}
    !insertmacro RadioButton ${country_ca}
    !insertmacro RadioButton ${country_cn}
    !insertmacro RadioButton ${country_de}
    !insertmacro RadioButton ${country_fr}
    !insertmacro RadioButton ${country_jp}
    !insertmacro RadioButton ${country_nz}
    !insertmacro RadioButton ${country_us}
    !insertmacro RadioButton ${country_uk}
  !insertmacro EndRadioButtons
	
FunctionEnd

