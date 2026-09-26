extends AbstractMethod

var instructions_dlt: Array[String] =  ["Top-Left", "Top-Mid", "Top-Right",
										"Mid-Left", "Mid-Mid", "Mid-Right",
										"Bot-Left", "Bot-Mid", "Bot-Right",
										"Bot-Lef2", "Bot-Mi2", "Bot-Righ2"]

var dlt_s_points: Array[Vector2] = [Vector2(128,72),  Vector2(640,72),  Vector2(1152,72),
									Vector2(128,360), Vector2(640,360), Vector2(1152,360),
									Vector2(128,648), Vector2(640,648), Vector2(1152,648),
									Vector2(128,648), Vector2(640,648), Vector2(1152,648)]

func get_instruction(index:int) -> String:
	if index >= instructions_dlt.size() or index < 0:
		return ""
	return instructions_dlt[index]
	
func add_point(location:Vector3, manager:TheMan):
	pass
	
func button_process_dlt(con_pos: Vector3):
	print(con_pos)
	points.append(con_pos)
	countLabel.text = str(points.size())
	if points.size() < instructions.size():
		textLabel.text = instructions[points.size()]
	else:
		textLabel.text = "No more points to record"

	make_red(con_pos)

	if points.size() == 9:
		var cal = RCalib.do_dlt(PackedVector3Array(points), PackedVector2Array(dlt_s_points))
		print(cal)
		if cal.size() >= 7:
			camHolder.position = Vector3(cal[0], cal[1], cal[2])
			camHolder.rotation = Quaternion(cal[3],cal[4],cal[5],cal[6]).get_euler()
			situationState = SitState.ESTIMATED
		pass
