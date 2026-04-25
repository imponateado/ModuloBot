local config = require("config")

return function(ctx)
	local sendError    = ctx.sendError
	local quoteTargets = ctx.quoteTargets

	return {
		description = "Sets a USD → BRL target quote (quote notification)",
		auth = config.permissions.is_module,
		f = function(message, parameters)
			local target = tonumber(parameters)
			if not target then
				return sendError(
					message,
					"alvo",
					"Invalid target value.",
					"Usage: `!alvo <value>` (example: `!alvo 5.10`)"
				)
			end

			local userId = message.author.id
			local targetData = {
				userId = userId,
				target = target,
				createdAt = os.time()
			}

			local totalQuotes = #quoteTargets
			for quoteIndex = 1, totalQuotes do
				local quote = quoteTargets[quoteIndex]
				if quote.userId == userId and quote.target == target then
					return sendError(
						message,
						"alvo",
						"Target <" .. target .. "> is already set"
					)
				end
			end

			table.insert(quoteTargets, targetData)

			message:reply({
				embed = {
					title = "Target quote set!",
					description = "You will be notified when the USD → BRL quote reaches **" .. target .. "**",
					color = config.color.sys
				}
			})
		end
	}
end
