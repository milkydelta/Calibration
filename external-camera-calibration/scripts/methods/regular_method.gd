extends AbstractMethod

var instructions: Array[String] = ["Record point at Camera Lens", "Record Top-Left point", "Record Bottom-Right point", "Record Top-Center Point"]

func get_instruction(index:int) -> String:
	if index >= instructions.size() or index < 0:
		return ""
	return instructions[index]
	
func add_point(location:Vector3, manager:TheMan):
	pass

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
