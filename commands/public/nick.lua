local config = require("config")

return {
	auth = config.permissions.public,
	description = "Changes your nickname in the server. (Blessed command for mobile users)",
	f = function(message, parameters)
		if parameters and #parameters > 0 then
			message.member:setNickname(parameters)
			message:delete()
		end
	end
}
