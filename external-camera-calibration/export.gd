extends Button

@export var specCam: Camera3D

func godot_to_unity(pos: Vector3) -> Vector3:
	var p = pos
	p.z = -p.z
	return p

func godot_to_unity_rot(euler_rad: Vector3) -> Vector3:
	var quat = Quaternion.from_euler(euler_rad)
	quat.x = -quat.x
	quat.y = -quat.y
	return quat.get_euler(EULER_ORDER_ZXY)
	#return quat.get_euler(EULER_ORDER_YXZ)
	

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _pressed() -> void:
	var pos = godot_to_unity(specCam.global_position)
	var rot = godot_to_unity_rot(specCam.global_rotation)
	var file = FileAccess.open(OS.get_executable_path().get_base_dir() + "/externalcamera.cfg",FileAccess.WRITE)
	var cfgstr = ""
	
	cfgstr += "x="+str(pos.x) + "\n"
	cfgstr += "y="+str(pos.y) + "\n"
	cfgstr += "z="+str(pos.z) + "\n"
	
	cfgstr += "rx="+str(rad_to_deg(rot.x)) + "\n"
	cfgstr += "ry="+str(rad_to_deg(rot.y)) + "\n"
	cfgstr += "rz="+str(rad_to_deg(rot.z)) + "\n"
	
	cfgstr += "fov="+str(specCam.fov) + "\n"
	file.store_string(cfgstr)
