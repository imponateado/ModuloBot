local json = require("json")

local db_url      = "http://127.0.0.1/"--"https://d-modulo-b-2.000webhostapp.com/"
local db_path     = ("C:/Users/tai/Desktop/discord/server/discorddb.000webhostapp.com" or "../db") .. "/public_html/files/"
local backup_path = ("C:/Users/tai/Desktop/discord/server/discorddb.000webhostapp.com" or "../db") .. "/public_html/backups/"

local M = {}

M.db_url      = db_url
M.db_path     = db_path
M.backup_path = backup_path

--[[Doc
	~
	"Gets a database content."
	@fileName string
	@raw boolean*
	>table|string
]]
M.getDatabase = function(fileName, raw, decodeBase64, ignoreDbErr)
	local file = io.open(db_path .. fileName .. ".json", "r")
	local content = file:read("*all")
	file:close()

	if not raw then
		content = json.decode(content)
	end

	if not content then
		error("Database issue -> " .. tostring(fileName))
	end

	return content
end

--[[Doc
	~
	"Saves a database."
	@fileName string
	@db table|string
	>boolean
]]
M.save = function(fileName, db, raw, encodeBase64)
	db = (raw and tostring(db) or json.encode(db))

	local file = io.open(db_path .. fileName .. ".json", "w+")
	file:write(db)
	file:flush()
	file:close()

	return true
end

M.backupFunction = function(src_folder, dest_folder)
	os.execute(string.format('mkdir "%s" 2>nul', dest_folder))
	local command = string.format(
		'robocopy "%s" "%s" /E /R:0 /W:0 /NFL /NDL',
		src_folder,
		dest_folder
	)
	os.execute(command)
end

M.TRY_REQUEST = function(db, arg1, arg2)
	local tentatives, content = 0
	repeat
		tentatives = tentatives + 1
		content = M.getDatabase(db, arg1, arg2, true)
	until content or tentatives > 10

	if not content then
		os.execute("luvit bot.lua")
		error("Database issue -> " .. db)
	end

	return content
end

return M
