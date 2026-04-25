local config = require("config")

return function(ctx)
	local sendError      = ctx.sendError
	local concat         = ctx.concat
	local encodeUrl      = ctx.encodeUrl
	local profileStruct  = ctx.profileStruct
	local roles          = ctx.roles
	local roleFlags      = ctx.roleFlags
	local memberProfiles = ctx.memberProfiles
	local color          = ctx.color

	return {
		auth = config.permissions.public,
		description = "Edits the data of your profile.",
		f = function(message, parameters)
			local syntax = "Use `!edit field value` or `!edit field` to remove the value.\nThe available fields are:\n" .. concat(profileStruct, '', function(index, value)
				if not value.index then
					return "**" .. index .. "** - " .. value.description .. "\n"
				else
					if message.member:hasRole(roles[roleFlags[value.index]]) then
						return "**" .. index .. "** - " .. value.description .. "\n"
					end
					return ''
				end
			end)

			if parameters and #parameters > 0 then
				local field, value = string.match(parameters, "^(%S+)[\n ]+(.+)$")

				if field and profileStruct[field] then
					if profileStruct[field].index and not message.member:hasRole(roles[roleFlags[profileStruct[field].index]]) then
						return sendError(message, "EDIT", "Field authorization denied.", "You can not update this field because you do not have the role `" .. string.upper(roleFlags[profileStruct[field].index]) .. "`.")
					end

					local isNumber = profileStruct[field].type == "number"
					if isNumber then
						value = tonumber(value)
						if not value then
							return sendError(message, "EDIT", "The value must be a number.")
						end
						value = math.floor(value)
					end

					if profileStruct[field].min and (isNumber and value or #value) < profileStruct[field].min then
						return sendError(message, "EDIT", "Invalid value.", "The value or value length must be greater than or equal to **" .. profileStruct[field].min .. "**.")
					end
					if profileStruct[field].max and (isNumber and value or #value) > profileStruct[field].max then
						return sendError(message, "EDIT", "Invalid value.", "The value or value length must be less than or equal to **" .. profileStruct[field].max .. "**.")
					end

					if profileStruct[field].format then
						local ok = true
						if type(profileStruct[field].format) == "table" then
							for k, v in next, profileStruct[field].format do
								if not string.format(value, v) then
									ok = false
									break
								end
							end
						else
							ok = not not string.format(value, profileStruct[field].format)
						end

						if not ok then
							return sendError(message, "EDIT", "Invalid value.", "The format of this field requires another value format.")
						end
					end

					if profileStruct[field].valid then
						local success, fix = profileStruct[field].valid(value, message)
						if not success then
							return sendError(message, "EDIT", "Invalid value.", "This value is invalid or does not exist.")
						elseif fix then
							value = fix
						end
					end

					if not memberProfiles[message.author.id] then
						memberProfiles[message.author.id] = { }
					end
					local old_value
					if profileStruct[field].index then
						if not memberProfiles[message.author.id][profileStruct[field].index] then
							memberProfiles[message.author.id][profileStruct[field].index] = { }
						end
						old_value = memberProfiles[message.author.id][profileStruct[field].index][field]
						memberProfiles[message.author.id][profileStruct[field].index][field] = value
					else
						old_value = memberProfiles[message.author.id][field]
						memberProfiles[message.author.id][field] = value
					end

					message.author:send({
						embed = {
							color = color.interaction,
							title = "Profile Data Updated!",
							description = "You updated the field `" .. field .. "` with the value `" .. value .. "`" .. (old_value and ("\nIts value was, previously, `" .. old_value .. "`") or "")
						}
					})
					message:delete()
				else
					if profileStruct[parameters] then
						local old_value
						if profileStruct[parameters].index then
							old_value = memberProfiles[message.author.id][profileStruct[parameters].index]
							if old_value then
								old_value = old_value[parameters]
							end

							memberProfiles[message.author.id][profileStruct[parameters].index][parameters] = nil
						else
							old_value = memberProfiles[message.author.id][parameters]
							memberProfiles[message.author.id][parameters] = nil
						end

						message.author:send({
							embed = {
								color = color.interaction,
								title = "Profile Data Updated!",
								description = "You removed the field `" .. parameters .. "`" .. (old_value and (" that had the value `" .. old_value .. "`") or "")
							}
						})
						message:delete()
					else
						sendError(message, "EDIT", "Invalid field.", syntax)
					end
				end
			else
				sendError(message, "EDIT", "Invalid or missing parameters.", syntax)
			end
		end
	}
end
