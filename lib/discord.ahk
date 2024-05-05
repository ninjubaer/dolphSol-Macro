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
	static CreateFormData(&payload, &contentType, fields) {
		static chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		Boundary := "----------W-NINJU-FEROX-BOUNDARY-" SubStr(Sort(chars, "Random"), 1, 12)
		Len := 0
		buf := Buffer(0,0)
		for field in fields {
			str :=
			(
			Boundary '
			Content-Disposition: form-data; name="' field.name '";' (field.HasProp("filename") ? ' filename="' field.filename '"' : "") '
			Content-type: ' (field.hasProp("contentType") ? field.contentType : field.HasProp("filename") ? getContentType(field.filename) : "application/json") '
			
			' (field.hasProp("payload") ? field.payload "`r`n" : "")
			)
			msgbox str
			buf := toUtf8(str)
			if field.hasProp("pBitmap") {
				try {
					bm := Buffer(40, 0)
					DllCall("GetObject", "ptr", field.pBitmap, "int", 40, "ptr", bm.ptr)
					width := NumGet(bm.ptr, 8, "int"), height := NumGet(bm.ptr, 12, "int")
					data := Buffer(width * height * 4,0)
					DllCall("GetDIBits", "ptr", field.pBitmap, "ptr", 0, "uint", 0, "uint", height, "ptr", data.ptr, "ptr", bm.ptr, "uint", 0)
					len += data.size, newBuf := Buffer(len, 0)
					DllCall("RtlMoveMemory", "ptr", newBuf.ptr, "ptr", buf.ptr, "uint", buf.size)
					buf := newBuf
				}
				catch error as e {
					msgbox e.message
				}
			}
			if field.hasProp("file") {
				f := FileOpen(field.file, "r"), len += f.Length
				newBuf := Buffer(len, 0)
				f.RawRead(newBuf.ptr + buf.Size, f.Length), f.Close()
			}
		}
		buf := toUtf8(Boundary "--`r`n")
		payload := ComObjArray(0x11, len)
		pvData := NumGet(ComObjValue(payload) + 8 + A_PtrSize, "uint")
		DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", buf, "Ptr", len)
		contentType := "multipart/form-data; boundary=" SubStr(Boundary,3)

		getContentType(FileName) {
			if !FileExist(FileName)
				return "image/png"
			n:=(f := FileOpen(FileName, "r")).ReadUInt(), f.Close()
			return n = 0x474E5089 ? "image/png"
				: n = 0x38464947 ? "image/gif"
				: (n&0xFFFF = 0xD8FF ) ? "image/jpeg"
				: "application/octet-stream"
		}
		toUtf8(str) {
			len += StrPut(str, "UTF-8")-1
			buffNew := Buffer(len, 0)
			DllCall("RtlMoveMemory", "ptr", buffNew.ptr, "ptr", buf.ptr, "uint", buf.Size)
			StrPut(str, buffNew.ptr + buf.Size, "UTF-8")
			return buffNew
		}
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
	Send(channel, files?, contentType := "application/json", id?) {
		payLoad := '{"embeds":' JSON.stringify([this.embedObj])
		. (isSet(id) ? ', "allowed_mentions": {"parse": []}, "message_reference": {"message_id": "' id '", "fail_if_not_exists": false}}' : "}")
		if !IsSet(files)
			return Discord.SendEmbed(channel, payLoad)
		formData := [{name:"payload_json", contentType : "application/json", payload: payLoad}]
		for i in files
			if i is AttachmentBuilder
				formData.Push({name: "file[" A_INDEX-1 "]", filename: i.fileName, contentType: contentType, %i.type%: i.file})
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