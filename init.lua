instant_ores = {}

instant_ores.register_gen_ore = function(node, rarity, ymax, ymax_deep)
	if rarity < 0 then rarity = 0 end
	local count_large = math.ceil(48/rarity) + 1
	local count_small = math.ceil(24/rarity) + 1
	local dense_rarity = math.ceil(rarity * 3/4)
	
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = node,
		wherein        = "default:stone",
		clust_scarcity = dense_rarity * dense_rarity * dense_rarity,
		clust_num_ores = count_large,
		clust_size     = 3,
		y_min          = 1025,
		y_max          = 31000,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = node,
		wherein        = "default:stone",
		clust_scarcity = rarity * rarity * rarity,
		clust_num_ores = count_small,
		clust_size     = 3,
		y_min          = ymax_deep,
		y_max          = ymax,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = node,
		wherein        = "default:stone",
		clust_scarcity = dense_rarity * dense_rarity * dense_rarity,
		clust_num_ores = count_large,
		clust_size     = 3,
		y_min          = -31000,
		y_max          = ymax_deep,
	})
	
end

instant_ores.register_toolset = function(mod, name, desc, color, level, ingredient, --[[ Parameters after this can be omitted ]] optional_durability, optional_speed, infinite_use)
	local durability = optional_durability or (40*level)
	local afteruse = infinite_use and (function() end) or (
		function(itemstack, user, node) 
			-- Use this hack instead of the insane default which is impossible to work with.
			
			local tool = itemstack:get_tool_capabilities()
			local ndef = minetest.registered_nodes[node.name]
			
			if not (ndef and tool) then return end
			
			local wear = 0
			
			if ndef.groups.cracky and tool.groupcaps.cracky then
				wear = (4-ndef.groups.cracky) * (65536/tool.groupcaps.cracky.uses)
			elseif ndef.groups.choppy and tool.groupcaps.choppy then
				wear = (4-ndef.groups.choppy) * (65536/tool.groupcaps.choppy.uses)
			elseif ndef.groups.crumbly and tool.groupcaps.crumbly then
				wear = (4-ndef.groups.crumbly) * (65536/tool.groupcaps.crumbly.uses)
			elseif ndef.groups.snappy and tool.groupcaps.snappy then
				wear = (4-ndef.groups.snappy) * (65536/tool.groupcaps.snappy.uses)
			else
				return
			end
			
			local breaksound = itemstack:get_definition().sound.breaks
			itemstack:add_wear(math.ceil(wear))
			if itemstack:get_count() == 0 and breaksound then
				minetest.sound_play(breaksound, {pos=user:get_pos(), max_hear_distance=6, gain=0.5})
			end
          		return itemstack
		end
	)
	
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
		groups = {tooltype_pick = 1},
		sound = {breaks = "default_tool_breaks"},
		after_use = afteruse,
		
	})
	
	minetest.register_craft({
		output = mod..":pick_"..name,
		recipe = {
			{ingredient, ingredient, ingredient},
			{"","default:stick",""},
			{"","default:stick",""}
		}	
	})

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
		groups = {tooltype_shovel = 1},
		sound = {breaks = "default_tool_breaks"},
		after_use = afteruse,
	})

	minetest.register_craft({
		output = mod..":shovel_"..name,
		recipe = {
			{ingredient},
			{"default:stick"},
			{"default:stick"}
		}	
	})

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
		groups = {tooltype_axe = 1},
		sound = {breaks = "default_tool_breaks"},
		after_use = afteruse,
	})

	minetest.register_craft({
		output = mod..":axe_"..name,
		recipe = {
			{ingredient, ingredient},
			{ingredient,"default:stick"},
			{"","default:stick"}
		}	
	})

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
		groups = {tooltype_sword = 1},
		sound = {breaks = "default_tool_breaks"},
		after_use = afteruse,
	})

	minetest.register_craft({
		output = mod..":sword_"..name,
		recipe = {
			{ingredient},
			{ingredient},
			{"default:stick"}
		}	
	})

	if farming then
		farming.register_hoe(mod..":hoe_"..name, {
			description = desc.." Hoe",
			inventory_image = "tool_base.png^tool_hoe_base.png^(tool_hoe.png^[colorize:"..color..")",
			max_uses = durability,
			material = ingredient,
			groups = {tooltype_hoe=1},
			after_use = infinite_use and (function() end),
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
		sounds = default.node_sound_metal_defaults(),
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
			sounds = default.node_sound_stone_defaults(),
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
		sounds = default.node_sound_stone_defaults(),
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
			sounds = default.node_sound_stone_defaults(),
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

-- test-ores (WARNING: _VERY_ UNBALANCED)
--dofile(minetest.get_modpath("instant_ores").."/examples.lua")
  
  
  