local config   = require("config")
local discordia = require("discordia")

return {
	auth = config.permissions.public,
	description = "Sends a private message with the embed in a text format.",
	f = function(message, parameters)
		parameters = parameters and string.match(parameters, "%d+")

		if parameters then
			local msg = message.channel:getMessage(parameters)

			if msg then
				if msg.embed then
					local content = { }

					if msg.content and #msg.content > 3 then
						content[#content + 1] = "`" .. msg.content .. "`"
					end

					if msg.embed.title then
						content[#content + 1] = "**" .. msg.embed.title .. "**"
					end
					if msg.embed.description then
						content[#content + 1] = msg.embed.description
					end

					local footerText = msg.embed.footer and msg.embed.footer.text
					if footerText then
						content[#content + 1] = "`" .. footerText .. "`"
					end

					local len = #content
					content[len + (footerText and 0 or 1)] = (footerText and (content[len] .. " | ") or "") .. "`" .. os.date("%c", os.time(discordia.Date().fromISO(msg.timestamp):toTableUTC())) .. "`"

					local img = (msg.attachment and msg.attachment.url) or (msg.embed and msg.embed.image and msg.embed.image.url)
					message.author:send({
						content = string.sub(table.concat(content, "\n"), 1, 2000),
						embed = {
							image = (img and { url = img } or nil)
						}
					})
				else
					message.author:send(msg.content)
				end
				message:delete()
			end
		end
	end
}
