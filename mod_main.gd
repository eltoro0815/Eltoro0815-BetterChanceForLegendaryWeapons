extends Node



const MOD_DIR = "Eltoro0815-BetterChanceForLegendaryWeapons/"
const LOG_NAME = "Eltoro0815-BetterChanceForLegendaryWeapons"

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

