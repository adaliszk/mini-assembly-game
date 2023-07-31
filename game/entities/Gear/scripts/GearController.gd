@tool
class_name Gear
extends RigidBody2D

signal power_changed(state: bool)
signal connection_changed(state: bool)
signal score


@export var locked: bool = false:
	set(value):
		freeze = value
		locked = value
		update()

@export var should_listen: bool = false
@export var connected: Gear:
	set(value):
		Log.info("Set connection to: %s" % value, str(self))
		if value == null and connected is Gear and connected.connected == self:
			connected.connected = null

		powered = true if value and value.powered else false

		if should_listen and value == null:
			Log.debug("Unsubscribe from score events!", str(self))
			connected.score.disconnect(_on_score_timer.bind(self))

		if should_listen and value is Gear:
			Log.info("Unsubscribe from score events from: %s" % value, str(self))
			value.score.connect(_on_score_timer.bind(self))

		freeze = value is Gear if  not locked else freeze
		connected = value

		emit_signal("connection_changed", value is Gear)

@export var powered: bool = false:
	set(value):
		powered = value
		emit_signal("power_changed", value)

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
@onready var score_timer: Timer = $ScoreTimer

@onready var debug_info: MarginContainer = $DebugInfo
@onready var debug_data: Container = $DebugInfo/Widget/Container/Data

var is_dragging: bool = false
var drag_speed: float = 6.0
var valid_connection: Gear = null
var collider: CollisionShape2D


func _ready() -> void:
	debug_info.hide()
	score_timer.timeout.connect(_on_score_timer.bind(self))
	score.connect(func(): Log.debug("score!", str(self)))
	handler.pressed.connect(func(): _on_drag_start())
	update()


func _on_score_timer(_event) -> void:
	if Engine.is_editor_hint():
		return
	emit_signal("score")


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

	if connected and connected.connected == null and not connected.powered:
		connected = null
		score_timer.stop()


func _process(delta) -> void:
	if Engine.is_editor_hint():
		return
	if connected == null and not powered:
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

	score_timer.wait_time = INF if not connected else speed * 0.5
	score_timer.start()


func update_color() -> void:
	if texture == null:
		return
	texture.color = color
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
	update()

func update_debuginfo() -> void:
	if debug_info:
		for label in debug_data.get_children():
			if label is Label:
				var property_name = label.name.to_lower()
				label.text = "%s=%s" % [property_name, get(property_name)]
