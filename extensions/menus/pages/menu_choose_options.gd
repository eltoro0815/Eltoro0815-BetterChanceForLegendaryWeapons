extends "res://ui/menus/pages/menu_choose_options.gd"

func _ready():
	var ModsConfigInterface = get_node_or_null("/root/ModLoader/dami-ModOptions/ModsConfigInterface")
	if is_instance_valid(ModsConfigInterface) and ModsConfigInterface.has_user_signal("bclw_container_ready"):
		ModsConfigInterface.emit_signal("bclw_container_ready", self)

