extends "res://singletons/item_service.gd"

var _RNG = RandomNumberGenerator.new()


func _get_rand_item_for_wave(wave:int, player_index:int, type:int, rand_item_args) -> ItemParentData:


	var _new_item = ._get_rand_item_for_wave(wave, player_index, type, rand_item_args)

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

		var chance_change_to_legendary_weapon = 0.50
		var rand_chance_change_to_legendary_weapon = randf()

		if rand_chance_change_to_legendary_weapon <= chance_change_to_legendary_weapon:
			var legendary_weapons = getAllLegendaryWeapons()
			_RNG.randomize()
			var rand_index = _RNG.randi_range(0, legendary_weapons.size() - 1)
			return legendary_weapons[rand_index]

	return _new_item  # Return the item if no replacement occurred

# Helper functions remain unchanged
func getAllLegendaryWeapons() -> Array:
	var weapon_pool = get_pool(Tier.LEGENDARY, TierData.WEAPONS)
	var legendary_weapons = []
	for weapon in weapon_pool:
		if hasLegendaryClass(weapon):
			legendary_weapons.append(weapon)
	return legendary_weapons

func hasLegendaryClass(weapon) -> bool:
	for set in weapon.sets:
		if set.my_id == "set_legendary":
			return true
	return false
