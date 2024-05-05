commands.push({
    command: 'help',
    description: 'Show this help message',
    alias: ['', 'h', '?'],
    function: showHelp
})

showHelp(cmd, params) {
    if params.has(2)
        switch params[2] {
            case 2:
                Embed := EmbedBuilder()
                .setTitle("Help")
                .setFooter({text: "Page 2/2"})
                .send(cmd["channel_id"],,,cmd["id"])
            default:
                Embed := EmbedBuilder()
                .setTitle("Help")
                .setFooter({text: "Page 1/2"})
                .send(cmd["channel_id"],,,cmd["id"])
        }
    else {
        Embed := EmbedBuilder()
        .setTitle("Help")
        .setFooter({text: "Page 1/2"})
        .send(cmd["channel_id"],,,cmd["id"])
    }
}