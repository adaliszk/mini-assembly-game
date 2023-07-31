extends Button

@export var loader: PackedScene = preload("res://game/Loader.tscn")
@export var level: String = "lv0_tutorial"


func _pressed() -> void:
	AppState.loader_target = "res://levels/%s/%s.tscn" % [level, level]
	get_tree().change_scene_to_packed(loader)
