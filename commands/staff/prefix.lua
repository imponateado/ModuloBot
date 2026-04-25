local config = require("config")

return function(ctx)
	local modules = ctx.modules
	local save    = ctx.save
	local color   = ctx.color
	local sendError = ctx.sendError

	return {
		auth = config.permissions.is_owner,
		description = "Sets the prefix used for the commands of the #module category.",
		f = function(message, parameters, category)
			local syntax = "Use `!prefix prefix(1|2 characters)`."

			if parameters and #parameters > 0 and #parameters < 3 then
				modules[category].prefix = (parameters):gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")

				save("serverModulesData", modules, false, true)

				message:reply({
					embed = {
						color = color.sys,
						description = "The prefix in the module `" .. category .. "` was set to `" .. parameters .. "` successfully!"
					}
				})

				message:delete()
			else
				sendError(message, "PREFIX", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
