local discordia = require("discordia")
discordia.extensions()

local authIds = {
	['285878295759814656'] = true
}

local channels = {
	["modules"] = "462295886857502730",
	["logs"] = "465639994690895896",
	["commu"] = "494667707510161418",
	["image"] = "462279141551636500",
	["map"] = "462279117866401792",
	["bridge"] = "499635964503785533",
	["flood"] = "465583146071490560",
	["guild"] = "462275923354451970",
	["report"] = "510448208800120842",
	["chat-log"] = "520231441985175572",
	["role-color"] = "530752494717108224",
	["top-activity"] = "530793741909491753",
	["priv-channels"] = "543094720382107659",
	["suggestions"] = "582605483836440606",
	["mod-logs"] = "586271889467506727",
	["region"] = "585174371774103582",
	["code-test"] = "474253217421721600",
	["polls"] = "595364384566673413",
	["role-log"] = "598894097419337755",
	["greetings"] = "598898246500483072",
	["breach"] = "718659508980809758",
	["games"] = "574279126073212928",
}

local botIds = {
	["moon"] = "484182969926418434",
}

local categories = {
	["467791436163842048"] = true, -- mt
	["462335892162478080"] = true, -- dev
	["462336028233957396"] = true, -- art
	["462336076476841986"] = true, -- trad
	["494665803107401748"] = true, -- map
	["465632638284201984"] = true, -- evt
	["481191678410227732"] = true, -- shelper
	["514914341380816906"] = true, -- fc
	["514914924825411586"] = true, -- math
	["526829154650554368"] = true, -- fashion
	["544935544975786014"] = true  -- writer
}

local nickList = {
	["mt"] = "560458100885291038",
	["td"] = "569606722059108392",
	["sh"] = "544936174544748587",
	["fc"] = "556869027893477376",
}

local color = {
	atelier801 = 0x2E565F,
	err        = 0xE74C3C,
	interaction = 0x7DC5B6,
	lua_err    = 0xC45273,
	sys        = 0x36393F,
	lua        = 0x272792,
	moderation = 0x9C3AAF
}

local reactions = {
	p41       = "p41:463508055577985024",
	camera    = "\xF0\x9F\x93\xB7",
	x         = "\xE2\x9D\x8C",
	hand      = "\xF0\x9F\x99\x8B",
	bomb      = "\xF0\x9F\x92\xA3",
	boot      = "\xF0\x9F\x91\xA2",
	wave      = "\xF0\x9F\x91\x8B",
	star      = "\xE2\xAD\x90",
	skull     = "\xF0\x9F\x92\x80",
	bug       = "\xF0\x9F\x90\x9B",
	eyes2     = "eyes2:499367166299340820",
	online    = "online:456197711356755980",
	idle      = "idle:456197711830581249",
	dnd       = "dnd:456197711251636235",
	offline   = "offline:456197711457419276",
	p5        = "p5:468937377981923339",
	yes       = "\xE2\x9C\x85",
	arrowUp   = "\xE2\x8F\xAB",
	thumbsup  = "\xF0\x9F\x91\x8D",
	thumbsdown = "\xF0\x9F\x91\x8E"
}

local countryFlags = {
	AR = "\xF0\x9F\x87\xB8\xF0\x9F\x87\xA6",
	BR = "\xF0\x9F\x87\xA7\xF0\x9F\x87\xB7",
	BG = "\xF0\x9F\x87\xA7\xF0\x9F\x87\xAC",
	CN = "\xF0\x9F\x87\xA8\xF0\x9F\x87\xB3",
	CZ = "\xF0\x9F\x87\xA8\xF0\x9F\x87\xBF",
	DE = "\xF0\x9F\x87\xA9\xF0\x9F\x87\xAA",
	EE = "\xF0\x9F\x87\xAA\xF0\x9F\x87\xAA",
	EN = "\xF0\x9F\x87\xAC\xF0\x9F\x87\xA7",
	ES = "\xF0\x9F\x87\xAA\xF0\x9F\x87\xB8",
	FI = "\xF0\x9F\x87\xAB\xF0\x9F\x87\xAE",
	FR = "\xF0\x9F\x87\xAB\xF0\x9F\x87\xB7",
	GR = "\xF0\x9F\x87\xAC\xF0\x9F\x87\xB7",
	HR = "\xF0\x9F\x87\xAD\xF0\x9F\x87\xB7",
	HU = "\xF0\x9F\x87\xAD\xF0\x9F\x87\xBA",
	ID = "\xF0\x9F\x87\xAE\xF0\x9F\x87\xA9",
	IT = "\xF0\x9F\x87\xAE\xF0\x9F\x87\xB9",
	JP = "\xF0\x9F\x87\xAF\xF0\x9F\x87\xB5",
	KR = "\xF0\x9F\x87\xB0\xF0\x9F\x87\xB7",
	LT = "\xF0\x9F\x87\xB1\xF0\x9F\x87\xB9",
	LV = "\xF0\x9F\x87\xB1\xF0\x9F\x87\xBB",
	NL = "\xF0\x9F\x87\xB3\xF0\x9F\x87\xB1",
	NO = "\xF0\x9F\x87\xB3\xF0\x9F\x87\xB4",
	PH = "\xF0\x9F\x87\xB5\xF0\x9F\x87\xAD",
	PL = "\xF0\x9F\x87\xB5\xF0\x9F\x87\xB1",
	RO = "\xF0\x9F\x87\xB7\xF0\x9F\x87\xB4",
	RU = "\xF0\x9F\x87\xB7\xF0\x9F\x87\xBA",
	TR = "\xF0\x9F\x87\xB9\xF0\x9F\x87\xB7"
}
countryFlags.PT = countryFlags.BR
countryFlags.GB = countryFlags.EN
countryFlags.JA = countryFlags.JP
countryFlags.SA = countryFlags.AR

local countryFlags_Aliases = { PT = "BR", JA = "JP", GB = "EN", SA = "AR" }

local communities = {
	["br"] = "\xF0\x9F\x87\xA7\xF0\x9F\x87\xB7",
	["es"] = "\xF0\x9F\x87\xAA\xF0\x9F\x87\xB8",
	["fr"] = "\xF0\x9F\x87\xAB\xF0\x9F\x87\xB7",
	["gb"] = "\xF0\x9F\x87\xAC\xF0\x9F\x87\xA7",
	["nl"] = "\xF0\x9F\x87\xB3\xF0\x9F\x87\xB1",
	["ro"] = "\xF0\x9F\x87\xB7\xF0\x9F\x87\xB4",
	["ru"] = "\xF0\x9F\x87\xB7\xF0\x9F\x87\xBA",
	["sa"] = "\xF0\x9F\x87\xB8\xF0\x9F\x87\xA6",
	["tr"] = "\xF0\x9F\x87\xB9\xF0\x9F\x87\xB7",
	["pt"] = "\xF0\x9F\x87\xA7\xF0\x9F\x87\xB7",
	["en"] = "\xF0\x9F\x87\xAC\xF0\x9F\x87\xA7",
	["ar"] = "\xF0\x9F\x87\xB8\xF0\x9F\x87\xA6",
}

local debugAction = {
	test = 0,
	cmd  = 1
}

local logColor = {
	gray  = 40,
	red   = 31,
	green = 32,
}

local permMaps = {
	["20"] = true,
	["21"] = true,
	["22"] = true,
	["32"] = true,
	["34"] = true,
	["41"] = true,
	["42"] = true
}

local permissions = discordia.enums.enum {
	public    = 0, -- Never change
	has_power = 1,
	is_module = 2, -- Never change
	is_dev    = 3, -- Never change
	is_art    = 4,
	--is_map  = 5,
	is_trad   = 6,
	--is_fash = 7,
	--is_evt  = 8,
	is_writer = 9,
	is_math   = 10,
	--is_fc   = 11,
	--is_shades = 12,
	--is_staff  = 13, -- Never change
	--is_owner  = 14,
	is_mod    = 15,
	is_admin  = 16,
}

local permIcons = {
	public    = ":small_orange_diamond:",
	has_power = ":small_blue_diamond:",
	is_module = "<:wheel:456198795768889344>",
	is_dev    = "<:lua:468936022248390687>",
	is_art    = "<:p5:468937377981923339>",
	--is_map  = "<:p41:463508055577985024>",
	is_trad   = ":earth_americas:",
	--is_fash = "<:dance:468937918115741718>",
	--is_evt  = "<:idea:559070151278854155>",
	is_writer = ":pencil:",
	is_math   = ":triangular_ruler:",
	--is_fc   = "<:fun:559069782469771264>",
	--is_shades = "<:illuminati:542115872328646666>",
	--is_staff  = ":star:",
	--is_owner  = ":star2:",
	is_mod    = ":hammer_pick:",
	is_admin  = ":cake:",
}

local roleColor = {
	owner     = 0x7AC9C4,
	community = 0x1ABC9C
}

local specialRoleColor = discordia.enums.enum {
	["462279926532276225"] = "530765845480210462", -- mt
	["462281046566895636"] = "530765846470066186", -- dev
	["462285151595003914"] = "530765853340467210", -- art
	["494665355327832064"] = "530765852296085524", -- trad
	["462329326600192010"] = "530765854174871553", -- map
	["481189370448314369"] = "530765850186219550", -- evt
	["544202727216119860"] = "544204980706476053", -- sh
	["526822896987930625"] = "530765847816568832", -- fc
	["514913541627838464"] = "530765851314356236", -- math
	["465631506489016321"] = "530765844406599680", -- fashion
	["514913155437035551"] = "530765848823201792"  -- write
}

local roles = {
	["tech guru"]    = "462279926532276225",
	["developer"]    = "462281046566895636",
	["artist"]       = "462285151595003914",
	["translator"]   = "494665355327832064",
	--["mapper"]     = "462329326600192010",
	--["event manager"] = "481189370448314369",
	--["shades helper"] = "544202727216119860",
	--["funcorp"]    = "526822896987930625",
	["mathematician"] = "514913541627838464",
	--["fashionista"] = "465631506489016321",
	["writer"]       = "514913155437035551",
}
for name, id in next, table.copy(roles) do roles[id] = name end

local roleFlags = {
	[1] = "tech guru",
	[2] = "developer",
	[3] = "artist",
	[4] = "translator",
	--[5] = "mapper",
	--[6] = "event manager",
	--[7] = "shades helper",
	--[8] = "funcorp",
	[5] = "mathematician",
	--[10] = "fashionista",
	[6] = "writer",
}
for i, name in next, table.copy(roleFlags) do roleFlags[name] = i end

return {
	authIds            = authIds,
	channels           = channels,
	botIds             = botIds,
	categories         = categories,
	nickList           = nickList,
	color              = color,
	reactions          = reactions,
	countryFlags       = countryFlags,
	countryFlags_Aliases = countryFlags_Aliases,
	communities        = communities,
	debugAction        = debugAction,
	logColor           = logColor,
	permMaps           = permMaps,
	permissions        = permissions,
	permIcons          = permIcons,
	roleColor          = roleColor,
	specialRoleColor   = specialRoleColor,
	roles              = roles,
	roleFlags          = roleFlags,
}
