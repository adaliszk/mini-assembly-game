extends Node2D

signal power_changed(state: bool)
signal connection_changed(state: bool)
signal satisfied
signal scored

@export var max_health: int = 90
@export var health: int = 60

@onready var gear: Gear = $Consumer
@onready var timer_label: Label = $UI/TimeLeft
@onready var timer: Timer = $Timer


func _ready():
	timer_label.text = str(health)
	timer.timeout.connect(func(): tick_down())
	gear.score.connect(func(): tick_up())
	gear.score.connect(func(): emit_signal("scored"))
	gear.connection_changed.connect(func(state): emit_signal("connection_changed", state))
	gear.power_changed.connect(func(state): emit_signal("power_changed", state))


func tick_down():
	if health > 0:
		health -= 1
		timer_label.text = str(health)
	else:
		GameState.health -= 1

func tick_up():
	if health < max_health:
		health += 1
		timer_label.text = str(health)
		GameState.health += 1
	if health >= max_health:
		emit_signal("satisfied")
