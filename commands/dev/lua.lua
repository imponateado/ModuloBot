local config = require("config")
local discordia = require("discordia")

return function(ctx)
	local client           = ctx.client
	local channels         = ctx.channels
	local authIds          = ctx.authIds
	local sendError        = ctx.sendError
	local getLuaEnv        = ctx.getLuaEnv
	local wrapMessageObject = ctx.wrapMessageObject
	local tokens           = ctx.tokens
	local token_whitelist  = ctx.token_whitelist
	local memoryLimitByMember = ctx.memoryLimitByMember
	local addRuntimeLimit  = ctx.addRuntimeLimit
	local minutes          = ctx.minutes
	local printf           = ctx.printf
	local getTimerName     = ctx.getTimerName
	local runtimeLimitByMember = ctx.runtimeLimitByMember
	local cmdData          = ctx.cmdData
	local uv_hrtime        = ctx.uv_hrtime
	local test             = ctx.test
	local debugAction      = ctx.debugAction
	local imageHandler     = ctx.imageHandler
	local splitByLine      = ctx.splitByLine
	local hasPermission    = ctx.hasPermission
	local globalCommands   = ctx.globalCommands
	local color            = ctx.color
	local permissions      = config.permissions
	local toDelete         = ctx.toDelete

	return {
		auth = config.permissions.is_dev,
		description = "Loads a Lua code.",
		f = function(message, parameters, _, isTest, compEnv, command)
			local syntax = "Use `!lua ```code``` `."
			local message_author = message.member or message.author

			if parameters and #parameters > 2 then
				local foo
				foo, parameters = string.match(parameters, "`(`?`?)(.*)%1`")

				if not parameters or #parameters == 0 then
					return sendError(message, "Lua", "Invalid syntax.", syntax)
				end

				local lua_tag, final = string.find(string.lower(parameters), "^lua\n+")
				if lua_tag then
					parameters = string.sub(parameters, final + 1)
				end

				local hasAuth = authIds[message.author.id] and not isTest

				local dataLines = {}
				local repliedMessages = {}

				local guild = message.guild or client:getGuild(channels["guild"])
				local _ENV = getLuaEnv(not hasAuth)
				local ENV = (hasAuth and ctx.devENV or ctx.moduleENV) + _ENV
				if compEnv then
					-- parameters
					if not compEnv.parameters then
						ENV.parameters = nil
					else
						ENV = ENV + compEnv
					end
				end
				ENV.discord = { }

				ENV.discord.authorId = message.author.id
				ENV.discord.authorName = message.author.name
				ENV.discord.messageId = message.id

				ENV.discord.message = wrapMessageObject(message)

				ENV.discord.messageContent = message.content:gsub("^!%s*(%S)", "!%1") -- remove later

				ENV.discord.channel = ENV.discord.message.channel

				ENV.discord.lastMessage = function()
					local lastMessage = message.channel:getMessagesBefore(message.id, 1):random()
					if lastMessage then
						return {
							content = lastMessage.content,
							authorId = lastMessage.author.id,
							authorName = lastMessage.author.name
						}
					end
					return { }
				end

				ENV.discord.delete = function(msgId)
					assert(msgId, "Missing parameters in discord.delete")

					local msg = message.channel:getMessage(msgId)
					assert(msg, "Message not found")

					assert((msg.channel.id ~= channels["commu"] and msg.channel.id ~= channels["modules"]), "Message deletion denied.")

					if message.channel.type == 1 then -- dms
						msg:delete()
						return
					end

					assert((os.time() - (60 * 3)) < discordia.Date.fromISO(msg.timestamp):toSeconds(), "The message cannot be deleted after 3 minutes.")

					local canDelete = msg.author.id == message.author.id
					if not canDelete then
						for i = 1, #repliedMessages do
							if repliedMessages[i].id == msgId then
								canDelete = true
								break
							end
						end
					end

					if canDelete then
						msg:delete()
					end
				end

				local http = require("coro-http")
				ENV.discord.http = function(url, header, body, token)
					assert(url, "Missing url link in discord.http")

					if token then
						if type(token) == "string" then
							if (tokens[token] and string.find(url, "^" .. token_whitelist[token])) then
								url = url .. tokens[token]
							end
						else
							if (token[2] and tokens[token[2]] and string.find(url, "^" .. token_whitelist[token[2]])) then
								if not header then
									header = { }
								end
								header[#header + 1] = { token[1], tokens[token[2]] }
							end
						end
					end

					local method = string.sub(url, 1, 1)
					if method == "!" or method == "*" or method == "@" then -- POST, DELETE, PATCH
						url = string.sub(url, 2)
						method = (method == "!" and "POST" or method == "*" and "DELETE" or method == "@" and "PATCH")
					else
						method = nil
					end
					return http.request((method or "GET"), url, header, body)
				end

				ENV.discord.reply = function(text)
					if #repliedMessages < (hasAuth and 50 or 30) then
						assert(text, "Missing parameter in discord.reply")

						if type(text) == "table" then
							if text.content then
								text.content = string.gsub(text.content, "[@!]*<[@!]+(%d+)>", function(id)
									return "<" .. (id == message.author.id and '' or "\\") .. "@" .. id .. ">"
								end)
								text.content = string.gsub(text.content, "@here", "@ here")
								text.content = string.gsub(text.content, "@everyone", "@ everyone")
							end
						else
							text = string.gsub(text, "[@!]*<[@!&]+(%d+)>", function(id)
								return "<" .. (id == message.author.id and '' or "\\") .. "@" .. id .. ">"
							end)
							text = string.gsub(text, "@here", "@ here")
							text = string.gsub(text, "@everyone", "@ everyone")
						end

						local msg = message:reply(text)
						assert(msg, "Missing content in discord.reply")

						repliedMessages[#repliedMessages + 1] = msg
						return msg.id
					end
					return false
				end

				ENV.discord.editMessage = function(messageId, content)
					assert(messageId, "Missing parameter 'messageId' in discord.editMessage")
					assert(content, "Missing parameter 'content' in discord.editMessage")
					assert(type(content) == "table", "Parameter 'content' should be a table in discord.editMessage")

					if content.content then
						content.content = string.gsub(content.content, "[@!]*<[@!]+(%d+)>", function(id)
							return "<" .. (id == message.author.id and '' or "\\") .. "@" .. id .. ">"
						end)
						content.content = string.gsub(content.content, "@here", "@ here")
						content.content = string.gsub(content.content, "@everyone", "@ everyone")
					end

					local msg = message.channel:getMessage(messageId)
					assert(msg, "Could not find message '" .. messageId .. "'")

					assert((os.time() - (60 * 3)) < discordia.Date.fromISO(msg.timestamp):toSeconds(), "The message cannot be updated after 3 minutes.")

					msg:update(content)

					return msg.id
				end

				ENV.discord.sendError = function(command, err, description)
					assert(err, "Missing error title in discord.sendError")

					sendError(message, command, err, description)
				end

				local maximumMemoryUsage = memoryLimitByMember(message.member or guild:getMember(message.author.id))
				ENV.discord.load = function(src)
					assert(src, "Source can't be nil in discord.load")

					return load(addRuntimeLimit(src, message, nil, maximumMemoryUsage), '', 't', ENV)
				end

				ENV.getTime = function()
					return minutes
				end

				ENV.print = function(...)
					local out = { }
					for arg = 1, select('#', ...) do
						out[arg] = tostring(select(arg, ...))
					end
					local r = table.concat(out, "\t")
					dataLines[#dataLines + 1] = r == '' and ' ' or r
				end

				ENV.printt = function(s, stop, ...)
					stop = stop or 1
					s = table.tostring(s, true, true, stop, ...)
					return ENV.print((#s < 1900 and ("```Lua\n" .. s .. "```") or s))
				end

				local getOwner = function(message, name)
					local owner
					if isTest == debugAction.cmd then
						command = tostring(command)
						assert(globalCommands[command], "Source command not found (" .. (name or command) .. ").")

						owner = globalCommands[command].author

						assert(hasPermission(permissions.is_module, guild:getMember(owner)), "<@" .. owner .. "> You cannot use this function (" .. (name or '') .. ").")
					else
						owner = message.author.id
						assert(hasPermission(permissions.is_module, guild:getMember(owner)), "You cannot use this function (" .. (name or '') .. ").")
					end
					return owner
				end

				if hasAuth then
					ENV.channel = message.channel
					ENV.message = message
					ENV.guild = message.guild

					ENV.load = function(src, env)
						return load(src, '', 't', (ENV or env))
					end
				end

				local timerName
				if isTest ~= debugAction.test then
					local timerNameUserId, limSeconds = message.author.id
					if not hasAuth then
						parameters, limSeconds = addRuntimeLimit(parameters, message, timerNameUserId, maximumMemoryUsage)
					end

					timerName = getTimerName(timerNameUserId)
					ENV[timerName] = function() return os.time() + (limSeconds or runtimeLimitByMember(message.member or guild:getMember(message.author.id))) end
				end

				ENV.discord.getData = function(userId)
					assert(userId, "User id can't be nil in discord.getData")

					local owner = getOwner(message, "getData")

					return (cmdData[owner] and cmdData[owner][userId] or '')
				end

				ENV.discord.saveData = function(userId, data)
					assert(userId, "User id can't be nil in discord.saveData")
					userId = tostring(userId)
					assert(data, "Data can't be nil in discord.saveData")
					data = tostring(data)
					assert(#data <= 8000, "Data can't exceed 8000 characters")

					local owner = getOwner(message, "saveData")

					if not cmdData[owner] then
						cmdData[owner] = { }
					end
					cmdData[owner][userId] = (data ~= '' and data or nil)
					return true
				end

				ENV.discord.getAllMembers = function(f)
					assert(f, "f can't be nil in discord.getAllMembers")
					assert(type(f) == "function", "f must be a function(member) in discord.getAllMembers")

					getOwner(message, "getAllMembers")

					local names, index = { }, 0
					guild.members:findAll(function(member)
						if f(member.id) then
							index = index + 1
							names[index] = member.id
						end
					end)()
					return names, index
				end

				ENV.getImage = function(url)
					assert(url, "Url can't be nil in getImage")

					getOwner(message, "getImage")

					return tostring(imageHandler.fromUrl(url))
				end

				ENV.discord.addReaction = function(messageId, reaction)
					assert(messageId, "Message id can't be nil in discord.addReaction")
					assert(reaction, "Reaction can't be nil in discord.addReaction")

					messageId = tostring(messageId)
					local msg = message.channel:getMessage(messageId)
					assert(msg, "Message '" .. tostring(messageId) .. "' not found.")
					assert((os.time() - (60 * 5)) < discordia.Date.fromISO(msg.timestamp):toSeconds(), "You can't add a reaction to a message that has been sent for longer than 5 minutes.")

					return not not msg:addReaction(reaction)
				end

				ENV.discord.retrieveReactions = function(messageId)
					messageId = tostring(messageId)
					local msg = message.channel:getMessage(messageId)
					assert(msg, "Message '" .. tostring(messageId) .. "' not found.")

					local reactions, counter = { }, 0
					for reaction in msg.reactions:iter() do
						reactions[reaction.emojiHash] = { }
						counter = 0
						for member in reaction:getUsers():iter() do
							counter = counter + 1
							reactions[reaction.emojiHash][counter] = member.id
						end
					end

					return reactions
				end

				ENV.discord.getMemberId = function(memberName)
					assert(memberName, "Member name can't be nil in discord.getMemberId")
					memberName = tostring(memberName):lower()

					local member = guild.members:find(function(m)
						return m.name:lower() == memberName or m.user.name:lower() == memberName
					end)

					return member and member.id
				end

				ENV.discord.getMemberName = function(memberId)
					assert(memberId, "Member ID can't be nil in discord.getMemberName")
					memberId = tostring(memberId)

					local member = guild:getMember(memberId)
					return member and member.name
				end

				ENV.discord.getMemberRoles = function(memberId)
					assert(memberId, "Member ID can't be nil in discord.getMemberRoles")
					memberId = tostring(memberId)

					local member = guild:getMember(memberId)
					if not member then return end

					return table.createSet(member.roles[1])
				end

				ENV.discord.getNicknamesFromMemberNamesChannel = function(channelId)
					assert(channelId, "Channel ID can't be nil in discord.getNicknamesFromMemberNamesChannel")
					channelId = tostring(channelId)

					local channel = message.guild:getChannel(channelId)
					if not channel then return end

					assert(channel.name == "member_names", "discord.getNicknamesFromMemberNamesChannel can only look for channels named member_names")

					local messages = channel:getMessages(100)
					local names = { }

					local tmpId, tmpNickname
					for message in messages:iter() do
						tmpId, tmpNickname = message.content:match("^<@!?(%d+)> *= *(%S+)")
						if tmpId then
							names[tmpId] = message.content:match(tmpNickname)
						end
					end

					return names
				end

				ENV.discord.isMember = function(userId)
					assert(userId, "Member id cannot be nil in discord.isMember")
					return not not (guild:getMember(userId))
				end

				ENV.discord.sendPrivateMessage = function(content, id)
					assert(content, "Content cannot be nil in discord.sendPrivateMessage")

					if type(content) ~= "table" then
						content = tostring(content)
					end

					local sendTo = message.author
					if id and getOwner(message, "sendPrivateMessage") then
						sendTo = client:getUser(id)
						assert(sendTo, "Cannot retrieve target user in discord.sendPrivateMessage")
					end

					local msg = sendTo:send(content)
					return msg and msg.id
				end

				ENV.discord.getMessage = function(channelId, messageId)
					assert(channelId, "Channel id cannot be nil in discord.getMessage")
					assert(messageId, "Message id cannot be nil in discord.getMessage")
					channelId, messageId = tostring(channelId), tostring(messageId)

					local msg = client:getChannel(channelId):getMessage(messageId)
					return msg and wrapMessageObject(msg) or nil
				end

				ENV.getmetatable = function(x)
					if type(x) == "string" then
						return "gtfo"
					end
					return getmetatable(x)
				end

				ENV.setmetatable = function(x, m)
					if x == string or x == math or x == table or type(x) == "string" or x == ENV or x == _G then
						return "gtfo"
					end
					return setmetatable(x, m)
				end

				ENV.test = function(...)
					local t, l = test(...)
					for i = 1, l do
						ENV.print(t[i])
					end
				end

				ENV.discord.getPinnedMessages = function(channelId)
					assert(channelId, "Channel id cannot be nil in discord.getPinnedMessages")
					channelId = tostring(channelId)

					local messages, index = { }, 0
					for message in client:getChannel(channelId):getPinnedMessages():iter() do
						index = index + 1
						messages[index] = wrapMessageObject(message)
					end

					return messages
				end

				local mainCoro = coroutine.running()
				ENV.discord.yield = function(...)
					if coroutine.running() ~= mainCoro then
						return coroutine.yield(...)
					end
					error("Can not yield main thread.", 2)
				end

				ENV.discord.waitForEvent = function(eventName, timeout)
					assert(eventName, "Event name cannot be nil in discord.waitForEvent")
					timeout = timeout or 5000

					getOwner(message, "waitForEvent")

					if eventName == "interactionCreate" then
						local success, message, member, interactionData = client:waitFor(eventName, timeout)
						return success, wrapMessageObject(message), member.user.id, interactionData
					else
						assert(false, "Event '" .. eventName .. "' is not mapped in discord.waitForEvent")
					end
				end

				ENV._G = ENV

				if timerName then
					ENV[timerName] = ENV[timerName]()
				end
				collectgarbage()
				local func, syntaxErr = load(parameters, '', 't', ENV)
				if not func then
					toDelete[message.id] = message:reply({
						embed = {
							color = color.lua_err,
							title = "[" .. message_author.name .. ".Lua] Error : SyntaxError",
							description = "```\n" .. syntaxErr .. "```"
						}
					})
					return
				end
				collectgarbage()

				if isTest == debugAction.test then
					return parameters
				end

				-- Runs the code
				local ms = uv_hrtime()
				local success, runtimeErr = pcall(func)
				ms = (uv_hrtime() - ms) / 1e6

				if not success then
					toDelete[message.id] = message:reply({
						embed = {
							color = color.lua_err,
							title = "[" .. message_author.name .. ".Lua] Error : RuntimeError",
							description = "```\n" .. tostring(runtimeErr) .. "```"
						}
					})
					return
				end

				local result
				if isTest ~= debugAction.cmd then
					result = message:reply({
						embed = {
							color = color.sys,
							footer = {
								text = "[" .. message_author.name .. ".Lua] Loaded successfully! (Ran in " .. ms .. "ms)"
							}
						}
					})
				end

				local lines = splitByLine(table.concat(dataLines, "\n"))

				local messages = { }
				for id = 1, math.min(#lines, (hasAuth and 5 or 3)) do
					messages[#messages + 1] = message:reply({
						embed = {
							color = color.sys,
							description = lines[id]
						}
					})
				end

				for id = 1, #repliedMessages do
					messages[#messages + 1] = repliedMessages[id]
				end

				if isTest ~= debugAction.cmd then
					messages[#messages + 1] = result
				end

				if #messages > 0 then
					if isTest == debugAction.cmd then
						return messages
					else
						toDelete[message.id] = messages
					end
				end
			else
				sendError(message, message_author.name .. ".Lua", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
