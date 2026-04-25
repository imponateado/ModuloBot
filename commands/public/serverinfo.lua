local config = require("config")

return function(ctx)
	local toDelete       = ctx.toDelete
	local color          = ctx.color
	local reactions      = ctx.reactions
	local roles          = ctx.roles
	local commands       = ctx.commands
	local globalCommands = ctx.globalCommands

	return {
		auth = config.permissions.public,
		description = "Displays fun info about the server.",
		f = function(message)
			local members = message.guild.members

			local bots = members:count(function(member) return member.bot end)

			local tcommands = table.count(commands)
			local tgcommands = table.count(globalCommands)

			toDelete[message.id] = message:reply({
				content = "<@" .. message.author.id .. ">",
				embed = {
					color = color.interaction,

					author = {
						name = message.guild.name,
						icon_url = message.guild.iconURL
					},

					thumbnail = { url = "https://i.imgur.com/Lvlrhot.png" },

					fields = {
						[1] = {
							name = ":computer: ID",
							value = message.guild.id,
							inline = true
						},
						[2] = {
							name = ":crown: Owner",
							value = "<@" .. message.guild.ownerId .. ">",
							inline = true
						},
						[3] = {
							name = ":speech_balloon: Channels",
							value = ":pencil2: Text: " .. #message.guild.textChannels .. "\n:speaker: Voice: " .. #message.guild.voiceChannels .. "\n:card_box: Category: " .. #message.guild.categories,
							inline = true
						},
						[4] = {
							name = ":calendar: Created at",
							value = os.date("%Y-%m-%d %I:%M%p", message.guild.createdAt),
							inline = true
						},
						[5] = {
							name = ":necktie: Roles",
							value = #message.guild.roles,
							inline = true
						},
						[6] = {
							name = ":robot: Bots",
							value = bots,
							inline = true
						},
						[7] = {
							name = ":family_mmgb: Members",
							value = string.format("<:%s> Online: %s | <:%s> Away: %s | <:%s> Busy: %s | <:offline:456197711457419276> Offline: %s\n\n:raising_hand: **Total:** %s\n\n<:wheel:456198795768889344> **Tech Guru**: %s\n<:lua:468936022248390687> **Developers**: %s\n<:p5:468937377981923339> **Artists**: %s\n:earth_americas: **Translators**: %s\n:triangular_ruler: **Mathematicians**: %s\n:pencil: **Writers**: %s", reactions.online, members:count(function(member)
								return member.status == "online"
							end), reactions.idle, members:count(function(member)
								return member.status == "idle"
							end), reactions.dnd, members:count(function(member)
								return member.status == "dnd"
							end), members:count(function(member)
								return member.status == "offline"
							end), message.guild.totalMemberCount - bots, members:count(function(member)
								return member:hasRole(roles["tech guru"])
							end), members:count(function(member)
								return member:hasRole(roles["developer"])
							end), message.guild.members:count(function(member)
								return member:hasRole(roles["artist"])
							end), members:count(function(member)
								return member:hasRole(roles["translator"])
							end), members:count(function(member)
								return member:hasRole(roles["mathematician"])
							end), members:count(function(member)
								return member:hasRole(roles["writer"])
							end)),
							inline = false
						},
						[8] = {
							name = ":exclamation: Commands",
							value = "**Total**: " .. (tcommands + tgcommands) .. "\n\n**Bot commands**: " .. tcommands .. "\n**Global Commands**: " .. tgcommands,
							inline = false
						},
					},
				}
			})
		end
	}
end
