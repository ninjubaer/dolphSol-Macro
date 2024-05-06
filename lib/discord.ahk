/************************************************************************
 * @description Discord Bot Library for AutoHotkey
 * @file Discord.ahk
 * @author ninju | .ninju.
 * @date 2024/05/05
 * @version 0.0.1
 * @credits xSPx for CreateFormData
 ***********************************************************************/

Class Discord {
	static apiBase := "https://discord.com/api/v10"

	static getMessage(channel) {
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
	static getChannelList(guildID) {
		static channels := ""
		if (channels)
			return channels
		whr := ComObject("WinHttp.WinHttpRequest.5.1")
		whr.Option[9] := 0x800
		whr.Open("GET", this.apiBase "/guilds/" guildID "/channels", 1)
		whr.SetRequestHeader("User-Agent", "AHK DiscordBot Ferox/Ninju")
		whr.SetRequestHeader("Authorization", "Bot " bottoken)
		whr.Send()
		whr.WaitForResponse()
		return channels := JSON.parse(whr.ResponseText)
	}
	static SendEmbed(channel, embeds, conentType := "application/json") {
		whr := ComObject("WinHttp.WinHttpRequest.5.1")
		whr.Option[9] := 0x800
		whr.Open("POST", this.apiBase "/channels/" channel "/messages", 1)
		whr.SetRequestHeader("User-Agent", "AHK DiscordBot Ferox/Ninju")
		whr.SetRequestHeader("Authorization", "Bot " bottoken)
		whr.SetRequestHeader("Content-Type", conentType)
		whr.SetTimeouts(0, 60000, 120000, 30000)
		whr.Send(embeds)
		whr.WaitForResponse()
		return whr.ResponseText
	}
	static CreateFormData(&payload, &contentType, fields) {
		static chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		Boundary := "----------W-NINJU-FEROX-BOUNDARY-" SubStr(Sort(chars, "Random"), 1, 12)
		hGlobal := DllCall("GlobalAlloc", "uint", 0x42, "ptr", 0, "ptr")
		DllCall("ole32\CreateStreamOnHGlobal", "uptr", hGlobal, "int", 1, "ptr*", &pStream:=0)
		fileIndex := 0
		for field in fields {
			if field is array
				type := field[2], field := field[1]
			else type:=field ~= "m)\{.*\}" ? "application/json" : getContentType(field, &isBitmap)
			str :=
			(
			'
			' Boundary '
			Content-Disposition: form-data; name="' (type="application/json" ? "payload_json" : "files[" fileIndex++ "]") '"' (!IsSet(isBitmap) ? "" : '; filename="' (isBitmap ? "image.png" : SubStr(field, InStr(field, "\",,-1)+1)) '"') '
			Content-type: ' type '
			
			'
			)
			. (type = "application/json" ? 
				payload "`r`n" : "")
			toUtf8(str)
			if FileExist(field) {
				DllCall("shlwapi\SHCreateStreamOnFileEx", "WStr", field, "Int", 0, "UInt", 0x80, "Int", 0, "Ptr", 0, "PtrP", &pFStream:=0)
				DllCall("shlwapi\IStream_Size", "Ptr", pFStream, "UInt64P", &size:=0, "UInt")
				DllCall("shlwapi\IStream_Copy", "Ptr", pFStream, "Ptr", pStream, "UInt", size, "UInt")
				ObjRelease(pFStream)
			}
			else try {
				pFStream := Gdip_SaveBitmapToStream(field)
				DllCall("shlwapi\IStream_Size", "Ptr", pFStream, "UInt64P", &size:=0, "UInt")
				DllCall("shlwapi\IStream_Reset", "Ptr", pFStream, "UInt")
				DllCall("shlwapi\IStream_Copy", "Ptr", pFStream, "Ptr", pStream, "UInt", size, "UInt")
				ObjRelease(pFStream)
			}
		}
		toUtf8("`r`n`r`n" Boundary "--`r`n")
		pGlobal := DllCall("GlobalLock", "uptr", hGlobal)
		size := DllCall("GlobalSize", "ptr", pGlobal, "uint")

		payload := ComObjArray(0x11, size)
		pvData := NumGet(ComObjValue(payload), 8 + A_PtrSize, "ptr")
		DllCall("RtlMoveMemory", "ptr", pvData, "ptr", pGlobal, "uint", size)

		DllCall("GlobalUnlock", "uptr", hGlobal)
		DllCall("GlobalFree", "uptr", hGlobal)

		contentType := "multipart/form-data; boundary=" SubStr(Boundary,3)

		getContentType(file, &isBitmap := false) {
			if !FileExist(file) && isBitmap := true
				return "image/png"
			SplitPath(file,,,&ext), ext := StrLower(ext)
			return "image/" ext
		}
		toUtf8(str) =>
			(utf8 := Buffer(StrPut(str, "UTF-8")-1), StrPut(str, utf8, "UTF-8")
			DllCall("shlwapi\IStream_Write", "ptr", pStream, "ptr", utf8.ptr, "uint", utf8.Size))
	}
}


#Include *i ../../natromacrodev/lib/Json.ahk
#include *i ../lib/Gdip_All.ahk
pToken := Gdip_Startup()

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
	 * @param {string} title -
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
	Send(channel, files?, id?) {
		payLoad := '{"embeds":' JSON.stringify([this.embedObj])
		. (isSet(id) ? ', "allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' id '", "fail_if_not_exists": false}}' : "}")
		if !IsSet(files)
			return Discord.SendEmbed(channel, payLoad)
		formData := [payLoad]
		for i in files
			if i is AttachmentBuilder
				formData.Push(i.file)
		Discord.CreateFormData(&payLoad, &contentType, formData)
		return Discord.SendEmbed(channel, payLoad, contentType)
	}
}
Class AttachmentBuilder extends EmbedBuilder {
	/**
	 * new AttachmentBuilder()
	 * @param File relative path to file
	 */
	__New(param) {
		this.fileName := "image.png", this.file := param
		loop files param
			this.file := A_LoopFileFullPath, this.fileName := A_LoopFileName
		this.attachmentName := "attachment://" this.fileName
	}
}