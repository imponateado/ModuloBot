local config = require("config")

return function(ctx)
	local authIds   = ctx.authIds
	local roles     = ctx.roles
	local roleFlags = ctx.roleFlags
	local concat    = ctx.concat
	local sendError = ctx.sendError
	local channels  = ctx.channels
	local client    = ctx.client

	return {
		auth = config.permissions.is_mod,
		description = "Gives a role to a member.",
		f = function(message, parameters)
			local syntax = "Use `!set @member_name/member_id role_name/role_flag`."

			if parameters and #parameters > 0 then
				local member, role = string.match(parameters, "<@!?(%d+)>[\n ]+(.+)")

				if not member then
					member, role = string.match(parameters, "(%d+)[\n ]+(.+)")
				end

				if member and role then
					if message.member.id == member and not authIds[member] then
						return sendError(message, "SET", "You can not assign yourself a role.")
					end
					member = message.guild:getMember(member)
					if member then
						local numR = tonumber(role)
						local role_id = roles[numR and roleFlags[numR] or string.lower(role)]
						if role_id then
							if not member:hasRole(role_id) then
								member:addRole(role_id)

								role = message.guild:getRole(role_id)

								local msg = {
									embed = {
										color = role.color,
										title = "Promotion!",
										thumbnail = { url = member.user.avatarURL },
										description = "**" .. member.name .. "** is now " .. (string.find(role.name, "^[^AEIOUaeiou]") and "a" or "an") .. " `" .. string.upper(role.name) .. "`.",
										footer = { text = "Set by " .. message.member.name }
									}
								}
								message:reply(msg)
								client:getChannel(channels["role-log"]):send(msg)
								message:delete()
							else
								sendError(message, "SET", "Member already have the role.")
							end
						else
							sendError(message, "SET", "Invalid role.", "The available roles are:" .. concat(roleFlags, '', function(id, name)
								return tonumber(id) and "\n\t• [" .. id .. "] " .. name or ''
							end))
						end
					else
						sendError(message, "SET", "Member doesn't exist.")
					end
				else
					sendError(message, "SET", "Invalid syntax.", syntax)
				end
			else
				sendError(message, "SET", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
