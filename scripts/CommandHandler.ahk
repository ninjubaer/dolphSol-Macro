commands := []
loop files '.\commands\*.ahk', "R" {
    if A_LoopFileName != "__includes.ahk" {
        includes .= "#include " . A_LoopFileFullPath . "`r`n"
        try FileAppend("Imported " A_LoopFileName "`n", "*")
    }
}
(f:=FileOpen(".\commands\__includes.ahk", "w")).Write(includes)
f.Close()
#Include .\..\commands\__includes.ahk

fetchCommand(command) {
    for cmd in commands {
        if cmd.command == command ||ObjHasValue(cmd.alias, command) {
            return cmd
        }
    }
    return false

}
commandHandler(command) {
    (params := StrSplit(SubStr(command["content"],StrLen(commandPrefix)+1), " ")).length ? "" : params := [""]
    ID := command["id"], (cmd := fetchCommand(params[1])) ? (cmd.function).Call(command, params) :""
}


loop
    if (cmd := Discord.getMessages(1207367046313283596)) is Object and cmd["content"] && SubStr(cmd["content"], 1,1) == commandPrefix
        commandHandler(cmd)