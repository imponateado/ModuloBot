local config = require("config")

return function(ctx)
	local binBase64 = ctx.binBase64
	local color     = ctx.color
	local sendError = ctx.sendError
	local http      = require("coro-http")

	return {
		auth = config.permissions.is_module,
		description = "Creates an emoji in the server.",
		f = function(message, parameters)
			local invalid
			if not parameters or #parameters < 3 then
				invalid = true
			end

			local emojiName, url
			if not invalid then
				emojiName, url = string.match(parameters, "^([%w_]+)[\n ]*(%S*)")
				if not emojiName then
					invalid = true
				end
			end

			if invalid then
				sendError(message, "EMOJI", "Invalid or missing parameters.", "Use `!emoji name` attached to an image or `!emoji name url`.")
				return
			end
			emojiName = string.lower(emojiName)

			local image = ((url and url ~= '') and url or (message.attachment and message.attachment.url))
			if image then
				local head, body = http.request("GET", image)

				if body then
					image = "data:image/png;base64," .. binBase64.encode(body)

					local emoji = message.guild:createEmoji(emojiName, image)
					if emoji then
						message:reply({
							embed = {
								color = color.interaction,
								title = "New Emoji!",
								description = "Emoji **:" .. emojiName .. ":** added successfully",
								image = {
									url = emoji.url
								},
								footer = { text = "By " .. message.member.name }
							}
						})

						message:delete()
					else
						sendError(message, "EMOJI", "Internal error.", "Try again later.")
					end
				else
					sendError(message, "EMOJI", "Invalid image or internal error.", "Try again later.")
				end
			else
				sendError(message, "EMOJI", "Invalid or missing image attachment.")
			end
		end
	}
end
