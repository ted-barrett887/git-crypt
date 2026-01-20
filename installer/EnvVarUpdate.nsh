/**
 *  EnvVarUpdate.nsh
 *    : Environmental Variables: append, prepend, and remove entries
 *
 *     WARNING: If you use StrFunc.nsh header then include it before this file
 *              with all required definitions. This is to avoid conflicts
 *
 *  Usage:
 *    ${EnvVarUpdate} "ResultVar" "MYVAR" "A|P|R" "HKLM|HKCU" "new string"
 *
 *  Credits:
 *  Version 1.0
 *  * Cal Turney (turnec2)
 *  * Wikipedia http://en.wikipedia.org/wiki/Environment_variable
 *
 *  Version 1.1
 *  * ttte
 *  * NickLawson
 *  * learncode
 *
 *  http://nsis.sourceforge.net/Environmental_Variables:_append%2C_prepend%2C_and_remove_entries
 *
 */

!ifndef ENVVARUPDATE_FUNCTION
!define ENVVARUPDATE_FUNCTION
!verbose push
!verbose 3
!include "LogicLib.nsh"
!include "WinMessages.NSH"
!include "StrFunc.nsh"

; StrStr function is required
${StrStr}
${StrTok}
${StrRep}

!define EnvVarUpdate '!insertmacro "_EnvVarUpdateCall"'
!define un.EnvVarUpdate '!insertmacro "_un.EnvVarUpdateCall"'

!macro _EnvVarUpdateConstructor
Function _EnvVarUpdate
  ; Stack: $0 ResultVar, $1 EnvVarName, $2 Action, $3 RegLoc, $4 PathString
  Exch $4
  Exch
  Exch $3
  Exch 2
  Exch $2
  Exch 3
  Exch $1
  Exch 4
  Exch $0
  Push $5
  Push $6
  Push $7
  Push $8
  Push $9
  Push $R0

  ; Read current value
  ${If} $3 == "HKLM"
    ReadRegStr $5 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" $1
  ${ElseIf} $3 == "HKCU"
    ReadRegStr $5 HKCU "Environment" $1
  ${EndIf}

  ; Skip the ';' at the beginning or end
  StrCpy $6 $5 1
  ${If} $6 == ";"
    StrCpy $5 $5 "" 1
  ${EndIf}
  StrLen $6 $5
  IntOp $6 $6 - 1
  StrCpy $7 $5 1 $6
  ${If} $7 == ";"
    StrCpy $5 $5 $6
  ${EndIf}

  ; Determine action
  ${If} $2 == "A"    ; Append
    ; Check if already exists
    ${StrStr} $6 $5 $4
    ${If} $6 == ""
      ; Not found, append
      ${If} $5 != ""
        StrCpy $5 "$5;$4"
      ${Else}
        StrCpy $5 $4
      ${EndIf}
    ${EndIf}
  ${ElseIf} $2 == "P" ; Prepend
    ; Check if already exists
    ${StrStr} $6 $5 $4
    ${If} $6 == ""
      ; Not found, prepend
      ${If} $5 != ""
        StrCpy $5 "$4;$5"
      ${Else}
        StrCpy $5 $4
      ${EndIf}
    ${EndIf}
  ${ElseIf} $2 == "R" ; Remove
    ; Find and remove
    ${StrRep} $5 $5 ";$4;" ";"
    ${StrRep} $5 $5 "$4;" ""
    ${StrRep} $5 $5 ";$4" ""
    ${StrRep} $5 $5 "$4" ""
  ${EndIf}

  ; Clean up any double semicolons
  ${StrRep} $5 $5 ";;" ";"

  ; Remove trailing/leading semicolons
  StrCpy $6 $5 1
  ${If} $6 == ";"
    StrCpy $5 $5 "" 1
  ${EndIf}
  StrLen $6 $5
  IntOp $6 $6 - 1
  ${If} $6 >= 0
    StrCpy $7 $5 1 $6
    ${If} $7 == ";"
      StrCpy $5 $5 $6
    ${EndIf}
  ${EndIf}

  ; Write back
  ${If} $3 == "HKLM"
    WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" $1 $5
  ${ElseIf} $3 == "HKCU"
    WriteRegExpandStr HKCU "Environment" $1 $5
  ${EndIf}

  ; Store result
  StrCpy $0 $5

  Pop $R0
  Pop $9
  Pop $8
  Pop $7
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Exch $0
FunctionEnd
!macroend

!macro _un.EnvVarUpdateConstructor
Function un._EnvVarUpdate
  ; Stack: $0 ResultVar, $1 EnvVarName, $2 Action, $3 RegLoc, $4 PathString
  Exch $4
  Exch
  Exch $3
  Exch 2
  Exch $2
  Exch 3
  Exch $1
  Exch 4
  Exch $0
  Push $5
  Push $6
  Push $7
  Push $8
  Push $9
  Push $R0

  ; Read current value
  ${If} $3 == "HKLM"
    ReadRegStr $5 HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" $1
  ${ElseIf} $3 == "HKCU"
    ReadRegStr $5 HKCU "Environment" $1
  ${EndIf}

  ; Skip the ';' at the beginning or end
  StrCpy $6 $5 1
  ${If} $6 == ";"
    StrCpy $5 $5 "" 1
  ${EndIf}
  StrLen $6 $5
  IntOp $6 $6 - 1
  StrCpy $7 $5 1 $6
  ${If} $7 == ";"
    StrCpy $5 $5 $6
  ${EndIf}

  ; Determine action
  ${If} $2 == "A"    ; Append
    ; Check if already exists
    ${UnStrStr} $6 $5 $4
    ${If} $6 == ""
      ; Not found, append
      ${If} $5 != ""
        StrCpy $5 "$5;$4"
      ${Else}
        StrCpy $5 $4
      ${EndIf}
    ${EndIf}
  ${ElseIf} $2 == "P" ; Prepend
    ; Check if already exists
    ${UnStrStr} $6 $5 $4
    ${If} $6 == ""
      ; Not found, prepend
      ${If} $5 != ""
        StrCpy $5 "$4;$5"
      ${Else}
        StrCpy $5 $4
      ${EndIf}
    ${EndIf}
  ${ElseIf} $2 == "R" ; Remove
    ; Find and remove
    ${UnStrRep} $5 $5 ";$4;" ";"
    ${UnStrRep} $5 $5 "$4;" ""
    ${UnStrRep} $5 $5 ";$4" ""
    ${UnStrRep} $5 $5 "$4" ""
  ${EndIf}

  ; Clean up any double semicolons
  ${UnStrRep} $5 $5 ";;" ";"

  ; Remove trailing/leading semicolons
  StrCpy $6 $5 1
  ${If} $6 == ";"
    StrCpy $5 $5 "" 1
  ${EndIf}
  StrLen $6 $5
  IntOp $6 $6 - 1
  ${If} $6 >= 0
    StrCpy $7 $5 1 $6
    ${If} $7 == ";"
      StrCpy $5 $5 $6
    ${EndIf}
  ${EndIf}

  ; Write back
  ${If} $3 == "HKLM"
    WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" $1 $5
  ${ElseIf} $3 == "HKCU"
    WriteRegExpandStr HKCU "Environment" $1 $5
  ${EndIf}

  ; Store result
  StrCpy $0 $5

  Pop $R0
  Pop $9
  Pop $8
  Pop $7
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Exch $0
FunctionEnd
!macroend

!macro _EnvVarUpdateCall _RV _VN _A _RL _PS
  Push "${_VN}"
  Push "${_A}"
  Push "${_RL}"
  Push "${_PS}"
  Call _EnvVarUpdate
  Pop ${_RV}
!macroend

!macro _un.EnvVarUpdateCall _RV _VN _A _RL _PS
  Push "${_VN}"
  Push "${_A}"
  Push "${_RL}"
  Push "${_PS}"
  Call un._EnvVarUpdate
  Pop ${_RV}
!macroend

!insertmacro _EnvVarUpdateConstructor
!insertmacro _un.EnvVarUpdateConstructor

; Define uninstaller versions of StrFunc functions
${UnStrStr}
${UnStrRep}

!verbose pop
!endif
