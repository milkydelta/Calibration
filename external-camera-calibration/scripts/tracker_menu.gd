extends MenuButton
class_name TrackerMenu

@export var xrOrigin:XROrigin3D
@export var vive:XRNode3D
@export var cameraOrigin:Node3D

func _ready() -> void:
	get_popup().about_to_popup.connect(pre_popup)
	get_popup().id_pressed.connect(id_press)

func id_press(id: int) -> void:
	print(id)
	var orig:Node3D
	if id == 2048:
		orig = vive
	elif id == 1024:
		orig = xrOrigin
		
	
	cameraOrigin.reparent(orig,false)

func pre_popup() -> void:
	var pop = get_popup()
	pop.clear()
	pop.add_item("Static", 1024)
	if vive.get_is_active():
		pop.add_item("OpenXR: Vive tracker role - Camera", 2048)
