; Abeerium is using JSON CPP by thqby see below link for dll and example
; https://www.autohotkey.com/boards/viewtopic.php?t=100602
; Native.ahk and written by thqby
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=100197
#Include ".\JSON\Native.ahk"
class JSON {
    static __New() {
        Native.LoadModule('.\JSON\' (A_PtrSize * 8) 'bit\ahk-json.dll', ['JSON'])
        this.DefineProp('true', {value: ComValue(11, 65535)})
        this.DefineProp('false', {value: ComValue(11, 0)})
        this.DefineProp('null', {value: ComValue(1, 0)})
    }
    static parse(str) => 1
    static stringify(obj, space := 0) => ""
}
