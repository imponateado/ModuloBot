local config = require("config")

return function(ctx)
	local toDelete    = ctx.toDelete
	local sendError   = ctx.sendError
	local concat      = ctx.concat
	local splitByLine = ctx.splitByLine
	local roleFlags   = ctx.roleFlags
	local reactions   = ctx.reactions
	local color       = ctx.color

	return {
		auth = config.permissions.public,
		description = "Lists the users with a specific role.",
		f = function(message, parameters)
			local syntax = "Use `!list [-]role_name/flag[, ...]`.\n\nThe available roles are:" .. concat(roleFlags, '', function(id, name)
				return tonumber(id) and "\n\t• [" .. id .. "] " .. name or ''
			end)

			if parameters and #parameters > 0 then
				parameters = string.lower(parameters)

				local counterRoles, counterNonRoles = 0, 0
				local roles, nonRoles = { }, { }
				local non, value, isId
				for role in string.gmatch(parameters, "[^,]+") do
					role = string.trim(role)

					non = string.sub(role, 1, 1) == '-'
					if non then
						counterNonRoles = counterNonRoles + 1
						role = string.sub(role, 2)
					else
						counterRoles = counterRoles + 1
					end

					isId = tonumber(role)
					if isId then
						role = roleFlags[isId] or role
					end
					value = message.guild.roles:find(function(r)
						return string.lower(r.name) == role
					end)

					if not value then
						return sendError(message, "LIST", "The role '" .. role .. "' does not exist.", syntax)
					end

					if non then
						nonRoles[counterNonRoles] = value
					else
						roles[counterRoles] = value
					end
				end

				local toSort, counter = { }, 0
				for member in message.guild.members:findAll(function(member)
					for i = 1, #roles do
						if not member:hasRole(roles[i]) then
							return false
						end
					end

					for i = 1, #nonRoles do
						if member:hasRole(nonRoles[i]) then
							return false
						end
					end

					return true
				end) do
					counter = counter + 1
					toSort[counter] = member
				end
				table.sort(toSort, function(m1, m2) return m1.name < m2.name end)

				local members = { }
				for m = 1, counter do
					members[m] = "<:" .. (reactions[toSort[m].status] or ':') .. "> <@" .. toSort[m].id .. "> " .. toSort[m].name
				end

				local lines, msgs = splitByLine(table.concat(members, "\n")), { }
				for i = 1, #lines do
					msgs[i] = message:reply({
						embed = {
							color = color.sys,
							title = (i == 1 and ("<:wheel:456198795768889344> Members " .. (roles and ("+(" .. concat(roles, ", ", function(index, value) return string.upper(value.name) end) .. ")") or "") .. (nonRoles and ("-(" .. concat(nonRoles, ", ", function(index, value) return string.upper(value.name) end) .. ")") or "") .. " (#" .. #members .. ")") or nil),
							description = lines[i]
						}
					})
				end
				toDelete[message.id] = msgs
			else
				sendError(message, "LIST", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
