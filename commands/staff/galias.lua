local config = require("config")

return function(ctx)
	local globalCommands = ctx.globalCommands
	local saveGlobalCommands = ctx.saveGlobalCommands
	local color          = ctx.color
	local sendError      = ctx.sendError
	local toDelete       = ctx.toDelete

	return {
		auth = config.permissions.is_module,
		description = "Creates an alias for a global command.",
		f = function(message, parameters)
			if parameters and #parameters > 0 then
				local cmd, alias = string.match(parameters, "([%a][%w_%-]+)[\n ]+([%a][%w_%-]+)")
				if not cmd then
					cmd = string.lower(parameters)
					if globalCommands[cmd] and globalCommands[cmd].ref then
						globalCommands[cmd] = nil
						toDelete[message.id] = message:reply({
							embed = {
								color = color.sys,
								title = "Alias GCMD",
								description = "Alias **" .. cmd .. "** deleted successfully."
							}
						})
						saveGlobalCommands()
					else
						sendError(message, "GALIAS", "Invalid command.", "The command **" .. cmd .. "** doesn't exist or is not an alias.")
					end
					return
				end
				cmd, alias = string.lower(cmd), string.lower(alias)

				if globalCommands[cmd] and not globalCommands[cmd].ref and not globalCommands[alias] then
					globalCommands[alias] = { ref = cmd }
					toDelete[message.id] = message:reply({
						embed = {
							color = color.sys,
							title = "Alias GCMD",
							description = "Alias **" .. alias .. "** created successfully."
						}
					})
					saveGlobalCommands()
				else
					sendError(message, "GALIAS", "Invalid command.", "The command **" .. cmd .. "** doesn't exist, already is an alias or can't be overwritten.")
				end
			else
				sendError(message, "GALIAS", "Invalid or missing parameters.", "Use `!galias command alias`")
			end
		end
	}
end
