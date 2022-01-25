instant_ores = {}

if minetest.get_modpath("default") then
	instant_ores.stone = "default:stone"
	instant_ores.stick = "default:stick"
elseif minetest.get_modpath("mcl_core") then
	instant_ores.stone = "mcl_core:stone"
	instant_ores.stick = "mcl_core:stick"
else
	minetest.log("warn","instant_ores only supports default and MineClone2. Sticks and stones could not be found.")
end
if minetest.get_modpath("default") then
	instant_ores.node_sound_metal_defaults=default.node_sound_metal_defaults
	instant_ores.node_sound_stone_defaults=default.node_sound_stone_defaults
elseif minetest.get_modpath("mcl_sounds") then
	instant_ores.node_sound_metal_defaults=mcl_sounds.node_sound_metal_defaults
	instant_ores.node_sound_stone_defaults=mcl_sounds.node_sound_stone_defaults
else
	instant_ores.node_sound_metal_defaults=function ()
		return {}
	end
	instant_ores.node_sound_stone_defaults=function ()
		return {}
	end
	minetest.log("warn","instant_ores only supports default and MineClone2. Sounds could not be found.")
end

instant_ores.register_gen_ore = function(node, rarity, ymax, ymax_deep)
	if rarity < 0 then rarity = 0 end
	local count_large = math.ceil(48/rarity) + 1
	local count_small = math.ceil(24/rarity) + 1
	local dense_rarity = math.ceil(rarity * 3/4)
	
	if not instant_ores.stone then return end

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = node,
		wherein        = instant_ores.stone,
		clust_scarcity = dense_rarity * dense_rarity * dense_rarity,
		clust_num_ores = count_large,
		clust_size     = 3,
		y_min          = 1025,
		y_max          = 31000,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = node,
		wherein        = instant_ores.stone,
		clust_scarcity = rarity * rarity * rarity,
		clust_num_ores = count_small,
		clust_size     = 3,
		y_min          = ymax_deep,
		y_max          = ymax,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = node,
		wherein        = instant_ores.stone,
		clust_scarcity = dense_rarity * dense_rarity * dense_rarity,
		clust_num_ores = count_large,
		clust_size     = 3,
		y_min          = -31000,
		y_max          = ymax_deep,
	})
	
end

instant_ores.register_armorset = function(
	mod, 
	name, 
	desc, 
	color, 
	level, 
	ingredient, 
	optional_durability, 
	infinite_use, 
	shield_damage_sound, 
	optional_protection, 
	hurt_back, 
	optional_weight)
	if not minetest.get_modpath("3d_armor") then return end
	local durability = optional_durability or (20*level*level*level)
	local uses = infinite_use and 0 or (65536 / durability)
	local weight = optional_weight or 1
	local default_protection = 24 - 20/((level >= 1) and level*level/2 or 1)
	local big_armor = math.ceil(optional_protection or default_protection)
	local small_armor = math.ceil((optional_protection or default_protection)*0.66)
	local sound = shield_damage_sound or "default_dig_metal"
	--local sanity = nil
	armor:register_armor(":"..mod..":helmet_"..name, {
		description = desc.." Helmet",
		inventory_image = "3d_armor_inv_helmet_steel.png^[multiply:"..color,
		texture = "3d_armor_dummy_image.png^(3d_armor_helmet_steel.png^(3d_armor_helmet_steel.png^[multiply:"..color.."^[opacity:220))^3d_armor_dummy_image.png",
		 -- I'm not going to try to explain how this texture hack works. Really, it shouldn't.
		preview = "3d_armor_preview_dummy_image.png^(3d_armor_helmet_steel_preview.png^(3d_armor_helmet_steel_preview.png^[multiply:"..color.."^[opacity:220))^3d_armor_preview_dummy_image.png",
		groups = {armor_head=1, armor_heal=0, armor_use=uses,
			physics_speed=-0.01*weight, physics_gravity=0.01*weight},
		reciprocate_damage = hurt_back,
		armor_groups = {fleshy=small_armor},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=level},
	})
	armor:register_armor(":"..mod..":chestplate_"..name, {
		description = desc.." Chestplate",
		inventory_image = "3d_armor_inv_chestplate_steel.png^[multiply:"..color,
		texture = "3d_armor_dummy_image.png^(3d_armor_chestplate_steel.png^(3d_armor_chestplate_steel.png^[multiply:"..color.."^[opacity:220))^3d_armor_dummy_image.png",
		preview = "3d_armor_preview_dummy_image.png^(3d_armor_chestplate_steel_preview.png^(3d_armor_chestplate_steel_preview.png^[multiply:"..color.."^[opacity:220))^3d_armor_preview_dummy_image.png",
		groups = {armor_torso=1, armor_heal=0, armor_use=uses,
			physics_speed=-0.04*weight, physics_gravity=0.04*weight},
		reciprocate_damage = hurt_back,
		armor_groups = {fleshy=big_armor},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=level},
	})
	armor:register_armor(":"..mod..":leggings_"..name, {
		description = desc.." Leggings",
		inventory_image = "3d_armor_inv_leggings_steel.png^[multiply:"..color,
		texture = "3d_armor_dummy_image.png^(3d_armor_leggings_steel.png^(3d_armor_leggings_steel.png^[multiply:"..color.."^[opacity:220))^3d_armor_dummy_image.png",
		preview = "3d_armor_preview_dummy_image.png^(3d_armor_leggings_steel_preview.png^(3d_armor_leggings_steel_preview.png^[multiply:"..color.."^[opacity:220))^3d_armor_preview_dummy_image.png",
		groups = {armor_legs=1, armor_heal=0, armor_use=uses,
			physics_speed=-0.03*weight, physics_gravity=0.03*weight},
		reciprocate_damage = hurt_back,
		armor_groups = {fleshy=big_armor},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=level},
	})
	armor:register_armor(":"..mod..":boots_"..name, {
		description = desc.." Boots",
		inventory_image = "3d_armor_inv_boots_steel.png^[multiply:"..color,
		texture = "3d_armor_dummy_image.png^(3d_armor_boots_steel.png^(3d_armor_boots_steel.png^[multiply:"..color.."^[opacity:220))^3d_armor_dummy_image.png",
		preview = "3d_armor_preview_dummy_image.png^(3d_armor_boots_steel_preview.png^(3d_armor_boots_steel_preview.png^[multiply:"..color.."^[opacity:220))^3d_armor_preview_dummy_image.png",
		groups = {armor_feet=1, armor_heal=0, armor_use=uses,
			physics_speed=-0.01*weight, physics_gravity=0.01*weight},
		reciprocate_damage = hurt_back,
		armor_groups = {fleshy=small_armor},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=level},
	})
	
	minetest.register_craft({
		output = mod..":helmet_"..name,
		recipe = {
			{ingredient, ingredient, ingredient},
			{ingredient, "", ingredient},
			{"", "", ""},
		},
	})
	minetest.register_craft({
		output = mod..":chestplate_"..name,
		recipe = {
			{ingredient, "", ingredient},
			{ingredient, ingredient, ingredient},
			{ingredient, ingredient, ingredient},
		},
	})
	minetest.register_craft({
		output = mod..":leggings_"..name,
		recipe = {
			{ingredient, ingredient, ingredient},
			{ingredient, "", ingredient},
			{ingredient, "", ingredient},
		},
	})
	minetest.register_craft({
		output = mod..":boots_"..name,
		recipe = {
			{ingredient, "", ingredient},
			{ingredient, "", ingredient},
		},
	})
	
	if not minetest.get_modpath("shields") then return end
	armor:register_armor(":"..mod..":shield_"..name, {
		description = desc.." Shield",
		inventory_image = "shields_inv_shield_steel.png^[multiply:"..color,
		texture = "3d_armor_dummy_image.png^(shields_shield_steel.png^(shields_shield_steel.png^[multiply:"..color.."^[opacity:220))^3d_armor_dummy_image.png",
		preview = "3d_armor_preview_dummy_image.png^(shields_shield_steel_preview.png^(shields_shield_steel_preview.png^[multiply:"..color.."^[opacity:220))^3d_armor_preview_dummy_image.png",
		groups = {armor_shield=1, armor_heal=0, armor_use=uses,
			physics_speed=-0.03*weight, physics_gravity=0.03*weight},
		armor_groups = {fleshy=small_armor},
		damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=level},
		reciprocate_damage = hurt_back,
		on_damage = function(player)
			if not minetest.settings:get_bool("shields_disable_sounds") then
				minetest.sound_play(sound, {
					pos = player:get_pos(),
					max_hear_distance = 10,
					gain = 0.5,
				})
			end
		end,
		on_destroy = function(player)
			if not minetest.settings:get_bool("shields_disable_sounds") then
				minetest.sound_play("default_tool_breaks", {
					pos = player:get_pos(),
					max_hear_distance = 10,
					gain = 0.5,
				})
			end
		end,
	})
	
	minetest.register_craft({
		output = mod..":shield_"..name,
		recipe = {
			{ingredient, ingredient, ingredient},
			{ingredient, ingredient, ingredient},
			{"", ingredient, ""},
		},
	})
end

instant_ores.after_use = function(itemstack, user, node) 
	-- Use this hack instead of the insane default which is impossible to work with.
	
	local tool = itemstack:get_tool_capabilities()
	local ndef = minetest.registered_nodes[node.name]
	local meta = itemstack:get_meta()
	local worn = meta:get_int("worn") or 0 
	-- Using this hack allows tools to have more than 65535 uses, and still behave correctly.
	local uses
	
	if not (ndef and tool) then return end
	
	local wear = 0
	
	if ndef.groups.cracky and tool.groupcaps.cracky then
		uses = tool.groupcaps.cracky.uses
		wear = (4-ndef.groups.cracky)
	elseif ndef.groups.choppy and tool.groupcaps.choppy then
		uses = tool.groupcaps.choppy.uses
		wear = (4-ndef.groups.choppy)
	elseif ndef.groups.crumbly and tool.groupcaps.crumbly then
		uses = tool.groupcaps.crumbly.uses
		wear = (4-ndef.groups.crumbly)
	elseif ndef.groups.snappy and tool.groupcaps.snappy then
		uses = tool.groupcaps.snappy.uses
		wear = (4-ndef.groups.snappy)
	else
		return
	end
	
	if itemstack:get_wear() ~= math.floor(worn * (65536/uses)) then
	 -- Something tried to change the wear value, adjust the true value to compensate.
		worn = math.floor((uses*itemstack:get_wear()/65536) + 0.5)
	end
	
	worn = worn + wear
	
	local breaksound = itemstack:get_definition().sound.breaks
	if uses then itemstack:set_wear(math.floor(worn * (65536/uses))) end
	if itemstack:get_count() == 0 and breaksound then
		minetest.sound_play(breaksound, {pos=user:get_pos(), max_hear_distance=6, gain=0.5})
	else
		meta:set_int("worn", worn)
	end
	return itemstack
end

instant_ores.null_function = function() end

instant_ores.register_toolset = function(mod, name, desc, color, level, ingredient, --[[ Parameters after this can be omitted ]] optional_durability, optional_speed, infinite_use)
	local durability = optional_durability or (20*level*level*level)
	local afteruse = infinite_use and instant_ores.null_function or instant_ores.after_use
	
	local maketool = infinite_use and 
		function(name, def)
			def.stack_max = 1
			minetest.register_craftitem(name, def)
		end
	or minetest.register_tool
	
	if level < 1 then level = 1 end
	local speed = optional_speed or level
	
	if speed > 2 then
		speed = speed*speed/level -- Correct for maxlevel having an effect on speed
	elseif speed < 0.001 then 
		speed = 0.001 
	else
		speed = speed/level
	end
	
	local gcap = {
		cracky = {},
		crumbly = {},
		choppy = {},
		snappy = {}
	}
	gcap.cracky[3] = 2.00/speed
	
	gcap.crumbly[3] = 1.00/speed
	gcap.crumbly[2] = 2.40/speed
	gcap.crumbly[1] = 3.60/speed
	
	gcap.choppy[3] = 2.60/speed
	gcap.choppy[2] = 4.00/speed
	
	gcap.snappy[3] = 0.80 / speed
	gcap.snappy[2] = 2.80 / speed
	if level > 1 then
		gcap.cracky[2] = 4.00 / speed
		gcap.choppy[1] = 6.00 /speed
		if level > 2 then
			gcap.cracky[1] = 6.00 /speed
			gcap.snappy[1] = 7.50 /speed
		end
	end
	
	maketool(":"..mod..":pick_"..name, {
		description = desc.." Pickaxe",
		inventory_image = "tool_base.png^tool_pick_base.png^(tool_pick.png^[colorize:"..color..")",
		tool_capabilities = {
			full_punch_interval = 2.67/(optional_speed or level),
			max_drop_level=level,
			groupcaps={
				cracky = {uses=durability, maxlevel=level, times=gcap.cracky},
			},
			damage_groups = {fleshy=level+1},
		},
		groups = {pick = 1},
		sound = {breaks = "default_tool_breaks"},
		after_use = afteruse,
		
	})
	
	if instant_ores.stick then
		minetest.register_craft({
			output = mod..":pick_"..name,
			recipe = {
				{ingredient, ingredient, ingredient},
				{"",instant_ores.stick,""},
				{"",instant_ores.stick,""}
			}	
		})
	end

	maketool(":"..mod..":shovel_"..name, {
		description = desc.." Shovel",
		inventory_image = "tool_base.png^tool_shovel_base.png^(tool_shovel.png^[colorize:"..color..")",
		wield_image = "tool_base.png^tool_shovel_base.png^(tool_shovel.png^[colorize:"..color..")^[transformR90",
		tool_capabilities = {
			full_punch_interval = 3/(optional_speed or level),
			max_drop_level=level,
			groupcaps={
				crumbly = {uses=durability, maxlevel=level, times=gcap.crumbly},
			},
			damage_groups = {fleshy=level},
		},
		groups = {shovel = 1},
		sound = {breaks = "default_tool_breaks"},
		after_use = afteruse,
	})

	if instant_ores.stick then
		minetest.register_craft({
			output = mod..":shovel_"..name,
			recipe = {
				{ingredient},
				{instant_ores.stick},
				{instant_ores.stick}
			}	
		})
	end

	maketool(":"..mod..":axe_"..name, {
		description = desc.." Axe",
		inventory_image = "tool_base.png^tool_axe_base.png^(tool_axe.png^[colorize:"..color..")",
		tool_capabilities = {
			full_punch_interval = 2.67/(optional_speed or level),
			max_drop_level=level,
			groupcaps={
				choppy={uses=durability, maxlevel=level, times=gcap.choppy},
			},
			damage_groups = {fleshy=level+2},
		},
		groups = {axe = 1},
		sound = {breaks = "default_tool_breaks"},
		after_use = afteruse,
	})

	if instant_ores.stick then
		minetest.register_craft({
			output = mod..":axe_"..name,
			recipe = {
				{ingredient, ingredient},
				{ingredient,instant_ores.stick},
				{"",instant_ores.stick}
			}	
		})
	end

	maketool(":"..mod..":sword_"..name, {
		description = desc.." Sword",
		inventory_image = "tool_base.png^tool_sword_base.png^(tool_sword.png^[colorize:"..color..")",
		tool_capabilities = {
			full_punch_interval = 2.25/(optional_speed or level),
			max_drop_level=level,
			groupcaps={
				snappy={uses=durability, maxlevel=level, times=gcap.snappy},
			},
			damage_groups = {fleshy=level+3},
		},
		groups = {sword = 1},
		sound = {breaks = "default_tool_breaks"},
		after_use = afteruse,
	})

	if instant_ores.stick then
		minetest.register_craft({
			output = mod..":sword_"..name,
			recipe = {
				{ingredient},
				{ingredient},
				{instant_ores.stick}
			}
		})
	end

	if farming then
		farming.register_hoe(mod..":hoe_"..name, {
			description = desc.." Hoe",
			inventory_image = "tool_base.png^tool_hoe_base.png^(tool_hoe.png^[colorize:"..color..")",
			max_uses = durability,
			material = ingredient,
			groups = {hoe=1},
			after_use = afteruse,
		})
	end

end

instant_ores.register_metal = function(metal)
	local name = string.split(metal.name, ":") 
	if #name ~= 2 then
		error("metal.name must be the mod name and the metal name separated by ':'")
	end
	-- name should be in 'mod:material' format (e.g 'aliens:plutonium', 'minerals_plus:tungsten', 'fairytest:enchanted_steel')
	
	-- Fallbacks for properties that *shouldn't* be omitted
	
	metal.description = metal.description or "Terribly Programmed" -- :P
	metal.power = metal.power or 3 -- If someone can't decide how strong to make their metal, make it a bit stronger than steel.
	
	--Properties that can reasonably be omitted, as they're not strictly necessary, and sane defaults exist.
	--NOTE: setting a custom image will disable automatic colorization.
	metal.lump_image = metal.lump_image or ("metal_lump_base.png^(metal_lump.png^[colorize:"..metal.color..")")
	metal.ingot_image = metal.ingot_image or ("default_steel_ingot.png^[colorize:"..metal.color)
	metal.ore_image = metal.ore_image or ("default_stone.png^mineral_0_base.png^(mineral_0.png^[colorize:"..metal.color..")")
	metal.block_image = metal.block_image or ("default_steel_block.png^[colorize:"..metal.color)
	metal.tool_ingredient = metal.tool_ingredient or (metal.name.."_ingot")
	metal.hardness = metal.hardness or (metal.power - 1)
	
	local crackiness = 1
	if metal.hardness < 3 then
		if metal.hardness < 1 then
			crackiness = 3
		else
			crackiness = 4 - metal.hardness
		end
	end
	local groups = {cracky = crackiness, level=metal.hardness}
	
	minetest.register_craftitem(":"..metal.name.."_ingot", {
		description = metal.description.." Ingot",
		inventory_image = metal.ingot_image,
	})
	
	minetest.register_node(":"..metal.name.."block", {
		description = metal.description.." Block",
		tiles = {metal.block_image},
		is_ground_content = false,
		groups = table.copy(groups),
		sounds = instant_ores.node_sound_metal_defaults(),
	})
	
	local i = metal.name.."_ingot"
	local iii = {i,i,i}
	
	minetest.register_craft({
		output = metal.name.."block",
		recipe = {iii,iii,iii}
	})
	
	minetest.register_craft({
		type="shapeless",
		output = i.." 9",
		recipe = {metal.name.."block"}
	})
	
	if not metal.artificial then -- Ore-less metals (like bronze) can disable lumps and ore. This will *NOT* make a recipe for your alloy/special metal/whatever.
		
		--Depth and rarity only needed if ore generated.
		metal.depth = metal.depth or 32
		metal.rarity = metal.rarity or 11
		metal.large_depth = metal.large_depth or 2*metal.depth
		
		minetest.register_craftitem(":"..metal.name.."_lump", {
			description = metal.description.." Lump",
			inventory_image = metal.lump_image,
		
		})
	
		minetest.register_craft({
			type = "cooking",
			output = metal.name.."_ingot",
			recipe = metal.name.."_lump",
			cooktime = metal.cooktime
		})
	
		
	
		minetest.register_node(":"..name[1]..":stone_with_"..name[2], {
			description = metal.description.." Ore",
			tiles = {metal.ore_image},
			groups = table.copy(groups),
			drop = metal.name.."_lump",
			sounds = instant_ores.node_sound_stone_defaults(),
		})
	
		instant_ores.register_gen_ore(
			name[1]..":stone_with_"..name[2],
			metal.rarity,
			--[[ For reference, 
				8 = coal (approx)
				12 = copper (approx)
				14 = mese (approx)
				Actual scarcity of clusters is this value cubed, but this affects the size of clusters as well.
			]]
			-metal.depth,
			-metal.large_depth
		)
	end
	if not metal.no_tools then
	instant_ores.register_toolset(
		name[1],
		name[2],
		metal.description,
		metal.color,
		metal.power, -- For reference, 2 is based on the power of stone tools.
		metal.tool_ingredient, --Must be a valid item
		metal.durability, -- can be nil, will be calculated from power if omitted.
		metal.speed,
		metal.infinite_uses
	)
	end
	if not metal.no_armor then
		instant_ores.register_armorset(name[1], name[2], 
			metal.description,
			metal.color,
			metal.power, 
			metal.tool_ingredient,
			metal.armor_durability or metal.durability, -- will be calculated from power if both are nil.
			metal.infinite_uses,
			metal.shield_damage_sound or "default_dig_metal",
			metal.armor_protection,
			metal.armor_hurtback,
			metal.armor_weight)
	end
		
end

instant_ores.register_crystal = function(crystal)
	local name = string.split(crystal.name, ":") 
	if #name ~= 2 then
		error("crystal.name must be the mod name and the crystal name separated by ':'")
	end
	
	-- Fallbacks for properties that *shouldn't* be omitted
	
	crystal.description = crystal.description or "Terribly Programmed" -- :P
	crystal.power = crystal.power or 3 -- If someone can't decide how strong to make their crystal, make it a bit stronger than steel.
	
	--Properties that can reasonably be omitted, as they're not strictly necessary, and sane defaults exist.
	--NOTE: setting a custom image will disable automatic colorization.
	crystal.shard_image = crystal.shard_image or ("crystal_shard_base.png^(crystal_shard.png^[colorize:"..crystal.color..")")
	crystal.crystal_image = crystal.crystal_image or ("crystal_1_base.png^(crystal_1.png^[colorize:"..crystal.color..")")
	crystal.ore_image = crystal.ore_image or ("default_stone.png^mineral_1_base.png^(mineral_1.png^[colorize:"..crystal.color..")")
	crystal.block_image = crystal.block_image or ("crystal_block.png^[colorize:"..crystal.color)
	crystal.tool_ingredient = crystal.tool_ingredient or (crystal.name.."_crystal")
	crystal.hardness = crystal.hardness or (crystal.power - 1)
	
	local crackiness = 1
	if crystal.hardness < 3 then
		if crystal.hardness < 1 then
			crackiness = 3
		else
			crackiness = 4 - crystal.hardness
		end
	end
	local groups = {cracky = crackiness, level=crystal.hardness}
	
	minetest.register_craftitem(":"..crystal.name.."_crystal", {
		description = crystal.description.." Crystal",
		inventory_image = crystal.crystal_image,
	})
	minetest.register_craftitem(":"..crystal.name.."_shard", {
		description = crystal.description.." Shard",
		inventory_image = crystal.shard_image,
	})
	
	minetest.register_node(":"..crystal.name.."block", {
		description = crystal.description.." Block",
		tiles = {crystal.block_image},
		is_ground_content = false,
		groups = table.copy(groups),
		sounds = instant_ores.node_sound_stone_defaults(),
	})
	
	local s = crystal.name.."_shard"
	local sss = {s,s,s}
	local i = crystal.name.."_crystal"
	local iii = {i,i,i}
	
	minetest.register_craft({
		output = i,
		recipe = {sss,sss,sss}
	})
	minetest.register_craft({
		type = "shapeless",
		output = s.." 9",
		recipe = {i}
	})
	
	minetest.register_craft({
		output = crystal.name.."block",
		recipe = {iii,iii,iii}
	})
	
	minetest.register_craft({
		type="shapeless",
		output = i.." 9",
		recipe = {crystal.name.."block"}
	})
	
	if not crystal.artificial then -- Ore-less crystals can disable oregen. This will *NOT* make a recipe for your crystal/whatever.
		
		--Depth and rarity only needed if ore generated.
		crystal.depth = crystal.depth or 32
		crystal.rarity = crystal.rarity or 11
		crystal.large_depth = crystal.large_depth or 2*crystal.depth
		
		
	
		minetest.register_node(":"..name[1]..":stone_with_"..name[2], {
			description = crystal.description.." Ore",
			tiles = {crystal.ore_image},
			groups = table.copy(groups),
			drop = crystal.name.."_crystal",
			sounds = instant_ores.node_sound_stone_defaults(),
		})
	
		instant_ores.register_gen_ore(
			name[1]..":stone_with_"..name[2],
			crystal.rarity,
			--[[ For reference, 
				8 = coal (approx)
				12 = copper (approx)
				14 = mese (approx)
				Actual scarcity of clusters is this value cubed, but this affects the size of clusters as well.
			]]
			-crystal.depth,
			-crystal.large_depth
		)
	end
	
	if not crystal.no_tools then
	instant_ores.register_toolset(
		name[1],
		name[2],
		crystal.description,
		crystal.color,
		crystal.power, -- For reference, 2 is based on the power of stone tools.
		crystal.tool_ingredient, --Must be a valid item
		crystal.durability, -- can be nil, will be calculated from power if omitted.
		crystal.speed,
		crystal.infinite_uses
	)
	end
	
	
	instant_ores.register_armorset(name[1], name[2], 
		crystal.description,
		crystal.color,
		crystal.power, 
		crystal.tool_ingredient,
		crystal.armor_durability or crystal.durability, -- will be calculated from power if both are nil.
		crystal.infinite_uses,
		crystal.shield_damage_sound or "default_glass_footstep",
		crystal.armor_protection,
		crystal.armor_hurtback,
		crystal.armor_weight)
end

-- test-ores (WARNING: _VERY_ UNBALANCED)
dofile(minetest.get_modpath("instant_ores").."/examples.lua")
  
  
  