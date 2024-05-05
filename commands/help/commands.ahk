commands.push({
    command: 'commands',
    description: 'List all available commands',
    alias: [],
    function: showCommands
})

showCommands(cmd, params) {
    fields := []
    for i in commands {
        fields.push({
            name: i.command,
            value: i.description,
            inline: true
        })
    }
    embed := EmbedBuilder()
    .setTitle("Available commands")
    .addFields(fields)
    .send(cmd["channel_id"])
}