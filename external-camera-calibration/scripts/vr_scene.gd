extends Node3D
class_name TheMan

@export var specCam: Camera3D
@export var leftCon: XRController3D
@export var rightCon: XRController3D
@export var textLabel: Label
@export var countLabel: Label

@export var rcen: MeshInstance3D
@export var bcen: MeshInstance3D
@export var ycen: MeshInstance3D

@export var zeroPoint: Node3D

var methodClass:AbstractMethod

var base_fov: float = 75
var camHolder: Node3D
var adjlayer: CanvasLayer

enum SitState {PRE_METHOD, COLLECTING_POINTS, ESTIMATED, FAILURE}
var situationState: SitState = SitState.PRE_METHOD


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camHolder = specCam.get_parent_node_3d()
	adjlayer = get_node_or_null("AdjustmentCanvasLayer")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func set_method(to:String) ->int:
	if situationState == SitState.PRE_METHOD:
		var sc:GDScript
		match to:
			"REGULAR":
				sc= load("res://scripts/methods/regular_method.gd")
			"MAGIC":
				sc= load("res://scripts/methods/magic_method.gd")
			"BIGMATH":
				sc= load("res://scripts/methods/rust_method.gd")
		
		# The script files above are compiled when they are loaded. If there's a syntax error, it'll happen then.
		# In the editor, that error is noticed and the debugger pauses execution. Unfortunately, error handling
		# with try/catch isn't a thing, and never will be. If there a syntax error, new() "doesn't exist", so I
		# need to run this check. The return value is to make sure the method selection screen doesn't disappear.
		if sc == null or !sc.can_instantiate():
			return -1
		
		methodClass = sc.new()
		textLabel.text = methodClass.get_instruction(0)
		situationState = SitState.COLLECTING_POINTS
		methodClass.cam_estimated.connect(_receive_estimation)
		return 0
	return -2

func make_red(pos: Vector3):
	var dup = rcen.duplicate()
	dup.position = pos
	zeroPoint.add_child(dup)
	
func make_blu(pos: Vector3):
	var dup = bcen.duplicate()
	dup.position = pos
	zeroPoint.add_child(dup)
	
func make_ylw(pos: Vector3):
	var dup = ycen.duplicate()
	dup.position = pos
	zeroPoint.add_child(dup)
	
func _receive_estimation(pos:Vector3, rot:Quaternion, vFov:float):
	#camHolder.reparent(zeroPoint)
	camHolder.position = pos
	camHolder.quaternion = rot
	specCam.fov=vFov
	
	situationState = SitState.ESTIMATED
	adjlayer.visible= true
	textLabel.get_canvas_layer_node().visible=false
	

func on_con_button_released(action_name: String, pos: Vector3):
	if action_name == "menu_button" and situationState == SitState.COLLECTING_POINTS:
		pos = zeroPoint.to_local(pos)
		
		make_red(pos)
		methodClass.add_point(pos, self)
		countLabel.text = str(methodClass.points.size())
		if situationState != SitState.FAILURE:
			textLabel.text = methodClass.get_instruction(methodClass.points.size())

func _on_left_con_button_released(action_name: String) -> void:
	on_con_button_released(action_name, leftCon.global_position)

func _on_right_con_button_released(action_name: String) -> void:
	on_con_button_released(action_name, rightCon.global_position)
