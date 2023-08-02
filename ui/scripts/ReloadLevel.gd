extends Button

@export var loader: PackedScene = preload("res://game/Loader.tscn")


func _pressed() -> void:
	get_tree().change_scene_to_packed(loader)
