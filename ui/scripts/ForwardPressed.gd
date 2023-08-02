extends Container

@export var button: Button


func _input(event) -> void:
	if event is InputEventMouseButton:
		button._pressed()
