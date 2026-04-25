local config = require("config")
local permissions = config.permissions
local roles       = config.roles
local authIds     = config.authIds

local _modRole

local getRoleOrder = function(member)
	local r = member.roles:toArray("position")
	return r, #r
end

local M = {}

M.setModRole = function(role)
	_modRole = role
end

--[[Doc
	"Verifies if an user has permission over a specific permission flag."
	@permission int
	@member Discordia.Guild.Member
	@message Discordia.Message*
	>boolean|nil
]]
M.hasPermission = function(permission, member, message)
	local auth = false
	if not permission or not member then return auth end

	if permission == permissions.public then
		return true
	elseif permission == permissions.has_power then
		local memberRoles, len = getRoleOrder(member)
		if len == 0 then
			return false
		end

		for i = 1, len do
			if roles[memberRoles[i].id] then
				return true
			end
		end
		return false
	elseif permission == permissions.is_module then
		return member:hasRole(roles["tech guru"]) or (member.guild.id == "897638804750471169" and
			member:hasRole("897640614387134534"))
	elseif permission == permissions.is_dev then
		return member:hasRole(roles["developer"])
	elseif permission == permissions.is_art then
		return member:hasRole(roles["artist"])
	--elseif permission == permissions.is_map then
	--	return member:hasRole(roles["mapper"])
	elseif permission == permissions.is_trad then
		return member:hasRole(roles["translator"])
	--elseif permission == permissions.is_fash then
	--	return member:hasRole(roles["fashionista"])
	--elseif permission == permissions.is_evt then
	--	return member:hasRole(roles["event manager"])
	elseif permission == permissions.is_writer then
		return member:hasRole(roles["writer"])
	elseif permission == permissions.is_math then
		return member:hasRole(roles["mathematician"])
	--elseif permission == permissions.is_fc then
	--	return member:hasRole(roles["funcorp"])
	--elseif permission == permissions.is_shades then
	--	return member:hasRole(roles["shades helper"])
	elseif permission == permissions.is_mod then
		return member:hasRole(_modRole.id)
	--[[elseif permission == permissions.is_staff or permission == permissions.is_owner then
		if not message or not message.channel then return auth end

		local module = message.channel.category and string.lower(message.channel.category.name) or nil
		if not module then return auth end

		local c = (permission == permissions.is_owner and "★ " or "[★⚙]+ ")

		return not not member.roles:find(function(role)
			return string.find(string.lower(role.name), "^" .. c .. module .. "$")
		end)]]
	elseif permission == permissions.is_admin then
		return authIds[member.id]
	end
end

return M
