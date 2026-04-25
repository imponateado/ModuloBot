local config = require("config")

return function(ctx)
	return {
		auth = config.permissions.public,
		f = function(message, parameters)
			ctx.commands["help"].f(message, parameters, nil, ctx.globalCommands)
		end
	}
end
