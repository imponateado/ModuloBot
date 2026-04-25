local config = require("config")
local discordia = require("discordia")

return function(ctx)
	local http = require("coro-http")
	local encodeUrl = ctx.encodeUrl
	local sendError = ctx.sendError
	local color = ctx.color
	local normalizeDiscriminator = ctx.normalizeDiscriminator
	local htmlToMarkdown = ctx.htmlToMarkdown
	local countryFlags = config.countryFlags
	local toDelete = ctx.toDelete

	return {
		auth = config.permissions.public,
		description = "Displays a forum message.",
		f = function(message, parameters)
			local syntax = "Use `!topic https://atelier801.com/topic`"

			if parameters and #parameters > 0 then
				parameters = string.gsub(parameters, "http:", "https:", 1)
				if not string.find(parameters, "https://atelier801%.com/topic") then
					return sendError(message, "TOPIC", "Invalid parameters.", "You must insert an atelier801's url as parameter.\n" .. syntax)
				end

				local code = string.match(parameters, "(%d+)$")
				if code then
					local head, body = http.request("GET", parameters, {
						{ "Accept-Language", "en-US,en;q=0.9" }
					})
					if body then
						-- Two matches because Lua sucks
						local commu, section, title = string.match(body, '<a href="section%?f=%d+&s=%d+" class=" ">.-<img src="/img/pays/(..)%.png".-/> (.-) +</a>.-class=" active">(.-) </a> +</li> +</ul> +<div')

						local avatarImg = '.-<img src="(http://avatars%.atelier801%.com/.-)"'
						local toMatch = { '<div id="m' .. code .. '"', '.-data%-afficher%-secondes="false">(%d+)</span>.-<img src="/img/pays/(..)%.png".-(%S+)<span class="nav%-header%-hashtag">(#%d+).-#' .. code .. '</a>.-<span class="coeur".-(%d+).-id="message_%d+">(.-)</div> +</div>' }

						local avatar, timestamp, playerCommu, playerName, playerDiscriminator, heart, msg = string.match(body, toMatch[1] .. avatarImg .. toMatch[2])
						if not avatar then
							avatar = "https://i.imgur.com/Lvlrhot.png"
							timestamp, playerCommu, playerName, playerDiscriminator, heart, msg = string.match(body, toMatch[1] .. toMatch[2])
						end

						if commu then
							local internationalFlag = "<:international:458411936892190720>"
							playerName = playerName .. playerDiscriminator

							msg = string.sub(htmlToMarkdown(msg), 1, 1000)
							local fields = {
								[1] = {
									name = "Author",
									value = (countryFlags[string.upper(playerCommu)] or internationalFlag) .. " [" .. normalizeDiscriminator(playerName) .. "](https://atelier801.com/profile?pr=" .. encodeUrl(playerName) .. ")",
									inline = true
								},
								[2] = {
									name = "Message #" .. code,
									value = msg .. (string.count(msg, "```") % 2 ~= 0 and "```" or ""),
									inline = false
								},
							}
							if heart ~= '0' then
								fields[3] = fields[2]
								fields[2] = {
									name = "Prestige",
									value = ":heart: " .. heart,
									inline = true
								}
							end

							toDelete[message.id] = message:reply({
								embed = {
									color = color.interaction,
									title = (countryFlags[string.upper(commu)] or internationalFlag) .. " " .. section .. " / " .. string.gsub(title, "<.->", ''),
									fields = fields,
									thumbnail = { url = avatar },
									timestamp = discordia.Date().fromMilliseconds(timestamp):toISO()
								}
							})
						end
					else
						return sendError(message, "TOPIC", "Internal Error", "Try again later.")
					end
				else
					return sendError(message, "TOPIC", "Message code not found.", "You must insert an atelier801's url as parameter, with section, page, topic and message. Example: `topic?f=0&t=000000&p=000#m0000`.\n" .. syntax)
				end
			else
				return sendError(message, "TOPIC", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
