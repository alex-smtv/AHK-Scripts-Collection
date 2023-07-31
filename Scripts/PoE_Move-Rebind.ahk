#SingleInstance, Force
#IfWinActive, ahk_class POEWindowClass
SendMode, Input

;;; Setup vars

;--- "Toggle" Key for toggling on/off the script.
toggleKey := "F1"
isToggleKeySendInput := false ; true: toggle key is also pressed, false: toggle key is silent.

;--- "Bind" Key that will have the new binding.
; Single press => "Bind-To" Key (see below)
; Double press => "Bind" Key
bindKey := "Space"
isDoublePressWanted := false

;--- "Bind-To" Key to output when "Bind" key is single pressed.
bindToKey := "LButton"

;;; Init vars
isScriptRunning := true

;;; Key Binding
Hotkey, %toggleKey%, togglePress
Hotkey, %bindKey%, bindPress
Hotkey, %bindKey% up, bindPressUP
return

togglePress:
    isScriptRunning := % isScriptRunning ? false : true
    SoundBeep, % 500 + (isScriptRunning * 300), 100

    if isToggleKeySendInput {
        Send, % "{" . toggleKey . "}"
    }
    
    return

bindPress:
    if isScriptRunning {
        Hotkey, %bindKey%, Off

        if LastDownTime
            ElapsedTime := A_TickCount - LastDownTime

        Send, {%bindToKey% down}

        if isDoublePressWanted && ElapsedTime && (ElapsedTime <= 250) {
            ;ToolTip, % "Elapsed Time = " ElapsedTime
            Send, {%bindKey%}
        }

        LastDownTime := A_TickCount
    } else {
        Send, {%bindKey% down}
    }
    
    return

bindPressUP:
    if isScriptRunning {
        Hotkey, %bindKey%, On
        Send, {%bindToKey% up}
    } else {
        Send, {%bindKey% up}
    }

    return