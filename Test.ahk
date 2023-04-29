#include ".\abberium.ahk"

Driver := Abberium() ; this will not intialize without two condition
; 1) WinAppDriver should be installed Abberium() will tell you where to download the latest version its one time
; 2) Developer Mode should be enanled it will ask user to enable developer mode if pressed yes it will enable it using regwrite

; after successfull run user can check for status 
msgbox(Json.stringify(Driver.Status(),1))

; Create AppDriver Session using Exe path
Bin := "C:/Windows/System32/notepad.exe"
NotePad := Driver.NewSession(Bin)

; dump all elements names and Control types
msgbox NotePad.DumpAll()

; Get element using ClassName
edit1 := NotePad.GetElementByClassName("Edit")

; sending Keystrokes 
edit1.sendKey("abcdefghki abdjkhs")
edit1.sendKey(" abdjkhs")

; Getting text of element 
msgbox edit1.text()

; getting all elements with control type Text
x := NotePad.getElementsbyControlType("Text")
; dumping element array 
msgbox NotePad.DumpElements(x)

; Re-access window using Hwnd aka toplevel window handle
NotePad2 := Driver.GetSession(WinExist("*Untitled - Notepad ahk_class Notepad"))
edit1 := NotePad2.GetElementByClassName("Edit")
edit1.sendKey("here I re-accessed this")