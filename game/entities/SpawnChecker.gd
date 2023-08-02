@tool
extends Area2D

@export var size: int = 1:
	set(value):
		size = value
		update_shape()

var collider: CollisionShape2D = CollisionShape2D.new()


func _ready() -> void:
	update_shape()
	add_child(collider)


func update_shape() -> void:
	if collider != null:
		collider.shape = CircleShape2D.new()
		collider.shape.radius = EntityUtils.size_to_boundary_px(size)
