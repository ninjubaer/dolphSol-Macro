#SingleInstance Force

/* if !A_Args.Length
    msgbox("This script is not meant to be run directly. Please run the main script instead.",,0x40010)
    ,ExitApp(-1)
*/
Class Discord {
    static apiBase := "https://discord.com/api/v10"
    
    static getMessages(channel) {
        static lastMessages := Map()
        args := lastMessages.Has(channel) ? "?after=" lastMessages[channel] : "?limit=1"

        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Option[9] := 0x800
        whr.Open("GET", this.apiBase "/channels/" channel "/messages" args, 1)
        whr.SetRequestHeader("User-Agent", "AHK DiscordBot Ferox/Ninju")
        whr.SetRequestHeader("Authorization", "Bot " bottoken)
        whr.Send()
        whr.WaitForResponse()
        messages := JSON.parse(whr.ResponseText)
        if messages.Has(1)
            lastMessages[channel] := messages[messages.Length]["id"]
        return messages.Has(1) ? messages[messages.Length] : false
    }
    ;* FORM DATA HERE!!!
    static FormData(&payLoad, &contentType, files) {
        
    }
    static SendEmbed(channel, embeds, conentType := "application/json") {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Option[9] := 0x800
        whr.Open("POST", this.apiBase "/channels/" channel "/messages", 1)
        whr.SetRequestHeader("User-Agent", "AHK DiscordBot Ferox/Ninju")
        whr.SetRequestHeader("Authorization", "Bot " bottoken)
        whr.SetRequestHeader("Content-Type", conentType)
        whr.Send(embeds)
        whr.WaitForResponse()
        return whr.ResponseText
    }
}


#Include *i ../../natromacrodev/lib/Json.ahk


/************************************************************************
 * @description create embeds in a discordjs style
 * @file DiscordBuilder.ahk
 * @author ninju | .ninju.
 * @date 2024/03/20
 * @version 0.0.0
***********************************************************************/

Class EmbedBuilder extends Discord {
    __New() {
        this.embedObj := {}
    }
    /**
     * @method setTitle()
     * @param {string} title 
    */
   setTitle(title) {
       if !(title is String)
            throw Error("expected a string", , title)
       this.embedObj.title := title
        return this
    }
    /**
     * @method setDescription()
     * @param {string} description 
     */
    setDescription(description) {
        if !(description is String)
            throw Error("expected a string", , description)
        this.embedObj.description := description
        return this
    }
    /**
     * @method setURL()
     * @param {URL} URL 
    */
   setURL(URL) {
        if !(URL is String)
            throw Error("expected a string", , URL)
        if !(RegExMatch(URL, ":\/\/"))
            throw Error("expected an URL", , URL)
        this.embedObj.url := URL
        return this
    }
    /**
     * @method setColor()
     * @param {Hex | Decimal Integer} Color 
     */
    setColor(Color) {
        if !(Color is Integer)
            throw Error("expected an integer", , Color)
        this.embedObj.color := Color + 0
        return this
    }
    /**
     * @method setTimestamp()
     * @param {timestamp} timestamp "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}"
     * @default this.now()
    */
   setTimeStamp(timestamp := "") {
       if IsSet(timestamp)
            if !RegExMatch(timestamp, "i)\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}")
                throw Error("invalid timestamp", , timestamp)
       time := A_NowUTC
       this.embedObj.timestamp := timestamp || SubStr(time, 1, 4) "-" SubStr(time, 5, 2) "-" SubStr(time, 7, 2) "T" SubStr(time, 9, 2) ":" SubStr(time, 11, 2) ":" SubStr(time, 13, 2) ".000Z"
        return this
    }
    /**
     * @method setAuthor()
     * @param {object} author
     * @property {string} name
     * @property {url} url
     * @property {url} icon_url
     */
    setAuthor(author) {
        if !(author is object)
            throw Error("Expected an object literal")
        for k, v in author.OwnProps()
            if !ObjHasValue(["name", "icon_url", "url"], k)
                throw Error("Expected one of the following propertires: `"name`", `"icon_url`", `"url`"`nReceived: " k)
        this.embedObj.author := author
        return this
    }
    /**
     * @method addFields()
     * @param {array of objects} fields .addFields([{name:"name",value:"value"}])
     * @property {string} name
     * @property {string} value
     * @property {Boolean} inline
     */
    addFields(fields) {
        if !(fields is Array)
            throw Error("expected an array", , fields)
        for i in fields {
            if !(i is Object)
                throw Error("Expected an object literal")
        for k, v in i.OwnProps()
                if !ObjHasValue(["name", "value", "inline"], k)
                    throw Error("Expected one of the following propertires: `"name`", `"value`", `"inline`"`nReceived: " k)
        }
        if this.embedObj.HasProp("fields")
            this.embedObj.fields.push(fields)
        else this.embedObj.fields := fields
        return this
    }
    /**
     * @method setFooter()
     * @param {object} footer
     * @property {string} text
     * @property {url} icon_url
     */
    setFooter(footer) {
        if !(footer is object)
            throw Error("Expected an object literal")
        for k, v in footer.OwnProps()
            if !ObjHasValue(["text", "icon_url"], k)
                throw Error("Expected one of the following propertires: `"text`", `"icon_url`"`nReceived: " k)
        this.embedObj.footer := footer
        return this
    }
    /**
     * @method setThumbnail()
     * @param {object} thumbnail
     * @property {url} url
    */
    setThumbnail(thumbnail) {
        if !IsObject(thumbnail)
            throw Error("expected an object", , thumbnail)
        if !RegExMatch(thumbnail.url, ":\/\/")
            throw Error("requires an url or attachment.attachmentName (attachment://filename.extension)", , thumbnail.url)
        this.embedObj.thumbnail := thumbnail
        return this
    }
    /**
     * @method setImage()
     * @param {object} image
     * @property {url} url 
     */
    setImage(image) {
        if !IsObject(image)
            throw Error("expected an object", , image)
        if !RegExMatch(image.url, ":\/\/")
            throw Error("requires an url or attachment.attachmentName (attachment://filename.extension)", , image.url)
        this.embedObj.image := image
        return this
    }
    Send(channel, files?) {
        payLoad := '{"embeds":' JSON.stringify([this.embedObj]) '}'
        msgbox payLoad
        Discord.CreateFormData(&payLoad, &contentType, { payload_json: payLoad, files: IsSet(files) ? files : [] })
        Discord.SendEmbed(channel, payLoad, contentType)
    }
}
Class AttachmentBuilder extends EmbedBuilder {
    /**
     * new AttachmentBuilder()
     * @param File relative path to file
    */
   __New(File) {
        if !FileExist(File)
            throw Error("Filename <" File "> doesnt exist", , File)
        loop Files File
            file := A_LoopFileFullPath
        this.fileName := File
        this.attachmentName := "attachment://" SubStr(File, InStr(File, "\", 0, -1) + 1)
    }
}

ObjHasValue(obj, value) {
    for k, v in obj
        if v = value
            return true
    return false
}

BotToken := ""
attachment := AttachmentBuilder(".\..\images\auryn.ico")
Embed := EmbedBuilder()
    .setTitle("Connected to Discord")
    .setImage({url: attachment.attachmentName})
    .Send("1207367046313283596")
loop
    if (msg := Discord.getMessages("1207367046313283596")) && SubStr(msg["content"], 1, 1) = "." {
        cmd := StrSplit(SubStr(msg["content"], 2), " ")
        switch cmd[1], 0
        {
            case "ping":
                Embed := EmbedBuilder()
                    .setTitle("Pong!")
                    .setDescription("Pong! ``" msg["author"]["username"] "``")
                    .Send(msg["channel_id"], [attachment])
        }
    }
