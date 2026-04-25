local config = require("config")

return function(ctx)
	return {
		auth = config.permissions.public,
		description = "Displays someone's avatar.",
		f = function(message, parameters)
			parameters = not parameters and message.author.id or string.match(parameters, "(%d+)")
			parameters = parameters and ctx.client:getUser(parameters)

			if parameters then
				local url = parameters.avatarURL .. "?size=2048"

				ctx.toDelete[message.id] = message:reply({
					embed = {
						color = config.color.sys,
						description = "**" .. parameters.name .. "'s avatar: [here](" .. url .. ")**",
						image = { url = url }
					}
				})
			end
		end
	}
end
