extends Button

@export var level: String = "lv0_tutorial"


func _pressed() -> void:
	Log.info("Setting level to: %s" % level, str(self))
	AppState.loader_target = "res://levels/%s/%s.tscn" % [level, level]
	get_tree().change_scene_to_file("res://game/Loader.tscn")
