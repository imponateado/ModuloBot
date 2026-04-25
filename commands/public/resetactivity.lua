local config = require("config")

return function(ctx)
	local client        = ctx.client
	local commands      = ctx.commands
	local channels      = ctx.channels
	local save          = ctx.save
	local messageCreate = ctx.messageCreate

	return {
		description = "Resets the monthly activity.",
		f = function(message, parameters)
			-- logs the activity before, just in case it's lost
			messageCreate(client:getChannel("474253217421721600"):getMessage("551753598477008919"), true)

			local m, c = commands["activity"].f(message, nil, nil, nil, true)
			local content = "**Activity Podium** - " .. (parameters or os.date("%m/%y")) .. "\n" .. m .. "\n\n" .. c
			client:getChannel(channels["top-activity"]):send(content)

			ctx.activeChannels[message.guild.id], ctx.activeMembers[message.guild.id] = { }, { }
			save("serverActiveChannels", ctx.activeChannels)
			save("serverActiveMembers", ctx.activeMembers)

			message:delete()
		end
	}
end
