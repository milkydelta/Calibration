extends Node
class_name VMCManager

@export var nod:Node3D

var server:OSCServer
var received_times: Dictionary[int,float] = {}
var received_vecs: Dictionary[int, Vector3] = {}
var received_quat: Dictionary[int, Quaternion] = {}
var serial_to_id: Dictionary[String, int] = {}

var active_track: int = -1

func _on_message(address: String, value: Array, time: float):
	if address != "/vnyan/tracker/pos" and address != "/VMC/Ext/Tra/Pos":
		return

	if value.size() != 8 or !(value[0] is String):
		return

	if serial_to_id.has(value[0]):
		var id = serial_to_id[value[0]]
		received_times[id] = time
		received_vecs[id] = Vector3(value[1],value[2],-value[3])
		received_quat[id] = Quaternion(-value[4],-value[5],value[6],value[7])
	else:
		serial_to_id[value[0]] = -1
		serial_to_id[value[0]] = serial_to_id.keys().find(value[0])
		if serial_to_id[value[0]] == -1:
			serial_to_id[value[0]] =0


	
func _ready() -> void:
	var temp = get_child(0)
	
	if temp is OSCServer:
		server = temp
	else:
		return
	
	server.timecode_as_unix = true
	
	server.message_received.connect(_on_message)
	
func _process(delta: float) -> void:
	if active_track >=0:
		nod.position = received_vecs[active_track]
		nod.quaternion = received_quat[active_track]
