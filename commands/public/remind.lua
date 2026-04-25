local config = require("config")

return function(ctx)
	local sendError   = ctx.sendError
	local setReminder = ctx.setReminder
	local authIds     = ctx.authIds
	local timer       = ctx.timer

	return {
		auth = config.permissions.public,
		description = "Sets a reminder. Bot will remind you.",
		f = function(message, parameters)
			if not (parameters and #parameters > 2) then
				return sendError(message, "REMIND", "Invalid or missing parameters.", "Use `!remind time_and_order (ms, s, m, h, d) text`.")
			end

			local timePart, text = string.match(parameters, "^([^%s]+)%s+(.+)$")
			if not timePart or not text or text == '' then
				return
			end

			local orders = {
				ms = 1,
				s  = 1000,
				m  = 60000,
				h  = 3600000,
				d  = 86400000
			}

			local totalMilliseconds = 0

			for number, order in string.gmatch(timePart, "(%d+)(%a+)") do
				local multiplier = orders[order]
				if not multiplier then
					return sendError(message, "REMIND", "Invalid order parameter.", "The available orders are: ms, s, m, h, d.")
				end

				totalMilliseconds = totalMilliseconds + tonumber(number) * multiplier
			end

			if totalMilliseconds == 0 then
				return sendError(message, "REMIND", "Invalid or missing parameters.", "Use `!remind time_and_order (ms, s, m, h, d) text`.")
			end

			local maxDays = authIds[message.author.id] and 90 or 7
			totalMilliseconds = math.clamp(totalMilliseconds, orders.m * 1, orders.d * maxDays)

			local reminder = {
				time = totalMilliseconds,
				text = text,
				userId = message.author.id,
				triggerTime = os.time() * 1000,
			}

			setReminder(reminder, true)

			local ok = message:reply(":thumbsup:")
			timer.setTimeout(1e4, coroutine.wrap(function(ok)
				ok:delete()
			end), ok)
			message:delete()
		end
	}
end
