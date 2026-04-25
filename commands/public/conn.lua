local config = require("config")

return {
	auth = config.permissions.public,
	description = "Checks the BOT ping.",
	f = function(message, parameters)
		local m = message:reply("pong")
		m:setContent("**Ping** : " .. string.format("%.3f", ((m.createdAt - message.createdAt) * 1000)) .. " ms.")
	end
}
