local config = require("config")

return function(ctx)
	local hasPermission = ctx.hasPermission
	local color         = ctx.color
	local sendError     = ctx.sendError
	local client        = ctx.client

	return {
		auth = config.permissions.is_owner,
		description = "Sets a member as a staff in the #module category.",
		f = function(message, parameters, category)
			local syntax = "Use `!staff @member_name`."

			if parameters and #parameters > 0 then
				local member = string.match(parameters, "<@!?(%d+)>")
				member = member and message.guild:getMember(member)

				if member then
					if hasPermission(config.permissions.is_owner, member, message) then
						return sendError(message, "STAFF", "Module owners already already are staff of their modules.")
					end

					local role = message.guild.roles:find(function(role)
						return role.name == "⚙ " .. category
					end)

					if role then
						if not member:hasRole(role.id) then
							member:addRole(role)

							message:reply({
								content = parameters .. ", <@!" .. message.author.id .. ">",
								embed = {
									color = color.sys,
									title = "Promotion!",
									thumbnail = { url = member.user.avatarURL },
									description = "**" .. member.name .. "** is now part of the " .. category .. " staff!"
								}
							})
						else
							member:removeRole(role)

							message:reply({
								content = parameters .. ", <@!" .. message.author.id .. ">",
								embed = {
									color = color.sys,
									title = "Fire!",
									thumbnail = { url = member.user.avatarURL },
									description = "**" .. member.name .. "** is not part of the " .. category .. " staff anymore!"
								}
							})
						end

						message:delete()
					else
						sendError(message, "STAFF", "Role not found for this category", "Private message **" .. client.owner.tag .. "**")
					end
				else
					sendError(message, "STAFF", "Invalid syntax, user or member.", syntax)
				end
			else
				sendError(message, "STAFF", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
