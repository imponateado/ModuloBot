local config = require("config")

return function(ctx)
	return {
		auth = config.permissions.public,
		description = "The invite link for this server.",
		f = function(message)
			ctx.toDelete[message.id] = message:reply("Invite link: **<https://discord.gg/quch83R>**")
		end
	}
end
