#include ".\AppDriver.ahk"
#Include ".\JSON.ahk"
Class Abberium
{
    static WebRequest := ComObject('WinHttp.WinHttpRequest.5.1')
    static by := ;https://github.com/Microsoft/WinAppDriver/blob/v1.0/README.md#supported-locators-to-find-ui-elements
    {
        AutomationId : "accessibility id",
        ClassName    : "class name",
        RuntimeId    : "id",
        Name         : "name",
        ControlType  : "tag name",
        xpath        : "xpath",
    }

    __New()
    {
        ;{"desiredCapabilities":{"app": "C:/Windows/System32/notepad.exe", "deviceName": "WindowsPC", "platformName": "Windows"}}
        this.Driver  := AppDriver()
		this.address := "http://127.0.0.1:4723"
    }
    
	SetTimeouts(ResolveTimeout:=3000,ConnectTimeout:=3000,SendTimeout:=3000,ReceiveTimeout:=3000)
	{
		Abberium.WebRequest.SetTimeouts(ResolveTimeout,ConnectTimeout,SendTimeout,ReceiveTimeout)
	}

	Send(url,Method:="GET",Payload:= 0,WaitForResponse:=1)
	{
		if !instr(url,"HTTP")
			url := this.address "/" url
		if !Payload and (Method = "POST")
			Payload := Json.null
		try r := Json.parse(Abberium.Request(url,Method,Payload,WaitForResponse)) ; Thanks to GeekDude for his awesome cJson.ahk
		if r.has("error")
			if (r["error"] = "chrome not reachable") ; incase someone close browser manually but session is not closed for driver
				this.quit() ; so we close session for driver at cost of one time response wait lag
		if r
			return r
	}

	static Request(url,Method,p:=0,w:=0)
	{
		Abberium.WebRequest.Open(Method, url, false)
		Abberium.WebRequest.SetRequestHeader("Content-Type","application/json")
		if p
		{
			p := RegExReplace(json.stringify(p),"\\\\uE(\d+)","\uE$1")  ; fixing Keys turn '\\uE000' into '\uE000'
			Abberium.WebRequest.Send(p)
		}
		else
			Abberium.WebRequest.Send()
		if w
			Abberium.WebRequest.WaitForResponse()
        ;Headers := Abberium.WebRequest.GetAllResponseHeaders
		return Abberium.WebRequest.responseText
	}

    Sessions() => this.Send( this.address "/sessions")["value"]

	NewSession(App)
	{
        cap := map(
            "desiredCapabilities",map(
                "app",App,
                "deviceName","WindowsPC",
                "platformName", "Windows"
                )
            )
        return Abb_Session(this.Send( this.address "/session","POST",cap,1),this.address)
	}

    NewHwndSession(WindowHandle)
    {
        cap := map(
            "desiredCapabilities",map(
                "appTopLevelWindow",Format("{:#x}", WindowHandle),
                "deviceName","WindowsPC",
                "platformName", "Windows"
                )
            )
        return Abb_Session(this.Send( this.address "/session","POST",cap,1),this.address)
    }


    GetSessionbyAppName(Name)
    {
        for k, s in this.Sessions()
        {
            if s["capabilities"].HasProp("app")
            {
                SplitPath S.Capabilities.app, &FileName
                if(FileName = Name)
                    return Abb_Session(s,this.address)
            }
        }
    }

    GetSessionbyLocation(Exe)
    {
        for k, s in this.Sessions()
        {
            if s["capabilities"].HasProp("app")
            {
                if(s["capabilities"]["app"] = Exe)
                    return Abb_Session(s,this.address)
            }
        }
    }

    GetSessionbyHwnd(Hwnd)
    {
        for k, s in x := this.Sessions()
        {
            if s["capabilities"].HasProp("appTopLevelWindow")
            {
                if(s["capabilities"]["appTopLevelWindow"] = Hwnd)
                    return Abb_Session(s,this.address)
            }
        }
    }

    Status() => this.Send("status")
	Exit() => this.Driver.close()
}

Class Abb_Session
{
    __New(D,Address)
    {
        This.id        := D["sessionId"]
        This.Address   := Address "/session/" This.id
        if D["value"].HasProp("app")
            This.app   := D["value"]["app"]
    }

    Send(url,Method:="GET",Payload:= 0,WaitForResponse:=1)
	{
		if !instr(url,"HTTP")
			url := this.address "/" url
		if !Payload and (Method = "POST")
			Payload := Json.null
		try r := Json.parse(Abberium.Request(url,Method,Payload,WaitForResponse)) ; Thanks to GeekDude for his awesome cJson.ahk
		if r.has("error")
			if (r["error"] = "chrome not reachable") ; incase someone close browser manually but session is not closed for driver
				this.quit() ; so we close session for driver at cost of one time response wait lag
		if r
			return r
	}

    
    Delete()            => this.Send("","Delete")["value"]
    Title()             => this.Send("title")["value"]
    source()            => this.Send("source")["value"]
    orientation()       => this.Send("orientation")["value"]
    screenshot()        => this.Send("screenshot")["value"]
    location()          => this.Send("location")["value"]

    element(using,Value)
    {
        return Abb_Element(this.Send("element","POST",Map("using",using,"value",Value))["value"],this.Address)
    }

    elements(using,Value)
    {
        e := []
        for k, element in this.Send("elements","POST",Map("using",using,"value",Value))["value"]
            e.Push(Abb_Element(element,this.Address))
        return e
    }

    getElementbyID(id)                   => this.element(Abberium.by.AutomationId,id)
    getElementbyClassName(ClassName)     => this.element(Abberium.by.ClassName,ClassName)
    getElementbyRuntimeId(RuntimeId)     => this.element(Abberium.by.RuntimeId,RuntimeId)
    getElementbyName(Name)               => this.element(Abberium.by.Name,Name)
    getElementbyControlType(ControlType) => this.element(Abberium.by.ControlType,ControlType)
    getElementbyxpath(xpath)             => this.element(Abberium.by.xpath,xpath)

    getElementsbyID(id)                   => this.elements(Abberium.by.AutomationId,id)
    getElementsbyClassName(ClassName)     => this.elements(Abberium.by.ClassName,ClassName)
    getElementsbyRuntimeId(RuntimeId)     => this.elements(Abberium.by.RuntimeId,RuntimeId)
    getElementsbyName(Name)               => this.elements(Abberium.by.Name,Name)
    getElementsbyControlType(ControlType) => this.elements(Abberium.by.ControlType,ControlType)
    getElementsbyxpath(xpath)             => this.elements(Abberium.by.xpath,xpath)

    DumpAll() => this.DumpElements(this.getElementsbyxpath("//*"))
    DumpElements(elements)
    {
        for k, ele in elements
            i .= k ": Element: " ele.Text() "`t-`t" ele.Name() "`n"
        return i
    }
}

Class Abb_Element
{
    __New(D,Address)
    {
        This.id     := D["ELEMENT"]
        This.Address    := Address "/element/" This.id
    }

    Send(url,Method:="GET",Payload:= 0,WaitForResponse:=1)
	{
		if !instr(url,"HTTP")
			url := this.address "/" url
		if !Payload and (Method = "POST")
			Payload := Json.null
		try r := Json.parse(Abberium.Request(url,Method,Payload,WaitForResponse)) ; Thanks to GeekDude for his awesome cJson.ahk
		if r.has("error")
			if (r["error"] = "chrome not reachable") ; incase someone close browser manually but session is not closed for driver
				this.quit() ; so we close session for driver at cost of one time response wait lag
		if r
			return r
	}

    Click()                 => this.Send("click","POST")
    name()                  => this.Send("name")["value"]
    ;value()                 => this.Send("value")["value"]
    text()                  => this.Send("text")["value"]
    size()                  => this.Send("size")["value"]
    displayed()             => this.Send("displayed")["value"]
    selected()              => this.Send("selected")["value"]
    enabled()               => this.Send("enabled")["value"]
    equals()                => this.Send("equals")["value"]
    location()              => this.Send("location")["value"]
    location_in_view()      => this.Send("location_in_view")["value"]
    screenshot()            => this.Send("screenshot")["value"]
    sendKey(text)           => this.Send("value","POST", map("value",StrSplit(text)))

}
