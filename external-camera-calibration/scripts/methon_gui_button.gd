extends Button

@export var method: String = ""
var sceneroot: TheMan
var pcl: CanvasLayer

func _ready() -> void:
	sceneroot = get_node_or_null("/root/Node3D")
	pcl = get_node_or_null("/root/Node3D/PointCanvasLayer")

func _pressed() -> void:
	get_canvas_layer_node().visible = false
	if sceneroot != null:
		sceneroot.set_method(method)
	pcl.visible = true
