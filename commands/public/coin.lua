local config = require("config")

return function(ctx)
	return {
		auth = config.permissions.public,
		description = "Converts a value between currencies.",
		f = function(message, parameters)
			if ctx.currency.USD then
				local syntax = "Use `!coin to_currency from_currency amount`."

				if parameters and #parameters > 2 then
					local available_currencies = "The available currencies are:\n```\n" .. ctx.concat(ctx.currency, ", ", tostring, nil, nil, ctx.pairsByIndexes) .. "```"

					local from, to, amount

					from = string.match(parameters, "^...")
					if from then
						from = string.upper(from)
						if not ctx.currency[from] then
							return ctx.sendError(message, "COIN", ":fire: | Invalid from_currency '" .. from .. "'!", available_currencies)
						end
					end

					to = string.match(parameters, "[ \n]+(...)[ \n]*")
					if to then
						to = string.upper(to)
						if not ctx.currency[to] then
							return ctx.sendError(message, "COIN", ":fire: | Invalid to_currency '" .. to .. "'!", available_currencies)
						end
					else
						to = from
						from = nil
					end

					local randomEmoji = ":" .. table.random({ "money_mouth", "money_with_wings", "moneybag" }) .. ":"

					amount = string.match(parameters, "(%d+[%.,]?%d*)$")
					amount = amount and tonumber((string.gsub(amount, ',', '.', 1))) or 1
					amount = (amount * ctx.currency[to]) / (ctx.currency[from] or ctx.currency.USD)

					ctx.toDelete[message.id] = message:reply({
						content = "<@!" .. message.author.id .. ">",
						embed = {
							color = config.color.sys,
							title = randomEmoji .. " " .. (from or "USD") .. " -> " .. to,
							description = string.format("¤ %.2f", amount)
						}
					})
				else
					ctx.sendError(message, "COIN", "Invalid or missing parameters.", syntax)
				end
			else
				ctx.sendError(message, "COIN", "Currency table is loading. Try again later.")
			end
		end
	}
end
