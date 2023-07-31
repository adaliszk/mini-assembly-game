class_name Log
extends Node

enum Level { VERBOSE, DEBUG, INFO, WARN, ERROR, FATAL }

const level: Level = Level.DEBUG

# region Public API

static func info(message: String, context = _get_context()) -> void:
	if Log.level <= Log.Level.INFO:
		send_message(Log.Level.INFO, message, context)


static func debug(message: String, context = _get_context()) -> void:
	if Log.level <= Log.Level.DEBUG:
		send_message(Log.Level.DEBUG, message, context)


static func warn(message: String, context = _get_context()) -> void:
	if Log.level <= Log.Level.WARN:
		send_message(Log.Level.WARN, message, context)


static func error(message: String, context = _get_context()) -> void:
	if Log.level <= Log.Level.ERROR:
		send_message(Log.Level.ERROR, message, context)


static func fatal(message: String, context = _get_context()) -> void:
	if Log.level <= Log.Level.FATAL:
		send_message(Log.Level.FATAL, message, context)


static func verbose(message: String, context = _get_context()) -> void:
	if Log.level <= Log.Level.VERBOSE:
		send_message(Log.Level.VERBOSE, message, context)

# endregion

# region Internal Logic

static func _get_context() -> String:
	var context = get_stack().pop_back()
	var name = context.source.split("/")[-1].split(".")[0]
	return "%s.%s()" % [ name.trim_prefix("_"), context.function ]


static func send_message(verbosity: Level, message: String, context: String) -> void:
	_add_message(verbosity, message, context)


static func _add_message(verbosity: Level, message: String, context: String) -> void:
	var line = "%s:%s: %s" % [Log.Level.keys().pop_at(verbosity)[0], context, message]
	print(line)

# endregion
