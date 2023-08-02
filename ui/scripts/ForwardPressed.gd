extends Container

@export var button: Button


func _input(event) -> void:
	if event is InputEventMouseButton:
		button.emit_signal("pressed")
		button._pressed()
