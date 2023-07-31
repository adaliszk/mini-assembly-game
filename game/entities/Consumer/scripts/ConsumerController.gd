extends Node2D

signal health_changed(health: int)

@export var max_health: int = 90
@export var health: int = 60

@onready var gear: Gear = $PowerConsumer
@onready var timer_label: Label = $UI/TimeLeft
@onready var timer: Timer = $Timer


func _ready():
	timer_label.text = str(health)
	gear.rotated.connect(func(): tick_up())
	timer.timeout.connect(func(): tick_down())
	timer.wait_time	= 1.0
	timer.start(1)


func tick_down():
	if health > 0:
		health -= 1
		emit_signal("health_changed", health)
		timer_label.text = str(health)
	else:
		GameState.health -= 1

func tick_up():
	if health < max_health:
		health += 1
		emit_signal("health_changed", health)
		timer_label.text = str(health)
		GameState.health += 1
