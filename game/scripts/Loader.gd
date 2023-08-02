extends Node

enum LoadStatus {
	THREAD_LOAD_INVALID_RESOURCE,
	THREAD_LOAD_IN_PROGRESS,
	THREAD_LOAD_FAILED,
	THREAD_LOAD_LOADED,
}

const LOADER_TIPS = [
	"Locating the required gigapixels to render...",
	"Spinning up the hamster...",
	"Programming the flux capacitor...",
]


@export var progress_bar: ProgressBar
@export var progress_tip: Label


func _enter_tree() -> void:
	Log.info("Loadin level: %s" % AppState.loader_target)
	ResourceLoader.load_threaded_request(AppState.loader_target)
	progress_tip.text = LOADER_TIPS[randi() % LOADER_TIPS.size()]


func _physics_process(_delta: float) -> void:
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(AppState.loader_target, progress)
	Log.debug("Threaded load: %s" % [LoadStatus.keys()[status]])

	if status == LoadStatus.THREAD_LOAD_FAILED:
		Log.error("Threaded load failed: %s" % [LoadStatus.keys()[status]])

	if status == LoadStatus.THREAD_LOAD_IN_PROGRESS:
		var sum = 0.0
		for p in progress:
			sum += p
		Log.debug("Threaded load progress: %s" % [sum])
		progress_bar.value = sum

	if status == LoadStatus.THREAD_LOAD_LOADED:
		Log.info("Threaded load completed")
		var scene = ResourceLoader.load_threaded_get(AppState.loader_target)
		get_tree().change_scene_to_packed(scene)
