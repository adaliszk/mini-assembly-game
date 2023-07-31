@tool
extends Node2D

var color: Color = Color(1.0, 1.0, 1.0)
var background: Color = Color(0.0, 0.0, 0.0)

# Tooth settings´
var tooth_count: int = 32
var tooth_length: float = 48.0
var tooth_width: float = 32.0

var size: float = 64.0:
	set(value):
		size = value
		queue_redraw()
	get:
		return size


func _draw() -> void:
	if size == null:
		return

	var wheel_radius = size * 4
	var tooth_radius = wheel_radius + tooth_length

	draw_circle(Vector2(0, 0), wheel_radius + 2.0, color)

	# Calculate possible teeth count
	tooth_count = int(2 * PI * tooth_radius / (tooth_length * 2))

	# Draw Teeth
	for i in range(tooth_count):
		var angle = i * 2 * PI / tooth_count
		var angle_left = (i - 0.2) * 2 * PI / tooth_count
		var angle_right = (i + 0.2) * 2 * PI / tooth_count
		var tooth_tl = Vector2(tooth_radius, 0).rotated(angle_left)
		var tooth_tr = Vector2(tooth_radius, 0).rotated(angle_right)
		var tooth_tip = Vector2(tooth_radius, 0).rotated(angle)
		var tooth_base = tooth_tip - Vector2(tooth_length, 0).rotated(angle)
		var tooth_left = tooth_base + Vector2(0, tooth_width).rotated(angle)
		var tooth_right = tooth_base - Vector2(0, tooth_width).rotated(angle)
		draw_polygon([tooth_tl, tooth_left, tooth_right], [color, color, color])
		draw_polygon([tooth_tr, tooth_left, tooth_right], [color, color, color])
		draw_polygon([tooth_tl, tooth_tr, tooth_base], [color, color, color])
