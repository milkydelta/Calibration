extends GridContainer

var sceneroot: TheMan
var s_x: Range
var s_y: Range
var s_z: Range
var s_rx: Range
var s_ry: Range
var s_rz: Range
var s_fov: Range
@export var cam: Camera3D

var rot: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	s_x   = get_node_or_null("SliderX")
	s_y   = get_node_or_null("SliderY")
	s_z   = get_node_or_null("SliderZ")
	s_rx  = get_node_or_null("SliderRx")
	s_ry  = get_node_or_null("SliderRy")
	s_rz  = get_node_or_null("SliderRz")
	s_fov = get_node_or_null("sliderFov")
	sceneroot = get_node_or_null("/root/Node3D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	cam.position.x = s_x.value * 0.01
	cam.position.y = s_y.value * 0.01
	cam.position.z = s_z.value * 0.01
	rot.x = s_rx.value
	rot.y = s_ry.value
	rot.z = s_rz.value
	cam.rotation_degrees = rot
	cam.fov = sceneroot.base_fov + s_fov.value
