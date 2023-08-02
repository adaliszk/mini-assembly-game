@tool
class_name GameStateController
extends CanvasLayer

@export var score_widget: Container
@export var show_score: bool = true:
	set(value):
		score_widget.visible = value
		show_score = value

@export var health_widget: Container
@export var show_health: bool = true:
	set(value):
		health_widget.visible = value
		show_health = value

@export var stage_widget: Label
@export var show_stage: bool = true:
	set(value):
		stage_widget.visible = value
		show_stage = value
