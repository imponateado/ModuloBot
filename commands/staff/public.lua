local config = require("config")

return function(ctx)
	local modules = ctx.modules
	local client  = ctx.client
	local color   = ctx.color
	local reactions = ctx.reactions
	local channels = ctx.channels
	local sendError = ctx.sendError
	local save = ctx.save
	local setPermissions = ctx.setPermissions
	local permissionOverwrites = ctx.permissionOverwrites
	local MOD_ROLE = ctx.MOD_ROLE

	return {
		auth = config.permissions.is_owner,
		description = "Creates a public role and a public channel for the #module.",
		f = function(message, parameters, category)
			local edition = modules[category].hasPublicChannel

			local syntax = "Use `!public module_description`."

			if parameters and #parameters > 0 then
				if not edition then
					local public_role = message.guild:createRole(category)

					local announcements_channel = message.channel.category.textChannels:find(function(c)
						return c.name == "announcements"
					end)

					if announcements_channel then
						setPermissions(announcements_channel:getPermissionOverwriteFor(public_role), permissionOverwrites.announcements.public.allowed, permissionOverwrites.announcements.public.denied)
					end

					local public_channel = message.guild:createTextChannel("chat")
					public_channel:setCategory(message.channel.category.id)

					public_channel:getPermissionOverwriteFor(message.guild.defaultRole):denyPermissions(table.unpack(permissionOverwrites.module.everyone.denied))
					public_channel:getPermissionOverwriteFor(public_role):allowPermissions(table.unpack(permissionOverwrites.public.public.allowed))
					-- Muted
					public_channel:getPermissionOverwriteFor(message.guild:getRole("565703024136421406")):denyPermissions(table.unpack(permissionOverwrites.muted.denied))
					-- Mod
					public_channel:getPermissionOverwriteFor(MOD_ROLE):allowPermissions(table.unpack(permissionOverwrites.mod.allowed))

					local staff_roles = { }
					message.guild.roles:find(function(role)
						if role.name == "★ " .. category or role.name == "⚙ " .. category then
							staff_roles[string.sub(role.name, 1, 1) == "⚙" and "staff" or "owner"] = role
						end
						return false
					end)

					for k, v in next, staff_roles do
						setPermissions(public_channel:getPermissionOverwriteFor(v), permissionOverwrites.module[k].allowed, permissionOverwrites.module[k].denied)
					end

					modules[category].hasPublicChannel = true

					save("serverModulesData", modules, false, true)

					message:reply({
						embed = {
							color = color.sys,
							title = "<:wheel:456198795768889344> " .. category,
							description = "The module **" .. category .. "** has now a public channel!"
						}
					})

					local m_channel = client:getChannel(channels["modules"])

					m_channel:send({
						embed = {
							color = color.interaction,
							title = category,
							description = parameters,
							footer = { text = "React to access the public channel of this module" }
						}
					}):addReaction(reactions.hand)
				else
					local modified = false
					for msg in client:getChannel(channels["modules"]):getMessages():iter() do
						if msg.embed.title == category then
							msg.embed.description = parameters

							msg:setEmbed(msg.embed)

							modified = true
							break
						end
					end

					if modified then
						message:reply({
							content = "<@!" .. message.author.id .. ">",
							embed = {
								color = color.sys,
								title = "<:wheel:456198795768889344> " .. category,
								description = "Description edited!"
							}
						})
					else
						sendError(message, "PUBLIC", "Something went wrong during the public message edition. Contact <@" .. client.owner.id .. ">.")
					end
				end

				message:delete()
			else
				if edition then
					sendError(message, "PUBLIC", "The module '" .. category .. "' has already a public channel.")
				else
					sendError(message, "PUBLIC", "Invalid or missing parameters.", syntax)
				end
			end
		end
	}
end
