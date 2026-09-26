@abstract
class_name AbstractMethod
extends RefCounted

var points: Array[Vector3] = []

@abstract func get_instruction(index:int) -> String

@abstract func add_point(location:Vector3, manager:TheMan)

## Args - position:Vector3, rotation:Quaternion, vFoV:float
signal cam_estimated
