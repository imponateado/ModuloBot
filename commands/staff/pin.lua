local config = require("config")

return function(ctx)
	return {
		auth = config.permissions.has_power,
		description = "Pins or Unpins a message in an #prj channel.",
		f = function(message, parameters, category)
			if not string.find(string.lower(message.channel.name), "^prj_") then
				return ctx.sendError(message, "PIN", "This command cannot be used in this channel.")
			end

			local syntax = "Use `!pin message_id`."

			if parameters and #parameters > 0 then
				local msg = message.channel:getMessage(parameters)
				if msg then
					if msg.pinned then
						msg:unpin()
					else
						msg:pin()
					end
					message:delete()
				else
					ctx.sendError(message, "PIN", "Message not found.", "Use a valid message id on this channel.\n" .. syntax)
				end
			else
				ctx.sendError(message, "PIN", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
