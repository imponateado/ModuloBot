local config = require("config")

return function(ctx)
	local save           = ctx.save
	local activeChannels = ctx.activeChannels
	local activeMembers  = ctx.activeMembers
	local memberProfiles = ctx.memberProfiles
	local cmdData        = ctx.cmdData
	local serverActivity = ctx.serverActivity
	local globalCommands = ctx.globalCommands
	local client         = ctx.client
	local logColor       = config.logColor

	return {
		description = "Ends the bot process.",
		f = function(message)
			--save("serverModulesData", modules, false, true)

			if table.count(activeChannels) > 0 then
				save("serverActiveChannels", activeChannels)
			end
			if table.count(activeMembers) > 0 then
				save("serverActiveMembers", activeMembers)
			end
			if table.count(memberProfiles) > 0 then
				save("serverMemberProfiles", memberProfiles)
			end
			if cmdData and table.count(cmdData) > 0 then
				save("serverCommandsData", cmdData)
			end
			if serverActivity and table.count(serverActivity) > 0 then
				save("serverActivity", serverActivity)
			end
			if table.count(globalCommands) > 0 then
				save("serverGlobalCommands", globalCommands)
			end

			message:delete()
			print(os.date("%Y-%m-%d %H:%M:%S") .. " | \27[1;" .. logColor.red .. "m[INFO]\27[0m\t| " .. "Disconnected from '" .. client.user.name .. "'")
			os.exit()
		end
	}
end
