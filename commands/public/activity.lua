local config = require("config")

return function(ctx)
	local client         = ctx.client
	local toDelete       = ctx.toDelete
	local concat         = ctx.concat
	local sortActivityTable = ctx.sortActivityTable
	local activeChannels = ctx.activeChannels
	local activeMembers  = ctx.activeMembers
	local getRate        = ctx.getRate
	local color          = ctx.color

	return {
		auth = config.permissions.public,
		description = "Displays the channels' and members' activity.",
		f = function(message, _, __, ___, get)
			local cachedChannels, loggedMessages = sortActivityTable(activeChannels[message.guild.id], function(id) return not client:getChannel(id) end)
			local cachedMembers, loggedMemberMessages = sortActivityTable(activeMembers[message.guild.id], function(id) return not message.guild:getMember(id) end)

			local members = concat(cachedMembers, "\n", function(index, value)
				local member = message.guild:getMember(value[1])
				return (index > 3 and ":medal: " or ":" .. (index == 1 and "first" or index == 2 and "second" or "third") .. "_place: ") .. "<@" .. member.id .. "> `" .. member.name .. (get and "` " or "`\n") .. getRate(value[2], loggedMemberMessages, 30) .. " [" .. value[2] .. "]"
			end, 1, (get and 3 or 10))

			local achannels = concat(cachedChannels, "\n", function(index, value)
				local channel = client:getChannel(value[1])
				return (index > 3 and ":medal: " or ":" .. (index == 1 and "first" or index == 2 and "second" or "third") .. "_place: ") .. (channel.category and (channel.category.name .. ".<#") or "<#") .. channel.id .. (get and "> " or ">\n") .. getRate(value[2], loggedMessages, 30) .. " [" .. value[2] .. "]"
			end, 1, (get and 3 or 5))

			if get then
				return members, achannels
			end

			toDelete[message.id] = message:reply({
				content = "<@" .. message.author.id .. ">",
				embed = {
					color = color.interaction,

					fields = {
						[1] = {
							name = ":bar_chart: " .. os.date("%B") .. "'s active members",
							value = members,
							inline = false
						},
						[2] = {
							name = ":chart_with_upwards_trend: " .. os.date("%B") .. "'s active channels",
							value = achannels,
							inline = false
						}
					}
				}
			})
		end
	}
end
