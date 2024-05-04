#singleinstance, force
#noenv
RegExMatch(A_ScriptDir, ".*(?=\\paths)", mainDir)
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
#Include ..\lib\pathReference.ahk

; revision by sanji (sir.moxxi) and Flash (drflash55)

if (options.ArcanePath){
    Send "{d Down}"
    walkSleep(2600)
    Send "{s Down}"
    Send "{d Up}"
    walkSleep(700)
    Send "{s Up}"
    Send "{d Down}"
    walkSleep(750)
    Send "{d Up}"
    collect(1)

    Send "{a Down}"
    walksleep(300)
    Send "{a Up}"
    Send "{w Down}"
    walkSleep(500)
    arcaneTeleport()
    walkSleep(2400)
    Send "{d Down}"
    walkSleep(400)
    Send "{d Up}"
    Send "{w Up}"
    collect(2)

    ; void hop
    Send "{d Down}"
    walkSleep(500)
    Send "{d Up}"
    sleep 4000 ; from 1750 since there is a semi risk of getting anti cheated for a few seconds

    Send "{w Down}"
    walkSleep(300)
    jump()
    walkSleep(350)
    Send "{a Down}"
    walkSleep(250)
    jump()
    walkSleep(350)
    Send "{w Up}"
    walkSleep(250)
    jump()
    walkSleep(350)
    Send "{a Up}"
    Send "{w Down}"
    walkSleep(225)
    jump()
    walkSleep(315)
    Send "{d Down}"
    walkSleep(750)
    Send "{w Up}"
    Send "{d Up}"
    collect(3)

    Send "{a Down}"
    walkSleep(600)
    Send "{w Down}"
    walkSleep(50)
    jump()
    walkSleep(800)
    jump()
    walkSleep(400)
    Send "{a Up}"
    Send "{w Up}"
    press("d",200)
    Send "{w Down}"
    walksleep(300)
    Send "{w Up}"
    Send "{d Down}"
    walkSleep(500)
    Send "{w Down}"
    walkSleep(500)
    Send "{w Up}"
    Send "{d Up}"
    Send "{Right Down}"
    sleep 650
    Send "{Right Up}"
    collect(4)

    alignCamera()
    Send "{a Down}"
    walksleep(850)
    Send "{a Up}"
    Send "{s Down}"
    walkSleep(1000)
    arcaneTeleport()
    walkSleep(2100)
    Send "{a Down}"
    walkSleep(1550)
    Send "{a Up}"
    walkSleep(600)
    Send "{s Up}"
    collect(5)

    Send "{a Down}"
    jump()
    walkSleep(300)
    Send "{a Up}"
    Send "{s Down}"
    walkSleep(1000)
    jump()
    realT := getWalkTime(150)
    sleep 150
    arcaneTeleport()
    sleep realT-150
    walkSleep(2000)
    Send "{s Up}"
    press("d",250)
    Send "{Left Down}"
    sleep 1000
    Send "{Left Up}"
    collect(6)

    alignCamera()
    Send "{s Down}"
    walkSleep(2500)
    press("d",500)
    Send "{s Up}"
    Send "{d Down}"
    walkSleep(100)
    jump()
    walkSleep(800)
    Send "{s Down}"
    walkSleep(400)
    jump()
    walkSleep(200)
    Send "{s Up}"
    Send "{d Down}"
    walkSleep(200)
    jump()
    walkSleep(800)
    jump()
    walkSleep(600)
    jump()
    walkSleep(800)
    jump()
    walkSleep(200)
    Send "{d Up}"
    Send "{w Down}"
    walksleep(100)
    Send "{w Up}"
    sleep 100
    collect(7)
}else{
    Send "{d Down}"
    walkSleep(2600)
    Send "{s Down}"
    Send "{d Up}"
    walkSleep(700)
    Send "{s Up}"
    Send "{d Down}"
    walkSleep(750)
    Send "{d Up}"
    collect(1)

    Send "{a Down}"
    walksleep(300)
    Send "{a Up}"
    Send "{w Down}"
    walkSleep(3800)
    Send "{d Down}"
    walkSleep(400)
    Send "{d Up}"
    Send "{w Up}"
    collect(2)

    ; void hop
    Send "{d Down}"
    walkSleep(400)
    Send "{d Up}"
    sleep 4000 ; from 1750 since there is a semi risk of getting anti cheated for a few seconds

    Send "{w Down}"
    walkSleep(300)
    jump()
    walkSleep(350)
    Send "{a Down}"
    walkSleep(250)
    jump()
    walkSleep(350)
    Send "{w Up}"
    walkSleep(250)
    jump()
    walkSleep(350)
    Send "{a Up}"
    Send "{w Down}"
    walkSleep(100)
    jump()
    walkSleep(350)
    Send "{d Down}"
    walkSleep(750)
    Send "{w Up}"
    Send "{d Up}"
    collect(3)

    Send "{a Down}"
    walkSleep(600)
    Send "{w Down}"
    walkSleep(100)
    jump()
    walkSleep(800)
    jump()
    walkSleep(400)
    Send "{a Up}"
    Send "{w Up}"
    press("d",200)
    Send "{w Down}"
    walksleep(300)
    Send "{w Up}"
    Send "{d Down}"
    walkSleep(500)
    Send "{w Down}"
    walkSleep(500)
    Send "{w Up}"
    Send "{d Up}"
    Send "{Right Down}"
    sleep 650
    Send "{Right Up}"
    collect(4)

    alignCamera()
    Send "{a Down}"
    walksleep(850)
    Send "{a Up}"
    Send "{s Down}"
    walkSleep(4000)
    Send "{a Down}"
    walkSleep(1550)
    Send "{a Up}"
    walkSleep(600)
    Send "{s Up}"
    collect(5)

    Send "{a Down}"
    jump()
    walkSleep(300)
    Send "{a Up}"
    press("s",4000)
    press("d",250)
    Send "{Left Down}"
    sleep 1000
    Send "{Left Up}"
    collect(6)

    alignCamera()
    Send "{s Down}"
    walkSleep(2500)
    press("d",500)
    Send "{s Up}"
    Send "{d Down}"
    walkSleep(100)
    jump()
    walkSleep(800)
    Send "{s Down}"
    walkSleep(400)
    jump()
    walkSleep(200)
    Send "{s Up}"
    Send "{d Down}"
    walkSleep(200)
    jump()
    walkSleep(800)
    jump()
    walkSleep(600)
    jump()
    walkSleep(800)
    jump()
    walkSleep(200)
    Send "{d Up}"
    Send "{w Down}"
    walksleep(100)
    Send "{w Up}"
    sleep 100
    collect(7)
}