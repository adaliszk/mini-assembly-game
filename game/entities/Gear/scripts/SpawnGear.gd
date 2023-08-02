@tool
extends Button

signal object_spawned(object: Node)

@export var inventory: int = 10:
	set(value):
		if label:
			label.text = str(value)
		inventory = value

@export var spawn_location: Node = self
@export var spawn_object: PackedScene = preload("res://game/entities/Gear/Gear.tscn")
@export var spawn_container: TileMap

@onready var label: Label = $Layout/Label


func _ready():
	label.text = str(inventory)


func _pressed() -> void:
	if inventory > 0:
		var gear = spawn_object.instantiate()
		spawn_container.add_child(gear)
		gear.position = spawn_location.global_position
		gear.is_dragging = true
		inventory -= 1
		emit_signal("object_spawned", gear)
	label.text = str(inventory)
