#Requires AutoHotkey v2.0

^j::
{   
    ;SendMode "Event"
    SetKeyDelay 300, 40
    
    moveDigits(spots){
        if spots == 3 {
            firstMove:= "fff"
            secondMove:= "f"
        }
        if spots == 2 {
            firstMove:= "ff"
            secondMove:= "ff"
        }
        if spots == 1 {
            firstMove:= "f"
            secondMove:= "fff"
        }

        SendEvent firstMove ;moves three positions
        Sleep 500
        Send "{f down}"
        Sleep 1400   ;spins a single digit
        Send "{f Up}"
        Sleep 800
        SendEvent secondMove ; moves back to ones
    }

    thousands()

    ones(){
        Send "{f down}"
        Sleep 6200
        Send "{f Up}"
        Sleep 1000
    }
    
    tens(){
        loop 10{
            ones()
            moveDigits(3)
        }
    }

    hundreds(){
        loop 10 {
            tens()
            moveDigits(2)
        }
    }

    thousands(){
        loop 10 {
            hundreds()
            moveDigits(1)
        }
    }
}
Esc::ExitApp
Pause:: Pause -1