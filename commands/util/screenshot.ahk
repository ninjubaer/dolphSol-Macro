commands.push({
    command: 'screenshot',
    description: 'Take a screenshot of the current page',
    alias: ['ss'],
    function: sendScreenshot
})

sendScreenshot(cmd, params) {
    attachment := AttachmentBuilder(pBitmap := Gdip_BitmapFromScreen())
    embed := EmbedBuilder()
    .setImage({url: attachment.attachmentName})
    .setTitle("Screenshot")
    .setColor(0x2b2d31)
    .setTimeStamp()
    .send(cmd["channel_id"], [attachment], cmd["id"])
    Gdip_DisposeImage(pBitmap)
}