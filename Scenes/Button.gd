extends Spatial

signal flipped_on

export var row = 1
export var col = 1

onready var mesh = $MeshInstance

var button_material = preload("res://Materials/Button.tres")
var button_on_material = preload("res://Materials/ButtonOn.tres")

var is_on = false

var _original_translation : Vector3

func _ready():
	_original_translation = translation


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func flip_on():
	translation = _original_translation
	translation.y -= 0.02
	is_on = true
	mesh.set_surface_material(0, button_on_material)
	emit_signal("flipped_on", row, col)
	
func flip_off():
	is_on = false
	mesh.set_surface_material(0, button_material)
	translation = _original_translation
	

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("{0}: {1}".format([name, event]))
		if is_on:
			flip_off()
		else:
			flip_on()
