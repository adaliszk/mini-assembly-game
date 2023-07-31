extends Label


func _ready():
	var file = FileAccess.open("res://git_version.txt", FileAccess.READ)
	self.text = "%s" % file.get_as_text()
