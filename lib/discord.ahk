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
	/**
	 * @author xSPx
	 */
	static CreateFormData(&retData, &contentType, fields)
	{
		static chars := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"

		chars := Sort(chars, "D| Random")
		boundary := SubStr(StrReplace(chars, "|"), 1, 12)
		hData := DllCall("GlobalAlloc", "UInt", 0x2, "UPtr", 0, "Ptr")
		DllCall("ole32\CreateStreamOnHGlobal", "Ptr", hData, "Int", 0, "PtrP", &pStream:=0, "UInt")

		for field in fields
		{
			str :=
			(
			'

			------------------------------' boundary '
			Content-Disposition: form-data; name="' field["name"] '"' (field.Has("filename") ? ('; filename="' field["filename"] '"') : "") '
			Content-Type: ' field["content-type"] '

			' (field.Has("content") ? (field["content"] "`r`n") : "")
			)

			utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
			DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")

			if field.Has("pBitmap")
			{
				try
				{
					pFileStream := Gdip_SaveBitmapToStream(field["pBitmap"])
					DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size:=0, "UInt")
					DllCall("shlwapi\IStream_Reset", "Ptr", pFileStream, "UInt")
					DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
					ObjRelease(pFileStream)
				}
			}

			if field.Has("file")
			{
				DllCall("shlwapi\SHCreateStreamOnFileEx", "WStr", field["file"], "Int", 0, "UInt", 0x80, "Int", 0, "Ptr", 0, "PtrP", &pFileStream:=0)
				DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size:=0, "UInt")
				DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
				ObjRelease(pFileStream)
			}
		}

		str :=
		(
		'

		------------------------------' boundary '--
		'
		)

		utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
		DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")
		ObjRelease(pStream)

		pData := DllCall("GlobalLock", "Ptr", hData, "Ptr")
		size := DllCall("GlobalSize", "Ptr", pData, "UPtr")

		retData := ComObjArray(0x11, size)
		pvData := NumGet(ComObjValue(retData), 8 + A_PtrSize, "Ptr")
		DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size)

		DllCall("GlobalUnlock", "Ptr", hData)
		DllCall("GlobalFree", "Ptr", hData, "Ptr")
		contentType := "multipart/form-data; boundary=----------------------------" boundary
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
	Send(channel, files?, contentType := "application/json", id?) {
		payLoad := '{"embeds":' JSON.stringify([this.embedObj])
		. (isSet(id) ? ', "allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' id '", "fail_if_not_exists": false}}' : "}")
		if !IsSet(files)
			return Discord.SendEmbed(channel, payLoad)
		formData := [Map("name", "payload_json", "content-type", "application/json", "content", payLoad)]
		for i in files
			if i is AttachmentBuilder
				formData.Push(Map("name", "file[" A_INDEX-1 "]", "filename", i.fileName, "content-type", contentType, i.type, i.file))
		Discord.CreateFormData(&payLoad, &contentType, formData)
		return Discord.SendEmbed(channel, payLoad, contentType)
	}
}
Class AttachmentBuilder extends EmbedBuilder {
	/**
	 * new AttachmentBuilder()
	 * @param File relative path to file
	 */
	__New(params*) {
		if FileExist(params[1])
			this.fileName := SubStr(params[1], InStr(params[1], "\", 0, -1) + 1), this.type := "file", this.file := params[1]
		else if IsInteger(params[1])
			this.fileName := params[2], this.type := "pBitmap", this.file := params[1]
		else throw Error("Filename <" params[1] "> doesnt exist", , params[1])
		this.attachmentName := "attachment://" this.fileName
	}
}