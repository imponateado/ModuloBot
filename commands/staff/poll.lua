local config = require("config")

return function(ctx)
	local sendError = ctx.sendError
	local color     = ctx.color
	local polls     = ctx.polls

	return {
		auth = config.permissions.has_power,
		description = "Creates a poll.",
		f = function(message, parameters)
			if table.find(polls, message.author.id, "authorID") then
				return sendError(message, "POLL", "Poll limit", "There is already a poll made by <@!" .. message.author.id .. ">.")
			end

			if parameters and #parameters > 0 then
				local time, option, question = 10, { "Yes", "No" }

				local custom = string.find(parameters, '`')

				if custom then
					local output, options
					output, question, time, options = string.match(parameters, "`(`?`?)(.*)%1`[ \n]+(%d+)[ \n]+(.+)")

					if not question then return end
					time = math.clamp(tonumber(time), 5, 60)
					if not time then return end

					option = string.split(options, (string.find(options, "`") and "`(.-)`" or "%S+"))
					if not option[2] then return end
				else
					question = string.sub(parameters, 1, 250)
				end

				local img = message.attachment and message.attachment.url

				local poll = message:reply({
					embed = {
						color = color.interaction,
						author = {
							name = message.member.name .. " - Poll",
							icon_url = message.author.avatarURL
						},
						description = "```\n" .. question .. "```\n:one: " .. option[1] .. "\n:two: " .. option[2],
						image = (img and { url = img } or nil),
						footer = {
							text = "Ends in " .. time .. " minutes."
						}
					}
				})
				if not poll then
					return sendError(message, "POLL", "Fatal Error", "Try this command again later.")
				end

				for i = 1, #polls.__REACTIONS do
					poll:addReaction(polls.__REACTIONS[i])
				end

				polls[poll.id] = {
					channel = message.channel.id,
					authorID = message.author.id,
					votes = {0, 0},
					time = os.time() + (time * 60),
					option = option
				}

				message:delete()
			else
				sendError(message, "POLL", "Invalid or missing parameters.", "Use `!poll question` or `!poll ```question``` poll_time` ` `poll_option_1` ` ` ` ` `poll_option_2` ` ` `.")
			end
		end
	}
end
