/************************************************************************
 * @description DolphSol Macro GUI Library
 * @file UI.ahk
 * @author ninju | .ninju.
 * @date 2024/05/04
 * @version 0.0.1
 ***********************************************************************/
if A_LineFile == A_ScriptFullPath {
    #SingleInstance Force
    #Requires AutoHotkey v2.0
    #MaxThreads 255
    #Warn All, StdOut
    
    
    #Include Gdip_All.ahk
    ptoken := Gdip_Startup()

    colorTheme := "classic"
    colorThemes := {
        classic: [
            "23272E", "1e2227", "858c98", "1d1f23"
        ]
    }
    colorChoice := colorThemes.%colorTheme%

    MainGui := MacroGui(,,500, 250, "DolphSol")
    .OnExit((*)=>ExitApp(1))
    ;; Main Tab
    .UseTab("Main")
    .AddGroupBox(10, 40, 215, 75, "Obby", 46)
    .AddGroupBox(235, 40, 213, 75, "Auto Equip",80)
    .AddGroupBox(10, 125, 438, 90, "Item Collecting", 100)
    ;; No Tab
    .UseTab(0)
    .AddButton(10, 222, 70, 20, "Start", (*) => MsgBox("start"), "StartButton")
    .AddButton(90, 222, 70, 20, "Pause", (*) => MsgBox("Pause"), "PauseButton")
    .AddButton(170, 222, 70, 20, "Stop", (*) => MsgBox("Stop"), "StopButton")
    .AddSideBar()
    .Show()
}
Class MacroGui {
    static WS_EX_LAYERED := 0x80000, WS_EX_TOPMOST := 0x8, WS_EX_TOOLWINDOW := 0x80
    __New(x?,y?, w := 500, h := 250,title:="DolphSol",  EX_STYLES:=0) {
        this.w := w, this.h := h, this.title := title, this.x := IsSet(x) ? x : (A_ScreenWidth - this.w) // 2, this.y := IsSet(y) ? y : (A_ScreenHeight - this.h) // 2, this.exitFunction := this.tempFunc
        this.EX_STYLES := MacroGui.WS_EX_LAYERED | EX_STYLES
        (this.Gui := Gui("-Caption +OwnDialogs +E" this.EX_STYLES, this.title)).OnEvent("Close", (*) => (this.exitFunction)())
        this.Gui.show()
        this.Gui.AddText("x7 y2 w" this.w-14 " h25 vTitle")
        this.Gui.AddText("x" this.w-37 " y0 w25 h25 vCloseButton")

        this.tab := "Main"
        this.usedTab := 0
        this.controls := []

        this.hBM := CreateDIBSection(this.w, this.h)
        this.hDC := CreateCompatibleDC()
        this.obj := SelectObject(this.hDC, this.hBM)
        this.g := Gdip_GraphicsFromHDC(this.hDC)
        Gdip_SetSmoothingMode(this.g, 4), Gdip_SetInterpolationMode(this.g, 7)
        UpdateLayeredWindow(this.Gui.hwnd,this.hdc, this.x || 0, this.y || 0, this.w, this.h)
    }
    tempFunc(*) => ""
    Show() {
        Gdip_GraphicsClear(this.g)
        ;; Border
        Gdip_FillRectangle(this.g, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[2]), 5, 0, this.w-10, this.h)
        ;; Title Bar
        Gdip_FillRectangle(this.g, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[1]), 7, 2, this.w-14, 25), Gdip_DeleteBrush(pBrush)
        Gdip_TextToGraphics(this.g, this.title, "x12 s20 y5 Bold cff" colorChoice[3])
        Gdip_TextToGraphics(this.g,"✕" ,"x" this.w - 37 " Regular s15 y5 Center vCenter cff" colorChoice[3],"Calibri", 25, 25)
        ;; Side Tab Bar
        for i , j in this.controls {
            if (j.HasProp("Tab") && j.tab == this.tab) || !j.HasProp("Tab") || j.tab == 0 {
                switch j.type, 0 {
                    case "SideBar":
                        Gdip_FillRectangle(this.g, pBrush := Gdip_BrushCreateSolid("0xFF" (j.color || colorChoice[1])), this.w - (j.state ? 120 : 40), 25, j.state ? 113 : 33, this.h-27)
                        Gdip_TextToGraphics(this.g, (j.state ? ">>" : "<<"), "x" this.w - (j.state ? 118 : 38) " s20 y" this.h-23 " Bold cff" colorChoice[3])
                        ; Main|Crafting|Status|Settings|Credits
                        if j.state
                            For k,v in j.tabs {
                                if this.tab = v
                                    Gdip_FillRectangle(this.g, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[2]), this.w-118, 27 + ((k-1)*25), 108, 25), Gdip_DeleteBrush(pBrush)
                                Gdip_TextToGraphics(this.g, v, "x" this.w-118 " s17 y" 33 + (k-1)*25 " Bold cff" colorChoice[3])
                            }
                    case "GroupBox":
                        Gdip_DrawRectangle(this.G, pPen := Gdip_CreatePen("0xFF" colorChoice[3], 2), j.x + 5, j.y, j.w, j.h), Gdip_DeletePen(pPen)
                        if j.title
                            Gdip_FillRectangle(this.G, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[2]), j.x+8, j.y-8,j.offset, 16), Gdip_DeleteBrush(pBrush)
                            , Gdip_TextToGraphics(this.G, j.title, "x" j.x+10 " s12 y" j.y-5 " cff" colorChoice[3])
                    case "Button":
                        Gdip_DrawRectangle(this.G, pPen := Gdip_CreatePen("0xFF" colorChoice[3], 2), j.x + 5, j.y, j.w, j.h), Gdip_DeletePen(pPen)
                        Gdip_FillRectangle(this.G, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[3]), j.x+5, j.y+j.h-3, j.w, 3), Gdip_DeleteBrush(pBrush)
                        Gdip_TextToGraphics(this.G, j.text, "Center vCenter x" j.x + 8 " y" j.y+5 " s12 cFF" colorChoice[3],, j.w-7, j.h-10)
                }
            }
        }


        /* for k,v in this.controls {
            switch v.type,0 {
                case "Checkbox":
                    ;drawCheckbox
                    
                default:
                    
            }
        } */
        UpdateLayeredWindow(this.Gui.hwnd, this.hdc)
        OnMessage(0x201, this.WM_LBUTTONDOWN.bind(this))
        return this
    }

    AddSideBar(state?, tabs?) {
        this.controls.push({type: "SideBar", color: "", state: IsSetV(&state) || false, tabs: IsSetV(&tabs) || ["Main", "Crafting", "Status", "Settings", "Credits"]})
        this.Gui.AddText("x" this.w - (IsSetV(&state) ? 118 : 38) " y" this.h-25 " w30 h25 vSideBarToggle")
        for i in IsSetV(&tabs) || ["Main", "Crafting", "Status", "Settings", "Credits"] {
            this.Gui.AddText("x7 y" 27 + (A_Index-1)*25 " w" this.w-14 " h25 vTabButton" i)
        }
        return this
    }

    AddGroupBox(x, y, w, h, title, offset) {
        this.controls.push({type: "GroupBox", x: x, y: y, w: w, h: h, title: title, offset: offset, tab: this.usedTab})
        return this
    }

    AddButton(x, y, w, h, text, function, name) {
        this.controls.push({type: "Button", x: x, y: y, w: w, h: h, text: text, name: name, tab: this.usedTab})
        this.Gui.AddText("x" x+8 " y" y " w" w " h" h " vButton" name).function := function
        return this
    }

    WM_LBUTTONDOWN(*) {
        MouseGetPos ,,, &hCtrl, 2
        if !hCtrl || !GetKeyState("LButton", "P") || hCtrl == this.Gui.hwnd
            return
        switch n:=this.Gui[hCtrl].name, 0 {
            case "Title":
                while GetKeyState("LButton", "P")
                    PostMessage(0xA1, 2)
            case "CloseButton":PostMessage(0x112, 0xF060)
            case "MinimizeButton":PostMessage(0x112, 0xF020)
            case "SideBarToggle":
                for i in this.controls {
                    if i.type == "SideBar"
                        i.state := !i.state, this.Gui["SideBarToggle"].Move(i.state ? this.w-118 : this.w-38)
                }
            default:
                switch {
                    case InStr(n, "TabButton"):
                        this.tab := SubStr(n, 10)
                        this.Show()
                    case RegExMatch(n, "^Button(.+)$",&match):
                        this.Gui[hCtrl].function()
                }
                
        }
        this.Show()
    }
    OnExit(function) {
        this.exitFunction := function
        return this
    }
    UseTab(tab) {
        this.usedTab := tab
        return this
    }
}
IsSetV(&v:=unset) => IsSet(v) ? v : 0