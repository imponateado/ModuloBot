local config = require("config")

return function(ctx)
	local envDocs            = ctx.envDocs
	local findKeyInsensitive = ctx.findKeyInsensitive
	local hasPermission      = ctx.hasPermission
	local permIcons          = ctx.permIcons
	local permissions        = config.permissions
	local pairsByIndexes     = ctx.pairsByIndexes
	local toDelete           = ctx.toDelete
	local color              = ctx.color

	return {
		auth = config.permissions.is_dev,
		description = "Shows Lua API documentation",
		f = function(message, parameters)
			parameters = parameters and #parameters > 0 and tostring(parameters) or ''

			local ns, fn
			if parameters == "" then
				ns, fn = nil, nil
			elseif string.find(parameters, "%.") then
				ns, fn = string.match(parameters, "^([^%.]+)%s*%.%s*(.+)$")
			else
				ns, fn = string.match(parameters, "^(%S+)%s*(%S*)$")
				fn = fn and #fn > 0 and fn or nil

				if not envDocs[ns] and not fn then
					ns, fn = '_G', ns
				end
			end

			if ns then
				ns = findKeyInsensitive(envDocs, ns)
			end

			-- NO PARAMETERS → LIST NAMESPACES
			if not ns or not fn then
				local lines, li = {}, 0

				for name, scope in pairsByIndexes(envDocs, function(a, b) return a < b end) do
					if not ns or ns == name then
						local methods, mi = {}, 0

						for mName, data in next, scope do
							if not data.auth or hasPermission(data.auth, message.member, message) then
								mi = mi + 1
								methods[mi] = (data.auth and (permIcons[permissions(data.auth)] .. " ") or '') .. "`" .. mName .. "`"
							end
						end

						if mi > 0 then
							table.sort(methods)

							li = li + 1
							lines[li] = name

							for i = 1, mi do
								li = li + 1
								lines[li] =
									(i == mi and "└─ " or "├─ ") .. methods[i]
							end

							li = li + 1
							lines[li] = "" -- spacing between namespaces
						end
					end
				end

				if li == 0 then
					toDelete[message.id] = message:reply("No entries available.")
					return
				end

				toDelete[message.id] = message:reply({
					embed = {
						color = color.sys,
						title = "Bot API",
						description = table.concat(lines, "\n")
					}
				})
				return
			end

			local scope = envDocs[ns] or envDocs._G
			if not fn then
				toDelete[message.id] = message:reply("Missing name, only got namespace")
				return
			end

			-- FUNCTION DOC
			fn = findKeyInsensitive(scope, fn)
			local data = scope[fn]

			if not data then
				toDelete[message.id] = message:reply("Documentation for `" .. tostring(ns) .. "." .. tostring(fn) .. "` not found.")
				return
			elseif data.auth and not hasPermission(data.auth, message.member, message) then
				toDelete[message.id] = message:reply("You don’t have permission to access the documentation for `" .. tostring(ns) .. "." .. tostring(fn) .. "`.")
				return
			end

			local lines, i = {
				data.description or "_N/A_"
			}, 1

			if data.type then
				i = i + 1
				lines[i] = "\n**Type:** `" .. data.type .. "`"
			end

			if data.params then
				i = i + 1
				lines[i] = "\n**Parameters:**"
				for p = 1, #data.params do
					i = i + 1
					lines[i] = "`" .. data.params[p].name .. "` : " .. data.params[p].type
				end
			end

			if data.returns then
				i = i + 1
				lines[i] = "\n**Returns:** `" .. data.returns .. "`"
			end

			toDelete[message.id] = message:reply({
				embed = {
					color = color.sys,
					title = (data.auth and (permIcons[permissions(data.auth)] .. " ") or '') .. "**" .. ns .. "." .. fn .. "**",
					description = table.concat(lines, "\n")
				}
			})
		end
	}
end
