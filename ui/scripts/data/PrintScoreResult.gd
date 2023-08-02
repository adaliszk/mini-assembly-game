extends Label


func _ready():
	text = "You scored %s!" % GameState.score
