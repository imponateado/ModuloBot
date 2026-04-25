local config       = require("config")
local http         = require("coro-http")
local imageHandler = require("Content/imageHandler")

return function(ctx)
	return {
		auth = config.permissions.public,
		description = "Displays a mathematical formula using LaTex syntax.",
		f = function(message, parameters)
			if parameters and #parameters > 0 then
				local head, body = http.request("POST", "https://quicklatex.com/latex3.f", nil,
					"formula=" .. ctx.encodeUrl("\\displaystyle " .. parameters) ..
					"&fsize=21px&fcolor=c2c2c2&out=1&preamble=\\usepackage{amsmath}\n\\usepackage{amsfonts}\n\\usepackage{amssymb}")
				body = string.match(body, "(http%S+)")
				if body then
					body = string.gsub(body, "http:", "https:", 1)
					ctx.toDelete[message.id] = message:reply({ file = tostring(imageHandler.fromUrl(body)) })
				else
					ctx.sendError(message, "TEX", "Internal Error.", "Try again later.")
				end
			else
				ctx.sendError(message, "TEX", "Invalid or missing parameters.", "Use `!tex latex_formula`.")
			end
		end
	}
end
