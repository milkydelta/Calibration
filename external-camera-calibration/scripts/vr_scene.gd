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

var base_fov: float = 75
var camHolder: Node3D
var adjlayer: CanvasLayer

enum SitState {PRE_METHOD, COLLECTING_POINTS, ESTIMATED, FAILURE}
var situationState: SitState = SitState.PRE_METHOD
var situationMethod: String = ""

var points: Array[Vector3] = []

var instructions: Array[String] = ["Record point at Camera Lens", "Record Top-Left point", "Record Bottom-Right point", "Record Top-Center Point"]
var instructions_magic: Array[String] = ["Record point at Camera Lens", "Record Top-Left point", "Record Bottom-Right point"]
var instructions_dlt: Array[String] =  ["Top-Left", "Top-Mid", "Top-Right",
										"Mid-Left", "Mid-Mid", "Mid-Right",
										"Bot-Left", "Bot-Mid", "Bot-Right",
										"Bot-Lef2", "Bot-Mi2", "Bot-Righ2"]

var dlt_s_points: Array[Vector2] = [Vector2(128,72),  Vector2(640,72),  Vector2(1152,72),
									Vector2(128,360), Vector2(640,360), Vector2(1152,360),
									Vector2(128,648), Vector2(640,648), Vector2(1152,648),
									Vector2(128,648), Vector2(640,648), Vector2(1152,648)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camHolder = specCam.get_parent_node_3d()
	adjlayer = get_node_or_null("AdjustmentCanvasLayer")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func set_method(to:String):
	if situationState == SitState.PRE_METHOD:
		situationMethod = to
		match to:
			"REGULAR":
				textLabel.text = instructions[0]
				situationState = SitState.COLLECTING_POINTS
			"MAGIC":
				textLabel.text = instructions_magic[0]
				situationState = SitState.COLLECTING_POINTS
			"BIGMATH":
				textLabel.text = instructions_dlt[0]
				situationState = SitState.COLLECTING_POINTS

func make_red(pos: Vector3):
	var dup = rcen.duplicate()
	dup.position = pos
	add_child(dup)
	
func make_blu(pos: Vector3):
	var dup = bcen.duplicate()
	dup.position = pos
	add_child(dup)
	
func make_ylw(pos: Vector3):
	var dup = ycen.duplicate()
	dup.position = pos
	add_child(dup)

func button_process(con_pos: Vector3):
	print(con_pos)
	
	points.append(con_pos)
	countLabel.text = str(points.size())
	if points.size() < instructions.size():
		textLabel.text = instructions[points.size()]
	else:
		textLabel.text = "No more points to record"
	
	if points.size() == 4:
		camHolder.position = points[0]
		var center = (points[1] + points[2])/2
		
		var plane: Plane = Plane(center-camHolder.position, center)
		var tc_pl: Vector3 = plane.intersects_ray(camHolder.position, (points[3]-camHolder.position).normalized())
		if tc_pl == null:
			return
		
		camHolder.look_at(center, (tc_pl - center).normalized())
		
		specCam.fov = rad_to_deg(atan( (tc_pl - center).length()*(5.0/4.0) / (center - camHolder.position).length() ))*2
		base_fov = specCam.fov
		
		print (rad_to_deg(atan( (tc_pl - center).length()*(5.0/4.0) / (center - camHolder.position).length() ))*2)

func button_process_magic(con_pos: Vector3):
	print(con_pos)
	points.append(con_pos)
	countLabel.text = str(points.size())
	if points.size() < instructions.size():
		textLabel.text = instructions[points.size()]
	else:
		textLabel.text = "No more points to record"

	make_red(con_pos)

	if points.size() == 3:
		camHolder.position = points[0]
		#var center = (points[1] + points[2])/2.0
		#var center = ((points[1] - points[0]) + (points[2] - points[0]))/2 + points[0]
		var center = camHolder.position.direction_to(points[1]).lerp(camHolder.position.direction_to(points[2]), 0.5).normalized()*1.5 + camHolder.position
		

		var plane: Plane = Plane(camHolder.position.direction_to(center), center)
		var tl_pl: Vector3 = plane.intersects_ray(camHolder.position, camHolder.position.direction_to(points[1]))
		var br_pl: Vector3 = plane.intersects_ray(camHolder.position, camHolder.position.direction_to(points[2]))
		if tl_pl == null or br_pl == null:
			textLabel.text = "Unable to place corner points on plane"
			situationState = SitState.FAILURE
			return

		var up = center.direction_to(tl_pl).rotated(plane.normal, atan(1280.0/720.0))
		up = up * sqrt((tl_pl-center).length()**2 / (1.77777777 ** 2 +1 ) )

		camHolder.look_at(center, camHolder.position + up)
		specCam.fov = (rad_to_deg(atan( (up).length()*(5.0/4.0) / (center - camHolder.position).length() ))*2)
		base_fov = specCam.fov
		print(base_fov)
		
		make_blu(tl_pl)
		make_blu(br_pl)
		make_blu(center)
		make_ylw(center + up)
		make_ylw(camHolder.position + up)
		
		situationState = SitState.ESTIMATED
		adjlayer.visible = true

func button_process_dlt(con_pos: Vector3):
	print(con_pos)
	points.append(con_pos)
	countLabel.text = str(points.size())
	if points.size() < instructions.size():
		textLabel.text = instructions[points.size()]
	else:
		textLabel.text = "No more points to record"

	make_red(con_pos)

	#if points.size() == 9:
		#var cal = RCalib.do_dlt(PackedVector3Array(points), PackedVector2Array(dlt_s_points))
		#print(cal)
		#if cal.size() >= 7:
			#camHolder.position = Vector3(cal[0], cal[1], cal[2])
			#camHolder.rotation = Quaternion(cal[3],cal[4],cal[5],cal[6]).get_euler()
			#situationState = SitState.ESTIMATED
		#pass


func on_con_button_released(action_name: String, pos: Vector3):
	if action_name == "menu_button" and situationState == SitState.COLLECTING_POINTS:
		match situationMethod:
			"REGULAR":
				button_process(pos)
			"MAGIC":
				button_process_magic(pos)
			"BIGMATH":
				button_process_dlt(pos)

func _on_left_con_button_released(action_name: String) -> void:
	on_con_button_released(action_name, leftCon.global_position)

func _on_right_con_button_released(action_name: String) -> void:
	on_con_button_released(action_name, rightCon.global_position)
