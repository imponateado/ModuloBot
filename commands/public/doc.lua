local config = require("config")
local http   = require("coro-http")

return function(ctx)
	local toDelete   = ctx.toDelete
	local sendError  = ctx.sendError
	local splitByChar = ctx.splitByChar
	local color      = ctx.color

	return {
		auth = config.permissions.public,
		description = "Gets information about a specific lua function.",
		f = function(message, parameters)
			if parameters and #parameters > 0 then
				local head, body = http.request("GET", "https://www.lua.org/manual/5.2/manual.html")

				if body then
					local syntax, description = string.match(body, "<a name=\"pdf%-" .. parameters .. "\"><code>(.-)</code></a></h3>[\n<p>]*(.-)<h[r2]>")

					if syntax then
						-- Normalizing tags
						syntax = string.gsub(syntax, "&middot;", ".")

						description = string.gsub(description, "<b>(.-)</b>", "**%1**")
						description = string.gsub(description, "<em>(.-)</em>", "_%1_")
						description = string.gsub(description, "<li>(.-)</li>", "\n- %1")

						description = string.gsub(description, "<code>(.-)</code>", "`%1`")
						description = string.gsub(description, "<pre>(.-)</pre>", function(code)
							return "```Lua¨" .. (string.gsub(string.gsub(code, "\n", "¨"), "¨	 ", "¨")) .. "```"
						end)

						description = string.gsub(description, "&sect;", '§')
						description = string.gsub(description, "&middot;", '.')
						description = string.gsub(description, "&nbsp;", ' ')
						description = string.gsub(description, "&gt;", '>')
						description = string.gsub(description, "&lt;", '<')
						description = string.gsub(description, "&pi;", 'π')

						description = string.gsub(description, "<a href=\"(#.-)\">(.-)</a>", "[%2](https://www.lua.org/manual/5.2/manual.html%1)")

						description = string.gsub(description, "\n", ' ')
						description = string.gsub(description, "¨", '\n')
						description = string.gsub(description, "<p>", "\n\n")

						description = string.gsub(description, "<(.-)>(.-)</%1>", "%2")

						local lines = splitByChar(description)

						local toRem = { }
						for i = 1, #lines do
							toRem[i] = message:reply({
								content = (i == 1 and "<@!" .. message.author.id .. ">" or nil),
								embed = {
									color = color.lua,
									title = (i == 1 and ("<:lua:468936022248390687> " .. syntax) or nil),
									description = lines[i],
									footer = { text = "Lua Documentation" }
								}
							})
						end
						toDelete[message.id] = toRem
					else
						toDelete[message.id] = message:reply({
							content = "<@!" .. message.author.id .. ">",
							embed = {
								color = color.lua,
								title = "<:lua:468936022248390687> Lua Documentation",
								description = "The function **" .. parameters .. "** was not found in the documentation."
							}
						})
					end
				else
					sendError(message, "DOC", "Fatal error")
				end
			else
				sendError(message, "DOC", "Invalid or missing parameters.", "Use `!doc function_name`.")
			end
		end
	}
end
