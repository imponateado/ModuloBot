local config = require("config")

return function(ctx)
	local toDelete      = ctx.toDelete
	local splitByLine   = ctx.splitByLine
	local timer         = ctx.timer
	local color         = ctx.color
	local permIcons     = ctx.permIcons
	local authIds       = ctx.authIds
	local hasPermission = ctx.hasPermission
	local permissions   = config.permissions

	return {
		auth = config.permissions.public,
		f = function(message, parameters, category, cmdSrc)
			local hasFilter = not not parameters

			if category and string.sub(category, 1, 1) == "#" then
				local keys = { }
				local cmds = { }
				for cmd, data in next, ctx.modules[category].commands do
					if not cmds[data.auth] then
						cmds[data.auth] = { }
						keys[#keys + 1] = data.auth
					end
					cmds[data.auth][#cmds[data.auth] + 1] = { cmd = cmd, data = data }
				end
				table.sort(keys)

				local prefix = "**" .. (ctx.modules[category].prefix or "!")

				for k, v in next, keys do
					local icon = permIcons[permissions(v)]
					table.sort(cmds[v], function(c1, c2) return c1.cmd < c2.cmd end)
					for j = 1, #cmds[v] do
						local cmd = cmds[v][j].cmd

						if not hasFilter or string.find(cmd, parameters, 1, true) then
							cmds[v][j] = icon .. prefix .. cmds[v][j].cmd .. "** " .. (cmds[v][j].data.info or '')
						end
					end
					keys[k] = table.concat(cmds[v], '\n')
				end
				cmds = table.concat(keys, '\n')

				toDelete[message.id] = message:reply({
					content = "<@!" .. message.author.id .. ">",
					embed = {
						color = color.sys,
						title = category .. " commands",
						description = cmds
					}
				})
			else
				local keys = { }
				local cmds, icon, description, index = { }
				local commandsSourceTable = (cmdSrc or ctx.commands)
				for cmd, cmdData in next, commandsSourceTable do
					if not cmdData.category or (message.channel.category and cmdData.category == message.channel.category.id) then
						if not cmdData.channel or cmdData.channel == message.channel.id then
							local data = cmdData
							if cmdData.ref then
								data = commandsSourceTable[cmdData.ref]
							end

							if authIds[message.author.id] or (data.auth and hasPermission(data.auth, message.member, message)) then
								if not hasFilter or string.find(cmd, parameters, 1, true) then
									icon = (not data.auth and permIcons.is_admin or permIcons[permissions(data.auth)]) .. " "

									description = data.description or data.info
									description = description and ("- " .. description) or ''

									index = data.auth or 666
									if not cmds[index] then
										cmds[index] = { }
										keys[#keys + 1] = index
									end
									cmds[index][#cmds[index] + 1] = { cmd = cmd, data = icon .. "**!" .. cmd .. "** " .. description }
								end
							end
						end
					end
				end
				table.sort(keys)

				for k, v in next, keys do
					table.sort(cmds[v], function(c1, c2) return c1.cmd < c2.cmd end)
					for j = 1, #cmds[v] do
						cmds[v][j] = cmds[v][j].data
					end
					keys[k] = table.concat(cmds[v], '\n')
				end
				cmds = table.concat(keys, '\n')

				local lines = splitByLine(cmds)

				local msg = { }
				for line = 1, #lines do
					msg[line] = message:reply({
						content = (line == 1 and "<@!" .. message.author.id .. ">" or nil),
						embed = {
							color = color.sys,
							title = (line == 1 and (cmdSrc and "Global " or "") .. "Commands" or nil),
							description = lines[line]
						}
					})
				end
				toDelete[message.id] = msg

				timer.setTimeout(3 * 60 * 1000, coroutine.wrap(function(msg)
					if toDelete[message.id] then
						ctx.messageDelete(message)
					end
				end), message)
			end
		end
	}
end
