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
