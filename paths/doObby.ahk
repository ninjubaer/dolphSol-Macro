#singleinstance, force
#noenv
RegExMatch(A_ScriptDir, ".*(?=\\paths)", mainDir)
CoordMode Pixel, Screen
CoordMode Mouse, Screen
#Include ..\lib\pathReference.ahk

; revision by sanji (sir.moxxi) and Flash (drflash55)

if (options.ArcanePath){
    if (options.VIP){

        Send "{d Down}" ;reposition
        walkSleep(50)
        Send "{d Up}"
        send "{w down}"
        walkSleep(100)
        jump()
        walkSleep(400)
        send "{a down}" ;move left earlier
        walkSleep(150)
        jump()
        walkSleep(200)
        send "{w up}" ;only move left in the air, prevents the first near miss
        walkSleep(200)
        send "{w down}"
        walkSleep(260)
        Send "{a Up}"
        walkSleep(100)
        jump()
        walkSleep(100)
        Send "{a Down}" ;move further left in the air
        walkSleep(330)
        Send "{a Up}"
        walkSleep(180)
        jump()
        walkSleep(100)
        Send "{a Down}" ;move further left in the air again, prevents the second near miss
        walkSleep(550)
        jump()
        walkSleep(230)
        Send "{w Up}"
        walkSleep(410)
        jump()
        walkSleep(550)
        jump()
        walkSleep(150)
        Send "{a Up}"
        sleep 100
        Send "{a Down}" ;start of arcane jump
        Send "{w Down}"
        walkSleep(1200)
        Send "{w Up}" ;positioning
        walkSleep(300)
        Send "{w Down}"
        walkSleep(50)
        jump()
        walkSleep(800)
        Send "{a Up}"
        Send "{w Up}"
        sleep 100
        Send "{a Down}" ;move against tree wall
        walkSleep(730)
        Send "{a Up}"
        Send "{w Down}"
        walkSleep(1000)
        Send "{w Up}"
        Send {a, d Down}
        Send {Left Down}
        sleep 250 ;adjusted cam turn
        Send {Left up}
        Send {a, d up}
        sleep 200
        Send "{a Down}"
        Send "{w Down}"
        walkSleep(325) ;adjusted timing for jump
        jump()
        arcaneTeleport()
        walkSleep(300)
        Send "{a Up}"
        Send "{w Up}"
        sleep 100
        Send "{w Down}"
        walkSleep(1500) ;move further forwards in case arcane teleport fell slightly short
        Send "{w Up}"
        Send "{a Down}"
        walkSleep(300)
        Send "{a Up}"
        Send "{s Down}"
        walkSleep(500) ;move back when macro moved to the left in case on the right side
        Send "{s Up}"
        Send "{d Down}"
        walkSleep(1000) ;try to head back to the blessing if missed on the left side
        Send "{d Up}"
    } else {
        Send "{w Down}"
        walkSleep(100)
        jump()
        walkSleep(550)
        Send "{a Down}"
        walkSleep(150)
        jump()
        walkSleep(650)
        jump()
        walkSleep(500)
        Send "{a Up}"
        walkSleep(100)
        jump()
        Send "{a Down}"
        walkSleep(200)
        Send "{a Up}"
        walkSleep(400)
        Send "{a Down}"
        Send "{w Down}"
        walkSleep(50)
        jump()
        walkSleep(300)
        Send "{w Up}"
        walkSleep(350)
        jump()
        walkSleep(700)
        jump()
        walkSleep(100)
        Send "{a Up}"
        sleep 100
        Send "{a Down}"
        Send "{w Down}"
        walkSleep(1250)
        jump()
        walkSleep(500)
        Send "{a Up}"
        Send "{w Up}"
        sleep 100
        Send "{a Down}"
        walkSleep(1100)
        Send "{a Up}"
        Send "{w Down}"
        walkSleep(700)
        Send "{w Up}"
        Send {a, d Down}
        Send {Left Down}
        walkSleep(200)
        Send {Left up}
        Send {a, d up}
        sleep 200
        Send "{a Down}"
        Send "{w Down}"
        walkSleep(300)
        jump()
        press("x",150)
        walkSleep(300)
        Send "{a Up}"
        Send "{w Up}"
        sleep 100
        Send "{w Down}"
        walkSleep(800)
        Send "{w Up}"
        Send "{a Down}"
        walkSleep(500)
        Send "{a Up}"
        Send "{d Down}"
        walkSleep(2000) 
        Send "{d Up}"
    }
} else {
    if (options.VIP) ;newest changes done here
    { 
        Send "{d Down}" ;reposition
        walkSleep(50)
        Send "{d Up}"
        Send "{w Down}"
        walkSleep(100)
        jump()
        walkSleep(400)
        Send "{a Down}" ;move left earlier
        walkSleep(150)
        jump()
        walkSleep(200)
        Send "{w Up}" ;only move left in the air, prevents the first near miss
        walkSleep(200)
        Send "{w Down}"
        walkSleep(260)
        Send "{a Up}"
        walkSleep(100)
        jump()
        walkSleep(100)
        Send "{a Down}" ;move further left in the air
        walkSleep(330)
        Send "{a Up}"
        walkSleep(180)
        jump()
        walkSleep(100)
        Send "{a Down}" ;move further left in the air again, prevents the second near miss
        walkSleep(550)
        jump()
        walkSleep(230)
        Send "{w Up}"
        walkSleep(410)
        jump()
        walkSleep(550)
        jump()
        walkSleep(1400)
        Send "{s Down}" ;real obby
        jump()
        walkSleep(350)
        Send "{s Up}"
        walkSleep(200)
        Send "{s Down}"
        walkSleep(60)
        jump()
        walkSleep(180)
        Send "{s Up}"
        walkSleep(500)
        Send "{s Down}"
        jump()
        walkSleep(150)
        Send "{s Up}"
        walkSleep(500)
        jump()
        walkSleep(40)
        Send "{w Down}"
        walkSleep(680)
        jump()
        walkSleep(430)
        Send "{a Up}"
        walkSleep(360)
        jump()
        walkSleep(640)
        jump()
        walkSleep(640)
        jump()
        walksleep(400)
        Send "{d Down}" ; finish
        walkSleep(600)
        Send "{d Up}"
        Send "{w Up}"
    } else {
        Send "{w Down}"
        walkSleep(100)
        jump()
        walkSleep(550)
        Send "{a Down}"
        walkSleep(150)
        jump()
        walkSleep(650)
        jump()
        walkSleep(500)
        Send "{a Up}"
        walkSleep(100)
        jump()
        Send "{a Down}"
        walkSleep(200)
        Send "{a Up}"
        walkSleep(400)
        Send "{a Down}"
        Send "{w Down}"
        walkSleep(50)
        jump()
        walkSleep(300)
        Send "{w Up}"
        walkSleep(350)
        jump()
        walkSleep(700)
        jump()
        walkSleep(1300)
        Send "{s Down}" ;real obby
        jump()
        walkSleep(500)
        Send "{s Up}"
        walkSleep(200)
        Send "{s Down}"
        jump()
        walkSleep(300)
        Send "{s Up}"
        walkSleep(450)
        jump()
        Send "{s Down}"
        walkSleep(200)
        Send "{s Up}"
        walkSleep(450)
        Send "{w Down}"
        jump()
        walkSleep(700)
        jump()
        walkSleep(550)
        Send "{a Up}"
        walkSleep(100)
        jump()
        walkSleep(700)
        jump()
        walkSleep(700)
        jump()
        walkSleep(600)
        Send "{d Down}" ; finish
        walkSleep(450)
        Send "{w Up}"
        walkSleep(200)
        Send "{d Up}"
    }
}