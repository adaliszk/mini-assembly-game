extends Node

signal game_start
signal game_pause
signal game_resume
signal game_over

signal increase_score(amount: int)
signal reduce_score(amount: int)
signal score_changed(amount: int)

signal increase_health(amount: int)
signal reduce_health(amount: int)
signal health_changed(amount: int)

signal level_changed(level: String)
signal stage_changed(stage: String)

var level: String = "N/A":
	set(value):
		level = value
		queue_update("level_changed")

var stage: String = "N/A":
	set(value):
		stage = value
		queue_update("stage_changed")

var score = 0:
	set(value):
		score = value
		queue_update("score_changed")

var max_health = 100
var health = 100:
	set(value):
		health = clamp(value, 0, max_health)
		queue_update("health_changed")


func queue_update(event: String = "*") -> void:
	var event_list = ["level_changed", "stage_changed", "score_changed", "health_changed"]
	for event_name in event_list:
		if event == "*" or event_name == event:
			var property = event_name.split("_")[0]
			emit_signal(event_name, self[property])
