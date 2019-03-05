--[[
Default image structure (reference for texture pack makers):
	tools: tool_base.png + tool_(pick/shovel/axe/sword/hoe)_base.png + (tool_(pick/shovel/axe/sword/hoe).png^[colorize:(color))
	block: (default_steel_block.png/crystal_block.png)^[colorize:(color)
	ingot: default_steel_ingot.png^[colorize:(color)
	metal ore: default_stone.png + mineral_0_base.png + (mineral_0.png^[colorize:(color))
	crystal ore: default_stone.png + mineral_1_base.png + (mineral_1.png^[colorize:(color))
	crystal/crystal_shard/metal_lump: (crystal/crystal_shard/metal_lump)_base.png + ((crystal/crystal_shard/metal_lump).png^[colorize:(color))
	
	
	NOTE: For images that are colorized, I HIGHLY recommend sharpening the brightness/contrast, 
	as the colorization can flatten it out quite a bit. Krita is an excelent tool for this.
]]



--[[
Properties shared by metal and crystal:
	
	name: material name base in 'mod:material' format 
		(e.g 'aliens:plutonium', 'minerals_plus:tungsten', 'fairytest:enchanted_steel')
	
	description: The readable name of the material (will be concatenated with strings such as " Ingot", " Ore", " Shovel", etc.)
	
	depth: how far down before the ore generates (positive = downward)
	
	large_depth (optional): how far down before large clusters of the ore generate
		If nil, 2*depth will be used.
	
	rarity: How rare the ore is. For reference, 
		8 = coal (approx)
		12 = copper (approx)
		14 = mese (approx)
		Actual scarcity of clusters is this value cubed, but this affects the size of clusters as well.
	
	artificial: This is an alloy or other specially made material, and does not have an ore (or a lump, if metal).
		Depth and rarity can be omitted if this is true.
		THIS WILL NOT REGISTER A RECIPE FOR YOU.
	
	infinite_uses: Tools don't break.
	
	durability: 
		How many uses the tools have.
		Does nothing if infinite_uses is true.
		Will default to 40*power
		Can be over 65536, a custom after_use function handles this
	
	armor_durability: 
		Durability (number of uses) of armor (if 3d_armor is present)
		Does nothing if infinite_uses is true.
		Will default to durability
	
	
	hardness (optional): Optional reversed nodegroup cracky of the ore and block, (1 = (cracky=3), 2 = (cracky=2), 3+ = (cracky=1)). 
		Will default to one less than power.
	
	power: How strong the tools are. For reference, a value of '2' gives strengths roughly similar to stone tools. 
		Affects max levels of tools, dig times, and ore hardness if hardness is not defined.
	
	speed (optional): Optional swing speed for tools. For reference, a value of '2' gives speeds roughly similar to stone tools. 
		If nil, power will be used.
	
	color: Must be in format "#RRGGBB:AAA" Used to colorize images for materials/ores (if no custom sprite is given), and tools.
	
	no_tools: Don't register a toolset for this material.
	
	no_armor: If 3d_armor is present, don't register armor for this material.
	
	tool_ingredient (optional): Optional name of an item to be used in place of ingots/crystals in the tool recipe.
	
	shield_damage_sound: The sound played when the shield takes/blocks damage.
	
	armor_protection:
		Fleshy armor group, defaults to 24 - 20/level
		WARNING: If this is set to anything over 24, then a full set of armor will make the player invincible.
		(if 3d_armor is present)
	
	armor_hurtback:
		If true, armor will damage the attacker when attacked.
	
	armor_weight:
		The heaviness of the armor (the same as steel, by default) will be multiplied by this.
	
	ore_image (optional): Optional custom sprite for the ore. Will not be automatically colorized if specified.
	
	block_image (optional): Optional custom sprite for the block. Will not be automatically colorized if specified.
]]


instant_ores.register_metal({
	name = "gnu_slash_ores:mintium",
	description = "Mintium",
	rarity = 8,
	depth = 24,
	color = "#00C018:128",
	no_armor = true;
	durability = 140,
	power = 2,
	cooktime = 10,
})

--[[
Properties unique to metal:
	cooktime (optional): Optional recipe cooktime for converting lumps into ingots.
	lump_image (optional): Optional custom sprite for the lump. Will not be automatically colorized if specified.
	ingot_image (optional): Optional custom sprite for the ingot. Will not be automatically colorized if specified.
]]
instant_ores.register_crystal({
	name = "gnu_slash_ores:ubnium",
	description = "Ubnium",
	rarity = 13,
	depth = 32,
	color = "#FF8030:160",
	durability = 140,
	power = 3,
	speed = 2,
	armor_weight = 0.5,
})
--[[
Properties unique to crystal:
	shard_image (optional): Optional custom sprite for the shard. Will not be automatically colorized if specified.
	crystal image (optional): Optional custom sprite for the crystal. Will not be automatically colorized if specified.
]]

instant_ores.register_metal({
	name = "gnu_slash_ores:debinite",
	description = "Debinite",
	artificial = true,
	block_image = "default_coal_block.png^[colorize:#D01060:70",
	color = "#D01060:160",
	durability = 800,
	power = 5,
	speed = 4,
	hardness = 1,
})

minetest.register_craft({
	type = "shapeless",
	output = "gnu_slash_ores:debinite_ingot 9",
	recipe = {
		"gnu_slash_ores:ubnium_shard",
		"gnu_slash_ores:ubnium_shard",
		"gnu_slash_ores:ubnium_shard",
		"gnu_slash_ores:ubnium_shard",
		"gnu_slash_ores:ubnium_shard",
		"gnu_slash_ores:ubnium_shard",
		"gnu_slash_ores:ubnium_shard",
		"gnu_slash_ores:ubnium_shard",
		"gnu_slash_ores:mintium_ingot"
	}
})