/*
"Absolute" mode mouse to keyboard script.
By evilc and Slightly adapted to my usage.
*/
#SingleInstance, Force
CoordMode, Mouse, Screen

; User configurable section
UpKey := "i"
DownKey := "k"
LeftKey := "j"
RightKey := "l"
ToggleKey := "F1"				; Key that toggles on/off mouse to keyboard
; Settings for when using no overlay image
DeadZoneX := 0					; if this close to the center, do not move left or right. Use -1 to auto-calculate deadzone from overlay pic
DeadZoneY := 0					; if this close to the center, do not move up or down. Use -1 to auto-calculate deadzone from overlay pic

; Settings for when using an overlay image
;DeadZoneX := -1					; if this close to the center, do not move left or right. Use -1 to auto-calculate deadzone from overlay pic
;DeadZoneY := -1					; if this close to the center, do not move up or down. Use -1 to auto-calculate deadzone from overlay pic
;PicFile := "Overlay.png"		; Path to overlay image. Comment out to disable
;PicTrans := 150					; Transparency level of overlay image. 0 (totally transparent) to 255 (totally opaque)

; End of user configurable section
Center := {x: round(A_ScreenWidth / 2), y: round(A_ScreenHeight / 2)}
DirStates := {x: 0, y: 0}
DirKeys := {x: {-1: LeftKey, 1: RightKey}, y: {-1: UpKey, 1: DownKey}}
MacroOn := 0
hotkey, % ToggleKey, DoToggle
UseGui := PicFile ? 1 : 0

if (UseGui){
	if (!FileExist(PicFile)){
		msgbox % "Could not find overlay file " PicFile
		ExitApp
	}
	Gui +HwndhOverlayGui
	Gui, Margin, 0, 0
	Gui -Caption +AlwaysOnTop
	Gui, Add, Picture, HwndhOverlayPic , % PicFile
	controlgetpos,,,PicW,PicH,, % "ahk_id " hOverlayPic
	GuiX := Center.x - (PicW / 2)
	GuiY := Center.y - (PicH / 2)
	Gui, Show, % "x" GuiX " y" GuiY
	WinSet, Trans, % PicTrans, % "ahk_id " hOverlayGui
	Gui, Hide
}
DeadZone := {x: DeadZoneX, y: DeadZoneY}
dz_vars := {x: "PicW", y: "PicH"}
err := 0
For axis in DirStates {
	If (DeadZone[axis] == -1 && UseGui){
		DeadZone[axis] := dz_vars[axis]
	} else if (DeadZone[axis] == -1){
		err := 1
	}
}
if (err){
	msgbox % "Could not auto-calculate DeadZone, probably because you specified no overlay file in PicFile"
}
return

DoToggle:
	MacroOn := !MacroOn
	SoundBeep, % 500 + (MacroOn * 300), 100
	if (MacroOn){
		if (UseGui){
			Gui, Show, NoActivate
		}
		SetTimer, DoLoop, -0
	} else {
		if (UseGui){
			Gui, Hide
		}
	}
	return

DoLoop:
	MouseMove, % Center.x, % Center.y, 0
	while (MacroOn) {
		MouseGetPos, x, y
		pos := {x: x - Center.x, y: y - Center.y}
		;Tooltip % "x: " pos.x ", y: " pos.y
		; Loop twice - once with axis holding "x", once with it holding "y"
		For axis in DirStates {
			; Is the magnitude of the deflection greater than DeadZone?
			if (abs(pos[axis]) > DeadZone && abs(abs(DirStates[axis]) - abs(pos[axis])) > 1){
				; Work out the new vector (If the movement is -1, +1 or 0)
				; Essentially clamps a number to an integer between -1 and +1
				new_vector := round(pos[axis] / abs(pos[axis]))
			} else {
				new_vector := 0
			}
			old_vector := DirStates[axis]
			; Did the state change?
			if (old_vector != new_vector){
				; If old_vector is non-zero, release the key that was held
				if (old_vector){
					Send % "{" DirKeys[axis, old_vector] " up}"
				}
				
				; If new_vector is non-zero, hold the new key
				if (new_vector){
					Send % "{" DirKeys[axis, new_vector] " down}"
				}
				
				; Update the state of the this axis
				DirStates[axis] := new_vector
			}
		}
		Sleep 10
	}
	return

