extends AbstractMethod

var instructions_magic: Array[String] = ["Record point at Camera Lens", "Record Top-Left point", "Record Bottom-Right point"]

func get_instruction(index:int) -> String:
	if index >= instructions_magic.size() or index < 0:
		return ""
	return instructions_magic[index]
	
func add_point(location:Vector3, manager:TheMan):
	points.append(location)
	
	if points.size() == 3:
		var camHolder:Node3D = manager.camHolder
		var specCam:Camera3D = manager.specCam
		
		var tr:Transform3D = Transform3D()
		var fov:float = 0
		
		tr.origin = points[0]
		var center = tr.origin.direction_to(points[1]).lerp(tr.origin.direction_to(points[2]), 0.5).normalized()*1.5 + tr.origin
		

		var plane: Plane = Plane(tr.origin.direction_to(center), center)
		var tl_pl: Vector3 = plane.intersects_ray(tr.origin, tr.origin.direction_to(points[1]))
		var br_pl: Vector3 = plane.intersects_ray(tr.origin, tr.origin.direction_to(points[2]))
		if tl_pl == null or br_pl == null:
			manager.textLabel.text = "Unable to place corner points on plane"
			manager.situationState = TheMan.SitState.FAILURE
			return

		var up = center.direction_to(tl_pl).rotated(plane.normal, atan(1280.0/720.0))
		up = up * sqrt((tl_pl-center).length()**2 / (1.77777777 ** 2 +1 ) )

		tr = tr.looking_at(center, tr.origin + up)
		fov = (rad_to_deg(atan( (up).length()*(5.0/4.0) / (center - tr.origin).length() ))*2)
		
		manager.make_blu(tl_pl)
		manager.make_blu(br_pl)
		manager.make_blu(center)
		manager.make_ylw(center + up)
		manager.make_ylw(tr.origin + up)
		
		cam_estimated.emit(tr.origin, tr.basis.get_rotation_quaternion(), fov)
