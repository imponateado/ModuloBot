local config = require("config")

return function(ctx)
	local globalCommands    = ctx.globalCommands
	local saveGlobalCommands = ctx.saveGlobalCommands
	local color             = ctx.color
	local sendError         = ctx.sendError
	local getCommandFormat  = ctx.getCommandFormat
	local getCommandTable   = ctx.getCommandTable
	local commands          = ctx.commands
	local authIds           = ctx.authIds
	local permissions       = config.permissions

	return {
		auth = config.permissions.is_dev,
		description = "Creates a command in the global categories.",
		f = function(message, parameters)
			local category = message.channel.category and string.lower(message.channel.category.name) or nil

			if category and string.sub(category, 1, 1) == "#" then
				return sendError(message, "GCMD", "This command cannot be used for #modules. Use the command `!cmd` instead.")
			end

			local syntax = "Use `!gcmd 0|1|2 0|1|2 0|1 command_name [ script ``` script ``` ] [ value[[command_content]] ] [ title[[command_title]] ] [ description[[command_description]] ]`.\n\n[Click here to open the command generator](https://fiftysol.github.io/gcmd-generator/)"

			if parameters and #parameters > 0 then
				local script, content, title, description = getCommandFormat(parameters)
				local channelLevel, authLevel, allowDM, command = string.match(parameters, "^(%d)[\n ]+(%d)[\n ]+(%d)[\n ]+([%a][%w_%-]+)[\n ]+")

				if channelLevel then
					channelLevel = tonumber(channelLevel)
					if channelLevel < 3 then
						if authLevel then
							authLevel = tonumber(authLevel)
							if authLevel < 3 then
								if allowDM then
									allowDM = tonumber(allowDM)
									if allowDM < 2 then
										if command and #command > 1 and #command < 21 then
											command = string.lower(command)

											if commands[command] then
												return sendError(message, "GCMD", "This command already exists and is not global.")
											end
											if globalCommands[command] and (globalCommands[command].author ~= message.author.id and not authIds[message.author.id]) then
												return sendError(message, "GCMD", "This command already exists.", "Ask the owner, <@" .. globalCommands[command].author .. ">, for editing it.")
											end

											local cmd = getCommandTable(message, script, content, title, description)
											if type(cmd) == "string" then
												return sendError(message, "GCMD", cmd)
											end

											cmd.author = ((globalCommands[command] and globalCommands[command].author) or message.author.id)
											cmd.auth = (authLevel == 0 and permissions.public or authLevel == 1 and permissions.is_dev or permissions.is_module)
											cmd.dm = allowDM == 1
											if channelLevel == 1 then
												cmd.category = message.channel.category.id
											elseif channelLevel == 2 then
												cmd.channel = message.channel.id
											end

											globalCommands[command] = cmd

											saveGlobalCommands()

											message:reply({
												embed = {
													color = color.sys,
													description = "Command `" .. command .. "` created successfully!",
													footer = { text = "By " .. message.member.name }
												}
											})
										else
											sendError(message, "GCMD", "Invalid syntax.", syntax)
										end
									else
										sendError(message, "GCMD", "Invalid level flag.", "The DM authorization level must be 0 (Disallowed) or 1 (Allowed).")
									end
								else
									sendError(message, "GCMD", "Invalid syntax.", syntax)
								end
							else
								sendError(message, "GCMD", "Invalid level flag.", "The authorization level must be 0 (Users), 1 (Developers) or 2 (Module Team).")
							end
						else
							sendError(message, "GCMD", "Invalid syntax.", syntax)
						end
					else
						sendError(message, "GCMD", "Invalid level flag.", "The channel authorization level must be 0 (Global), 1 (Category) or 2 (Channel).")
					end
				else
					sendError(message, "GCMD", "Invalid syntax.", syntax)
				end
			else
				sendError(message, "GCMD", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
