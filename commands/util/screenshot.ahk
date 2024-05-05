commands.push({
    command: 'screenshot',
    description: 'Take a screenshot of the current page',
    alias: ['ss'],
    function: sendScreenshot
})

sendScreenshot(cmd, params) {
    attachment := AttachmentBuilder(pBitmap := Gdip_BitmapFromScreen(), "ss.png")
    embed := EmbedBuilder()
    .setImage({url: "attachment://ss.png"})
    .setColor(0x2b2d31)
    .send(cmd["channel_id"], [attachment], "image/png", cmd["id"])
}