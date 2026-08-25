extends Node3D

var xr_interface: XRInterface

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("Initialised OpenXR")
		get_viewport().use_xr = true
	else:
		print("Could not initialise OpenXR")
