extends Node2D

const end_screen = preload("res://game/Results.tscn")

@onready var state_panel: GameStateController = $GameStatePanel
@onready var stage_container: Node2D = $StageContainer

var stage_scenes: Array = []
var stage_index: int = -1
var current_stage: Node2D


func _ready() -> void:
	stage_scenes = stage_container.scenes
	next_stage()


func next_stage() -> void:
	stage_index += 1

	if current_stage:
		stage_container.remove_child(current_stage)

	if stage_index >= stage_scenes.size():
		get_tree().change_scene_to_packed(end_screen)
		return

	current_stage = stage_scenes[stage_index].instantiate()
	stage_container.add_child(current_stage)

	state_panel.show_health = current_stage.show_health
	state_panel.show_score = current_stage.show_score

	if current_stage.win_conditions == 0:
		next_stage()
		return

	current_stage.stage_success.connect(func(): next_stage())

	GameState.level = self.name
	GameState.stage = current_stage.name
	GameState.queue_update()
