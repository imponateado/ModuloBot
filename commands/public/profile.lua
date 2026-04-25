local config = require("config")

return function(ctx)
	local toDelete      = ctx.toDelete
	local sendError     = ctx.sendError
	local encodeUrl     = ctx.encodeUrl
	local concat        = ctx.concat
	local memberProfiles = ctx.memberProfiles
	local activeMembers = ctx.activeMembers
	local sortActivityTable = ctx.sortActivityTable
	local getRate       = ctx.getRate
	local getAge        = ctx.getAge
	local hasPermission = ctx.hasPermission
	local getRoleOrder  = ctx.getRoleOrder
	local permIcons     = ctx.permIcons
	local roles         = ctx.roles
	local roleFlags     = ctx.roleFlags
	local color         = ctx.color
	local permissions   = config.permissions

	return {
		auth = config.permissions.public,
		description = "Displays the profile of a member.",
		f = function(message, parameters)
			local found, p = true
			parameters = (parameters and (string.match(parameters, "<@!?(%d+)>") or string.lower(parameters)) or message.author.id)
			if not tonumber(parameters) then
				local p = string.lower(parameters)
				p = message.guild.members:find(function(member)
					return string.lower(member.name) == p
				end)

				if p then
					parameters = p.id
				else
					found = false
				end
			end

			local member
			if found then
				member = message.guild:getMember(parameters)
				if member then
					if not memberProfiles[member.id] then
						memberProfiles[member.id] = { }
					end
					p = {
						discord = member,
						data = memberProfiles[member.id]
					}
				end
			end
			if not found or not member then
				return sendError(message, "PROFILE", "User '" .. parameters .. "' not found.", "Use `!profile member_name/@member`")
			end

			local fields = { }

			local icon = " "
			fields[#fields + 1] = p.data.nickname and {
				name = "<:atelier:458403092417740824> TFM Nickname",
				value = "[" .. string.gsub(p.data.nickname, "#0000", '', 1) .. "](https://atelier801.com/profile?pr=" .. encodeUrl(p.data.nickname) .. ")",
				inline = true
			} or nil

			if p.discord.bot then
				icon = icon .. ":robot: "
			end
			if hasPermission(permissions.is_mod, p.discord) then
				icon = icon .. permIcons.is_mod
			end
			if hasPermission(permissions.has_power, p.discord) then
				if hasPermission(permissions.is_module, p.discord) then
					icon = icon .. permIcons.is_module
					if p.data[1] and table.count(p.data[1]) > 0 then
						fields[#fields + 1] = p.data[1].since and {
							name = ":calendar: MT Member since",
							value = p.data[1].since,
							inline = true
						} or nil

						fields[#fields + 1] = p.data[1].hosting and {
							name = ":house: Hosted modules",
							value = p.data[1].hosting,
							inline = true
						} or nil
					end
				end
				if hasPermission(permissions.is_dev, p.discord) then
					icon = icon .. permIcons.is_dev
					if p.data[2] and table.count(p.data[2]) > 0 then
						fields[#fields + 1] = p.data[2].modules and {
							name = ":gear: Modules",
							value = p.data[2].modules,
							inline = true
						} or nil

						fields[#fields + 1] = p.data[2].github and {
							name = "<:github:506473892689215518> GitHub",
							value = "[" .. p.data[2].github .. "](https://github.com/" .. p.data[2].github .. ")",
							inline = true
						} or nil
					end
				end
				if hasPermission(permissions.is_art, p.discord) then
					icon = icon .. permIcons.is_art
					if p.data[3] and table.count(p.data[3]) > 0 then
						fields[#fields + 1] = p.data[3].deviantart and {
							name = "<:deviantart:506475600416866324> DeviantArt",
							value = "[" .. p.data[3].deviantart .. "](https://www.deviantart.com/" .. p.data[3].deviantart .. ")",
							inline = true
						} or nil
					end
				end
				if hasPermission(permissions.is_trad, p.discord) then
					icon = icon .. permIcons.is_trad
					if p.data[4] and table.count(p.data[4]) > 0 then
						fields[#fields + 1] = p.data[4].trad and {
							name = ":globe_with_meridians: Modules Translated",
							value = p.data[4].trad,
							inline = true
						} or nil
					end
				end
				if hasPermission(permissions.is_math, p.discord) then
					icon = icon .. permIcons.is_math
					if p.data[9] and table.count(p.data[9]) > 0 then

					end
				end
				if hasPermission(permissions.is_writer, p.discord) then
					icon = icon .. permIcons.is_writer
					if p.data[11] and table.count(p.data[11]) > 0 then
						fields[#fields + 1] = p.data[11].wattpad and {
							name = "<:wattpad:517697014541058049> Wattpad",
							value = "[" .. p.data[11].wattpad .. "](https://www.wattpad.com/user/" .. p.data[11].wattpad .. ")",
							inline = true
						} or nil
					end
				end
			end

			if p.data.bday then
				fields[#fields + 1] = {
					name = ":tada: Birthday",
					value = p.data.bday .. (#p.data.bday == 10 and (" - " .. getAge(p.data.bday)) or ""),
					inline = true
				}
			end

			if p.data.insta then
				fields[#fields + 1] = {
					name = "<:insta:605096338140430396> Instagram",
					value = "[" .. string.gsub(p.data.insta, '_', "\\_") .. "](https://instagram.com/" .. p.data.insta .. "/)",
					inline = true
				}
			end

			if p.data.twt then
				fields[#fields + 1] = {
					name = "<:twitter:717130502447956059> Twitter",
					value = "[" .. string.gsub(p.data.twt, '_', "\\_") .. "](https://twitter.com/" .. p.data.twt .. "/)",
					inline = true
				}
			end

			if p.data.time then
				local code, index = string.match(p.data.time, "^(..)(.*)")
				code = string.upper(code)
				index = tonumber(index) or 1
				local timezone = ctx.commands["timezone"].f(message, code, nil, true)
				timezone = timezone[index]

				fields[#fields + 1] = {
					name = ":clock10: Timezone",
					value = "**" .. (timezone.zone or '?') .. "** @ **" .. (timezone.country or '?') .. "** (" .. code .. ")\n[GMT" .. (not timezone.utc and '' or ((timezone.utc > 0 and '+' or '') .. timezone.utc)) .. "] " .. os.date("%H:%M:%S `%d/%m/%Y`", os.time() + ((timezone.utc or 0) * 3600)),
					inline = true
				}
			end

			local activity = activeMembers[message.guild.id]
			if activity and activity[p.discord.id] then
				local cachedMembers, loggedMemberMessages = sortActivityTable(activity, function(id) return not message.guild:getMember(id) end)
				local _, o = table.find(cachedMembers, p.discord.id, 1)

				if o then
					fields[#fields + 1] = {
						name = (o > 3 and ":medal: " or ":" .. (o == 1 and "first" or o == 2 and "second" or "third") .. "_place: ") .. "Activity" .. (o > 3 and " [#" .. o .. "]" or ""),
						value = getRate(cachedMembers[o][2], loggedMemberMessages, 10) .. " [" .. cachedMembers[o][2] .. "]",
						inline = true
					}
				end
			end

			local memberRoles, len = getRoleOrder(member)

			local roleColor = member.guild.defaultRole.color
			if len > 0 then
				for i = 1, len do
					if memberRoles[i].color > 0 then
						roleColor = memberRoles[i].color
					end
				end
			end

			toDelete[message.id] = message:reply({
				embed = {
					color = (roleColor > 0 and roleColor or color.sys),

					thumbnail = { url = p.discord.avatarURL },

					title = (p.data.gender and (p.data.gender == 0 and "<:male:456193580155928588> " or "<:female:456193579308679169> ") or "") .. p.discord.name .. icon,

					description = (p.data.status and "`"" .. p.data.status .. ""` - " or "") .. "<@" .. p.discord.id .. ">",

					fields = fields
				}
			})
		end
	}
end
