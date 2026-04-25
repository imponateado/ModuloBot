local config = require("config")

return function(ctx)
	return {
		auth = config.permissions.public,
		description = "Displays a color.",
		f = function(message, parameters)
			if parameters and #parameters > 0 then
				local hex = string.match(parameters, "^0x(%x+)$") or string.match(parameters, "^#?(%x+)$")
				if tonumber(hex) and #hex > 6 then
					hex = nil
				end
				if not hex then
					if string.find(parameters, ',') then
						local m = "(%d+), *(%d+), *(%d+)"
						local r, g, b = string.match(parameters, "rgb%(" .. m .. "%)")
						if not r then
							r, g, b = string.match(parameters, m)
						end
						r, g, b = tonumber(r), tonumber(g), tonumber(b)

						parameters = nil
						if r then
							r, g, b = math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255)
							parameters = string.format("%02x%02x%02x", r, g, b)
						end
					else
						parameters = string.match(parameters, "^(%d+)$")
						if parameters then
							parameters = string.format("%06x", parameters)
						end
					end
				else
					parameters = hex
				end

				if not parameters then
					return ctx.sendError(message, "COLOR", "Invalid hexadecimal or RGB code.")
				end

				local dec = tonumber(parameters, 16)
				local image = "https://www.colorhexa.com/" .. string.format("%06x", dec) .. ".png"

				ctx.toDelete[message.id] = message:reply({
					embed = {
						color = dec,
						author = {
							name = "#" .. string.upper(parameters) .. " <" .. dec .. ">",
							icon_url = image
						},
						image = { url = image }
					}
				})
			else
				ctx.sendError(message, "COLOR", "Invalid or missing parameters.", "Use `!color #hex_code` or `!color rgb(r, g, b)`.")
			end
		end
	}
end
