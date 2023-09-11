;dayz padlock cracker
;It takes 3h20m to go through all 9999 numbers
;it can start from any initial combination
;can be paused wth Pause button and resumed with Pause button

#Requires AutoHotkey v2.0
^j::
{   
    ; stating position when cracking a new lock shoud be 0000
    ; If the lock has been tried to a specific value than change the initial values bellow
    thousandthDigitStartingNumber:= 0
    hundredthDigitStartingNumber:= 0
    tenthDigitStartingNumber:= 0

    tenthDigitCounter:= 10
    hundredthDigitCounter:= 10
    thousandthDigitCounter:= 9

    if (tenthDigitStartingNumber != 0 || hundredthDigitStartingNumber != 0 || thousandthDigitStartingNumber != 0){
        tenthDigitCounter:= 10 - tenthDigitStartingNumber
        hundredthDigitCounter:= 10 - hundredthDigitStartingNumber
        thousandthDigitCounter:= 9 - thousandthDigitStartingNumber
    }
    
    rotateOnesTimer:= 6300 ; this will rotate through all 10 digits

    SetKeyDelay 300, 40
    
    moveDigits(spots){
        firstMove:= ""
        secondMove:= ""

        loop spots 
            {
                firstMove:= firstMove . "f"
            }
        loop (4-spots) 
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

    ones(){
        Send "{f down}"
        Sleep rotateOnesTimer  ;spins throught 10 digits
        Send "{f Up}"
        Sleep 1000
    }

    thousands(1)
    thousands(thousandthDigitCounter)

    tens(){
        loop tenthDigitCounter{
            ones()
            moveDigits(3)
        }
        tenthDigitCounter:=10
    }

    hundreds(){
        loop hundredthDigitCounter {
            tens()
            moveDigits(2)
        }
        hundredthDigitCounter:=10
    }

    thousands(loops){
        loop loops {
            hundreds()
            moveDigits(1)
        }
    }
}
Esc::ExitApp
Pause:: Pause -1