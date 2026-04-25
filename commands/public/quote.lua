local config = require("config")

return function(ctx)
	local client      = ctx.client
	local sendError   = ctx.sendError
	local buildMessage = ctx.buildMessage

	return {
		auth = config.permissions.public,
		description = "Quotes an old message.",
		f = function(message, parameters)
			if parameters and #parameters > 0 then
				local quotedChannel, quotedMessage
				quotedChannel, quotedMessage = string.match(parameters, "^https://discordapp.com/channels/%d+/(%d+)/(%d+)$")
				if not quotedChannel then
					quotedChannel, quotedMessage = string.match(parameters, "<?#?(%d+)>? *%-(%d+)")
					quotedMessage = quotedMessage or string.match(parameters, "%d+")
				end

				if quotedMessage then
					local msg = client:getChannel(quotedChannel or message.channel)
					if msg then
						msg = msg:getMessage(quotedMessage)

						if msg then
							message:delete()
							message:reply({ content = "_Quote from **" .. (message.member or message.author).name .. "**_", embed = buildMessage(msg, message) })
						end
					end
				end
			else
				sendError(message, "QUOTE", "Invalid or missing parameters.", "Use `!quote [channel_id-]message_id`.")
			end
		end
	}
end
