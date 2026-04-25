local config = require("config")
local http   = require("coro-http")

return function(ctx)
	return {
		auth = config.permissions.public,
		description = "Displays the timezone of a country.",
		f = function(message, parameters, _, toReturn)
			if parameters and #parameters == 2 then
				parameters = string.upper(parameters)

				local head, body = http.request("GET", "https://pastebin.com/raw/di8TMeeG")
				if body then
					body = load("return " .. body)()
					if not body[parameters] then
						return ctx.sendError(message, "TIMEZONE", "Country code not found", "Couldn't find '" .. parameters .. "'")
					end

					if toReturn then
						return body[parameters]
					end

					ctx.toDelete[message.id] = message:reply({
						embed = {
							color = config.color.sys,
							title = body[parameters][1].country,
							description = ctx.concat(body[parameters], "\n", function(index, value)
								return index .. " - **" .. value.zone .. "** - " .. os.date("%H:%M:%S `%d/%m/%Y`", os.time() + ((value.utc or 0) * 3600))
							end, nil, nil, ipairs)
						}
					})
				end
			else
				ctx.sendError(message, "TIMEZONE", "Invalid or missing parameters.", "Use `!timezone country_code`.")
			end
		end
	}
end
