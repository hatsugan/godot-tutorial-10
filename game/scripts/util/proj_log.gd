extends Node

enum LogLevel {CRITICAL, ERROR, WARNING, INFO, DEBUG}
const log_str_format = "[{level}] [{timestamp}]  {message}"

var log_level: LogLevel

func _ready() -> void:
	log_level = log_level

func get_current_time_str() -> String:
	var current_time = Time.get_time_dict_from_system(false)
	return "{hour}:{minute}:{second}".format(current_time)


func log_to_console(level, message, leading_newline: bool = false, trailing_newline: bool = false) -> void:
	if level >= log_level:
		
		if leading_newline: print("") 
		
		print(log_str_format.format({
			"level": LogLevel.find_key(level),
			"timestamp": get_current_time_str(),
			"message": message
		}))
		
		if trailing_newline: print("") 

func critical(message: String, leading_newline: bool = false, trailing_newline: bool = false) -> void:
	log_to_console(LogLevel.CRITICAL, message, leading_newline, trailing_newline)
	
func error(message: String, leading_newline: bool = false, trailing_newline: bool = false) -> void:
	log_to_console(LogLevel.ERROR, message, leading_newline, trailing_newline)
	
func warning(message: String, leading_newline: bool = false, trailing_newline: bool = false) -> void:
	log_to_console(LogLevel.WARNING, message, leading_newline, trailing_newline)
	
func info(message: String, leading_newline: bool = false, trailing_newline: bool = false) -> void:
	log_to_console(LogLevel.INFO, message, leading_newline, trailing_newline)
	
func debug(message: String, leading_newline: bool = false, trailing_newline: bool = false) -> void:
	log_to_console(LogLevel.DEBUG, message, leading_newline, trailing_newline)
