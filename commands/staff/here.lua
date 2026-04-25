local config = require("config")

return function(ctx)
	local sendError = ctx.sendError

	return {
		auth = config.permissions.is_mod,
		description = "Pings @here.",
		f = function(message, parameters)
			if not parameters or #parameters < 1 then
				return sendError(message, "HERE", "Invalid or missing parameters.", "Use `!here message`.")
			end

			message:reply("@here\n<@" .. message.author.id .. "> says... " .. tostring(parameters))
			message:delete()
		end
	}
end
