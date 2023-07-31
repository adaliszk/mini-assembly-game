extends Node

enum Level { VERBOSE, DEBUG, INFO, WARN, ERROR, FATAL }

const level: Level = Level.DEBUG

# region Public API

func info(message: String, context = _get_context()) -> void:
	if level <= Level.INFO:
		send_message(Level.INFO, message, context)


func debug(message: String, context = _get_context()) -> void:
	if level <= Level.DEBUG:
		send_message(Level.DEBUG, message, context)


func warn(message: String, context = _get_context()) -> void:
	if level <= Level.WARN:
		send_message(Level.WARN, message, context)


func error(message: String, context = _get_context()) -> void:
	if level <= Level.ERROR:
		send_message(Level.ERROR, message, context)


func fatal(message: String, context = _get_context()) -> void:
	if level <= Level.FATAL:
		send_message(Level.FATAL, message, context)


func verbose(message: String, context = _get_context()) -> void:
	if level <= Level.VERBOSE:
		send_message(Level.VERBOSE, message, context)

# endregion

# region Internal Logic

func _get_context() -> String:
	var context = get_stack().pop_back()
	var name = context.source.split("/")[-1].split(".")[0]
	return "%s.%s()" % [ name.trim_prefix("_"), context.function ]


func send_message(verbosity: Level, message: String, context: String) -> void:
	_add_message(verbosity, message, context)


func _add_message(verbosity: Level, message: String, context: String) -> void:
	var line = "%s:%s: %s" % [Log.Level.keys().pop_at(verbosity)[0], context, message]
	print(line)

# endregion
