Class AppDriver
{
    Static DriverLocation := A_ProgramFiles (A_Is64bitOS ? " (x86)" : "") "\Windows Application Driver\WinAppDriver.exe"
    Static DriverReleases := "https://github.com/microsoft/WinAppDriver/releases"

    __New(Port:=4723)
    {
        AppDriver.AppDriverFormilities()
        this.PID := AppDriver.PID := ProcessExist("WinAppDriver.exe")
        if AppDriver.PID = 0
            this.Run()
    }

    Run()
    {
        run AppDriver.DriverLocation " 4723",, "Hide", &PID
        this.PID := AppDriver.PID := PID
    }

    Close() => ProcessClose(this.pid)
    Disabled() => AppDriver.unRegister()

    Static AppDriverFormilities()
    {
        AppDriver.CheckDriverAvailibility()
        try This.DevMode := AppDriver.CheckDriverRegistry()
        catch Error as e
            AppDriver.ForceRegister()
        if This.DevMode = 0
        {
            i := "Press Yes to enbale Developer Mode"
            result := Msgbox(i,"Abeerium AppDriver Notification",4)
            if result = "No"
                exitapp
            AppDriver.Register()
        }
    }

    Static CheckDriverAvailibility()
    {
        if !FileExist(AppDriver.DriverLocation)
        {
            i := "Unable to find Driver at Following Address:`n'" AppDriver.DriverLocation 
            .    "'`nPlease Download Latest WinAppDriver from URL:`n'" AppDriver.DriverReleases 
            .    "'`nPress Ok to Open above Link"
            result := Msgbox(i,"Abeerium AppDriver Notification",1)
            if result = "Cancel"
                exitapp
            run AppDriver.DriverReleases
            exitapp
        }
    }

    static CheckDriverRegistry() => RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock","AllowDevelopmentWithoutDevLicense")
    static Register()   => RegWrite( 1, "REG_DWORD", "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock","AllowDevelopmentWithoutDevLicense")
    static unRegister() => RegWrite( 0, "REG_DWORD", "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock","AllowDevelopmentWithoutDevLicense")
    static ForceRegister()
    {
        run '*UIAccess "' A_ScriptDir '\ForceRegisterDevMode.ahk"'
        exitapp
    }

}
