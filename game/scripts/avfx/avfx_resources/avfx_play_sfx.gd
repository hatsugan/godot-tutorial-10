class_name AVFXPlaySFXResource extends AVFXResource

@export var clip: AudioStream

func _do(instance: AVFXInstance):
	Events.on_avfx_sfx.emit(instance, clip)
