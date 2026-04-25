local config = require("config")

return function(ctx)
	local roleColor    = ctx.roleColor
	local countryFlags = config.countryFlags
	local channels     = ctx.channels
	local sendError    = ctx.sendError
	local permissionOverwrites = ctx.permissionOverwrites
	local MOD_ROLE     = ctx.MOD_ROLE
	local roles        = ctx.roles
	local roleFlags    = ctx.roleFlags

	return {
		description = "Creates a new community role.",
		f = function(message, parameters)
			local syntax = "Use `!commu community_code`."

			if parameters and #parameters == 2 then
				parameters = string.upper(parameters)

				local exists = message.guild.roles:find(function(role)
					return role.name == parameters
				end)

				if not exists then
					local role = message.guild:createRole(parameters)

					local botRole = message.guild:getRole(roles["tech guru"]) -- MT
					role:moveUp(botRole.position - #roleFlags - 1)

					local channel = message.guild:createTextChannel(parameters)
					channel:setCategory("472948887230087178") -- category Community

					channel:getPermissionOverwriteFor(message.guild.defaultRole):denyPermissions(table.unpack(permissionOverwrites.community.everyone.denied))
					channel:getPermissionOverwriteFor(role):allowPermissions(table.unpack(permissionOverwrites.community.speaker.allowed))
					-- Muted
					channel:getPermissionOverwriteFor(message.guild:getRole("565703024136421406")):denyPermissions(table.unpack(permissionOverwrites.muted.denied))
					-- Mod
					channel:getPermissionOverwriteFor(MOD_ROLE):allowPermissions(table.unpack(permissionOverwrites.mod.allowed))

					message:reply({
						content = "<@!" .. message.author.id .. ">",
						embed = {
							color = roleColor.community,
							title = "Community!",
							description = (countryFlags[parameters] or (":flag_" .. string.lower(parameters) .. ":")) .. " Community **" .. parameters .. "** created!"
						}
					})

					if countryFlags[parameters] then
						local commu_flag = message.guild:getChannel(channels["commu"]):getLastMessage()
						commu_flag:setContent(commu_flag.content .. "\t" .. countryFlags[parameters] .. " `" .. parameters .. "`")
						commu_flag:addReaction(countryFlags[parameters])
					end

					message:delete()
				else
					sendError(message, "COMMU", "The community '" .. parameters .. "' already exists.")
				end
			else
				sendError(message, "COMMU", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
