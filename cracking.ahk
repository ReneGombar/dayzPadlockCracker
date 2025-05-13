; LAUNCH with Ctrl+m
;dayz padlock cracker
;It takes 3h20m to go through all 9999 numbers
;it can start from any initial combination

#Requires AutoHotkey v2.0

isRunning := false
paused :=false
startingCombination := 0000
lockSize := 4
thousandthDigitStartingNumber := 0, 
hundredthDigitStartingNumber := 0
tenthDigitStartingNumber:=0
onesDigitStartingNumber:=0
currentCombo := 0
digits := []
initialRun:= FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")

dialingTimer:= 630
keyDelayTimer := 350 ; delay between key presses
pressReleaseTimer:= 45   ; time of press down for a key

filePath := "log.txt"

writeLog(){ ;check and creates a log.txt with info on the session
    global initialRun,startingCombination, currentCombo
    if FileExist(filePath) {
        f := FileOpen(filePath, "a")  ; Append if exists
    } else {
        f := FileOpen(filePath, "w")  ; Create new file
    }
    
    if f {
        lockSize=4 ? endCombo := SubStr(Format("{:04}", currentCombo), -4) : endCombo := SubStr(Format("{:03}", currentCombo), -3)
        lockSize=4 ? startingCombination := SubStr(Format("{:04}", startingCombination), -4) : startingCombination:= SubStr(Format("{:03}", startingCombination), -3)
        f.WriteLine( initialRun " | Initial Combination: " startingCombination " | End Combination: " endCombo " | Script Ended: " FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"))
        f.Close()
    } else {
        MsgBox "Failed to open file."
    }
}

createHelpGui(){   ;creates the toggable help window
    global helpGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000", "Transparent GUI")
    global helpGuiIsVisible := false
    helpGui.BackColor := "3b3b3b"
    helpGui.SetFont(, "Verdana")
    ;WinSetTransColor("Green", helpGui.Hwnd)
    MouseGetPos &xPos, &yPos ; Get mouse position
    helpGui.Add("Text", "ca4ffa5 BackgroundTrans w500", "Dialing Delay (default " dialingTimer ") `n`tIncrease Ctrl+n / Decrease Ctrl+Shift+n")
    helpGui.Add("Text", "ca4ffa5 BackgroundTrans w500", "Delay between key presses for cursor movement (default " keyDelayTimer "). `n`tIncrease Ctrl+k / Decrease Ctrl+Shift+k")
    helpGui.Add("Text", "ca4ffa5 BackgroundTrans w500", "Pressdown of 'f' key for cursor movement (default " pressReleaseTimer "). `n`tIncrease Ctrl+j / Decrease Ctrl+Shift+j")
    helpGui.Show("x" (xPos+100) "y" (yPos + 350) "NoActivate")
    helpGui.Hide()
}


^m:: ;initiate the script
{   
    global isRunning, paused
    global startingCombination, thousandthDigitStartingNumber, hundredthDigitStartingNumber, tenthDigitStartingNumber, onesDigitStartingNumber
    tenthDigitCounter:= 10
    hundredthDigitCounter:= 10
    thousandthDigitCounter:= 9
    
    readLockSize(){     ; read lock size and trigger startig combo
        global lockSize
        Selected := 0
        MyGui := Gui( , "Lock Size")
        MyGui.OnEvent("Close", (*) => ExitApp())
        MyGui.SetFont("s10")
        MyGui.Add("Text",, "Select the size of the lock")

        ; Radios
        Radio1 := MyGui.AddRadio(,"3 Digit Lock")
        Radio1.SS := 3   ; add a property SS to the Radio button object
        Radio1.OnEvent("Click", RadioEvent)          ; activate a function to handle 'Click' events

        Radio2 := MyGui.AddRadio(, "4 Digit Lock")
        Radio2.SS := 4
        Radio2.OnEvent("Click", RadioEvent)

        ; The Button is disabled until a Radio was clicked
        ButtonEnter := MyGui.Add("Button", "Disabled", "Enter")
        ButtonEnter.OnEvent("Click", ButtonEvent)
        MyGui.Show()

        RadioEvent(RB, *) { ; the first parameter is the clicked Radio button object
            Global Selected
            Selected := RB
            ButtonEnter.Enabled := True ; enable ButtonEnter 
        }

        ButtonEvent(*) {
            Global Selected
            ;MsgBox "Radio Choice: " Selected.SS
            lockSize := Selected.SS
            MyGui.Destroy()
            readStartingCombination
        }
    }   

    readStartingCombination(){  ; Reads the initial combination of the lock, triggered within readLockSize
        global startingCombination
        global lockSize, currentCombo
        min:=0
        max:=9999
        if lockSize = 3 
            max:=999 
        loop {
            result := InputBox("Enter starting combination on the lock (" min "-" max "). Must reflect the combination on the lock in the game!", "Ingame lock combination")
            if result.Result != "OK" {
                ToolTip("Input Canceled")
		        SetTimer(() => ToolTip(), -3000)
                return
            } 
            if RegExMatch(result.Value, "^-?\d+$") && StrLen(result.Value) = lockSize{
                value := Integer(result.Value)
                if value >= min && value <= max {
                    startingCombination := value
                    ;ToolTip("Valid number: " value)
                    ;SetTimer(() => ToolTip(), -3000)
                    MsgBox ("Make sure the digit selector in the game is on the far right digit!`n`tExample for 4 digit lock: 1 2 3 [4]  `n`tExample for 3 digit lock:1 2 [3]")
                    ;ToolTip ("Script Starting")
                    sleep 500
                    currentCombo:=startingCombination
                    displayGui
                    createHelpGui
                    lockSize = 4 ? thousands(thousandthDigitCounter) : hundreds()  ; begin dialing
                    break
                }
            }
            MsgBox("Try Again (" min "-" max ")")
        }
    }

    splitCombo(combination){    ; separates the digits of the initial combo into an array
        global thousandthDigitStartingNumber, hundredthDigitStartingNumber, tenthDigitStartingNumber, onesDigitStartingNumber, digits
        digits := StrSplit(Format("{:0" lockSize "}",combination)) ; split the number into an array
        onesDigitStartingNumber:= digits[digits.Length]
        tenthDigitStartingNumber:=digits[digits.Length-1]
        hundredthDigitStartingNumber:=digits[digits.Length-2]
        if lockSize = 4 
            thousandthDigitStartingNumber:=digits[digits.Length-3]
        return digits
    }

    moveDigits(spots)
    {
        global lockSize, keyDelayTimer, pressReleaseTimer

        SetKeyDelay keyDelayTimer, pressReleaseTimer     ; sets the the timers for pressing and releasing the "f" key to move digits
        firstMove:= ""
        secondMove:= ""
        ;lockSize = 4 ? spots:= spots : spots:= spots-1
        ; for three digits change this to spots-1   ;!Need to change this for 3 digits
        loop spots 
            {
                firstMove:= firstMove . "f"
            }
        loop (lockSize-spots) 
            {
                secondMove:= secondMove . "f"
            }
        SendEvent firstMove ;moves positions
        Sleep 500
        Send "{f down}"
        Sleep 1400   ;spins a single digit
        Send "{f Up}"
        Sleep 1000
        SendEvent secondMove ; moves back to ones
    }
    
    ones(){ ; holds down f key to run through 10 digits of the far right digit 
        global currentCombo, dialingTimer
        Sleep 100
        Send "{f down}"
        loop 10{    ; loops through ten digits of the ones
            Sleep dialingTimer
            currentCombo:=currentCombo+1
            lastDigit := SubStr(currentCombo, -1)
            ;info := lockSize =4 ? SubStr(Format("{:04}", currentCombo), -4) : SubStr(Format("{:03}", currentCombo), -3)
            ;info := "Current Combo: " info "`nCursor Speed:  " Format("{:03}", keyDelayTimer) "," Format("{:03}", pressReleaseTimer) "`nDialing Speed: " dialingTimer
            lastDigit == 0 ? currentCombo:= currentCombo-10 : 0
            ;ToolTip (currentCombo)
        }
        Send "{f Up}"
        Sleep 1000
    }
    
    tens(){ ; increases the tenths digit after the ones run through all 10
        global currentCombo, lockSize ; array digits[digits.Length-1] is the the tenth digit
        loop tenthDigitCounter{
            ones()
            lockSize = 4 ? moveDigits(3) : moveDigits(2)
            currentCombo:= currentCombo + 10
            arr := splitCombo(currentCombo)
            if arr[arr.Length-1] = 0 
                break
        }
        tenthDigitCounter:=10
    }
    
    hundreds(){ ; increases the hundredth digit after the tens run ten times
        global currentCombo, lockSize ; array digits[digits.Length-2] is the the hundreds digit
        loop hundredthDigitCounter {
            tens()
            lockSize = 4 ? moveDigits(2) : moveDigits(1)
            arr := splitCombo(currentCombo)
            if arr[arr.Length-2] =0 && lockSize == 4  
                break
        }
        hundredthDigitCounter:=10
    }

    thousands(loops){  ; is called for 4 digit lock, and runs 9 times. 
        loop loops {
            hundreds()
            moveDigits(1)
        }
    }

    displayGui(){   ;display the gui showing the current combination and other info. Fully dynamic
        global myGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000", "Transparent GUI")
        myGui.BackColor := "Green"
        MyGui.SetFont(, "Verdana")
        WinSetTransColor("Green", myGui.Hwnd)
        MouseGetPos &xPos, &yPos ; Get mouse position
        line1 := myGui.Add("Text", "cWhite BackgroundTrans w200", "")
        line2 := myGui.Add("Text", "cWhite BackgroundTrans w200", "")
        line3 := myGui.Add("Text", "cWhite BackgroundTrans w200", "")
        myGui.Add("Text", "ca4ffa5 BackgroundTrans w200", "Press Ctrl+h to show/hide Help.")
        
        updateGui(){
            global lockSize, currentCombo, keyDelayTimer, pressReleaseTimer, dialingTimer, myGui
            comboInfo:= lockSize =4 ? SubStr(Format("{:04}", currentCombo), -4) : SubStr(Format("{:03}", currentCombo), -3)
            line1.Value:= "Current Combo: " comboInfo
            line2.Value:= "Dialing Speed: " dialingTimer
            line3.Value:= "Cursor Speed:  " Format("{:03}", keyDelayTimer) ", " Format("{:03}", pressReleaseTimer)
        }
        
        myGui.Show("x" (xPos+100) "y" (yPos + 200) " NoActivate")
        SetTimer(updateGui, 100)
    }
    

    ;BEGIN ************************
    readLockSize    ; begin the script
}

; Shortcuts for changing settings 
^n::{   ; increase dialing Timer
    global dialingTimer
    dialingTimer := dialingTimer + 10
}

^+n::{   ;decrease delay timer
    global dialingTimer
    dialingTimer := dialingTimer - 10
}

^k::{   ; increase keyDelayTimer
    global keyDelayTimer
    keyDelayTimer := keyDelayTimer + 10
}

^+k::{   ; decrease keyDelayTimer
    global keyDelayTimer
    keyDelayTimer := keyDelayTimer - 10
}

^j::{   ; press down of a key for cursor movement
    global pressReleaseTimer
    pressReleaseTimer := pressReleaseTimer + 10
}

^+j::{   ; press down of a key for cursor movement
    global pressReleaseTimer
    pressReleaseTimer :=  pressReleaseTimer - 10
}

^h::{   ; toggle help menu
    global helpGui, helpGuiIsVisible
    if helpGuiIsVisible
        {
            helpGui.Hide()
            helpGuiIsVisible := false
        }
    else
        {
            helpGui.Show("NoActivate")
            helpGuiIsVisible := true
        }
}

Esc::
{
    Send "{f Up}"
    writeLog
    ExitApp
}