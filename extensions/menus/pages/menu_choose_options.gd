extends "res://ui/menus/pages/menu_choose_options.gd"

func _ready():
	var ModsConfigInterface = get_node_or_null("/root/ModLoader/dami-ModOptions/ModsConfigInterface")
	if is_instance_valid(ModsConfigInterface):
		# Connect to setting changes to save to ModLoader config
		ModsConfigInterface.connect("setting_changed", self, "_on_setting_changed")
		if ModsConfigInterface.has_user_signal("bclw_container_ready"):
			ModsConfigInterface.emit_signal("bclw_container_ready", self)

func _on_setting_changed(setting_name: String, value, mod_name: String):
	# Only handle our mod's settings
	if mod_name == "Eltoro0815-BetterChanceForLegendaryWeapons":
		# Save to ModLoader config for permanent storage
		if ModLoaderStore.mod_data.has(mod_name):
			var mod_data = ModLoaderStore.mod_data[mod_name]
			if mod_data.current_config:
				mod_data.current_config.data[setting_name] = value
				mod_data.current_config.save_to_file()
				print("Saved setting %s = %s for mod %s" % [setting_name, value, mod_name])

