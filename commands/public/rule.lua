local config = require("config")
local http   = require("coro-http")

return function(ctx)
	return {
		auth = config.permissions.public,
		description = "Quotes a server rule.",
		f = function(message, parameters)
			-- Command by Tocutoeltuco
			local sec, rule = string.match(tostring(parameters), "\xC2?\xA7?(%d-)%.(%d-%.?%d*)")
			if not parameters or not sec then
				return ctx.sendError(message, "RULE", "Invalid or missing parameters", "Use `!rule section.rule` or `!rule section.rule.subrule`.")
			end

			local rules = ctx.client:getChannel("491723107728621578"):getMessage("575849365608857600").content .. "\n\n"
			local sec_name, content = string.match(rules, "§" .. sec .. " __(.-)__ %- [`*]+[^`]+[`*\n]+(.-)\n\n")

			if not sec_name then
				return ctx.sendError(message, "RULE", "Invalid section", "The section **" .. sec .. "** does not exist.")
			end

			local _rule_content = string.match(content, rule .. "%) (.+)")

			if not _rule_content then
				return ctx.sendError(message, "RULE", "Invalid rule", "The rule **" .. sec .. "." .. rule .. "** does not exist.")
			end

			local rule_content = string.match(_rule_content, "(.+)[\n ]-" .. (math.floor(tonumber(rule)) + 1) .. "%)")

			ctx.toDelete[message.id] = message:reply({
				embed = {
					color = config.color.moderation,
					title = "<:rule:586043498537418757> " .. sec_name .. " - §" .. sec .. "." .. rule,
					description = (rule_content or _rule_content)
				}
			})
		end
	}
end
