local config = require("config")

return function(ctx)
	local client           = ctx.client
	local sendError        = ctx.sendError
	local authIds          = ctx.authIds
	local categories       = config.categories
	local roles            = config.roles
	local specialRoleColor = config.specialRoleColor
	local channels         = config.channels

	return {
		auth = config.permissions.has_power,
		description = "Leaves a team/role.",
		f = function(message, parameters)
			if not categories[message.channel.category.id] then
				return sendError(message, "RESIGN", "This command cannot be used in this category.")
			end

			if parameters and authIds[message.author.id] then
				local syntax = "Use `!resign @role_member_name`"

				local member = string.match(parameters, "%d+")
				if not member then
					return sendError(message, "RESIGN", "Invalid or missing parameters.", syntax)
				end

				member = message.guild:getMember(member)
				if not member then
					return sendError(message, "RESIGN", "Member doesn't exist.")
				end

				parameters = member
			else
				parameters = message.guild:getMember(message.author.id)
			end

			local role = message.channel.category.permissionOverwrites:find(function(role)
				return roles[role.id]
			end)
			role = role and message.guild:getRole(role.id)

			if not role then
				return sendError(message, "RESIGN", "Role not found.", "Report it to <@" .. client.owner.id .. ">")
			end

			if not parameters:hasRole(role.id) then
				return sendError(message, "RESIGN", "You cannot resign from a role you do not have.", "You don't have the role '" .. role.name .. "'.")
			end

			parameters:removeRole(role.id)
			if specialRoleColor[role.id] then
				parameters:removeRole(specialRoleColor[role.id])
			end

			local msg = {
				embed = {
					color = role.color,
					title = "Demotion :(",
					thumbnail = { url = parameters.user.avatarURL },
					description = "**" .. parameters.name .. "** is not a `" .. string.upper(role.name) .. "` anymore.",
					footer = { text = "Unset by " .. message.member.name }
				}
			}
			message:reply(msg)
			client:getChannel(channels["role-log"]):send(msg)
			message:delete()
		end
	}
end
