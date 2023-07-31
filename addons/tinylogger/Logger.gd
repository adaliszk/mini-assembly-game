extends Node

enum LEVEL { VERBOSE, DEBUG, INFO, WARN, ERROR, FATAL }

@export var level: LEVEL = LEVEL.DEBUG

var threads: Array = []


# region Lifecycle

func _init() -> void:
	if not OS.is_debug_build():
		level = LEVEL.INFO


func _exit_tree() -> void:
	for thread in threads:
		thread.wait_to_finish()


# endregion

# region Public API

func info(message: String, context = _get_context()) -> void:
	if level <= LEVEL.INFO:
		send_message(LEVEL.INFO, message, context)


func debug(message: String, context = _get_context()) -> void:
	if level <= LEVEL.DEBUG:
		send_message(LEVEL.DEBUG, message, context)


func warn(message: String, context = _get_context()) -> void:
	if level <= LEVEL.WARN:
		send_message(LEVEL.WARN, message, context)


func error(message: String, context = _get_context()) -> void:
	if level <= LEVEL.ERROR:
		send_message(LEVEL.ERROR, message, context)


func fatal(message: String, context = _get_context()) -> void:
	if level <= LEVEL.FATAL:
		send_message(LEVEL.FATAL, message, context)


func verbose(message: String, context = _get_context()) -> void:
	if level <= LEVEL.VERBOSE:
		send_message(LEVEL.VERBOSE, message, context)

# endregion

# region Internal Logic

func _get_context() -> String:
	var context = get_stack().pop_back()
	var name = context.source.split("/")[-1].split(".")[0]
	return "%s.%s()" % [ name.trim_prefix("_"), context.function ]


func send_message(verbosity: LEVEL, message: String, context: String) -> void:
	var thread = Thread.new()
	threads.append(thread)
	thread.start(func(): _add_message(verbosity, message, context))
	await thread.wait_to_finish()
	threads.erase(thread)


func _add_message(verbosity: LEVEL, message: String, context: String) -> void:
	var line = "%s:%s: %s" % [LEVEL.keys().pop_at(verbosity)[0], context, message]
	print(line)

# endregion
