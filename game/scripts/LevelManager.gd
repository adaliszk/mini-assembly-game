extends Node2D

@onready var stage_container: Node2D = $Stages
var current_stage: Node2D


func _ready() -> void:
	for stage in stage_container.get_children():
		stage.hide()

	current_stage = stage_container.get_child(0)

	GameState.level = self.name
	GameState.stage = current_stage.name
	current_stage.show()
	GameState.queue_update()

