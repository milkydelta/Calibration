extends CanvasItem


func _ready() -> void:
	if not OS.is_debug_build():
		visible = false
