extends Spatial

onready var alive_meter : ProgressBar = $Control/AliveMeter

func _ready():
	pass 

func _process(delta):
	var people = get_tree().get_nodes_in_group("person")
	if len(people) > 0:
		var avg_vibe = 0.0
		for person in people:
			avg_vibe += person.vibe
		avg_vibe /= len(people)
		print(avg_vibe)
		alive_meter.value = (avg_vibe / 3.0) * 100


func _on_Board_pattern_emitted(pattern):
	get_tree().call_group("person", "handle_pattern", pattern)

