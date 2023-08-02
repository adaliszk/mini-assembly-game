extends Node

var loader_fallback: String = "res://game/Main.tscn"
var loader_target: String:
	set(value):
		Log.info("Setting loader target to: %s" % value, "AppState")
		loader_target = value


