﻿#Requires AutoHotkey v2.0
if A_IsAdmin = 0
{
    result  := Msgbox("Press Yess to Enable AppModelUnlock in order to run WinAppdriver`nThis will write following key to registery`n`n" 'RegWrite( 1, "REG_DWORD", "HKEY_LOCAL_MACHINE \SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock",`n"AllowDevelopmentWithoutDevLicense")`n`nor press No and manually enable developer mode instead' ,"Abeerium AppDriver Notification",4)
    if result = "no"
    {
        Msgbox("WinAppDriver unable run without DevMode enabled from windows security setting`n`nTo Enable DevMode:`nPress Win+I find 'Developer Settings'`nturn one Developer Mode","Abeerium AppDriver Notification")
        exitapp
    }
}

full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}
RegWrite( 1, "REG_DWORD", "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock","AllowDevelopmentWithoutDevLicense")
msgbox "Please restart Abeerium"

