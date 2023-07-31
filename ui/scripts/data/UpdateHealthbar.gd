extends ProgressBar


func _ready():
	GameState.health_changed.connect(func(_value): _update())
	_update()


func _update() -> void:
	max_value = GameState.max_health
	value = GameState.health

