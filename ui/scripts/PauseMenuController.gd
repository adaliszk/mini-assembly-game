@tool
extends CanvasLayer

@onready var menu_button: Button = $Viewport/Container/Button
@onready var menu_drawer: PanelContainer = $MenuDrawer
@onready var drawer_button: Button = $MenuDrawer/Layout/Header/Button
@onready var shadow: Container = $Shadow


func _ready() -> void:
	menu_button.pressed.connect(func(): show_drawer())
	drawer_button.pressed.connect(func(): hide_drawer())
	hide_drawer()


func show_drawer() -> void:
	menu_drawer.position.x = 0
	get_tree().paused = true
	shadow.show()


func hide_drawer() -> void:
	menu_drawer.position.x = -menu_drawer.size.x
	get_tree().paused = false
	shadow.hide()

