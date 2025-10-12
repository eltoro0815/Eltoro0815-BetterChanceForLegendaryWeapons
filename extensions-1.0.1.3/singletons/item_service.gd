extends "res://singletons/item_service.gd"

var _RNG = RandomNumberGenerator.new()

# Helper function to get the legendary weapon chance from mod configuration
func get_legendary_weapon_chance() -> float:
	# Try ModLoader config first (permanent storage)
	if ModLoaderStore.mod_data.has("Eltoro0815-BetterChanceForLegendaryWeapons"):
		var mod_data = ModLoaderStore.mod_data["Eltoro0815-BetterChanceForLegendaryWeapons"]
		if mod_data.current_config and mod_data.current_config.data.has("LEGENDARY_WEAPON_CHANCE"):
			return mod_data.current_config.data["LEGENDARY_WEAPON_CHANCE"]
	
	# Fallback to ModOptions (temporary)
	var ModsConfigInterface = get_node_or_null("/root/ModLoader/dami-ModOptions/ModsConfigInterface")
	if is_instance_valid(ModsConfigInterface):
		var settings = ModsConfigInterface.get_settings("Eltoro0815-BetterChanceForLegendaryWeapons")
		if settings.has("LEGENDARY_WEAPON_CHANCE"):
			return settings["LEGENDARY_WEAPON_CHANCE"]
	
	# Final fallback to default value
	return 0.5

func get_rand_item_for_wave(wave:int, type:int, excluded_items:Array = [], owned_items:Array = [], fixed_tier:int = -1) -> ItemParentData:
	var _new_item = .get_rand_item_for_wave(wave, type, excluded_items, owned_items, fixed_tier)

	# Handle logic for item replacement
	if _new_item != null:
		return handle_legendary_weapon_replacement(type, _new_item)
	else:
		push_error("function _get_rand_item_for_wave from res://singletons/item_service.gd does not return an item")

	return _new_item  # Return the new item or null if not found



# Helper function to handle legendary weapon replacement logic
func handle_legendary_weapon_replacement(type:int, _new_item:ItemParentData) -> ItemParentData:
	if type == TierData.WEAPONS and _new_item.tier == Tier.LEGENDARY:
		# Do not replace an already legendary weapon by a random one
		if hasLegendaryClass(_new_item):
			return _new_item

		var chance_change_to_legendary_weapon = get_legendary_weapon_chance()
		var rand_chance_change_to_legendary_weapon = randf()

		if rand_chance_change_to_legendary_weapon <= chance_change_to_legendary_weapon:
			var legendary_weapons = getAllLegendaryWeaponsFilteredByType(type)
			_RNG.randomize()
			var rand_index = _RNG.randi_range(0, legendary_weapons.size() - 1)
			return legendary_weapons[rand_index]

	return _new_item  # Return the item if no replacement occurred

func getAllLegendaryWeaponsFilteredByType(type:int) -> Array:
	var weapon_pool = get_pool(Tier.LEGENDARY, TierData.WEAPONS)
	var legendary_weapons = []
	for weapon in weapon_pool:
		if hasLegendaryClass(weapon):
			if weapon.type == type:
				legendary_weapons.append(weapon)
	return legendary_weapons

func hasLegendaryClass(weapon) -> bool:
	for set in weapon.sets:
		if set.my_id == "set_legendary":
			return true
	return false
