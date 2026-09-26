extends Node3D

@export var sceneroot:TheMan

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if sceneroot.zeroPoint != null:
		global_position = sceneroot.zeroPoint.global_position
		global_basis = sceneroot.zeroPoint.global_basis
