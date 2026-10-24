class_name AVFXInstance extends Node

var target: Monster
var resource: AVFXResource

func _init(res: AVFXResource, targ: Monster):
	resource = res
	target = targ

func execute_fx():
	resource._do(self)

func finish():
	AvfxManager.remove_fx(self)
