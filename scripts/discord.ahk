#SingleInstance Force
#MaxThreads 255
#Warn All, StdOut

/* if A_Args.Length = 0 {
    MsgBox
    (
    'Script needs to be run directly from Main!
    Please run Main.ahk instead of this script'
    ),,0x1010
    ExitApp()
} */
SetWorkingDir A_ScriptDir '\..\'
BotToken := IniRead(".\settings\config.ini", "Options", "BotToken")
commandPrefix := "?"
ChannelID := "1207367046313283596"

#Include CommandHandler.ahk
#Include %A_ScriptDir%\..\lib
#Include Gdip_All.ahk
#Include discord.ahk

pToken := Gdip_Startup()

loop {
    if (cmd := Discord.getMessages(1207367046313283596)) is Object and cmd["content"] && SubStr(cmd["content"], 1,1) == commandPrefix
        commandHandler(cmd)
}

ObjHasValue(obj,value) {
    for k, v in obj
        if v = value
            return k
    return false
}