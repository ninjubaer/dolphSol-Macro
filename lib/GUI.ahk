/************************************************************************
 * @description DolphSol Macro GUI Library
 * @file UI.ahk
 * @author ninju | .ninju. + moksh | sir.moxxi | sanji 
 * @date 2024/05/04
 * @version 0.0.1
 ***********************************************************************/
;! This is only testing; will not be in final
if A_LineFile == A_ScriptFullPath {
	#SingleInstance Force
	#Requires AutoHotkey v2.0
	#MaxThreads 255
	#Warn All, StdOut

	#Include *i ..\..\natroMacroDev\lib\JSON.ahk
	
	#Include Gdip_All.ahk
	ptoken := Gdip_Startup()

	colorTheme := "OG"
	colorThemes := {
		;? Task/SideBar, Background, Text, Dark
		classic: ["23272E", "1e2227", "858c98", "1d1f23"],
		OG: ["878787", "dcdcdc", "000000", "#323232"],
		cozy: ["5A3A31", "635B53", "C4BBAF", "31231E"],
		cyan: ["342C2E", "433E40", "59B5EE", "191E1C"],
		ocean: ["191923", "63768d", "C8E6F9", "101018"],
		ultraviolet: ["36213E", "554971", "E8EBE4", "170E1B"]
	}
	colorChoice := colorThemes.%colorTheme%

	MainGui := MacroGui(, , 500, 250, "DolphSol")
		.OnExit((*) => ExitApp(1))
		;; Main Tab
		.UseTab("Main")
		.AddGroupBox(10, 40, 215, 75, "Obby", 46)
		.AddGroupBox(235, 40, 213, 75, "Auto Equip", 80)
		.AddGroupBox(10, 125, 438, 90, "Item Collecting", 100)
		;? Obby
		.AddSwitch(25, 60, 1, (*) => "", 0).AddText(53,61,unset,unset,"s12","Do Obby")
		.AddSwitch(25, 85, 1, (*) => "", 1).AddText(53,86,unset,unset,"s12","Check for Obby Buff Effect")
		;? Auto Equip
		.AddSwitch(250, 60, 1, (*) => "", 2).AddText(278,61,unset,unset,"s12","Enable Auto Equip")
		.AddButton(245, 85, 100, 20, "Select Slot", (*) => MsgBox("SlotSelection"), "SlotSelection")
		;? Item Collecting
		.AddSwitch(25, 140, 1, (*) => "", 3)
		.AddText(53,141,unset,unset,"s12","Collect Items Around the Map")
		.AddGroupBox(20, 164, 418, 41, "Collect From Spots", 120)
		loop 7
			MainGui.AddSwitch((A_Index-1)*57+35, 180, 1, (*) => "", 3+A_Index)
			.AddText((A_Index-1)*57+68,181,unset,unset,"s12",A_Index)
		;; Crafting Tab
		MainGui.UseTab("Crafting")
		;; Item Crafting
		.AddGroupBox(10, 40, 225, 170, "Item Crafting", 80)
		.AddSwitch(25, 60, 1, (*) => "", 0).AddText(53,61,unset,unset,"s12","Auto Item Crafting")
		.AddGroupBox(20, 90, 200, 110, "Crafting Options", 100)
		.AddSwitch(35, 110, 50, (*) => "", 1).AddText(65,110,unset,unset,"s12","Gilded Coins")
		;? idk how to add a scroller keep it in the crafting options group box tho, just to be clean 
		;? dolph could add more stuff to craft so its best to have it near the bottom to begin with

		;; Potion crafting
		.AddGroupBox(245, 40, 205, 170, "Potion Crafting", 90)
		.AddSwitch(265, 60, 1, (*) => "", 0).AddText(295,61,unset,unset,"s12","Auto Potion Crafting")
		.AddGroupBox(258, 90, 180, 110, "Crafting Slots", 80)

		;; No Tab
		MainGui.UseTab(0)
		.AddButton(10, 222, 70, 20, "Start", (*) => MsgBox("start"), "StartButton")
		.AddButton(90, 222, 70, 20, "Pause", (*) => MsgBox("Pause"), "PauseButton")
		.AddButton(170, 222, 70, 20, "Stop", (*) => MsgBox("Stop"), "StopButton")
		.AddSideBar()
		.Show()
}
Class MacroGui {
	static WS_EX_LAYERED := 0x80000, WS_EX_TOPMOST := 0x8, WS_EX_TOOLWINDOW := 0x80
	__New(x?, y?, w := 500, h := 250, title := "DolphSol", EX_STYLES := 0) {
		this.w := w, this.h := h, this.title := title, this.x := IsSet(x) ? x : (A_ScreenWidth - this.w) // 2, this.y := IsSet(y) ? y : (A_ScreenHeight - this.h) // 2, this.exitFunction := this.tempFunc.Bind(this)
		this.EX_STYLES := MacroGui.WS_EX_LAYERED | EX_STYLES
		(this.Gui := Gui("-Caption +OwnDialogs +E" this.EX_STYLES, this.title)).OnEvent("Close", (*) => (this.exitFunction)())
		this.Gui.show()
		this.Gui.AddText("x7 y2 w" this.w - 14 " h25 vTitle")
		this.Gui.AddText("x" this.w - 37 " y0 w25 h25 vCloseButton")

		this.tab := "Main"
		this.usedTab := 0
		this.controls := []
		this.hoverCtrl := 0

		this.hBM := CreateDIBSection(this.w, this.h)
		this.hDC := CreateCompatibleDC()
		this.obj := SelectObject(this.hDC, this.hBM)
		this.g := Gdip_GraphicsFromHDC(this.hDC)
		Gdip_SetSmoothingMode(this.g, 4), Gdip_SetInterpolationMode(this.g, 7)
		UpdateLayeredWindow(this.Gui.hwnd, this.hdc, this.x || 0, this.y || 0, this.w, this.h)
	}
	tempFunc(*) => ""
	Show() {
		Gdip_GraphicsClear(this.g)
		;; Border
		Gdip_FillRectangle(this.g, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[2]), 5, 0, this.w - 10, this.h)
		;; Title Bar
		Gdip_FillRectangle(this.g, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[1]), 7, 2, this.w - 14, 25), Gdip_DeleteBrush(pBrush)
		Gdip_TextToGraphics(this.g, this.title, "x12 s20 y5 Bold cff" colorChoice[3])
		Gdip_TextToGraphics(this.g, "✕", "x" this.w - 37 " Regular s15 y5 Center vCenter cff" colorChoice[3], "Calibri", 25, 25)
		;; Side Tab Bar
		for i, j in this.controls {
			if (j.HasProp("Tab") && j.tab == this.tab) || !j.HasProp("Tab") || j.tab == 0 {
				switch j.type, 0 {
					case "SideBar":
						Gdip_FillRectangle(this.g, pBrush := Gdip_BrushCreateSolid("0xFF" (j.color || colorChoice[1])), this.w - (j.state ? 120 : 40), 25, j.state ? 113 : 33, this.h - 27)
						Gdip_TextToGraphics(this.g, (j.state ? ">>" : "<<"), "x" this.w - (j.state ? 118 : 38) " s20 y" this.h - 23 " Bold cff" colorChoice[3])
						; Main|Crafting|Status|Settings|Credits
						if j.state
							For k, v in j.tabs {
								if this.tab = v
									Gdip_FillRectangle(this.g, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[2]), this.w - 118, 27 + ((k - 1) * 25), 108, 25), Gdip_DeleteBrush(pBrush)
								Gdip_TextToGraphics(this.g, v, "x" this.w - 118 " s17 y" 33 + (k - 1) * 25 " Bold cff" colorChoice[3])
							}
					case "GroupBox":
						Gdip_DrawRectangle(this.G, pPen := Gdip_CreatePen("0xFF" colorChoice[3], 2), j.x + 5, j.y, j.w, j.h), Gdip_DeletePen(pPen)
						if j.title
							Gdip_FillRectangle(this.G, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[2]), j.x + 8, j.y - 8, j.offset, 16), Gdip_DeleteBrush(pBrush)
								, Gdip_TextToGraphics(this.G, j.title, "x" j.x + 10 " s12 y" j.y - 5 " cff" colorChoice[3])
					case "Button":
						Gdip_DrawRectangle(this.G, pPen := Gdip_CreatePen("0xFF" colorChoice[3], 2), j.x + 5, j.y, j.w, j.h), Gdip_DeletePen(pPen)
						Gdip_FillRectangle(this.G, pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[this.hoverCtrl = "Button" j.name ? 1 : 3]), j.x + 5, j.y + j.h - 3, j.w, 4), Gdip_DeleteBrush(pBrush)
						Gdip_TextToGraphics(this.G, j.text, "Center vCenter x" j.x + 8 " y" j.y + 5 " s12 cFF" colorChoice[3], , j.w - 7, j.h - 10)
					case "Switch":
						pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[3]), Gdip_FillRoundedRectangle(this.G, pBrush, j.x - 1, j.y + 1, 27, 12, 5), Gdip_DeleteBrush(pBrush)
						pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[1]), Gdip_FillRoundedRectangle(this.G, pBrush, j.x, j.y + 2, 25, 10, 5), Gdip_DeleteBrush(pBrush)
						pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[3]), Gdip_FillEllipse(this.G, pBrush, j.x - 1 + j.state * 13, j.y - 0.5, 15, 15), Gdip_DeleteBrush(pBrush)
						if not j.state
							pBrush := Gdip_BrushCreateSolid("0xFF" colorChoice[1]), Gdip_FillEllipse(this.G, pBrush, j.x + 1 + j.state * 13, j.y + 1.5, 11, 11), Gdip_DeleteBrush(pBrush)
					case "Text":Gdip_TextToGraphics(this.G, j.text, j.options " x" j.x " y" j.y " s12 cFF" colorChoice[3], , j.w, j.h)
				}
			}
		}

		UpdateLayeredWindow(this.Gui.hwnd, this.hdc)
		OnMessage(0x201, this.WM_LBUTTONDOWN.bind(this))
		OnMessage(0x0102, this.WM_CHAR.bind(this))
		OnMessage(0x0200, this.WM_MOUSEMOVE.bind(this))
		return this
	}

	AddSideBar(state?, tabs?) {
		this.controls.push(j:={ type: "SideBar", color: "", state: IsSetV(&state) || false, tabs: IsSetV(&tabs) || ["Main", "Crafting", "Status", "Settings", "Credits"] })
		this.Gui.AddText("x" this.w - (IsSetV(&state) ? 118 : 38) " y" this.h - 25 " w30 h25 vSideBarToggle")
		for i in IsSetV(&tabs) || ["Main", "Crafting", "Status", "Settings", "Credits"] {
			this.Gui.AddText("vTabButton" i)
			this.Gui["TabButton" i].Move(j.state ? this.w - 118 : this.w - 38, 27 + ((A_Index - 1) * 25), 108, 25)
		}
		return this
	}

	AddGroupBox(x, y, w, h, title, offset) {
		this.controls.push({ type: "GroupBox", x: x, y: y, w: w, h: h, title: title, offset: offset, tab: this.usedTab })
		return this
	}

	AddButton(x, y, w, h, text, function, name) {
		this.controls.push({ type: "Button", x: x, y: y, w: w, h: h, text: text, name: name, tab: this.usedTab })
		this.Gui.AddText("x" x + 8 " y" y " w" w " h" h " vButton" name).function := function
		return this
	}

	AddSwitch(x, y, state, function, name) {
		this.controls.push({ type: "Switch", x: x, y: y, w: 25, h: 10, state: state, tab: this.usedTab})
		i := this.controls.length
		this.Gui.AddText("x" x " y" y " w" 25 " h" 10 " vSwitch" this.controls.length).function := (p*) => function(this.controls[i].state, p*)
		return this
	}

	AddText(x, y, w?, h?, options:="", text:="") {
		this.controls.push({type: "Text", x: x, y: y, w: IsSetV(&w), h: IsSetV(&h), options: options, text: text, tab: this.usedTab})
		return this
	}

	WM_LBUTTONDOWN(wP, lP, msg, hwnd, *) {
		this.editActive := 0
		if hwnd != this.Gui.hwnd
			return
		MouseGetPos , , , &hCtrl, 2
		if !hCtrl || !GetKeyState("LButton", "P") || hCtrl == this.Gui.hwnd
			return
		switch n := this.Gui[hCtrl].name, 0 {
			case "Title":return PostMessage(0xA1, 2)
			case "CloseButton": return PostMessage(0x112, 0xF060)
			case "MinimizeButton": return PostMessage(0x112, 0xF020)
			case "SideBarToggle":
				for i in this.controls {
					if i.type == "SideBar" {
						i.state := !i.state, this.Gui["SideBarToggle"].Move(i.state ? this.w - 118 : this.w - 38)
						for k, v in i.tabs
							this.Gui["TabButton" v].Move(i.state ? this.w - 118 : this.w - 38, 27 + ((k - 1) * 25), 108, 25)
					}
				}
			default:
				switch {
					case InStr(n, "TabButton"):
						this.tab := SubStr(n, 10)
						this.Show()
					case RegExMatch(n, "^(Button)"):
						(this.Gui[hCtrl].function)()
						KeyWait("LButton")
					case RegExMatch(n, "^Switch(\d+)", &match):
						this.controls[match.1].state := !this.controls[match.1].state
						(this.Gui[hCtrl].function)()
						KeyWait("LButton")
				}
		}
		this.Show()
	}
	WM_CHAR(wParam, lParam, msg, hwnd, *) {
		if hwnd != this.Gui.hwnd
			return
		ToolTip Chr(wParam)
		return
	}
	OnExit(function) {
		this.exitFunction := function
		return this
	}
	UseTab(tab) {
		this.usedTab := tab
		return this
	}
	WM_MOUSEMOVE(*) {
		static oldCtrl := 0
		MouseGetPos , , &hwnd, &hCtrl, 2
		if !hCtrl || hCtrl == this.Gui.hwnd || hwnd !== this.Gui.hwnd
			return this.hoverCtrl != 0 ? (this.hoverCtrl := 0, this.Show(), oldCtrl := hCtrl) : oldCtrl:=hCtrl
		if hCtrl == oldCtrl
			return
		oldCtrl := hCtrl
		this.hoverCtrl := RegExMatch(this.Gui[hCtrl].name, "i)^Button") ? this.Gui[hCtrl].name : 0
		this.Show()
	}
}
IsSetV(&v := unset) => IsSet(v) ? v : 0
