@tool
class_name Gear
extends RigidBody2D

signal rotated
signal cycled


@export var locked: bool = false:
	set(value):
		freeze = value
		locked = value
		update()

@export var connected: Gear:
	set(value):
		powered = true if value and value.powered else false
		connected = value

@export var powered: bool = false

@export var torque: float = 1.0:
	get:
		if connected:
			var connected_torque = connected.torque if connected.powered else 0.0
			return connected_torque * (float(tooth_count) / float(connected.tooth_count))
		return torque if abs(direction) > 0 else 0.0

@export var speed: float = 1.0:
	get:
		if connected:
			var connected_speed = connected.speed if connected.powered else 0.0
			return connected_speed * (float(connected.tooth_count) / float(tooth_count))
		return speed if abs(direction) > 0 else 0.0

@export_range(-1, 1) var direction: int = 0:
	get:
		if connected:
			return connected.direction * -1 if connected.powered else 0
		return direction if powered else 0

@export var tooth_count: int = 0:
	get:
		if texture:
			return texture.tooth_count
		return 0

@export var color: Color = Color(0, 0, 0):
	set(value):
		color = value
		update()

@export var size: float = 1:
	set(value):
		size = snapped(value, 0.01)
		update()

@onready var gizmo: TilemapGizmo = $TilemapGizmo
@onready var texture: Node2D = $Texture
@onready var handler: Button = $Handler

@onready var debug_info: MarginContainer = $DebugInfo
@onready var debug_data: Container = $DebugInfo/Widget/Container/Data


var rotation_slice: float = PI / 8
var rotation_phase: int = 1
var cycle_count: int = 0

var is_dragging: bool = false
var drag_speed: float = 6.0
var valid_connection: Gear = null
var collider: CollisionShape2D


func _ready() -> void:
	debug_info.hide()
	handler.pressed.connect(func(): _on_drag_start())
	update()


func _on_drag_start() -> void:
	if locked:
		return
	is_dragging = true
	freeze = false


func _on_drag_end() -> void:
	if locked:
		return
	connected = valid_connection
	is_dragging = false
	update_connections()



func _on_dragging(delta) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var target_position = gizmo.map_to_local(gizmo.local_to_map(mouse_position))
	var velocity = target_position - global_position

	global_position = global_position.lerp(target_position, delta * drag_speed)
	var overlapping = move_and_collide(velocity * drag_speed * delta, true)
	valid_connection = overlapping.get_collider() if overlapping else null


func _input(event) -> void:
	if is_dragging:
		if event.is_action_released("scale_up") and size < 3:
			size += 0.5
		if event.is_action_released("scale_down") and size > 0.5:
			size -= 0.5
		if event.is_action_released("drop_item"):
			_on_drag_end()
		return


func _physics_process(delta) -> void:
	if OS.is_debug_build():
		update_debuginfo()

	if Engine.is_editor_hint():
		return

	if is_dragging:
		_on_dragging(delta)

	if texture.rotation >= PI * 2:
		emit_signal("cycled")
		texture.rotation = 0
		rotation_phase = 1
		cycle_count += 1

	if texture.rotation >= rotation_slice * rotation_phase:
		emit_signal("rotated")
		rotation_phase += 1

func _process(delta) -> void:
	if Engine.is_editor_hint():
		return

	texture.rotation += direction * speed * PI * delta


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = gizmo._get_configuration_warnings()
	return warnings


func update() -> void:
	if texture == null:
		return

	var gear_size = size * GameSettings.CELL_SIZE * 4
	update_color()

	if OS.is_debug_build():
		debug_info.add_theme_constant_override("margin_top", gear_size + 24)

	if collider:
		collider.queue_free()

	collider = CollisionShape2D.new()
	collider.shape = CircleShape2D.new()
	collider.shape.radius = gear_size + texture.tooth_length / 8
	add_child(collider)

	handler.custom_minimum_size = Vector2(gear_size * 2, gear_size * 2)
	texture.size = ceil(gear_size)


func update_color() -> void:
	if texture == null:
		return
	texture.color = color if locked == false else Color(0.45, 0.45, 0.45)
	texture.queue_redraw()


func update_connections() -> void:
	for node in get_colliding_bodies():
		if node is Gear == false:
			continue
		Log.debug("Check connection: %s -> %s" % [self, node])
		# Connect up powered gears
		if not self.powered and node.powered:
			self.connected = node
		if not node.powered and not node.connected:
			node.connected = self

func update_debuginfo() -> void:
	if debug_info:
		debug_info.show()
		for label in debug_data.get_children():
			if label is Label:
				var property_name = label.name.to_lower()
				label.text = "%s=%s" % [property_name, get(property_name)]
