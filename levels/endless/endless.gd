extends Node

enum SpawnType { POWER_NODE, SCORE_NODE }

const SPAWN_CHECKER = preload("res://game/entities/SpawnChecker.tscn")
const POWER_NODE = preload("res://game/entities/Power/Power.tscn")
const SCORE_NODE = preload("res://game/entities/Consumer/Consumer.tscn")

@export var map: TileMap
@export var actions: Container



var spawn_locations: Dictionary = {}
var spawn_queue: Array
var spawn_check: Area2D

var spawn_timer: Timer = Timer.new()
var upgrade_timer: Timer = Timer.new()

var consumers: Array


func _ready():
	AppState.loader_target = "res://levels/endless/endless.tscn"
	GameState.health = GameState.max_health
	GameState.score = 0
	GameState.game_over.connect(func(): get_tree().change_scene_to_file("res://game/Results.tscn"))
	
	spawn_check = SPAWN_CHECKER.instantiate()
	spawn_check.size = 3
	map.add_child(spawn_check)
	
	spawn_timer.wait_time = 3
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(func(): spawn(SpawnType.SCORE_NODE))
	
	upgrade_timer.wait_time = 5
	upgrade_timer.autostart = true
	upgrade_timer.timeout.connect(func(): upgrade_random())
	add_child(upgrade_timer)
	
	spawn(SpawnType.POWER_NODE)
	spawn(SpawnType.SCORE_NODE)


func _physics_process(_delta) -> void:
	if spawn_queue.size() > 0:
		var spawn_type = spawn_queue.pop_front()
		var point = generate_point()
		if point != null and point != Vector2.ZERO:
			var item = self[spawn_type].instantiate()
			item.position = point
			if item is Consumer:
				item.scored.connect(func(): add_score())
				consumers.append(item)
			map.add_child(item)


func add_score() -> void:
	GameState.score += 1


func spawn(type: SpawnType) -> void:
	var type_key = SpawnType.keys()[type]
	Log.info("Spawn %s at a random location!" % type_key)
	spawn_queue.append(type_key)


func upgrade_random() -> void:
	Log.info("Upgrading a consumer and adding more actions...")
	var consumer = consumers[randi() % consumers.size()]
	consumer.demand_time *= 0.8
	
	var action_items = []
	for i in actions.get_children():
		action_items.append(i)
	
	var action = action_items[randi() % action_items.size()]
	action.inventory += 2


func generate_point() -> Vector2:
	var margin = Vector2i(32, 128)
	var p1 = Vector2i.ZERO + margin
	var p2 = get_viewport().size - margin
	Log.info("Generate point within: %s -> %s" % [str(p1), str(p2)])
	
	var region_size_x = 5
	var region_size_y = 3
	var region_size = Vector2(
		(p2.x - p1.x) / region_size_x,
		(p2.y - p1.y) / region_size_y
	)
	
	var point: Vector2
	for ry in range(region_size_y):
		for rx in range(region_size_x):
			var region_code = "[%s,%s]" % [rx, ry]
			var region = spawn_locations.get(region_code, false)
			Log.verbose("Check region %s -> %s" % [region_code, region])
			if region:
				continue
				
			if randf_range(0, 1) > 0.5:
				continue
			
			spawn_locations[region_code] = true
			spawn_locations["[%s,%s]" % [rx -1, ry]] = true
			spawn_locations["[%s,%s]" % [rx -1, ry +1]] = true
			spawn_locations["[%s,%s]" % [rx -1, ry -1]] = true
			spawn_locations["[%s,%s]" % [rx +1, ry]] = true
			spawn_locations["[%s,%s]" % [rx +1, ry +1]] = true
			spawn_locations["[%s,%s]" % [rx +1, ry -1]] = true
			spawn_locations["[%s,%s]" % [rx, ry +1]] = true
			spawn_locations["[%s,%s]" % [rx, ry -1]] = true
			
			var rx_start = Vector2(p1) + Vector2(region_size.x * rx, region_size.y * ry)
			var rx_end = rx_start + region_size
			var rx_center = rx_start + ((rx_end - rx_start) / 2)
			return rx_center
			
			spawn_check.position = rx_center
			
			var overlapping = spawn_check.get_overlapping_bodies()
			Log.debug("Check collisions at %s -> %s" % [rx_center, overlapping])
			if overlapping.size() == 0:
				return rx_center
	
	return point
