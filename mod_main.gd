extends Node

const MOD_DIR = "Eltoro0815-BetterChanceForLegendaryWeapons/"
const LOG_NAME = "Eltoro0815-BetterChanceForLegendaryWeapons"
const MOD_NAME = "Eltoro0815-BetterChanceForLegendaryWeapons"
const CONFIG_NAME = "bclw_config"
const MOD_OPTIONS_MOD_ID = "dami-ModOptions"

var dir = ""
var ext_dir = ""

func _init(_modLoader = ModLoader):
	ModLoaderLog.info("Init", LOG_NAME)
	dir = ModLoaderMod.get_unpacked_dir() + MOD_DIR

	var progress_data_script = load("res://singletons/progress_data.gd")
	print(progress_data_script.VERSION)

	match progress_data_script.VERSION:
		"1.0.1.3":
			ext_dir = dir + "extensions-1.0.1.3/"
			
		_:
			ext_dir = dir + "extensions/"
	
	
	ModLoaderMod.install_script_extension(ext_dir + "singletons/item_service.gd")
	

func _ready(_modLoader = ModLoader):
	ModLoaderLog.info("Done", LOG_NAME)

	if ModLoaderMod.is_mod_loaded(MOD_OPTIONS_MOD_ID):
		# Install menu extension for mod options
		ModLoaderMod.install_script_extension(ext_dir + "menus/pages/menu_choose_options.gd")
	else:
		ModLoaderLog.info("Optionaler Mod \"%s\" nicht gefunden. Überspringe Menüerweiterung." % MOD_OPTIONS_MOD_ID, LOG_NAME)
	
	# Create and start the config manager
	var config_manager = load("res://mods-unpacked/Eltoro0815-BetterChanceForLegendaryWeapons/bclw_config_manager.gd").new()
	config_manager.name = "BCLWConfigManager"
	add_child(config_manager)


