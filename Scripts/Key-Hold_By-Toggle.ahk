#SingleInstance, Force
SendMode Input

toggleKey := "Numpad2"
holdKey   := "RButton"

isToggleActive := 0

Hotkey, %toggleKey%, toggleAction
return

toggleAction:
	%isToggleActive% := !%isToggleActive%
	SoundBeep, % 500 + (%isToggleActive% * 300), 100

	if (%isToggleActive% = 1)
		SendInput, {%holdKey% Down}
	else
		SendInput, {%holdKey% Up}
	return