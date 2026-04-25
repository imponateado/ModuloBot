local config = require("config")

return function(ctx)
	local client       = ctx.client
	local color        = ctx.color
	local channels     = ctx.channels
	local reactions    = ctx.reactions
	local buildMessage = ctx.buildMessage

	return {
		auth = config.permissions.public,
		description = "Reports a message.",
		f = function(message, parameters)
			local syntax = "To report a message, please make sure that your developer mode on discord is enabled. Use the command `!report message_id report_reason`"

			message:delete()
			if parameters and #parameters > 0 then
				local msg, reason = string.match(parameters, "^(%d+)[\n ]+(.+)$")

				if msg and reason then
					msg = message.channel:getMessage(msg)

					if msg and not msg.embed then
						local embed = buildMessage(msg, message)
						embed.color = color.err
						embed.author = nil
						embed.fields = nil

						local report = client:getChannel(channels["report"]):send({
							content = "Message from **" .. (msg.member or msg.author).name .. "** <@" .. msg.author.id .. ">\nReported by: **" .. message.member.name .. "** <@" .. message.member.id .. ">\n\nSource: <" .. msg.link .. "> | Reason:\n```\n" .. tostring(reason) .. "```",
							embed = embed
						})

						report:addReaction(reactions.wave)
						report:addReaction(reactions.bomb)
						report:addReaction(reactions.boot)
						report:addReaction(reactions.x)
					else
						message.author:send({ embed = { color = color.err, title = "<:ban:504779866919403520> Report", description = "Invalid message. " .. syntax } })
					end
				else
					message.author:send({ embed = { color = color.err, title = "<:ban:504779866919403520> Report", description = syntax } })
				end
			else
				message.author:send({ embed = { color = color.err, title = "<:ban:504779866919403520> Report", description = "Invalid or missing parameters. " .. syntax } })
			end
		end
	}
end
