extends ScrollContainer

@export var content_container: Control

func _ready():
	# Connect signal listeners
	Events.request_log.connect(log)
	Events.request_log_clear.connect(clear)
	

func log(text: String):
	# Log simply spawns a new label in the log and scrolls to it. Great for seeing what's happening.
	var label = Label.new()
	label.text = text
	content_container.add_child(label)
	call_deferred("scroll_bottom")

func scroll_bottom():
	set_deferred("scroll_vertical", get_v_scroll_bar().max_value)


func clear():
	for child in content_container.get_children():
		if child is Label:
			child.queue_free() 
