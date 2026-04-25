local config = require("config")

return function(ctx)
	local timer        = ctx.timer
	local color        = ctx.color
	local client       = ctx.client
	local channels     = ctx.channels
	local sendError    = ctx.sendError

	return {
		auth = config.permissions.is_mod,
		description = "Mutes a member.",
		f = function(message, parameters)
			local syntax = "Use `!mute @user time_in_minutes"

			if parameters and #parameters > 0 then
				local user, time = string.match(parameters, "<@!?(%d+)>[\n ]+(%d+)$")

				local member = user and message.guild:getMember(user)
				time = tonumber(time)

				if member and time then
					message:delete()

					member:addRole("565703024136421406")
					timer.setTimeout(time * 6e4, coroutine.wrap(function(member)
						member:removeRole("565703024136421406")
					end), member)

					local description = "<@" .. user .. "> has been muted for " .. time .. " minutes!"
					message:reply({
						embed = {
							color = color.moderation,
							title = ":alarm_clock: Moderation",
							description = description
						}
					})
					client:getChannel(channels["mod-logs"]):send({
						embed = {
							color = color.moderation,
							title = ":alarm_clock: Mute",
							description = description .. ("\n\nBy <@" .. message.member.id .. "> [" .. message.member.name .. "]"),
							timestamp = message.timestamp:gsub(" ", '')
						}
					})
				else
					sendError(message, "MUTE", "Invalid parameters.", syntax)
				end
			else
				sendError(message, "MUTE", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
