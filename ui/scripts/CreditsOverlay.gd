extends Container

func _ready():
	if OS.get_name() != "HTML5":
		$Body.meta_clicked.connect(func(meta): OS.shell_open(meta))
