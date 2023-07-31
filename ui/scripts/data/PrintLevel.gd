extends Label


func _ready() -> void:
	GameState.level_changed.connect(func(_state): _update())
	_update()


func _update() -> void:
	text = "%s: %s" % [ GameState.level, GameState.stage ]
