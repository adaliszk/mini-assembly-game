extends Label


func _ready() -> void:
	GameState.score_changed.connect(func(_state): _update())
	_update()


func _update() -> void:
	text = "%s rpm" % GameState.score
