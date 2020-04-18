extends Spatial

onready var timer = $Timer
onready var column_timer = $ColumnTimer
var current_column = 0

var light_on_material = preload("res://Materials/LightOn.tres")
var light_material = preload("res://Materials/Light.tres")

func _ready():
	pass 


func _process(delta):
	pass


func _on_Button_flipped_on(row, col):
	for i in range(3):
		if i + 1 != row:
			get_node("Flat/Button_r{0}_c{1}".format([i + 1, col])).flip_off()


func _on_Timer_timeout():
	column_timer.start()


func _on_ColumnTimer_timeout():
	current_column += 1
	var last_column = 5
	if current_column > last_column:
		var light : MeshInstance = get_node("Flat/light_c{0}".format([last_column]))
		light.set_surface_material(0, light_material)
		column_timer.stop()
		current_column = 0
		timer.start()
	else:
		for column_idx in range(5):
			var light : MeshInstance = get_node("Flat/light_c{0}".format([column_idx + 1]))
			if column_idx + 1 == current_column:
				light.set_surface_material(0, light_on_material)
			else:
				light.set_surface_material(0, light_material)
			for row_idx in range(3):
				var button = get_node("Flat/Button_r{0}_c{1}".format([row_idx + 1, current_column]))
				if button.is_on:
					for child in button.get_children():
						if child is AudioStreamPlayer:
							child.play()
		
		
