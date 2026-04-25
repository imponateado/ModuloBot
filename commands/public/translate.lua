local config = require("config")
local http   = require("coro-http")
local json   = require("json")

return function(ctx)
	return {
		auth = config.permissions.public,
		description = "Translates a sentence using Google Translate. Professional translations: <@&494665355327832064>",
		f = function(message, parameters)
			local syntax = "Use `!translate [from_language-]to_language sentence`."

			if parameters and #parameters > 0 then
				local language, content = string.match(parameters, "(%S+)[ \n]+(.+)$")
				if language and content and #content > 0 then
					if #content == 18 and tonumber(content) then
						local msgContent = message.channel:getMessage(content)
						if msgContent then
							msgContent = msgContent.content or (msgContent.embed and msgContent.embed.description)
							content = (msgContent and (string.gsub(msgContent, '`', '')) or content)
						end
					end

					language = string.lower(language)
					local sourceLanguage, targetLanguage = string.match(language, "^(..)[%-~]>?(..)$")
					if not sourceLanguage then
						sourceLanguage = "auto"
						targetLanguage = language
					end

					content = string.sub(content, 1, 250)
					local head, body = http.request("GET",
						"https://translate.googleapis.com/translate_a/single?client=gtx&sl=" .. sourceLanguage ..
						"&tl=" .. targetLanguage .. "&dt=t&q=" .. ctx.encodeUrl(content),
						{ { "User-Agent", "Mozilla/5.0" } })
					body = json.decode(tostring(body))

					if body and #body > 0 then
						sourceLanguage = string.upper((sourceLanguage == "auto" and tostring(body[3]) or sourceLanguage))
						targetLanguage = string.upper(targetLanguage)

						sourceLanguage = config.countryFlags_Aliases[sourceLanguage] or sourceLanguage
						targetLanguage = config.countryFlags_Aliases[targetLanguage] or targetLanguage

						ctx.toDelete[message.id] = message:reply({
							embed = {
								color = config.color.interaction,
								title = ":earth_americas: Quick Translation",
								description =
									(config.countryFlags[config.countryFlags_Aliases[sourceLanguage] or sourceLanguage] or "") ..
									"@**" .. sourceLanguage .. "**\n```\n" .. content .. "```" ..
									(config.countryFlags[config.countryFlags_Aliases[targetLanguage] or targetLanguage] or "") ..
									"@**" .. string.upper(targetLanguage) .. "**\n```\n" ..
									ctx.concat(body[1], ' ', function(index, value)
										return value[1]
									end) .. "```"
							}
						})
					else
						ctx.sendError(message, "TRANSLATE", "Internal Error.", "Couldn't translate ```\n" .. parameters .. "```")
					end
				else
					ctx.sendError(message, "TRANSLATE", "Invalid parameters.", syntax)
				end
			else
				ctx.sendError(message, "TRANSLATE", "Missing parameters.", syntax)
			end
		end
	}
end
