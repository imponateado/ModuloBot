local config = require("config")

return function(ctx)
	local globalCommands = ctx.globalCommands
	local authIds        = ctx.authIds
	local saveGlobalCommands = ctx.saveGlobalCommands
	local color          = ctx.color
	local sendError      = ctx.sendError

	return {
		auth = config.permissions.is_dev,
		description = "Deletes a global command created by you.",
		f = function(message, parameters, category)
			local syntax = "Use `!delgcmd command_name`."

			if parameters and #parameters > 0 then
				local command = string.match(parameters, "(%a[%w_%-]+)")

				if command then
					command = string.lower(command)
					if globalCommands[command] and (globalCommands[command].author == message.author.id or authIds[message.author.id]) then
						globalCommands[command] = nil

						local deletedAliases = {}
						for cmd, data in next, globalCommands do
							if data.ref and data.ref == command then
								globalCommands[cmd] = nil
								deletedAliases[#deletedAliases + 1] = cmd
							end
						end
						deletedAliases = #deletedAliases == 0 and '' or "\n\nAliases `" .. table.concat(deletedAliases, "`, `") .. "` deleted successfully!"

						saveGlobalCommands()

						message:reply({
							embed = {
								color = color.sys,
								description = "Command `" .. command .. "` deleted successfully!" .. deletedAliases,
								footer = { text = "By " .. message.member.name }
							}
						})

						message:delete()
					else
						sendError(message, "DELGCMD", "This command doesn't exist or you don't have permission to remove it.")
					end
				else
					sendError(message, "DELGCMD", "Invalid syntax.", syntax)
				end
			else
				sendError(message, "DELGCMD", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
