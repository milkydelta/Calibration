extends HSlider

@export var lab: Label

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _value_changed(new_value: float) -> void:
	lab.text = str(new_value)
