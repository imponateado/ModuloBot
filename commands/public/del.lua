local config = require("config")

return function(ctx)
	local sendError = ctx.sendError

	return {
		description = "Delete messages.",
		f = function(message, parameters)
			local syntax = "Use `!del from_message_id [total_maps(1:100)]`."

			if parameters and #parameters > 0 then
				local messageId = string.match(parameters, "^(%d+)")
				local limit = string.match(parameters, "[\n ]+(%d+)$")
				if limit then limit = math.clamp(limit, 1, 100) end

				if message.channel:getMessage(messageId) then
					message.channel:bulkDelete(message.channel:getMessagesAfter(messageId, limit))
				else
					sendError(message, "DEL", "Message id not found.", syntax)
				end
			else
				sendError(message, "DEL", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
