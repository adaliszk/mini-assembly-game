extends Node

signal stage_start
signal stage_success
signal stage_failure


@export var should_heal: bool = true
@export var show_health: bool = true
@export var show_score: bool = true

@export var win_conditions: int = 1


func _ready() -> void:
	GameState.health = GameState.max_health


func meet_win_condition() -> void:
	Log.info("Win condition met!")
	win_conditions -= 1

	if win_conditions == 0:
		Log.info("All win conditions met!")
		emit_signal("stage_success")

