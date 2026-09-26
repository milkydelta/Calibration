extends Button

@export var method: String = ""
var sceneroot: TheMan
var pcl: CanvasLayer

func _ready() -> void:
	sceneroot = get_node_or_null("/root/Node3D")
	pcl = get_node_or_null("/root/Node3D/PointCanvasLayer")

func _pressed() -> void:
	if sceneroot != null and sceneroot.set_method(method) ==0:
		get_canvas_layer_node().visible = false
		pcl.visible = true
