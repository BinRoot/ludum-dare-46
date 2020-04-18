extends Spatial

signal round_ended

onready var alive_meter : ProgressBar = $Control/AliveMeter
onready var time_label : Label = $Control/TimePanel/TimeLabel
onready var round_end_timer : Timer = $RoundEnd
onready var crowd : Spatial = $Crowd
onready var board : Spatial = $Stage/Board
onready var fireworks : Particles = $Fireworks

onready var person_scene = preload("res://Scenes/Person.tscn")

var _people

func _ready():
	#populate_people(5)
	_people = get_tree().get_nodes_in_group("person")
	
func init_inventory(item_dict):
	board.enable_buttons(item_dict)

func populate_people(num):
	for i in range(num):
		_people = get_tree().get_nodes_in_group("person")
		var candidate_vecs = []
		var min_penalty = 99999
		var min_penalty_idx = -1
		for ridx in range(50):
			var candidate_vec = Vector3((randf() - 0.5) * 20, 0, (randf() - 0.5) * 3)
			candidate_vecs.append(candidate_vec);
			var penalty = 0
			for p in _people:
				if (candidate_vec + crowd.global_transform.origin).distance_to(p.global_transform.origin) < 1:
					penalty += 1
			if penalty < min_penalty:
				min_penalty = penalty
				min_penalty_idx = ridx
		var person = person_scene.instance()
		crowd.add_child(person)
		person.translation += candidate_vecs[min_penalty_idx]
		
	_people = get_tree().get_nodes_in_group("person")

func _process(delta):
	if len(_people) > 0:
		var avg_vibe = 0.0
		for person in _people:
			avg_vibe += person.vibe
		avg_vibe /= len(_people)
		alive_meter.value = (avg_vibe / 3.0) * 100
	time_label.text = str(int(round_end_timer.time_left))

func _on_Board_pattern_emitted(pattern):
	get_tree().call_group("person", "handle_pattern", pattern)


func _on_RoundEnd_timeout():
	var cash = pow(alive_meter.value * len(_people), 1.1)
	emit_signal("round_ended", cash)


func _on_Board_fireworks_emitted():
	fireworks.restart()
