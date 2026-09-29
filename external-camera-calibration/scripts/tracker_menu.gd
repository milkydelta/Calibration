extends MenuButton
class_name TrackerMenu

@export var xrOrigin:XROrigin3D
@export var vive:XRNode3D
@export var cameraOrigin:Node3D
@export var vmc:VMCManager

func _ready() -> void:
	get_popup().about_to_popup.connect(pre_popup)
	get_popup().id_pressed.connect(id_press)

func id_press(id: int) -> void:
	print(id)
	var orig:Node3D

	match id / 1024:
		3:
			orig = vmc.nod
			vmc.active_track = id % 1024
		2:
			orig = vive
		1, _:
			orig = xrOrigin
		
	#print(XRServer.get_trackers(255))
	cameraOrigin.reparent(orig,false)

func pre_popup() -> void:
	var pop = get_popup()
	pop.clear()
	pop.add_item("Static", 1024)
	if vive.get_is_active() or vive.visible:
		pop.add_item("OpenXR: Vive tracker role - Camera", 2048)
	for i in vmc.serial_to_id:
		if Time.get_unix_time_from_system() - vmc.received_times[vmc.serial_to_id[i]] < 5:
			pop.add_item("VMC: "+i, 3072+vmc.serial_to_id[i])
