class_name BCLWConfigManager
extends Node

const MOD_NAME = "Eltoro0815-BetterChanceForLegendaryWeapons"
const CONFIG_NAME = "bclw_config"
const DEFAULT_SETTINGS = {
	"LEGENDARY_WEAPON_CHANCE": 0.5
}

var ModsConfigInterface = null
var settings_dict = DEFAULT_SETTINGS.duplicate()
var _save_path = ""

func _ready():
	call_deferred("load_settings")

func load_settings():
	ModsConfigInterface = get_node_or_null("/root/ModLoader/dami-ModOptions/ModsConfigInterface")
	if ModsConfigInterface != null and is_instance_valid(ModsConfigInterface):
		# Load saved settings from file
		if has_valid_save_file():
			var saved_settings = get_json_dict_from_file(get_save_path())
			for key in settings_dict.keys():
				if saved_settings.has(key):
					settings_dict[key] = saved_settings[key]
		
		# Update ModOptions with loaded values
		for key in settings_dict.keys():
			ModsConfigInterface.on_setting_changed(key, settings_dict[key], MOD_NAME)
		
		# Connect to setting changes
		ModsConfigInterface.connect("setting_changed", self, "_on_setting_changed")
		
		print("BCLW Config loaded: ", settings_dict)

func _on_setting_changed(setting_name, value, mod_name):
	if mod_name == MOD_NAME:
		settings_dict[setting_name] = value
		save_settings()
		print("BCLW Setting changed: ", setting_name, " = ", value)

func get_save_path():
	var base_path = ProgressData.SAVE_PATH.get_base_dir()
	_save_path = base_path.plus_file("bclw_config/" + CONFIG_NAME + ".json")
	return _save_path

func has_valid_save_file():
	var f = File.new()
	return f.file_exists(get_save_path())

func save_settings():
	var save_path = get_save_path()
	if save_path.empty():
		return false
	
	var file_directory = save_path.get_base_dir()
	var dir = Directory.new()
	
	if not dir.dir_exists(file_directory):
		var makedir_error = dir.make_dir_recursive(file_directory)
		if makedir_error != OK:
			print("Error creating directory: ", file_directory)
			return false
	
	var file = File.new()
	var fileopen_error = file.open(save_path, File.WRITE_READ)
	
	if fileopen_error != OK:
		print("Error opening file: ", save_path)
		return false
	
	var save_string = to_json(settings_dict)
	file.store_string(save_string)
	file.flush()
	file.close()
	
	print("BCLW Settings saved: ", settings_dict)
	return true

func get_settings():
	return settings_dict

func get_json_dict_from_file(path: String) -> Dictionary:
	var file = File.new()
	if not file.file_exists(path):
		return {}
	
	var error = file.open(path, File.READ)
	if error != OK:
		return {}
	
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.parse(text)
	if json.error != OK:
		return {}
	
	return json.result
