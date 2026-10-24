extends Node

var active_fx_count: int = 0
var effect_group_queue: Array[Node] = []
var effect_group_current: Node
var active: bool

func _process(delta: float) -> void:
	if active and effect_group_current == null:
		if effect_group_queue.size() == 0:
			#pass
			Events.on_avfx_block_end.emit()
			active = false
		else:
			Events.on_avfx_block_start.emit()
			effect_group_current = effect_group_queue.pop_front()
			active_fx_count = effect_group_current.get_child_count()
			for instance in effect_group_current.get_children():
				instance.execute_fx()

func queue_avfx_fx_group(resources: Array[AVFXResource], monster: Monster):
	active = true
	var avfx_group = Node.new()
	add_child(avfx_group)
	effect_group_queue.append(avfx_group)
	
	for avfx_res in resources:
		var target = monster if avfx_res.target_self else MonsterController.get_monster_opponent(monster)
		var instance = avfx_res.generate_instance(target)
		avfx_group.add_child(instance)
		instance.name = avfx_res.get_script().get_global_name() + "_" + avfx_res.resource_path.get_file()
	
	#ProjLog.debug("QUEUE, active_count = %d"%active_fx_count)
	#if active_fx_count != 0:
		#call_deferred("emit_on_avfx_block_start")  # Deferring so hits next process loop

func remove_fx(avfx_instance: AVFXInstance):
	avfx_instance.queue_free()  # Not using queue free, so it happens instantaneously
	active_fx_count -= 1

	if active_fx_count == 0:
		effect_group_current.queue_free()
		effect_group_current = null
		#call_deferred("emit_on_avfx_block_end")
		
	#ProjLog.debug("REMOVE, active_count = %d"%active_fx_count)

func emit_on_avfx_block_start() -> void:
	Events.on_avfx_block_start.emit()
	
func emit_on_avfx_block_end() -> void:
	ProjLog.debug("EMIT block end! no items")
	Events.on_avfx_block_end.emit()
